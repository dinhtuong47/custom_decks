local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCondition(s.condition)
	e1:SetCode(EVENT_CHAINING)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function s.cfilter(c)
	return c:IsSetCard(0xBB8) and not c:IsPublic() 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToEffect(re) then
			Duel.SendtoGrave(eg,REASON_EFFECT)
		end
		local ct=re:GetHandler():GetType()
		local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil,ct)
		if #g<2 then return end
			local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_CONFIRM)
			Duel.ConfirmCards(1-tp,sg,REASON_EFFECT)
		
	end
end
