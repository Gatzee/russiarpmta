
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
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 5 and faction == 0
        end,
        rewards =
        {
            { value = 2, type = "donate" },
        },
    },

    ["play_casino"] =
    { 
        id = 2,
        name = "Сыграй в казино",
        condition = function( player )
            return true
        end,
        rewards = 
        {
            { value = 1000, type = "money" },
        },
    },

    ["participate_kb"] =
    { 
        id = 3,
        name = "Поучаствуй в Русской Королевской Битве",
        short_name = "Участвуй в КБ",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 2, type = "donate", first_value = 5 }
        },
    },

    ["start_hunting"] =
    {
        id = 5,
        name = "Начни охоту",
        condition = function( player )
            local playerLevel = player:GetLevel()
            return playerLevel >= 5
        end,
        rewards =
        {
            { value = 1, type = "donate" }
        },
    },

    ["start_fishing"] =
    { 
        id = 6,
        name = "Начни рыбалку",
        condition = function( player )
            local playerLevel = player:GetLevel()
            return playerLevel >= 4
        end,
        rewards =
        {
            { value = 1, type = "donate" }
        },
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
        rewards =
        {
            { value = 2000, type = "money" }
        },
    },

    ["buy_eat"] =
    { 
        id = 8,
        name = "Купи еды",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 1000, type = "money" }
        },
    },

    ["buy_medicine"] =
    { 
        id = 9,
        name = "Купить лекарства",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 1000, type = "money" }
        },
    },

    ["visit_wardrobe"] = 
    { 
        id = 10,
        name = "Посети гардероб",
        condition = function( player )
            local player_apartments = player:HasAnyApartment()
            return player_apartments
        end,
        rewards =
        {
            { value = 1000, type = "money" }
        },
    },

    ["start_kino_list"] = 
    { 
        id = 11,
        name = "Запусти свой плейлист в кинотеатре",
        short_name = "Запусти плейлист в кино",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 2000, type = "money" }
        },
    },

    ["install_inner_vehicle_detail"] = 
    { 
        id = 12,
        name = "Установи деталь на авто во внутреннем тюнинге",
        short_name = "Установи внутреннюю деталь авто",
        condition = function( player )
            local pVehiclesList = player:GetVehicles()
            local IsVehicle = true
            for k, v in pairs( pVehiclesList ) do
                if v.model == 468 then
                    IsVehicle = false
                    break
                end
            end
            return IsVehicle
        end,
        rewards =
        {
            { value = 2, type = "donate" }
        },
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
            return faction ~= 0 and faction ~= F_MEDIC and playerLevel >= 4
        end,
        rewards =
        {
            { value = 1, type = "donate" }
        },
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
        rewards =
        {
            { value = 1, type = "donate" }
        },
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
        rewards =
        {
            { value = 1, type = "donate" }
        },
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
        rewards =
        {
            { value = 1, type = "donate" }
        },
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
        rewards =
        {
            { value = 1, type = "donate" }
        },
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
        rewards =
        {
            { value = 1, type = "donate" }
        },
    },

    ["dps_verify_documents"] = 
    {
        id = 20,
        name = "Проверка документов",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 4 and ( faction == F_POLICE_DPS_NSK or faction == F_POLICE_DPS_GORKI )
        end,
        rewards =
        {
            { value = 1, type = "donate" }
        },
    },

    ["dps_watch_posts"] = 
    {
        id = 21,
        name = "Дежурство на постах",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 4 and ( faction == F_POLICE_DPS_NSK or faction == F_POLICE_DPS_GORKI )
        end,
        rewards =
        {
            { value = 1, type = "donate" }
        },
    },

    ["medic_watch"] = 
    {
        id = 22,
        name = "Дежурство",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 4 and faction == F_MEDIC
        end,
        rewards =
        {
            { value = 1, type = "donate" }
        },
    },

    ["medic_overflow_morgue"] = 
    {
        id = 23,
        name = "Переполнение в морге",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 4 and faction == F_MEDIC
        end,
        rewards =
        {
            { value = 1, type = "donate" }
        },
    },

    ["medic_unload_medicines"] = 
    {
        id = 24,
        name = "Разгрузка медикаментов",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 4 and faction == F_MEDIC
        end,
        rewards =
        {
            { value = 1, type = "donate" }
        },
    },

    ["mayor_agitation"] = 
    {
        id = 25,
        name = "Агитация власти",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 4 and ( faction == F_GOVERNMENT_NSK or faction == F_GOVERNMENT_GORKI )
        end,
        rewards =
        {
            { value = 1, type = "donate" }
        },
    },

    ["mayor_wellfed_city"] = 
    {
        id =  26,
        name = "Сытый город",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 4 and ( faction == F_GOVERNMENT_NSK or faction == F_GOVERNMENT_GORKI )
        end,
        rewards =
        {
            { value = 1, type = "donate" }
        },
    },

    --------------
    --Для бандитов
    --------------

    ["band_kill_opponents"] = 
    {
        id = 27,
        name = "Убей противника банды",
        condition = function( player )
            local band = player:GetBandID()
            local playerLevel = player:GetLevel()
            return band and playerLevel >= 6
        end,
        rewards =
        {
            { value = 1, type = "donate" }
        },
    },

    ["band_join_clan"] = 
    {
        id = 28,
        name = "Вступи в клан",
        condition = function( player )
            local band = player:GetBandID()
            local playerLevel = player:GetLevel()
            local IsInClan = player:GetClanID()
            return band and not IsInClan and playerLevel >= 6
        end,
        rewards =
        {
            { value = 2, type = "donate" }
        },
    },

    ["band_redraw_graffiti"] = 
    {
        id = 29,
        name = "Перекрась граффити",
        condition = function( player )
            local band = player:GetBandID()
            local playerLevel = player:GetLevel()
            return band and playerLevel >= 6
        end,
        rewards =
        {
            { value = 1, type = "donate" }
        },
    },

    ["band_participate_raider_capture"] = 
    {
        id = 30,
        name = "Участвуй в “рейдерском захвате”",
        condition = function( player )
            local band = player:GetBandID()
            local playerLevel = player:GetLevel()
            return band and playerLevel >= 6
        end,
        rewards =
        {
            { value = 3, type = "donate" }
        },
    },

    ["band_start_fight"] = 
    {
        id = 31,
        name = "Устрой драку",
        condition = function( player )
            local band = player:GetBandID()
            local playerLevel = player:GetLevel()
            return band and playerLevel >= 6
        end,
        rewards =
        {
            { value = 1500, type = "money" }
        },
    },

    ["band_get_into_hospital"] = 
    {
        id = 32,
        name = "Попади в больницу",
        condition = function( player )
            local band = player:GetBandID()
            local playerLevel = player:GetLevel()
            return band and playerLevel >= 6
        end,
        rewards =
        {
            { value = 1500, type = "money" }
        },
    },

    ["band_heal_in_hospital"] = 
    {
        id = 33,
        name = "Вылечись в больнице",
        condition = function( player )
            local band = player:GetBandID()
            local playerLevel = player:GetLevel()
            return band and playerLevel >= 6
        end,
        rewards =
        {
            { value = 2, type = "donate" }
        },
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
        rewards =
        {
            { value = 1000, type = "money" }
        },
    },

    ["np_get_new_level"] = 
    {
        id = 36,
        name = "Получи новый уровень",
        condition = function( player )
            local playerLevel = player:GetLevel()
            return playerLevel >= 2 and playerLevel <= 4
        end,
        rewards =
        {
            { value = 3, type = "donate" }
        },
    },

    ["np_get_b_rights"] = 
    {
        id = 37,
        name = "Получи права B",
        condition = function( player )
            local playerLevel = player:GetLevel()
            return not player:HasLicense( LICENSE_TYPE_AUTO ) and player:GetMoney() >= 19000 and playerLevel >= 2
        end,
        max_execution = 1,
        rewards =
        {
            { value = 3, type = "donate" }
        },
    },

        --Дополнительные
    ["np_visit_dance_school"] = 
    {
        id = 38,
        name = "Посети школу танцев",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 1, type = "donate", first_value = 2 }
        },
    },

    ["np_visit_cloth_shop"] = 
    {
        id = 39,
        name = "Посети магазин одежды",
        condition = function( player )
            local playerLevel = player:GetLevel()
            return playerLevel >= 10
        end,
        rewards =
        {
            { value = 1, type = "donate", first_value = 2 }
        },
    },

    ["np_visit_car_showroom"] = 
    {
        id = 40,
        name = "Посети автосалон (Любой)",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 1, type = "donate", first_value = 2 }
        },
    },

    ["np_visit_kino"] = 
    {
        id = 41,
        name = "Посети кинотеатр",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 1, type = "donate", first_value = 2 }
        },
    },

    ["np_visit_autoschool"] = 
    {
        id = 42,
        name = "Посети автошколу",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 1, type = "donate", first_value = 2 }
        },
    },

    ["np_visit_airshow"] = 
    {
        id = 43,
        name = "Посети авиасалон",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 1, type = "donate", first_value = 2 }
        },
    },

    ["np_visit_shipyard"] = 
    {
        id = 44,
        name = "Посети верфь",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 1, type = "donate", first_value = 2 }
        },
    },

    ["np_visit_exchange"] = 
    {
        id = 45,
        name = "Посети биржу",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 1, type = "donate", first_value = 2 }
        },
    },

    ["np_visit_pps"] = 
    {
        id = 46,
        name = "Посети ППС",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 2, type = "donate", first_value = 4 }
        },
    },

    ["np_visit_dps"] = 
    {
        id = 47,
        name = "Посети ДПС",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 2, type = "donate", first_value = 4 }
        },
    },

    ["np_visit_hospital"] = 
    {
        id = 48,
        name = "Посети больницу",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 2, type = "donate", first_value = 4 }
        },
    },

    ["np_visit_mayor"] = 
    {
        id = 49,
        name = "Посети мэрию",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 2, type = "donate", first_value = 4 }
        },
    },

    ["np_visit_apartament"] = 
    {
        id = 50,
        name = "Посети квартиру",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 1, type = "donate", first_value = 2 }
        },
    },

    ["np_use_taxi"] = 
    {
        id = 51,
        name = "Воспользуйся такси",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 2, type = "donate", first_value = 3 }
        },
    },

    ["np_join_band"] = 
    {
        id = 52,
        name = "Вступи в банду",
        condition = function( player )
            local band = player:GetBandID()
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            return playerLevel >= 6 and faction == 0 and not band
        end,
        max_execution = 1,
        rewards =
        {
            { value = 3, type = "donate", first_value = 6 }
        },
    },

    ["np_join_faction"] = 
    {
        id = 53,
        name = "Вступи во фракцию",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local band = player:GetBandID()
            local millitary_ticker = player:HasMilitaryTicket()
            local faction = player:GetFaction()
            return playerLevel >= 4 and not band and millitary_ticker and faction == 0
        end,
        max_execution = 1,
        rewards =
        {
            { value = 4, type = "donate", first_value = 8 }
        },
    },

    ["np_get_rp_certificate"] = 
    {
        id = 54,
        name = "Получи РП аттестат",
        condition = function( player )
            local playerLevel = player:GetLevel()
            local faction = player:GetFaction()
            local hasCert = player:HasRPCert() 
            return playerLevel >= 3 and faction == 0 and not hasCert
        end,
        max_execution = 1,
        rewards =
        {
            { value = 4, type = "donate", first_value = 8 }
        },
    },

    ["find_treasure"] =
    { 
        id = 55,
        name = "Найди сокровище",
        condition = function( player )
            local playerLevel = player:GetLevel()
            return playerLevel >= 7
        end,
        rewards =
        {
            { value = 1, type = "donate", first_value = 2 }
        },
    },

    ["participate_race"] =
    { 
        id = 56,
        name = "Поучаствуй в гонках",
        condition = function( player )
            local pVehiclesList = player:GetVehicles()
            local IsVehicle = true
            for k, v in pairs( pVehiclesList ) do
                if v.model == 468 then
                    IsVehicle = false
                    break
                end
            end
            return IsVehicle
        end,
        rewards =
        {
            { value = 2, type = "donate", first_value = 4 }
        },
    },

    ["try_accessoaries"] =
    { 
        id = 57,
        name = "Примерь аксессуар",
        condition = function( player )
            return true
        end,
        rewards =
        {
            { value = 1, type = "donate", first_value = 2 }
        },
    },

    ["np_view_cloth_shop"] = 
    {
        id = 58,
        name = "Осмотри магазин одежды",
        condition = function( player )
            local playerLevel = player:GetLevel()
            return playerLevel < 10
        end,
        rewards =
        {
            { value = 1000, type = "money" }
        },
    },
}

for k, v in pairs( DAILY_QUEST_LIST ) do
    table.insert( QUEST_NAMES, k )
end