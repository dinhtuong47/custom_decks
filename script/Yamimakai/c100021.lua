local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetCondition(s.ntcon)
    c:RegisterEffect(e1)
    local e1a=e1:Clone()
    e1a:SetCode(EFFECT_SET_PROC)
    c:RegisterEffect(e1a)

    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW+CATEGORY_POSITION)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    local e2a=e2:Clone()
    e2a:SetCode(EVENT_FLIP)
    c:RegisterEffect(e2a)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_FLIP_SUMMON_START)
    e3:SetLabelObject(e2)
    e3:SetOperation(s.regop)
    c:RegisterEffect(e3)
end

function s.cfilter(c)
    return c:IsFaceup()
end

function s.ntcon(e,c,minc)
    if c==nil then return true end
    local tp=c:GetControler()
    return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsPosition(POS_FACEDOWN_ATTACK) then
        e:GetLabelObject():SetLabel(1)
    else
        e:GetLabelObject():SetLabel(0)
    end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return true
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(0xfa0) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) 
        and (c:IsLocation(LOCATION_DECK) or c:IsFaceup())
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local is_fd_atk=(e:GetLabel()==1 or c:GetPreviousPosition()==POS_FACEDOWN_ATTACK)
    e:SetLabel(0)
    
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
        Duel.ConfirmCards(1-tp,g)
        
        if is_fd_atk and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.BreakEffect()
            if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
                if c:IsRelateToEffect(e) and c:IsFaceup() and not c:IsReason(REASON_BATTLE) then
                    Duel.BreakEffect()
                    Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
                end
            end
        end
    end
end
