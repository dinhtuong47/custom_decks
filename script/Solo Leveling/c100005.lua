local s,id=GetID()
function s.initial_effect(c)
	-- FLIP: Target 1 "Solo Leveling" card in GY/Banishment, Set or SS facedown
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)

	-- Quick Effect: Gain effect then banish if in GY
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)

	-- Gain ATK for Flip Summoned card
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e3:SetOperation(s.fssop)
	c:RegisterEffect(e3)
end

-- ==========================================================
-- LOGIC EFF 1: FLIP (SET S/T OR SS MONSTER FACEDOWN)
-- ==========================================================

function s.setfilter(c,e,tp)
	if not (c:IsSetCard(0xbb8) and not c:IsCode(id)) then return false end
    if not (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) then return false end
	if c:IsType(TYPE_MONSTER) then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
	else
		return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
	end
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.setfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetFirst():IsType(TYPE_MONSTER) then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if tc:IsType(TYPE_MONSTER) then
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
				Duel.ConfirmCards(1-tp,tc)
			end
		else
			Duel.SSet(tp,tc)
		end
	end
end

-- ==========================================================
-- LOGIC EFF 2: QUICK EFFECT (COPY & BANISH)
-- ==========================================================

function s.rmfilter(c,e,tp)
	if not c:IsType(TYPE_MONSTER) then return false end
	-- Target opponent's GY monster or monster banished by this effect
	return (c:IsLocation(LOCATION_GRAVE) and c:IsControler(1-tp)) 
		or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup() and c:GetFlagEffect(id)>0)
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.rmfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil,e,tp)
	-- Only flag CATEGORY_REMOVE if targeting a monster in the GY
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 1. Gain target's effect
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		end
		
		-- 2. Then, if target is still in GY, banish it
		if tc:IsLocation(LOCATION_GRAVE) then
			if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
				-- Add flag to mark it as banished by this effect
				tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
			end
		end
	end
end

-- ==========================================================
-- LOGIC EFF 3: GAIN ATK BASED ON BANISHED MONSTERS
-- ==========================================================

function s.fssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD) 
	c:RegisterEffect(e1)
	
	c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
end

function s.atkfilter(c)
	-- Filter banished monsters with the specific flag
	return c:IsFaceup() and c:GetFlagEffect(id)>0
end

function s.atkval(e,c)
	-- Count them to calculate ATK
	local g=Duel.GetMatchingGroup(s.atkfilter,c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED,nil)
	return #g*300
end
