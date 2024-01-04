--xian
local s,id=GetID()
function s.initial_effect(c)
	--return to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x7D0}
function s.filter(c)
    return c:IsLevel(6) and c:IsSetCard(0x7D0) and c:IsFaceup() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.setfilter(c,tp)
	return c:IsSetCard(0x7D0) and c:IsTrap() and c:IsSSetable()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND) then
		local c=e:GetHandler()
	if tc:IsRace(RACE_PLANT) and tc:IsLocation(LOCATION_HAND) and Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE+LOCATION_FZONE)>0
	 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
	 --sent s/t to gy
		Duel.BreakEffect()
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_SZONE+LOCATION_FZONE)
		local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_SZONE+LOCATION_FZONE,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=g:Select(1-tp,1,1,nil)
		Duel.HintSelection(sg)
		Duel.SendtoGrave(sg,REASON_RULE)
	end
	elseif tc:IsRace(RACE_DRAGON) and tc:IsLocation(LOCATION_HAND) and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,tp)
	and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
	--set to field
    	Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
		if #sg==0 then return end
		local ft=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),2)
		local rg=aux.SelectUnselectGroup(sg,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SET)
		if #rg then Duel.SSet(tp,rg)
		end
	elseif not tc:IsRace(RACE_DRAGON) and not tc:IsRace(RACE_PLANT) and tc:IsLocation(LOCATION_HAND)
		and c:IsFaceup() and c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		--Increase ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		e1:SetValue(500)
		c:RegisterEffect(e1)
		end
	end
end

 


