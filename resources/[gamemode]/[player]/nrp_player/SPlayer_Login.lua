loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShApartments" )
Extend( "ShVipHouses" )
Extend( "SPlayer" )
Extend( "SVehicle" )

MARIADB_INCLUDE = { APIDB = true }
SDB_SEND_CONNECTIONS_STATS = true
Extend( "SDB" )

Extend( "SChat" )
Extend( "SPlayerCommon" )

addEvent( "onPlayerCompleteLogin" )
addEvent( "onPlayerReadyToPlay" )
addEvent( "onPlayerRegister" )

USE_UTM_DATA = true

-- Авторизация
OLD_AUTH_SUPPORTED_UNTIL = 2236916201
REPEAT_AUTH_RETRIES = 60 -- максимальное количество повторов авторизации подряд
REPEAT_AUTH_DELAY = 1000 -- задержка перед повтором авторизации
AUTH_ALLOWED_TESTING_BYPASS = true -- можно ли заходить в игру мимо авторизации на тестовые сервера
FORCE_OLD_AUTH = false

IS_INVITE_ONLY = exports.startup:GetWebConfigValue( "isInviteOnly" ) -- вход по инвайтам (для РП сервера)

-- Всякая нечеловеческая магия

PLAYER_DATA = { } -- данные из базы
DOWNLOADING_PLAYERS = { } -- качающие игроки

PLAYER_SAVE_TIMERS = { }

-- Текущая версия клиента игры
CONST_MAJOR_CLIENT_VERSION = 20
CONST_MINOR_CLIENT_VERSION = 0

LOCKED_KEY = "permanent_data"

