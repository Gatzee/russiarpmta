loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShVehicleConfig" )

LOTTERY_MARKERS = 
{
    {
        x = -90, y = -497.65, z = 913.97, 
        interior = 1, dimension = 1, 
    },
    {
        x = 2390.2409, y = -1309.5739, z = 2800.0783, 
        interior = 4, dimension = 1, 
    },
}

LOTTERIES_INFO = {
    classic = {
        name = "Классическая",
    },
    gold = {
        type = "donate",
        name = "Золотая",
        cost_is_hard = true,
    },
    theme_1 = {
        type = "theme",
        analytics_name = "superhero",
        name = "Супергеройский",
        start_ts  = getTimestampFromString( "19.11.2020" ),
        finish_ts = getTimestampFromString( "26.11.2020" ),
    },
    theme_2 = {
        type = "theme",
        analytics_name = "occult",
        name = "Оккультный",
        start_ts  = getTimestampFromString( "26.11.2020" ),
        finish_ts = getTimestampFromString( "03.12.2020" ),
    },
    theme_3 = {
        type = "theme",
        analytics_name = "mortal_combat",
        name = "Мортал комбат",
        start_ts  = getTimestampFromString( "03.12.2020" ),
        finish_ts = getTimestampFromString( "10.12.2020" ),
    },
    theme_4 = {
        type = "theme",
        analytics_name = "major",
        name = "Мажорный",
        start_ts  = getTimestampFromString( "10.12.2020" ),
        finish_ts = getTimestampFromString( "17.12.2020" ),
    },
    theme_5 = {
        type = "theme",
        analytics_name = "space",
        name = "Космический",
        start_ts  = getTimestampFromString( "17.12.2020" ),
        finish_ts = getTimestampFromString( "24.12.2020" ),
    },
    theme_6 = {
        type = "theme",
        analytics_name = "newyear",
        name = "Новогодняя",
        start_ts  = getTimestampFromString( "31.12.2020" ),
        finish_ts = getTimestampFromString( "07.01.2021" ),
        ignore_iterating = true,
    },
    theme_7 = {
        type = "theme",
        analytics_name = "valentine",
        name = "Валентинная",
        start_ts  = getTimestampFromString( "11.02.2021" ),
        finish_ts = getTimestampFromString( "18.02.2021" ),
    },
    theme_8 = {
        type = "theme",
        analytics_name = "frosty",
        name = "Морозная",
        start_ts  = getTimestampFromString( "25.02.2021" ),
        finish_ts = getTimestampFromString( "04.03.2021" ),
    },
    theme_9 = {
        type = "theme",
        analytics_name = "students",
        name = "Студенческая",
        start_ts  = getTimestampFromString( "02.09.2021" ),
        finish_ts = getTimestampFromString( "09.09.2021" ),
    },
    theme_10 = {
        type = "theme",
        analytics_name = "march",
        name = "Мартовская",
        start_ts  = getTimestampFromString( "04.03.2021" ),
        finish_ts = getTimestampFromString( "11.03.2021" ),
    },
    theme_11 = {
        type = "theme",
        analytics_name = "pancake_week",
        name = "Масленичная",
        start_ts  = getTimestampFromString( "11.03.2021" ),
        finish_ts = getTimestampFromString( "18.03.2021" ),
    },
    theme_12 = {
        type = "theme",
        analytics_name = "domestic",
        name = "Отечественная",
        start_ts  = getTimestampFromString( "18.02.2021" ),
        finish_ts = getTimestampFromString( "25.02.2021" ),
    },
    theme_13 = {
        type = "theme",
        analytics_name = "saint_patrick",
        name = "Святого Патрика",
        start_ts  = getTimestampFromString( "18.03.2021" ),
        finish_ts = getTimestampFromString( "25.03.2021" ),
    },
    theme_14 = {
        type = "theme",
        analytics_name = "spring",
        name = "Весенняя",
        start_ts  = getTimestampFromString( "25.03.2021" ),
        finish_ts = getTimestampFromString( "01.04.2021" ),
    },
    theme_15 = {
        type = "theme",
        analytics_name = "april_fools",
        name = "Первоапрельская",
        start_ts  = getTimestampFromString( "01.04.2021" ),
        finish_ts = getTimestampFromString( "08.04.2021" ),
    },
    theme_16 = {
        type = "theme",
        analytics_name = "cosmonautics",
        name = "Космонавтика",
        start_ts  = getTimestampFromString( "08.04.2021" ),
        finish_ts = getTimestampFromString( "15.04.2021" ),
        ignore_iterating = true,
    },
    theme_17 = {
        type = "theme",
        analytics_name = "vegas",
        name = "Вегас",
        start_ts  = getTimestampFromString( "15.04.2021" ),
        finish_ts = getTimestampFromString( "22.04.2021" ),
    },
    theme_18 = {
        type = "theme",
        analytics_name = "earth_day",
        name = "День земли",
        start_ts  = getTimestampFromString( "22.04.2021" ),
        finish_ts = getTimestampFromString( "29.04.2021" ),
    },
    theme_19 = {
        type = "theme",
        analytics_name = "budget",
        name = "Бюджетная",
        start_ts  = getTimestampFromString( "29.04.2021" ),
        finish_ts = getTimestampFromString( "06.05.2021" ),
    },
    theme_20 = {
        type = "theme",
        analytics_name = "california",
        name = "Калифорния",
        start_ts  = getTimestampFromString( "10.06.2021" ),
        finish_ts = getTimestampFromString( "17.06.2021" ),
    },
    theme_21 = {
        type = "theme",
        analytics_name = "victory",
        name = "Победная",
        start_ts  = getTimestampFromString( "13.05.2021" ),
        finish_ts = getTimestampFromString( "20.05.2021" ),
    },
    theme_22 = {
        type = "theme",
        analytics_name = "cascade",
        name = "Каскадная",
        start_ts  = getTimestampFromString( "20.05.2021" ),
        finish_ts = getTimestampFromString( "27.05.2021" ),
    },
    theme_23 = {
        type = "theme",
        analytics_name = "working",
        name = "Трудовая",
        start_ts  = getTimestampFromString( "17.06.2021" ),
        finish_ts = getTimestampFromString( "24.06.2021" ),
    },
    theme_24 = {
        type = "theme",
        analytics_name = "eastcoast",
        name = "East Coast",
        start_ts  = getTimestampFromString( "24.06.2021" ),
        finish_ts = getTimestampFromString( "01.07.2021" ),
    },
    theme_25 = {
        type = "theme",
        analytics_name = "newgentry",
        name = "Новодворянская",
        start_ts  = getTimestampFromString( "01.07.2021" ),
        finish_ts = getTimestampFromString( "08.07.2021" ),
    },
    theme_26 = {
        type = "theme",
        analytics_name = "golden_shoe",
        name = "\"Золотая подкова\"",
        start_ts  = getTimestampFromString( "08.07.2021" ),
        finish_ts = getTimestampFromString( "15.07.2021" ),
    },
    theme_27 = {
        type = "theme",
        analytics_name = "hype",
        name = "Хайповая",
        start_ts  = getTimestampFromString( "15.07.2021" ),
        finish_ts = getTimestampFromString( "22.07.2021" ),
    },
    theme_28 = {
        type = "theme",
        analytics_name = "academic",
        name = "Академическая",
        start_ts  = getTimestampFromString( "22.07.2021" ),
        finish_ts = getTimestampFromString( "29.07.2021" ),
    },
    -- ignore_iterating = true, чтобы лотерея была одноразовой
}

