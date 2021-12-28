loadstring(exports.interfacer:extend("Interfacer"))()
Extend("Globals")

SDB_SEND_CONNECTIONS_STATS = true
Extend("SDB")

Extend("ShUtils")
Extend("ShVehicleConfig")
Extend("SVehicle")
Extend("SPlayer")

COLUMNS =
{
	{ Field = "id",							Type = "int(11) unsigned",			Null = "NO",	Key = "PRI",		Default = NULL,	Extra = "auto_increment", options = { ignored = true } };
	{ Field = "owner_pid",					Type = "varchar(12)",				Null = "NO",	Key = "",			Default = NULL	};
	{ Field = "model",						Type = "smallint(3) unsigned",		Null = "NO",	Key = "",			Default = NULL	};
	{ Field = "health",						Type = "smallint(5)",				Null = "NO",	Key = "",			Default = 1000	};
	{ Field = "x",							Type = "float",						Null = "NO",	Key = "",			Default = NULL	};
	{ Field = "y",							Type = "float",						Null = "NO",	Key = "",			Default = NULL	};
	{ Field = "z",							Type = "float",						Null = "NO",	Key = "",			Default = NULL	};
	{ Field = "rx",							Type = "float",						Null = "YES",	Key = "",			Default = NULL	};
	{ Field = "ry",							Type = "float",						Null = "YES",	Key = "",			Default = NULL	};
	{ Field = "rz",							Type = "float",						Null = "YES",	Key = "",			Default = NULL	};
	{ Field = "interior",					Type = "smallint(5) unsigned",		Null = "NO",	Key = "",			Default = 0		};
	{ Field = "dimension",					Type = "smallint(5) unsigned",		Null = "NO",	Key = "",			Default = 0		};
	{ Field = "fuel",						Type = "float unsigned",			Null = "NO",	Key = "",			Default = 100	};
	{ Field = "mileage",					Type = "float unsigned",			Null = "NO",	Key = "",			Default = 0		};
	{ Field = "mileage_since_lp",			Type = "float unsigned",			Null = "NO",	Key = "",			Default = 0		};
	{ Field = "mileage_total",				Type = "float unsigned",			Null = "NO",	Key = "",			Default = 0		};
	{ Field = "number_plate",				Type = "text",						Null = "YES",	Key = "",			Default = NULL	};
	{ Field = "variant",					Type = "smallint(5) unsigned",		Null = "NO",	Key = "",			Default = 1		};
	--{ Field = "tuning",					Type = "text",						Null = "YES",	Key = "",			Default = NULL, options = { json = true, autofix = true }	};
	--{ Field = "upgrades",					Type = "text",						Null = "YES",	Key = "",			Default = NULL, options = { json = true, autofix = true }	};
	{ Field = "windows_color",				Type = "text",						Null = "YES",	Key = "",			Default = NULL, options = { json = true, autofix = true }	};
	{ Field = "locked",						Type = "enum('on','off')",			Null = "NO",	Key = "",			Default = "off"	};
	{ Field = "wheels_states",				Type = "text",						Null = "YES",	Key = "",			Default = NULL, options = { json = true, autofix = true }	};
	{ Field = "panels_states",				Type = "text",						Null = "YES",	Key = "",			Default = NULL, options = { json = true, autofix = true }	};
	{ Field = "doors_states",				Type = "text",						Null = "YES",	Key = "",			Default = NULL, options = { json = true, autofix = true }	};
	{ Field = "lights_states",				Type = "text",						Null = "YES",	Key = "",			Default = NULL, options = { json = true, autofix = true }	};
	{ Field = "color",						Type = "varchar(255)",				Null = "NO",	Key = "",			Default = "[[ 255, 255, 255, 0, 0, 0, 128, 128, 128, 64, 64, 64 ]]", options = { json = true, autofix = true }	};
	{ Field = "headlights_color",			Type = "varchar(255)",				Null = "NO",	Key = "",			Default = "[[]]", options = { json = true, autofix = true }	};
	{ Field = "flags",						Type = "varchar(255)",				Null = "YES",	Key = "",			Default = NULL	};
	{ Field = "condition",					Type = "text",						Null = "YES",	Key = "",			Default = NULL, options = { json = true, autofix = true }	};
	{ Field = "deleted",					Type = "bigint(20)",				Null = "YES",	Key = "",			Default = NULL	};
	{ Field = "last_owner",					Type = "text",						Null = "YES",	Key = "",			Default = NULL	};
	{ Field = "comment",					Type = "text",						Null = "YES",	Key = "",			Default = NULL	};
	{ Field = "custom_data",				Type = "text",						Null = "YES",	Key = "",			Default = NULL, options = { json = true }	};
	{ Field = "blocked",					Type = "enum('yes','no')",			Null = "NO",	Key = "",			Default = "no"	};
	{ Field = "parked",						Type = "enum('yes','no')",			Null = "NO",	Key = "",			Default = "no"	};
	{ Field = "hydraulics",					Type = "enum('yes','no')",			Null = "NO",	Key = "",			Default = "no"	};
	{ Field = "wheels",						Type = "int(6) unsigned",			Null = "NO",	Key = "",			Default = 0		};
	{ Field = "wheels_color",				Type = "varchar(255)",				Null = "NO",	Key = "",			Default = "[[255, 255, 255]]", options = { json = true, autofix = true }	};
	{ Field = "height_level",				Type = "int(2)",					Null = "NO",	Key = "",			Default = 0		};
	{ Field = "black_platecolor",			Type = "text",						Null = "YES",	Key = "",			Default = NULL	};
	{ Field = "tuning_internal",			Type = "text",						Null = "YES",	Key = "",			Default = NULL, options = { json = true, autofix = true }	};
	{ Field = "tuning_external",			Type = "text",						Null = "YES",	Key = "",			Default = NULL, options = { json = true, autofix = true }	};
	{ Field = "neon_data",					Type = "text",						Null = "YES",	Key = "",			Default = NULL, options = { json = true }	};
	{ Field = "temp_timeout",				Type = "int(11) unsigned",			Null = "YES",	Key = "",			Default = NULL	};
	
	{ Field = "creation_date",				Type = "int(11) unsigned",			Null = "NO",	Key = "",			Default = NULL,	options = { ignored = true } };
	
	{ Field = "dmg_total",					Type = "float",						Null = "YES",	Key = "",			Default = NULL };
	{ Field = "dmg_since_lp",				Type = "float",						Null = "YES",	Key = "",			Default = NULL };
	
	{ Field = "sell_last_date",				Type = "int(11) unsigned",			Null = "YES",	Key = "",			Default = NULL };
	{ Field = "sell_count",					Type = "int(11) unsigned",			Null = "YES",	Key = "",			Default = NULL };

	{ Field = "change_status_last_date",	Type = "int(11) unsigned",			Null = "YES",	Key = "",			Default = NULL };

	{ Field = "evacuated",					Type = "enum('yes','no')",			Null = "NO",	Key = "",			Default = "no"	};

	{ Field = "race_circle_count",  		Type = "int(11) unsigned",			Null = "NO",    Key = "",			Default = 0 };
	{ Field = "race_circle_points", 		Type = "int(11) unsigned",			Null = "NO",    Key = "",			Default = 0 };

	{ Field = "race_drift_count",   		Type = "int(11) unsigned",			Null = "NO",    Key = "",			Default = 0 };
	{ Field = "race_drift_points",  		Type = "int(11) unsigned",			Null = "NO",    Key = "",			Default = 0 };

	{ Field = "race_drag_count",    		Type = "int(11) unsigned",			Null = "NO",    Key = "",			Default = 0 };
	{ Field = "race_drag_points",   		Type = "int(11) unsigned",			Null = "NO",    Key = "",			Default = 0 };
}

