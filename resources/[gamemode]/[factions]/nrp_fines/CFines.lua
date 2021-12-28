loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "CPlayer" )
Extend( "CInterior" )
Extend( "ib" )
Extend( "ShUtils" )

ibUseRealFonts( true )

scx, scy = guiGetScreenSize()


function OnClientResourceStart()
	for k, v in pairs(PAY_FINES_LOCATIONS) do
		CreatePayFinesLocation( v )
	end
end
addEventHandler("onClientResourceStart", resourceRoot, OnClientResourceStart)

function CreatePayFinesLocation( config )
	config.keypress = "lalt"
	config.radius = config.radius or 1.5
	config.marker_text = "Оплата штрафов"

	local point = TeleportPoint(config)
	point.element:setData( "material", true, false )
	point:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 121, 38, 255, 1.2 } )
	point.marker:setColor(255, 121, 38, 50)

	point.PreJoin = function( point, player )
		return true
	end
	point.PostJoin = function(point) 
		triggerServerEvent( "OnPlayerRequestShowFinesList", resourceRoot, localPlayer, config.jail_id )
	end
	point.PostLeave = function(point) 
		ShowUI_FinesList( false )
	end
end