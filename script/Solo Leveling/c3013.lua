local s,id=GetID()
function s.initial_effect(c)
	--Set card from GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--change pos
        local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+50)
	e2:SetCondition(s.setcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg2)
	e2:SetOperation(s.setop2)
	c:RegisterEffect(e2)
end
function s.setfilter(c,e,tp)
	if not (c:IsSetCard(0xBB8) and not c:IsLevelAbove(6)) then return end
	if c:IsMonster() then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
	elseif c:IsSpellTrap() then
		return (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0) and c:IsSSetable()
	end
	return false
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc:IsMonster() then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
	elseif tc:IsSpellTrap() then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,tp,LOCATION_GRAVE)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local andifyoudo=false
	if tc:IsMonster() then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		Duel.ConfirmCards(1-tp,tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e1:SetValue(s.atlimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
end
function s.atlimit(e,c)
	return c:IsFacedown()
end
	elseif tc:IsSpellTrap() then
		if tc:IsType(TYPE_FIELD) then
			local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if fc then
				Duel.SendtoGrave(fc,REASON_RULE)
				Duel.BreakEffect()
			end
		end
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			Duel.SSet(tp,tc)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			if tc:IsType(TYPE_QUICKPLAY) then
				e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			elseif  tc:IsTrap() then
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			end
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
--change pos
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xBB8) 
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.filter(c)
	return c:IsMonster()
end
function s.settg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.setop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc then
			local pos=0
			if tc:IsCanTurnSet() then
				pos=Duel.SelectPosition(tp,tc,POS_DEFENSE)
			else
				pos=Duel.SelectPosition(tp,tc,POS_FACEUP_DEFENSE)
			end
			Duel.ChangePosition(tc,pos)
		else
			Duel.ChangePosition(tc,0,0,POS_FACEDOWN_DEFENSE,POS_FACEUP_DEFENSE)
		end
	end
end
