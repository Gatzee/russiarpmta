-- 0xFF87ea9a -- green
-- 0xFFe73f5e -- purple

-- Подвалы
CLAN_BASEMENT_MARKER_CONFIGS = {
    { base_id = 1, name = "Горки-Город"    , x =  1989.057, y = -914.8650 + 860, z = 57.23  },
    { base_id = 2, name = "г.Новороссийск" , x = -205.5430, y = -1828.477 + 860, z = 17.591 },
    { base_id = 3, name = "Подмосковье"    , x = -47.15200, y =  552.2150 + 860, z = 17.467 },

    { base_id = 4, name = "Зап. Картель"   , x = -2010.402, y = 674.52300 + 860, z = 18.485, cartel_id = 1 },
    { base_id = 5, name = "Вост. Картель"  , x =  1918.068, y = -2219.493 + 860, z = 31.596, cartel_id = 2 },
}

CLAN_BASEMENT_ENTERS = {
    { x = -59.1020, y = 552.07100 + 860, z = 20.917 },
    { x = 1999.281, y = -910.1900 + 860, z = 60.662 },
    { x = -205.355, y = -1816.956 + 860, z = 21.019 },
}

CARTEL_NAMES = {
    "Зап. Картель",
    "Вост. Картель",
}

CLAN_CREATION_COST = 5000000
CLAN_WAY_CHANGE_COST = 5000000

CLANTAGS_AMOUNT = 60

enum "CLAN_WAYS" {
    "CLAN_WAY_BIKERS",
    "CLAN_WAY_RACERS",
    "CLAN_WAY_BRATVA",
}

CLAN_WAY_NAMES = {
    "Байкеры",
    "Стрит-Рейсеры",
    "Братва из 90-х",
}

CLAN_WAY_DESCRIPTION = {
    "Бандиты, которые испытывают невероятную верность своему клану, так и любовь транспорту, а именно мотоциклам. За счет чего весь путь развития направлен в сторону их техники и поддержки друг друга. Также имеют увеличенные показатели жизней.",
    "Бандиты, которые готовы на все ради скорости. Эта жажда выливается в доступность полного тюнинга машин. Дабы превратить простой кусок железа в безбашенное воплощение адреналина.",
    "Бандиты, которые полагаются на вооружение. Договор с барыгой позволяет им иметь поставки оружия по особым ценам. Также обладают связями в правоохранительных органах, что позволяет сократить срок пребывания за решеткой.",
}

CLAN_WAY_KEYS = {
    "bikers",
    "streetracers",
    "bratva",
}

CLAN_BASE_KEYS_BY_ID = {
    "gorkygorod",
    "novoros",
    "podmsk",
}

-- Анлоки в кланах
enum "eClanUnlocks" {
	"UNLOCK_MODES_ACCESS",
	"UNLOCK_CLAN_CREATION",
	"UNLOCK_WEAPON_SPRAY_CAN",
	"UNLOCK_WEAPON_GLOCK",
	"UNLOCK_WEAPON_RIFLE",
	"UNLOCK_WEAPON_SHOTGUN",
	"UNLOCK_WEAPON_SAWEDOFF",
	"UNLOCK_WEAPON_MP5",
	"UNLOCK_WEAPON_UZI",
	"UNLOCK_WEAPON_AK47",
	"UNLOCK_WEAPON_M4",
	"UNLOCK_WEAPON_DEAGLE",
	"UNLOCK_WEAPON_SNIPER",
	"UNLOCK_SKIN_160",
	"UNLOCK_SKIN_22",
	"UNLOCK_SKIN_165",
	"UNLOCK_SKIN_23",
	"UNLOCK_SKIN_195",
	"UNLOCK_SKIN_21",
	"UNLOCK_SKIN_159",
	"UNLOCK_SKIN_20",
	"UNLOCK_CATEGORY_SEASON_WINNER",
	"UNLOCK_CLAN_SEASON_WINNER",
	"UNLOCK_CLAN_CREATION_PAID",
	"UNLOCK_SKIN_258",
	"UNLOCK_SKIN_259",
	"UNLOCK_SKIN_260",
    "UNLOCK_SKIN_262",
}

