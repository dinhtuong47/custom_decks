local s,id=GetID()
if not s then
	s={}
	id=30001
end

function s.initial_effect(c)
	-- =========================================================================
	-- LUẬT CƠ CHẾ SỬ DỤNG MÃ SỐ TOÀN DIỆN (NÉ LỖI CORE CŨ)
	-- =========================================================================
	if not s.global_check then
		s.global_check=true
		
		-- 0x0014 chính là EFFECT_TYPE_FIELD_CONTINUOUS
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(0x0014)
		ge1:SetCode(EVENT_ADJUST) -- Check liên tục khi bàn cờ thay đổi
		ge1:SetCondition(s.mechanic_con)
		ge1:SetOperation(s.mechanic_op)
		Duel.RegisterEffect(ge1,0)
		
		local ge2=ge1:Clone()
		Duel.RegisterEffect(ge2,1)
	end
end

-- 1. ĐIỀU KIỆN KÍCH HOẠT: Battle Phase, đúng lượt và có quái chứa Material
function s.mechanic_con(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsBattlePhase() or Duel.GetTurnPlayer()~=tp then return false end
	if Duel.GetLocationCount(tp,LOCATION_M_ZONE)<=0 then return false end
	
	-- Chỉ hiện bảng chọn nếu người chơi chưa kích hoạt trong chuỗi hành động này
	if e:GetLabel() == 1 then return false end
	
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_M_ZONE,0,nil)
	local has_mat=false
	for tc in aux.Next(g) do
		if tc:GetOverlayCount()>0 then
			has_mat = true
			break
		end
	end
	return has_mat
end

-- 2. VẬN HÀNH CƠ CHẾ: Hiện Pop-up gọi Linh Thú
function s.mechanic_op(e,tp,eg,ep,ev,re,r,rp)
	-- Khóa tạm thời để tránh loop vô hạn khi EVENT_ADJUST quét liên tục
	e:SetLabel(1) 
	
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_M_ZONE,0,nil)
		local host_g=Group.CreateGroup()
		for tc in aux.Next(g) do
			if tc:GetOverlayCount()>0 then
				host_g:AddCard(tc)
			end
		end
		
		if #host_g>0 then
			local hc=host_g:Select(tp,1,1,nil):GetFirst()
			if hc then
				local mat=hc:GetOverlayGroup()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=mat:Select(tp,1,1,nil)
				
				if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
					-- Đăng ký luật tự chui lại vào bụng ở End Battle Phase
					local sc=sg:GetFirst()
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(0x0014) -- EFFECT_TYPE_FIELD_CONTINUOUS
					e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
					e1:SetCountLimit(1)
					e1:SetLabelObject(sc)
					e1:SetCondition(s.return_con)
					e1:SetOperation(s.return_op)
					Duel.RegisterEffect(e1,tp)
				end
			end
		end
	end
	
	-- Mở khóa lại sau khi xử lý xong xuôi
	e:SetLabel(0)
end

-- 3. LUẬT TỰ ĐỘNG RETURN
function s.return_con(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or not tc:IsLocation(LOCATION_M_ZONE) then 
		e:Reset()
		return false 
	end
	return true
end

function s.return_op(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_M_ZONE,0,nil)
	if #g>0 then
		local hc=g:Select(tp,1,1,nil):GetFirst()
		if hc then
			Duel.Overlay(hc,Group.FromCards(tc))
		end
	else
		Duel.SendtoGrave(tc,REASON_RULE)
	end
	e:Reset()
end
end