LOCKED_KEY = "custom_data"

COLUMNS_REVERSE = { }
COLUMNS_LIST = { }
for i, v in pairs( COLUMNS ) do
	COLUMNS_REVERSE[ v.Field ] = not v.locked and ( v.options or { } )
	table.insert( COLUMNS_LIST, v.Field )
end

DB:createTable("nrp_vehicles", COLUMNS)

-- Индексы
local requests = { 
	"CREATE INDEX owner_pid ON nrp_vehicles( owner_pid );",
}
for i, v in pairs( requests ) do DB:exec( v ) end


VEHICLES = {}
VEHICLE_DATA = {}
VEHICLES_SAVE_TIMERS = { }

IGNORED_VEHICLES = {}
IRREGULAR_VEHICLES = {}

addEvent( "onVehiclePreLoad", true )

function VSetPermanentData_handler( key, value )
	if client then return end
	local vehicle_data = VEHICLE_DATA[ source ]
	if vehicle_data then
		if COLUMNS_REVERSE[ key ] then
			vehicle_data[ key ] = value
		else
			if vehicle_data[ "custom_data" ] then 
				vehicle_data[ "custom_data" ][ key ] = value
			else
				vehicle_data[ "custom_data" ] = { [ key ] = value } 
			end
		end
	end
end
addEvent( "VSetPermanentData" )
addEventHandler( "VSetPermanentData", root, VSetPermanentData_handler )

function VGetPermanentData( vehicle, key )
	local vehicle_data = VEHICLE_DATA[ vehicle ]
	if vehicle_data then
		if COLUMNS_REVERSE[ key ] then
			return vehicle_data[ key ]
		else
			local data = vehicle_data[ "custom_data" ]
			return data and data[ key ]
		end
	end
