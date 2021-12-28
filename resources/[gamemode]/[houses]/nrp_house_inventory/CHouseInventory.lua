loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CInterior" )
Extend( "CPlayer" )

function CreateMarker( id, number, position, interior, dimension )
	local config = {
		text = "ALT Взаимодействие",
		keypress = "lalt",
		radius = 1,
		x = position.x;
		y = position.y;
		z = position.z;
		interior = interior or 0;
		dimension = dimension or 0;
		color = { 0, 191, 255, 50 },
	}

	local marker = TeleportPoint( config )
	
	marker:SetImage( "img/marker.png" )
	marker.element:setData( "material", true, false )
    marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 191, 255, 255, 0.75 } )

	marker.PreJoin = function( _, player )
		return not player:getData( "in_clan_event_lobby" ) and not localPlayer:GetCoopJobLobbyId()
	end

	marker.PostJoin = function( _, player )
		triggerServerEvent( "onPlayerWantShowHouseInventory", resourceRoot, id, number )
	end

    marker.PostLeave = function( self, player )
        triggerEvent( "CloseInventory", resourceRoot, id .. "_" .. number )
    end

	return marker.element
end