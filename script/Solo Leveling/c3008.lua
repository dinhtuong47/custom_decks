local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--decrease tribute
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DECREASE_TRIBUTE_SET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xBB8))
	e2:SetValue(0x1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_DECREASE_TRIBUTE)
	c:RegisterEffect(e3)
	--ss from gy
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--Monsters cannot attack the turn they are Summoned
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_ATTACK)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(s.limtg)
	c:RegisterEffect(e5)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local rc=tc:GetReasonCard()
	return #eg==1 and rc:IsControler(tp) and rc:IsSetCard(0xBB8)
		and tc:IsMonster() and tc:IsReason(REASON_BATTLE) and tc:IsLocation(LOCATION_GRAVE)
	        and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	local rc=tc:GetReasonCard()
	local bc=rc:GetBattleTarget()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	Duel.SetTargetCard(bc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		Duel.ConfirmCards(1-tp,tc)
	end
end
--cannot attack
function s.limtg(e,c)
	return c:IsStatus(STATUS_SUMMON_TURN|STATUS_SPSUMMON_TURN) --[[and (not c:IsType(TYPE_FLIP)) |STATUS_FLIP_SUMMON_TURN]]--
end