end

function VGetAllPermanentData( vehicle )
	return VEHICLE_DATA[ vehicle ]
end

-- Add to database
function AddVehicle( config, bCreate, callback_event, callback_args )
	if not config.model or not VEHICLE_CONFIG[ config.model ] then
		return false, "Не указана модель, или неверный ID модели"
	end

	local pDefaultValues =
	{
		color = { 255, 255, 255, 255, 255, 255 },
		x = 0, y = 0, z = 0,
		rx = 0, ry = 0, rz = 0,
		variant = 1,
		owner_pid = NULL,
		fuel = VEHICLE_CONFIG[ config.model ] and VEHICLE_CONFIG[ config.model ].fuel or 100, 
	}

	for k,v in pairs(pDefaultValues) do
		if not config[k] then
			config[k] = v
		end
	end

	local iPlateType = VEHICLE_CONFIG[ config.model ].is_moto and PLATE_TYPE_MOTO or PLATE_TYPE_AUTO
	config.number_plate = iPlateType == PLATE_TYPE_AUTO and GenerateRandomNumberInCategory( NUMBER_TYPE_REGULAR, iPlateType ) or GenerateRandomNumber( iPlateType )
	--config.number_plate = '01:B888BB88'
	--iprint('Нужно пофиксить, стоит заглушка. 167 строка SVehicles.lua')
	exports.nrp_vehicle_numberplates:SetNumberLocked( config.number_plate, true )

	local sQuery = DB:prepare( 
		"INSERT INTO nrp_vehicles (creation_date, model, variant, color, owner_pid, x, y, z, rx, ry, rz, fuel, number_plate) VALUES (UNIX_TIMESTAMP(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
		config.model, config.variant, toJSON(config.color), config.owner_pid, config.x, config.y, config.z, config.rx, config.ry, config.rz, config.fuel, config.number_plate
	)
	if bCreate then
		local function callback_func( query, callback_event, callback_args, resource_name )
			local _, _, id = query:poll( -1 )
			LoadVehicle( id, true, callback_event, callback_args, resource_name, config, true )
		end

		local resource_name = sourceResource and getResourceName( sourceResource )

		DB:queryAsync( callback_func, { callback_event, callback_args, resource_name }, sQuery )
	else
		DB:exec( sQuery )
	end

	if callback_args and callback_args.player then
		local c = VEHICLE_CONFIG[ config.model ]

		if c.is_moto and config.model ~= 468 then
			triggerEvent( "onPlayerSomeDo", callback_args.player, "add_moto" ) -- achievements
		elseif not c.is_boat and not c.is_airplane then
			triggerEvent( "onPlayerSomeDo", callback_args.player, "add_car" ) -- achievements
		end
	end

	return true
end

-- Load AND create from database
function LoadVehicle( iID, bAsync, callback_event, callback_args, resource_name, additional_permanent_data, is_new )
	if bAsync then
		DB:queryAsync(function( queryHandler, callback_event, callback_args, resource_name )
			local result = dbPoll( queryHandler, 0 )
			if type ( result ) ~= "table" or #result == 0 then
				return
			end

			local conf = result[1]
			local pVehicle = nil
			local error_reason = nil

			if IsSpecialVehicle( conf.model ) and conf.health < 400 then
				error_reason = "Невозможно вызвать ТС с такими повреждениями, воспользуйтесь мастерской для его ремонта"
			else
				pVehicle = CreateVehicle( iID, conf.model, conf.x, conf.y, conf.z, conf.rx, conf.ry, conf.rz, conf, additional_permanent_data )
			end

			if callback_event and ( pVehicle or error_reason ) then
				local resource = resource_name and getResourceFromName( resource_name )
				local source_element = resource and getResourceRootElement( resource ) or root

				triggerEvent( callback_event, source_element, pVehicle, callback_args, error_reason )
			end

			local config = pVehicle and VEHICLE_DATA[ pVehicle ] or false
			if config then
				local player = GetPlayer( tonumber( config.owner_pid:match( "p:(%d+)" ) ) )
				if player and not config.temp_timeout and config.owner_pid then

					-- remove moped
					if not IsSpecialVehicle( config.model ) then
						local player_vehicles = player:GetVehicles( false, true )
						if #player_vehicles > 1 then
							for _, veh in ipairs( player_vehicles ) do
								if veh.model == 468 then
									DestroyForever( veh:GetID( ) )
									break
								end
							end
						end
					end

					-- send event if it's new vehicle
					if is_new then
						triggerEvent( "onPlayerGotNewVehicle", player, pVehicle )
					end
				end
			end

		end, { callback_event, callback_args, resource_name }, "SELECT * FROM nrp_vehicles WHERE ID=? LIMIT 1", iID )

		return true
	end
