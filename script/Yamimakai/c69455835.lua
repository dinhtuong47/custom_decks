local s,id=GetID()
local SET_YAMIMAKAI=0xfa0

function s.initial_effect(c)
    c:EnableReviveLimit()
    --[[local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetValue(69455834)
    c:RegisterEffect(e1)]]--

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
    e2:SetTargetRange(POS_FACEDOWN_DEFENSE,0)
    e2:SetRange(LOCATION_EXTRA)
    e2:SetCondition(s.hspcon)
    e2:SetTarget(s.hsptg)
    e2:SetOperation(s.hspop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.reptg)
    e3:SetOperation(s.repop)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_FLIP)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,id+50)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
end

function s.hspfilter(c)
    return c:IsSetCard(SET_YAMIMAKAI) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function s.hspcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    if #g<2 then return false end
    if Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 then return true end
    return g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local sg=Duel.SelectMatchingCard(tp,s.hspfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,2,2,nil)
    if #sg==2 then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    end
    return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
    local sg=e:GetLabelObject()
    if not sg then return end
    Duel.Remove(sg,POS_FACEUP,REASON_COST)
    sg:DeleteGroup()
end

function s.repfilter(c)
    return c:IsAbleToRemove()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
        and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_GRAVE,0,1,nil) end
    if Duel.SelectEffectYesNo(tp,c,96) then
        return true
    else return false end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end

function s.thfilter(c)
    return c:IsSetCard(SET_YAMIMAKAI) and not c:IsType(TYPE_FUSION) and (c:IsLocation(LOCATION_DECK) or c:IsFaceup())
end
function s.can_hand(c)
    return c:IsAbleToHand()
end
function s.can_field(c,e,tp,ftm,fts)
    if c:IsType(TYPE_MONSTER) then
        return ftm>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
    else
        return fts>0 and c:IsSSetable()
    end
end
function s.thfilter1(c,e,tp,g,ftm,fts)
    return g:IsExists(s.thfilter2,1,c,c:GetCode(),e,tp,ftm,fts,c)
end
function s.thfilter2(c,code,e,tp,ftm,fts,c1)
    if c:GetCode()==code then return false end
    return (s.can_hand(c1) and s.can_field(c,e,tp,ftm,fts)) or (s.can_hand(c) and s.can_field(c1,e,tp,ftm,fts))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local ftm=Duel.GetLocationCount(tp,LOCATION_MZONE)
        local fts=Duel.GetLocationCount(tp,LOCATION_SZONE)
        local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil)
        return g:IsExists(s.thfilter1,1,nil,e,tp,g,ftm,fts)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local ftm=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local fts=Duel.GetLocationCount(tp,LOCATION_SZONE)
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil)
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local sg1=g:FilterSelect(tp,s.thfilter1,1,1,nil,e,tp,g,ftm,fts)
    if #sg1==0 then return end
    local tc1=sg1:GetFirst()
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local sg2=g:FilterSelect(tp,s.thfilter2,1,1,tc1,tc1:GetCode(),e,tp,ftm,fts,tc1)
    sg1:Merge(sg2)
    
    local c1,c2
    for tc in aux.Next(sg1) do
        if not c1 then c1=tc else c2=tc end
    end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local tg=sg1:FilterSelect(tp,function(c,e,tp,ftm,fts,ca,cb)
        local oc = (c==ca) and cb or ca
        return s.can_hand(c) and s.can_field(oc,e,tp,ftm,fts)
    end,1,1,nil,e,tp,ftm,fts,c1,c2)
    
    local tc=tg:GetFirst()
    if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1-tp,tc)
        sg1:RemoveCard(tc)
        local sc=sg1:GetFirst()
        if sc then
            if sc:IsType(TYPE_MONSTER) then
                Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
                Duel.ConfirmCards(1-tp,sc)
            else
                Duel.SSet(tp,sc)
            end
        end
    end
end
