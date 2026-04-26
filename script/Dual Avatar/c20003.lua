local s,id=GetID()
function s.initial_effect(c)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(c20003.condition)
	e1:SetTarget(c20003.target)
	e1:SetOperation(c20003.activate)
	c:RegisterEffect(e1)
	if not c20003.global_check then
		c20003.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(c20003.valcheck)
		Duel.RegisterEffect(ge1,0)
	end
end
function c20003.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_EFFECT) then
		c:RegisterFlagEffect(20003,RESET_EVENT+0x4fe0000,0,1)
	end
end
--negate
function c20003.fmfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsFaceup()  
end
function c20003.fmfilter2(c)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x14e) and c:IsFaceup() and c:GetFlagEffect(20003)~=0
end
function c20003.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(c20003.fmfilter,tp,LOCATION_MZONE,0,2,nil)
end
function c20003.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c20003.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)
	and Duel.Destroy(eg,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(c20003.fmfilter2,tp,LOCATION_MZONE,0,1,nil) then
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		Duel.BreakEffect()
		Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