end

local table_insert = table.insert
local table_concat = table.concat

function SaveVehicle_handler( )
	local vehicle = source
	SaveVehicle( vehicle:GetID() )
end
addEvent( "SaveVehicle", true )
addEventHandler( "SaveVehicle", root, SaveVehicle_handler )

-- Update vehicle data in database
function SaveVehicle( id, force_synchronous )
	if id <= 0 then return end
	local vehicle = GetVehicle( id )

	if not isElement( vehicle ) then return end

	local vehicle_data = { }

	-- Конвертация в JSON или сохранение
	for i, v in pairs( VEHICLE_DATA[ vehicle ] ) do
		local col_info = COLUMNS_REVERSE[ i ] or { }
		local is_permanent_data = i == LOCKED_KEY

		if col_info.json or is_permanent_data then
			vehicle_data[ i ] = toJSON( v or { }, true ) or "[[]]"
		elseif not col_info.ignore then
			vehicle_data[ i ] = v
		end
	end

	-- Колёса
	vehicle_data.wheels_states = toJSON( { getVehicleWheelStates( vehicle ) }, true )

	-- Другие параметры
	vehicle_data.health 	= getElementHealth( vehicle )
	vehicle_data.interior 	= getElementInterior( vehicle )
	vehicle_data.dimension 	= getElementDimension( vehicle )
	vehicle_data.locked 	= isVehicleLocked( vehicle ) and "on" or "off"
	vehicle_data.blocked 	= vehicle:GetBlocked() and "yes" or "no"
	vehicle_data.parked		= vehicle:GetParked() and "yes" or "no"
	vehicle_data.hydraulics = vehicle:GetHydraulics() and "yes" or "no"
	vehicle_data.x, vehicle_data.y, vehicle_data.z 		= getElementPosition( vehicle )
	vehicle_data.rx, vehicle_data.ry, vehicle_data.rz 	= getElementRotation( vehicle )

	-- Подготовка запроса
	local query_table = { }
	for i, v in pairs( vehicle_data ) do
		local q = dbPrepareString( DB, "`??`=?", i, v )
		table_insert( query_table, q )
	end

	local query_str = table_concat( { "UPDATE nrp_vehicles SET ", table_concat( query_table, ", " ), DB:prepare( " WHERE id=? LIMIT 1", id ) }, '' )

	if force_synchronous then
		local query = DB:query( query_str )
		dbPoll( query, -1 )
	else
		DB:exec( query_str )
	end
end

-- Async Creation
function OnVehicleAsyncCreateRequest(callbackEvent, args, ...)
	local pVehicle = CreateVehicle( _, ... )

	if isElement( pVehicle ) then
		triggerEvent( callbackEvent, pVehicle, args )
	end
end
addEvent("OnVehicleAsyncCreateRequest", true)
addEventHandler("OnVehicleAsyncCreateRequest", resourceRoot, OnVehicleAsyncCreateRequest)

