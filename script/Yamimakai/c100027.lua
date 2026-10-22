local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    --[[e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)]]--
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)

end

function s.tgfilter(c)
    return c:IsSetCard(0xfa0) and not c:IsType(TYPE_LINK+TYPE_TOKEN)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local pos=tc:GetPosition()
        if pos==POS_FACEUP_ATTACK then
            Duel.ChangePosition(tc,POS_FACEDOWN_ATTACK)
        elseif pos==POS_FACEDOWN_ATTACK then
            Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
        elseif pos==POS_FACEUP_DEFENSE then
            Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
        elseif pos==POS_FACEDOWN_DEFENSE then
            Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
        end
    end
end

--Ss
function s.spfilter(c,e,tp)
    if not (c:IsRace(RACE_FIEND)
        and (c:GetAttack()==2000 or c:GetAttack()==2600)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)) then return false end
    return c:IsLocation(LOCATION_HAND) or c:IsFaceup()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
        Duel.ConfirmCards(1-tp,g)
    end
end

