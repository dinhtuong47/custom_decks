local s,id=GetID()
function s.initial_effect(c)
	--Activate	
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Additional Normal Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2c))
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
	local e5=e3:Clone()
	e5:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--atk boost
	local e4=Effect.CreateEffect(c)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE))
	e4:SetCondition(s.atcon3)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
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
--atk boost
function s.atcon3(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_GRAVE)<8
end
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_REMOVED)*100
end


	
