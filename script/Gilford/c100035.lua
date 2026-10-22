local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,36354007)
    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetHintTiming(0,TIMING_BATTLE_START+TIMING_END_PHASE)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
    e2:SetCondition(s.skipcon)
    e2:SetOperation(s.skipop)
    c:RegisterEffect(e2)
end

function s.eqfilter(c,tp)
    return c:IsType(TYPE_EQUIP) and aux.IsCodeListed(c,36354007) 
        and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,c)
end

function s.tgfilter(c,eqcard)
    return c:IsFaceup() and eqcard:CheckEquipTarget(c)
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,tp)
    local ec=g:GetFirst()
    if ec then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,ec)
        local tc=tg:GetFirst()
        if tc and Duel.Equip(tp,ec,tc) then
            local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
            if #dg>0 then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
                local sg=dg:Select(tp,1,1,nil)
                Duel.HintSelection(sg)
                Duel.Destroy(sg,REASON_EFFECT)
            end
        end
    end
end

function s.skipcon(e,tp,eg,ep,ev,re,r,rp)
    return re and re:GetHandler():IsCode(100039)
end

function s.skipop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    
    if Duel.GetTurnPlayer()==tp then
        Duel.SkipPhase(tp,Duel.GetCurrentPhase(),RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(tp,PHASE_END,RESET_PHASE+PHASE_END,1)
        
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_SKIP_TURN)
        e1:SetTargetRange(0,1)
        e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
        Duel.RegisterEffect(e1,tp)
        
        Duel.SkipPhase(tp,PHASE_DRAW,RESET_PHASE+PHASE_END,2)
        Duel.SkipPhase(tp,PHASE_STANDBY,RESET_PHASE+PHASE_END,2)
        Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,2)
    else
        Duel.SkipPhase(1-tp,Duel.GetCurrentPhase(),RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(1-tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(1-tp,PHASE_END,RESET_PHASE+PHASE_END,1)
        
        Duel.SkipPhase(tp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(tp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
        Duel.SkipPhase(tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
    end
    
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_EP)
    e2:SetTargetRange(1,0)
    e2:SetReset(RESET_PHASE+PHASE_MAIN1+RESET_SELF_TURN,1)
    Duel.RegisterEffect(e2,tp)
    
    Duel.RegisterFlagEffect(tp,id,0,0,0)
    
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_BATTLE_DAMAGE)
    e3:SetCondition(s.damcon)
    e3:SetOperation(s.damop)
    Duel.RegisterEffect(e3,tp)
    
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
    e4:SetCountLimit(1)
    e4:SetDescription(aux.Stringid(id,1))  
    e4:SetCondition(s.wincon)
    e4:SetOperation(s.winop)
    e4:SetLabelObject(e3)
    Duel.RegisterEffect(e4,tp)
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp and Duel.GetTurnPlayer()==tp and Duel.GetFlagEffect(tp,id)>0
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end

function s.wincon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp and Duel.GetFlagEffect(tp,id)>0
end

function s.winop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp,id+1)==0 then
        Duel.Win(1-tp,REASON_EFFECT)
    end
    Duel.ResetFlagEffect(tp,id)
    Duel.ResetFlagEffect(tp,id+1)
    local e3=e:GetLabelObject()
    if e3 then e3:Reset() end
    e:Reset()
end
