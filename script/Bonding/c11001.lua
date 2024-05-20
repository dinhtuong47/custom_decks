--Bonding ovl
local s,id=GetID()
function s.initial_effect(c)
    --Activate
 	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Send
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+50)
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
--add
function s.thfilter1(c,tp)
	return c:IsSetCard(0x100) and not c:IsPublic() 
		and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,2,nil,c)
end
function s.thfilter2(c,mc)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToHand() and s.isfit(c,mc)
end
function s.isfit(c,mc)
	return (mc.fit_monster and c:IsCode(table.unpack(mc.fit_monster))) or mc:ListsCode(c:GetCode())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE) 
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if not rc then return end
	Duel.ConfirmCards(1-tp,rc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,2,2,nil,rc)
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
	local g=Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,nil,e,0,tp,false,false)
	if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP) end
end
--send
function s.spconfilter(c)
	return c:IsMonster() or c:GetPreviousTypeOnField()&TYPE_MONSTER==TYPE_MONSTER
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil)
end
function s.tgfilter(c)
	return  c:IsLevelAbove(8) and c:IsRace(RACE_SEASERPENT) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end