CLAN_RANKS = {
	-- 1
	{
		required_exp = 0,
		unlocks = { },

		fn_OnReached = function( player )
			player:ShowNotification( "Добро пожаловать в клан!" )
			player:InventoryAddItem( IN_WEAPON, { 41 }, 3 )
		end,
	},
	-- 2
	{
		required_exp = 5000,
		unlocks = { },

		fn_OnReached = function( player )
			player:InventoryAddItem( IN_WEAPON, { 22 }, 1 )
		end,
	},
	-- 3
	{
		required_exp = 10000,
		unlocks = { },

		fn_OnReached = function( player )
			player:InventoryAddItem( IN_WEAPON, { 29 }, 1 )
		end,
	},
	-- 4
	{
		required_exp = 25000,
		skins = { 
            [ CLAN_WAY_RACERS ] = 198,
            [ CLAN_WAY_BIKERS ] = 81,
            [ CLAN_WAY_BRATVA ] = 115,
        },
	},
	-- 5
	{
		required_exp = 50000,
		unlocks = { },

		fn_OnReached = function( player )
			player:InventoryAddItem( IN_WEAPON, { 34 }, 1 )
		end,
	},
	-- 6
	{
		required_exp = 75000,
		unlocks = { },

		fn_OnReached = function( player )
			player:InventoryAddItem( IN_WEAPON, { 24 }, 1 )
		end,
	},
	-- 7
	{
		required_exp = 100000,
		unlocks = { },

		fn_OnReached = function( player )
			player:InventoryAddItem( IN_WEAPON, { 30 }, 1 )
		end,
	},
	-- 8
	{
		required_exp = 150000,
		skins = {
            [ CLAN_WAY_RACERS ] = 205,
            [ CLAN_WAY_BIKERS ] = 107,
            [ CLAN_WAY_BRATVA ] = 143,
        },
	},
	-- 9
	{
		required_exp = 200000,
		unlocks = { },

		fn_OnReached = function( player )
			player:InventoryAddItem( IN_WEAPON, { 29, 150 }, 1 )
			player:InventoryAddItem( IN_WEAPON, { 30, 150 }, 1 )
			player:InventoryAddItem( IN_WEAPON, { 34, 30 }, 1 )
		end,
	},
	-- 10
	{
		required_exp = 250000,
		skins = {
            [ CLAN_WAY_RACERS ] = 176,
            [ CLAN_WAY_BIKERS ] = 103,
            [ CLAN_WAY_BRATVA ] = 283,
        },
	},
}

UNLOCK_NEED_RANKS = { }
for rank, data in pairs( CLAN_RANKS ) do
    for i, unlock in pairs( data.unlocks or { } ) do
        UNLOCK_NEED_RANKS[ unlock ] = rank
    end
end

TAG_IMAGES = {
    [ -1 ] = "img/tags/band/-1.png",
	[ -2 ] = "img/tags/band/-2.png",
	[ -3 ] = "img/tags/band/-3.png",
    [ -4 ] = "img/tags/band/-4.png",

    "img/tags/band/1.png",
    "img/tags/band/2.png",
    "img/tags/band/3.png",
    "img/tags/band/4.png",
    "img/tags/band/5.png",
    "img/tags/band/6.png",
    "img/tags/band/7.png",
    "img/tags/band/8.png",
    "img/tags/band/9.png",
    "img/tags/band/10.png",
    "img/tags/band/11.png",
    "img/tags/band/12.png",
    "img/tags/band/13.png",
    "img/tags/band/14.png",
    "img/tags/band/15.png",
    "img/tags/band/16.png",
    "img/tags/band/17.png",
    "img/tags/band/18.png",
    "img/tags/band/19.png",
    "img/tags/band/20.png",
    "img/tags/band/21.png",
    "img/tags/band/22.png",
    "img/tags/band/23.png",
    "img/tags/band/24.png",
    "img/tags/band/25.png",
    "img/tags/band/26.png",
    "img/tags/band/27.png",
    "img/tags/band/28.png",
    "img/tags/band/29.png",
    "img/tags/band/30.png",
    "img/tags/band/31.png",
    "img/tags/band/32.png",
    "img/tags/band/33.png",
    "img/tags/band/34.png",
    "img/tags/band/35.png",
    "img/tags/band/36.png",
    "img/tags/band/37.png",
    "img/tags/band/38.png",
    "img/tags/band/39.png",
    "img/tags/band/40.png",
    "img/tags/band/41.png",
    "img/tags/band/42.png",
    "img/tags/band/43.png",
    "img/tags/band/44.png",
    "img/tags/band/45.png",
    "img/tags/band/46.png",
    "img/tags/band/47.png",
    "img/tags/band/48.png",
    "img/tags/band/49.png",
    "img/tags/band/50.png",
    "img/tags/band/51.png",
    "img/tags/band/52.png",
    "img/tags/band/53.png",
    "img/tags/band/54.png",
    "img/tags/band/55.png",
    "img/tags/band/56.png",
    "img/tags/band/57.png",
    "img/tags/band/58.png",
    "img/tags/band/59.png",
    "img/tags/band/60.png",
}