COLUMNS = {
		{ Field = "id",									Type = "int(11) unsigned",		Null = "NO",	Key = "PRI", Default = NULL,	Extra = "auto_increment" };
		{ Field = "accesslevel",						Type = "tinyint(1) unsigned",	Null = "NO",	Key = "",	Default = 0 			};
		{ Field = "nickname",							Type = "varchar(32)",			Null = "NO",	Key = "",	Default = NULL		};
		{ Field = "level",								Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 1,		};
		{ Field = "exp",								Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 150,		options = { private = true }	};
		{ Field = "quests",								Type = "mediumtext",			Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, private = true }	};
		{ Field = "quests_enabled",						Type = "mediumtext",			Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, private = true }	};

		{ Field = "donate",								Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0,		options = { private = true }			};
		{ Field = "donate_total",						Type = "bigint(20)",			Null = "NO",	Key = "",	Default = 0			};
		{ Field = "donate_transactions",				Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0			};
		{ Field = "donate_last_date",					Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0			};

		{ Field = "premium_time_left",					Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = NULL,		};
		{ Field = "premium_total",						Type = "bigint(20)",			Null = "NO",	Key = "",	Default = 0			};
		{ Field = "premium_transactions",				Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0			};
		{ Field = "premium_last_date",					Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0			};
		{ Field = "premium_discounts_data",				Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true }	};

		{ Field = "money",								Type = "bigint(20)",			Null = "NO",	Key = "",	Default = 0,		options = { private = true }};
		{ Field = "health",								Type = "float unsigned",		Null = "NO",	Key = "",	Default = 100.0		};
		{ Field = "calories",							Type = "float",					Null = "YES",	Key = "",	Default = 100.0,	options = { private = true }		};
		{ Field = "armor",								Type = "float unsigned",		Null = "NO",	Key = "",	Default = 0			};
		{ Field = "weapons",							Type = "text",					Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "intro",								Type = "enum('Yes','No')",		Null = "NO",	Key = "",	Default = "Yes"		};
		{ Field = "last_vehicle_id",					Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "last_vehicle_seat",					Type = "tinyint(1) unsigned",	Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "licenses",							Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true, private = true }		};
		{ Field = "phone",								Type = "varchar(13)",			Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "phone_contacts",						Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true }		};
		{ Field = "phone_balance",						Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = 0			};
		{ Field = "items",								Type = "longtext",				Null = "YES",	Key = "",	Default = NULL, 	options = { json = true }	};
		{ Field = "vehicle_items",						Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true }	};
		{ Field = "start_city",							Type = "smallint(3) unsigned",	Null = "NO",	Key = "",	Default = 0,		options = { private = true }	};
		{ Field = "gender",								Type = "smallint(3) unsigned",	Null = "NO",	Key = "",	Default = 0,		options = { private = true }	};
		{ Field = "skin",								Type = "smallint(3) unsigned",	Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "x",									Type = "float",					Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "y",									Type = "float",					Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "z",									Type = "float",					Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "rotation",							Type = "float",					Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "dimension",							Type = "smallint(5) unsigned",	Null = "NO",	Key = "",	Default = 0			};
		{ Field = "interior",							Type = "smallint(5) unsigned",	Null = "NO",	Key = "",	Default = 0			};
		{ Field = "client_id",							Type = "char(36)",				Null = "YES",	Key = "",	Default = NULL,		options = { ignore = true }		};
		{ Field = "reg_serial",							Type = "varchar(32)",			Null = "YES",	Key = "",	Default = NULL,		options = { ignore = true }		};
		{ Field = "last_serial",						Type = "varchar(32)",			Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "check_serial",						Type = "tinyint(1) unsigned",	Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "reg_ip",								Type = "varchar(15)",			Null = "YES",	Key = "",	Default = NULL,		options = { ignore = true }		};
		{ Field = "last_ip",							Type = "varchar(15)",			Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "now_ip",								Type = "varchar(15)",			Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "reg_date",							Type = "bigint(20) unsigned",	Null = "YES",	Key = "",	Default = NULL,		options = { ignore = true, private = true }		};
		{ Field = "last_date",							Type = "bigint(20) unsigned",	Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "last_enter_date",					Type = "bigint(20) unsigned",	Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "playing_time",						Type = "bigint(20) unsigned",	Null = "NO",	Key = "",	Default = 0		};
		{ Field = "birthday",							Type = "bigint(20) unsigned",	Null = "NO",	Key = "",	Default = NULL,		options = { ignore = true }		};
		--{ Field = "first_car",							Type = "enum('Yes','No')",		Null = "NO",	Key = "",	Default = "No"		};
		{ Field = "muted",								Type = "bigint(20) unsigned",	Null = "NO",	Key = "",	Default = 0		};
		{ Field = "banned",								Type = "bigint(20) unsigned",	Null = "NO",	Key = "",	Default = 0		};
		{ Field = "banned_serials",						Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }	};
		{ Field = "all_vehicles_discount",				Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true, private = true }	};

		{ Field = "social_rating",						Type = "int(10)",				Null = "NO",	Key = "",	Default = 0			};
		{ Field = "last_rating_donate",					Type = "bigint(20) unsigned",	Null = "NO",	Key = "",	Default = 0			};
		{ Field = "available_rating",					Type = "int(3)",				Null = "NO",	Key = "",	Default = 0			};
		{ Field = "available_dislike",					Type = "int(3) unsigned",		Null = "NO",	Key = "",	Default = 0			};
		{ Field = "available_like",						Type = "int(3) unsigned",		Null = "NO",	Key = "",	Default = 0			};
		{ Field = "last_date_like",						Type = "bigint(20) unsigned",	Null = "NO",	Key = "",	Default = 0			};
		{ Field = "last_rated_players",					Type = "text",					Null = "YES",	Key = "",	Default = NULL,		options = { json = true, autofix = true }	};

		{ Field = "retention_tasks",					Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }	};
		{ Field = "retention_tasks_today",				Type = "smallint(5) unsigned",	Null = "YES",	Key = "",	Default = NULL	};

		{ Field = "cases",								Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, private = true }	};
		{ Field = "cases_exp",							Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0,		options = { private = true }	};
		{ Field = "cases_inc_chances",					Type = "enum('Yes','No')",		Null = "NO",	Key = "",	Default = "No"		};
		{ Field = "cases_discount_pur",					Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, private = true }	};

		{ Field = "cases_tuning",						Type = "mediumtext",			Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true, private = true }	};
		{ Field = "cases_vinyl",						Type = "mediumtext",			Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true, private = true }	};
		{ Field = "business_items",						Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true }	};
		{ Field = "skins",								Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true }	};
		{ Field = "hometown",							Type = "smallint(3) unsigned",	Null = "NO",	Key = "",	Default = 1			};
		{ Field = "weapons",							Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }		};

		{ Field = "clan_id",				Type = "varchar(128)",			Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "clan_exp",				Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0		};
		{ Field = "clan_rank",				Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0		};
		{ Field = "clan_role",				Type = "tinyint(1) unsigned",	Null = "NO",	Key = "",	Default = 0, 		options = { private = true }	};
		{ Field = "clan_stats",				Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }		};
		{ Field = "clan_events_stats",		Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }		};

		{ Field = "wanted_data",						Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true }	};

		{ Field = "party_id",							Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "party_role",							Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "party_locked_time",					Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = NULL		};

		{ Field = "job_class",							Type = "varchar(128)",			Null = "YES",	Key = "",	Default = NULL		};
		{ Field = "job_id",								Type = "varchar(128)",			Null = "YES",	Key = "",	Default = NULL		};

		{ Field = "military_level",						Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0,		options = { private = true }	};
		{ Field = "military_exp",						Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0,		options = { private = true }	};

		{ Field = "faction_id",							Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0,		options = { private = true }	};
		{ Field = "faction_level",						Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0,		options = { private = true }	};
		{ Field = "faction_exp",						Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0,		options = { private = true }	};
		{ Field = "faction_warns",						Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0,		options = {  }	};
		{ Field = "faction_reports",					Type = "text",					Null = "NO",	Key = "",	Default = 0,		options = { json = true, autofix = true  }	};
		{ Field = "faction_thanks_last",				Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0,		options = {  }	};
		{ Field = "faction_timeout",					Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0,		options = {  }	};

		{ Field = "subscription_time_left",				Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0,		options = { private = true }	};
		{ Field = "subscription_total",					Type = "bigint(20)",			Null = "NO",	Key = "",	Default = 0			};
		{ Field = "subscription_transactions",			Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0			};
		{ Field = "subscription_last_date",				Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0			};
		{ Field = "subscription_discount_buy_count", 	Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0,	options = { private = true }	};
		{ Field = "subscription_reward_time", 			Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0,		options = { private = true }	};

		{ Field = "nickname_color",						Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 1,		};
		{ Field = "nickname_color_timeout",				Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0,		options = { private = true }	};

		{ Field = "hide_nickname_time",					Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0,		};

		{ Field = "vehicle_access_sub_id",				Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = NULL,		options = { private = true }	};
		{ Field = "vehicle_access_sub_time", 			Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = NULL,		options = { private = true }	};

		{ Field = "own_accessories",					Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true }	};
		{ Field = "accessories",						Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }	};
		{ Field = "ref_rewards",						Type = "mediumtext",			Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }	};
		{ Field = "refferer",							Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = NULL, 	};
		{ Field = "total_refferals",					Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = NULL, 	};
		{ Field = "tuning_internal",					Type = "mediumtext",			Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }	};
		{ Field = "neons",								Type = "mediumtext",			Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }	};
		{ Field = "sessions_counter",					Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = 0		};

		{ Field = "business_coins",						Type = "int(11) unsigned",		Null = "NO",	Key = "",	Default = 0,		options = { private = true }			};
		{ Field = "offline_notifications",				Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }		};

		{ Field = "taxi_licenses",						Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }		};
		{ Field = "taxi_rates",							Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }		};

		{ Field = "hobby_data",							Type = "text",					Null = "YES",	Key = "",	Default = NULL,		options = { json = true, autofix = true }		};
		{ Field = "hobby_items",						Type = "text",					Null = "YES",	Key = "",	Default = NULL,		options = { json = true, autofix = true }		};
		{ Field = "hobby_equipment",					Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }		};

		{ Field = "cinema_balance",						Type = "bigint(20)",			Null = "NO",	Key = "",	Default = 0			};

		{ Field = "car_slots",              			Type = "smallint(3) unsigned",	Null = "NO",    Key = "",	Default = 0			};
		{ Field = "release_players",        			Type = "smallint(3) unsigned",	Null = "NO",    Key = "",	Default = 0			};

		{ Field = "megaphone_time_left",				Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = NULL,		};

		{ Field = LOCKED_KEY,							Type = "longtext",				Null = "YES",	Key = "",	Default = NULL, 	options = { json = true }, 	locked = true };

		{ Field = "annuity_payment_timeout",			Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = NULL,		options = { private = true }	};
		{ Field = "annuity_payment",					Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = NULL,		options = { private = true }	};
		{ Field = "annuity_days",						Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, private = true }	};

		{ Field = EVENT_COINS_VALUE_NAME,				Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = NULL,		options = { private = true }	};
		{ Field = EVENT_BOOSTER_VALUE_NAME,				Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = NULL,		options = { private = true }	};

		{ Field = "casino_drop_count",      			Type = "int(11) unsigned",		Null = "YES",    Key = "",	Default = NULL };
		{ Field = "casino_stat",						Type = "text",					Null = "YES",	 Key = "",	Default = NULL, 	options = { json = true, autofix = true }	};

		{ Field = "phone_number",      					Type = "int(7) unsigned",		Null = "YES",    Key = "",	Default = NULL };
		{ Field = "phone_number_type",      			Type = "text",					Null = "YES",    Key = "",	Default = NULL };
		{ Field = "phone_number_date_pur",  			Type = "int(11) unsigned",		Null = "YES",    Key = "",	Default = NULL };
		{ Field = "phone_contacts",  					Type = "text",					Null = "YES",    Key = "",	Default = NULL, 	options = { json = true, autofix = true } };
		{ Field = "free_evacuations",					Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }	};
		{ Field = "give_on_join",						Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true }	};

		{ Field = "daily_quest_list",  					Type = "text",					Null = "YES",   Key = "",	Default = NULL, 	options = { json = true, autofix = true } };
		{ Field = "cur_daily_quests",  					Type = "text",					Null = "YES",   Key = "",	Default = NULL, 	options = { json = true, autofix = true } };
		{ Field = "last_refresh_data",					Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true } };

		{ Field = "exp_bonus", 							Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true }  };
		{ Field = "job_money_bonus", 					Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true }  };

		{ Field = "gifts",								Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }		};
		{ Field = "wedding_at_id",						Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = NULL,		};

		{ Field = "pay_strip_money", 					Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = 0, 		};
		{ Field = "car_marks_today_num", 				Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = 0, 		};

		{ Field = "admin_data", 						Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true }  };
		{ Field = "admin_payout", 						Type = "int(11) unsigned",		Null = "YES",	Key = "",	Default = NULL, 	};

		{ Field = "race_prizes",						Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }		};

		{ Field = "new_year_auction_rate", 				Type = "int(11)",				Null = "YES",	Key = "",	Default = 0, 		};

		{ Field = "ltr_purchased_tickets", 				Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }		};
		{ Field = "ltr_progression_points", 			Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }		};
		{ Field = "ltr_received_awards",				Type = "text",					Null = "YES",	Key = "",	Default = NULL, 	options = { json = true, autofix = true }		};
}

