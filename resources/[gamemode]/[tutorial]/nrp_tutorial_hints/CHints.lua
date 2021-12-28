local INFO
local TEMP_INFO

local CONST_TIMER_FREQ = 60
local CONST_MAX_HINT_TIME = 60 * 60

local POSITIONS_CACHE = { }

function GetHintsPositions( id_list )
    POSITIONS = POSITIONS or exports.nrp_help:GetNavigationList( )

    table.sort( id_list )
    local cache_id = table.concat( id_list, " " )
    if POSITIONS_CACHE[ cache_id ] then
        return POSITIONS_CACHE[ cache_id ]

    else

        local positions = { }

        local function is_in_list( value )
            if value then
                for i, v in pairs( id_list ) do
                    if v == value or string.find( value, v ) then
                        return true
                    end
                end
            end
        end

        for i, page in pairs( POSITIONS ) do
            if page.menu then
                for n, menu_conf in ipairs( page.menu ) do
                    if menu_conf.gps and type( menu_conf.gps ) == "table" then
                        local in_list
                        if menu_conf.id then
                            in_list = menu_conf.id and is_in_list( menu_conf.id )
                        else
                            in_list = is_in_list( menu_conf.category )
                        end

                        if in_list then
                            if #menu_conf.gps > 0 then
                                for k, gps_value in pairs( menu_conf.gps ) do
                                    table.insert( positions, gps_value )
                                end
                            else
                                table.insert( positions, menu_conf.gps )
                            end
                        end
                    end
                end
            end
        end

        POSITIONS_CACHE[ cache_id ] = positions
        
        return positions
    end
end

function IsNearPositions( id_list, distance )
    local distance = distance or 5

    local px, py, pz = getElementPosition( localPlayer.vehicle or localPlayer )

    local positions = GetHintsPositions( id_list )

    for i, v in pairs( positions ) do
        if v and v.x and getDistanceBetweenPoints3D( px, py, pz, v.x, v.y, v.z ) <= distance then
            return true
        end
    end
end

