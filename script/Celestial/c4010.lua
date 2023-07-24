local s,id=GetID()
function s.initial_effect(c)
	--fusion summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,4000,s.matfilter)  
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.ngcon)
	e2:SetTarget(s.ngtg)
	e2:SetOperation(s.ngop)
	c:RegisterEffect(e2)
	--cannot be target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsLevel,6))
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
end
s.listed_names={4000}
function s.matfilter(c,fc,sumtype,tp)
	return c:GetLevel()==6
end
--negate
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	local ch=Duel.GetCurrentChain()-1
	if ch<=0 then return false end
	local cplayer=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_CONTROLER)
	local ceff=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT)
	return ep==1-tp and cplayer==tp and ( ceff:GetHandler():IsSetCard(0xFA0) or ceff:GetHandler():IsSetCard(0xFA1) )
end
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and rc:IsAbleToDeck() then
		rc:CancelToGrave()
			Duel.SendtoDeck(rc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		Duel.RaiseEvent(rc,EVENT_TODECK,e,REASON_EFFECT,tp,tp,0)
	end
end
