
function AddDeliveryVehicleHandlers( target_vehicle )
	GEs.target_vehicle = target_vehicle

	GEs.onVehicleEnter = function( vehicle )
		if vehicle ~= target_vehicle then return end

	end
	addEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.onVehicleEnter )

	function onClientVehicleDamage_handler( theAttacker, theWeapon )
		if source.health < 390 then
			triggerServerEvent( "onServerPlayerFailCoopQuest", localPlayer, "разбил доставляемое авто", "destroy_car" )
		end
	end
	addEventHandler( "onClientVehicleDamage", GEs.target_vehicle, onClientVehicleDamage_handler )

	GEs._pulse_tmr = setTimer( function()
		if isElement( target_vehicle ) and (isElementInWater( target_vehicle ) or target_vehicle.health < 390) then
			triggerServerEvent( "onServerPlayerFailCoopQuest", localPlayer, "разбил доставляемое авто", "destroy_car" )
		end
	end, 1000, 0 )
end

function RemoveDeliveryVehicleHandlers()
	if isTimer( GEs._pulse_tmr ) then killTimer( GEs._pulse_tmr ) end

	if GEs.onVehicleEnter then
		removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.onVehicleEnter )
	end
	
	if isElement( GEs.target_vehicle ) then
		removeEventHandler( "onClientVehicleDamage", GEs.target_vehicle, onClientVehicleDamage_handler )
	end
end

Vehicle.calculateFBPosition = function( self, direction, distance )
	if direction == 1 then distance = distance * -1 end
	local x, y, z  = getElementPosition( self )
	local _, _, rz = getElementRotation( self )
	
    x = x - math.sin( math.rad( rz ) ) * distance
	y = y + math.cos( math.rad( rz ) ) * distance
	
    return Vector3( x, y, z )
end

Player.RotateToTarget = function( self, target )
	self.rotation = Vector3( 0,  0, FindRotation( self.position.x, self.position.y, target.x, target.y ) )
end

function onClientGetLastMarker_handler( route_id )
	CreateQuestPoint( CAR_ROUTES[ route_id ][ #CAR_ROUTES[ route_id ] ], function()
		CEs.marker:destroy()
	end, _, 5, 0, 0, CheckFailNotVehicle, false, false, "cylinder", 0, 100, 230, 50 )
end
addEvent( "onClientGetLastMarker", true )
addEventHandler( "onClientGetLastMarker", resourceRoot, onClientGetLastMarker_handler )

function ShowEnterHeliHint( state, lobby_data )
	if CEs.hint_enter_heli then CEs.hint_enter_heli:destroy() end
	if state then
		CEs.hint_enter_heli = CreateSutiationalHint( {
			text = "Нажми key=G чтобы сесть в вертолёт пассажиром",
			condition = function( )
				return isElement( lobby_data.heli_vehicle ) and ( localPlayer.position - lobby_data.heli_vehicle.position ).length <= 4
			end
		} )
	end
end


function CreateColshapePathInterface( conf )
    local self = conf
    self.current_point_id = 1

	self.create_colshape = function( self, point_id )
		local position = CAR_ROUTES[ self.route_id ][ point_id ]
        local colshape = createColCircle( position.x, position.y, point_id == #CAR_ROUTES[ self.route_id ] and 3 or POINT_MARKER_SIZE )
        return colshape
    end

    self.create_next_colshape = function( self )
        if isElement( self.next_colshape ) then
            self.current_colshape = self.next_colshape
            self.next_colshape = nil
        else
            self.current_colshape = self:create_colshape( self.current_point_id )
        end

        addEventHandler( "onClientColShapeHit", self.current_colshape, function( element )
            if element ~= self.target_player or element.vehicle ~= self.target_vehicle then return end
            
			triggerServerEvent( "onServerDriverTakePoint", resourceRoot, self.current_point_id )
			
			self.current_colshape:destroy()
			self.current_point_id = self.current_point_id + 1
            if self.current_point_id > #CAR_ROUTES[ self.route_id ] then
                self:callback()
            else
				self:create_next_colshape()
				if self.current_point_id == #CAR_ROUTES[ self.route_id ] then
					CreateQuestPoint( CAR_ROUTES[ self.route_id ][ self.current_point_id ], function()
						CEs.marker:destroy()
					end, _, END_POINT_MARKER_SIZE, 0, 0, _, _, _, _, 0, 255, 0, 20, 3 )
				end
			end
        end )

        local next_colshape_id = self.current_point_id + 1
        if CAR_ROUTES[ self.route_id ][ next_colshape_id ] then
            self.next_colshape = self:create_colshape( next_colshape_id )
        end        
    end

	self.destroy = function( self )
		if isElement( self.end_marker ) then destroyElement( self.end_marker ) end
        if isElement( self.current_colshape ) then destroyElement( self.current_colshape ) end
        if isElement( self.next_colshape ) then destroyElement( self.next_colshape ) end
    end

    self:create_next_colshape()
    
    return self
end