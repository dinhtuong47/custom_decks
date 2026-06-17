local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS) 
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.limcon)
	e1:SetOperation(s.limop)
	c:RegisterEffect(e1)

	local e1a=e1:Clone()
	e1a:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1a)

	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1b:SetCode(EVENT_CHAINING)
	e1b:SetRange(LOCATION_FZONE)
	e1b:SetCondition(s.limcon_chain)
	e1b:SetOperation(s.limop)
	c:RegisterEffect(e1b)

	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
    
	-- bao ve bai phep/cam bay (e3)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDES_BY_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetCondition(s.indcon)
	e3:SetTarget(s.indtg)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
end

function s.limcon_chain(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return ep==tp and rc:IsSetCard(0xBB8) and re:IsActiveType(TYPE_MONSTER)
end

function s.limfilter(c,tp)
	return c:IsSetCard(0xBB8) and c:IsControler(tp)
end

function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and eg:IsExists(s.limfilter,1,nil,tp)
end

function s.limop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(s.chainlm)
end

function s.chainlm(e,rp,tp)
	return tp==rp
end

function s.cfilter(c,tp)
	local ctype=c:GetType()&(TYPE_MONSTER|TYPE_SPELL|TYPE_TRAP)
	return c:IsSetCard(0xBB8) and not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,ctype,c:GetCode())
end

function s.thfilter(c,ctype,code)
	return c:IsSetCard(0xBB8) and c:IsType(ctype) and not c:IsType(TYPE_FIELD) and not c:IsCode(code) and c:IsAbleToHand()
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabel(g:GetFirst():GetType()&(TYPE_MONSTER|TYPE_SPELL|TYPE_TRAP))
	e:SetLabelObject(g:GetFirst())
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ctype=e:GetLabel()
	local rc=e:GetLabelObject()
	local code=rc and rc:GetCode() or 0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,ctype,code)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- dieu kien va muc tieu cua e3

function s.cfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0xBB9) and c:IsType(TYPE_MONSTER)
end

function s.indcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter2,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

function s.indtg(e,c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL|TYPE_TRAP)
end
