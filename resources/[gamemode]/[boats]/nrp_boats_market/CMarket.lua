loadstring(exports.interfacer:extend("Interfacer"))()
Extend("ShUtils")
Extend("ShVehicleConfig")
Extend("Globals")
Extend("CPlayer")
Extend("CVehicle")
Extend("CInterior")
Extend("CUI")
Extend("ib")

ibUseRealFonts( true )

scx, scy = guiGetScreenSize()

function OnClientResourceStart()
	for k,v in pairs( MARKETS_LIST ) do
		CreateMarket( v, k )
	end
end
addEventHandler("onClientResourceStart", resourceRoot, OnClientResourceStart)

function CreateMarket( config, market_id )
	config.radius = config.radius or 2
	config.marker_text = "Верфь"
	config.keypress = "lalt"
	config.text = "ALT Взаимодействие"

	local store = TeleportPoint(config)
	store.marker:setColor( 0, 100, 255, 40 )
	store:SetImage( "files/img/icon_marker.png" )
	store.element:setData( "material", true, false )
    store:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.45 } )

	store.PreJoin = function( store, player )
		return true
	end
	store.PostJoin = function(store) 
		ShowUI_Market( true, market_id )
		triggerServerEvent( "onPlayerBoatMarketOpen", localPlayer, tonumber( config.assortment_id ) )
	end
	store.PostLeave = function(store) 
		ShowUI_Market( false ) 
	end
end