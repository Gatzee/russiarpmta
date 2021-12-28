Extend( "ShUtils" )
Extend( "CInterior" )

local MEDBOOK_MARKERS = { }

function ShowMedbookMarker( show )
	DestroyTableElements( MEDBOOK_MARKERS )
	if not show then return end

	-- Больница НСК
	MEDBOOK_MARKERS.nsk = TeleportPoint( 
		{ 
			x = 441.824, y = -1600.561, z = 1020.968, 
			interior = 1, dimension = 1,
			radius = 1.5, 
			color = { 255, 121, 38, 50 },
			keypress = "lalt", 
			text = "ALT Взаимодействие",
			PostJoin = ShowMedbookBuying,
			marker_text = "Мед.Книжка",
		} 
	)

	-- Больница Горки
	MEDBOOK_MARKERS.gorki = TeleportPoint( 
		{ 
			x = 1935.762, y = 310.135, z = 660.966,
			interior = 1, dimension = 1,
			radius = 1.5, 
			color = { 255, 121, 38, 50 },
			keypress = "lalt", 
			text = "ALT Взаимодействие",
			PostJoin = ShowMedbookBuying,
			marker_text = "Мед.Книжка",
		} 
	)

	-- Больница МСК
	MEDBOOK_MARKERS.msk = TeleportPoint( 
		{ 
			x = -1986.804, y = 1990.814, z = 1797.890,
			interior = 2, dimension = 2,
			radius = 1.5, 
			color = { 255, 121, 38, 50 },
			keypress = "lalt", 
			text = "ALT Взаимодействие",
			PostJoin = ShowMedbookBuying,
			marker_text = "Мед.Книжка",
		} 
	)

	MEDBOOK_MARKERS.nsk.element:setData( "material", true, false )
	MEDBOOK_MARKERS.nsk:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 121, 38, 255, 1.15 } )

	MEDBOOK_MARKERS.gorki.element:setData( "material", true, false )
	MEDBOOK_MARKERS.gorki:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 121, 38, 255, 1.15 } )

	MEDBOOK_MARKERS.msk.element:setData( "material", true, false )
	MEDBOOK_MARKERS.msk:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 121, 38, 255, 1.15 } )
end
addEvent( "ShowMedbookMarker", true )
addEventHandler( "ShowMedbookMarker", resourceRoot, ShowMedbookMarker )

function ShowMedbookBuying( )
	if localPlayer:getData( "current_quest" ) then
		localPlayer:ShowInfo( "Заверши текущую задачу!" )
		return
	end

	showCursor( true )
	ibConfirm(
		{
			title = "ПОКУПКА МЕД. КНИЖКИ", 
			text = "Мед. книжка ускоряет возрождение. Вы уверены, что хотите купить мед. книжку за " .. format_price( MEDBOOK_COST ) .. "р.?" ,
			fn = function( self )
				triggerServerEvent( "onPlayerTryBuyMedbook", resourceRoot )
				self:destroy()
				showCursor( false )
			end,
			fn_cancel = function( self ) 
				showCursor( false ) 
			end,
			escape_close = true,
		}
	)
end