enum "CLAN_ROLES" {
    "CLAN_ROLE_JUNIOR",
    "CLAN_ROLE_MIDDLE",
    "CLAN_ROLE_SENIOR",
    "CLAN_ROLE_MODERATOR",
    "CLAN_ROLE_LEADER",
}

CLAN_ROLES_NAMES = {
    [ CLAN_ROLE_JUNIOR ] = "Младший",
    [ CLAN_ROLE_MIDDLE ] = "Местный",
    [ CLAN_ROLE_SENIOR ] = "Старший",
    [ CLAN_ROLE_MODERATOR ] = "Модератор",
    [ CLAN_ROLE_LEADER ] = "Лидер",
}

CLAN_ROLES_PLAYERS_LIMIT = {
    [ CLAN_ROLE_SENIOR ] = 10,
    [ CLAN_ROLE_MODERATOR ] = 3,
    -- [ CLAN_ROLE_LEADER ] = 1,
}

CLAN_SEASON_REWARDS = {
    [ 1 ] = {
        clan = {
            -- { type = "money", count = 100000 },
            { type = "weapon", id = 30, count = 10 },
            { type = "weapon", id = 29, count = 5 },
            { type = "weapon", id = 34, count = 2 },
        },
        members = {
            { type = "money", count = 100000 },
            { type = "weapon", id = 24, count = 1 },
            { type = "weapon", id = 41, count = 5 },
        },
    },
    [ 2 ] = {
        clan = {
            -- { type = "money", count = 80000 },
            { type = "weapon", id = 30, count = 8 },
            { type = "weapon", id = 29, count = 3 },
            { type = "weapon", id = 34, count = 1 },
        },
        members = {
            { type = "money", count = 50000 },
            { type = "weapon", id = 24, count = 1 },
            { type = "weapon", id = 41, count = 4 },
        },
    },
    [ 3 ] = {
        clan = {
            -- { type = "money", count = 60000 },
            { type = "weapon", id = 30, count = 5 },
            { type = "weapon", id = 29, count = 2 },
            { type = "weapon", id = 34, count = 1 },
        },
        members = {
            { type = "money", count = 30000 },
            { type = "weapon", id = 29, count = 1 },
            { type = "weapon", id = 41, count = 3 },
        },
    },
    [ 4 ] = {
        clan = {
            -- { type = "money", count = 40000 },
            { type = "weapon", id = 29, count = 8 },
            { type = "weapon", id = 34, count = 1 },
            { type = "weapon", id = 22, count = 5 },
        },
        members = {
            { type = "money", count = 20000 },
            { type = "weapon", id = 29, count = 1 },
            { type = "weapon", id = 41, count = 2 },
        },
    },
    [ 6 ] = {
        clan = {
            -- { type = "money", count = 30000 },
            { type = "weapon", id = 29, count = 5 },
            { type = "weapon", id = 34, count = 1 },
            { type = "weapon", id = 22, count = 3 },
        },
        members = {
            { type = "money", count = 10000 },
            { type = "weapon", id = 22, count = 1 },
            { type = "weapon", id = 41, count = 1 },
        },
    },
}
CLAN_SEASON_REWARDS[ 5 ] = CLAN_SEASON_REWARDS[ 4 ]
CLAN_SEASON_REWARDS[ 7 ] = CLAN_SEASON_REWARDS[ 6 ]
CLAN_SEASON_REWARDS[ 8 ] = CLAN_SEASON_REWARDS[ 6 ]

enum "CLAN_EVENTS" {
    "CLAN_EVENT_DEATHMATCH",
    "CLAN_EVENT_HOLDAREA",
    -- "CLAN_EVENT_CAPTURE_POINTS",

    "CLAN_EVENT_CARTEL_CAPTURE",
    "CLAN_EVENT_CARTEL_TAX_WAR",
}