-- Create element
local min_huge = -math.huge
function CreateVehicle( id, model, x, y, z, rx, ry, rz, config, additional_permanent_data )
	if not id then
		for i = -1, min_huge, -1 do
			if not VEHICLES[ i ] then
				id = i
				break
			end
		end
	end

	if VEHICLES[ id ] and isElement( VEHICLES[ id ] ) then
		return false, "Vehicle already exists"
	end

	local vehicle = createVehicle( model, x or 0, y or 0, z or 0, rx or 0, ry or 0, rz or 0)

	if vehicle then
		removeVehicleSirens( vehicle )

		VEHICLE_DATA[ vehicle ] = { custom_data = {} }
		VEHICLES[ id ] = vehicle

		vehicle:SetID( id )
		vehicle:SetVariant( 1 )

		local function onVehicleDestroy( )
			DestroySaveTimerForVehicle( vehicle )
			VEHICLES[ id ] = nil
			VEHICLE_DATA[ vehicle ] = nil
			IGNORED_VEHICLES[ vehicle ] = nil
			IRREGULAR_VEHICLES[ vehicle ] = nil
		end
		addEventHandler( "onElementDestroy", vehicle, onVehicleDestroy )

		if VEHICLE_CONFIG[ vehicle.model ] and VEHICLE_CONFIG[ vehicle.model ].special_type == "boat" then
			addEventHandler( "onVehicleStartExit", vehicle , onVehicleStartExit_handler )
		end

		if config then

			for i, v in pairs( config ) do
				local col_reverse = COLUMNS_REVERSE[ i ]
				if col_reverse then
					if col_reverse.json then
						config[ i ] = type( v ) == "string" and fromJSON( v ) or { }
						if col_reverse.autofix then
							local new_data = { }
							for k, n in pairs( config[ i ] ) do
								new_data[ tonumber( k ) or k ] = n
							end
							config[ i ] = new_data
						end
					end
				end
			end

			-- Данные, которые не были заинсертены в бд при добавлении машины
			if additional_permanent_data then
				local custom_data = config.custom_data
				for k,v in pairs( additional_permanent_data ) do
					if COLUMNS_REVERSE[ k ] then
						config[ k ] = v
					else
						custom_data[ k ] = v
					end
				end
			end

			-- После первого создания машины, id может быть пустой
			config.id = config.id or id

			VEHICLE_DATA[ vehicle ] = config

			-- Инфа о владельце и комплектации должна быть еще до отсылки ивента
			setElementData( vehicle, "_ownerpid", config.owner_pid )
			local config_variant = config.variant
			if config_variant and config_variant > 1 then
				if VEHICLE_CONFIG[ model ] and VEHICLE_CONFIG[ model ].variants[ config_variant ] then
					vehicle:SetVariant( config_variant )
				else
					VEHICLE_DATA[ vehicle ].variant = 1
				end
			end
			triggerEvent( "onVehiclePreLoad", vehicle, config )

			-- Если onVehiclePreLoad изменил какие-то данные, заново их берем
			config = VEHICLE_DATA[ vehicle ]

			-- Нужная хуетень
			setElementData( vehicle, "_numplate", config.number_plate )

			-- Несинхронизируемая нужная хуететь
			setElementData( vehicle, "fFuel", config.fuel or 0, false )
			setElementData( vehicle, "fMileage", config.mileage or 0, false )
			
			-- Старая хуетень
			if config.flags and config.flags ~= "0" then
				for i, flag in pairs( split( config.flags, "," ) or { } ) do
					if flag == "untradable" or flag == "govuntradable" then
						config.custom_data[ flag ] = true
					end
				end
				config.flags = false
			end

			-- Всякая ересь
			setElementHealth( vehicle, math.clamp( config.health or 1000, 350, 1000 ) )
			if config.dimension and config.dimension > 0 then setElementDimension( vehicle, config.dimension ) end
			if config.interior and config.interior > 0 then setElementInterior( vehicle, config.interior ) end
			if config.locked == "on" then setVehicleLocked( vehicle, true ) end
			if config.blocked == "yes" then vehicle:SetBlocked( true ) end
			if config.parked == "yes" then vehicle:SetParked( true, Vector3( x, y, z ), Vector3( rx, ry, rz ) ) end

			-- Состояние частей ремонта
			local condition = config.condition
			if not condition or not next( condition ) then
				condition = {
					panels = {},
					doors = {},
					lights = {},
					engine = 0,
				}
				for i = 0, 6 do condition.panels[ tostring(i) ] = 0 end
				for i = 0, 5 do condition.doors[ tostring(i) ] = 0 end
				for i = 0, 3 do condition.lights[ tostring(i) ] = 0 end
			end
			setElementData( vehicle, "condition", condition, false )

			setVehicleOverrideLights( vehicle, 1 ) -- для того, чтобы не было проблем с состоянием фар по дефолту

			-- Состояние повреждений панелей, дверей, фар, колёс
			local wheels_states = config.wheels_states or { 0, 0, 0, 0 }
			if #wheels_states > 0 then setVehicleWheelStates( vehicle, unpack( wheels_states ) ) end

			local player = GetPlayer( vehicle:GetOwnerID(), true )
			if player then player:AddVehicleToList( vehicle ) end

			triggerEvent( "onVehiclePostLoad", vehicle, config )

		end
	end

	return vehicle
end

-- Destroy any
function DestroyVehicle( iID, force_synchronous )
	local pVehicle = VEHICLES[iID]
	if pVehicle then
		if pVehicle:GetSpecialType() then
			OnSpecialVehicleDestroyed( pVehicle )
		end

		DestroySaveTimerForVehicle( pVehicle )
		if isElement(pVehicle) then

			--Если авто ожидает/в процессе эвакуации
			if pVehicle:getData( 'tow_evac_added' ) then
				pVehicle:SetParked( true )
			end
			
			SaveVehicle( iID, force_synchronous )
			destroyElement( pVehicle )
		end
		VEHICLES[iID] = nil
		VEHICLE_DATA[pVehicle] = nil
		IGNORED_VEHICLES[ pVehicle ] = nil
		IRREGULAR_VEHICLES[ pVehicle ] = nil
	end
end

