UI = { }

function ShowResultUI( state, data )
	if state then
		ShowResultUI( false )

		local clan_id = localPlayer:GetClanID( )
		local enemy_clan_id = nil
		for other_clan_id in pairs( data.scores ) do
			if other_clan_id ~= clan_id then
				enemy_clan_id = other_clan_id
			end
		end

		local is_victory = data.winner_clan_id == clan_id

		UI.black_bg = ibCreateBackground( 0xD7000000, ShowResultUI, nil, true )
		UI.screen_fading_bg = ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, _, UI.black_bg, COLOR_BLACK )

		UI.bg = ibCreateImage( 0, 0, 1599, 900, is_victory and "img/bg_win.png" or "img/bg_lose.png", UI.black_bg )
			:center_x( )

		local score_text = math.floor( data.scores[ clan_id ] or 0 ) .. " - " .. math.floor( data.scores[ enemy_clan_id ] or 0 )
		UI.lbl_score = ibCreateLabel( 0, 291, 0, 0, score_text, UI.bg, _, _, _, "center", "center", ibFonts.bold_36 )
			:ibData( "color", is_victory and 0xFF54ff68 or 0xFFd42d2d )
			:ibData( "outline", 1 )
			:center_x( )

		UI.bg_tag_left = ibCreateImage( UI.lbl_score:ibGetBeforeX( -20 - 67 ), 254, 67, 67, "img/bg_clan_tag.png", UI.bg )
		ibCreateImage( 0, 0, 64, 64, ":nrp_clans/img/tags/band/" .. ( GAME_DATA.clans_tags[ clan_id ] or -2 ) .. ".png", UI.bg_tag_left )
			:center_x( )

		ibCreateLabel( UI.bg_tag_left:ibGetBeforeX( -20 ), 287, 0, 0, ( GetClanName( clan_id ) or "Ваш клан" ), UI.bg, COLOR_WHITE, _, _, "right", "center", ibFonts.regular_20 )
			:ibData( "outline", 1 )

		UI.bg_tag_right = ibCreateImage( UI.lbl_score:ibGetAfterX( 20 ), 254, 67, 67, "img/bg_clan_tag.png", UI.bg )
		ibCreateImage( 0, 0, 64, 64, ":nrp_clans/img/tags/band/" .. ( GAME_DATA.clans_tags[ enemy_clan_id ] or -1 ) .. ".png", UI.bg_tag_right )
			:center_x( )

		ibCreateLabel( UI.bg_tag_right:ibGetAfterX( 20 ), 287, 0, 0, ( GetClanName( enemy_clan_id ) or "Вражеский клан" ), UI.bg, COLOR_WHITE, _, _, "left", "center", ibFonts.regular_20 )
			:ibData( "outline", 1 )

		if data.event_id == CLAN_EVENT_CARTEL_CAPTURE then
			local text = localPlayer:IsInCartelClan( ) and ( is_victory and "ВЫ ОТБИЛИ ДОМ КАРТЕЛЯ"    or "ВЫ ПОТЕРЯЛИ ДОМ КАРТЕЛЯ" )
														or ( is_victory and "ВЫ ЗАХВАТИЛИ ДОМ КАРТЕЛЯ" or "ВЫ НЕ СМОГЛИ ЗАХВАТИТЬ ДОМ КАРТЕЛЯ" )
			
			ibCreateLabel( 0, _SCREEN_Y - 275, 0, 0, text, UI.bg )
				:center_x( )
				:ibBatchData( { outline = true, align_x = "center", align_y = "center", font = ibFonts.bold_20 } )

		elseif data.event_id == CLAN_EVENT_CARTEL_TAX_WAR then
			local text = localPlayer:IsInCartelClan( ) and ( is_victory and "ВЫ ОГРАБИЛИ ОБЩАК КЛАНА \"%s\"" or "КЛАН \"%s\" ОТБИЛ ОБЩАК" ):format( utf8.upper( GetClanName( enemy_clan_id ) or "" ) )
														or ( is_victory and "ВЫ ОТБИЛИ СВОЙ ОБЩАК" 			 or "КАРТЕЛЬ ОГРАБИЛ ВАШ ОБЩАК" )
			
			ibCreateLabel( 0, _SCREEN_Y - 275, 0, 0, text, UI.bg )
				:center_x( )
				:ibBatchData( { outline = true, align_x = "center", align_y = "center", font = ibFonts.bold_20 } )

		else
			local list = { }
			local event_conf = CLAN_EVENT_CONFIG[ data.event_id ]
			if is_victory then
				local rewards_data = event_conf.rewards
				ParseRewardsFromTable( rewards_data, list )
				if rewards_data.player then
					ParseRewardsFromTable( rewards_data.player, list )
				end
			else
				table.insert( list, { type = "clan_honor", value = -event_conf.loser_clan_honor_loss } )
				table.insert( list, { type = "clan_money", value = -event_conf.loser_clan_money_loss } )

				ibCreateLabel( 0, _SCREEN_Y - 275, 0, 0, "ВАШИ ПОТЕРИ:", UI.bg )
					:center_x( )
					:ibBatchData( { outline = true, align_x = "center", align_y = "center", font = ibFonts.bold_20 } )
			end

			localPlayer:ShowRewards( {
				no_auto_destroy = true,
				no_title = not is_victory,
				big = true,
				offset_y = -90,
				list = list,
			} )
		end
			
		local offset = 80
		UI.timehide = ibCreateArea( 0, _SCREEN_Y - offset, 0, 0, UI.black_bg )
		UI.lbl_name= ibCreateLabel( 0, 0, 0, 0, "Автовыход:", UI.timehide, ibApplyAlpha( COLOR_WHITE, 80 ), _, _, "left", "center", ibFonts.bold_24 )
			:ibData( "outline", 1 )

		local time = 10
		local timestamp = os.time( ) + time
		local lbl_time = ibCreateLabel( UI.lbl_name:ibGetAfterX( 8 ), 0, 0, 0, getTimerString( timestamp ), UI.timehide, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_26 )
			:ibData( "outline", 1 )
			:ibTimer( function( self )
				self:ibData( "text", getTimerString( timestamp ) )
				UI.timehide:ibData( "sx", self:ibGetAfterX( ) ):center_x( )
			end, 1000, 0 )
		UI.timehide:ibData( "sx", lbl_time:ibGetAfterX( ) ):center_x( )
		
		UI.black_bg
			:ibData( "alpha", 0 )
			:ibAlphaTo( 255, 500 )
		
		UI.screen_fading_bg
			:ibData( "alpha", 0 )
			:ibAlphaTo( 255, time * 1000 )

	elseif isElement( UI.black_bg ) then
		if data then
			UI.black_bg:ibAlphaTo( 0, 1000 ):ibTimer( destroyElement, 1000, 1 )
		else
			destroyElement( UI.black_bg )
		end
		localPlayer:ShowRewards( nil )
	end
end

addEventHandler( "onClientResourceStop", resourceRoot, function( )
	if isElement( UI.black_bg ) then
		localPlayer:ShowRewards( nil )
	end
end )

-- function onResultClientKey_handler( key )
-- 	if key == "space" then
-- 		removeEventHandler( "onClientKey", root, onResultClientKey_handler )
-- 	end
-- end

local rewards_types = {
	clan_money = true,
	clan_honor = true,
	clan_exp = true,
	money = true,
}

function ParseRewardsFromTable( tbl, output_list )
	for k, v in pairs( tbl ) do
		if rewards_types[ k ] then
			table.insert( output_list, { type = k, value = v } )
		end
	end
end