CLAN_EVENTS_NAMES = {
    [ CLAN_EVENT_DEATHMATCH ] = "Смертельный матч",
    [ CLAN_EVENT_HOLDAREA ] = "Рейдерский захват",
    -- [ CLAN_EVENT_CAPTURE_POINTS ] = "Захват 3 флагов",
    [ CLAN_EVENT_CARTEL_CAPTURE ] = "Война за дом Картеля",
    [ CLAN_EVENT_CARTEL_TAX_WAR ] = "Война за общак",
}

enum "CLAN_UPGRADES" {
	"CLAN_UPGRADE_SLOTS",
	"CLAN_UPGRADE_STORAGE",
	"CLAN_UPGRADE_WAY",
	"CLAN_UPGRADE_ALCO_FACTORY",
    "CLAN_UPGRADE_HASH_FACTORY",
    
    "CLAN_UPGRADE_MAX_HP",
    "CLAN_UPGRADE_HEALING",
    "CLAN_UPGRADE_MOTO_DISCOUNT",
    "CLAN_UPGRADE_GROUP_MAX_HP",
    "CLAN_UPGRADE_HASH_DRYING_TIME",
    "CLAN_UPGRADE_MAX_HP_2",
    "CLAN_UPGRADE_HASH_SALE_COST",
    "CLAN_UPGRADE_MAX_STAMINA",
    "CLAN_UPGRADE_DRUGS_DISCOUNT",
    "CLAN_UPGRADE_TUNING_DISCOUNT",
    "CLAN_UPGRADE_FIST_DAMAGE",
    "CLAN_UPGRADE_DISEASE_RESISTANCE",
    "CLAN_UPGRADE_MAX_STAMINA_2",
    "CLAN_UPGRADE_DRUGS_TIME",
    "CLAN_UPGRADE_JAIL_TIME",
    "CLAN_UPGRADE_SLOW_HUNGER",
    "CLAN_UPGRADE_WEAPON_DISCOUNT",
    "CLAN_UPGRADE_MAX_HP_AND_STAMINA",
    "CLAN_UPGRADE_ALCO_FERMENT_TIME",
    "CLAN_UPGRADE_JAIL_TIME_2",
    "CLAN_UPGRADE_ALCO_SALE_COST",
}