-- Значения, которые пишутся напрямую в колонки базы
COLUMNS_REVERSE = { }
COLUMNS_LIST = { }
for i, v in pairs( COLUMNS ) do
	COLUMNS_REVERSE[ v.Field ] = not v.locked and ( v.options or { } )
	table.insert( COLUMNS_LIST, v.Field )
end
-- Создание базы ебаным способом
DB:createTable("nrp_players", COLUMNS )

-- Индексы
do
	local indices = { "client_id", "clan_id", "nickname", "faction_id", "banned", "business_coins", "phone_number", "reg_date", "level", "last_serial", "reg_serial", "last_ip", "now_ip" }
	for i, v in pairs( indices ) do
		DB:exec( "CREATE INDEX " .. v .. " ON nrp_players( " .. v .. " );" )
	end
end

--------------------------- STAGE 0
-- Загрузка файлов
CAMERA_LOCATIONS = {
	{ 264.17254638672, -1563.5985107422, 51.35559463501, 187.01307678223, -1500.9643554688, 40.247985839844, 0, 70 }, -- НСК у тюнинга и домов
	{ 1069.5777587891, -604.49597167969, 274.14367675781, 972.17156982422, -624.58544921875, 263.73001098633, 0, 70 }, -- Гора
	{ 245.55143737793, -690.17181396484, 47.017807006836, 156.9755859375, -653.04705810547, 19.159757614136, 0, 70 }, -- Дома
	{ 2069.4985351563, 153.51800537109, 73.659065246582, 2027.3699951172, 62.974102020264, 68.463829040527, 0, 70 }, -- Лмборгини салон
	{ 2151.4057617188, -154.29368591309, 78.649269104004, 2239.2739257813, -106.87602233887, 73.105537414551, 0, 70 }, -- Ёлка и здание
	--{ 2382.1462402344, -44.138355255127, 60.232173919678, 2412.8247070313, -139.19274902344, 65.07884979248, 0, 70 }, -- Горки Мариотт
	--{ 497.92269897461, -1491.6826171875, 20.402099609375, 497.16146850586, -1492.2624511719, 20.692390441895, 0, 70 }, -- Больница
	{ 533.95513916016, -1057.2928466797, 20.987522125244, 633.90551757813, -1059.4193115234, 23.311653137207, 0, 70 }, -- Дорога
}

