local s,id=GetID()
function s.initial_effect(c)
	-- FLIP: You can add to your hand, 1 "Solo Leveling" Equip Spell from your Deck, or 1 Equip Spell from either GY, then you can equip it
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    
	-- Eff 2: If you control a Set monster, or a "Solo Leveling" monster, and this card is in your hand: Immediately after this effect resolves, you can Normal Set this card.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)

	-- Static Effect: This Flip Summoned card can attack directly.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e3:SetOperation(s.fssop)
	c:RegisterEffect(e3)
end

-- ==========================================================
-- LOGIC EFF 1: FLIP (SEARCH/RECYCLE EQUIP SPELL)
-- ==========================================================

function s.thfilter(c)
	if c:IsLocation(LOCATION_DECK) then
		return c:IsSetCard(0xBB8) and c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
	else
		return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
	end
end

function s.eqfilter(c,ec)
	return c:IsFaceup() and ec:CheckEquipTarget(c)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.SendtoHand(tc,tp,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,tc)
			Duel.ShuffleHand(tp)
			
			if Duel.GetLocationCount(tp,LOCATION_SZONE)>0
				and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,0,1,nil,tc)
				and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				local sg=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil,tc)
				if #sg>0 then
					Duel.HintSelection(sg)
					Duel.BreakEffect()
					Duel.Equip(tp,tc,sg:GetFirst())
				end
			end
		end
	end
end

-- ==========================================================
-- LOGIC EFF 2: IMMEDIATELY AFTER RESOLVES, NORMAL SET
-- ==========================================================

function s.cfilter(c)
	return c:IsFacedown() or (c:IsFaceup() and c:IsSetCard(0xBB8))
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and e:GetHandler():IsMSetable(true,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_HAND) and c:IsMSetable(true,nil) then
			Duel.MSet(tp,c,true,nil)
		end
	end
end


-- ==========================================================
-- STATIC LOGIC: DIRECT ATTACK IF FLIP SUMMONED
-- ==========================================================

function s.fssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	c:RegisterEffect(e1)
	
	c:RegisterFlagEffect(0,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
end
