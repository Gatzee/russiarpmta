loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShVehicleConfig" )
Extend( "ShSkin" )
Extend( "ShAccessories" )
Extend( "ShVinyls" )
Extend( "ShRace" )
Extend( "ShHobby" )
Extend( "rewards/_ShItems" )

BP_CURRENT_SEASON_ID = 9

BP_STAGES = {
    { tasks_count = 10, start_ts = getTimestampFromString( "24.06.2021 00:00" ) },
    { tasks_count = 10, start_ts = getTimestampFromString( "01.07.2021 00:00" ) },
    { tasks_count = 10, start_ts = getTimestampFromString( "08.07.2021 00:00" ) },
    { tasks_count = 10, start_ts = getTimestampFromString( "15.07.2021 00:00" ) },
}

BP_BOOSTERS = {
    { days = 1, cost = 199 },
    { days = 3, cost = 299 },
    { days = 5, cost = 399 },
    { days = 7, cost = 499 },
}

BP_BOOSTER_EXP_MULTIPLIER = 0.5
BP_PREMIUM_EXP_MULTIPLIER = 0.25
BP_PREMIUM_COST = 490

BP_TASK_SKIP_COSTS = {
    25,
    50,
    150,
    300,
    500,
    750,
    1050,
    1400,
    1800,
    2250,
    2750,
    3300,
    3900,
    4550,
    5250,
    6000,
    6800,
    7650,
    8550,
    9500,
    10500,
    11550,
    12650,
    13800,
    15000,
    16250,
    17550,
    18900,
    20300,
    21750,
    23250,
    24800,
    26400,
    28050,
    29750,
    31500,
    33300,
    35150,
    37050,
    39000,
    41000,
    43050,
    45150,
    47300,
    49500,
    51750,
    54050,
    56400,
    58800,
    61250,
    63750,
    66300,
    68900,
    71550,
    74250,
    77000,
    79800,
    82650,
    85550,
    88500,
    91500,
}

BP_MAX_LEVEL = 24

BP_LEVELS_NEED_EXP = {
    [ 1 ] = 1000,
    [ 2 ] = 2100,
    [ 3 ] = 3300,
    [ 4 ] = 4600,
    [ 5 ] = 6000,
    [ 6 ] = 7500,
    [ 7 ] = 9100,
    [ 8 ] = 10800,
    [ 9 ] = 14500,
    [ 10 ] = 18800,
    [ 11 ] = 23500,
    [ 12 ] = 28600,
    [ 13 ] = 34100,
    [ 14 ] = 40000,
    [ 15 ] = 46500,
    [ 16 ] = 53400,
    [ 17 ] = 60700,
    [ 18 ] = 68400,
    [ 19 ] = 76500,
    [ 20 ] = 85200,
    [ 21 ] = 94300,
    [ 22 ] = 103800,
    [ 23 ] = 113700,
    [ 24 ] = 124000,
    -- [ 25 ] = 150000,
    -- [ 26 ] = 160100,
    -- [ 27 ] = 174900,
    -- [ 28 ] = 189800,
    -- [ 29 ] = 204700,
    -- [ 30 ] = 250000,
    -- [ 31 ] = 289900,
    -- [ 32 ] = 333400,
    -- [ 33 ] = 376000,
    -- [ 34 ] = 418600,
    -- [ 35 ] = 461200,
    -- [ 36 ] = 503800,
}

BP_THRESHOLD_LEVELS = {
    6,
    12,
    18,
    24,
    -- 30,
    -- 36,
}

BP_THRESHOLD_LEVEL_TO_NEXT = { }
for i, level in ipairs( BP_THRESHOLD_LEVELS ) do
    BP_THRESHOLD_LEVEL_TO_NEXT[ level ] = BP_THRESHOLD_LEVELS[ i + 1 ]
end

BP_CURRENT_SEASON_START_TS = BP_STAGES[ 1 ].start_ts
BP_CURRENT_SEASON_END_TS = BP_STAGES[ #BP_STAGES ].start_ts + 7 * 24 * 60 * 60

function GetCurrentSeasonEndDate( )
    return BP_CURRENT_SEASON_END_TS
end

function GetBattlePassPremuimCost( )
	local offer_data = PREMIUM_OFFER_DATA or localPlayer:getData( "bp_premium_offer" )
	local current_ts = getRealTimestamp( )
	if offer_data and offer_data.start_ts and offer_data.start_ts < current_ts and current_ts < offer_data.finish_ts then
		return offer_data.cost, offer_data and offer_data.discount
	end
	return BP_PREMIUM_COST
end

function GetBattlePassBoosterCost( booster_id, player )
	local current_ts = getRealTimestamp( )
    player = player or localPlayer

	local offer_data = BOOSTER_OFFER_DATA or player:getData( "bp_booster_offer" )
	if offer_data and offer_data.start_ts and offer_data.booster_id == booster_id and offer_data.start_ts < current_ts and current_ts < offer_data.finish_ts then
		return offer_data.cost, offer_data.discount
	end

    local offer_data = player:getData( "bp_boosters_discount" )
    if offer_data and offer_data.boosters[ booster_id ] and current_ts < ( offer_data.start_ts + offer_data.duration ) then
        return offer_data.boosters[ booster_id ].cost, offer_data.boosters[ booster_id ].discount
    end

	return BP_BOOSTERS[ booster_id ].cost
end

function GetBattlePassLevelCost( level, current_level )
    local sum_cost = 0
    for i = current_level + 1, level do
        sum_cost = sum_cost + BP_LEVELS_NEED_EXP[ i ] / 25
    end
    return math.ceil( sum_cost )
end