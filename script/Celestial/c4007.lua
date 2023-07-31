local s,id=GetID()
function s.initial_effect(c)
	--Activate	
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Fusion
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)			
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.fcondition)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- Non-CelestialThunder cannot attack or activate their effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(_,c) return not c:IsSetCard(0xFA0) end)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	c:RegisterEffect(e3)
	--cook itself during the End Phase
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.tgcond)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
--fusion
function s.fcondition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp 
end
function s.tdfilter(c,e,tp)
    local att=c:GetAttribute() 
	return c:IsLevel(6) and c:IsMonster() and c:IsAbleToDeckAsCost()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,att,c)
end
function s.spfilter(c,e,tp,att,sc)
	return c:IsSetCard(0xFA0) and  c:GetAttribute()==att and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,sc,c)>0 
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	local rg=Group.FromCards(sc,c)
	Duel.SendtoDeck(rg,nil,1,REASON_COST)
	e:SetLabelObject(sc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local att=e:GetLabelObject():GetAttribute()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,att)
	local tc=g:GetFirst()
	if tc then Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP) end
	end
--cook
function s.rfilter(c)
	return c:IsSetCard(0xFA0) and c:IsFaceup()
end
function s.tgcond(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,tp,LOCATION_SZONE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKBOTTOM,REASON_EFFECT)
end