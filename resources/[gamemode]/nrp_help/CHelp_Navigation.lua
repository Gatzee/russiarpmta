
-- Названия вкладок
CATEGORIES_NAMES = {
    all = "Все",

    -- Автосалоны
    carsell_economy = "Эконом",
    carsell_normal  = "Средний класс",
    carsell_luxe    = "Люкс",
    carsell_premium = "Премиум",
    carsell_air     = "Авиа",
    carsell_boat    = "Верфь",
    carsell_moto	= "Мотосалон",
    
    -- Фракции
    urgent_military = "Срочная служба",
    faction_dps     = "ДПС",
    faction_pps     = "ППС",
    faction_medics  = "Медики",
    faction_army    = "Армия",
    faction_mayor   = "Мэрия",
    faction_fsin    = "ФСИН",

    -- Работы
    job_taxi       = "Таксист",
    job_farmer     = "Фермер",
    job_courier    = "Курьер",
    job_loader     = "Грузчик",
    job_trucker    = "Дальнобойщик",
    job_driver     = "Водитель",
    job_pilot      = "Лётчик",
    job_mechanic   = "Автомеханик",
    job_parkemp    = "Сотрудник парка",
    job_woodcut    = "Дровосек",
    job_hcs        = "Сотрудник ЖКХ",
    job_towtrucker = "Эвакуаторщик",
    job_inkas      = "Инкассатор",
    job_trashman   = "Мусорщик",
    job_delivery_cars = "Доставка транспорта",
    job_industrial_fish = "Промышленная рыбалка",
    job_hajack_cars = "Угон авто",

    -- Бизнесы
    businesses_general          = "Бизнесы",
    businesses_sell             = "Биржа",
    businesses_center           = "Бизнес - Центр",
    business_flowers            = "Магазины цветов",
    business_hotel              = "Отели",
    business_hypermarket        = "Гипермаркеты",
    business_ipshop             = "Магазины ИП",
    business_smallshop          = "Ларьки",
    business_shop               = "Магазины продуктов",
    business_repairstore        = "СТО",
    business_drugstore          = "Аптеки",
    business_gasstation         = "Заправки",
    business_carsell            = "Автосалоны",
    business_tradecentre        = "Торговые центры",
    business_circus             = "Цирки",
    business_school             = "Обучение",
    business_catering           = "Общественное питание",
    business_tuning             = "Тюнинг",
    business_cinema             = "Кинотеатр",
    business_bank               = "Банк",

    -- Новые (25.03)
    business_apart_hotel_gorki  = "Апарт Отель Горки",
    business_apart_hotel_msk    = "Апарт Отель МСК",
    business_apart_hotel_nsk    = "Апарт Отель НСК",
    business_bus_depot          = "Автобусный парк",
    business_construction       = "Стройка",
    business_grk_airport        = "Аэропорт ГРК",
    business_hotel_gorki        = "Отель Горки",
    business_hotel_ukraine      = "Гостиница Украина",
    business_moskovsky_port     = "Московский Порт",
    business_nsk_airport        = "Аэропорт НСК",
    business_oter_marriott      = "Отель Марриотт",
    business_plant              = "Завод",
    business_private_dump       = "Частная свалка",
    business_private_parking    = "Частная парковка",
    business_private_warehouse  = "Частный склад",
    business_strip_club         = "Стрип клуб",
    business_transport_service  = "Транспортный сервис",
    business_tuning_common      = "Тюнинг стандартный",

    -- Новые 29.04.21
    business_railway_station     = "Вокзал",
    business_shipyard            = "Верфь",
    business_workshop            = "Мастерская",
    business_clothing_store      = "Магазин одежды",
    business_moscow_central_bank = "Московский центробанк",
    business_gun_shop            = "Оружейный магазин",
    business_tretyakov_gallery   = "Третьяковская галерея",
    business_sawmill             = "Лесопилка",

    -- Кланы
    clan_base = "Кланы" ,
    hash_laboratory = "Лаборатория" ,
    cartel_1  = "Западный Картель" ,
    cartel_2  = "Восточный Картель",

    -- Школы
    school_land = "Автошкола",

    -- Бутик
    boutique = "Магазин Одежды",

    -- Заправки
    gasstation = "Заправки",

    -- Ремонтки
    repairstore = "СТО",
    ground_vehicles = "Автомобили",
    air_vehicles = "Воздушный транспорт",
    boat_vehicles = "Водный транспорт",

    -- Еда
    food = "Фастфуд",

    -- Недвижимость
    apartments = "Недвижимость",
    house_sale = "Продажа недвижимости",

    -- Продажа машин
    cartrade_econom = "Рынок Б/У эконом",
    cartrade_lux    = "Рынок Б/У люкс",
    govsell  = "Продажа государству",

    -- Тюнинг
    tuning = "Тюнинг",

    -- Аптеки
    drugstore = "Аптеки",

    -- Развлечения
    casino         = "Казино",
    fight_club     = "Бойцовский клуб",
    dancing_school = "Школа Танцев",
    strip_club     = "Стрип клуб",

    -- Гонки
    race_time   = "Круг на время",
    race_drift  = "Дрифт",
    race_drag   = "Драг-рейсинг",

    -- Хобби
    fishing = "Рыбалка",
    hunting = "Охота",
    digging = "Поиск сокровищ",

    -- Кино
    cinema = "Кинотеатр",

    -- Штрафы
    fines = "Штрафы",

    --Свадьба
    wedding = "Свадьба",

    -- Кооп квесты
    coop_quests = "Опасные задания",
}

