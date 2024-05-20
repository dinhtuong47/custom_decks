--Bonding ovl
local s,id=GetID()
function s.initial_effect(c)
    --Activate
 	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
--add
function s.spcfilter(c,e,tp,mc)
	return c:IsSetCard(0x100) and not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,mc,c)
end
function s.thfilter(c,e,tp,mc,sc)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,0) and Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
local rc=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,c):GetFirst()
	if not rc then return end
	Duel.ConfirmCards(1-tp,rc)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,c,rc):GetFirst()
	if #g<2 then return end
	local sg=aux.SelectUnselectGroup(sc,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if #sg>0 then
		Duel.SendtoHand(sg,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end


