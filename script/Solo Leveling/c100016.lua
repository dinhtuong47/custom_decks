local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Ham thuc cong kiem tra xem Group co the dat duoc tong Level >= lv hay khong
function s.check_greater_or_equal(g,lv)
    local t={}
    local mc=g:GetFirst()
    while mc do
        table.insert(t,mc)
        mc=g:GetNext()
    end
    return s.recursive_check(t,lv,1,0)
end

function s.recursive_check(t,lv,idx,current_sum)
    if current_sum>=lv then return true end
    if idx>#t then return false end
    -- Truong hop 1: Lay quai vat nay lam te pham
    if s.recursive_check(t,lv,idx+1,current_sum+t[idx]:GetLevel()) then return true end
    -- Truong hop 2: Bo qua quai vat nay
    return s.recursive_check(t,lv,idx+1,current_sum)
end

-- Filter: Quai vat he DARK trong GY co the banish
function s.matfilter(c)
    return (c:IsCode(100000) or c:IsCode(100002)) and c:IsAbleToRemove()  --[[c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_DARK)]]--
end

-- Filter: Quai vat Ritual Solo Leveling
function s.tgfilter(c,e,tp,mg)
    if not (c:IsSetCard(0xBB8) and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER)) then return false end
    
    -- ?? S?A: ??i th?nh true, true ?? v?a cho ph?p check ?i?u ki?n v?a b? qua Revive Limit ? GY
    local b1 = c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true,POS_FACEUP_ATTACK)
    local b2 = c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true,POS_FACEDOWN_DEFENSE)
    if not (b1 or b2) then return false end
    
    local lv=c:GetLevel()
    local g=mg:Clone()
    if g:IsContains(c) then g:RemoveCard(c) end
    return s.check_greater_or_equal(g,lv)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg=Duel.GetRitualMaterial(tp)
        local mg2=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil)
        mg:Merge(mg2)
        return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,mg)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetRitualMaterial(tp)
    local mg2=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil)
    mg:Merge(mg2)
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,mg)
    local tc=tg:GetFirst()
    if not tc then return end
    
    local g=mg:Clone()
    if g:IsContains(tc) then g:RemoveCard(tc) end
    
    local lv=tc:GetLevel()
    
    -- Vong lap chon tay tung la bai cho den khi tong Level >= yeu cau (Tuong thich moi core)
    local mat=Group.CreateGroup()
    while true do
        local sum=0
        local mc=mat:GetFirst()
        while mc do
            sum=sum+mc:GetLevel()
            mc=mat:GetNext()
        end
        
        if sum>=lv then break end
        
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        local sg=g:Select(tp,1,1,nil)
        local sc=sg:GetFirst()
        if not sc then break end
        mat:AddCard(sc)
        g:RemoveCard(sc)
    end
    
    if mat:GetCount()==0 then return end
    tc:SetMaterial(mat)
    
    -- Phan chia nguyen lieu: Tren tay/san thi hien te, duoi GY thi truc xuat
    local rg1=Group.CreateGroup()
    local rg2=Group.CreateGroup()
    local mc=mat:GetFirst()
    while mc do
        if mc:GetLocation()==LOCATION_GRAVE then
            rg2:AddCard(mc)
        else
            rg1:AddCard(mc)
        end
        mc=mat:GetNext()
    end
    
    if rg1:GetCount()>0 then
        Duel.Release(rg1,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
    end
    if rg2:GetCount()>0 then
        Duel.Remove(rg2,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
    end
    local b1=tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true,POS_FACEUP_ATTACK)
    local b2=tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true,POS_FACEDOWN_DEFENSE)
    
    local pos=0
    if b1 and b2 then
        pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
    elseif b1 then
        pos=POS_FACEUP_ATTACK
    else
        pos=POS_FACEDOWN_DEFENSE
    end
    
    if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,true,pos)>0   then 
   --[[and Duel.ConfirmCards(1-tp,tc)>0 then]]--
        tc:CompleteProcedure()
    end
end
