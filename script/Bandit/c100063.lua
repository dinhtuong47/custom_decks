--Fusion Monster: DARK Machine non-Fusion + Time Wizard / monster that activated its effects this turn
local s,id=GetID()
s.listed_names={71625222,49511705} --Mentions "Time Wizard" and "Proton Blast"
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon procedure
	aux.AddFusionProcMix(c,true,true,s.matfilter1,s.matfilter2)
	
	--Special Summon from Extra Deck by tributing the materials on either field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If Special Summoned: place 1 "Proton Blast" face-up
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
	--Once per turn: toss a coin 3 times, draw 1 if at least 2 are heads
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_COIN+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.cointg)
	e3:SetOperation(s.coinop)
	c:RegisterEffect(e3)
	--Global check: mark monsters that activated their effects this turn
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end

--Register a flag on every monster that activates its effect
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if re:IsActiveType(TYPE_MONSTER) and rc then
		rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end

--Fusion materials
function s.matfilter1(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE)
		and not c:IsType(TYPE_FUSION)
end
function s.matfilter2(c)
	return c:IsCode(71625222)
		or c:GetFlagEffect(id)>0
end

--Special Summon procedure (tribute materials on either field)
function s.relfilter(c)
	return c:IsFaceup() and c:IsReleasable()
end
function s.f1(c,g,tp,sc)
	return s.matfilter1(c) and g:IsExists(s.f2,1,c,c,tp,sc)
end
function s.f2(c,m1,tp,sc)
	return s.matfilter2(c)
		and Duel.GetLocationCountFromEx(tp,tp,Group.FromCards(m1,c),sc)>0
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	return g:IsExists(s.f1,1,nil,g,tp,c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	if c==nil then c=chk end
	local g=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	--Slot 1: DARK Machine non-Fusion
	local sg1=g:Filter(s.f1,nil,g,tp,c)
	if #sg1==0 then return false end
	Duel.Hint(HINT_SELECTION,tp,HINTMSG_RELEASE)
	local g1=sg1:Select(tp,1,1,nil)
	if #g1==0 then return false end
	local m1=g1:GetFirst()
	--Slot 2: Time Wizard / monster đã kích hoạt hiệu ứng
	local sg2=g:Filter(s.f2,m1,m1,tp,c)
	if #sg2==0 then return false end
	Duel.Hint(HINT_SELECTION,tp,HINTMSG_RELEASE)
	local g2=sg2:Select(tp,1,1,nil)
	if #g2==0 then return false end
	g1:Merge(g2)
	g1:KeepAlive()
	e:SetLabelObject(g1)
	return true
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end

--Place "Proton Blast"
function s.plfilter(c,tp)
	return c:IsCode(49511705) and not c:IsForbidden()
		and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
	end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTION,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if not tc then return end
	--Place face-up on the field (Field Spell goes to the Field Zone)
	local loc=tc:IsType(TYPE_FIELD) and LOCATION_FZONE or LOCATION_SZONE
	Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true)
end

--Coin toss
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	--Toss a coin 3 times, draw 1 card if at least 2 are heads
	local c1,c2,c3=Duel.TossCoin(tp,3)
	if c1+c2+c3>=2 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end