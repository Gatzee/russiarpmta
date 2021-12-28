DOING_LIST = {
    ready_to_play = {
        "achieve_gen1",
        "achieve_gen2",
        "achieve_gen3",
        "achieve_gen4",
        "achieve_gen11",
        "achieve_gen13",
        "achieve_gen14",
        "achieve_gen15",
        "achieve_gen17",
        "achieve_gen20",
        "achieve_gen24",
        "achieve_gen28",
        "achieve_gen29",
        "achieve_gen30",
        "achieve_gen32",
        "achieve_gen44",
        "achieve_gen45",
        "achieve_gen48",
    },
    learn_free_dances = { "achieve_gen24" },
    finish_tutorial = { "achieve_gen1" },
    update_social_rating = { "achieve_gen2" },
    finish_task = { "achieve_gen3", "achieve_gen11" },
    call_112 = { "achieve_gen12" },
    add_car = { "achieve_gen13" },
    add_plane = { "achieve_gen14" },
    add_boat = { "achieve_gen15" },
    start_work = { "achieve_gen4" },
    watch_cinema = { "achieve_gen5" },
    got_fish = { "achieve_gen6" },
    got_animal = { "achieve_gen7" },
    start_coop_work = { "achieve_gen8", "achieve_gen4" },
    enter_casino_game = { "achieve_gen9" },
    fall = { "achieve_gen10" },
    bounty_order = { "achieve_gen18" },
    play_radio = { "achieve_gen16" },
    buy_skin = { "achieve_gen17" },
    admin_event_join = { "achieve_gen19" },
    buy_house = { "achieve_gen20" },
    enter_stip_club = { "achieve_gen21" },
    church_wedding = { "achieve_gen22" },
    start_fight_fc = { "achieve_gen23" },
    fuel_car = { "achieve_gen25" },
    repair_car = { "achieve_gen26" },
    capital_repair_car = { "achieve_gen27" },
    buy_business = { "achieve_gen28" },
    join_clan = { "achieve_gen29" },
    join_faction = { "achieve_gen30" },
    visit_market = { "achieve_gen31" },
    add_moto = { "achieve_gen32" },
    find_taxi = { "achieve_gen33" },
    buy_used_vehicle = { "achieve_gen34" },
    buy_uniq_thing = { "achieve_gen35" },
    buy_case = { "achieve_gen36" },
    spin_wheel = { "achieve_gen37" },
    spin_wheel_gold = { "achieve_gen38" },
    f4_service = { "achieve_gen39" },
    use_weapon_store = { "achieve_gen41" },
    use_ostankino = { "achieve_gen42" },
    delightful_treatment = { "achieve_gen43" },
    got_license = { "achieve_gen44" },
    use_accessory = { "achieve_gen45" },
    maximum_intoxication = { "achieve_gen47" },
    wedding = { "achieve_gen48" },
    bought_garage_slot = { "achieve_gen49" },
    puke = { "achieve_gen50" },
}

--[[
    // level system
    targets = { 100, 300 },
    local lvl = 0
    local result = false

    if self.targets then
        for level, value in ipairs( self.targets ) do
            if progress >= value then
                lvl = level
                result = true
            end
        end
    end
]]

