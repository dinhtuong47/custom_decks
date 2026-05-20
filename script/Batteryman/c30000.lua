local s,id=GetID()
function s.initial_effect(c)
    -- Hiệu ứng 1: Chọn 1 quái trên sân để chui vào bụng (Kích hoạt từ tay)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.eattg)
    e1:SetOperation(s.eatop)
    c:RegisterEffect(e1)
end

-- Logic chui vào bụng
function s.eattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

function s.eatop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Overlay(tc,c)
        
        -- GẮN HIỆU ỨNG LÊN CON CHỦ ĐỂ HIỂN THỊ NÚT BẤM
        local e2=Effect.CreateEffect(c)
        e2:SetDescription(aux.Stringid(id,1)) -- Hiện đúng mô tả của con kí sinh
        e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
        e2:SetType(EFFECT_TYPE_QUICK_O)
        e2:SetCode(EVENT_FREE_CHAIN)
        e2:SetRange(LOCATION_MZONE)
        e2:SetLabelObject(c) -- Khóa mục tiêu vào đúng con c đang nằm dưới
        e2:SetCondition(s.sscon)
        e2:SetTarget(s.sstg)
        e2:SetOperation(s.ssop)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD) -- Mất khi con chủ rời sân
        tc:RegisterEffect(e2)
    end
end

-- Logic xé bụng (Bấm trên con chủ, lấy con dưới ra)
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsBattlePhase()
end

function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetLabelObject()
    if chk==0 then
        return c and c:IsLocation(LOCATION_OVERLAY)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_OVERLAY)
end

function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetLabelObject()
    if c and c:IsLocation(LOCATION_OVERLAY) then
        if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
            e:Reset() -- Giải phóng hiệu ứng trên con chủ sau khi đẻ xong
        end
    end
end
