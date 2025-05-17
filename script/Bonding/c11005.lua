--fire dragon 
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--Draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.drcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--ss
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
        e3:SetCountLimit(1,id+50)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
--draw
function s.cfilter(c)

	return c:IsCode(62397231) or c:IsRace(RACE_SEASERPENT) and c:IsDiscardable()

end

function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)

	if chk==0 then return e:GetHandler():IsDiscardable()

		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)

	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())

	g:AddCard(e:GetHandler())

	Duel.SendtoGrave(g,REASON_DISCARD|REASON_COST)

end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)

	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end

	Duel.SetTargetPlayer(tp)

	Duel.SetTargetParam(2)

	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)

end

function s.drop(e,tp,eg,ep,ev,re,r,rp)

	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)

	Duel.Draw(p,d,REASON_EFFECT)

end


--ss
function s.filter1(c)

	return c:IsSpellTrap() and c:IsAbleToDeck()

end

function s.filter2(c)

	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsAttribute(ATTRIBUTE_WATER)

end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)

	if chkc then return false end

	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,nil)

		and Duel.IsExistingTarget(s.filter2,tp,0,LOCATION_MZONE,1,nil) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)

	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,2,nil)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)

	local g2=Duel.SelectTarget(tp,s.filter2,tp,0,LOCATION_MZONE,1,1,nil)

	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,LOCATION_GRAVE+LOCATION_REMOVED)

	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g2,1,0,0)

end

function s.negop(e,tp,eg,ep,ev,re,r,rp)

	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_TODECK)

	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_DISABLE)

	if g1:GetFirst():IsRelateToEffect(e) then

		Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)

		local og=Duel.GetOperatedGroup()

		if og:GetFirst():IsLocation(LOCATION_DECK) or og:GetFirst():IsLocation(LOCATION_EXTRA) then

			local tc=g2:GetFirst()

			if tc:IsFaceup() and tc:IsRelateToEffect(e) then

				local e1=Effect.CreateEffect(e:GetHandler())

				e1:SetType(EFFECT_TYPE_SINGLE)

				e1:SetCode(EFFECT_DISABLE)

				e1:SetReset(RESETS_EVENT+RESETS_STANDARD)

				tc:RegisterEffect(e1)

				local e2=Effect.CreateEffect(e:GetHandler())

				e2:SetType(EFFECT_TYPE_SINGLE)

				e2:SetCode(EFFECT_DISABLE_EFFECT)

				e2:SetReset(RESETS_EVENT+RESETS_STANDARD)

				tc:RegisterEffect(e2)

			end

		end

	end

end



