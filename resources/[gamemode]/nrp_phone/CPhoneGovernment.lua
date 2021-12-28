GOVERNMENTAPP = nil

local CITY_NAMES_BY_GOV_ID = {
	[ F_GOVERNMENT_NSK ] = "Новороссийск";
	[ F_GOVERNMENT_GORKI ] = "Горки город";
	[ F_GOVERNMENT_MSK ] = "Москва";
}

APPLICATIONS.government = {
	id = "government";
	name = "Госуслуги",
	icon = "img/apps/government.png";
	elements = { };

	create = function( self, parent, conf )
		self.parent = parent
		self.conf = conf

		local real_fonts = ibIsUsingRealFonts( )
		ibUseRealFonts( true )
		
		self:create_list( )
		
		ibUseRealFonts( real_fonts ) 

		GOVERNMENTAPP = self
		return self
	end;

	create_list = function( self )
		self.elements.bg = ibCreateArea( 0, 0, 204, self.parent:ibData( "sy" ), self.parent )

		local list = { "fines", "vote", "fines2", "reports", "house_pay" }
		ibCreateImage( 0, 0, 204, 55, "img/elements/gov/head.png", self.elements.bg, 0xFFFFFFFF )

		for i, name in pairs( list ) do
			ibCreateButton(	0, 55 + 40 * ( i - 1 ), 204, 40, self.elements.bg,
							"img/elements/gov/btn_".. name .."_i.png", "img/elements/gov/btn_".. name .."_h.png", "img/elements/gov/btn_".. name .."_c.png", 0xFFFFFFFF, 0xFFFFFFFF - 0x55000000, 0xFFFFFFFF - 0xAA000000 )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					ibClick( )

					self.elements.loading = ibLoading( { parent = self.elements.bg } )
					triggerServerEvent( "onClientRequestGovernmentList", resourceRoot, name )
				end )
		end
	end;

	create_tab_fines = function( self, fines )
		local list_pane, scroll_v = ibCreateScrollpane( 0, 55, 204, self.parent:ibData( "sy" ) - 55, self.elements.bg, { scroll_px = -13, bg_color = 0x00FFFFFF } )
		scroll_v:ibBatchData( { absolute = true, sensivity = 75 } ):ibSetStyle( "slim_nobg" )

		local category_names = {
			businesses = "Бизнесмены";
			jobs = "Рабочие";
			rating = "Агитация власти";
		}
		for faction_id, faction_name in pairs( FACTIONS_NAMES ) do
			category_names[ "factions_".. faction_id ] = faction_name
		end

		local pos_y = 0
		for gov_id, fines_data in pairs( fines ) do
			pos_y = pos_y + 25

			ibCreateLabel( 13, pos_y, 0, 0, CITY_NAMES_BY_GOV_ID[ gov_id ], list_pane, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.regular_12, align_x = "left", align_y = "center" } )

			pos_y = pos_y + 5
			for category_id, fine in pairs( fines_data ) do
				if category_names[ category_id ] then
					pos_y = pos_y + 20

					ibCreateLabel( 13, pos_y, 0, 0, category_names[ category_id ] ..":", list_pane, 0xFFFFFFFF - 0x55000000 ):ibBatchData( { font = ibFonts.bold_9, align_x = "left", align_y = "center" } )

					ibCreateLabel( 13 + dxGetTextWidth( category_names[ category_id ], 1, ibFonts.bold_9 ) + 8, pos_y, 0, 0, fine .."%", list_pane, 0xFFFFFFFF )
						:ibBatchData( { font = ibFonts.bold_9, align_x = "left", align_y = "center" } )
				end
			end

			pos_y = pos_y + 25

			ibCreateImage( 0, pos_y, 204, 1, _, list_pane, 0x26000000 )
		end

		list_pane:AdaptHeightToContents( )
		scroll_v:UpdateScrollbarVisibility( list_pane )
	end;

	create_tab_vote = function( self, vote_data, last_gov_id )
		local gov_id, gov_data = next( vote_data, last_gov_id )
		
		if last_gov_id then
			destroyElement( self.elements.bg_tab_vote )

			if not gov_id then
				gov_id, gov_data = next( vote_data )
			end
		end

		local bg_area = ibCreateArea( 0, 55, 240, self.elements.bg:ibData( "sy" ) - 55, self.elements.bg )
		self.elements.bg_tab_vote = bg_area

		ibCreateLabel( 102, 20, 0, 0, CITY_NAMES_BY_GOV_ID[ gov_id ], bg_area, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.regular_10, align_x = "center", align_y = "center" } )
		ibCreateImage( 0, 40, 204, 1, _, bg_area, 0xFFFFFFFF - 0xF5000000 )

		ibCreateButton(	17, 63, 24, 24, self.elements.bg,
						"img/elements/gov/arrow_left.png", "img/elements/gov/arrow_left.png", "img/elements/gov/arrow_left.png",
						0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF - 0x50000000)
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				self:create_tab_vote( vote_data, gov_id )
			end )

		ibCreateButton(	163, 63, 24, 24, self.elements.bg,
						"img/elements/gov/arrow_left.png", "img/elements/gov/arrow_left.png", "img/elements/gov/arrow_left.png",
						0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF - 0x50000000)
			:ibData( "rotation", 180 )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				self:create_tab_vote( vote_data, gov_id )
			end )

		if gov_data.mayor_name then
			ibCreateLabel( 13, 62, 0, 0, "Имя мэра:", bg_area, 0xFFFFFFFF - 0x50000000 ):ibBatchData( { font = ibFonts.bold_10, align_x = "left", align_y = "center" } )
			ibCreateLabel( 13, 80, 0, 0, gov_data.mayor_name, bg_area, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.bold_10, align_x = "left", align_y = "center" } )

			ibCreateImage( 13, 95, 10, 10, "img/elements/gov/rating.png", bg_area )
			ibCreateLabel( 27, 100, 0, 0, "Рейтинг:", bg_area, 0xFFFFFFFF - 0x50000000 ):ibBatchData( { font = ibFonts.bold_8, align_x = "left", align_y = "center" } )
			ibCreateLabel( 78, 100, 0, 0, math.ceil( gov_data.rating or 0 ) .."%", bg_area, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.bold_8, align_x = "left", align_y = "center" } )
		else
			ibCreateLabel( 102, 78, 0, 0, "В вашем городе мэр пока\nне выбран", bg_area, 0xFFFFFFFF - 0x50000000 ):ibBatchData( { font = ibFonts.bold_10, align_x = "center", align_y = "center" } )
		end
		ibCreateImage( 0, 117, 204, 1, _, bg_area, 0x33000000 )

		ibCreateLabel( 13, 129, 0, 0, "ИМЯ КАНДИДАТА:", bg_area, 0xFFFFFFFF - 0x50000000 ):ibBatchData( { font = ibFonts.bold_6, align_x = "left", align_y = "center" } )
		ibCreateLabel( 191, 129, 0, 0, "ПРОЦЕНТ ГОЛОСОВ:", bg_area, 0xFFFFFFFF - 0x50000000 ):ibBatchData( { font = ibFonts.bold_6, align_x = "right", align_y = "center" } )
		ibCreateImage( 0, 140, 204, 1, _, bg_area, 0xFFFFFFFF - 0xF5000000 )

		if gov_data.candidates then
			if next( gov_data.candidates ) then
				table.sort( gov_data.candidates, function( frst, scnt )
					return frst.votes > scnt.votes
				end )

				local list_pane, scroll_v = ibCreateScrollpane( 0, 141, 204, 166, bg_area, { scroll_px = -13, bg_color = 0x00FFFFFF } )
				scroll_v:ibBatchData( { absolute = true, sensivity = 25 } ):ibSetStyle( "slim_nobg" )

				for i, candidate_data in pairs( gov_data.candidates ) do
					local bg = ibCreateImage( 0, 30 * ( i - 1 ), 204, 30, _, list_pane, ( i % 2 == 1 and 0xFF314050 or 0x00FFFFFF ) )
					ibCreateLabel( 13, 15, 0, 0, candidate_data.name, bg, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.bold_9, align_x = "left", align_y = "center" } )

					local percent_text = "-"
					if gov_data.all_votes > 0 then
						local percent = candidate_data.votes / gov_data.all_votes * 100
						if percent > 0 and percent < 1 then
							percent_text = "< 1%"
						else
							percent_text = math.floor( percent ).."%"
						end
					end
					ibCreateLabel( 180, 15, 0, 0, percent_text, bg, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.bold_9, align_x = "right", align_y = "center" } )
				end

				list_pane:AdaptHeightToContents( )
				scroll_v:UpdateScrollbarVisibility( list_pane )
			else
				local bg = ibCreateImage( 0, 141, 204, 30, _, bg_area, 0xFF314050 )
				ibCreateLabel( 102, 15, 0, 0, "Список кандидатов пуст", bg, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.regular_10, align_x = "center", align_y = "center" } )
			end
		else
			local bg = ibCreateImage( 0, 141, 204, 30, _, bg_area, 0xFF314050 )
			ibCreateLabel( 102, 15, 0, 0, "Выборы не проходят", bg, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.regular_10, align_x = "center", align_y = "center" } )
		end
	end;

	create_tab_fines2 = function( self, fines )
		if not fines or #fines < 1 then
			ibCreateImage( 0, 0, 149, 41, "img/elements/gov/no_fines.png", self.elements.bg, 0xFFFFFFFF ):center()
			return
		end

		local bg_area = ibCreateArea( 0, 55, 204, self.elements.bg:ibData( "sy" ) - 55, self.elements.bg )
		ibCreateImage( 0, 0, 204, bg_area:ibData("sy"), _, bg_area, 0xAA293441 )

		ibCreateLabel( 15, 35, 0, 28, "СТАТЬЯ:", bg_area, 0xFFFFFFFF - 0x50000000, 1, 1, "left", "center", ibFonts.bold_7 )
		ibCreateLabel( 204-15, 35, 0, 28, "СУММА ШТРАФА:", bg_area, 0xFFFFFFFF - 0x50000000, 1, 1, "right", "center", ibFonts.bold_7 )

		local list_pane, scroll_v = ibCreateScrollpane( 0, 62, 204, 200, bg_area, { scroll_px = -13, bg_color = 0x00FFFFFF } )
		scroll_v:ibBatchData( { absolute = true, sensivity = 75 } ):ibSetStyle( "slim_nobg" )

		local iTotalCash = 0

		local px, py = 0, 0
		for k,v in pairs(fines) do
			local pFineData = FINES_LIST[ v ]
			local fine_bg = ibCreateImage( px, py, 204, 30, _, list_pane, k/2 == math.floor(k/2) and 0x00000000 or 0xff314050 )
			ibCreateLabel( 15, 0, 0, 30, "ст. "..pFineData.id, fine_bg, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_9 )
			ibCreateLabel( 204-32, 0, 0, 30, format_price( pFineData.cost ), fine_bg, 0xFFFFFFFF, 1, 1, "right", "center", ibFonts.bold_9 )
			ibCreateImage( 204-26, 10, 14, 11, "img/elements/gov/icon_soft_tiny.png", fine_bg )
			py = py + 30
			iTotalCash = iTotalCash + pFineData.cost or 0
		end

		list_pane:AdaptHeightToContents( )
		scroll_v:UpdateScrollbarVisibility( list_pane )

		local total_cash_bg = ibCreateImage( 0, 0, 204, 35, _, bg_area, 0xAA293441 )
		local lbl_total = ibCreateLabel( 15, 0, 0, 35, "Общая сумма:", total_cash_bg, 0xFFFFFFFF - 0x50000000, 1, 1, "left", "center", ibFonts.bold_10 )
		local lbl_cash = ibCreateLabel( lbl_total:ibGetAfterX(5), 0, 0, 35, format_price( iTotalCash ) , total_cash_bg, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_10 )

		ibCreateImage( lbl_cash:ibGetAfterX(5), 10, 16, 13, "img/elements/gov/icon_soft_small.png", total_cash_bg )

		ibCreateButton( 204/2-50, bg_area:ibData("sy")-46, 100, 30, bg_area, "img/elements/gov/btn_pay.png", "img/elements/gov/btn_pay_h.png", "img/elements/gov/btn_pay_h.png",
			0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF - 0x50000000)
		:ibOnClick(function( button, state )
			if button == "left" and state == "down" then
				ibClick()

				if iTotalCash >= 60000 then
					localPlayer:ShowError("Такое количество штрафов можно оплатить только в отеделении ППС/ДПС!")
					return
				end

				local confirmation = ibConfirm(
				    {
				        title = "ОПЛАТА ШТРАФОВ", 
				        text = "Ты хочешь оплатить штрафы на сумму "..format_price(iTotalCash).."р.?" ,
				        fn = function( self )
				        	triggerServerEvent("OnPlayerTryPayFines", root )
				            self:destroy()
				            ShowPhoneUI(false)
						end,
						escape_close = true,
				    }
				)
			end
		end)
	end;

	create_tab_reports = function( self )
		local pPossibleFactions = {
			F_POLICE_PPS_NSK,
			F_POLICE_DPS_NSK,
			F_POLICE_PPS_GORKI,
			F_POLICE_DPS_GORKI,
			F_POLICE_PPS_MSK,
			F_POLICE_DPS_MSK,
		}

		local iSelectedIndex = 1
		local iSelectedFaction = pPossibleFactions[iSelectedIndex]

		local bg_area = ibCreateArea( 0, 55, 204, self.elements.bg:ibData( "sy" ) - 55, self.elements.bg )

		local list_pane, scroll_v = ibCreateScrollpane( 0, 55, 204, self.parent:ibData( "sy" ) - 115, self.elements.bg, { scroll_px = -13, bg_color = 0x00FFFFFF } )
		scroll_v:ibBatchData( { absolute = true, sensivity = 75 } ):ibSetStyle( "slim_nobg" )

		ibCreateLabel( 15, 17, 0, 0, "Подразделение", list_pane, 0xFFFFFFFF, _, _, _, _, ibFonts.bold_9 )

		local lbl_faction_name = ibCreateLabel( 102, 50, 0, 0, FACTIONS_NAMES[iSelectedFaction], list_pane, 0xFFFFFFFF, _, _, "center", "center", ibFonts.regular_9 )
		
		local function SwitchFaction( value )
			iSelectedIndex = (iSelectedIndex + value)%#pPossibleFactions
			iSelectedFaction = pPossibleFactions[iSelectedIndex+1]
			lbl_faction_name:ibData("text", FACTIONS_NAMES[iSelectedFaction])
		end

		ibCreateButton( 25, 38, 24, 24, list_pane, "img/elements/gov/arrow_left.png", "img/elements/gov/arrow_left.png", "img/elements/gov/arrow_left.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF - 0x50000000)
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
			SwitchFaction( -1 )
		end )

		ibCreateButton( 204-25-24, 38, 24, 24, list_pane, "img/elements/gov/arrow_left.png", "img/elements/gov/arrow_left.png", "img/elements/gov/arrow_left.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF - 0x50000000)
		:ibData( "rotation", 180 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
			SwitchFaction( 1 )
		end )

		ibCreateLabel( 15, 68, 0, 0, "Имя сотрудника:", list_pane, 0xFFFFFFFF, _, _, _, _, ibFonts.bold_9 )
		ibCreateImage( 15, 86, 176, 30, _, list_pane, 0xA0000000 )
		local edit_name = ibCreateWebEdit( 15, 86, 176, 30, "", list_pane, 0xFFffffff, 0 )
	    :ibData( "font", "regular_9_600" )
	    :ibData( "focusable", true )

		ibCreateLabel( 15, 121, 0, 0, "Звание сотрудника:", list_pane, 0xFFFFFFFF, _, _, _, _, ibFonts.bold_9 )
		ibCreateImage( 15, 139, 176, 30, _, list_pane, 0xA0000000 )
		local edit_rank = ibCreateWebEdit( 15, 139, 176, 30, "", list_pane, 0xFFffffff, 0 )
	    :ibData( "font", "regular_9_600" )
	    :ibData( "focusable", true )

		ibCreateLabel( 15, 176, 0, 0, "Краткое описание жалобы:", list_pane, 0xFFFFFFFF, _, _, _, _, ibFonts.bold_9 )
		ibCreateImage( 15, 194, 176, 62, _, list_pane, 0xA0000000 )
		local edit_reason = ibCreateWebMemo( 15, 194, 176, 62, "", list_pane, 0xFFFFFFFF, 0 )
        :ibData( "max_length", 100 )
        :ibData( "focusable", true )


		list_pane:AdaptHeightToContents( )
		scroll_v:UpdateScrollbarVisibility( list_pane )

		ibCreateButton( 102-50, bg_area:ibData("sy")-45, 100, 30, bg_area, "img/elements/gov/btn_send.png", "img/elements/gov/btn_send_h.png", "img/elements/gov/btn_send_h.png" )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )

			local pFields = 
			{
				name = { text = "имя", min = 6, max = 30, data = edit_name:ibData("text") },
				rank = { text = "звание", min = 6, max = 30, data = edit_rank:ibData("text") },
				reason = { text = "описание", min = 10, max = 100, data = edit_reason:ibData("text") },
			}

			for k,v in pairs( pFields ) do
				if utf8.len(v.data) < v.min then
					localPlayer:ShowError("Слишком короткое "..v.text)
					return false
				end

				if utf8.len(v.data) > v.max then
					localPlayer:ShowError("Слишком длинное "..v.text)
					return false
				end
			end

			local pDataToSend = 
			{
				name = pFields.name.data,
				faction = iSelectedFaction,
				rank = pFields.rank.data,
				reason = pFields.reason.data,
			}

			triggerServerEvent( "OnPlayerTrySendFactionReport", localPlayer, pDataToSend )

			ShowPhoneUI( false )
		end )
	end;

	create_tab_house_pay = function( self, house_data_list )
		local real_fonts = ibIsUsingRealFonts( )
		ibUseRealFonts( true )

		if not house_data_list or #house_data_list < 1 then
			ibCreateLabel( 0, 0, 0, 0, "У вас нет недвижимости", self.elements.bg, 0x80FFFFFF, 1, 1, "center", "center", ibFonts.bold_12 ):center()
			ibUseRealFonts( real_fonts )
			return
		end

		local scrollpane, scrollbar = ibCreateScrollpane(0, 55, 204, self.parent:ibData( "sy" ) - 55,
			self.elements.bg, { scroll_px = -10 })

		scrollbar:ibSetStyle( "slim_nobg" ):ibBatchData({
			handle_color = 0x0000000, handle_color_hover = 0x4D000000, handle_color_click = 0x77000000,
		})

		for i, house_data in pairs( house_data_list ) do
			ibCreateLabel( 8, ( i - 1 ) * 41, 196, 41, house_data.name, scrollpane, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_12 )
			ibCreateButton( 0, ( i - 1 ) * 41, 204, 41, scrollpane,
				_,_,_, 0x00000000, 0x734E6781, 0x4D4E6781)
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					ibClick()

					DestroyTableElements( self.elements )
					self:show_house_pay( house_data )
				end )
		end

		scrollpane:AdaptHeightToContents( )
		scrollbar:UpdateScrollbarVisibility( scrollpane )

  		ibUseRealFonts( real_fonts )
	end;

	show_house_pay = function( self, house_data )
		self.elements.bg = ibCreateArea( 0, 0, 204, self.parent:ibData( "sy" ), self.parent )

		ibCreateButton(	0, 0, 204, 55, GOVERNMENTAPP.elements.bg,
						"img/elements/gov/btn_b_house_pay_i.png", "img/elements/gov/btn_b_house_pay_h.png", "img/elements/gov/btn_b_house_pay_c.png",
						0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF - 0x50000000)
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				self.elements.loading = ibLoading( { parent = self.elements.bg } )
				triggerServerEvent( "onClientRequestGovernmentList", resourceRoot, "house_pay" )
			end )

		local real_fonts = ibIsUsingRealFonts( )
		ibUseRealFonts( true )

		if not house_data then
			ibCreateLabel( 0, 0, 0, 0, "У вас нет недвижимости", self.elements.bg, 0x80ffffff, 1, 1, "center", "center", ibFonts.bold_12 ):center()
			ibUseRealFonts( real_fonts )
			return
		end

		local bg_area = ibCreateArea( 0, 55, self.elements.bg:ibData( "sx" ), self.elements.bg:ibData( "sy" ) - 55, self.elements.bg )

		ibCreateLabel( 0, 14, bg_area:ibData( "sx" ), 0, house_data.name, bg_area, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_12 )

		local days = math.max( 0, house_data.paid_days )
		local days_text_label = ibCreateLabel( 14, 40, 0, 0, "Оплаченные дни: ", bg_area, 0x80ffffff, 1, 1, "left", "top", ibFonts.bold_12 )
		local days_label = ibCreateLabel( days_text_label:ibGetAfterX( ), 40, 0, 0, days..plural( days, " день", " дня", " дней" ), bg_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_12 )

		local debt = math.max( 0, -house_data.paid_days )
		local debt_text_label = ibCreateLabel( 14, 58, 0, 0, "Долг: ", bg_area, 0x80ffffff, 1, 1, "left", "top", ibFonts.bold_12 )
		local debt_label = ibCreateLabel( debt_text_label:ibGetAfterX( ), 58, 0, 0, debt..plural( debt, " день", " дня", " дней" ), bg_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_12 )

		ibCreateLabel( 0, 100, bg_area:ibData( "sx" ), 0, "Количество дней:", bg_area, 0x80ffffff, 1, 1, "center", "top", ibFonts.regular_12 )

		local cost_area = ibCreateArea( 0, 205, bg_area:ibData( "sx" ), 50, bg_area )
		local cost_text_label = ibCreateLabel( 0, 0, 0, 0, "Сумма оплаты:", cost_area, 0x80ffffff, 1, 1, "left", "top", ibFonts.bold_12 )
		local cost_label = ibCreateLabel( cost_text_label:ibGetAfterX( 3 ), 0, bg_area:ibData( "sx" ), 0, format_price( house_data.cost_day ), cost_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_12 )
		local money_img = ibCreateImage( cost_label:ibGetAfterX( 3 ), 0, 16, 16, ":nrp_shared/img/money_icon.png", cost_area )
		cost_area:ibData( "sx", money_img:ibGetAfterX( ) ):center_x( )

		local selected_days_count = 1
		local selected_days_btn

		for i = 1, 3 do
			local btn = ibCreateButton( 18 + ( i - 1 ) * 62, 126, 44, 44, bg_area, "img/elements/gov/btn_circle_i.png", "img/elements/gov/btn_circle_h.png", "img/elements/gov/btn_circle_h.png", COLOR_WHITE, COLOR_WHITE, 0xFFCCCCCC )
				:ibOnClick( function( button, state )
					if button ~= "left" or state ~= "up" then return end
					ibClick( )

					selected_days_count = i

					selected_days_btn:ibData( "color", COLOR_WHITE )
					source:ibData( "color", 0xFF808080 )
					selected_days_btn = source

					cost_label:ibData( "text", format_price( house_data.cost_day * i ) )
					money_img:ibData( "px", cost_label:ibGetAfterX( 3 ) )
					cost_area:ibData( "sx", money_img:ibGetAfterX( ) ):center_x( )
				end )
			ibCreateLabel( 0, 0, 0, 0, i, btn, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_18 ):center( )
			if i == 1 then
				selected_days_btn = btn
				btn:ibData( "color", 0xFF808080 )
			end
		end

		ibCreateButton( 0, bg_area:ibData("sy") - 60, 100, 30, bg_area, "img/elements/gov/btn_pay.png", "img/elements/gov/btn_pay_h.png", "img/elements/gov/btn_pay_h.png", _, _, 0xFFCCCCCC ):center_x( )
			:ibOnClick(function( button, state )
				if button ~= "left" or state ~= "up" then return end
				ibClick( )
				if not localPlayer:HasMoney( house_data.cost_day * selected_days_count ) then
					localPlayer:ShowError( "У вас недостаточно денег" )
					return
				end

				if house_data.type == "viphouse" then
					triggerServerEvent( "onViphouseAddcashAttempt", localPlayer, house_data.hid, selected_days_count, true )
				else
					triggerServerEvent( "PlayerWantPayApartment", localPlayer, house_data.id, house_data.number, selected_days_count, true )
				end
				ShowPhoneUI( false )
			end)

		ibUseRealFonts( real_fonts )
	end;

	destroy = function( self, parent, conf )
		DestroyTableElements( self.elements )
		GOVERNMENTAPP = nil
	end;
}

function onClientRequestGovernmentListCallback_handler( tab, data )
	if not GOVERNMENTAPP then return end

	destroyElement( GOVERNMENTAPP.elements.bg )
	GOVERNMENTAPP.elements.bg = ibCreateArea( 0, 0, 204, GOVERNMENTAPP.parent:ibData( "sy" ), GOVERNMENTAPP.parent )

	ibCreateButton(	0, 0, 204, 55, GOVERNMENTAPP.elements.bg,
					"img/elements/gov/btn_b_".. tab .."_i.png", "img/elements/gov/btn_b_".. tab .."_h.png", "img/elements/gov/btn_b_".. tab .."_c.png",
					0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF - 0x50000000)
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )

			destroyElement( GOVERNMENTAPP.elements.bg )
			GOVERNMENTAPP:create_list( )
		end )

	GOVERNMENTAPP[ "create_tab_".. tab ]( GOVERNMENTAPP, data )
end
addEvent( "onClientRequestGovernmentListCallback", true )
addEventHandler( "onClientRequestGovernmentListCallback", root, onClientRequestGovernmentListCallback_handler )