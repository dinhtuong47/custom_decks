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
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+50)
    e2:SetCode(EVENT_FLIP)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
    
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_FLIP_SUMMON_START)
    e3:SetLabelObject(e2)
    e3:SetOperation(s.regop)
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

function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsPosition(POS_FACEDOWN_ATTACK) then
        e:GetLabelObject():SetLabel(1)
    else
        e:GetLabelObject():SetLabel(0)
    end
end

function s.setfilter(c,e,tp)
    if c:IsFacedown() or not c:IsSetCard(0xfa0) or c:IsCode(id) then return false end
    if c:IsType(TYPE_MONSTER) then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
    else
        return c:IsSSetable()
    end
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.setfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    if g:GetFirst():IsLocation(LOCATION_GRAVE) then
        Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
    end
end

function s.posfilter(c)
    return c:IsFaceup() and c:IsCanTurnSet()
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local is_fd_atk=(e:GetLabel()==1 or c:GetPreviousPosition()==POS_FACEDOWN_ATTACK)
    e:SetLabel(0)
    
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end
    
    local res=0
    if tc:IsType(TYPE_MONSTER) then
        res=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
        if res~=0 then
            Duel.ConfirmCards(1-tp,tc)
        end
    else
        res=Duel.SSet(tp,tc)
    end
    
    if res~=0 then
        local opg=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
        if is_fd_atk and #opg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
            local sg=opg:Select(tp,1,1,nil)
            Duel.HintSelection(sg)
            Duel.ChangePosition(sg:GetFirst(),POS_FACEDOWN_DEFENSE)
        end
    end
end