LOTTERY_QUEUE_DISCOUNT =
{
    default =
    {
        [ 1 ] = 0.05,
        [ 3 ] = 0.07,
    },
    gold =
    {
        [ 1 ] = 0.05,
        [ 3 ] = 0.1,
    }
}

function GetCurrentQueueDiscount( cur_num, lottery_variant )
    local queue = LOTTERY_QUEUE_DISCOUNT[ lottery_variant > 3 and "gold" or "default" ]
    local result = 0
    for k, v in pairs( queue ) do
        if cur_num >= k and v > result then
            result = v
        end
    end
    return result > 0 and result
end


CONST_PROGRESSION_POINTS = {
    600,
    2000,
    4500,
    8500,
    15000,
}

CONST_PROGRESSION_POINTS_REVERSE = {}
for k, v in ipairs( CONST_PROGRESSION_POINTS ) do
    CONST_PROGRESSION_POINTS_REVERSE[ v ] = k
end

CONST_PROGRESSION_POINTS_FOR_LOTTERY_VARIANT = {
    [ 1 ] = 5,
    [ 2 ] = 10,
    [ 3 ] = 15,
    [ 4 ] = 20,
    [ 5 ] = 25,
}

function GetLotteryRewardIdByPoints( count_progression_points )
    for k, v in ipairs( CONST_PROGRESSION_POINTS ) do
        if count_progression_points < v then
            return k - 1
        end
    end
    return #CONST_PROGRESSION_POINTS
