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
	for k,v in pairs( WORKSHOPS_LIST ) do
		CreateRepairStore( v, k )
	end
end
addEventHandler("onClientResourceStart", resourceRoot, OnClientResourceStart)

function CreateRepairStore( config, workshop_id )
	config.keypress = "lalt"
	config.text = "ALT Взаимодействие"
	config.radius = config.radius or 5
	config.marker_text = "Обслуживание водной техники"
	config.accepted_elements = { player = true, vehicle = true }

	local workshop = TeleportPoint(config)
	workshop.marker:setColor(0,100,255,40)
	workshop:SetImage( "files/img/icon_marker.png" )
	workshop.element:setData( "material", true, false )
    workshop:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 3.45 } )

	workshop.PreJoin = function( workshop, player )
		return true
	end
	workshop.PostJoin = function(workshop) 
		triggerServerEvent( "OnPlayerHitSpecialBoatWorkshopMarker", localPlayer, workshop_id )
	end
	workshop.PostLeave = function(workshop) 
		ShowUI_Workshop( false )
	end

	workshop.elements = {}
	workshop.elements.blip = Blip( config.x, config.y, config.z, 9, 2, 255, 0, 0, 255, 0, 300 )
end