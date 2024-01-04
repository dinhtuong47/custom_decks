local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and (ph~=PHASE_DAMAGE or not Duel.IsDamageCalculated())
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x7D0) and c:IsLevel(6) 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SetLP(tp,Duel.GetLP(tp)+tc:GetDefense())~=0 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
		local c=e:GetHandler()
	end
    if tc:IsCode(2004) and tc:IsRelateToEffect(e) then
		Duel.BreakEffect()
		local e1=Effect.CreateEffect(e:GetHandler())
    	e1:SetType(EFFECT_TYPE_FIELD)
    	e1:SetCode(EFFECT_CANNOT_ATTACK)
    	e1:SetTargetRange(0,LOCATION_MZONE)
    	e1:SetReset(RESET_PHASE+PHASE_END)
    	Duel.RegisterEffect(e1,tp)
	end
end
