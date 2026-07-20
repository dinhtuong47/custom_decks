local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddCodeList(c,100016)

    local e1=Effect.CreateEffect(c) 
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(100000)
    c:RegisterEffect(e1)

    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
    e5:SetCategory(CATEGORY_POSITION)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,id)
    e5:SetCost(s.poscost)
    e5:SetTarget(s.postg)
    e5:SetOperation(s.posop)
    c:RegisterEffect(e5)

    local e6=Effect.CreateEffect(c)
    e6:SetCategory(CATEGORY_POSITION)
    e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_F)
    e6:SetProperty(EFFECT_FLAG_DELAY)
    e6:SetTarget(s.fliptg)
    e6:SetOperation(s.flipop)
    c:RegisterEffect(e6)

    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e7:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    e7:SetOperation(s.fssop)
    c:RegisterEffect(e7)
end

function s.aclimit(e,re,tp)
    return re:GetHandler():IsFacedown()
end

function s.poslimit(e,c)
    return c:IsFacedown()
end

function s.cfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xBB9) and c:IsAbleToRemoveAsCost()
end

function s.posfilter(c)
    return c:IsFaceup() and not c:IsType(TYPE_TOKEN) and not c:IsType(TYPE_LINK)
end

function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    local tc=g:GetFirst()
    if tc and tc:IsFaceup() then
        if tc:IsType(TYPE_MONSTER) then
            Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
        else
            Duel.ChangePosition(tc,POS_FACEDOWN)
            if tc:IsType(TYPE_CONTINUOUS) or tc:IsType(TYPE_FIELD) or tc:IsType(TYPE_EQUIP) then
                local ch=Duel.GetCurrentChain()
                for i=1,ch do
                    local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
                    if te and te:GetHandler()==tc then
                        Duel.ChangeChainOperation(i,function(e,tp,eg,ep,ev,re,r,rp) end)
                    end
                end
            end
        end
    end
end

function s.fliptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    if g:GetCount()>0 then
        Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
    end
end

function s.fssop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetValue(aux.tgoval)
    e1:SetReset(RESET_EVENT+0x1fe0000)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET) 
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,1)
    e2:SetValue(s.aclimit)
    e2:SetReset(RESET_EVENT+0x1fe0000)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET) 
    e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0,1)
    e3:SetReset(RESET_EVENT+0x1fe0000)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(0,LOCATION_MZONE) 
    e4:SetTarget(s.poslimit)
    e4:SetReset(RESET_EVENT+0x1fe0000)
    c:RegisterEffect(e4)
    
    c:RegisterFlagEffect(0,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
end
