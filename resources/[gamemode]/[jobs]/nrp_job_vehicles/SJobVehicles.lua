loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "ShPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )

VEHICLE_DATA = { }

VEHICLE_IGNORE_CHECK_WATER = {
    [ 595 ] = true,
}

function CreateJobVehicleRequest_handler( args )
    local resource = sourceResource or getThisResource( )

    local px, py, pz = args.position.x, args.position.y, args.position.z

    args.rotation = args.rotation or Vector3( )
    local rx, ry, rz = args.rotation.x , args.rotation.y, args.rotation.z

    Vehicle.AsyncCreate( 
        "CreateJobVehicleRequest_Callback", 
        { 
            player = source,
            args = args,
            resource = resource,
        }, 
        args.model, px, py, pz, rx, ry, rz
    )
end
addEvent( "CreateJobVehicleRequest" )
addEventHandler( "CreateJobVehicleRequest", root, CreateJobVehicleRequest_handler )

function CreateJobVehicleRequest_Callback_handler( conf )
    local args = conf.args

    local vehicle = source
    local player = conf.player

    local resource = conf.resource
    local resource_root = getResourceRootElement( resource )

    VEHICLE_DATA[ vehicle ] = { 
        timers = { }, 
        elements = { }, 
        player = player,
        resource = resource,
        ignore_warp_vehicle = conf.ignore_warp_vehicle,
    }
    if args.all_controllers then
        VEHICLE_DATA[ vehicle ].all_controllers = args.all_controllers
    end
    
    if args.city then
        VEHICLE_DATA[ vehicle ].city = args.city
    end

    if args.block_repair then
        vehicle:setData( "block_repair", args.block_repair, false )
    end

    -- Общая обработка удаления машины
    addEventHandler( "onElementDestroy", vehicle, function( )
        local data = VEHICLE_DATA[ vehicle ]

        if data.onDestroy and resource_root then
            triggerEvent( "onJobVehicleDestroyed", resource_root, vehicle, data )
        end

        for i, v in pairs( data.element or { } ) do
            if isElement( v ) then destroyElement( v ) end
        end
        for i, v in pairs( data.timers or { } ) do
            if isTimer( v ) then killTimer( v ) end
        end
        VEHICLE_DATA[ vehicle ] = nil
    end )

    -- Аттач к отключению ресурса работы
    addEventHandler( "onResourceStop", resource_root, function( )
        if isElement( vehicle ) then destroyElement( vehicle ) end
    end )

    -- Аттач к отключению текущего ресурса
    addEventHandler( "onResourceStop", resourceRoot, function( )
        if isElement( vehicle ) then destroyElement( vehicle ) end
    end )

    -- Аттач к смене игрока
    if args.destroy_on_shift_end then
        addEvent( "PlayerAction_EndJobShift", true )
        --Возможность цеплять авто к сразу нескольким игрокам
        if VEHICLE_DATA[ vehicle ].all_controllers  then
            for player_in, v in pairs( VEHICLE_DATA[ vehicle ].all_controllers ) do

                function PlayerAction_EndJobShift_handler()
                    if isElement( vehicle ) then
                        local pcount = 0
                        for player_c, v in pairs( VEHICLE_DATA[ vehicle ].all_controllers ) do
                            pcount = pcount + 1
                        end
                        VEHICLE_DATA[ vehicle ].all_controllers[source] = nil

                        --Иначе будет вызываться повторно
                        removeEventHandler( "PlayerAction_EndJobShift", source, PlayerAction_EndJobShift_handler )

                        if pcount > 1 then return end

                        vehicle:destroy()
                    end
                end
                addEventHandler( "PlayerAction_EndJobShift", player_in, PlayerAction_EndJobShift_handler )

            end
        else
            --Если на смене не предусмотрены несколько игроков
            addEventHandler( "PlayerAction_EndJobShift", player, function( )
                if isElement( vehicle ) then destroyElement( vehicle ) end
            end )
        end
    end

    VEHICLE_DATA[ vehicle ].damage_threshold = args.damage_threshold
    -- Аттач к дамагу машины
    addEventHandler( "onVehicleDamage", vehicle, function( loss )
        if isElement( vehicle ) then
            if vehicle.health <= ( args.damage_threshold or 360 ) then
                triggerEvent( "onJobVehicleDamage", vehicle, VEHICLE_DATA[ vehicle ] )

                if not wasEventCancelled( ) and isElement( vehicle ) then
                    destroyElement( vehicle )
                end
            end
        end
	end )

    -- Могут садиться только разрешенные игроки
    args.allowed_players = args.allowed_players or { [ player ] = true }
    if args.allowed_players then
        addEventHandler( "onVehicleStartEnter", vehicle, function( enter_player, seat )
			if not args.allowed_players[ enter_player ] or not enter_player:GetOnShift() then
				cancelEvent( )
			end
		end )
    end

    -- Обработка машин без действия
    SetVehicleMaxIdle_handler( vehicle, args.max_idle )

    -- Макс топливо
    vehicle:SetFuel( "full" )

    triggerEvent( args.callback_event, resource_root, vehicle, VEHICLE_DATA[ vehicle ] )
