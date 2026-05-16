-- Scripted by Gemini (Chuẩn hóa cơ chế Immediately Set cho cả Hand và Field)
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

-- --- FILTER SET TỪ HAND HOẶC FIELD ---
function s.filter(c)
    if not c:IsSetCard(0xBB8) then return false end
    if c:IsLocation(LOCATION_HAND) then
        return c:IsSummonable(true,nil) -- Kiểm tra xem trên tay có Set được không
    elseif c:IsLocation(LOCATION_MZONE) then
        return c:IsFaceup() and c:IsCanTurnSet() -- Kiểm tra xem trên sân có đang ngửa và úp xuống được không
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
        -- =================================================================
        -- EFF 1: IMMEDIATELY SET TỪ HAND HOẶC FIELD (TÍNH LÀ SET TAY)
        -- =================================================================
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
        local tc=g:GetFirst()
        if tc then
            if tc:IsLocation(LOCATION_HAND) then
                -- Từ trên TAY: Gọi hàm MSet gốc của bạn (Core tự tính là Set tay)
                Duel.MSet(tp,tc,true,nil)
            else
                -- Từ trên SÂN: Tiến hành ép úp mặt xuống
                if Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE) > 0 then
                    -- GIẢ LẬP BIẾN THÀNH HÀNH ĐỘNG SET TAY:
                    tc:SetStatus(0x400,1) -- Đóng dấu STATUS_SUMMON_TURN (Quái vật tính là được Set/Summon lượt này)
                    
                    -- Bắn sự kiện báo cho toàn hệ thống: Vừa có 1 quái vật được SET TAY xuống sân
                    -- REASON_SUMMON (0x100) ép game hiểu đây là hành động Triệu hồi chứ KHÔNG PHẢI hiệu ứng bài.
                    local g2=Group.FromCards(tc)
                    Duel.RaiseEvent(g2,EVENT_MZONE_COUNT_CHANGED,e,REASON_SUMMON,tp,tp)
                end
            end
        end
    else
        -- =================================================================
        -- EFF 2: IMMEDIATELY FLIP SUMMON (TÍNH LÀ FLIP SUMMON TAY)
        -- =================================================================
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
