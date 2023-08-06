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
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
--atkup
function s.cfilter(c)
	return c:IsSetCard(0xBB8) and not c:IsPublic()
end
function s.rescon(sg,e,tp,mg)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,sg)
end
function s.thfilter(c,e,tp,sg)
	return c:IsSetCard(0xBB8) and c:IsAbleToHand()
		and not sg:IsExists(Card.IsType,1,nil,c:GetType())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) and g:GetClassCount(Card.GetType)>=2 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
	if #g<2 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_CONFIRM)
	Duel.ConfirmCards(1-tp,sg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local eq=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,sg):GetFirst()
		if not eq then return end
		Duel.BreakEffect()
		Duel.SendtoHand(eq,0,tp,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,eq)
end


 
