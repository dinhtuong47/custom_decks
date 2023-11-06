local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon
	local e1=Ritual.AddProcGreater({handler=c,filter=s.ritualfil,lvtype=RITPROC_GREATER,sumpos=POS_FACEUP_ATTACK|POS_FACEDOWN_DEFENSE,extrafil=s.extrafil,location=LOCATION_HAND|LOCATION_GRAVE,extratg=s.extratg})
end
--should be removed in hardcode overhaul
s.listed_names={3017}
function s.ritualfil(c)
	return c:IsSetCard(0xbb8) and c:IsRitualMonster()
end
function s.mfilter(c)
	return not Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741) and c:HasLevel() and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsMonster() and c:IsAbleToRemove()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
