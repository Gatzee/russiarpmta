loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

local rechargeLastTime = 0

addEvent( "onShopNotEnoughHard", true )
addEventHandler( "onShopNotEnoughHard", root, function( place, event_callback, ... )
	local timestamp = getRealTimestamp( )

	if rechargeLastTime + 600 > timestamp then localPlayer:ShowError( "Недостаточно средств" ) return end

	rechargeLastTime = timestamp

	triggerServerEvent( "onGiveHardOfferShown", localPlayer, place )

	local args = ...

	showCursor( true )
	ibConfirm( {
		title = "Пополнение",
		text = "Вам не хватает на данный товар, желаете ли пополнить свой баланс?",
		priority = 10,
		fn = function( self )
			triggerServerEvent( "onGiveHardOfferAccepted", localPlayer, place )

			if event_callback then
				local result = triggerEvent( event_callback, resourceRoot, type( args ) == "table" and unpack( args ) or args )
				if not result then triggerServerEvent( event_callback, resourceRoot, type( args ) == "table" and unpack( args ) or args )  end
			end

			if localPlayer:getData( "f4_is_active" ) then
				triggerEvent( "SwitchNavbar", localPlayer, "donate" )
			else
				triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate" )
			end

			showCursor( false )
			self:destroy( )
		end,
		fn_cancel = function( self )
			showCursor( false )
			self:destroy( )
		end,
		escape_close = true,
	} )
end )

addEvent( "onConvertConfirmation", true )
addEventHandler( "onConvertConfirmation", resourceRoot, function( amount )
	showCursor( true )
	ibConfirm( {
		title = "Конвертация валюты",
		text = "Вам не хватает на данный товар, желаете конвертить донат ( " .. format_price( amount ) .. " ) для совершения покупки?",
		priority = 10,
		fn = function( self )
			triggerServerEvent( "onClientConvertConfirm", resourceRoot, true )
			showCursor( false )
			self:destroy()
		end,
		fn_cancel = function( self )
			triggerServerEvent( "onClientConvertConfirm", resourceRoot, false )
			showCursor( false )
			self:destroy()
		end,
		escape_close = true,
	} )
end )