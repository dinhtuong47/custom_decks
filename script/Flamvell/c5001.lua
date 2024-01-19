local s,id=GetID()
function s.initial_effect(c)
	--Activate	
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Additional Normal Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2c))
	c:RegisterEffect(e2)
	--act limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(0,1)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.actcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--atk boost
	local e1=e3:Clone()
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE))
	e1:SetCondition(s.actcon3)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
        --Double damage
	local e5=e3:Clone()
	e5:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetCondition(s.actcon2)
	e5:SetTarget(s.damtg)
	e5:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e5)
end
--act limit
function s.actcon(e)
	local gct=Duel.GetFieldGroupCount(e:GetHandler():GetControler(),0,LOCATION_GRAVE)
	local ph=Duel.GetCurrentPhase()
	if gct<=3 then return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE end
end
--double dmg
function s.actcon2(e)
	local gct=Duel.GetFieldGroupCount(e:GetHandler():GetControler(),0,LOCATION_GRAVE)
	return gct<=5 end
end
function s.damtg(e,c)
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x2c) and c:GetBattleTarget()~=nil
end
--atk boost
function s.actcon3(e)
	local gct=Duel.GetFieldGroupCount(e:GetHandler():GetControler(),0,LOCATION_GRAVE)
	return gct<=7 end
end
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_REMOVED)*100
end


	
