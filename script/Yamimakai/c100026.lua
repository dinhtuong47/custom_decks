local s, id = GetID()

function s.initial_effect(c)
    Duel.AddCustomActivityCounter(id, ACTIVITY_SPSUMMON, s.counterfilter)

    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id + EFFECT_COUNT_CODE_OATH)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)  
end

function s.counterfilter(c)
    return c:IsRace(RACE_FIEND)
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then 
        return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, e:GetHandler()) 
        and Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON) == 0 
    end
    Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST + REASON_DISCARD, nil)
    
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1, 0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(e1, tp)
end

function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
    return not c:IsRace(RACE_FIEND)
end

function s.spfilter(c, e, tp)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xFA0) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEDOWN_DEFENSE)
    and (c:IsLocation(LOCATION_DECK) or c:IsFaceup())
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        if Duel.IsPlayerAffectedByEffect(tp, 59822133) then return false end
        if Duel.GetLocationCount(tp, LOCATION_MZONE) < 2 then return false end
        local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_DECK+LOCATION_REMOVED, 0, nil, e, tp)
        return g:GetClassCount(Card.GetCode) >= 2
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp, LOCATION_DECK+LOCATION_REMOVED)
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    if Duel.IsPlayerAffectedByEffect(tp, 59822133) then return end
    if Duel.GetLocationCount(tp, LOCATION_MZONE) < 2 then return end
    local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_DECK+LOCATION_REMOVED, 0, nil, e, tp)
    if g:GetCount() < 2 then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local sg = g:SelectSubGroup(tp, aux.dncheck, false, 2, 2)
    if sg and sg:GetCount() == 2 then
        Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEDOWN_DEFENSE)
        Duel.ConfirmCards(1 - tp, sg)
    end
end
