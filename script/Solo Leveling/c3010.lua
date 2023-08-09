local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_FLIP))
	e2:SetValue(400)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(400)
	c:RegisterEffect(e3)
	--to hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
--add
local key=TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP
function s.cfilter1(c,tp)
	return c:IsSetCard(0xBB8) and not c:IsPublic() and Duel.IsExistingMatchingCard(s.cffilter2,tp,LOCATION_HAND,0,1,nil,c:GetCode())
end
function s.cfilter2(c,tp)
	return c:IsSetCard(0xBB8) and not c:IsPublic() and not c:IsCode(code)
end
function s.thfilter(c,ctype)
	return c:IsSetCard(0xBB8) and c:IsAbleToHand() and not c:IsType(ctype&key)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.cfilter1,tp,LOCATION_HAND,0,nil)
	local g2=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_HAND,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=2 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.cfilter1,tp,LOCATION_HAND,0,nil)
	local g2=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_HAND,0,nil)
	if #g1>0 and #g2>0 then
	Duel.ConfirmCards(1-tp,g1)
	Duel.ConfirmCards(1-tp,g2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local eq=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,g1:GetType(),g2:GetFirst():GetType())
		if not eq then return end
		Duel.BreakEffect()
		Duel.SendtoHand(eq,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,eq)
	end
end
