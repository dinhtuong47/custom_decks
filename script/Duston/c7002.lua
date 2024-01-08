--dustage
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--cannot be used as link material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x80))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--change effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.condition) 
	e2:SetCountLimit(1,0)
	e2:SetCost(s.chcost)
	e2:SetTarget(s.chtg)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_FZONE)
	c:RegisterEffect(e3) 
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
	--recycle
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.tdcon)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)
end
s.listed_series={0x80}
--change effect
function s.chainfilter(re,tp,cid)
	return not ((re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and not re:GetHandler():IsSetCard(0x80))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.chcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and not re:GetHandler():IsSetCard(0x80)  
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if  not c:GetType()==TYPE_FIELD then
		c:CancelToGrave(false)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(1-tp,nil,1-tp,LOCATION_ONFIELD,0,1,1,nil)
	if #g~=0 then Duel.Destroy(g,REASON_EFFECT)
	end
end
--recycle
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_FZONE)
end
function s.tdfilter(c)
	return c:IsSetCard(0x80) and c:IsMonster() and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #dg>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,dg,#dg,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	if #dg==0 then return end
	Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