-- Поиск бизнесов
function GetBusinessesByClass( business_class, business_class_additional, ignore_underline )
	local businesses = exports.nrp_businesses:GetBusinessesList( )

	local positions = { }

    if ignore_underline then
        for i, v in pairs( businesses ) do
            local r_id = string.gsub( v.id, "_%d+", '' )
            if r_id == business_class then
                table.insert( positions, { x = v.x, y = v.y, z = v.z } )
            end
        end
    else
        for i, v in pairs( businesses ) do
    		if split( v.id, "_" )[ 1 ] == business_class or split( v.id, "_" )[ 1 ] == business_class_additional or v.id == business_class then
    			table.insert( positions, { x = v.x, y = v.y, z = v.z } )
    		end
    	end
    end

	return positions
end

function IsGPSEnabled( )
    return not not gps_marker
end

function DisableGPS( )
    if IsGPSEnabled( ) then
        DestroyMarkerAndBlip( )
	end
end
addEvent( "DisableGPS", true )
addEventHandler( "DisableGPS", root, DisableGPS )

function ToggleGPS( data, near, area, max_distance, auto_height )
	DisableGPS( )
	if not data then return end

    if UI_elements and isElement( UI_elements.btn_hide_gps ) then
        UI_elements.btn_hide_gps:ibData( "visible", true )
    end
    
    local function CreateUpdateTimer( element )
        local function UpdateElementHeight( )
            if element then
                local position = element:GetPosition( )
                local hit, ground_x, ground_y, ground_z = processLineOfSight(
                    position.x, position.y, position.z + 500, position.x, position.y, position.z - 500,
                    true, false, false, true, false, false, false, false, nil, false, false
                )
                local px, py, pz = ground_x or position.x, ground_y or position.y, ground_z or position.z

                element:SetPosition( Vector3( px, py, pz ) )
            end
        end
        local timer = setTimer( UpdateElementHeight, 1000, 0 )
        local fns = { }
        fns.RemoveTimer = function( )
            if isTimer( timer ) then killTimer( timer ) end
            removeEventHandler( "onClientElementDestroy", element.element, fns.RemoveTimer )
        end
        addEventHandler( "onClientElementDestroy", element.element, fns.RemoveTimer, false )
    end
    if type( data ) == "table" and #data > 0 then
        if near then
			local min_index = 1
			local min_len = getDistanceBetweenPoints3D( data[1].x, data[1].y, data[1].z, localPlayer.position )

			for i, pos in ipairs( data ) do
				local len = getDistanceBetweenPoints3D( pos.x, pos.y, pos.z, localPlayer.position )
				if len < min_len then
					min_index = i
					min_len = len
				end
			end

			gps_marker = TeleportPoint( { x = data[min_index].x, y = data[min_index].y, z = data[min_index].z, radius = 4, gps = true, ignore_gps_route = true, keypress = false } )
			gps_marker.accepted_elements = { player = true, vehicle = true }
			gps_marker.marker.markerType = "checkpoint"
			gps_marker.marker:setColor( 250, 100, 100, 150 )
			gps_marker.elements = { }
            gps_marker.elements.blip = createBlipAttachedTo( gps_marker.marker, 41, 5, 250, 100, 100 )
            gps_marker.elements.blip.position = gps_marker.marker.position
            gps_marker.PostJoin = DestroyMarkerAndBlip

            if auto_height then CreateUpdateTimer( gps_marker ) end
        else
			gps_marker = { }

			local function anything_in_area( x, y, z, area )
				for i, v in pairs( gps_marker ) do
					if getDistanceBetweenPoints3D( v.x, v.y, v.z, x, y, z ) <= area then
						return true
					end
				end
			end

            for i, pos in ipairs( data ) do
				if not area or area and not anything_in_area( pos.x, pos.y, pos.z, area ) then
                    local marker = TeleportPoint( { x = pos.x, y = pos.y, z = pos.z, radius = 4, gps = max_distance or true, ignore_gps_route = true, keypress = false } )
					marker.accepted_elements = { player = true, vehicle = true }
					marker.marker.markerType = "checkpoint"
					marker.marker:setColor( 250, 100, 100, 150 )
					marker.elements = { }
                    marker.elements.blip = createBlipAttachedTo( marker.marker, 41, 5, 250, 100, 100 )
                    marker.elements.blip.position = marker.marker.position
					marker.PostJoin = DestroyMarkerAndBlip
					
                    table.insert( gps_marker, marker )
                    
                    if auto_height then CreateUpdateTimer( marker ) end
				end
			end
		end
	else
		gps_marker = TeleportPoint( { x = data.x, y = data.y, z = data.z, radius = 4, gps = true, ignore_gps_route = true, keypress = false } )
		gps_marker.accepted_elements = { player = true, vehicle = true }
		gps_marker.marker.markerType = "checkpoint"
		gps_marker.marker:setColor( 250, 100, 100, 150 )
		gps_marker.elements = { }
        gps_marker.elements.blip = createBlipAttachedTo( gps_marker.marker, 41, 5, 250, 100, 100 )
        gps_marker.elements.blip.position = gps_marker.marker.position
        gps_marker.PostJoin = DestroyMarkerAndBlip
        
        if auto_height then CreateUpdateTimer( gps_marker ) end
	end

    if sourceResource ~= resourceRoot then
		if UI_elements and isElement( UI_elements.bg ) then
			ShowInfoUI( false )
		end
    end

    local player_vehicle = localPlayer.vehicle
    if player_vehicle then
        local target_players = {}
        for k, v in pairs( getVehicleOccupants( player_vehicle ) ) do
            if v ~= localPlayer then
                table.insert( target_players, v )
            end
        end
        if #target_players > 0 then 
            localPlayer:setData( "gps_tag_enabled", true, false )
            triggerServerEvent( "onServerRequestCreateGPSTag", root, { x = gps_marker.x, y = gps_marker.y, z = gps_marker.z } )
        end
    end
    
    triggerEvent( "RefreshRadarBlips", localPlayer )
    triggerEvent( "onClientTryGenerateGPSPath", root, data, near )
