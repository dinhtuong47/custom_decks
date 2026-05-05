local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon: 1 Level 6 FIRE monster
    Link.AddProcedure(c,s.matfilter,1,1)
    c:EnableReviveLimit()
    
    -- 1. Anti-Target
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    
    -- 2. Cấm SS: Chỉ kích hoạt khi card đã lên sân thành công
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(1,0)
    e2:SetTarget(s.splimit)
    c:RegisterEffect(e2)
    
    -- 3. Triệu hồi từ Deck: Thêm FLAG_DELAY để tránh bị lỡ timing
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
    
    -- 4. Cấp hiệu ứng Bất tử: Dùng EFFECT_TYPE_GRANT để nó luôn hoạt động khi là nguyên liệu
    -- Cách này hỗ trợ cả khi dùng Hazy Pillar nhét vào
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e4:SetRange(LOCATION_OVERLAY)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(s.eftg)
    e4:SetLabelObject(s.indes_effect())
    c:RegisterEffect(e4)
end

-- Filter Link
function s.matfilter(c,scard,sumtype,tp)
    return c:IsLevel(6) and c:IsAttribute(ATTRIBUTE_FIRE)
end

-- Fix Cấm SS: Chỉ cấm nếu quái không phải Hazy
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not c:IsSetCard(0x67)
end

-- Check Link Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- Target & Operation cho hiệu ứng xồ quái
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

-- Hiệu ứng bất tử để cấp cho Xyz
function s.indes_effect()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    return e1
end

-- Target của EFFECT_GRANT: Chỉ cấp cho Basiltrice đang đè lên nó
function s.eftg(e,c)
    return e:GetHandler():GetOverlayTarget()==c and c:IsCode(23776077)
end
