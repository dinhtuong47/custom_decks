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
    e2:SetCategory(CATEGORY_DRAW+CATEGORY_POSITION)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
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

--set
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsPosition(POS_FACEDOWN_ATTACK) then
        e:GetLabelObject():SetLabel(1)
    else
        e:GetLabelObject():SetLabel(0)
    end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return true
end

function s.setfilter(c)
    return c:IsSetCard(0xfa0) and c:IsType(TYPE_SPELL+TYPE_TRAP) 
    and (c:IsLocation(LOCATION_DECK) or c:IsFaceup())  and c:IsSSetable()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local is_fd_atk=(e:GetLabel()==1 or c:GetPreviousPosition()==POS_FACEDOWN_ATTACK)
    e:SetLabel(0)
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
    if #g>0 and Duel.SSet(tp,g:GetFirst())~=0 then
        
        if is_fd_atk and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.BreakEffect()
            if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
                if c:IsRelateToEffect(e) and c:IsFaceup() and not c:IsReason(REASON_BATTLE)  then
                    Duel.BreakEffect()
                    Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
                end
            end
        end
    end
end