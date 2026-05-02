local s,id=GetID()
function s.initial_effect(c)
	--Triệu hồi từ tay khi có Thunder trên sân
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,3))
	e0:SetCategory(CATEGORY_SUMMON)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.tscon)
	e0:SetTarget(s.tstg)
	e0:SetOperation(s.tsop)
	c:RegisterEffect(e0)

	--Kiểm tra nguyên liệu hiến tế
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.valcheck)
	c:RegisterEffect(e1)

	--Kích hoạt hiệu ứng dựa trên nguyên liệu khi Summon thành công
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
end

--Hàm lọc quái thú ngửa mặt (Thay thế cho FaceupFilter bị lỗi nil)
function s.fufilter(c,race)
	return c:IsFaceup() and c:IsRace(race)
end

function s.tscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.IsExistingMatchingCard(s.fufilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,RACE_THUNDER)
end

function s.tstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CanSummonOrSet(true,nil,1) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,tp,LOCATION_HAND)
end

function s.tsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Summon(tp,c,true,nil,1)
	end
end

--Xử lý flag nguyên liệu (Thay thế Iter() bằng GetFirst/GetNext)
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local flag=0
	local tc=g:GetFirst()
	while tc do
		local code=tc:GetCode()
		if code==55401221 then
			flag=(flag|0x1)
		elseif code==19733961 then
			flag=(flag|0x2)
		elseif code==63142001 then
			flag=(flag|0x4)
		end
		tc=g:GetNext()
	end
	e:SetLabel(flag)
end

--Kiểm tra Summon Type (Thay thế IsTributeSummoned bị lỗi nil)
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return (e:GetHandler():GetSummonType()&SUMMON_TYPE_TRIBUTE)==SUMMON_TYPE_TRIBUTE
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local flag=e:GetLabelObject():GetLabel()
    local c=e:GetHandler()
    -- Cắm "cờ" id vào quái thú, lưu giá trị flag nguyên liệu vào
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,flag)
    
    -- (Các hiệu ứng e1, e2 đăng ký động như cũ...)
end
	
	--Hiệu ứng 1: Phủ nhận Spell (Nếu dùng card 55401221)
	if (flag&0x1)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCategory(CATEGORY_DISABLE)
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_CHAINING)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(s.discon)
		e1:SetTarget(s.distg)
		e1:SetOperation(s.disop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	
	--Hiệu ứng 2: Trục xuất card (Nếu dùng card 19733961)
	if (flag&0x2)~=0 then
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetCategory(CATEGORY_REMOVE)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_CHAINING)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCondition(s.rmvcon)
		e2:SetTarget(s.rmvtg)
		e2:SetOperation(s.rmvop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
	
	--Hiệu ứng 3: Draw 2 (Nếu dùng card 63142001)
	if (flag&0x4)~=0 then
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,2))
		e3:SetCategory(CATEGORY_DRAW)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e3:SetRange(LOCATION_MZONE)
		e3:SetProperty(EFFECT_FLAG_DELAY)
		e3:SetCode(EVENT_SUMMON_SUCCESS)
		e3:SetCondition(s.drcon)
		e3:SetTarget(s.drtg)
		e3:SetOperation(s.drop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	
end

--Logic Negate Spell
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and re:IsSpellEffect() and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

--Logic Banished Trap
function s.rmvcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and re:IsTrapEffect() and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,LOCATION_ONFIELD)
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

--Logic Draw
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Kiểm tra xem con này có cái "cờ" chứa nguyên liệu số (3) không
    local flag=c:GetFlagEffectLabel(id)
    if not flag or (flag&0x4)==0 then return false end
    
    -- Check xem có quái thú nào được Normal Summon (bao gồm cả chính nó)
    -- eg là group chứa các quái thú vừa triệu hồi thành công
    return eg:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
end

-- Hàm Target và Operation
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end
