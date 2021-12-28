function cancelPartnerJacking( player, seat )
	local occupant = source:getOccupant( seat )
	if player ~= localPlayer or not occupant then return end
    for k, v in pairs( LOBBY_DATA.participants ) do
		if v.player == occupant then
			localPlayer:ShowError( "Это место в машине уже занял твой напарник" )
			cancelEvent()
		end
    end
end

function CreateDriverParkingPoint_handler( lobby_data )
	CEs.current_point = TRASH_POINTS[ lobby_data.trash_point_id ].parking -- + Vector3( 0, 0, 1.05 )
	CreateQuestPoint( CEs.current_point, function()
		triggerServerEvent( lobby_data.end_step, localPlayer )
	end, _, 50, 0, 0, CheckPlayerQuestVehicle, _, _, _, 0, 255, 0, 20, 3 )
	CEs.marker.slowdown_coefficient = nil
	CEs.marker.marker.size = 5
end
addEvent( "CreateDriverParkingPoint", true )
addEventHandler( "CreateDriverParkingPoint", root, CreateDriverParkingPoint_handler )

function CreateParkingDummyVehicle( lobby_data, position, rz )
	local ghost_truck = createVehicle( 524, position, 0, 0, rz )
	ghost_truck.alpha = 101
	ghost_truck.frozen = true
	ghost_truck:setCollisionsEnabled( false )
	ghost_truck:SetGPSMarker( { radius = 0, quest_state = false, PostJoin = function( ) end } )
	table.insert( CEs, ghost_truck )

	local SHADER_CODE = [[
		technique tec0
		{
			pass P0
			{
				AlphaRef = 0;
			}
		}
	]]
	local fix_alpha_shader = dxCreateShader( SHADER_CODE, 0, 50, false, "vehicle" )
	if fix_alpha_shader then
		engineApplyShaderToWorldTexture( fix_alpha_shader, "*", ghost_truck )
	end

	local function BlinkTruckAlpha( )
		ghost_truck.alpha = 205 - 204 * math.sin( math.pi * ( getTickCount( ) % 1337 ) / 1337 )
	end
	addEventHandler( "onClientRender", root, BlinkTruckAlpha )

	addEventHandler( "onClientElementDestroy", ghost_truck, function( )
		removeEventHandler( "onClientRender", root, BlinkTruckAlpha )
	end )

	local job_vehicle = LOBBY_DATA.job_vehicle
	CEs.check_parking_timer = setTimer( function( )
		if job_vehicle.position:distance( position ) < 0.5 then
			local delta_rz = math.abs( job_vehicle.rotation.z - rz )
			if delta_rz < 5 or delta_rz > 355 then
				CEs.check_parking_timer:destroy( )
				ghost_truck:destroy( )
				if not CheckPlayerQuestVehicle( true ) then return end
				triggerServerEvent( lobby_data.end_step, localPlayer )
			end
		end
	end, 200, 0 )
end

function CreateTrashUnloadPoint_handler( point )
	GEs.current_point = TRASH_UNLOAD_POINTS_VEHICLE[ point ]
	CreateQuestPoint( GEs.current_point.position, function()
		triggerServerEvent( LOBBY_DATA.end_step, localPlayer )
	end, _, 50, 0, 0, CheckPlayerQuestVehicle, _, _, _, 0, 255, 0, 20, 3 )
	CEs.marker.slowdown_coefficient = nil
	CEs.marker.marker.size = 5
end
addEvent( "CreateTrashUnloadPoint", true )
addEventHandler( "CreateTrashUnloadPoint", root, CreateTrashUnloadPoint_handler )

function ShowSituationalInfoPressKey( config )
	local self = { }

	local main_key_handler = config.key_handler
	config.key_handler = function( )
		if config.condition( ) then
			main_key_handler( )
			self.destroy( )
		end
	end

	self.timer = setTimer( function( )
		if config.condition( ) then
			if self.press_key_info then return end
			self.press_key_info = ibInfoPressKey( config )
		elseif self.press_key_info then
			self.press_key_info:destroy( )
			self.press_key_info = nil
		end
	end, 500, 0 )

	self.destroy = function( )
		DestroyTableElements( self )
	end

	if CEs.press_key_info then CEs.press_key_info:destroy( ) end
	CEs.press_key_info = self
end

