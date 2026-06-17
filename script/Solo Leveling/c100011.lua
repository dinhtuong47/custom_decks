local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)

	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	c:RegisterEffect(e0)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1)
    e3:SetCondition(s.effcon)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DECREASE_TRIBUTE_SET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xBB8))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--[[local e1a=e1:Clone()
	e1a:SetCode(EFFECT_DECREASE_TRIBUTE)
	c:RegisterEffect(e1a)]]--

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end

function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) 
		and c:IsSetCard(0xBB9) and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT))
		and not c:IsReason(REASON_REPLACE)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_CARD,0,id)
		local g=eg:Filter(s.repfilter,nil,tp)
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end

function s.repval(e,c)
	local g=e:GetLabelObject()
	return g and g:IsContains(c)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	Duel.SendtoHand(g,nil,REASON_EFFECT+REASON_REPLACE)
	g:DeleteGroup()
end

--Set or Flip
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
function s.filter(c)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsSetCard(0xBB8) and c:IsMSetable(true,nil)
	elseif c:IsLocation(LOCATION_MZONE) then
		return c:IsFacedown() and c:IsSetCard(0xBB8)
	end
	return false
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) 
	end
end


function s.effop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		if tc:IsLocation(LOCATION_HAND) then
			Duel.MSet(tp,tc,true,nil)
		else
			if Duel.ChangePosition(tc,POS_FACEUP_ATTACK)>0 then
				--[[tc:SetStatus(0x40,1)
				tc:SetStatus(0x400,1)]]--
				local g2=Group.FromCards(tc)
				Duel.RaiseEvent(g2,EVENT_FLIP_SUMMON_SUCCESS,e,REASON_EFFECT,tp,tp,0)
				Duel.RaiseSingleEvent(tc,EVENT_FLIP_SUMMON_SUCCESS,e,REASON_EFFECT,tp,tp,0)
			end
		end
	end
end
