local s,id=GetID()
function s.initial_effect(c)
	--set
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(id)
	e0:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)	
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	--[[e1:SetCountLimit(1,id)]]--
	e1:SetTarget(s.nstg)
	e1:SetOperation(s.nsop)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Flip face-up or facedown
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	--[[e2:SetCountLimit(1,id+50)]]--
	e2:SetCost(s.poscost)
	e2:SetCondition(s.poscon)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
--set
function s.cfilter(c)
	return c:IsSetCard(0xBB8) and not c:IsPublic()
end	
function s.nsfilter(c)
	return c:IsType(TYPE_FLIP) and c:IsSummonable(true,nil)
end
--draw
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rvg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and rvg:GetClassCount(Card.GetCode)>=2 end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local rvg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
	local g=aux.SelectUnselectGroup(rvg,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_CONFIRM)
	if #g<2 then return end
	Duel.ConfirmCards(1-tp,g)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	Duel.ShuffleHand(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local sg1=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		if #sg1~=0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.ShuffleHand(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sg2=sg1:Select(tp,1,1,nil):GetFirst()
			Duel.MSet(tp,sg2,true,nil)
	end
end
--change pos
function s.filter(c)
	return c:IsMonster()
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.GetTurnPlayer()~=tp and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>=2
end
function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHandAsCost() end
	Duel.SendtoHand(e:GetHandler(),nil,REASON_COST)
end
function s.posfilter(c)
	return c:IsCanTurnSet() or c:IsFacedown()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,tp,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local opt=0
	if tc:IsPosition(POS_FACEDOWN) then
		opt=POS_FACEUP_DEFENSE
	elseif tc:IsPosition(POS_FACEUP_DEFENSE) then
		opt=POS_FACEDOWN_DEFENSE
	elseif tc:IsPosition(POS_FACEUP_ATTACK) then
		opt=POS_FACEDOWN_DEFENSE|POS_FACEUP_DEFENSE
	end
	if opt==0 then return end
	local pos=Duel.SelectPosition(tp,tc,opt)
	if pos==0 then return end
	Duel.ChangePosition(tc,pos)
end

