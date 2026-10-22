local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.con1)
    e1:SetCost(s.cost1)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)
    local e1a=e1:Clone()
    e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1a)
    local e1b=e1:Clone()
    e1b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e1b)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetTarget(s.reptg)
    e2:SetValue(s.repval)
    e2:SetOperation(s.repop)
    c:RegisterEffect(e2)

end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsControler,1,nil,1-tp)
end

function s.posfilter(c)
    return c:IsFacedown() and c:IsSetCard(0xfa0)
end

function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
    tc:CreateEffectRelation(e)
    e:SetLabelObject(tc)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetCard(eg)
    local tc=e:GetLabelObject()
    if tc then
        Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
    end
    local dg=eg:Filter(Card.IsControler,nil,1-tp)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if not tg then return end
    local dg=tg:Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsControler,nil,1-tp)
    if #dg>0 and Duel.Destroy(dg,REASON_EFFECT)~=0 then
        local tc=e:GetLabelObject()
        if tc and tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
            Duel.BreakEffect()
            Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
        end
    end
end

--replace
function s.repfilter(c,tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and (c:IsSetCard(0xfa0) or c:IsCode(59197169)) and c:IsFaceup()
        and not c:IsReason(REASON_REPLACE) and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT))
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToRemove() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
        and eg:IsExists(s.repfilter,1,nil,tp) end
    return Duel.SelectEffectYesNo(tp,c,96)
end

function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end