function OnPlayerJoin( )
	local player = source

	setPlayerHudComponentVisible( player, "all", false )

	spawnPlayer( player, 335.406, 2300.431, 20.818, 0, 0, 0, math.random( 65534 ) )
	setCameraMatrix( player, 348.38079833984, 2257.1127929688, 40.117870330811, 281.99002075195, 2331.8801269531, 41.572319030762, 0, 70 )
	fadeCamera( player, true, 1.0 )

	player.frozen = true
	player:setName( hash( "md5", getPlayerSerial( player ) ):sub( 1, 22 ) )
end
addEventHandler( "onPlayerJoin", root, OnPlayerJoin )

--------------------------- STAGE 1
-- Приём готовности клиента
addEvent( "onClientPlayerRequestResourcesList", true )
addEventHandler( "onClientPlayerRequestResourcesList", resourceRoot, function()
	local resources = { }
	for i, v in pairs( getResources( ) ) do
		table.insert( resources, getResourceName( v ) )
	end
	triggerClientEvent( client, "onReciveResourceList", resourceRoot, resources, LOGSERVER )
end )

function OnClientPlayerReady_handler( launcher_data, ac_data )
	local player = client
	
	if isTimer( DOWNLOADING_PLAYERS[ player ] ) then
		killTimer( DOWNLOADING_PLAYERS[ player ] )
		DOWNLOADING_PLAYERS[ player ] = nil
	end
	local session_id, client_id = launcher_data.HWID or "", launcher_data.SESSIONID or ""

	--[[if #pregMatch( client_id, "^[a-f0-9]{8}\\-[a-f0-9]{4}\\-4[a-f0-9]{3}\\-(8|9|a|b)[a-f0-9]{3}\\-[a-f0-9]{12}$" ) <= 0 then
		player:kick( "Загрузите лаунчер на NextRP.ru" )
		return
	end

	if tonumber( get( "server.number" ) ) < 100 and player:getData( "use_custom_interfacer_files" ) then
		player:kick( "Вы используете модифицированную версию клиента" )
		return
	end

	local is_test_version = launcher_data and launcher_data.is_test_version or false
	if tonumber( get( "server.number" ) ) < 100 and is_test_version then
		player:kick( "Вы используете тестовую версию клиента" )
		return
	end

	local major_version = launcher_data and launcher_data.major_version or 0
	if major_version < CONST_MAJOR_CLIENT_VERSION then
		player:kick( "Обновите клиент игры через лаунчер" )
		return
	end]]

	local minor_version = launcher_data and launcher_data.minor_version or 0
	if minor_version < CONST_MINOR_CLIENT_VERSION and major_version == CONST_MAJOR_CLIENT_VERSION then
		outputChatBox( "==================== ! ВНИМАНИЕ ! ====================", player, 250, 80, 80 )
		outputChatBox( "                     * ВАША ВЕРСИЯ КЛИЕНТА УСТАРЕЛА *", player, 250, 80, 80 )
		outputChatBox( "           * РЕКОМЕНДУЕМ ОБНОВИТЬ ЕЁ ЧЕРЕЗ ЛАУНЧЕР *", player, 250, 80, 80 )
		outputChatBox( "=====================================================", player, 250, 80, 80 )
	end

	for i, p in pairs( getElementsByType( "player" ) ) do
		if p:GetClientID( ) == client_id then
			player:kick( "Этот аккаунт онлайн с другого устройства" )
			return
		end
	end

	local admin_resource = getResourceFromName( "nrp_admin" )
	if admin_resource and getResourceState( admin_resource ) == "running" then
		local player_ban_data = exports.nrp_admin:GetPlayerBanDataBySerial( getPlayerSerial( player ) )
		if player_ban_data and (player_ban_data.server == 0 or player_ban_data.server == SERVER_NUMBER) then
			player:kick( "Вы забанены" )
			return
		end
	end

	local function continue_auth( )
		for i, p in pairs( getElementsByType( "player" ) ) do
			if p:GetClientID( ) == client_id then
				player:kick( "Этот аккаунт онлайн с другого устройства" )
				return
			end
		end

		player:SetClientID( client_id )


			LoadGlobalData( player, function( )
				DB:queryAsync( PlayerLoad_Callback, { player }, "SELECT * FROM nrp_players WHERE client_id = ? LIMIT 1", client_id )
			end )
		
	end
	
	-- Старая авторизация. Оставляем до дня Х чтоб не сломать старые лаунчеры сразу. Разрешаем на дев серверах всегда
	if FORCE_OLD_AUTH or ( session_id == client_id and getRealTime( ).timestamp <= OLD_AUTH_SUPPORTED_UNTIL ) or ( SERVER_NUMBER > 100 and AUTH_ALLOWED_TESTING_BYPASS ) then
		continue_auth( )

	-- Новая авторизация по сессиям
	else
		-- Всё еще пытаемся войти старой авторизацией после дропа ее поддержки
		if session_id == client_id then
			player:kick( "Требуется обновление лаунчера" )
			return
		end

		local attempt = 0
		local t = { }
		function t.try_to_auth( )
			if not isElement( player ) then return end
			local options = {
				queueName = "auth" .. math.random( 1, 1000 ),
				connectionAttempts = 5,
				connectTimeout = 15000,
				postData = utf8.sub( toJSON( {
					sessionId = session_id
				}, true ), 2, -2 ),
				method = "POST",
				headers = {
					['Content-Type'] = "application/json",
				},
			}
			fetchRemote( "https://webclient.gamecluster.nextrp.ru/game/session-details", options, function( result, info )
				if not isElement( player ) then return end
				-- Успешный ответ API, можем начинать проверку
				if info.statusCode == 200 then
					local data = fromJSON( result )
					-- Сессия найдена
					if data.status == "success" then
						-- client_id не был подменен
						if data.data.clientId == client_id then
							continue_auth( )
						else
							WriteLog( "session_hack", "[BAD CLIENT_ID] %s попытка подмены сессии %s", player, inspect( launcher_data ) )
							player:kick( "[NS01] Перезапустите игру через лаунчер" )
						end
					end
				-- Попытка подмены данных замечена со стороны бекенда
				elseif info.statusCode == 422 then
					WriteLog( "session_hack", "[STATUS 422] %s попытка подмены сессии %s", player, inspect( launcher_data ) )
					player:kick( "[NS02] Перезапустите игру через лаунчер" )
				-- Сессия истекла, просим перезапустить в лаунчере
				elseif info.statusCode == 403 then
					player:kick( "[NS03] Перезапустите игру через лаунчер" )
				-- Ошибка со стороны API, пробуем несколько раз
				else
					attempt = attempt + 1
					-- Пробуем с радиусом в REPEAT_AUTH_DELAY мс.
					if attempt < REPEAT_AUTH_RETRIES then
						setTimer( t.try_to_auth, REPEAT_AUTH_DELAY, 1 )
					-- Апи не дало ответ за REPEAT_AUTH_RETRIES попыток
					else
						player:kick( "[NS04] Перезапустите игру через лаунчер" )
					end
				end
			end )
		end
		t.try_to_auth( )
	end

