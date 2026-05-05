local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon: 1 Level 6 FIRE monster
    Link.AddProcedure(c,s.matfilter,1,1)
    c:EnableReviveLimit()
    
    -- Ko bị chọn làm mục tiêu (Hazy Flame standard)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    
    -- FIX: Cấm Special Summon ngoại trừ Hazy Flame
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(1,0)
    e2:SetTarget(s.splimit)
    c:RegisterEffect(e2)
    
    -- FIX: Triệu hồi 1 Hazy Flame từ Deck khi Link Summon thành công
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
    
    -- FIX: Cấp hiệu ứng "Không bị tiêu diệt bởi chiến đấu" cho Basiltrice
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_BE_MATERIAL)
    e4:SetCondition(s.efcon)
    e4:SetOperation(s.efop)
    c:RegisterEffect(e4)
end

-- Filter nguyên liệu
function s.matfilter(c,scard,sumtype,tp)
    return c:IsLevel(6) and c:IsAttribute(ATTRIBUTE_FIRE)
end

-- FIX logic cấm xồ: Trả về true nếu quái KHÔNG PHẢI Hazy Flame (để hệ thống cấm)
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not c:IsSetCard(0x67)
end

-- Điều kiện: Phải là Link Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- FIX Target SS: Kiểm tra Deck có quái Hazy không
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x67) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- FIX Operation SS: Thực hiện gọi bài
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- FIX Grant Effect: Sử dụng EVENT_BE_MATERIAL để gắn hiệu ứng vĩnh viễn vào quái Xyz
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
    -- Kiểm tra xem có phải làm nguyên liệu cho Xyz Summon Basiltrice không
    return r==REASON_XYZ and e:GetHandler():GetReasonCard():IsCode(23776077)
end

function s.efop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=c:GetReasonCard() -- Basiltrice
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    rc:RegisterEffect(e1)
end
