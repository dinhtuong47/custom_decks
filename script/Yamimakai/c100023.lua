local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.atkcon)
    e2:SetCost(s.poscost)
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(s.tgcon)
    e3:SetCost(s.poscost)
    e3:SetTarget(s.tgtg)
    e3:SetOperation(s.tgop)
    c:RegisterEffect(e3)
end

function s.cfilter(c)
    return c:IsFaceup() and c:IsCode(59197169)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
        Duel.ConfirmCards(1-tp,c)
    end
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local d=Duel.GetAttackTarget()
    return d and d:IsControler(tp) and d~=e:GetHandler() and e:GetHandler():IsFacedown()
end

function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
    local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
    return g and g:IsExists(Card.IsType,1,e:GetHandler(),TYPE_MONSTER) and e:GetHandler():IsFacedown()
end

function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsFacedown() end
    e:SetLabel(c:GetPosition())
    Duel.ChangePosition(c,POS_FACEUP_ATTACK)
end

function s.rmfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==POS_FACEDOWN_ATTACK then
        local bg=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
        if #bg>0 then
            Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
        end
    end
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==POS_FACEDOWN_ATTACK then
        local bg=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
        if #bg>0 then
            Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
        end
    end
end

function s.rmop(tp)
    local bg=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if #bg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local sg=bg:Select(tp,1,1,nil)
        if #sg>0 then
            Duel.BreakEffect()
            Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
        end
    end
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        Duel.ChangeAttackTarget(c)
        if e:GetLabel()==POS_FACEDOWN_ATTACK then
            s.rmop(tp)
        end
    end
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local g=Group.FromCards(c)
        Duel.ChangeTargetCard(ev,g)
        if e:GetLabel()==POS_FACEDOWN_ATTACK then
            s.rmop(tp)
        end
    end
end