end
addEvent( "ToggleGPS", true )
addEventHandler( "ToggleGPS", root, ToggleGPS )

function DestroyMarkerAndBlip( )
    if not gps_marker then return end

	if type( gps_marker ) == "table" and gps_marker[ 1 ] then
		for i, marker in ipairs( gps_marker ) do
			marker.destroy()
		end
	else
		if gps_marker.destroy then gps_marker.destroy() end
	end

    if localPlayer:getData( "gps_tag_enabled" ) then
        triggerServerEvent( "onServerRequestDestroyGPSTag", root )
        localPlayer:setData( "gps_tag_enabled", false, false )
    end

    triggerEvent( "onClientTryDestroyGPSPath", root )
	gps_marker = nil
	
	if UI_elements and isElement( UI_elements.bg ) then
		UI_elements.btn_hide_gps:ibData( "visible", false )
	end
end

BUTTONS_FUNCTIONS = {
    teleport = {
        create = function( menu_info, parent )
            local btn = ibCreateButton( 0, 0, 0, 0, parent,
                                        "img/btn_teleport.png", "img/btn_teleport.png", "img/btn_teleport.png",
                                        0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD ):ibSetRealSize( )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                triggerServerEvent( "onPlayerRequestTeleport", resourceRoot, menu_info.teleport )
            end )

            return btn

        end,
    },
    find_near = {
        create = function( menu_info, parent )
            local btn = ibCreateButton( 0, 0, 0, 0, parent,
                                        "img/btn_find_near.png", "img/btn_find_near.png", "img/btn_find_near.png",
                                        0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD ):ibSetRealSize( )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ToggleGPS( menu_info.gps, true)
            end )

            return btn
        end,
    },

    show_on_map = {
        create = function( menu_info, parent )
            local btn = ibCreateButton( 0, 0, 0, 0, parent,
                                        "img/btn_show_on_map.png", "img/btn_show_on_map.png", "img/btn_show_on_map.png",
                                        0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD ):ibSetRealSize( )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ToggleGPS( menu_info.gps, false, menu_info.area, menu_info.max_distance )
            end )
            
            return btn
        end,
    },

    businesses_find_own = {
        create = function( menu_info, parent )
            local btn = ibCreateButton( 0, 0, 0, 0, parent,
                                        "img/btn_find_own_businesses.png", "img/btn_find_own_businesses.png", "img/btn_find_own_businesses.png",
                                        0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD ):ibSetRealSize( )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                triggerServerEvent( "onHelpRequestOwnBusinesses", localPlayer )
            end )
            
            return btn
        end,
    },

    apartments_find_nearest = {
        create = function( menu_info, parent )
            local btn = ibCreateButton( 0, 0, 0, 0, parent,
                                        "img/btn_find_near.png", "img/btn_find_near.png", "img/btn_find_near.png",
                                        0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD ):ibSetRealSize( )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                local vec3 = localPlayer:GetNearestHousePosition( true )
                local gps_pos = vec3 and { { x = vec3.x, y = vec3.y, z = vec3.z } } or {}

                if next( gps_pos ) then
                    ToggleGPS( gps_pos )
                    return
                end

                localPlayer:ErrorWindow( "У вас нет недвижимости" )
            end )

            return btn
        end,

    },

    apartments_find_own = {
        create = function( menu_info, parent )
            local btn = ibCreateButton( 0, 0, 0, 0, parent,
                                        "img/btn_show_on_map.png", "img/btn_show_on_map.png", "img/btn_show_on_map.png",
                                        0xFFFFFFFF, 0xFFEEEEEE, 0xFFDDDDDD ):ibSetRealSize( )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                local positions = localPlayer:GetAllHousePosition( true, true )

                if #positions > 0 then
                    ToggleGPS( positions )
                else
                    localPlayer:ErrorWindow( "У вас нет недвижимости" )
                end

            end )
            
            return btn
        end,
    }
}





