--diamond breakdown
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.flipcon)
	e1:SetOperation(s.flipop)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	c:RegisterEffect(e1)
end
s.listed_names={22587018,58071123,15981690,62397231}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,62397231),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.ConfirmDecktop(tp,5)
	local c=e:GetHandler()
	local g=Duel.GetDecktopGroup(tp,5)
	local break_chk=false
	--"Carbonnedon": 1 "Hyozanryu" you control becomes unaffected and gains 1k until the end of this turn
	if g:IsExists(Card.IsCode,1,nil,15981690) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
		local tc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsCode,62397231),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc then
			Duel.HintSelection(tc,true)
			break_chk=true
			--Gains 1000 ATK
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1000)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			e2:SetValue(1000)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetDescription(3110)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e3:SetCode(EFFECT_IMMUNE_EFFECT)
			e3:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			e3:SetValue(function(e,te) return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() end) --[[and te:IsMonsterEffect()]]--
			tc:RegisterEffect(e3)
		end
	end
	--"Hydrogeddon": neg 1 face-up card
	if g:IsExists(Card.IsCode,1,nil,22587018) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local sc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #sc>0 then


			Duel.HintSelection(sc)

			local tc=sc:GetFirst()

			Duel.NegateRelatedChain(tc,RESET_TURN_SET)

			local e1=Effect.CreateEffect(c)

			e1:SetType(EFFECT_TYPE_SINGLE)

			e1:SetCode(EFFECT_DISABLE)

			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)

			e1:SetReset(RESET_EVENT|RESETS_STANDARD)

			tc:RegisterEffect(e1)

			local e2=e1:Clone()

			e2:SetCode(EFFECT_DISABLE_EFFECT)

			tc:RegisterEffect(e2)		
		end
	end
	--"Oxygeddon": Destroy 1 monster, then inflict 800 damage to both
	if g:IsExists(Card.IsCode,1,nil,58071123) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if #dg>0 then
			Duel.HintSelection(dg,true)
			if break_chk then Duel.BreakEffect() end
			if Duel.Destroy(dg,REASON_EFFECT)>0 then
				Duel.BreakEffect()
				Duel.Damage(tp,800,REASON_EFFECT)
				Duel.Damage(1-tp,800,REASON_EFFECT)
			end
		end
	end
	Duel.BreakEffect()
	Duel.SendtoGrave(g,REASON_EFFECT)
end
