local s,id=GetID()
function s.initial_effect(c)
    -- Summon itself by Tribute Summon (Action từ tay)
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,4)) -- Thêm desc cho dễ nhìn
    e0:SetCategory(CATEGORY_SUMMON)
    e0:SetType(EFFECT_TYPE_IGNITION)
    e0:SetRange(LOCATION_HAND)
    e0:SetCondition(s.tscon)
    e0:SetTarget(s.tstg)
    e0:SetOperation(s.tsop)
    c:RegisterEffect(e0)

    -- Material check
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_MATERIAL_CHECK)
    e1:SetValue(s.valcheck)
    c:RegisterEffect(e1)

    -- Gain effects based on the monsters used
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCondition(s.regcon)
    e2:SetOperation(s.regop)
    e2:SetLabelObject(e1)
    c:RegisterEffect(e2)
end

-- Logic Triệu hồi
function s.tscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase() and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_THUNDER),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end

function s.tstg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsSummonable(true,nil,1) end -- Dùng IsSummonable chuẩn hơn
    Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,0,0)
end

function s.tsop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.Summon(tp,c,true,nil,1)
    end
end

-- Kiểm tra nguyên liệu
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local flag=0
	for tc in g:Iter() do
		local code=tc:GetCode()
		if code==55401221 then
			flag=(flag|0x1)
		elseif code==19733961 then
			flag=(flag|0x2)
		elseif code==63142001 then
			flag=(flag|0x4)
		elseif code==47346845 then
            		flag=(flag|0x8)
		end
	end
	e:SetLabel(flag)
end

function s.regcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsTributeSummoned()
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local flag=e:GetLabelObject():GetLabel()
    local c=e:GetHandler()
    
    -- Effect 1: Negate Spell
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
    
    -- Effect 2: Banish Trap
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

    -- Effect 3: Draw 2
    if (flag&0x4)~=0 then
        local e3=Effect.CreateEffect(c)
        e3:SetDescription(aux.Stringid(id,2))
        e3:SetCategory(CATEGORY_DRAW)
        e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
        e3:SetRange(LOCATION_MZONE)
        e3:SetCode(EVENT_SUMMON_SUCCESS)
        e3:SetCondition(s.drcon)
        e3:SetTarget(s.drtg)
        e3:SetOperation(s.drop)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e3)
    end

    -- Effect 4: Buff ATK & Immune
    if (flag&0x8)~=0 then
        local e4a=Effect.CreateEffect(c)
        e4a:SetType(EFFECT_TYPE_SINGLE)
	e4a:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
        e4a:SetCode(EFFECT_UPDATE_ATTACK)
        e4a:SetValue(1000)
        e4a:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e4a)

        local e4b=Effect.CreateEffect(c)
        e4b:SetType(EFFECT_TYPE_SINGLE)
	e4b:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
        e4b:SetRange(LOCATION_MZONE)
        e4b:SetCode(EFFECT_IMMUNE_EFFECT)
        e4b:SetValue(s.efilter)
        e4b:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e4b)
	-- Cập nhật lại chỉ số cho card ngay lập tức
        c:ReadjustStatus()
    end
end

-- Filter Kháng hiệu ứng
function s.efilter(e,re)
    return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end

-- Negate Spell logic
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
        and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateEffect(ev)
end

-- Banish logic
function s.rmvcon(e,tp,eg,ep,ev,re,r,rp)
    return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
        and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end

-- Draw logic
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(2)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end
