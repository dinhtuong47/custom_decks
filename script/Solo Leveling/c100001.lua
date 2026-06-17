local s,id=GetID()
function s.initial_effect(c)
	-- Effect 1: FLIP effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FLIP)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)

	-- Effect 2: Hand Normal Set
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_MSET)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.sumcon)
	e3:SetTarget(s.sumtg)
	e3:SetOperation(s.sumop)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EVENT_CHANGE_POS)
	e3b:SetCondition(s.sumcon2)
	c:RegisterEffect(e3b)
	local e3c=e3:Clone()
	e3c:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3c:SetCondition(s.sumcon3)
	c:RegisterEffect(e3c)
	local e3d=e3:Clone()
	e3d:SetCode(EVENT_SSET)
	e3d:SetCondition(s.sumcon4)
	c:RegisterEffect(e3d)
end

function s.thfilter(c,ttype)
	return c:IsSetCard(0xBB8) and c:IsType(ttype) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFacedown() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if e:GetHandler():GetFlagEffect(id)~=0 then
		e:SetLabel(1)
		e:GetHandler():ResetFlagEffect(id)
	else
		e:SetLabel(0)
	end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
		Duel.ConfirmCards(1-tc:GetControler(),tc)
		local ttype=tc:GetType()&(TYPE_MONSTER|TYPE_SPELL|TYPE_TRAP)
		if e:GetLabel()==1 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,ttype)
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,ttype)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,0,0,0)
end

function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end

function s.sumcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsFacedown,1,nil)
end

function s.sumcon3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsFacedown,1,nil)
end

function s.sumcon4(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsFacedown,1,nil)
end

function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local c=e:GetHandler()
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and (c:IsSummonable(true,nil) or c:IsMSetable(true,nil))
	end
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetLabelObject(e)
	e1:SetCondition(s.dosum_con)
	e1:SetOperation(s.dosum_op)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
end

function s.dosum_con(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end

function s.dosum_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local te=e:GetLabelObject()
	if c:IsRelateToEffect(te) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local pos=0
		local s1=c:IsSummonable(true,nil)
		local s2=c:IsMSetable(true,nil)
		if s1 and s2 then
			pos=Duel.SelectPosition(tp,c,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
		elseif s1 then
			pos=POS_FACEUP_ATTACK
		elseif s2 then
			pos=POS_FACEDOWN_DEFENSE
		end
		if pos==POS_FACEUP_ATTACK then
			Duel.Summon(tp,c,true,nil)
		elseif pos==POS_FACEDOWN_DEFENSE then
			Duel.MSet(tp,c,true,nil)
		end
	end
	e:Reset()
end
