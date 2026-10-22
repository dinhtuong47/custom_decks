local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_LEAVE_GRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id + EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.acttg)
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfa0))
    e2:SetValue(600)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.defcon)
    e3:SetOperation(s.defop)
    c:RegisterEffect(e3)
end

function s.tzfilter(c)
    return c:IsCode(59197169) and not c:IsForbidden()
end

function s.costfilter(c)
    return c:IsSetCard(0xfa0) and not (c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS)) and c:IsAbleToGraveAsCost()
end

function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if Duel.IsExistingMatchingCard(s.tzfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local cg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
        Duel.SendtoGrave(cg,REASON_COST)
        e:SetLabel(1)
    else
        e:SetLabel(0)
    end
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    if e:GetLabel()==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local tc=Duel.SelectMatchingCard(tp,s.tzfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
        if tc then
            local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0) or Duel.GetFieldCard(tp,LOCATION_SZONE,5)
            if fc then
                Duel.SendtoGrave(fc,REASON_RULE)
                Duel.BreakEffect()
            end
            Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
        end
    end
end

function s.cfilter(c)
    return c:IsFaceup() and c:IsCode(59197169)
end

function s.defcon(e,tp,eg,ep,ev,re,r,rp)
    local ac=Duel.GetBattleMonster(tp) 
    return ac and not ac:IsType(TYPE_LINK)
    and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end

function s.defop(e,tp,eg,ep,ev,re,r,rp)
    local ac=Duel.GetBattleMonster(tp) 
    if ac then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(ac:GetDefense())
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
        ac:RegisterEffect(e1)
    end
end