-- Destroy owned vehicle
function DestroyForever( iID, reason )
	local pVehicle = VEHICLES[ iID ]
	if pVehicle then
		if isElement( pVehicle ) then
			local iOwnerID = pVehicle:GetOwnerID( )
			local pPlayer = GetPlayer( iOwnerID, true )
			if pPlayer then pPlayer:RemoveVehicleFromList( pVehicle ) end

			destroyElement( pVehicle )

			DB:exec( "DELETE FROM nrp_vehicles WHERE id = ? LIMIT 1", iID )
		end

		VEHICLES[ iID ] = nil
		VEHICLE_DATA[ pVehicle ] = nil

		return true
	else
		return false
	end
end

addEventHandler("onResourceStop",resourceRoot,function()
	for k,v in pairs(VEHICLES) do
		DestroyVehicle( k, true )
	end

	for k,v in pairs(getElementsByType("player")) do
		v:SetPrivateData( "pVehiclesList", {} )
	end
end)

addEventHandler("onResourceStart",resourceRoot,function()
	for k,v in pairs( getElementsByType("player") ) do
		if v:IsInGame() then
			PlayerReadyToPlay( v )
		end
	end

	-- rm after release 10.06.21
	DB:exec( "DELETE FROM nrp_vehicles WHERE owner_pid LIKE ?", "-%" )
end)

function PlayerReadyToPlay_Callback( queryHandler, player )
	if not isElement( player ) then
		dbFree( queryHandler )
		return
	end

	local result = dbPoll( queryHandler, -1 )

	local data = player:GetBatchPermanentData( "last_vehicle_id", "last_vehicle_seat" )
	local last_vehicle_id = data.last_vehicle_id

	player:SetPrivateData( "pVehiclesList", {} )
	player:SetPrivateData( "pSpecialVehiclesList", {} )

	for k, conf in pairs( result ) do
		local vehicle_id = conf.id

		if IsSpecialVehicle( conf.model ) then
			player:AddSpecialVehicleToList( vehicle_id, conf.model )
		else
			local vehicle, error = CreateVehicle( vehicle_id, conf.model, conf.x, conf.y, conf.z, conf.rx, conf.ry, conf.rz, conf )
			if vehicle_id == last_vehicle_id and vehicle.dimension == 0 and player.interior == 0 and player.dimension == 0 then
				if isElement( vehicle ) then
					setTimer( WarpPedIntoVehicleDelayed, 200, 1, player, vehicle, data.last_vehicle_seat or 0 )
				else
					-- Машины не успевают удалиться в Async:foreach при реконнекте?
					Debug( "CreateVehicle failed, vehicle" .. tostring( vehicle ) .. ", error: " .. tostring( error ) )
				end
			end
		end
	end

	triggerEvent( "onPlayerVehiclesLoad", player )
end

function WarpPedIntoVehicleDelayed( player, vehicle, seat )
	if isElement( player ) and isElement( vehicle ) then
		warpPedIntoVehicle( player, vehicle, seat )
		setCameraTarget( player, player )
	end
end

function CreateSaveTimerForVehicle( vehicle )
	if isElement( vehicle ) and not isTimer( VEHICLES_SAVE_TIMERS[ vehicle ] ) then
		VEHICLES_SAVE_TIMERS[ vehicle ] = setTimer( SaveVehicle, 60000, 0, vehicle:GetID( ) )
	end
end

function DestroySaveTimerForVehicle( vehicle )
	local timer = VEHICLES_SAVE_TIMERS[ vehicle ]
	if isTimer( timer ) then 
		killTimer( timer )
		VEHICLES_SAVE_TIMERS[ vehicle ] = nil
	end
end

function HasSaveTimerForVehicle( vehicle )
	return isTimer( VEHICLES_SAVE_TIMERS[ vehicle ] )
end

function PlayerReadyToPlay( pPlayer )
	local pPlayer = pPlayer or source
	if isElement(pPlayer) then
		local iUserID = pPlayer:GetUserID()

		DB:queryAsync( PlayerReadyToPlay_Callback, { pPlayer }, "SELECT * FROM nrp_vehicles WHERE owner_pid=?", "p:" .. iUserID )
	end
end
addEvent("onPlayerReadyToPlay", true)
addEventHandler( "onPlayerReadyToPlay", root, PlayerReadyToPlay, true, "high+1000000" )

local function has_player_any_house_with_positive_paid_days( player )
    if not isElement( player ) then return end

    --[[local house_list = exports.nrp_house_sale:GetPlayerHouseList( player )

    for i, house in ipairs( house_list[ 1 ] or {} ) do
        if house.paid_days >= 0 then
            return true
        end
	end

    for i, house in ipairs( house_list[ 2 ] or {} ) do
        if house.paid_days >= 0 then
            return true
        end
	end]]

    return false
end

