function s.initial_effect(c)
	-- [Hiệu ứng riêng của lá bài c30001 nếu có]

	-- =========================================================================
	-- LUẬT CƠ CHẾ KHÔNG RÀNG BUỘC (DÙNG ĐỂ TEST CƠ CHẾ)
	-- =========================================================================
	if not s.global_check then
		s.global_check=true
		
		-- Luật gọi Linh Thú ra sân trong Battle Phase
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD_CONTINUOUS)
		ge1:SetCode(EVENT_FREE_CHAIN)
		ge1:SetCondition(s.mechanic_con)
		ge1:SetOperation(s.mechanic_op)
		Duel.RegisterEffect(ge1,0)
		
		local ge2=ge1:Clone()
		Duel.RegisterEffect(ge2,1)
	end
end

-- 1. ĐIỀU KIỆN KÍCH HOẠT: Chỉ cần đang ở Battle Phase lượt mình và có quái chứa Material
function s.mechanic_con(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsBattlePhase() or Duel.GetTurnPlayer()~=tp then return false end
	if Duel.GetLocationCount(tp,LOCATION_M_ZONE)<=0 then return false end
	
	-- Quét toàn sân xem có con nào có chồng bài Material bên dưới không
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

-- 2. VẬN HÀNH CƠ CHẾ: Lôi bất kỳ lá nào dưới bụng ra sân
function s.mechanic_op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(e:GetHandler():GetOriginalCode(),0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		-- Lọc ra những con quái đang có Material
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_M_ZONE,0,nil)
		local host_g=Group.CreateGroup()
		for tc in aux.Next(g) do
			if tc:GetOverlayCount()>0 then
				host_g:AddCard(tc)
			end
		end
		
		if #host_g>0 then
			-- Chọn con quái đang chứa bài bên dưới
			local hc=host_g:Select(tp,1,1,nil):GetFirst()
			if hc then
				-- Lấy ra toàn bộ đống bài dưới bụng nó
				local mat=hc:GetOverlayGroup()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				-- Bạn thích chọn lá nào nhảy ra cũng được
				local sg=mat:Select(tp,1,1,nil)
				
				if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
					-- Đăng ký luật ép tự động chui lại vào bụng khi kết thúc Battle Phase
					local sc=sg:GetFirst()
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_FIELD_CONTINUOUS)
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
end

-- 3. TỰ ĐỘNG CHUI LẠI VÀO BỤNG QUÁI BẤT KỲ TRÊN SÂN
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
	-- Tìm bất kỳ con quái nào đang ngửa trên sân của bạn để chui lại vào làm Material
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_M_ZONE,0,nil)
	if #g>0 then
		local hc=g:Select(tp,1,1,nil):GetFirst()
		if hc then
			Duel.Overlay(hc,Group.FromCards(tc))
		end
	else
		-- Không còn ai trên sân thì đi xuống mộ bài
		Duel.SendtoGrave(tc,REASON_RULE)
	end
	e:Reset()
end

