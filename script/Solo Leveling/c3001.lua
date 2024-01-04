local s,id=GetID()
function s.initial_effect(c)
	--ss sung
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(id)
	e0:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	--[[e1:SetCountLimit(1,id)]]--
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--block attack
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_END)
	--[[e2:SetCountLimit(1,id+50)]]--
	e2:SetCost(s.poscost)
	e2:SetCondition(s.poscon)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
--ss sung
function s.cfilter(c)
	return c:IsSetCard(0xBB8) and not c:IsPublic()
end	
function s.spsetfilter(c,e,tp,ft)
	return (ft>0 and c:IsCode(3000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE))
		or (c:IsSetCard(0xBB8) and c:IsType(TYPE_SPELL+TYPE_TRAP))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetMZoneCount(tp,c)
	local rvg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and rvg:GetClassCount(Card.GetCode)>=2
	and Duel.IsExistingMatchingCard(s.spsetfilter,tp,LOCATION_DECK,0,1,c,e,tp,ft) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local rvg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
	local g=aux.SelectUnselectGroup(rvg,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_CONFIRM)
	if #g<2 then return end
	Duel.ConfirmCards(1-tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc=Duel.SelectMatchingCard(tp,s.spsetfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft):GetFirst()
	if not sc then return end
	if sc:IsMonster() then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE) 
		Duel.ConfirmCards(1-tp,sc)
	elseif sc:IsType(TYPE_SPELL+TYPE_TRAP) then Duel.SSet(tp,sc)
	Duel.ConfirmCards(1-tp,sc)
	end
end
--set
function s.zfilter(c)
	return c:IsMonster() 
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase() and Duel.GetTurnPlayer()~=tp and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>=2
end
function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHandAsCost() end
	Duel.SendtoHand(e:GetHandler(),nil,REASON_COST)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.zfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.zfilter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.SelectTarget(tp,s.zfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then	
	     --Cannot be targeted for attacks
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3007)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
			e1:SetValue(aux.imval1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