CLAN_UPGRADES_LIST = 
{
	[ CLAN_UPGRADE_SLOTS ] = {
        key = "members_limit",
		[ 1 ] = {
			cost = 500000,
			apply = function( clan )
				clan:AddSlots( 25 )
			end,
		},
		[ 2 ] = {
			cost = 1000000,
			apply = function( clan )
				clan:AddSlots( 25 )
			end,
		},
		[ 3 ] = {
			cost = 2500000,
			apply = function( clan )
				clan:AddSlots( 25 )
			end,
		},
		[ 4 ] = {
			cost = 5000000,
			apply = function( clan )
				clan:AddSlots( 25 )
			end,
		},
		[ 5 ] = {
			cost = 7500000,
			apply = function( clan )
				clan:AddSlots( 25 )
			end,
		},
	},

	[ CLAN_UPGRADE_STORAGE ] = {
        key = "clan_box",
		[ 1 ] = {
			cost = 1000000,
			apply = function( clan )
				clan:SetPermanentData( "storage", { } )
			end,
		},
	},

	[ CLAN_UPGRADE_ALCO_FACTORY ] = {
        name = "Алко-Цех",
        product_type = "alco",
        key = "alco_production",
		[ 1 ] = {
			cost = 500000,
			apply = function( clan )
				clan:SetPermanentData( "alco_factory", { } )
			end,
		},
		[ 2 ] = {
			cost = 1000000,
		},
		[ 3 ] = {
			cost = 2500000,
		},
		[ 4 ] = {
			cost = 5000000,
		},
		[ 5 ] = {
			cost = 8000000,
		},
		[ 6 ] = {
			cost = 12000000,
		},
		[ 7 ] = {
			cost = 20000000,
		},
	},

	[ CLAN_UPGRADE_HASH_FACTORY ] = {
        name = "Цех-Петрушки",
        product_type = "hash",
        key = "hash_production",
		[ 1 ] = {
			cost = 500000,
			apply = function( clan )
				clan:SetPermanentData( "hash_factory", { } )
			end,
		},
		[ 2 ] = {
			cost = 1000000,
		},
		[ 3 ] = {
			cost = 2500000,
		},
		[ 4 ] = {
			cost = 5000000,
		},
		[ 5 ] = {
			cost = 8000000,
		},
		[ 6 ] = {
			cost = 12000000,
		},
		[ 7 ] = {
			cost = 20000000,
		},
    },

    -- Ветка байкеров
    
	[ CLAN_UPGRADE_MAX_HP ] = {
        name = "Кожаная броня",
        desc = "Увеличение максимального запаса здоровья на %s ед.",
        key = "increase_max_hp",
        buff_id = "max_health",
		[ 1 ] = {
            cost = 200000,
            buff_add_value = 5,
		},
		[ 2 ] = {
			cost = 400000,
            buff_add_value = 5,
		},
		[ 3 ] = {
			cost = 800000,
            buff_add_value = 5,
		},
		[ 4 ] = {
			cost = 1000000,
            buff_add_value = 10,
		},
    },
    
	[ CLAN_UPGRADE_HEALING ] = {
        name = "Анаболизм",
        desc = "Увеличение объема восстановления здоровья от аптечек и наркотиков на %s%%",
        key = "increase_healing",
		[ 1 ] = {
			cost = 200000,
            buff_add_value = 5,
		},
		[ 2 ] = {
			cost = 400000,
            buff_add_value = 5,
		},
		[ 3 ] = {
			cost = 800000,
            buff_add_value = 5,
		},
		[ 4 ] = {
			cost = 1000000,
            buff_add_value = 10,
		},
    },
    
	[ CLAN_UPGRADE_MOTO_DISCOUNT ] = {
        name = "Скидка на мотоциклы",
        desc = "Скидка %s%% на мотоциклы из салонов",
        key = "moto_discount",
		[ 1 ] = {
			cost = 1500000,
            buff_add_value = 5,
		},
		[ 2 ] = {
			cost = 3000000,
            buff_add_value = 5,
		},
		[ 3 ] = {
			cost = 4500000,
            buff_add_value = 5,
		},
    },
    
	[ CLAN_UPGRADE_GROUP_MAX_HP ] = {
        name = "Брат за брата",
        desc = "От 3 сокланцев вместе повышается максимальное кол-во здоровья на %s ед. (радиус 100 метров)",
        key = "group_hp_increase",
		[ 1 ] = {
			cost = 400000,
            buff_add_value = 5,
		},
		[ 2 ] = {
			cost = 800000,
            buff_add_value = 5,
		},
		[ 3 ] = {
			cost = 1600000,
            buff_add_value = 5,
		},
		[ 4 ] = {
			cost = 2000000,
            buff_add_value = 10,
		},
    },
    
	[ CLAN_UPGRADE_HASH_DRYING_TIME ] = {
        name = "Выжимание соков",
        desc = "Уменьшение времени сушки петрушки на %s с",
        key = "fast_hash_drying",
		[ 1 ] = {
			cost = 400000,
            buff_add_value = 30,
		},
		[ 2 ] = {
			cost = 800000,
            buff_add_value = 30,
		},
		[ 3 ] = {
			cost = 1600000,
            buff_add_value = 60,
		},
		[ 4 ] = {
			cost = 2000000,
            buff_add_value = 60,
		},
    },
    
	[ CLAN_UPGRADE_MAX_HP_2 ] = {
        name = "Здоровье как у байкера",
        desc = "Увеличение максимального запаса здоровья на %s ед.",
        key = "increase_max_hp_2",
        img = "increase_max_hp",
        buff_id = "max_health",
        dupblicate = CLAN_UPGRADE_MAX_HP,
		[ 1 ] = {
			cost = 600000,
            buff_add_value = 5,
		},
		[ 2 ] = {
			cost = 1200000,
            buff_add_value = 5,
		},
		[ 3 ] = {
			cost = 2400000,
            buff_add_value = 5,
		},
		[ 4 ] = {
			cost = 3000000,
            buff_add_value = 10,
		},
    },
    
	[ CLAN_UPGRADE_HASH_SALE_COST ] = {
        name = "Свежая петрушка",
        desc = "Повышение стоимости оптовой продажи петрушки на %s%%",
        key = "increase_hash_cost",
		[ 1 ] = {
			cost = 600000,
            buff_add_value = 3,
		},
		[ 2 ] = {
			cost = 1200000,
            buff_add_value = 3,
		},
		[ 3 ] = {
			cost = 2400000,
            buff_add_value = 3,
		},
		[ 4 ] = {
			cost = 3000000,
            buff_add_value = 4,
		},
    },

    -- Ветка стрит-рейсеров
    
	[ CLAN_UPGRADE_MAX_STAMINA ] = {
        name = "Бей или беги",
        desc = "Увеличение максимального запаса выносливости на %s ед.",
        key = "increase_stamina",
        buff_id = "max_stamina",
		[ 1 ] = {
			cost = 200000,
            buff_add_value = 5,
		},
		[ 2 ] = {
			cost = 400000,
            buff_add_value = 5,
		},
		[ 3 ] = {
			cost = 800000,
            buff_add_value = 5,
		},
		[ 4 ] = {
			cost = 1000000,
            buff_add_value = 10,
		},
    },

    [ CLAN_UPGRADE_DRUGS_DISCOUNT ] = {
        name = "Цена кайфа",
        desc = "Уменьшение стоимости веществ у барыги на %s%%",
        key = "drugs_discount",
		[ 1 ] = {
			cost = 200000,
            buff_add_value = 2,
		},
		[ 2 ] = {
			cost = 400000,
            buff_add_value = 2,
		},
		[ 3 ] = {
			cost = 800000,
            buff_add_value = 2,
		},
		[ 4 ] = {
			cost = 1000000,
            buff_add_value = 2,
		},
    },

    [ CLAN_UPGRADE_TUNING_DISCOUNT ] = {
        name = "Скидка на тюнинг",
        desc = "Скидка %s%% на тюнинг транспорта",
        key = "tuning_discount",
		[ 1 ] = {
			cost = 1500000,
            buff_add_value = 5,
		},
		[ 2 ] = {
			cost = 3000000,
            buff_add_value = 5,
		},
		[ 3 ] = {
			cost = 4500000,
            buff_add_value = 5,
		},
    },

    [ CLAN_UPGRADE_FIST_DAMAGE ] = {
        name = "Мощь ударов",
        desc = "Увеличение урона от ударов на %s ед.",
        key = "increase_fist_damage",
		[ 1 ] = {
			cost = 400000,
            buff_add_value = 1,
		},
		[ 2 ] = {
			cost = 800000,
            buff_add_value = 1,
		},
		[ 3 ] = {
			cost = 1600000,
            buff_add_value = 1,
		},
		[ 4 ] = {
			cost = 2000000,
            buff_add_value = 2,
		},
    },

    [ CLAN_UPGRADE_DISEASE_RESISTANCE ] = {
        name = "Предел дозы",
        desc = "Устойчивость к болезням \"Наркомания\" и \"Алкоголизм\" на %s ед.",
        key = "disease_resistance",
		[ 1 ] = {
			cost = 400000,
            buff_add_value = 5,
		},
		[ 2 ] = {
			cost = 800000,
            buff_add_value = 5,
		},
		[ 3 ] = {
			cost = 1600000,
            buff_add_value = 5,
		},
		[ 4 ] = {
			cost = 2000000,
            buff_add_value = 25,
            desc = "Устойчивость к болезням \"Наркомания\" и \"Алкоголизм\" на %s ед.\nВремя между приемами веществ снижено до 60 c",
		},
    },

    [ CLAN_UPGRADE_MAX_STAMINA_2 ] = {
        name = "Бей и беги",
        desc = "Увеличение максимального запаса выносливости на %s ед.",
        key = "increase_stamina_2",
        img = "increase_stamina",
        buff_id = "max_stamina",
        dupblicate = CLAN_UPGRADE_MAX_STAMINA,
		[ 1 ] = {
			cost = 600000,
            buff_add_value = 5,
		},
		[ 2 ] = {
			cost = 1200000,
            buff_add_value = 5,
		},
		[ 3 ] = {
			cost = 2400000,
            buff_add_value = 5,
		},
		[ 4 ] = {
			cost = 3000000,
            buff_add_value = 10,
		},
    },

    [ CLAN_UPGRADE_DRUGS_TIME ] = {
        name = "Стойкость кайфа",
        desc = "Увеличение времени действия веществ от барыги на %s%%",
        key = "increase_drugs_time",
		[ 1 ] = {
			cost = 600000,
            buff_add_value = 15,
		},
		[ 2 ] = {
			cost = 1200000,
            buff_add_value = 15,
		},
		[ 3 ] = {
			cost = 2400000,
            buff_add_value = 15,
		},
		[ 4 ] = {
			cost = 3000000,
            buff_add_value = 15,
		},
    },

    -- Ветка братьев

    [ CLAN_UPGRADE_JAIL_TIME ] = {
        name = "Связи",
        desc = "Уменьшение срока в КПЗ/Тюрьме на %s%%",
        key = "reduce_jail_time",
		[ 1 ] = {
			cost = 200000,
            buff_add_value = 5,
		},
		[ 2 ] = {
			cost = 400000,
            buff_add_value = 5,
		},
		[ 3 ] = {
			cost = 800000,
            buff_add_value = 5,
		},
		[ 4 ] = {
			cost = 1000000,
            buff_add_value = 10,
		},
    },
    [ CLAN_UPGRADE_SLOW_HUNGER ] = {
        name = "Контроль голода",
        desc = "Калории тратятся медленнее на %s%%",
        key = "slowing_down_hunger",
		[ 1 ] = {
			cost = 200000,
            buff_add_value = 10,
		},
		[ 2 ] = {
			cost = 400000,
            buff_add_value = 10,
		},
		[ 3 ] = {
			cost = 800000,
            buff_add_value = 10,
		},
		[ 4 ] = {
			cost = 1000000,
            buff_add_value = 10,
		},
    },
    [ CLAN_UPGRADE_WEAPON_DISCOUNT ] = {
        name = "Скидка на оружие",
        desc = "Скидка на оружие у барыги %s%%",
        key = "weapon_discount",
		[ 1 ] = {
			cost = 1500000,
            buff_add_value = 5,
		},
		[ 2 ] = {
			cost = 3000000,
            buff_add_value = 5,
		},
		[ 3 ] = {
			cost = 4500000,
            buff_add_value = 5,
		},
    },
    [ CLAN_UPGRADE_MAX_HP_AND_STAMINA ] = {
        name = "Армейская закалка",
        desc = "Повышение здоровья и выносливости на %s ед.",
        key = "increase_stats",
		[ 1 ] = {
			cost = 400000,
            buff_add_value = 2,
		},
		[ 2 ] = {
			cost = 800000,
            buff_add_value = 2,
		},
		[ 3 ] = {
			cost = 1600000,
            buff_add_value = 2,
		},
		[ 4 ] = {
			cost = 2000000,
            buff_add_value = 4,
		},
    },
    [ CLAN_UPGRADE_ALCO_FERMENT_TIME ] = {
        name = "Химия алкоголя",
        desc = "Уменьшение времени брожение алкоголя на %s с",
        key = "fast_alco_fermentation",
		[ 1 ] = {
			cost = 400000,
            buff_add_value = 30,
		},
		[ 2 ] = {
			cost = 800000,
            buff_add_value = 30,
		},
		[ 3 ] = {
			cost = 1600000,
            buff_add_value = 60,
		},
		[ 4 ] = {
			cost = 2000000,
            buff_add_value = 60,
		},
    },
    [ CLAN_UPGRADE_JAIL_TIME_2 ] = {
        name = "Вне закона",
        desc = "Уменьшение срока в КПЗ/Тюрьме на %s%%",
        key = "reduce_jail_time_2",
        img = "reduce_jail_time",
        dupblicate = CLAN_UPGRADE_JAIL_TIME,
		[ 1 ] = {
			cost = 600000,
            buff_add_value = 5,
		},
		[ 2 ] = {
			cost = 1200000,
            buff_add_value = 5,
		},
		[ 3 ] = {
			cost = 2400000,
            buff_add_value = 5,
		},
		[ 4 ] = {
			cost = 3000000,
            buff_add_value = 10,
		},
    },
    [ CLAN_UPGRADE_ALCO_SALE_COST ] = {
        name = "Алкобизнес",
        desc = "Повышение стоимости оптовой продажи алкоголя на %s%%",
        key = "increase_alco_cost",
		[ 1 ] = {
			cost = 600000,
            buff_add_value = 3,
		},
		[ 2 ] = {
			cost = 1200000,
            buff_add_value = 3,
		},
		[ 3 ] = {
			cost = 2400000,
            buff_add_value = 3,
		},
		[ 4 ] = {
			cost = 3000000,
            buff_add_value = 4,
		},
    },
}