ACHIEVEMENTS = {
    achieve_gen1 = {
        name = "Великое падение",
        description = "Пройти туториал игры",
        en_name = "great_fall",
        check_func = function ( self, player )
            return player:HasFinishedTutorial( )
        end,
    },

    achieve_gen2 = {
        name = "Социальная защищенность",
        description = "Достигни положительного социального рейтинга на 100 или более единиц",
        en_name = "social_security",
        func = function ( self, player )
            local progress = player:GetSocialRating( )
            return progress >= 100
        end,
    },

    achieve_gen3 = {
        name = "Начало истории",
        description = "Пройти первую линейку квестов с 1 по 14",
        en_name = "beginning_story",
        func = function ( self, player )
            local q_list = ( player:GetPermanentData( "quests" ) or { } ).completed or { }
            local result = q_list[ "return_of_history" ] and true or false

            return result
        end,
    },

    achieve_gen4 = {
        name = "Рабочий настрой",
        description = "Начать впервые любую работу",
        en_name = "working_attitude",
        check_func = function ( self, player )
            local rewards = player:GetPermanentData( "jobs_cash_rewards" ) or 0
            return rewards > 0
        end,
    },

    achieve_gen5 = {
        name = "Лучшие фильмы",
        description = "Включить фильм в кинотеатре",
        en_name = "best_movies",
    },

    achieve_gen6 = {
        name = "Отдых на рыбалке",
        description = "Выловить одну рыбу",
        en_name = "fishing_holidays",
    },

    achieve_gen7 = {
        name = "Отдых на охоте",
        description = "Освежевать одну дичь",
        en_name = "hunting_rest",
    },

    achieve_gen8 = {
        name = "Вместе работа быстрей",
        description = "Начать кооперативную работу",
        en_name = "work_faster_together",
    },

    achieve_gen9 = {
        name = "Местный азарт",
        description = "Посетить любую игру в казино",
        en_name = "local_passion",
    },

    achieve_gen10 = {
        name = "Смертельная лепёшка",
        description = "Смертельно упасть с высоты 20 раз",
        en_name = "deadly_cake",
        func = function ( self, player )
            player:AddAchievementProgress( self.id, 1 )
            return player:GetAchievementsProgress( self.id ) >= 20
        end,
    },

    achieve_gen11 = {
        name = "Железный конь",
        description = "Получить железного коня",
        en_name = "iron_horse",
        func = function ( self, player )
            local q_list = ( player:GetPermanentData( "quests" ) or { } ).completed or { }
            local result = q_list[ "alexander_get_vehicle_bike" ] and true or false

            return result
        end,
    },

    achieve_gen12 = {
        name = "Госслужбы в деле",
        description = "Вызвать госпомощь",
        tooltip = "Использовать приложение вызов госслужб",
        en_name = "civil_services_inaction",
    },

    achieve_gen13 = {
        name = "Первая тачка",
        description = "Приобрести первую машину",
        en_name = "first_car",
        check_func = function ( self, player )
            local vehicles = player:GetVehicles( nil, nil, true )
            local result = next( vehicles ) and true or false

            return result
        end,
    },

    achieve_gen14 = {
        name = "Первый авиатранспорт",
        description = "Приобрести первый самолет",
        en_name = "first_air_transport",
        check_func = function ( self, player )
            local specVehicles = player:GetSpecialVehicles( )

            for _, vehicle in pairs( specVehicles ) do
                local model = vehicle[ 2 ]
                if VEHICLE_CONFIG[ model ] and VEHICLE_CONFIG[ model ].is_airplane then
                    return true
                end
            end

            return false
        end,
    },

    achieve_gen15 = {
        name = "Первый морской транспорт",
        description = "Приобрести первую лодку",
        en_name = "first_sea_transport",
        check_func = function ( self, player )
            local specVehicles = player:GetSpecialVehicles( )

            for _, vehicle in pairs( specVehicles ) do
                local model = vehicle[ 2 ]
                if VEHICLE_CONFIG[ model ] and VEHICLE_CONFIG[ model ].is_boat then
                    return true
                end
            end

            return false
        end,
    },

    achieve_gen16 = {
        name = "Музыка везде",
        description = "Используй плеер в телефоне",
        en_name = "music_everywhere",
        client_side = true,
    },

    achieve_gen17 = {
        name = "Новые шмотки",
        description = "Приобрести первый скин в магазине одежды",
        en_name = "new_clothes",
        check_func = function ( self, player )
            local skins = player:GetSkins( )
            local counter = 0

            for i in pairs( skins ) do
                counter = counter + 1
                if counter > 1 then
                    return true
                end
            end

            return false
        end,
    },

    achieve_gen18 = {
        name = "Месть превыше всего",
        description = "Заказать своего убийцу после смерти",
        en_name = "revenge_above_all",
    },

    achieve_gen19 = {
        name = "Активист",
        description = "Участие в ивенте от администрации",
        en_name = "activist",
    },

    achieve_gen20 = {
        name = "Больше не бомжуем",
        description = "Приобрести первую любую недвижимость",
        en_name = "longer_homeless",
        check_func = function ( self, player )
            local apartments = player:getData( "apartments" ) or { }
            local vip_h = player:getData( "viphouse" ) or { }

            return #apartments > 0 or #vip_h > 0
        end,
    },

    achieve_gen21 = {
        name = "Страстные танцы",
        description = "Посетить стрип — бар",
        en_name = "passionate_dancing",
    },

    achieve_gen22 = {
        name = "Церковное венчание",
        description = "Посетить священника в церкви",
        en_name = "church_wedding",
    },

    achieve_gen23 = {
        name = "В душе боец",
        description = "Сразиться в бойцовском клубе",
        en_name = "at_heart_fighter",
    },

    achieve_gen24 = {
        name = "Движение жизнь",
        description = "Забрать бесплатные анимации в школе танцев",
        en_name = "movement_life",
        func = function ( self, player )
            for idx, v in pairs( DANCES_LIST ) do
                if v.cost == 0 and not player:HasDance( idx ) then
                    return false
                end
            end

            return true
        end,
    },

    achieve_gen25 = {
        name = "Полный бак",
        description = "Заполнить полный бак",
        en_name = "full_tank",
    },

    achieve_gen26 = {
        name = "Ремонт транспорта",
        description = "Отремонтировать транспорт",
        en_name = "transport_repair",
    },

    achieve_gen27 = {
        name = "Капиталка",
        description = "Произвести капиталку",
        en_name = "capital",
    },

    achieve_gen28 = {
        name = "Бизнесмен",
        description = "Приобрести бизнес",
        en_name = "businessman",
        check_func = function ( self, player )
            local b = exports.nrp_businesses:GetOwnedBusinesses( player ) or { }
            return #b > 0
        end
    },

    achieve_gen29 = {
        name = "Бандитизм в крови",
        description = "Вступить в клан",
        en_name = "blood_banditry",
        check_func = function ( self, player )
            return ( player:GetClanID( ) or 0 ) > 0
        end
    },

    achieve_gen30 = {
        name = "Служба отчизне",
        description = "Устроиться в любую фракцию",
        en_name = "service_to_fatherland",
        check_func = function ( self, player )
            return ( player:GetFaction( ) or 0 ) > 0
        end
    },

    achieve_gen31 = {
        name = "Любопытный покупатель",
        description = "Посетить все салоны продажи транспорта",
        en_name = "curious_buyer",
        func = function ( self, player )
            player:AddAchievementProgress( self.id, 1 )
            return player:GetAchievementsProgress( self.id ) >= 8
        end,
    },

    achieve_gen32 = {
        name = "Двухколесный хаус",
        description = "Приобрести мотоцикл",
        en_name = "two_wheeled_house",
        check_func = function ( self, player )
            local vehicles = player:GetVehicles( nil, true, true )

            for _, element in pairs( vehicles ) do
                local config = VEHICLE_CONFIG[ element.model ]
                if config and config.is_moto then
                    return true
                end
            end

            return false
        end,
    },

    achieve_gen33 = {
        name = "Сумасшедший таксист",
        description = "Заказать такси",
        tooltip = "Использовать приложение в телефоне",
        en_name = "crazy_taxi_driver",
    },

    achieve_gen34 = {
        name = "Подержанный транспорт",
        description = "Приобрести подержанный транспорт",
        en_name = "used_vehicles",
    },

    achieve_gen35 = {
        name = "Уникальный товар",
        description = "Приобрести любой уникальный товар",
        en_name = "unique_item",
    },

    achieve_gen36 = {
        name = "В окружении кейсов",
        description = "Приобрести любой кейс в магазине F4",
        en_name = "surrounded_by_cases",
    },

    achieve_gen37 = {
        name = "Колесо фортуны",
        description = "Использовать колесо фортуны",
        en_name = "wheel_of_fortune",
    },

    achieve_gen38 = {
        name = "Колесо фортуны VIP",
        description = "Использовать колесо фортуны VIP",
        en_name = "wheel_of_fortune_vip",
    },

    achieve_gen39 = {
        name = "Удобство в услугах",
        description = "Воспользоваться одной из услуг в магазине F4",
        en_name = "convenience_in_services",
    },

    --achieve_gen40 = { -- TODO: enable
    --    name = "Праздничные события",
    --    description = "Впервые принять участие в любом состязании праздничного события",
    --    en_name = "holiday_events",
    --},

    achieve_gen41 = {
        name = "Самозащита",
        description = "Приобрести товар в оружейном магазине",
        en_name = "self_defense",
    },

    achieve_gen42 = {
        name = "Парашютный экспресс",
        description = "Спрыгнуть с Останкино с парашютом",
        en_name = "parachute_express",
    },

    achieve_gen43 = {
        name = "Восхитительное лечение",
        description = "Вылечить одну стадию любой болезни",
        en_name = "delightful_treatment",
    },

    achieve_gen44 = {
        name = "Первые права",
        description = "Получи любые права на транспорт",
        en_name = "first_rights",
        check_func = function ( self, player )
            local licenses = player:GetLicenses( ) or { }

            for i in pairs( licenses ) do
                return true
            end

            return false
        end,
    },

    achieve_gen45 = {
        name = "Настоящий модник",
        description = "Надеть аксессуар",
        en_name = "real_fashionista",
        check_func = function ( self, player )
            local accessories = player:GetPermanentData( "accessories" ) or { }
            local a_used = accessories[ player.model ] or { }

            if next( a_used ) then
                return true
            end

            return false
        end
    },

    --achieve_gen46 = { -- TODO: enable
    --    name = "Настоящий москвич",
    --    description = "Купить квартиру в Москве",
    --    en_name = "real_muscovite",
    --    func = function ( self, player )
    --        local apartments = player:getData( "apartments" ) or { }
    --
    --        for i, v in pairs( apartments ) do
    --            if GetLocationIDFromHID( v.id ) == 8 then
    --                return true
    --            end
    --        end
    --
    --        return false
    --    end,
    --},

    achieve_gen47 = {
        name = "Максимальное опьянение",
        description = "Напиться в хлам в стрип—баре",
        en_name = "maximum_intoxication",
    },

    achieve_gen48 = {
        name = "Брачный сезон",
        description = "Заключить брачный союз",
        en_name = "mating_season",
        check_func = function ( self, player )
            return player:GetPermanentData( "wedding_at_id" ) and true or false
        end,
    },

    achieve_gen49 = {
        name = "Невероятный гараж",
        description = "Приобрести слот для транспорта в услугах",
        en_name = "incredible_garage",
    },

    achieve_gen50 = {
        name = "Внутренности желудка",
        description = "Переесть 20 раз",
        en_name = "insides_stomach",
        func = function ( self, player )
            player:AddAchievementProgress( self.id, 1 )
            return player:GetAchievementsProgress( self.id ) >= 20
        end,
    },
}

-- sort & add 'id'
ACHIEVEMENTS_SORTED = { }
for id, v in pairs( ACHIEVEMENTS ) do
    v.id = id

    local index = tonumber( string.match( id,"%d+" ) ) or 0
    ACHIEVEMENTS_SORTED[ index ] = v
end