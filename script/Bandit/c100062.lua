--Plasma Laser Cannon
local s,id=GetID()
s.listed_names={100060} --Mentions "Number 7 Card"
function s.initial_effect(c)
	--Activate: shuffle banished "Number 7 Card(s)" into the Deck, then banish that many opponent's cards
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH) --only 1 "Plasma Laser Cannon" can be activated per turn
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

--Condition: control a face-up DARK Machine Fusion Monster
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

--Target: need at least 1 banished "Number 7 Card" and 1 card the opponent controls
function s.tdfilter(c)
	return c:IsFaceup() and c:IsCode(100060) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil)
			and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end

--Operation
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil,tp)
	local max=math.min(#g,#rg)
	if max==0 then return end
	--Choose any number of banished "Number 7 Card(s)"
	Duel.Hint(HINT_SELECTION,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,1,max,nil)
	if #sg==0 then return end
	Duel.HintSelection(sg)
	local ct=Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if ct>0 then
		--Banish that many cards your opponent controls
		rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil,tp)
		ct=math.min(ct,#rg)
		if ct==0 then return end
		Duel.Hint(HINT_SELECTION,tp,HINTMSG_REMOVE)
		local bg=rg:Select(tp,ct,ct,nil)
		Duel.HintSelection(bg)
		Duel.Remove(bg,POS_FACEDOWN,REASON_EFFECT)
	end
end