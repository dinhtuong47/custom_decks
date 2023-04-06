local s,id=GetID()
function s.initial_effect(c)
	--neg attack
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(s.cbcon)
	e2:SetOperation(s.cbop)
	c:RegisterEffect(e2)
	--neg
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_NEGATE)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(s.discon)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)	
end
--neg attack
function s.cbcon(e,tp,eg,ep,ev,re,r,rp)
	local bt=Duel.GetAttackTarget()
	return bt and bt:IsLocation(LOCATION_MZONE) and bt:IsControler(tp) and bt:IsCode(111) and Duel.GetAttacker():GetColumnGroup():IsContains(bt)
end
function s.cbop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
end
--neg
function s.cfilter(c,seq,p)
	return c:IsFaceup() and c:IsCode(111) and c:IsColumn(seq,p,LOCATION_MZONE)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsActiveType(TYPE_MONSTER) then return false end
	local rc=re:GetHandler()
	local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	return loc==LOCATION_MZONE and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,seq,p)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

