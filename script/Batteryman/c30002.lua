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