for i, upgrade_conf in pairs( CLAN_UPGRADES_LIST ) do
    if upgrade_conf[ 1 ].buff_add_value then
        local buff_value = 0
        for i, lvl_conf in ipairs( upgrade_conf ) do
            buff_value = buff_value + lvl_conf.buff_add_value
            lvl_conf.buff_value = buff_value
        end
    end
end

FACTORY_UPGRADES = {
    { -- 1
        quality_chances = { 80, 15, 5 },
        money_bonus = 0,
        making_time = 20 * 60,
        max_slots = 5,
        need_count_for_batch = 50,
    },
    { -- 2
        quality_chances = { 70, 20, 10 },
        money_bonus = 0.05,
        making_time = 18 * 60,
        max_slots = 7,
        need_count_for_batch = 80,
    },
    { -- 3
        quality_chances = { 60, 25, 15 },
        money_bonus = 0.10,
        making_time = 16 * 60,
        max_slots = 10,
        need_count_for_batch = 120,
    },
    { -- 4
        quality_chances = { 50, 30, 20 },
        money_bonus = 0.15,
        making_time = 14 * 60,
        max_slots = 12,
        need_count_for_batch = 180,
    },
    { -- 5
        quality_chances = { 40, 35, 25 },
        money_bonus = 0.20,
        making_time = 12 * 60,
        max_slots = 15,
        need_count_for_batch = 250,
    },
    { -- 6
        quality_chances = { 30, 40, 30 },
        money_bonus = 0.30,
        making_time = 10 * 60,
        max_slots = 17,
        need_count_for_batch = 350,
    },
    { -- 7
        quality_chances = { 10, 50, 40 },
        money_bonus = 0.40,
        making_time = 8 * 60,
        max_slots = 20,
        need_count_for_batch = 500,
    },
}