function PrepareParkedVehicleForPlayer( player, vehicles )
	if #vehicles == 0 then return end
	if not has_player_any_house_with_positive_paid_days( player ) then return end

	local vehicleToPark	

	for i = 1, #vehicles do
		local vehicle = vehicles[ i ]
		if isElement( vehicle ) then
			local is_moto = VEHICLE_CONFIG[ vehicle.model ].is_moto and vehicle.model ~= 468
			if not is_moto and not vehicle:GetBlocked() and not vehicle:IsConfiscated() then
				if not vehicle:GetParked() then
					vehicleToPark = vehicle
				else
					vehicleToPark = false
					break
				end
			end
		end
	end

	if vehicleToPark then		
		vehicleToPark:SetParked( true )
	end
end

function OnPlayerQuit()
	if isElement( source ) then
		local last_vehicle_id, last_vehicle_seat = 0, 0

		local veh = getPedOccupiedVehicle( source )
		if veh and veh:GetOwnerID( ) == source:GetUserID( ) then
			last_vehicle_id = math.max( 0, veh:GetID( ) )
			if last_vehicle_id > 0 then
				last_vehicle_seat = getPedOccupiedVehicleSeat( source )
			end
		end

		source:SetBatchPermanentData( { last_vehicle_id = last_vehicle_id, last_vehicle_seat = last_vehicle_seat } )

		local vehicles = source:GetVehicles( _, true )

		if source:GetPermanentData( "init_spawn_in_home" ) ~= false then
			PrepareParkedVehicleForPlayer( source, vehicles )
		end

		for i, vehicle in pairs(vehicles) do
			if isElement( vehicle ) then
				DestroyVehicle( vehicle:GetID( ) )
			end
		end 

		local special_vehicles = source:GetSpecialVehicles( )

		Async:foreach( special_vehicles, function( vehicle_data )
			local pVehicle = GetVehicle( vehicle_data[1] )
			if isElement( pVehicle ) then
				DestroyVehicle( vehicle_data[1] )
			end
		end )
	end
end
addEvent("onPlayerPreLogout", true)
addEventHandler("onPlayerPreLogout", root, OnPlayerQuit)

function ForceToggleVehicleEngine( pVehicle, state )
	if isElement(pVehicle) then
		pVehicle.engineState = state
	end
end
addEvent("ForceToggleVehicleEngine", true)
addEventHandler("ForceToggleVehicleEngine", root, ForceToggleVehicleEngine)

function ForceSyncVehicleStats( pVehicle, fFuel, fMileage )
	if not isElement( pVehicle ) then
		return
	end

	pVehicle:SetFuel( fFuel, nil, true )

	local old_mileage = pVehicle:GetMileage()
	if fMileage >= old_mileage and pVehicle.dimension == 0 then
		pVehicle:SetMileage( fMileage, nil, true )
		triggerEvent( "onVehicleMileageChanged", pVehicle, fMileage )
	end

	if not client then
		return
	end

	local data = client:GetPermanentData( "offer_short_rally" ) or { }
	if data.time_to or data.is_ready then
		return
	end

	if fMileage > old_mileage and client:GetID( ) == pVehicle:GetOwnerID( ) then
		local config = VEHICLE_CONFIG[ pVehicle.model ]
		if config.is_airplane or config.is_boat then return end

		local add_mileage = fMileage - old_mileage

		data.mileage = ( data.mileage or 0 ) + add_mileage
		if data.mileage >= 100 then
			data.is_ready = true
		end

		client:SetPermanentData( "offer_short_rally", data )
	end
end
addEvent( "ForceSyncVehicleStats", true )
addEventHandler( "ForceSyncVehicleStats", root, ForceSyncVehicleStats )

local function getTierByModel( model, variant )
	local tier = 1
	local tiers = {
		[ 1 ] = 0,
		[ 2 ] = 184,
		[ 3 ] = 219,
		[ 4 ] = 249,
		[ 5 ] = 279,
	}

	local max_speed = VEHICLE_CONFIG[model].variants[variant].max_speed
	while true do
		if tiers[ tier + 1 ] and tiers[ tier + 1 ] < max_speed then
			tier = tier + 1
		else
			break
		end
	end

	return tier
end

DAMAGE_MULTIPLIERS = {
	0.6,
	0.55,
	0.5,
	0.4,
	0.3,
	0.5,
}

addEventHandler( "onResourceStart", resourceRoot, function( )
	for model, info in pairs( VEHICLE_CONFIG ) do
		for variant, config in ipairs( info.variants ) do
			if config.handling.centerOfMassX then
				config.handling.centerOfMass = {
					config.handling.centerOfMassX,
					config.handling.centerOfMassY,
					config.handling.centerOfMassZ,
				}

				config.handling.centerOfMassX = nil
				config.handling.centerOfMassY = nil
				config.handling.centerOfMassZ = nil
			end

			for key, value in pairs( config.handling ) do
				setModelHandling( model, key, value )
			end

			if not config.use_collisions_dm then
				local class = getTierByModel( model, variant )
				local damageMultiplier = DAMAGE_MULTIPLIERS[ class ] or 1

				--setModelHandling( model, "collisionDamageMultiplier", damageMultiplier )
			end
		end
	end
end )






