-- Scripted by Gemini (Sửa chính xác Filter Set từ tay hoặc sân)
local s,id=GetID()

function s.initial_effect(c)
    -- Kích hoạt bài: Chọn 1 trong 2 hiệu ứng khi Resolve
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- --- SỬA LẠI FILTER SET: Tách biệt điều kiện trên Tay và trên Sân ---
function s.filter(c)
    if not c:IsSetCard(0xBB8) then return false end
    if c:IsLocation(LOCATION_HAND) then
        return c:IsSummonable(true,nil) -- Nếu trên tay thì phải Set được
    elseif c:IsLocation(LOCATION_MZONE) then
        return c:IsFaceup() and c:IsCanTurnSet() -- Nếu trên sân thì phải đang ngửa và úp xuống được
    end
    return false
end

function s.flipfilter(c)
    return c:IsSetCard(0xBB8) and c:IsFacedown() and c:IsLocation(LOCATION_MZONE)
end

-- --- TARGET CHÍNH ---
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.flipfilter,tp,LOCATION_MZONE,0,1,nil)
    if chk==0 then return b1 or b2 end
    
    if b1 and b2 then
        e:SetCategory(CATEGORY_SUMMON+CATEGORY_POSITION)
    elseif b1 then
        e:SetCategory(CATEGORY_SUMMON)
    else
        e:SetCategory(CATEGORY_POSITION)
    end
end

-- --- OPERATION CHÍNH ---
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.flipfilter,tp,LOCATION_MZONE,0,1,nil)
    if not (b1 or b2) then return end
    
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    elseif b1 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1))
    else
        op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
    end
    
    if op==0 then
        -- EFF 1: SET TỪ HAND HOẶC FIELD (Logic gốc của bạn xử lý tc)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
        local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
        local tc=g:GetFirst()
        if tc then
            -- Hàm MSet gốc của bạn tự nhận diện vị trí để đưa từ tay xuống hoặc bắt quái trên sân úp tại chỗ
            Duel.MSet(tp,tc,true,nil) 
        end
    else
        -- EFF 2: IMMEDIATELY FLIP SUMMON (Mã Hex thô cho nhân cũ)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
        local g=Duel.SelectMatchingCard(tp,s.flipfilter,tp,LOCATION_MZONE,0,1,1,nil)
        if #g>0 then
            local tc=g:GetFirst()
            if Duel.ChangePosition(tc,POS_FACEUP_ATTACK) > 0 then
                tc:SetStatus(0x40,1)   -- STATUS_FLIP_SUMMONED
                tc:SetStatus(0x400,1)  -- STATUS_SUMMON_TURN
                
                local g2=Group.FromCards(tc)
                Duel.RaiseEvent(g2,EVENT_FLIP_SUMMON_SUCCESS,e,REASON_EFFECT,tp,tp,0)
                Duel.RaiseSingleEvent(tc,EVENT_FLIP_SUMMON_SUCCESS,e,REASON_EFFECT,tp,tp,0)
            end
        end
    end
end