MAX_BATCHES_COUNT_IN_DAY = 3

enum "CLAN_LOG_MESSAGES_TYPES" {
    "CLAN_LOG_ADD_MONEY",
    "CLAN_LOG_UPGRADE",
    "CLAN_LOG_ITEMS_PURCHASE",
    "CLAN_LOG_CHANGE_WAY",
}

enum "LEADERBOARD_CLAN_DATA_FIELDS" {
    "LB_CLAN_ID",
    -- "LB_CLAN_NAME",
    "LB_CLAN_MONEY",
    "LB_CLAN_HONOR",
    "LB_CLAN_SCORE",
    "LB_CLAN_SLOTS",
    "LB_CLAN_MEMBERS_COUNT",
    "LB_CLAN_IS_CLOSED",
    "LB_CLAN_TAG",
}

enum "CARTEL_TAX_CLANS_LIST_FIELDS" {
    "CT_CLAN_ID",
    "CT_CLAN_MONEY",
    "CT_CLAN_SCORE",
    "CT_CLAN_SLOTS",
    "CT_CLAN_MEMBERS_COUNT",
    "CT_CLAN_TAX_STATUS",
    "CT_CLAN_TAX_WAIT_UNTIL_DATE",
}

enum "CARTEL_TAX_LOG_FIELDS" {
    "CT_LOG_CLAN_NAME",
    "CT_LOG_DATE",
    "CT_LOG_TAX_STATUS",
    "CT_LOG_VALUE",
}

