local s,id=GetID()
function s.initial_effect(c)
	--Activate	
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--act limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(0,1)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.actcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
        --Double damage
	local e3=Effect.CreateEffect(c)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.atcon2)
	e3:SetTarget(s.damtg)
	e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e3)
	-- can make up to 2 attacks on monsters
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(s.atcon3)
	e4:SetTarget(s.damtg2)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--atk boost
	local e5=Effect.CreateEffect(c)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE))
	e5:SetCondition(s.atcon4)
	e5:SetValue(s.atkval)
	c:RegisterEffect(e5)
end
--ss from GY
function s.filter(c,e,sp)
	return c:IsSetCard(0x2c) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--act limit
function s.actcon(e)
	local gct=Duel.GetFieldGroupCount(e:GetHandler():GetControler(),0,LOCATION_GRAVE)
	local ph=Duel.GetCurrentPhase()
	if gct<=3 then return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE end
end
--double dmg
function s.atcon2(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_GRAVE)<6
end
function s.damtg(e,c)
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x2c) and c:GetBattleTarget()~=nil
end
--attack 2 on monsters
function s.atcon3(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_GRAVE)<6
end
function s.damtg2(e,c)
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x2c)  
end
--atk boost
function s.atcon4(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_GRAVE)<8
end
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_REMOVED)*100
end


	
