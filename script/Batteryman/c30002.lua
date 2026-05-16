-- Scripted by Gemini (Non-Target Version)
local s,id=GetID()

function s.initial_effect(c)
    -- Kích hoạt lá bài (Activate)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- --- KIỂM TRA ĐIỀU KIỆN KÍCH HOẠT ---
function s.filter(c)
    return c:IsFacedown() and c:IsLocation(LOCATION_MZONE)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Chỉ kiểm tra xem trên sân có ít nhất 1 quái vật úp mặt hay không
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
    
    -- Không dùng Duel.SelectTarget ở đây, hệ thống sẽ hiểu là Non-target
    Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,LOCATION_MZONE)
end

-- --- XỬ LÝ HIỆU ỨNG KHI RESOLVE ---
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Tiến hành chọn quái vật NGAY LÚC RESOLVE
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
    
    if #g>0 then
        local tc=g:GetFirst()
        -- Lật quái vật lên thế công ngửa mặt
        if Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true) then
            
            -- Đóng dấu trạng thái hệ thống Flip Summon
            tc:SetStatus(STATUS_FLIP_SUMMONED,true)
            tc:SetStatus(STATUS_SUMMON_TURN,true)
            
            -- Bắn Event báo cho toàn bộ sàn đấu và bản thân quái vật
            local g2=Group.FromCards(tc)
            Duel.RaiseEvent(g2,EVENT_FLIP_SUMMON_SUCCESS,e,REASON_EFFECT,tp,tp,0)
            Duel.RaiseSingleEvent(tc,EVENT_FLIP_SUMMON_SUCCESS,e,REASON_EFFECT,tp,tp,0)
        end
    end
end
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
        -- Tăng ATK
        local e4a=Effect.CreateEffect(c)
        e4a:SetType(EFFECT_TYPE_SINGLE)
        e4a:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
        e4a:SetRange(LOCATION_MZONE) -- Phải có Range cho SINGLE_RANGE
        e4a:SetCode(EFFECT_UPDATE_ATTACK)
        e4a:SetValue(1000)
        e4a:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e4a)

        -- Kháng hiệu ứng
        local e4b=Effect.CreateEffect(c)
        e4b:SetType(EFFECT_TYPE_SINGLE)
        e4b:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
        e4b:SetRange(LOCATION_MZONE)
        e4b:SetCode(EFFECT_IMMUNE_EFFECT)
        e4b:SetValue(s.efilter)
        e4b:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e4b)
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
