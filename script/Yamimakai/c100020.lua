local s, id = GetID()

function s.initial_effect(c)
    
    
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_NEGATE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_DAMAGE_STEP)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.negcon)
    e3:SetCost(s.negcost)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)

    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EVENT_FLIP)
    e4:SetOperation(s.flipop)
    c:RegisterEffect(e4)
    
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetCategory(CATEGORY_ATKCHANGE)
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_FLIP)
    e5:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1, id + 1)
    e5:SetCondition(s.rmcon)
    e5:SetTarget(s.rmtg)
    e5:SetOperation(s.rmop)
    c:RegisterEffect(e5)
end

function s.splimit(e, se, sp, st)
    return se:GetHandler():IsSetCard(0xFA0)
end

--[[function s.cfilter(c)
    return c:IsFaceup()
end

function s.ntcon(e,c,minc)
    if c==nil then return true end
    local tp=c:GetControler()
    return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.cfilter(c)
    return c:IsFaceup() and c:IsCode(100025)
end
function s.tgcon(e)
    return Duel.IsExistingMatchingCard(s.cfilter, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end
function s.tgtg(e, c)
    return c:IsFacedown()
end]]--

function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    return rp ~= tp and e:GetHandler():IsFacedown() and Duel.IsChainNegatable(ev)
end
function s.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsFacedown() end
    Duel.ChangePosition(c, POS_FACEUP_ATTACK)
end
function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
end
function s.negop(e, tp, eg, ep, ev, re, r, rp)
    Duel.NegateActivation(ev)
end

function s.flipop(e, tp, eg, ep, ev, re, r, rp)
    e:GetHandler():RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 1)
end
function s.rmfilter(c, tp)
    return c:IsControler(tp) and c:GetPreviousPosition() == POS_FACEDOWN_ATTACK
end
function s.rmcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsFaceup() and c:GetFlagEffect(id) > 0 and eg:IsExists(s.rmfilter, 1, nil, tp)
end
function s.atkfilter(c)
    return c:IsFaceup()
end
function s.rmtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.atkfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g = Duel.SelectTarget(tp, s.atkfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_ATKCHANGE, g, 1, 0, 0)
end
function s.rmop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-2600)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end