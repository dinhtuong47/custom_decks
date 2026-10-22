local s,id=GetID()
function s.initial_effect(c)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e1:SetTarget(s.protg)
    e1:SetValue(s.indval)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_REMOVE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_SET_AVAILABLE)
    e2:SetTargetRange(0,1)
    e2:SetTarget(s.rmtg)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_MSET)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCondition(s.poscon)
    e3:SetOperation(s.posop)
    c:RegisterEffect(e3)
    
    local e5=e3:Clone()
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e5)
    
    local e6=e3:Clone()
    e6:SetCode(EVENT_CHANGE_POS)
    c:RegisterEffect(e6)
    
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_POSITION)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.postg2)
    e4:SetOperation(s.posop2)
    c:RegisterEffect(e4)
    
end

function s.protg(e,c)
    return c:IsFacedown()
end

function s.indval(e,re,rp)
    return rp==1-e:GetHandlerPlayer()
end

function s.rmtg(e,c,tp,r,re)
    return c:IsControler(e:GetHandlerPlayer()) and c:IsLocation(LOCATION_MZONE) and c:IsFacedown() and r==REASON_EFFECT
end

function s.posfilter(c,tp)
    return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsControler(tp) and c:IsSetCard(0xFA0)
end

function s.poscon(e,tp,eg,ep,ev,re,r,rp)
    if e:GetCode()==EVENT_CHANGE_POS and (r&REASON_FLIP)~=0 then return false end
    return eg:IsExists(s.posfilter,1,nil,tp)
end

function s.target_filter(c)
    return c:IsFacedown() and c:IsPosition(POS_FACEDOWN_ATTACK) and c:GetSequence()<5
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.posfilter,nil,tp)
    for tc in aux.Next(g) do
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
        local pos=Duel.SelectPosition(tp,tc,POS_FACEDOWN_ATTACK+POS_FACEDOWN_DEFENSE)
        if pos==POS_FACEDOWN_ATTACK then
            Duel.ChangePosition(tc,POS_FACEDOWN_ATTACK)
        end
    end
    local sg=Duel.GetMatchingGroup(s.target_filter,tp,LOCATION_MZONE,0,nil)
    if #sg>=2 then
        if Duel.GetCurrentChain()>0 then
            local shuf=Effect.CreateEffect(e:GetHandler())
            shuf:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            shuf:SetCode(EVENT_CHAIN_SOLVED)
            shuf:SetOperation(s.shufop)
            Duel.RegisterEffect(shuf,tp)
        else
            Duel.BreakEffect()
            Duel.ShuffleSetCard(sg)
        end
    end
end

function s.shufop(e,tp,eg,ep,ev,re,r,rp)
    local sg=Duel.GetMatchingGroup(s.target_filter,tp,LOCATION_MZONE,0,nil)
    if #sg>=2 then
        Duel.ShuffleSetCard(sg)
    end
    e:Reset()
end


--end phase

function s.posfilter2(c)
    return c:IsFaceup() and c:IsCanTurnSet()
end

function s.postg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter2,tp,LOCATION_MZONE,0,1,nil) end
    local g=Duel.GetMatchingGroup(s.posfilter2,tp,LOCATION_MZONE,0,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end

function s.posop2(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(s.posfilter2,tp,LOCATION_MZONE,0,nil)
    if #g>0 then
        Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
    end
end