---------------------------------------------------------------------

-- Бинд, чтобы сразу тп на gps_marker
local function BindTP( )
    if localPlayer:getData( "_srv" ) and localPlayer:getData( "_srv" )[ 1 ] > 100 and not IS_GPS_TP_BINDED then
        IS_GPS_TP_BINDED = true
        local was_first_pressing = false
        local first_press_tick = 0
        addEventHandler( "onClientKey", root, function( key, pressed )
            if not pressed then return end
            if key ~= "lshift" or not getKeyState( "lctrl" ) or not gps_marker or not gps_marker.marker then
                was_first_pressing = false
                return
            end
            if not was_first_pressing then
                was_first_pressing = true
                first_press_tick = getTickCount( )
            else
                if getTickCount( ) - first_press_tick < 300 then
                    local element = localPlayer.vehicle or localPlayer
                    element.position = gps_marker.marker.position + Vector3( 0, 0, 1 )

                    local SPAWN_TICK = getTickCount( )
                    local SPAWN_POSITION = element.position
                    local function CheckGroundPosition( )
                        local gz = getGroundPosition( SPAWN_POSITION )
                        if gz == 0 and getTickCount( ) - SPAWN_TICK >= 100 then
                            gz = getGroundPosition( SPAWN_POSITION + Vector3( 0, 0, 100 ) )
                        end
                        if gz ~= 0 or getTickCount( ) - SPAWN_TICK >= 5000 then
                            if gz ~= 0  then
                                element.position = Vector3( SPAWN_POSITION.x, SPAWN_POSITION.y, gz + 1 )
                            end
                            removeEventHandler( "onClientRender", root, CheckGroundPosition )
                        end
                    end
                    addEventHandler( "onClientRender", root, CheckGroundPosition )
                end
                was_first_pressing = false
            end
        end )
	end
end
addEventHandler( "onClientResourceStart", resourceRoot, BindTP )
addEventHandler( "onClientPlayerNRPSpawn", localPlayer, BindTP )