local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local cd=re:GetHandler():GetType()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil,cd)
	if chk==0 then return g:GetClassCount(Card.GetType)>=2 end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.cfilter(c)
	return c:IsSetCard(0xBB8) and not c:IsPublic()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToEffect(re) then
			Duel.SendtoGrave(eg,REASON_EFFECT)
		end
		local cd=re:GetHandler():GetType()
		local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil,cd)
		if #g>1 then
			Duel.ConfirmCards(1-tp,g,REASON_EFFECT)
		end
	end
end
