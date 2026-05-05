local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon: 1 Level 6 FIRE monster
    -- Cu phap: c, filter, min, max, special_check
    Link.AddProcedure(c,s.matfilter,1,1)
    c:EnableReviveLimit()
    
    -- Cannot be targeted
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    
    -- Lock Special Summon (Hazy Flame only)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(1,0)
    e2:SetTarget(s.splimit)
    c:RegisterEffect(e2)
    
    -- Special Summon from Deck
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
    
    --Gain Effect (Xyz Material)
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_BE_MATERIAL)
    e4:SetCondition(s.effcon)
    e4:SetOperation(s.effop)
    c:RegisterEffect(e4)

    -- Hỗ trợ Hazy Pillar (Gắn thủ công)
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_MOVE) 
    e5:SetCondition(s.attachcon)
    e5:SetOperation(s.effop) -- Dùng chung operation với e4
    c:RegisterEffect(e5)
end

-- Filter nguyen lieu: Level 6 va thuoc tinh LUA
function s.matfilter(c,scard,sumtype,tp)
    return c:IsLevel(6) and c:IsAttribute(ATTRIBUTE_FIRE)
end

--SS Lock: Chan tat ca quai khong phai Hazy Flame
function s.splimit(e,c)
    return not c:IsSetCard(0x67)
end

-- Condition: Phai la Link Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- Target & Operation: SS 1 Hazy Flame tu Deck
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x67) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

--Hieu ung thua huong cho Basiltrice
-- Kiểm tra khi triệu hồi Xyz bình thường
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
    return r==REASON_XYZ
end

-- Kiểm tra khi bị "attach" bởi hiệu ứng card (như Hazy Pillar)
function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Kiểm tra nếu card đang ở trong vùng Xyz Material và trước đó nó ở trên sân
    return c:IsLocation(LOCATION_OVERLAY) and c:GetDestinationType()==LOCATION_OVERLAY
end

-- Operation cấp hiệu ứng (giữ nguyên logic cũ nhưng thêm check kỹ hơn)
function s.effop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=c:GetOverlayTarget() -- Lấy con Xyz đang chứa nó làm nguyên liệu
    
    -- Nếu triệu hồi Xyz thông thường thì dùng GetReasonCard
    if not rc then rc=c:GetReasonCard() end 
    
    -- Kiểm tra nếu đúng là Basiltrice (23776077)
    if rc and rc:IsCode(23776077) then
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,1))
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        rc:RegisterEffect(e1,true)
    end
end
