local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Filter chuẩn cho PSY-Frame
function s.rmfilter(c)
    -- Mã 0xc1 là chuẩn quốc tế cho PSY-Frame
    return c:IsSetCard(0x0c1) and not c:IsCode(id) 
        and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
        and c:IsAbleToRemove()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsPlayerCanDraw(tp,2)
            and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler())
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
    if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
        -- 2. Draw 2
        Duel.BreakEffect()
        if Duel.Draw(tp,2,REASON_EFFECT)==2 then
            -- 3. Trả 1 lá bị trục xuất về GY (Optional)
            -- IsAbleToGrave không dùng cho vùng Removed, dùng IsType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) để check hợp lệ
            local mg=Duel.GetMatchingGroup(nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
            if #mg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
                local sg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
                if #sg>0 then
                    Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
                end
            end
        end
    end
end