end
addEvent( "OnClientPlayerReady", true )
addEventHandler( "OnClientPlayerReady", root, OnClientPlayerReady_handler )

--------------------------- STAGE 2
-- Результат из базы, решение о регистрации или логине
function PlayerLoad_Callback( query, player )
	if not isElement( player ) then
		dbFree( query )
		return
	end

	local result = query:poll( -1 )
	if #result <= 0 then
		-- У игрока нет аккаунта, нужна регистрация
		--outputConsole( "need registration" )
		if IS_INVITE_ONLY then
			triggerClientEvent( player, "ShowInviteLoginUI", player, true, SERVER_DATA )
		else
			triggerEvent( "onPlayerStartRegisterRequest", player )
		end
	else
		-- У игрока есть аккаунт
		--outputConsole( inspect( result ) )
		TryCompleteLogin_STAGE2( result, player, getTickCount() )
	end
end

--------------------------- STAGE 3
-- Запрос о регистрации
local FORBID_REGS = { }
function onAsyncRegisterProcess_handler( player, data )
	if FORBID_REGS[ player ] then return end
	local nickname = data.nickname
	nickname = utf8.gsub(nickname, "Ё", "Е")
	nickname = utf8.gsub(nickname, "ё", "е")
	local success, error = VerifyPlayerName( nickname )
	if not success then
		player:ShowError( "Ошибка регистрации: " .. tostring( error ) )
		return
	end
	FORBID_REGS[ player ] = true
	DB:queryAsync( onAsyncRegisterProcess, { player, data }, "SELECT id FROM nrp_players WHERE nickname = ? LIMIT 1", data.nickname )