addEventHandler("onPlayerVehicleEnter", root, function( pVehicle, iSeat )
	if iSeat == 0 then
		local should_disable_engine = false

		-- Если это не владелец
		if pVehicle:GetOwnerID( ) then
			local owner_id = pVehicle:GetOwnerID( )
			local player_id = source:GetUserID( )
			local pOwners = pVehicle:GetTempOwnersPID( )
			pOwners[owner_id] = true

			if not pOwners[player_id] and not source:IsAdmin( ) then
				should_disable_engine = true
			end
		end

		local fuel = pVehicle:GetFuel( )

		-- Если пустой бак
		should_disable_engine = should_disable_engine or fuel <= 0

		if should_disable_engine then
			setVehicleEngineState( pVehicle, false )
		end

		triggerClientEvent(source, "ForceSyncVehicleStats", source, pVehicle, fuel, pVehicle:GetMileage( ) )
	end
end)

addEventHandler("onVehicleStartEnter", root, function( pPlayer, iSeat )
	if IGNORED_VEHICLES[source] then return end

	if iSeat == 0 then
		local sType = getVehicleType(source)
		local sSpecialType = source:GetSpecialType()

		if sType == "BMX" or sType == "Bike" or sType == "Quad" or sType == "Boat" or sSpecialType == "helicopter" or sSpecialType == "airplane" then
			if source:GetOwnerID() then
				local owner_id = source:GetOwnerID()
				local player_id = pPlayer:GetUserID()
				local pOwners = source:GetTempOwnersPID()
				pOwners[owner_id] = true
				if not pOwners[player_id] and not pPlayer:IsAdmin() then
					cancelEvent()
				end
			end
		end
	end
end)

function IsOwnerInVehicle( vehicle )
	if isElement( vehicle ) then
		for i, v in pairs( getVehicleOccupants( vehicle ) ) do
			if vehicle:IsOwnedBy( v, true ) then
				return true
			end
		end
	end
end

function onVehicleEnter_handler( player, seat )
	if seat == 0 then
		source:UpdateSpedometerMaxSpeed( )
	end

	if IGNORED_VEHICLES[source] then return end

	local owner_id = source:GetOwnerID()
	if owner_id and not HasSaveTimerForVehicle( source ) and IsOwnerInVehicle( source ) then
		CreateSaveTimerForVehicle( source )
	end

	if seat ~= 0 then return end
	if not owner_id then return end

	--if player:IsAdmin() then return end

	local user_id = player:GetUserID()
	if (not player:HasLicense( source:GetLicenseType() ) or owner_id ~= user_id) then
		source.engineState = false
	end
end
addEventHandler( "onVehicleEnter", root, onVehicleEnter_handler )

function onVehicleStartExit_handler( player )
	if VEHICLE_CONFIG[ source.model ].special_type == "boat" and (Vector3( getElementVelocity( source ) ) * 180).length > 5 then
		player:ShowError( "Снизьте скорость для того, чтобы покинуть транспорт" )
		cancelEvent()
	end
end

function onVehicleExit_handler( player, seat )
	if IGNORED_VEHICLES[source] then return end

	local owner_id = source:GetOwnerID()

	if HasSaveTimerForVehicle( source ) and not IsOwnerInVehicle( source ) then
		DestroySaveTimerForVehicle( source )
	end

	if seat ~= 0 then return end

	-- Открываем двери, если кто-то закрылся изнутри
	if isVehicleLocked( source ) then
		if owner_id ~= player:GetUserID() then
			setVehicleLocked(source, false)
		end
	end
end
addEventHandler( "onVehicleExit", root, onVehicleExit_handler )

addEvent("OnVehiclePropertiesChanged", true)
addEventHandler("OnVehiclePropertiesChanged", root, function( key, val )
	if key == "br_vehicle" then
		if val then
			IGNORED_VEHICLES[source] = true
		end
	end

	if not IRREGULAR_VEHICLES[source] then
		IRREGULAR_VEHICLES[source] = true

		local function ForceSyncProperties( pPlayer )
			triggerClientEvent( pPlayer, "ReceiveVehicleProperties", source, source:GetProperties() )
		end

		addEventHandler("onVehicleEnter", source, ForceSyncProperties)
	end
end)

addEvent("OnRequestVehicleProperties", true)
addEventHandler("OnRequestVehicleProperties", root, function( pVehicle )
	if isElement(pVehicle) and isElement(source) then
		triggerClientEvent( source, "ReceiveVehicleProperties", pVehicle, pVehicle:GetProperties() )
	end
end)