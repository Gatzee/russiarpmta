loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShVehicleConfig" )

enum "eAssemblyVehicle" {
    "DETAIL_BODY",
    "DETAIL_ENGINE",
    "DETAIL_ELECTRICIAN",
    "DETAIL_WHEELS",
    "DETAIL_TRANSMISSION",
    "DETAIL_FUEL_SYSTEM",
}

OFFER_CONFIG = {
	start_date  = getTimestampFromString( "31 декабря 2020 00:00" ),
    finish_date = getTimestampFromString( "6 января 2021 23:59" ),
    after_start_date  = getTimestampFromString( "7 января 2021 00:00" ),
	after_finish_date = getTimestampFromString( "13 января 2021 23:59" ),
	cost_soft = 390000,
	cost_hard = 483,
	vehicle = {
		cost = 2900000,
		name = "Победа Т-34",
		params = {
			model = 6584
		},
		type = "vehicle"

	},
	point = {
		x = -1003.05,
		y = 2399.77,
		z = 16.96,
		radius = 3,
		marker_type = "checkpoint",
		color = { 250, 100, 100, 150 },
		gps = true,
		blip = true,
		keypress = false,
    },
    camera = {
        start = {
            x = -1047.3251953125,
            y = 2419.1577148438,
            z = 25.747175216675,
         },
        finish = {
            x = -1024.1141357422,
            y = 2408.9035644531,
            z = 18.254957199097 + 0.3,
            lx = -936.41027832031,
            ly = 2371.375,
            lz = -11.739190101624,
        },
    },    
    path = { x = -1019.850, y = 2407.105, z = 17.588, speed_limit = 35 },
    vehicle_position = Vector3( -1003.735, 2400.049, 17.587 ), 
    vehicle_rotation = Vector3( 0, 0, 67 ),
    vehicle_points = {
        { x = -1019.674, y = 2407.027, z = 17.585 },
        { x = -1018.387, y = 2409.802, z = 17.587 },
        { x = -1020.819, y = 2404.030, z = 17.587 },
        { x = -1017.146, y = 2412.803, z = 17.587 },
        { x = -1022.036, y = 2400.320, z = 17.587 },
    },
    vehicle_reserve_point = { x = -1004.988, y = 2412.729, z = 17.587 },
}

DETAILS_PLACE = {
    [ "wheel_of_fortune" ] = DETAIL_ENGINE,
    [ "task" ] = DETAIL_FUEL_SYSTEM,
    [ "battle_pass" ] = DETAIL_ELECTRICIAN,
    [ "battle_pass_prem" ] = DETAIL_BODY,
    [ "case" ] = DETAIL_WHEELS,
    [ "lottery" ] = DETAIL_TRANSMISSION,
}

DETAILS_INFO = {
    [ DETAIL_ENGINE ] = {
		name = "Двигатель",
		show_source = function( )
			triggerServerEvent( "InitRouletteWindow", resourceRoot, "default" )
		end,
        type = "engine",
        x = 160,
        y = 132,
    },
    [ DETAIL_FUEL_SYSTEM ] = {
        name = "Топливная система",
        show_source = function( )
            localPlayer:InfoWindow( "Деталь можно получить выполнив задачу\n Местный поиск" )
			triggerServerEvent( "ShowRetentionInterfaceRequest", localPlayer, "localsearch5" )
		end,
        type = "fuel_system",
        x = 30,
        y = 286,
        sy = 13,
    },
    [ DETAIL_ELECTRICIAN ] = {
        name = "Электрика",
        show_source = function( )
			triggerServerEvent( "BP:onPlayerWantShowUI", localPlayer )
		end,
        type = "electrician",
        x = 160,
        y = 446,
    },
    [ DETAIL_BODY ] = {
        name = "Каркас",
        show_source = function( )
			triggerServerEvent( "BP:onPlayerWantShowUI", localPlayer )
		end,
        type = "body",
        x = 764,
        y = 132,
    },
    [ DETAIL_WHEELS ] = {
        name = "Колеса",
        show_source = function( )
            localPlayer:InfoWindow( "Деталь можно получить в Зимнем кейсе" )
			triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "cases" )
		end,
        type = "wheels",
        x = 894,
        y = 299,
    },
    [ DETAIL_TRANSMISSION ] = {
        name = "АКПП",
        show_source = function( )
            localPlayer:InfoWindow( "Деталь можно получить в Новогодней лотерее" )
            triggerEvent( "ToggleGPS", localPlayer, { { x = 706.599, y = -208.847, z = 21.036 } } )
		end,
        type = "transmission",
        x = 764,
        y = 446,
    },
}

function GetAssemblyVehicleDetailById( detail_id )
    if not detail_id then return end
    return DETAILS_INFO[ detail_id ]
end

function CheckActiveAssemblyVehicle( after_finish )
    local timestamp = getRealTimestamp( )
    local start_date = after_finish and OFFER_CONFIG.after_start_date or OFFER_CONFIG.start_date
    local finish_date = after_finish and OFFER_CONFIG.after_finish_date or OFFER_CONFIG.finish_date

    if timestamp >= start_date and timestamp <= finish_date then return true end
    return false
end