end
addEvent( "CreateJobVehicleRequest_Callback", true )
addEventHandler( "CreateJobVehicleRequest_Callback", root, CreateJobVehicleRequest_Callback_handler )

function SetVehicleMaxIdle_handler( vehicle, max_idle )
    local data = VEHICLE_DATA[ vehicle ]

    data.last_active = data.last_active or getTickCount( )

    if max_idle and max_idle >= 50 then
        VEHICLE_DATA[ vehicle ].max_idle = max_idle

    else
        VEHICLE_DATA[ vehicle ].max_idle = nil

    end
    CheckVehicleRequiresTimer( vehicle )
end
addEvent( "SetVehicleMaxIdle", true )
addEventHandler( "SetVehicleMaxIdle", root, SetVehicleMaxIdle_handler )

function PingVehicle_handler( vehicle )
    local vehicle = vehicle or source
    if VEHICLE_DATA[ vehicle ] then
        VEHICLE_DATA[ vehicle ].last_active = getTickCount( )
    end
end
addEvent( "PingVehicle", true )
addEventHandler( "PingVehicle", root, PingVehicle_handler )

function CheckVehicleRequiresTimer( vehicle )
    local data = VEHICLE_DATA[ vehicle ]
    if isTimer( data.timers.pulse_timer ) then return end
    data.timers.pulse_timer = setTimer( PulseVehicle, 10000, 0, vehicle )
end

function PulseVehicle( vehicle )
    local data = VEHICLE_DATA[ vehicle ]
    local tick = getTickCount( )

    if data.max_idle and ( tick - data.last_active >= data.max_idle ) then
        triggerEvent( "onJobVehicleIdle", vehicle, data )

        if not wasEventCancelled( ) then
            if isElement( vehicle ) then destroyElement( vehicle ) end
            return
        end
    end

    if data.damage_threshold and vehicle.health <= ( data.damage_threshold or 360 ) then
        triggerEvent( "onJobVehicleDamage", vehicle, VEHICLE_DATA[ vehicle ] )
        return
    end

    if VEHICLE_IGNORE_CHECK_WATER[ vehicle.model ] then return end
    if isElementInWater( vehicle ) then
        vehicle.health = 360
        triggerEvent( "onJobVehicleDamage", vehicle, VEHICLE_DATA[ vehicle ], true )

        if not wasEventCancelled( ) then
            if isElement( vehicle ) then destroyElement( vehicle ) end
            return
        end
    end
end

--[[
-- Async Creation
function OnVehicleAsyncCreateRequest(callbackEvent, args, ...)
	local pVehicle = CreateVehicle( _, ... )

	triggerEvent( callbackEvent, pVehicle, args )
end
addEvent("OnVehicleAsyncCreateRequest", true)
addEventHandler("OnVehicleAsyncCreateRequest", root, OnVehicleAsyncCreateRequest)
]]