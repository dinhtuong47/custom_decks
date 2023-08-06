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
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.cfilter,ep,LOCATION_HAND,0,nil,re:GetHandler():GetType())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,ep,LOCATION_HAND,0,nil,re:GetHandler():GetType())
	if #g<1 then return end
			Duel.ConfirmCards(1-tp,g,REASON_EFFECT)
	end
end
