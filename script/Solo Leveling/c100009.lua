local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)

	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
    
    --[[local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.atktg)
	c:RegisterEffect(e1)]]--
    
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DECREASE_TRIBUTE_SET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xBB8))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--[[local e2a=e2:Clone()
	e2a:SetCode(EFFECT_DECREASE_TRIBUTE)
	c:RegisterEffect(e2a)]]--

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.atktg2)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	local e3a=e3:Clone()
	e3a:SetCode(EFFECT_UPDATE_DEFENSE)
	e3a:SetValue(s.defval)
	c:RegisterEffect(e3a)
    
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCost(s.descost)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)

      
end

--[[function s.atktg(e,c)
	return c:IsStatus(STATUS_SPSUMMON_TURN)
end]]--
--atk
function s.atktg2(e,c)
	if c:IsCode(100000) or c:IsSetCard(0xBB9) or c:IsOriginalSetCard(0xBB9) then 
		return true 
	end
	return c:IsHasEffect(EFFECT_CHANGE_SETCODE) and c:IsSetCard(0xBB9)
end

function s.atkval(e,c)
	local atk=c:GetBaseAttack()
	if atk==0 then return 0 end
	return (atk+1)//2
end

function s.defval(e,c)
	local def=c:GetBaseDefense()
	if def==0 then return 0 end
	return (def+1)//2
end

function s.desfilter(c,ttype,ec)
    return c:IsFaceup() and c:IsType(ttype) and c~=ec and c:IsCanTurnSet()
end

function s.costfilter(c,tp,e)
	if not (c:IsSetCard(0xBB8) and not c:IsPublic()) then return false end
	local ttype=c:GetType() & 0x7
	return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,ttype,e:GetHandler())
end

function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,tp,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil,tp,e)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabel(g:GetFirst():GetType() & 0x7)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ttype=e:GetLabel()
	if chkc then return chkc:IsOnField() and s.desfilter(chkc,ttype,e:GetHandler()) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,ttype,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if tc:IsType(TYPE_MONSTER) then
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		else
			Duel.ChangePosition(tc,POS_FACEDOWN)
		end
	end
end