local CONST_HINTS = {
    {
        id = "carsell",
        text = "Справка об автосалоне",
        near_positions = { "carsell_.*" },
        distance = 40,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Автосалоны", 1 },
    },
    {
        id = "repairstore",
        text = "Справка об автосервисе",
        near_positions = { "repairstore" },
        distance = 10,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Автосервис", 1 },
    },
    {
        id = "gasstation",
        text = "Справка о заправках",
        near_positions = { "gasstation" },
        distance = 25,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance ) or localPlayer.vehicle and ( localPlayer.vehicle:GetFuel( ) / localPlayer.vehicle:GetMaxFuel( ) ) <= 0.3
        end,
        tab = { 2, "Заправки", 1 },
    },
    {
        id = "drivingschool",
        text = "Справка об автошколе",
        near_positions = { "driving_school" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Автошкола", 1 },
    },
    {
        id = "flyingschool",
        text = "Справка об авиашколе",
        near_positions = { "flying_school" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Автошкола", 1 },
    },
    {
        id = "drugstore",
        text = "Справка об аптеке",
        near_positions = { "drugstore.*" },
        distance = 10,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Аптека", 1 },
    },
    {
        id = "business_trade",
        text = "Справка о бирже",
        near_positions = { "businesses_sell" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Бизнесы", 1 },
    },
    {
        id = "races",
        text = "Справка о гонках",
        near_positions = { "race_.*" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Гонки", 1 },
    },
    {
        id = "clothes",
        text = "Справка о магазине одежды",
        near_positions = { "boutique" },
        distance = 10,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Магазин Одежды", 1 },
    },
    {
        id = "houses",
        text = "Справка о недвижимости",
        main_dimension = true,
        distance = 15,
        check = function( self )
            -- Квартиры
            local position = localPlayer.position
            for i, v in pairs( APARTMENTS_LIST ) do
                if v.enter_position and ( v.enter_position - position ).length <= self.distance then
                    return true
                end
            end

            -- Вип дома и коттеджи
            local x, y, z = getElementPosition( localPlayer )
            for i, v in pairs( APARTMENTS_LIST ) do
                if v.sell_marker_position and getDistanceBetweenPoints3D( x, y, z, v.sell_marker_position.x, v.sell_marker_position.y, v.sell_marker_position.z ) <= self.distance then
                    return true
                end
            end
        end,
        tab = { 2, "Недвижимость", 1 },
    },
    {
        id = "cartrade",
        text = "Справка о Б/У Рынке",
        near_positions = { "cartrade" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Продажа авто", "Рынок Б/У" },
    },
    {
        id = "govsell",
        text = "Справка о продаже авто",
        near_positions = { "govsell" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Продажа авто", "Продажа государству" },
    },
    {
        id = "courier",
        text = "Справка о курьере",
        near_positions = { "job_courier.*" },
        distance = 30,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Работы", "Курьер" },
    },
    {
        id = "trucker",
        text = "Справка о дальнобойщике",
        near_positions = { "job_trucker.*" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Работы", "Дальнобойщик" },
    },
    {
        id = "loader",
        text = "Справка о грузчике",
        near_positions = { "job_loader.*" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Работы", "Грузчик" },
    },
    {
        id = "taxi",
        text = "Справка о таксисте",
        near_positions = { "job_taxi.*" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Работы", "Таксист" },
    },
    {
        id = "pilot",
        text = "Справка о лётчике",
        near_positions = { "job_pilot.*" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Работы", "Лётчик" },
    },
    {
        id = "mechanic",
        text = "Справка об автомеханике",
        near_positions = { "job_mechanic.*" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Работы", "Автомеханик" },
    },
    {
        id = "parkemployee",
        text = "Справка о сотруднике парка",
        near_positions = { "job_parkemp.*" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Работы", "Сотрудник парка" },
    },
    {
        id = "farmer",
        text = "Справка о фермере",
        near_positions = { "job_farmer.*" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Работы", "Фермер" },
    },
    {
        id = "driver",
        text = "Справка о водителе автобуса",
        near_positions = { "job_driver.*" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Работы", "Водитель" },
    },
    {
        id = "hcs",
        text = "Справка о сотруднике ЖКХ",
        near_positions = { "job_hcs.*" },
        distance = 30,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Работы", "Сотрудник ЖКХ" },
    },
    {
        id = "industrial_fish",
        text = "Справка о промышленной рыбалке",
        near_positions = { "industrial_fish" },
        distance = 30,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Работы", "Промышленная рыбалка" },
    },
    {
        id = "cinema",
        text = "Справка о кинотеатре",
        near_positions = { "cinema" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Развлечения", "Кинотеатр" },
    },
    {
        id = "casino",
        text = "Справка о казино",
        near_positions = { "casino" },
        distance = 10,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Развлечения", "Казино" },
    },
    {
        id = "fc",
        text = "Справка о единоборствах",
        near_positions = { "fc" },
        distance = 20,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Развлечения", "Бойцовский клуб" },
    },
    {
        id = "dancingschool",
        text = "Справка о школе танцев",
        near_positions = { "dancing_school" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Развлечения", "Школа Танцев" },
    },
    {
        id = "tuning",
        text = "Справка о тюнинге",
        near_positions = { "tuning" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Тюнинг", 1 },
    },
    {
        id = "simshop",
        text = "Справка о сим-картах",
        near_positions = { "simshops" },
        distance = 7,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Сим-карты", 1 },
    },
    {
        id = "food",
        text = "Справка о фастфуде",
        near_positions = { "food" },
        distance = 15,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Фастфуд", 1 },
    },
    {
        id = "urgentmilitary",
        text = "Справка о срочной службе",
        near_positions = { "urgent_military" },
        distance = 20,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Фракции", "Срочная служба" },
    },
    {
        id = "medics",
        text = "Справка о медиках",
        near_positions = { "faction_medics" },
        distance = 30,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Фракции", "Медики" },
    },
    {
        id = "dps",
        text = "Справка о ДПС",
        near_positions = { "faction_dps" },
        distance = 20,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Фракции", "ДПС" },
    },
    {
        id = "pps",
        text = "Справка о ППС",
        near_positions = { "faction_pps" },
        distance = 20,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Фракции", "ППС" },
    },
    {
        id = "army",
        text = "Справка об армии",
        near_positions = { "faction_army" },
        distance = 50,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Фракции", "Армия" },
    },
    {
        id = "mayoralty",
        text = "Справка о мэрии",
        near_positions = { "faction_mayor" },
        distance = 20,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Фракции", "Мэрия" },
    },
    {
        id = "fsin",
        text = "Справка о ФСИН",
        near_positions = { "faction_fsin" },
        distance = 50,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Фракции", "ФСИН" },
    },
    {
        id = "business",
        text = "Справка о бизнесах",
        main_dimension = true,
        check = function( self )
            return localPlayer:getData( "business_near" )
        end,
        tab = { 2, "Бизнесы", 1 },
    },
    {
        id = "fishing",
        text = "Справка о рыбалке",
        near_positions = { "fishing" },
        distance = 20,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Хобби", "Рыбалка" },
    },
    {
        id = "hunting",
        text = "Справка об охоте",
        near_positions = { "hunting" },
        distance = 20,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Хобби", "Охота" },
    },
    {
        id = "treasure",
        text = "Справка о поиске сокровищ",
        near_positions = { "digging" },
        distance = 10,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Хобби", "Поиск сокровищ" },
    },
    {
        id = "purple",
        text = "Справка о Восточном Картеле",
        near_positions = { "cartel_2" },
        distance = 30,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Кланы", "Восточный Картель" },
    },
    {
        id = "green",
        text = "Справка о Западном Картеле",
        near_positions = { "cartel_1" },
        distance = 30,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Кланы", "Западный Картель" },
    },
    {
        id = "clans",
        text = "Справка о Кланах",
        near_positions = { "clan_base" },
        distance = 20,
        main_dimension = true,
        check = function( self )
            return IsNearPositions( self.near_positions, self.distance )
        end,
        tab = { 2, "Кланы", 1 },
    },
    {
        id = "keyboard",
        text = "Чтобы открыть горячие клавиши",
        check = function( ) return TEMP_INFO and TEMP_INFO.state == "keyboard" end,
    },
}

function onClientPlayerHintsRefresh_handler( state )
    if not _MODULES_LOADED then
        loadstring( exports.interfacer:extend( "Interfacer" ) )( )
        Extend( "ib" )
        Extend( "Globals" )
        Extend( "ShUtils" )
        Extend( "ShApartments" )
        Extend( "ShVipHouses" )
        Extend( "CVehicle" )
        Extend( "ShVehicleConfig" )
        _MODULES_LOADED = true
    end

    if state then
        onClientPlayerHintsRefresh_handler( false )

        LoadInfo( )

        TEMP_INFO = { }
        TEMP_INFO.state = state
        
        INFO.total_duration = INFO.total_duration or 0

        if TEMP_INFO.state == "keyboard" then
            TEMP_INFO.timer = setTimer( function( )
                INFO.total_duration = INFO.total_duration + CONST_TIMER_FREQ

                if INFO.total_duration >= CONST_MAX_HINT_TIME then
                    triggerServerEvent( "onPlayerHintExpired", resourceRoot )
                end
            end, CONST_TIMER_FREQ * 1000, 0 )
        end
        
        TEMP_INFO.location_timer = setTimer( LookForActiveHint, 500, 0 )
        LookForActiveHint( )
    else
        SaveInfo( )
        INFO = nil

        DestroyTableElements( TEMP_INFO )
        TEMP_INFO = nil

        triggerEvent( "onHUDDisplayHint", localPlayer )
    end
end
addEvent( "onClientPlayerHintsRefresh", true )
addEventHandler( "onClientPlayerHintsRefresh", root, onClientPlayerHintsRefresh_handler )

function LookForActiveHint( )
    local is_active_hint = false
    local dimension = localPlayer.dimension
    local interior = localPlayer.interior

    local is_in_quest = false
    local current_quest = localPlayer:getData( "current_quest" )
    if current_quest then
        local quest_id = current_quest.id
        for i, v in pairs( REGISTERED_QUESTS ) do
            if v == quest_id then
                is_in_quest = true
                break
            end
        end
    end

    if not is_in_quest then
        for i, v in pairs( CONST_HINTS ) do
            if not IsHintSeen( v.id ) and CheckHintCondition( i, v ) and ( not v.main_dimension or v.main_dimension and dimension == 0 and interior == 0 ) then
                if TEMP_INFO.current and TEMP_INFO.current.id == v.id then
                    return
                end

                triggerEvent( "onHUDDisplayHint", localPlayer, v.id, v )
                TEMP_INFO.current = v

                return
            end
        end
    end

    if not is_active_hint and TEMP_INFO.current then
        triggerEvent( "onHUDDisplayHint", localPlayer )
        TEMP_INFO.current = nil
    end
end

function CheckHintCondition( i )
    if CONST_HINTS[ i ].check and not localPlayer:getData( "photo_mode" ) then
        return CONST_HINTS[ i ].check( CONST_HINTS[ i ] )
    end
end

function IsHintSeen( id, state )
    return INFO and INFO.states and INFO.states[ id ]
end

function onHelpOpenAutomated_handler( kv )
    local id, v = unpack( kv )
    SetHintSeen( id, true )
    LookForActiveHint( )
    SaveInfo( )
end
addEvent( "onHelpOpenAutomated" )
addEventHandler( "onHelpOpenAutomated", root, onHelpOpenAutomated_handler )

function SetHintSeen( id, state )
    if not INFO.states then INFO.states = { } end
    INFO.states[ id ] = state or nil
end

do

    local file_name = "info.json"

    function SaveInfo( )
        if INFO then
            
            local file = fileExists( file_name ) and fileOpen( file_name ) or fileCreate( file_name )
            if file then
                fileWrite( file, toJSON( INFO ) )
                fileClose( file )
            end
        end
    end

    function LoadInfo( )
        local file = fileExists( file_name ) and fileOpen( file_name )
        if file then
            local contents = fileRead( file, fileGetSize( file ) )
            INFO = fromJSON( contents ) or { }
            fileClose( file )
        else
            INFO = { }
        end
    end

end