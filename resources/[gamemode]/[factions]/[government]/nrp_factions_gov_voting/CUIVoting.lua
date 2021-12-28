loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "CPlayer" )
Extend( "ShUtils" )
Extend( "ib" )

ibUseRealFonts( true )

local UIe = { }

local CITY_NAMES_BY_GOV_ID = {
	[ F_GOVERNMENT_NSK ] = "города Новороссийка";
	[ F_GOVERNMENT_GORKI ] = "города Горки";
	[ F_GOVERNMENT_MSK ] = "города Москвы";
}

function ShowConfirmRegisterCandidacy( gov_id, cost )
	showCursor( true )

	UIe.confirmation = ibConfirm(
		{
			title = "ПОДАЧА КАНДИДАТУРЫ";
			text = "Ты хочешь баллотироваться на пост мэра\n".. CITY_NAMES_BY_GOV_ID[ gov_id ] .." и участвовать в выборах?\n".. ( cost and ( "Стоимость: ".. format_price( cost ) .." р." ) or "" );
			fn = function( self )
				triggerServerEvent( "PlayerRegisterCandidacy", resourceRoot, gov_id )
				HideUIVoting()
				self:destroy()
			end;
			fn_cancel = function( self )
				HideUIVoting()
			end;
			escape_close = true,
		}
	)
end
addEvent( "ShowConfirmRegisterCandidacy", true )
addEventHandler( "ShowConfirmRegisterCandidacy", resourceRoot, ShowConfirmRegisterCandidacy )

function ShowUIVoting( gov_id, candidates, player_vote )
	if isElement( UIe.black_bg ) then
		destroyElement( UIe.black_bg )
	end

	UIe.black_bg = ibCreateBackground( _, HideUIVoting, _, true )
	showCursor( true )

	UIe.bg				= ibCreateImage( 0, 0, 600, 580, "images/bg.png", UIe.black_bg )
							:center():ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )

	UIe.btn_close		= ibCreateButton(	548, 25, 24, 24, UIe.bg,
											":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
											0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
							:ibData( "priority", 1 )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end
								ibClick( )
								HideUIVoting()
							end, false )

	ibCreateLabel( 30, 37, 0, 0, "Выборы Мэра ".. CITY_NAMES_BY_GOV_ID[ gov_id ], UIe.bg ):ibBatchData( { font = ibFonts.bold_21, align_x = "left", align_y = "center" } )
	ibCreateLabel( 245, 98, 0, 0, player_vote or "-", UIe.bg ):ibBatchData( { font = ibFonts.bold_18, align_x = "left", align_y = "center" } )

	ibCreateLabel( 30, 135, 0, 0, "Имя Фамилия", UIe.bg, 0x4CFFFFFF ):ibBatchData( { font = ibFonts.regular_12, align_x = "left", align_y = "center" } )
	ibCreateLabel( 498, 135, 0, 0, "Выбор кандидатуры", UIe.bg, 0x4CFFFFFF ):ibBatchData( { font = ibFonts.regular_12, align_x = "center", align_y = "center" } )

	UIe.list_pane, scroll_v = ibCreateScrollpane( 0, 156, 600, 343, UIe.bg, { scroll_px = -18, bg_color = 0x00FFFFFF } )
	scroll_v:ibBatchData( { absolute = true, sensivity = 75 } ):ibSetStyle( "slim_nobg" )

	local i = 0
	for user_id, user_name in pairs( candidates ) do
		local bg = ibCreateImage( 0, 40 * i, 600, 40, _, UIe.list_pane, ( i % 2 == 0 and 0x40314050 or 0x00FFFFFF ) )
		i = i + 1

		ibCreateLabel( 30, 20, 0, 0, user_name, bg ):ibBatchData( { font = ibFonts.regular_16, align_x = "left", align_y = "center" } )

		ibCreateButton(	433, 8, 130, 24, bg, "images/btn_select_i.png", "images/btn_select_h.png", "images/btn_select_c.png" )
			:ibData( "color_disabled", 0x80FFFFFF )
			:ibData( "disabled", player_vote and true or false )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				triggerServerEvent( "PlayerSelectVotingCandidate", resourceRoot, user_id )
			end, false )
	end

	UIe.list_pane:AdaptHeightToContents( )
	scroll_v:UpdateScrollbarVisibility( UIe.list_pane )
end
addEvent( "ShowUIVoting", true )
addEventHandler( "ShowUIVoting", resourceRoot, ShowUIVoting )

function HideUIVoting( )
	if isElement( UIe and UIe.black_bg ) then
		destroyElement( UIe.black_bg )
	end
	showCursor( false )
end