function ShowInfoOpenBody( )
	ShowSituationalInfoPressKey( {
		condition = function ( )
			return CheckPlayerQuestVehicle( true )
		end,
        do_text = "Нажмите",
        key_text = "К",
        text = "чтобы открыть кузов",
        key = "k",
		black_bg = 0,
		key_handler = function( )
			triggerServerEvent( "onPlayerTryChangeTrashTruckOpenState", resourceRoot, true )

			local function onClientTrashTruckOpenStateChange( )
				removeEventHandler( "onClientTrashTruckOpenStateChange", LOBBY_DATA.job_vehicle, onClientTrashTruckOpenStateChange )
				CEs.info_timer = setTimer( function( )
					triggerServerEvent( LOBBY_DATA.end_step, resourceRoot )
				end, TRUCK_ACTIONS_INFO.open_doors.duration, 1 )
			end
			addEventHandler( "onClientTrashTruckOpenStateChange", LOBBY_DATA.job_vehicle, onClientTrashTruckOpenStateChange )
		end,
    } )
end

function StartTrashUnloading( )
	ShowSituationalInfoPressKey( {
		condition = function ( )
			return CheckPlayerQuestVehicle( true )
		end,
        do_text = "Нажмите",
        key_text = "К",
        text = "чтобы открыть кузов",
        key = "k",
		black_bg = 0,
		key_handler = function( )
			triggerServerEvent( "onPlayerTryChangeTrashTruckOpenState", resourceRoot, true )
		end,
    } )

	local function onClientTrashTruckOpenStateChange( )
		removeEventHandler( "onClientTrashTruckOpenStateChange", LOBBY_DATA.job_vehicle, onClientTrashTruckOpenStateChange )
		CEs.info_timer = setTimer( function( )
			ShowInfoLiftBody( )
		end, TRUCK_ACTIONS_INFO.open_doors.duration, 1 )
	end
	addEventHandler( "onClientTrashTruckOpenStateChange", LOBBY_DATA.job_vehicle, onClientTrashTruckOpenStateChange )
end

function ShowInfoLiftBody( )
	ShowSituationalInfoPressKey( {
		condition = function ( )
			return CheckPlayerQuestVehicle( true )
		end,
		do_text = "Нажмите",
		key_text = "ЛКМ",
		text = "чтобы поднять кузов",
		key = "mouse1",
		black_bg = 0,
		key_handler = function( )
			triggerServerEvent( "onPlayerTryChangeTrashTruckLiftState", resourceRoot, true )
		end,
	} )

	local function onClientTrashTruckLiftStateChange( )
		removeEventHandler( "onClientTrashTruckLiftStateChange", LOBBY_DATA.job_vehicle, onClientTrashTruckLiftStateChange )
		CEs.info_timer = setTimer( function( )
			ShowInfoDumpBody( )
		end, TRUCK_ACTIONS_INFO.lift_body.duration, 1 )
	end
	addEventHandler( "onClientTrashTruckLiftStateChange", LOBBY_DATA.job_vehicle, onClientTrashTruckLiftStateChange )
end

function ShowInfoDumpBody( )
	ShowSituationalInfoPressKey( {
		condition = function ( )
			return CheckPlayerQuestVehicle( true )
		end,
		do_text = "Нажмите",
		key_text = "ПКМ",
		text = "чтобы опустить кузов",
		key = "mouse2",
		black_bg = 0,
		key_handler = function( )
			triggerServerEvent( "onPlayerTryChangeTrashTruckLiftState", resourceRoot, false )
		end,
	} )

	local function onClientTrashTruckLiftStateChange( )
		removeEventHandler( "onClientTrashTruckLiftStateChange", LOBBY_DATA.job_vehicle, onClientTrashTruckLiftStateChange )
		CEs.info_timer = setTimer( function( )
			ShowInfoCloseBody( )
		end, TRUCK_ACTIONS_INFO.lift_body.duration, 1 )
	end
	addEventHandler( "onClientTrashTruckLiftStateChange", LOBBY_DATA.job_vehicle, onClientTrashTruckLiftStateChange )
end

function ShowInfoCloseBody( )
	ShowSituationalInfoPressKey( {
		condition = function ( )
			return CheckPlayerQuestVehicle( true )
		end,
		do_text = "Нажмите",
		key_text = "K",
		text = "чтобы закрыть кузов",
		key = "k",
		black_bg = 0,
		key_handler = function( )
			triggerServerEvent( "onPlayerTryChangeTrashTruckOpenState", resourceRoot, false )

			local function onClientTrashTruckOpenStateChange( )
				removeEventHandler( "onClientTrashTruckOpenStateChange", LOBBY_DATA.job_vehicle, onClientTrashTruckOpenStateChange )
				CEs.info_timer = setTimer( function( )
					triggerServerEvent( LOBBY_DATA.end_step, resourceRoot )
				end, TRUCK_ACTIONS_INFO.open_doors.duration, 1 )
			end
			addEventHandler( "onClientTrashTruckOpenStateChange", LOBBY_DATA.job_vehicle, onClientTrashTruckOpenStateChange )
		end,
	} )
end