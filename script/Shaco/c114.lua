local s,id=GetID()
function s.initial_effect(c)
	--change name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(111)
	c:RegisterEffect(e1)
    --sp
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--ac
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+50)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_names={111}
--sp
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_TRAP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
--Trap activate in set turn 
function s.dfilter(c)
	return c:IsSetCard(0x22b)
end      
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCountLimit(1)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x22b))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetCountLimit(1)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x22b))
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end 
