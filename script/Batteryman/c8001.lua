local s,id=GetID()
function s.initial_effect(c)
	--Activate	
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Untargetable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_FZONE)
        e1:SetTargetRange(LOCATION_MZONE,0)
        e1:SetTarget(s.tgtg)
	e1:SetValue(s.tglimit)
	c:RegisterEffect(e1)
	--broken line
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	--[[e2:SetCost(s.thcost)]]--
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
        --short circuit
        local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,1))
        e3:SetCountLimit(1,id+20)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
        c:RegisterEffect(e3)	
end
--untarget 
function s.tgtg(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_THUNDER)
end
function s.tglimit(e,re,rp)
	return rp~=e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER) 
end
--add
--[[function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	Duel.PayLPCost(tp,500)
end]]--
function s.blfilter(c)
	return c:IsCode(88086137) and c:IsAbleToHand()
end
function s.scfilter(c)
	return c:IsCode(75967082) and c:IsAbleToHand()
end
--broken line
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,20529766)
			and Duel.IsExistingMatchingCard(s.blfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	--[[Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)]]--
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.blfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		--[[Duel.BreakEffect()
		Duel.Damage(1-tp,500,REASON_EFFECT)]]--
	end
end
--Short Circuit
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,19441018)
			and Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	--[[Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)]]--
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.scfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		--[[Duel.BreakEffect()
		Duel.Damage(tp,1000,REASON_EFFECT)]]--
	end
end

