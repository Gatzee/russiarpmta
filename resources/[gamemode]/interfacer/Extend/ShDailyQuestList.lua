

QUEST_NAMES = {}

MAX_PLAYER_DAILY_QUESTS = 5
DAILY_QUEST_LIST =
{
    -------------
    --Обычные
    ------------
 
    ["start_shift"] = 
    { 
        id = 1,
        name = "Начни смену на работе",
        condition = function( player )
            local playerLevel = player:GetLevel( )
            local faction = player:GetFaction( )
            return playerLevel >= 5 and faction == 0
        end,
        rewards = { value = 2, type = "hard", first_value = 4 }, 
    },

    ["play_casino"] =
    { 
        id = 2,
        name = "Сыграй в казино",
        condition = function( player )
            return true
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "casino" )
        end,
        on_completed = function( player )
            player:AddDailyQuest( "np_daily_reward", true )
        end,
        rewards =  { value = 1000, type = "soft" }, 
    },

    ["start_hunting"] =
    {
        id = 5,
        name = "Начни охоту",
        condition = function( player )
            local playerLevel = player:GetLevel()
            return playerLevel >= 5
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "hunting" )
        end,
        rewards = { value = 1, type = "hard" } 
    },

    ["start_fishing"] =
    { 
        id = 6,
        name = "Начни рыбалку",
        condition = function( player )
            local playerLevel = player:GetLevel()
            return playerLevel >= 4
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "fishing" )
        end,
        rewards = { value = 1, type = "hard" } 
    },

    ["recharge_ba"] =
    { 
        id = 7,
        name = "Пополни лицевой счет бизнеса",
        short_name = "Пополни лс бизнеса",
        condition = function( player )
            local business = exports.nrp_businesses:GetOwnedBusinesses( player )
            return #business > 0
        end,
        rewards = { value = 1200, type = "soft" } 
    },

    ["buy_eat"] =
    { 
        id = 8,
        name = "Купи еды",
        condition = function( player )
            return true
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "food" )
        end,
        rewards = { value = 500, type = "soft" } 
    },

    ["buy_medicine"] =
    { 
        id = 9,
        name = "Купить лекарства",
        condition = function( player )
            return true
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "business_drugstore" )
        end,
        rewards = { value = 500, type = "soft" } 
    },

    ["visit_wardrobe"] = 
    { 
        id = 10,
        name = "Посети гардероб",
        condition = function( player )
            local player_apartments = player:HasAnyApartment()
            return player_apartments
        end,
        rewards = { value = 500, type = "soft" } 
    },

    ["start_kino_list"] = 
    { 
        id = 11,
        name = "Запусти свой плейлист в кинотеатре",
        short_name = "Запусти плейлист в кино",
        condition = function( player )
            return true
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "cinema" )
        end,
        rewards = { value = 2000, type = "soft" } 
    },

    ["install_inner_vehicle_detail"] = 
    { 
        id = 12,
        name = "Установи внутреннюю деталь авто",
        short_name = "Установи внутреннюю деталь авто",
        condition = function( player )
            local vehicles = player:GetVehicles( false, true )
            if #vehicles == 0 or ( #vehicles == 1 and vehicles[ 1 ].model == 468 ) then
                return false
            end
            return true
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "tuning" )
        end,
        rewards = { value = 2, type = "hard" } 
    },

    -------------
    --Для фракций
    ------------
    
    ["participation_study"] = 
    {
        id = 13,
        name = "Участвуй в учении",
        condition = function( player )
            local faction = player:GetFaction()
            local playerLevel = player:GetLevel()
            return faction ~= 0 and faction ~= F_MEDIC and faction ~= F_MEDIC_MSK and playerLevel >= 4
        end,
        rewards = { value = 1, type = "hard" } 
    },

    ["army_outfit_akpp"] = 
    {
        id = 15,
        name = "Наряд АКПП",
        condition = function( player )
            local faction = player:GetFaction()
            local playerLevel = player:GetLevel()
            return playerLevel >= 4 and faction == F_ARMY
        end,
        rewards = { value = 1, type = "hard" } 
    },

    ["army_guard"] = 
    {
        id = 16,
        name = "Караул",
        condition = function( player )
            local faction = player:GetFaction()
            local playerLevel = player:GetLevel()
            return playerLevel >= 4 and faction == F_ARMY
        end,
        rewards = { value = 1, type = "hard" } 
    },

    ["army_weapons_depot"] = 
    {
        id = 17,
        name = "Склад вооружения",
        condition = function( player )
            local faction = player:GetFaction()
            local playerLevel = player:GetLevel()
            return playerLevel >= 4 and faction == F_ARMY
        end,
        rewards = { value = 1, type = "hard" } 
    },

    ["pps_verify_documents"] = 
    {
        id = 18,
        name = "Проверка документов",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 4 and ( faction == F_POLICE_PPS_NSK or faction == F_POLICE_PPS_GORKI )
        end,
        rewards = { value = 1, type = "hard" } 
    },

    ["pps_sweep_city"] = 
    {
        id = 19,
        name = "Зачистка города",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 4 and ( faction == F_POLICE_PPS_NSK or faction == F_POLICE_PPS_GORKI )
        end,
        rewards = { value = 1, type = "hard" } 
    },

    ["dps_verify_documents"] = 
    {
        id = 20,
        name = "Проверка документов",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 4 and ( faction == F_POLICE_DPS_NSK or faction == F_POLICE_DPS_GORKI or faction == F_POLICE_DPS_MSK )
        end,
        rewards = { value = 1, type = "hard" } 
    },

    ["dps_watch_posts"] = 
    {
        id = 21,
        name = "Дежурство на постах",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 4 and ( faction == F_POLICE_DPS_NSK or faction == F_POLICE_DPS_GORKI or faction == F_POLICE_DPS_MSK )
        end,
        rewards = { value = 1, type = "hard" } 
    },

    ["medic_watch"] = 
    {
        id = 22,
        name = "Дежурство",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 4 and ( faction == F_MEDIC or faction == F_MEDIC_MSK )
        end,
        rewards = { value = 1, type = "hard" } 
    },

    ["medic_overflow_morgue"] = 
    {
        id = 23,
        name = "Переполнение в морге",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 4 and ( faction == F_MEDIC or faction == F_MEDIC_MSK )
        end,
        rewards = { value = 1, type = "hard" } 
    },

    ["medic_unload_medicines"] = 
    {
        id = 24,
        name = "Разгрузка медикаментов",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 4 and ( faction == F_MEDIC or faction == F_MEDIC_MSK )
        end,
        rewards = { value = 1, type = "hard" } 
    },

    ["mayor_agitation"] = 
    {
        id = 25,
        name = "Агитация власти",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 4 and ( faction == F_GOVERNMENT_NSK or faction == F_GOVERNMENT_GORKI or faction == F_GOVERNMENT_MSK )
        end,
        rewards = { value = 1, type = "hard" } 
    },

    ["mayor_wellfed_city"] = 
    {
        id =  26,
        name = "Сытый город",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 4 and ( faction == F_GOVERNMENT_NSK or faction == F_GOVERNMENT_GORKI or faction == F_GOVERNMENT_MSK )
        end,
        rewards = { value = 1, type = "hard" } 
    },

    --------------
    --Для бандитов
    --------------

    ["band_kill_opponents"] = 
    {
        id = 27,
        name = "Убей члена вражеского клана",
        condition = function( player )
            local band = player:GetClanID()
            local playerLevel = player:GetLevel()
            return band and playerLevel >= 6
        end,
        rewards = { value = 1, type = "hard" } 
    },

    ["band_redraw_graffiti"] = 
    {
        id = 29,
        name = "Перекрась граффити",
        condition = function( player )
            local band = player:GetClanID()
            local playerLevel = player:GetLevel()
            return band and playerLevel >= 6
        end,
        rewards = { value = 1, type = "hard" } 
    },

    ["band_participate_raider_capture"] = 
    {
        id = 30,
        name = "Участвуй в “рейдерском захвате”",
        condition = function( player )
            local band = player:GetClanID()
            local playerLevel = player:GetLevel()
            return band and playerLevel >= 6
        end,
        rewards = { value = 3, type = "hard" } 
    },

    ["band_start_fight"] = 
    {
        id = 31,
        name = "Устрой драку",
        condition = function( player )
            local band = player:GetClanID()
            local playerLevel = player:GetLevel()
            return band and playerLevel >= 6
        end,
        rewards = { value = 1000, type = "soft" } 
    },

    ["band_get_into_hospital"] = 
    {
        id = 32,
        name = "Попади в больницу",
        condition = function( player )
            local band = player:GetClanID()
            local playerLevel = player:GetLevel()
            return band and playerLevel >= 6
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "faction_medics" )
        end,
        rewards = { value = 1000, type = "soft" } 
    },

    ["band_heal_in_hospital"] = 
    {
        id = 33,
        name = "Вылечись в больнице",
        condition = function( player )
            local band = player:GetClanID()
            local playerLevel = player:GetLevel()
            return band and playerLevel >= 6
        end,
        rewards = { value = 2, type = "hard" } 
    },


    -------------------
    --Для новых игроков
    -------------------
        --Основные
    ["np_start_shift"] = 
    {
        id = 34,
        name = "Начни смену на работе",
        condition = function( player )
            local playerLevel = player:GetLevel()
            return playerLevel >= 2 and playerLevel <= 4
        end,
        rewards = { value = 1000, type = "soft" } 
    },

    ["np_get_new_level"] = 
    {
        id = 36,
        name = "Получи новый уровень",
        condition = function( player )
            local playerLevel = player:GetLevel()
            return playerLevel >= 2 and playerLevel <= 4
        end,
        rewards = { value = 3, type = "hard" } 
    },

    ["np_get_b_rights"] = 
    {
        id = 37,
        name = "Получи права B",
        condition = function( player )
            local playerLevel = player:GetLevel()
            return not player:HasLicense( LICENSE_TYPE_AUTO ) and player:GetMoney() >= 19000 and playerLevel >= 2
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "driving_school" )
        end,
        max_execution = 1,
        rewards = { value = 3, type = "hard" } 
    },

        --Дополнительные
    ["np_visit_dance_school"] = 
    {
        id = 38,
        name = "Посети школу танцев",
        condition = function( player )
            return true
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "dancing_school" )
        end,
        rewards = { value = 1, type = "hard", first_value = 2 } 
    },

    ["np_visit_cloth_shop"] = 
    {
        id = 39,
        name = "Посети магазин одежды",
        condition = function( player )
            local playerLevel = player:GetLevel()
            return playerLevel >= 10
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "boutique" )
        end,
        rewards = { value = 1, type = "hard", first_value = 2 } 
    },

    ["np_visit_car_showroom"] = 
    {
        id = 40,
        name = "Посети автосалон (Любой)",
        condition = function( player )
            return true
        end,
        get_location = function( )
            local carsells_list = { }
            local carsell_categories = { "carsell_economy", "carsell_normal", "carsell_luxe", "carsell_premium", "carsell_premium_msk" }

            for k,v in pairs( carsell_categories ) do
                table.insert( carsells_list, exports.nrp_help:FindClosestLocation( v ) )
            end

            local source_position = localPlayer.position
            local closest_location
            local min_distance = math.huge

            for k,v in pairs( carsells_list ) do
                local distance = ( source_position - Vector3( v ) ).length
                if distance <= min_distance then
                    closest_location = v
                    min_distance = distance
                end
            end

            return closest_location
        end,
        rewards = { value = 1, type = "hard", first_value = 2 } 
    },

    ["np_visit_kino"] = 
    {
        id = 41,
        name = "Посети кинотеатр",
        condition = function( player )
            return true
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "cinema" )
        end,
        rewards = { value = 1, type = "hard", first_value = 2 } 
    },

    ["np_visit_autoschool"] = 
    {
        id = 42,
        name = "Посети автошколу",
        condition = function( player )
            return true
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "driving_school" )
        end,
        rewards = { value = 1, type = "hard", first_value = 2 } 
    },

    ["np_visit_airshow"] = 
    {
        id = 43,
        name = "Посети авиасалон",
        condition = function( player )
            return true
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "carsell_air" )
        end,
        rewards = { value = 1, type = "hard", first_value = 2 } 
    },

    ["np_visit_shipyard"] = 
    {
        id = 44,
        name = "Посети верфь",
        condition = function( player )
            return true
        end,
        get_location = function( )
            return { x = 1474.718, y = -2518.580, z = 2.170 }
        end,
        rewards = { value = 1, type = "hard", first_value = 2 } 
    },

    ["np_visit_exchange"] = 
    {
        id = 45,
        name = "Посети биржу",
        condition = function( player )
            return true
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "businesses_sell" )
        end,
        rewards = { value = 1, type = "hard", first_value = 2 } 
    },

    ["np_visit_pps"] = 
    {
        id = 46,
        name = "Посети ППС",
        condition = function( player )
            return true
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "faction_pps" )
        end,
        rewards = { value = 2, type = "hard", first_value = 4 } 
    },

    ["np_visit_dps"] = 
    {
        id = 47,
        name = "Посети ДПС",
        condition = function( player )
            return true
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "faction_dps" )
        end,
        rewards = { value = 2, type = "hard", first_value = 4 } 
    },

    ["np_visit_hospital"] = 
    {
        id = 48,
        name = "Посети больницу",
        condition = function( player )
            return true
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "faction_medics" )
        end,
        rewards = { value = 2, type = "hard", first_value = 4 } 
    },

    ["np_visit_mayor"] = 
    {
        id = 49,
        name = "Посети мэрию",
        condition = function( player )
            return true
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "faction_mayor" )
        end,
        rewards = { value = 2, type = "hard", first_value = 4 } 
    },

    ["np_visit_apartament"] = 
    {
        id = 50,
        name = "Посети любую квартиру",
        condition = function( player )
            return true
        end,
        rewards = { value = 1, type = "hard", first_value = 2 } 
    },

    ["np_use_taxi"] = 
    {
        id = 51,
        name = "Проедь 1000 метров в такси",
        condition = function( player )
            return true
        end,
        rewards = { value = 2, type = "hard", first_value = 3 } 
    },

    ["np_join_clan"] = 
    {
        id = 52,
        name = "Вступи в клан",
        condition = function( player )
            return not player:GetFaction( )
        end,
        max_execution = 1,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "clan_base" )
        end,
        rewards = { value = 3, type = "hard", first_value = 6 } 
    },

    ["np_join_faction"] = 
    {
        id = 53,
        name = "Вступи во фракцию",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local band = player:GetClanID()
            local millitary_ticker = player:HasMilitaryTicket()
            local faction = player:GetFaction()
            return playerLevel >= 4 and not band and millitary_ticker and faction == 0
        end,
        max_execution = 1,
        rewards = { value = 4, type = "hard", first_value = 8 } 
    },

    ["np_get_rp_certificate"] = 
    {
        id = 54,
        name = "Получи РП аттестат",
        condition = function( )
            return false -- disable
        end,
        max_execution = 1,
        rewards = { value = 4, type = "hard", first_value = 8 } 
    },

    ["find_treasure"] =
    { 
        id = 55,
        name = "Найди сокровище",
        condition = function( player )
            local playerLevel = player:GetLevel()
            return playerLevel >= 7
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "digging" )
        end,
        rewards = { value = 1, type = "hard", first_value = 2 } 
    },

    ["participate_race"] =
    { 
        id = 56,
        name = "Поучаствуй в гонках",
        condition = function( player )
            local vehicles = player:GetVehicles( false, true )
            if #vehicles == 0 or ( #vehicles == 1 and vehicles[ 1 ].model == 468 ) then
                return false
            end
            return true
        end,
        rewards = { value = 2, type = "hard", first_value = 4 } 
    },

    ["try_accessoaries"] =
    { 
        id = 57,
        name = "Примерь аксессуар",
        condition = function( player )
            return true
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "boutique" )
        end,
        rewards = { value = 1, type = "hard", first_value = 2 } 
    },

    ["np_view_cloth_shop"] = 
    {
        id = 58,
        name = "Осмотри магазин одежды",
        condition = function( player )
            local playerLevel = player:GetLevel()
            return playerLevel < 10
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "boutique" )
        end,
        rewards = { value = 1000, type = "soft" } 
    },

    ["get_phone_number"] =
    {
        id = 59,
        name = "Купи SIM-карту",
        condition = function( player )
            local phoneNumber = player:GetPhoneNumber( )
            local playerLevel = player:GetLevel( )
            return playerLevel == 2 and not phoneNumber
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "simshops" )
        end,
        rewards = { value = 1500, type = "soft" }
    },

    ["np_visit_weapon_store"] =
    {
        id = 60,
        name = "Посети оружейный магазин",
        condition = function( player )
            local playerLevel = player:GetLevel( )
            return playerLevel >= 6
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "gunshop" )
        end,
        rewards = { value = 1, type = "hard", first_value = 2 } 
    },

    ["np_start_trashman"] =
    {
        id = 61,
        name = "Начни работу мусорщика",
        condition = function( player )
            local playerLevel = player:GetLevel( )
            local faction = player:GetFaction( )
            return playerLevel >= 4 and playerLevel <= 8 and faction == 0
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "job_trashman" )
        end,
        rewards = { value = 2, type = "hard", first_value = 4 }
    },

    ["np_start_delivery_car"] =
    {
        id = 62,
        name = "Начни работу доставщика ТС",
        condition = function( player )
            local playerLevel = player:GetLevel( )
            local faction = player:GetFaction( )
            return playerLevel >= 16 and playerLevel <= 24 and faction == 0
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "job_delivery_cars" )
        end,
        rewards = { value = 3000, type = "soft", first_value = 5000 }
    },

    ["np_start_incasator"] =
    {
        id = 63,
        name = "Начни работу инкассатора",
        condition = function( player )
            local playerLevel = player:GetLevel( )
            local faction = player:GetFaction( )
            return playerLevel >= 18 and playerLevel <= 25 and faction == 0
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "job_inkas" )
        end,
        rewards = { value = 3000, type = "soft", first_value = 5000 }
    },

    ["np_start_towtrucker"] =
    {
        id = 64,
        name = "Начни работу эвакуаторщика",
        condition = function( player )
            local playerLevel = player:GetLevel( )
            local faction = player:GetFaction( )
            return playerLevel >= 13 and playerLevel <= 18 and faction == 0
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "job_towtrucker" )
        end,
        rewards = { value = 2000, type = "soft", first_value = 4000 }
    },

    ["np_start_incasator_4"] =
    {
        id = 65,
        name = "Начни работу инкассатора в четвером",
        condition = function( player )
            local playerLevel = player:GetLevel( )
            local faction = player:GetFaction( )
            return playerLevel >= 18 and playerLevel <= 25 and faction == 0
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "job_inkas" )
        end,
        rewards = { value = 4000, type = "soft", first_value = 10000 }
    },

    -- New tasks ( 29.04.21 )

    ["faction_shift_complite"] =
    {
        id = 66,
        name = "Выполни любой план на смену",
        condition = function( player )
            local playerLevel = player:GetLevel( )
            local faction = player:GetFaction( )
            return faction and faction ~= 0 and playerLevel >= 4
        end,
        rewards = { value = 2000, type = "soft" }
    },

    ["pps_order_complite"] =
    {
        id = 67,
        name = "Выполнить заказ ориентировок",
        condition = function( player )
            local playerLevel = player:GetLevel( )
            local faction = player:GetFaction( )
            return playerLevel >= 4 and ( faction == F_POLICE_PPS_NSK or faction == F_POLICE_PPS_GORKI )
        end,
        rewards = { value = 1, type = "hard" }
    },

    ["np_add_contact"] =
    {
        id = 68,
        name = "Добавь в контакты 3 человека",
        only_forced = true,
        condition = function( player )
            return player:GetPhoneNumber( ) and true or false
        end,
        max_execution = 1,
        rewards = { value = 2500, type = "soft" }
    },

    ["np_daily_reward"] =
    {
        id = 69,
        name = "Забери ежедневную награду",
        only_forced = true,
        condition = function( player )
            local playerLevel = player:GetLevel( )
            return playerLevel >= 2
        end,
        max_execution = 1,
        rewards = { value = 1000, type = "soft" }
    },

    ["wof_use"] =
    {
        id = 70,
        name = "Покрути колесо фортуны",
        condition = function( player )
            local playerLevel = player:GetLevel( )
            return playerLevel >= 2 and playerLevel <= 5
        end,
        rewards = { value = 500, type = "soft" }
    },

    ["np_visit_fc"] =
    {
        id = 71,
        name = "Посети бойцовский клуб",
        condition = function( player )
            local playerLevel = player:GetLevel( )
            return playerLevel >= 12
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "fight_club" )
        end,
        rewards = { value = 1500, type = "soft" }
    },

    ["np_visit_church"] =
    {
        id = 72,
        name = "Посети церковь",
        condition = function( player )
            local playerLevel = player:GetLevel( )
            return playerLevel >= 5
        end,
        get_location = function( )
            return { x = 179.96, y = -1693.46, z = 22 }
        end,
        rewards = { value = 1000, type = "soft" }
    },

    ["race_participation_drift"] =
    {
        id = 73,
        name = "Прими участие в дрифте",
        condition = function( player )
            local vehicles = player:GetVehicles( false, true )
            if #vehicles == 0 or ( #vehicles == 1 and vehicles[ 1 ].model == 468 ) then
                return false
            end
            return true
        end,
        rewards = { value = 1, type = "hard", first_value = 2 }
    },

    ["race_participation_drag"] =
    {
        id = 74,
        name = "Прими участие в драге",
        condition = function( player )
            local vehicles = player:GetVehicles( false, true )
            if #vehicles == 0 or ( #vehicles == 1 and vehicles[ 1 ].model == 468 ) then
                return false
            end
            return true
        end,
        rewards = { value = 1, type = "hard", first_value = 2 }
    },

    ["race_participation_circle"] =
    {
        id = 75,
        name = "Прими участие в круге на время",
        condition = function( player )
            local vehicles = player:GetVehicles( false, true )
            if #vehicles == 0 or ( #vehicles == 1 and vehicles[ 1 ].model == 468 ) then
                return false
            end
            return true
        end,
        rewards = { value = 1, type = "hard", first_value = 2 }
    },

    ["battle_pass_uplvl"] =
    {
        id = 76,
        name = "Получи уровень сезонных наград",
        condition = function( player )
            local playerLevel = player:GetLevel( )
            return playerLevel >= 3
        end,
        rewards = { value = 1000, type = "soft" }
    },

    ["np_visit_stripclub"] =
    {
        id = 77,
        name = "Посети стрипклуб",
        condition = function( player )
            local playerLevel = player:GetLevel( )
            return playerLevel >= 5
        end,
        get_location = function( )
            return exports.nrp_help:FindClosestLocation( "strip_club" )
        end,
        rewards = { value = 1500, type = "soft" }
    },

    --[[
    ["np_start_hijack_car"] =
    {
        id = 78,
        name = "Начни работу угонщика транспорта",
        condition = function( player )
            return false -- disabled
        end,
        rewards = { value = 2, type = "hard", first_value = 4 }
    },
    ]]
}

for k, v in pairs( DAILY_QUEST_LIST ) do
    table.insert( QUEST_NAMES, k )
end