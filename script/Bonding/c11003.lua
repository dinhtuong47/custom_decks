--Electrolysis/Bonding - H2O
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
s.listed_names={58071123,85066822,22587018,45898858} 
function s.cfilter(c)
	return c:IsCode(45898858) and c:IsAbleToRemoveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.thfilter2(c,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND+LOCATION_DECK)) and c:IsCode(22587018) and c:IsAbleToGrave()
	--[[and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,c)]]--
		and Duel.IsExistingMatchingCard(s.thfilter3,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE,0,1,c)
end
function s.thfilter3(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND+LOCATION_DECK)) and c:IsCode(58071123) and c:IsAbleToGrave()
end
function s.filter(c,e,tp)
	return c:IsCode(85066822) and c:IsCanBeSpecialSummoned(e,0,tp,true,true,POS_FACEUP)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE,0,2,nil,tp)
	and Duel.IsExistingMatchingCard(s.thfilter3,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE,0,1,nil,tp)
	and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE,0,2,2,nil,tp)
	if #g1>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g2=Duel.SelectMatchingCard(tp,s.thfilter3,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE,0,1,1,g1:GetFirst())
		g1:Merge(g2)
		Duel.SendtoGrave(g1,tp,nil,REASON_EFFECT)
    end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.descon)
		e1:SetOperation(s.desop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
--race change
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
