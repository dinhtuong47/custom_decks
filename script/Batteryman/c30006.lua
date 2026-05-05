local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon: 1 Level 6 FIRE monster
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
    
    -- Cấp hiệu ứng cho quái thú Xyz (Basiltrice)
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e4:SetRange(LOCATION_OVERLAY)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(s.eftg)
    e4:SetItemProperty(EFFECT_FLAG_CLIENT_HINT)
    e4:SetLabelObject(s.eff_indes) -- Trỏ đến hiệu ứng muốn cấp
    c:RegisterEffect(e4)
end

-- Hiệu ứng được cấp: Không bị tiêu diệt bởi chiến đấu
s.eff_indes=Effect.CreateEffect(c)
s.eff_indes:SetDescription(aux.Stringid(id,1))
s.eff_indes:SetType(EFFECT_TYPE_SINGLE)
s.eff_indes:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
s.eff_indes:SetValue(1)
s.eff_indes:SetReset(RESET_EVENT+RESETS_STANDARD)

-- Filter nguyên liệu Link
function s.matfilter(c,scard,sumtype,tp)
    return c:IsLevel(6) and c:IsAttribute(ATTRIBUTE_FIRE)
end

-- SS Lock
function s.splimit(e,c)
    return not c:IsSetCard(0x67)
end

-- Link Summon Condition
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- SS Hazy từ Deck
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

-- Target check: Chỉ cấp hiệu ứng nếu nó đang là Material của Basiltrice
function s.eftg(e,c)
    local g=e:GetHandler():GetOverlayTarget()
    return g and c==g and c:IsCode(23776077)
end