end

function GetLotteryProgressionRewards( lottery_id, is_premium, reward_id )
    local result, current_season_num = {}, 1
    local ts = getRealTimestamp()

    local p_rewards = LOTTERIES_INFO[ lottery_id ].progression_prizes
    local current_season_num = #p_rewards == 1 and current_season_num or GetCurrentSeasonNumByTheme()

    result = p_rewards[ current_season_num ].items[ is_premium and "Premium" or "Common" ]
    result = reward_id and result[ reward_id ] or result
    

    return result, current_season_num
end

-- Текущий сезон получаем относительно текущей тематической лотереи, айдишники сезонов в ShLotteryItems генерируются
function GetCurrentSeasonNumByTheme()
    for i, lottery_type in pairs( { "theme" } ) do
        for lottery_id, lottery in pairs( LOTTERIES_INFO ) do
            if lottery.type == lottery_type and ( not lottery.IsActive or lottery:IsActive( ) ) then
                return lottery.season_num
            end
        end
    end
end

function IterateExpiredLotteries( )
    local current_ts = getRealTimestamp( )

    while true do
        -- находим самую просроченную
        local most_expired_lottery
        local lottery_by_start_ts = { }
        
        for i, lottery in pairs( LOTTERIES_INFO ) do
            if lottery.finish_ts then
                if not lottery.ignore_iterating and lottery.finish_ts < current_ts then
                    if not most_expired_lottery or most_expired_lottery.finish_ts > lottery.finish_ts then
                        most_expired_lottery = lottery
                    end
                end

                lottery_by_start_ts[ lottery.start_ts ] = lottery
            end
        end

        -- перемещаем её на следующую ближайшую свободную неделю
        if most_expired_lottery then
            local next_start_ts
            for i, lottery in pairs( LOTTERIES_INFO ) do
                if lottery.finish_ts and not lottery_by_start_ts[ lottery.finish_ts ] then
                    if not lottery.ignore_iterating or lottery.finish_ts > most_expired_lottery.finish_ts then
                        next_start_ts = math.min( next_start_ts or math.huge, lottery.finish_ts )
                    end
                end
            end
            local duration = most_expired_lottery.finish_ts - most_expired_lottery.start_ts
            most_expired_lottery.start_ts  = next_start_ts
            most_expired_lottery.finish_ts = next_start_ts + duration
            -- iprint( most_expired_lottery.name, os.date( "%c", most_expired_lottery.start_ts ), os.date( "%c", most_expired_lottery.finish_ts ) )
        else
        --повторяем пока есть хотя бы одна просроченная лотерея
            break
        end
    end
end
IterateExpiredLotteries( )
if localPlayer then
    local function onRecieveServerTimestamp_handler( )
        removeEventHandler( "onRecieveServerTimestamp", root, onRecieveServerTimestamp_handler )
        setTimer( IterateExpiredLotteries, 50, 1 )
    end
    addEvent( "onRecieveServerTimestamp", true )
    addEventHandler( "onRecieveServerTimestamp", root, onRecieveServerTimestamp_handler )
else
    -- На сервере срок не проверяется, так что не нужно
    -- Extend( "ShTimelib" )
    -- ExecAtWeekdays( "thursday", IterateExpiredLotteries )
end

for lottery_id, lottery in pairs( LOTTERIES_INFO ) do
    lottery.id = lottery_id
    if lottery.start_ts then
        lottery.IsActive = function( self )
            local current_ts = getRealTimestamp( )
            return self.start_ts < current_ts and current_ts < self.finish_ts
        end
    end
    if not lottery.type then
        lottery.type = lottery_id
    end
end

REGISTERED_ITEMS = { }

enum "LOTTERY_TOP_PLAYERS_LIST_FIELDS" {
    "LTP_PLAYER_ID",
    "LTP_PLAYER_NAME",
    "LTP_REWARD_TYPE",
    "LTP_REWARD_COST",
    "LTP_REWARD_PARAMS",
}