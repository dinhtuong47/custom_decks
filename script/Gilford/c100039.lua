local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,36354007)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    
    s.listed_names={36354007,100035}
end

function s.cfilter(c)
    return c:IsFaceup() and (c:IsCode(36354007) or aux.IsCodeListed(c,36354007))
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
    if mg:GetCount()==0 or mg:FilterCount(s.cfilter,nil)~=mg:GetCount() then return false end
    
    local fg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    if fg:GetCount()==0 then return false end
    local maxg=fg:GetMaxGroup(Card.GetAttack)
    return maxg:IsExists(Card.IsControler,1,nil,1-tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,100035) 
    end
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount()-1,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local sg=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,100035)
    if sg:GetCount()==0 then return end
    local show_c=sg:GetFirst()
    if show_c:IsLocation(LOCATION_HAND+LOCATION_DECK) then
        Duel.ConfirmCards(1-tp,sg)
    else
        Duel.HintSelection(sg)
    end

    local fg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    if fg:GetCount()==0 then return end
    local maxg=fg:GetMaxGroup(Card.GetAttack)
    local opmaxg=maxg:Filter(Card.IsControler,nil,1-tp)
    if opmaxg:GetCount()==0 then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local keep_tc=opmaxg:Select(tp,1,1,nil):GetFirst()
    if not keep_tc then return end
    
    local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,keep_tc)
    dg:RemoveCard(e:GetHandler())
    
    if Duel.SendtoGrave(dg,REASON_EFFECT)>0 then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CHANGE_DAMAGE)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,1)
        e1:SetValue(s.damval)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        
        keep_tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
        show_c:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
        
        local tg=Group.FromCards(keep_tc,show_c)
        tg:KeepAlive()
        
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_PHASE+PHASE_END)
        e2:SetCountLimit(1)
        e2:SetLabelObject(tg)
        e2:SetCondition(s.epcon)
        e2:SetOperation(s.epop)
        e2:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e2,tp)
    end
end

function s.damval(e,re,val,r,rp,rc)
    if (r&REASON_BATTLE)~=0 then
        return math.floor(val/2)
    end
    return val
end

function s.epcon(e,tp,eg,ep,ev,re,r,rp)
    return true
end

function s.epop(e,tp,eg,ep,ev,re,r,rp)
    local tg=e:GetLabelObject()
    if not tg then return end
    
    local keep_tc=tg:Filter(function(c) return c:GetFlagEffect(id)>0 end, nil):GetFirst()
    local show_c=tg:Filter(function(c) return c:GetFlagEffect(id+1)>0 end, nil):GetFirst()
    
    if keep_tc then
        Duel.SendtoGrave(keep_tc,REASON_EFFECT)
    end
    
    if show_c and show_c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
        Duel.SpecialSummon(show_c,0,tp,tp,false,false,POS_FACEUP)
    end
    
    tg:DeleteGroup()
end