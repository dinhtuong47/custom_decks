-- Giả sử đây là script của một con Vật Chủ hoặc Linh Thú
function s.initial_effect(c)
	-- [Hiệu ứng riêng của lá bài viết ở đây, ví dụ e1, e2...]

	-- =========================================================================
	-- ĐOẠN CODE DƯỚI ĐÂY LÀ KHỞI ĐỘNG CƠ CHẾ (Dán y hệt cho mọi lá bài trong tộc)
	-- =========================================================================
	if not s.global_check then
		s.global_check=true
		
		-- Tạo một hiệu ứng quét liên tục đăng ký thẳng vào hệ thống game
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD_CONTINUOUS)
		ge1:SetCode(EVENT_FREE_CHAIN) -- Quét liên tục để nháy bảng chọn khi đủ điều kiện
		ge1:SetCondition(s.mechanic_con)
		ge1:SetOperation(s.mechanic_op)
		Duel.RegisterEffect(ge1,0) -- Đăng ký cho Player 1
		
		local ge2=ge1:Clone()
		Duel.RegisterEffect(ge2,1) -- Đăng ký cho Player 2
	end
end

-- 1. ĐIỀU KIỆN KÍCH HOẠT CƠ CHẾ TRONG TRẬN ĐẤU
function s.mechanic_con(e,tp,eg,ep,ev,re,r,rp)
	-- Phải là Battle Phase và là lượt của mình
	if not Duel.IsBattlePhase() or Duel.GetTurnPlayer()~=tp then return false end
	-- Phải còn ô trống trên sân để gọi thú ra
	if Duel.GetLocationCount(tp,LOCATION_M_ZONE)<=0 then return false end
	
	-- Quét sân xem có con Vật Chủ nào đang chứa Linh Thú thuộc tộc này không (Mã tộc tạm thời là 0xXXXX)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_M_ZONE,0,nil)
	local has_beast=false
	for tc in aux.Next(g) do
		local mat=tc:GetOverlayGroup()
		if mat:IsExists(Card.IsSetCard,1,nil,0xXXXX) then
			has_beast = true
			break
		end
	end
	return has_beast
end

-- 2. VẬN HÀNH CƠ CHẾ: HIỆN POP-UP CHO NGƯỜI CHƠI CHỌN GỌI LINH THÚ
function s.mechanic_op(e,tp,eg,ep,ev,re,r,rp)
	-- Hiện bảng hỏi: "Bạn có muốn giải phóng Linh Thú không?"
	if Duel.SelectYesNo(tp,aux.Stringid(e:GetHandler():GetOriginalCode(),0)) then
		-- Bước 1: Chọn Vật Chủ đang chứa Linh Thú
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_M_ZONE,0,nil)
		local host_g=Group.CreateGroup()
		for tc in aux.Next(g) do
			if tc:GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0xXXXX) then
				host_g:AddCard(tc)
			end
		end
		
		if #host_g>0 then
			local hc=host_g:Select(tp,1,1,nil):GetFirst()
			if hc then
				-- Bước 2: Chọn con Linh Thú nằm trong bụng con Vật Chủ đó
				local mat=hc:GetOverlayGroup():Filter(Card.IsSetCard,nil,0xXXXX)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=mat:Select(tp,1,1,nil)
				
				-- Bước 3: Triệu hồi Đặc biệt ra sân
				if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
					-- Thêm luật tự động rút lui vào bụng ở END BATTLE PHASE cho con Linh Thú vừa nhảy ra
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

-- 3. LUẬT TỰ ĐỘNG CHUI LẠI VÀO BỤNG Ở END BATTLE PHASE
function s.return_con(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- Nếu con Linh Thú đó đã rời sân trước khi End Battle Phase thì hủy hiệu ứng này
	if not tc or not tc:IsLocation(LOCATION_M_ZONE) then 
		e:Reset()
		return false 
	end
	return true
end

function s.return_op(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- Quét tìm lại một con Vật Chủ ngửa trên sân để chui vào
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_M_ZONE,0,nil) -- Có thể thêm filter check hệ Vật Chủ nếu cần
	if #g>0 then
		local hc=g:Select(tp,1,1,nil):GetFirst()
		if hc then
			-- Luật Game: Tự động biến thành Material (Không tạo chain link, không bị negate)
			Duel.Overlay(hc,Group.FromCards(tc))
		end
	else
		-- Nếu không còn Vật Chủ nào trên sân, Linh Thú chết (gửi xuống GY)
		Duel.SendtoGrave(tc,REASON_RULE)
	end
	e:Reset() -- Xóa hiệu ứng continuous này sau khi thực hiện xong
end
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end

-- Draw logic
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(2)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end