end
addEvent("onAsyncRegisterProcess")
addEventHandler("onAsyncRegisterProcess", root, onAsyncRegisterProcess_handler )

function onAsyncRegisterProcess( query, player, data )
	if not isElement( player ) then
		FORBID_REGS[ player ] = nil
		dbFree( query )
		return
	end
	local result = query:poll( -1 )
	if #result > 0 then
		FORBID_REGS[ player ] = nil
		player:ShowError( "Ошибка регистрации: данное имя уже занято" )
		return
	end
	local client_id = player:GetClientID()
	local serial = getPlayerSerial( player )

	local reg_write_info = {
		intro 			= "Yes",
		reg_serial 		= serial,
		last_serial 	= serial,
		reg_ip 			= getPlayerIP( player ),
		nickname 		= data.nickname,
		client_id 		= client_id,
		reg_date 		= getRealTime().timestamp,
		start_city 		= data.start_city,
		gender 			= data.gender,
		skin 			= data.skin,
		skins 			= toJSON( { s1 = data.skin }, true ),
		birthday 		= data.birthday or 0,
		quests 			= toJSON( data.quests or { completed = { }, failed = { }, count_failed = { }, count_completed = { } }, true ),
		check_serial 	= 0,
	}

	player:UpdateOfflineData( "nickname", data.nickname )

	local keys, values_n, values = { }, { }, { }
	for i, v in pairs( reg_write_info ) do
		table.insert( keys, i )
		table.insert( values_n, "?" )
		table.insert( values, v )
	end

	local query_str = table.concat( { "INSERT INTO nrp_players ( ", table.concat( keys, ", " ), " ) VALUES ( ", table.concat( values_n, ", " ), " )" }, '' )
	DB:queryAsync( onAsyncRegisterProcess_STAGE2, { player, data }, query_str, unpack( values ) )
end

function onAsyncRegisterProcess_STAGE2( query, player, data )
	FORBID_REGS[ player ] = nil

	if not isElement( player ) then
		dbFree( query )
		return
	end

	local _, _, id = query:poll( -1 )
	local client_id = player:GetClientID( )

	

	DB:queryAsync( TryCompleteLogin_STAGE2, { player, getTickCount( ), account_num }, "SELECT * FROM nrp_players WHERE client_id = ? LIMIT 1", client_id )

end

--------------------------- STAGE 4
-- Логин

function TryCompleteLogin_STAGE2( query, player, tick, account_num )
	if not isElement( player ) then dbFree( query ) return end
	local data = ( type( query ) == "table" and query or query:poll( -1 ) )[ 1 ]

	-- Перманент дата
	local permanent_data_type = type( data[ LOCKED_KEY ] )
	data[ LOCKED_KEY ] = permanent_data_type == "string" and fromJSON( data[ LOCKED_KEY ] ) or permanent_data_type == "table" and data[ LOCKED_KEY ] or { }

	-- Сохранение глобальных настроек
	local private_info = { }
	for i, v in pairs( data ) do
		if COLUMNS_REVERSE[ i ] then
			if COLUMNS_REVERSE[ i ].json then
				data[ i ] = type( v ) == "string" and fromJSON( v ) or { }
				if COLUMNS_REVERSE[ i ].autofix then
					local new_data = { }
					for k, n in pairs( data[ i ] ) do
						local k = tonumber( k ) or k
						new_data[ k ] = n
					end
					data[ i ] = new_data
				end
			end

			if COLUMNS_REVERSE[ i ].private then
				private_info[ i ] = data[ i ]
			end
		end
	end
	player:SetBatchPrivateData( private_info )

	PLAYER_DATA[ player ] = data

	local access = ( data.accesslevel or 0 ) > 0 and data.accesslevel or ( data.check_serial or 0 )
	local serial = getPlayerSerial( player )

	if ( data.last_serial ~= serial and data.reg_serial ~= serial ) and access > 0 then
		if isElement( CommonDB ) then
			CommonDB:queryAsync(
				onPlayerInvalidSerialCheck_callback, { player },
				"SELECT nickname FROM priority_serials.allowed_serials WHERE serial=? AND nickname LIKE ? AND server=? AND active=?",
				serial, data.nickname, SERVER_NUMBER, 'Yes'
			)
			return			
		else
			player:kick( "Вход с неизвестного устройства" )
			PLAYER_DATA[ player ] = nil
			return
		end
	end

	if isElement( player ) then
		if account_num == 1 then
			player:SetPermanentData( "is_first_character", true )
		end

		player:SetID( data.id )

		onPlayerContinueLogin( player, tick )
	end
