local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)

	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DECREASE_TRIBUTE_SET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xBB8))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e2a=e2:Clone()
	--[[e2a:SetCode(EFFECT_DECREASE_TRIBUTE)
	c:RegisterEffect(e2a)]]--

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.sscon)
	e3:SetTarget(s.sstg)
	e3:SetOperation(s.ssop)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_ADD_SETCODE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.shatg)
	e4:SetValue(0xBB9)
	c:RegisterEffect(e4)

    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_ADJUST)
    e5:SetRange(LOCATION_SZONE)
    e5:SetOperation(s.adjustop)
    c:RegisterEffect(e5)

    if not s.global_check then
    s.global_check=true
    local ge1=Effect.CreateEffect(c)
    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
    ge1:SetOperation(s.checkop)
    Duel.RegisterEffect(ge1,0)
    end
end

-- Treated as Shadow Army
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if tc:GetPreviousLocation()==LOCATION_GRAVE and tc:GetPreviousControler()~=tc:GetControler() then
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
end

function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		if tc:GetFlagEffect(id)>0 and tc:GetFlagEffect(id+100)==0 then
			tc:RegisterFlagEffect(id+100,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
		end
	end
end

function s.shatg(e,c)
	return e:GetHandler():IsLocation(LOCATION_SZONE) and c:IsFaceup() and c:GetFlagEffect(id)>0
end

function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	if not rc or not rc:IsControler(tp) or not rc:IsCode(100000) then return false end
	local bc=rc:GetBattleTarget()
	return bc and bc:IsLocation(LOCATION_GRAVE) and bc:GetPreviousControler()==1-tp
end

function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local rc=eg:GetFirst()
		if not rc then return false end
		local bc=rc:GetBattleTarget()
		return bc and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
	end
	local rc=eg:GetFirst()
	local bc=rc:GetBattleTarget()
	Duel.SetTargetCard(bc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end

function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
