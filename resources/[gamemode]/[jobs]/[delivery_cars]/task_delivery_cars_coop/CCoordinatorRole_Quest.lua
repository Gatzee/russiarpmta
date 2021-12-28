
addEvent( "onClientDriverTakePoint", true )

function CreateMarkerPathInterface( conf )
    local self = conf
    self.current_point_id = 1

    self.create_marker = function( self, point_id )
        local id = "mrk" .. point_id
        CreateQuestPoint( CAR_ROUTES[ self.route_id ][ point_id ], nil, id, point_id == #CAR_ROUTES[ self.route_id ] and END_POINT_MARKER_SIZE or POINT_MARKER_SIZE, 0, 0, CheckFailIfVehicle, _, _, _, 0, 255, 0, 20, 3 )
        return CEs[ id ]
    end

    self.create_next_marker = function( self )
        if self.next_marker then
            self.current_marker = self.next_marker
            self.next_marker = nil
        else
            self.current_marker = self:create_marker( self.current_point_id )
        end
        self.current_marker.marker.size = POINT_MARKER_SIZE

        local next_marker_id = self.current_point_id + 1
        if CAR_ROUTES[ self.route_id ][ next_marker_id ] then
            self.next_marker = self:create_marker( next_marker_id )
            self.next_marker.marker.size = math.floor( POINT_MARKER_SIZE / 2 )
        end        
    end

    self.on_take_point = function()
        self.current_marker:destroy()
        self.current_point_id = self.current_point_id + 1
            
        if CAR_ROUTES[ self.route_id ][ self.current_point_id ] then
            self:create_next_marker()
        else
            self:destroy()
        end
    end
    addEventHandler( "onClientDriverTakePoint", resourceRoot, self.on_take_point )

    self.destroy = function( self )
        removeEventHandler( "onClientDriverTakePoint", resourceRoot, self.on_take_point )
        
        if self.current_marker then self.current_marker:destroy() end
        if self.next_marker then self.next_marker:destroy() end
    end

    self:create_next_marker()
    
    return self
end

function AddHeliHandlers( vehicle )
    function onClientVehicleDamage_handler( theAttacker, theWeapon )
        if source.health < 390 then
			triggerServerEvent( "onServerPlayerFailCoopQuest", localPlayer, "уничтожил служебный вертолет", "destroy_helicopter" )
		end
	end
	addEventHandler( "onClientVehicleDamage", vehicle, onClientVehicleDamage_handler )
end

function CreateBlipDeliveredVehicle( lobby_data )	
	CEs.gps_marker = lobby_data.delivery_vehicle:SetGPSMarker({
        radius = 0,
        color = { 255, 0, 0, 0 },
        x = lobby_data.delivery_vehicle.position.x, y = lobby_data.delivery_vehicle.position.y, z = lobby_data.delivery_vehicle.position.z, 
        blip = { id = 0, size = 2, color = { 255, 255, 255, 255 } },
		PostJoin = function( ) end,
        quest_state = false,
	} )
end

function DestroyBlipDliveredVehicle( )
	if isElement( CEs.blip_delivery_vehicle ) then 
		destroyElement( CEs.blip_delivery_vehicle ) 
	end
end