end

function onPlayerInvalidSerialCheck_callback( query, player, tick )
	if isElement( player ) then
		local result = query and query:poll( -1 ) or { }
		if #result <= 0 then
			player:kick( "Вход с неизвестного устройства" )
			PLAYER_DATA[ player ] = nil
			return
		end
		onPlayerContinueLogin( player, tick )
	end
end

function onPlayerContinueLogin( player, tick )
	if isElement( player ) and getElementType( player ) == "player" then
		local data = PLAYER_DATA[ player ]

		if tick then
			local duration = getTickCount() - tick
			iprint( data.nickname, "данные загружены за", duration )
			SendToLogserver( data.nickname .. " вошёл в игру", { database_speed = duration, access_level = data.accesslevel or 0 } )
		end
		
		-- Сообщаем клиенту о готовности спавна
		triggerClientEvent( player, "onPlayerVerifyReadyToSpawn", resourceRoot )

		-- Если во время входа его не послали нахуй
		if isElement( player ) then
			-- Вывод входа чисто админам
			local ip = getPlayerIP( player )
			local text = ( "%s вошёл в игру, IP: %s" ):format( data.nickname, ip )
			for i, v in pairs( GetPlayersInGame( ) ) do
				if v:GetAccessLevel() >= ACCESS_LEVEL_DEVELOPER then
					outputChatBox( text, v, 0, 255, 0, true )
				end
			end

			-- If check_serial is null
			if not tonumber( data.check_serial ) then
				player:SetPermanentData( "check_serial", ( data.accesslevel or 0 ) > 0 and 1 or 0 )
			end

			-- last date of enter in game
			player:SetPermanentData( "last_enter_date", getRealTime( ).timestamp )
		else
			PLAYER_DATA[ player ] = nil
		end
	end
end

local toJSON                = toJSON
local pairs                 = pairs
local table_insert          = table.insert
local table_concat          = table.concat
local dbPrepareString       = dbPrepareString
local getPedArmor           = getPedArmor
local isPedDead             = isPedDead
local getElementHealth      = getElementHealth

function SavePlayer( player, client_id, force_synchronous, is_quit )
	local pdata = PLAYER_DATA[ player ]
	local client_id = client_id or pdata.client_id

	local player_data = {
		armor       = getPedArmor( player ),
		health      = isPedDead( player ) and 0 or getElementHealth( player ),
		weapons     = toJSON( player:GetPermanentWeapons( ) or { }, true ),
	}

	local last_pos = player:GetPermanentData( "last_tp_position" )
	if player.dimension < 10 then -- public places
		player_data.x = player.position.x
		player_data.y = player.position.y
		player_data.z = player.position.z
		player_data.dimension = player.dimension
		player_data.interior = player.interior
	elseif last_pos then
		player_data.x = last_pos.x
		player_data.y = last_pos.y
		player_data.z = last_pos.z
		player_data.dimension = 0
		player_data.interior = 0
	end

	if is_quit then
		player_data.last_date   = getRealTime( ).timestamp
		player_data.last_ip     = getPlayerIP( player )
		player_data.last_serial = getPlayerSerial( player )
	end

	local query_table, changed_values = { }, CHANGED_VALUES[ player ] or { }
	for i, _ in pairs( changed_values ) do
		local v = pdata[ i ]
		local col_info = COLUMNS_REVERSE[ i ] or { }
		if col_info.json or i == LOCKED_KEY then
			table_insert( query_table, dbPrepareString( DB, "`??`=?", i, toJSON( v or { }, true ) or "[[]]" ) )
		elseif not col_info.ignore then
			table_insert( query_table, dbPrepareString( DB, "`??`=?", i, v ) )
		end
	end

	-- Внутриигровые переменные игрока
	for i, v in pairs( player_data ) do
		table_insert( query_table, dbPrepareString( DB, "`??`=?", i, v ) )
	end

	local query_str = table_concat( { "UPDATE nrp_players SET ", table_concat( query_table, ", " ), dbPrepareString( DB, " WHERE client_id=? LIMIT 1", client_id ) }, '' )

	if force_synchronous then
		local query = DB:query( query_str )
		dbPoll( query, -1 )
	else
		DB:exec( query_str )
	end

	CHANGED_VALUES[ player ] = nil

	SaveGlobalData( player )
end

