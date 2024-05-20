--diamond breakdown
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCost(s.cost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Return and draw 1 card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	
end
s.listed_series={0x100}
s.listed_names={62397231}
--special summon
function s.thcfilter(c,tp)
	return ( c:IsRace(RACE_SEASERPENT) and c:IsLevelAbove(8) ) or c:IsCode(62397231) and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thcfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Duel.SelectMatchingCard(tp,s.thcfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	Duel.ShuffleHand(tp)
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_COST)
	e:SetLabel(tc:GetCode())
end
function s.spfilter(c,e,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND+LOCATION_GRAVE)) and c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--draw
function s.tdfilter1(c)
	return c:IsSetCard(0x100) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.tdfilter2(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and c:IsControler(tp) and s.tdfilter1(chkc) and s.tdfilter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter1,tp,LOCATION_REMOVED,0,1,nil)
	and Duel.IsExistingTarget(s.tdfilter2,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsPlayerCanDraw(tp,1)  end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectTarget(tp,s.tdfilter1,tp,LOCATION_REMOVED,0,1,1,nil)
	local g2=Duel.SelectTarget(tp,s.tdfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,#g1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g2,#g2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 or Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)==0 then return end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if ct>1 then
		Duel.SortDeckbottom(tp,tp,ct)
	end
	Duel.BreakEffect()
	Duel.Draw(tp,1,REASON_EFFECT)
end


