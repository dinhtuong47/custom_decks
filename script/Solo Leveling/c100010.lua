local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)

	-- Activation
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	c:RegisterEffect(e0)

	-- Replacement effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)

	-- Decrease tribute
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DECREASE_TRIBUTE_SET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xBB8))
	e2:SetValue(1)
	c:RegisterEffect(e2)

	-- Special Summon facedown
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1)
	e3:SetCost(s.exchcost)
	e3:SetTarget(s.exchtg)
	e3:SetOperation(s.exchop)
	c:RegisterEffect(e3)
end

-- ==========================================================
-- LOGIC EFF 1: REPLACE DESTROY
-- ==========================================================

function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
		and c:IsCode(100000) and c:IsReason(REASON_DESTROY) 
		and c:GetDestination()==LOCATION_GRAVE
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_CARD,0,id)
		local g=eg:Filter(s.repfilter,nil,tp)
		if #g>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			g=g:Select(tp,1,#g,nil)
		end
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end

function s.repval(e,c)
	local g=e:GetLabelObject()
	return g and g:IsContains(c)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	g:DeleteGroup()
end

-- ==========================================================
-- LOGIC EFF 3: RETURN TO HAND TO SP SUMMON FACEDOWN
-- ==========================================================

-- Filter for valid target in GY or Banishment (Monster only)
function s.tgfilter(c,e,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0xBB8) 
		and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end

-- Filter for cost (Monster on field)
function s.exchcostfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xBB8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHandAsCost()
		and Duel.GetMZoneCount(tp,c,tp)>0 
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
end

-- Cost: Return 1 face-up "Solo Leveling" monster to hand
function s.exchcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.exchcostfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.exchcostfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SendtoHand(g,nil,REASON_COST)
end

-- Target 1 monster in GY or Banishment
function s.exchtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tgfilter(chkc,e,tp) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

-- Special Summon facedown defense
function s.exchop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