function onPlayerQuit_handler( player, force_synchronous )
	local reason = type( player ) == "string" and player or "Quit"

	local player = isElement( player ) and player or source

	DestroySaveTimerForPlayer( player )

	if isTimer( DOWNLOADING_PLAYERS[ player ] ) then killTimer( DOWNLOADING_PLAYERS[ player ] ) end
	DOWNLOADING_PLAYERS[ player ] = nil
	local client_id = player:GetClientID()
	local data = PLAYER_DATA[ player ]

	SaveGlobalData( player, true )

	-- Если не был в игре, то ПНХ
	if not player:IsInGame() then
		player:SetClientID()
		PLAYER_DATA[ player ] = nil
		return
	end

	triggerEvent( "onPlayerPreLogout", player, reason )
	player:SetClientID()

	SavePlayer( player, client_id, force_synchronous == true, true )

	-- Вывод выхода чисто админам
	local text = ( "%s вышел из игры, IP: %s%s" ):format( data.nickname, getPlayerIP( player ), reason ~= "Quit" and " [" .. reason .. "]" or "" )
	for i, v in pairs( GetPlayersInGame( ) ) do
		if v:GetAccessLevel() >= ACCESS_LEVEL_DEVELOPER then
			outputChatBox( text, v, 255, 0, 0, true )
		end
	end

	SendToLogserver( data.nickname .. " вышел из игры", { access_level = data.accesslevel or 0 } )

	PLAYER_DATA[ player ] = nil
end
addEventHandler( "onPlayerQuit", root, onPlayerQuit_handler, true, "low-100" )

function onAsyncQuitFinish( query, nickname, tick )
	dbPoll( query, -1 )
	if tick then iprint( nickname, "данные сохранены за", getTickCount() - tick ) end
end

function onResourceStart_handler( )
	setTimer( function ( )
		triggerClientEvent( GetPlayersInGame( ) or { }, "onRecieveServerTimestamp", resourceRoot, getRealTime( ).timestamp )
	end, SERVER_NUMBER > 100 and 20000 or 120000, 0 )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function onResourceStop_handler()
	local players = getElementsByType( "player" )
	for i, player in pairs( players ) do
		onPlayerQuit_handler( player, true )
	end
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_handler )

function CreateSaveTimerForPlayer( player )
	if isElement( player ) and not HasSaveTimerForPlayer( player ) then
		PLAYER_SAVE_TIMERS[ player ] = setTimer( SavePlayer, 60000, 0, player, player:GetClientID( ) )
	end
end

function DestroySaveTimerForPlayer( player )
	if PLAYER_SAVE_TIMERS[ player ] then
		if isTimer( PLAYER_SAVE_TIMERS[ player ] ) then killTimer( PLAYER_SAVE_TIMERS[ player ] ) end
		PLAYER_SAVE_TIMERS[ player ] = nil
	end
end

function HasSaveTimerForPlayer( player )
	return isTimer( PLAYER_SAVE_TIMERS[ player ] )
end

function OnKickMePls_handler( )
	if not client then return end
	client:setData( "use_custom_interfacer_files", true, false )
end
addEvent( "OnKickMePls", true )
addEventHandler( "OnKickMePls", root, OnKickMePls_handler )

addEvent( "onRequestServerTimestamp", true )
addEventHandler( "onRequestServerTimestamp", resourceRoot, function ( )
	if not isElement( client ) then return end

	triggerClientEvent( client, "onRecieveServerTimestamp", resourceRoot, getRealTime( ).timestamp )
end )

if SERVER_NUMBER > 100 then
	function SetFakeTime( player, cmd, ... )
		local str_time = table.concat( { ... }, " " )

		if str_time == "" then
			ResetFakeTime( player )
			return
		end
		
		local pattern = "^(%d+)[%p%s]+(%d*)([^%d%p%s]*)[%p%s]+(%d+)%s*(%d*):?(%d*):?(%d*)"
		local day, month, month_name, year, time_hours, time_minutes, time_seconds = str_time:match( pattern )
		if not year or ( tonumber( year ) or 0 ) < 1000 and ( tonumber( day ) or 0 ) < 100 then
			local pattern = "^(%d+)[%p%s]+(%d*)([^%d%p%s]*)%s*(%d*):?(%d*):?(%d*)"
			local day, month, month_name, time_hours, time_minutes, time_seconds = str_time:match( pattern )
			local year = os.date( "*t" ).year
			str_time = day .." ".. month .. month_name .." ".. year .." ".. time_hours ..":".. time_minutes ..":".. time_seconds
		end

		local result, time = pcall( getTimestampFromString, str_time, true )

		if not result then
			outputConsole( "ОШИБКА! Пример правильного ввода: setfaketime 20 февраля 2020 20:02", player )
			return
		end

		root:setData( "timestamp_fake_diff", time - getRealTime().timestamp )
		triggerClientEvent( "onRecieveServerTimestamp", resourceRoot, getRealTime().timestamp )
		triggerEvent( "onFakeTimestampChange", resourceRoot )

		outputConsole( "Фейковое время успешно установлено на " .. formatTimestamp( getRealTimestamp( ) ), player )
	end
	addCommandHandler( "setfaketime", SetFakeTime )
	addCommandHandler( "sft", SetFakeTime )

	function ResetFakeTime( player, cmd )
		root:setData( "timestamp_fake_diff", nil )
		triggerClientEvent( player, "onRecieveServerTimestamp", resourceRoot, getRealTime().timestamp )
		triggerEvent( "onFakeTimestampChange", resourceRoot )

		outputConsole( "Фейковое время успешно сброшено", player )
	end
	addCommandHandler( "resetfaketime", ResetFakeTime )

	addCommandHandler( "clientid", function ( player )
		outputConsole( "* Ваш client id: " .. player:GetClientID( ) )
	end )
end