enum "CARTEL_TAX_STATUS" {
    "CARTEL_TAX_NOT_REQUESTED", -- Налог не запрашивался
    "CARTEL_TAX_WAITING", -- Ожидание ответа
    "CARTEL_TAX_OTHER_WAITING", -- Другой картель запросил налог
    "CARTEL_TAX_PAYED", -- Оплачено
    "CARTEL_TAX_REFUSED", -- Отказ платить
    "CARTEL_TAX_SAVED", -- Клан отбился от налога
    "CARTEL_TAX_TAKEN",  -- Ограблен
    "CARTEL_TAX_FIGHT", -- Вы объявили войну
    "CARTEL_TAX_OTHER_FIGHT", -- Другой картель объявил войну
    -- nil -- Не хватает денег у клана
}

MAX_CARTEL_REQUESTED_TAXES_COUNT_PER_SEASON = 3

SPUTNIK_PRICE_FOR_CLAN = 500000 -- price
SPUTNIK_TIME_AVAILABLE = 3600 * 24 * 14 -- 14 days

--------------------------------------------------------------------------------
--============================================================================--
--------------------------------------------------------------------------------

GetClanTeam = function( clan_id )
    if type( clan_id ) == "number" then
        return getElementByID( "c" .. clan_id )
    end
end

GetClanName = function( clan_id )
	local team = GetClanTeam( clan_id )
	return team and team.name
end