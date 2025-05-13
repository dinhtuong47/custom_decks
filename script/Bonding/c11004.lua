--tidal blast
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Return
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+50)
	e3:SetCondition(s.tdcon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	
end
s.listed_series={0x100}
s.listed_names={85066822}
--channge race
function s.zfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SEASERPENT) --[[and c:IsCode(85066822)]]--
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.zfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.chfilter(c)
	return c:IsFaceup()  
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.chfilter,tp,0,LOCATION_MZONE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.chfilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)	
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(ATTRIBUTE_FIRE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(RACE_PYRO)
	tc:RegisterEffect(e2) 
	end
end
--draw
function s.spconfilter(c)
	return c:IsMonster() or c:GetPreviousTypeOnField()&TYPE_MONSTER==TYPE_MONSTER

end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil)

end

function s.tdfilter(c,e)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsRace(RACE_DINOSAUR) or c:IsRace(RACE_SEASERPENT) 
		and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck()

end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)

	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc,e,tp) end

	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)

	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,ft,nil,e,tp)

	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)

end



function s.tdop(e,tp,eg,ep,ev,re,r,rp)

	local tg=Duel.GetTargetCards(e)

	if #tg==0 then return end

	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)

end

