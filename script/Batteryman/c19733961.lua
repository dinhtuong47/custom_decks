local s,id=GetID()
function s.initial_effect(c)
	--atk,def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_MACHINE))
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(s.defval)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.atkfil(c)
	return c:IsFaceup() and c:IsCode(19733961)  
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfil,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*500
end
function s.defval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfil,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*500
end

