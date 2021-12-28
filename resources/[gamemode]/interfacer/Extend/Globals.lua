-- Globals

if not localPlayer then
	SERVER_NUMBER = 101

	function getReservedSlots( )
		return GET( "reserved_slots" ) or 0
	end
end

-- Работы
enum "eJobClass" {
	"JOB_CLASS_COURIER",
	"JOB_CLASS_LOADER",
	"JOB_CLASS_DRIVER",
	"JOB_CLASS_TAXI",
	"JOB_CLASS_TRUCKER",
	"JOB_CLASS_FARMER",
	"JOB_CLASS_TAXI_PRIVATE",
	"JOB_CLASS_PILOT",
	"JOB_CLASS_MECHANIC",
	"JOB_CLASS_PARK_EMPLOYEE",
	"JOB_CLASS_WOODCUTTER",
	"JOB_CLASS_HCS",
	"JOB_CLASS_TOWTRUCKER",
	"JOB_CLASS_INKASSATOR",
	"JOB_CLASS_TRASHMAN",
	"JOB_CLASS_TRANSPORT_DELIVERY",
	"JOB_CLASS_INDUSTRIAL_FISHING",
	"JOB_CLASS_HIJACK_CARS",
}

JOB_NAMES = {
	[ JOB_CLASS_COURIER ] 		= "Курьер",
	[ JOB_CLASS_LOADER ] 		= "Грузчик",
	[ JOB_CLASS_DRIVER ] 		= "Водитель",
	[ JOB_CLASS_TAXI ] 			= "Таксист",
	[ JOB_CLASS_TRUCKER ] 		= "Дальнобойщик",
	[ JOB_CLASS_FARMER ] 		= "Фермер",
	[ JOB_CLASS_TAXI_PRIVATE ]  = "Таксист Частник",
	[ JOB_CLASS_PILOT ] 		= "Лётчик",
	[ JOB_CLASS_MECHANIC ] 		= "Автомеханик",
	[ JOB_CLASS_PARK_EMPLOYEE ] = "Сотрудник парка",
	[ JOB_CLASS_WOODCUTTER ] 	= "Дровосек",
	[ JOB_CLASS_HCS ] 			= "Сотрудник ЖКХ",
	[ JOB_CLASS_TOWTRUCKER ] 	= "Эвакуаторщик",
	[ JOB_CLASS_INKASSATOR ] 	= "Инкассатор",
	[ JOB_CLASS_TRASHMAN ] 		= "Мусорщик",
	[ JOB_CLASS_TRANSPORT_DELIVERY ] = "Доставка транспорта",
	[ JOB_CLASS_INDUSTRIAL_FISHING ] = "Промышленная рыбалка",
	[ JOB_CLASS_HIJACK_CARS ] = "Угон транспорта",
}

JOB_ID = {
	[ JOB_CLASS_COURIER ] 	    = "courier",
	[ JOB_CLASS_LOADER ]  	    = "loader",
	[ JOB_CLASS_DRIVER ]  	    = "driver",
	[ JOB_CLASS_TAXI ]    	    = "taxi",
	[ JOB_CLASS_TRUCKER ] 	    = "trucker",
	[ JOB_CLASS_FARMER ]  	    = "farmer",
	[ JOB_CLASS_TAXI_PRIVATE ]  = "taxi_private",
	[ JOB_CLASS_PILOT ] 	    = "pilot",
	[ JOB_CLASS_MECHANIC 	 ]  = "mechanic",
	[ JOB_CLASS_PARK_EMPLOYEE ] = "park_employee",
	[ JOB_CLASS_WOODCUTTER ] 	= "woodcutter",
	[ JOB_CLASS_HCS ] 		    = "hcs",
	[ JOB_CLASS_TOWTRUCKER ]    = "towtrucker",
	[ JOB_CLASS_INKASSATOR ]    = "incasator",
	[ JOB_CLASS_TRASHMAN ] 		= "trashman",
	[ JOB_CLASS_TRANSPORT_DELIVERY ] = "delivery_cars",
	[ JOB_CLASS_INDUSTRIAL_FISHING ] = "industrial_fishing",
	[ JOB_CLASS_HIJACK_CARS ] = "hijack_cars",
}

-- Статусы авто
enum "eCarStatus" {
	"STATUS_TYPE_EASY",
	"STATUS_TYPE_NORM",
	"STATUS_TYPE_HARD",
	"STATUS_TYPE_CRIT",
}

TUNING_EFFECT_WEAR = {
    status = {
        [0] = 1,
        [5] = 1.1,
        [10] = 1.1,
        [15] = 1.2,
        [20] = 1.2,
        [25] = 1.3,
        [30] = 1.4
    },

    damage = {
        [0] = 1,
        [5] = 0.95,
        [10] = 0.95,
        [15] = 0.9,
        [20] = 0.9,
        [25] = 0.85,
        [30] = 0.8
    }
}

STATUSES_DATA = {
	mileage = {
		[1] = { 500, 1000, 2000 },
		[2] = { 500, 1000, 2000 },
		[3] = { 1000, 1750, 2500 },
		[4] = { 1500, 2250, 3000 },
		[5] = { 2000, 3000, 4000 },
		[6] = { 1000, 1750, 2500 },
	},

    damage = {
        [1] = { 1, 1.3, 1.6, 2 },
        [2] = { 1, 1.3, 1.6, 2 },
        [3] = { 1, 1.3, 1.6, 2 },
        [4] = { 1, 1.3, 1.6, 2 },
        [5] = { 1, 1.3, 1.6, 2 },
		[6] = { 1, 1.3, 1.6, 2 },
    },

    capitalRepairCost = {
        [1] = { 0.15, 0.3 },
        [2] = { 0.1, 0.15 },
        [3] = { 0.1, 0.15 },
        [4] = { 0.05, 0.1 },
        [5] = { 0.05, 0.1 },
		[6] = { 0.1, 0.15 },
    },

    capitalRepairMin = {
        [1] = 30000,
        [2] = 30000,
        [3] = 150000,
        [4] = 300000,
        [5] = 500000,
		[6] = 150000,
    },

    capitalRepairMax = {
        [1] = 1000000,
        [2] = 1000000,
        [3] = 2000000,
        [4] = 2000000,
        [5] = 2500000,
		[6] = 2000000,
    }

}

CAR_STATUS_NAMES = {
	[ STATUS_TYPE_EASY ] = "С завода",
	[ STATUS_TYPE_NORM ] = "Новая",
	[ STATUS_TYPE_HARD ] = "Подержанная",
	[ STATUS_TYPE_CRIT ] = "Старый конь",
}

MOTO_STATUS_NAMES = {
	[ STATUS_TYPE_EASY ] = "С завода",
	[ STATUS_TYPE_NORM ] = "Новый",
	[ STATUS_TYPE_HARD ] = "Подержанный",
	[ STATUS_TYPE_CRIT ] = "Старый конь",
}

-- Номерные знаки автомобилей
enum "eNumberplateTypes" {
	"NUMBER_TYPE_REGULAR",
	"NUMBER_TYPE_STANDART",
	"NUMBER_TYPE_LUXE",
	"NUMBER_TYPE_PREMIUM",
	"NUMBER_TYPE_UNIQUE",
}

NUMBER_TYPE_CONFIG = {
	[ NUMBER_TYPE_REGULAR ] = {
		conditions = {
			mirror = false,
			first_ten = false,
			round = false,
			total_repeats = { 0, 0 },
		},
		cost = 75000,
		visible_name = "Обычные",
	},
	[ NUMBER_TYPE_STANDART ] = {
		conditions = {
			total_repeats = { 1, 2 },
			first_ten = false,
		},
		cost = 500000,
		visible_name = "Стандартные",
	},
	[ NUMBER_TYPE_LUXE ] = {
		conditions = { },
		selective_conditions = {
			total_repeats = { 2, 4 },
			mirror = true,
			first_ten = true,
		},
		cost = 2500000,
		visible_name = "Люкс",
		visible_color = 0xffcd7f32,
	},
	[ NUMBER_TYPE_PREMIUM ] = {
		conditions = {
			repeats = { 3, 6 },
		},
		cost = 5000000,
		visible_name = "Премиум",
		visible_color = 0xffc0c0c0,
	},
	[ NUMBER_TYPE_UNIQUE ] = {
		conditions = {
			unique = true,
		},
		cost = 10000000,
		visible_name = "Уникальные",
		visible_color = 0xffffd700,
	},
}

-- Номера
enum "eNumberPlateTypes" {
	"PLATE_TYPE_AUTO",
	"PLATE_TYPE_MOTO",
	"PLATE_TYPE_TRANSIT",
	"PLATE_TYPE_TAXI",
	"PLATE_TYPE_ARMY",
	"PLATE_TYPE_POLICE",
	"PLATE_TYPE_SPECIAL",
}

-- Лицензии
enum "eLicenses" {
	"LICENSE_TYPE_AUTO",
	"LICENSE_TYPE_MOTO",
	"LICENSE_TYPE_TRUCK",
	"LICENSE_TYPE_BUS",
	"LICENSE_TYPE_AIRCRAFT",
	"LICENSE_TYPE_WEAPON",
	"LICENSE_TYPE_AIRPLANE",
	"LICENSE_TYPE_HELICOPTER",
	"LICENSE_TYPE_BOAT"
}

LICENSE_TYPE_NAMES = {
	[ LICENSE_TYPE_AUTO ]       = "Авто",
	[ LICENSE_TYPE_MOTO ]       = "Мото",
	[ LICENSE_TYPE_TRUCK ]      = "Грузовой",
	[ LICENSE_TYPE_BUS ]        = "Автобус",
	[ LICENSE_TYPE_AIRPLANE ]   = "Самолёт",
	[ LICENSE_TYPE_HELICOPTER ] = "Вертолёт",
	[ LICENSE_TYPE_BOAT ] = "Лодка",
}

-- Статусы лицензий
enum "eLicenseStateType"
{
	"LICENSE_STATE_TYPE_NONE",
	"LICENSE_STATE_TYPE_BOUGHT",
	"LICENSE_STATE_TYPE_LOST",
	"LICENSE_STATE_TYPE_CUSTOM1",
	"LICENSE_STATE_TYPE_CUSTOM2",
	"LICENSE_STATE_TYPE_CUSTOM3",
	"LICENSE_STATE_TYPE_CUSTOM4",
	"LICENSE_STATE_TYPE_CUSTOM5",
	"LICENSE_STATE_TYPE_PASSED",
}

-- Список тюнинга
enum "eTuningParts" {
	"TUNING_REAR_FENDS",
	"TUNING_FRONT_FENDS",
	"TUNING_REAR_LIP",
	"TUNING_FRONT_LIP",
	"TUNING_FRONT_BUMP",
	"TUNING_REAR_BUMP",
	"TUNING_SPOILER",
	"TUNING_BONNET",
	"TUNING_EXHAUST",
	"TUNING_SKIRT",
	"TUNING_ROOF",
	"TUNING_FRONT_LIGHTS",
	"TUNING_REAR_LIGHTS",
	"TUNING_SIREN",
	"TUNING_RADIO",
	"TUNING_SHIELD",
	"TUNNING_FENDER_PART",
	"TUNING_LEFT_MIRROR",
	"TUNING_RIGHT_MIRROR",
	"TUNING_DIFFUSER",
	"TUNING_SPLITTER",
	"TUNING_BOOT",
	"TUNING_FRONT_RESH",
	"TUNING_MISC",
	"TUNING_MISC_FLIGTHS",
	"TUNING_MISC_BODY",
}

-- Айдишники для преобразования
TUNING_IDS = {
	rear_fends   = TUNING_REAR_FENDS,
	front_fends  = TUNING_FRONT_FENDS,
	rear_lip     = TUNING_REAR_LIP,
	front_lip    = TUNING_FRONT_LIP,
	front_bump   = TUNING_FRONT_BUMP,
	rear_bump    = TUNING_REAR_BUMP,
	spoiler      = TUNING_SPOILER,
	bonnet       = TUNING_BONNET,
	exhaust      = TUNING_EXHAUST,
	skirt        = TUNING_SKIRT,
	roof         = TUNING_ROOF,
	front_lights = TUNING_FRONT_LIGHTS,
	rear_lights  = TUNING_REAR_LIGHTS,
	siren        = TUNING_SIREN,
	radio        = TUNING_RADIO,
	shield       = TUNING_SHIELD,
	fender_part  = TUNNING_FENDER_PART,
	left_mirror  = TUNING_LEFT_MIRROR,
	right_mirror = TUNING_RIGHT_MIRROR,
	diffuser 	 = TUNING_DIFFUSER,
	splitter 	 = TUNING_SPLITTER,
	boot       	 = TUNING_BOOT,
	front_resh 	 = TUNING_FRONT_RESH,
	misc		 = TUNING_MISC,
	misc_flight  = TUNING_MISC_FLIGTHS,
	misc_body    = TUNING_MISC_BODY,
}

VINYL_FACTION_VEHICLES = {
    [ 490 ] = true,
    [ 400 ] = true,
    [ 420 ] = true,
    [ 426 ] = true,
    [ 436 ] = true,
    [ 540 ] = true,
    [ 543 ] = true,
    [ 546 ] = true,
    [ 579 ] = true,
    [ 580 ] = true,
}
VINYL_TEXTURE_NAMES = { "vinil", "remap" }
MAX_VINYL_SIZE = 1024
MAX_VINYL_DISTANCE = 150

-- Айдишники тасков в тюнинг-салоне
enum "eTuningTasks" {
	"TUNING_TASK_PARTS",
	"TUNING_TASK_COLOR",
	"TUNING_TASK_LIGHTSCOLOR",
	"TUNING_TASK_BODYPARTS",
	"TUNING_TASK_BODYPARTS_LIST",
	"TUNING_TASK_TONING",
	"TUNING_TASK_TONING_PURCHASE",
	"TUNING_TASK_HYDRAULICS",
	"TUNING_TASK_HYDRAULICS_PURCHASE",
	"TUNING_TASK_SUSPENSION",
	"TUNING_TASK_SUSPENSION_PURCHASE",
	"TUNING_TASK_BLACKMARKET",
	"TUNING_TASK_BLACKMARKET_TONING",
	"TUNING_TASK_BLACKMARKET_PLATECOLOR",
	"TUNING_TASK_BLACKMARKET_RESET",
	"TUNING_TASK_WHEELS",
	"TUNING_TASK_WHEELS_PURCHASE",
	"TUNING_TASK_NUMBERS",
	"TUNING_TASK_NUMBERS_PURCHASE",
	"TUNING_TASK_VINYL",
	"TUNING_TASK_WHEELS_EDIT",
	"TUNING_TASK_NEON",
	"TUNING_TASK_WHEELS_COLOR",
}

-- Реверсная таблица для поиска по айдишникам
TUNING_IDS_REVERSE = { }
for i, v in pairs( TUNING_IDS ) do
	TUNING_IDS_REVERSE[ v ] = i
end

-- Названия тюна
TUNING_PARTS_NAMES = {
	[ TUNING_REAR_FENDS ]   = "Задние расширители",
	[ TUNING_FRONT_FENDS ]  = "Передние расширители",
	[ TUNING_REAR_LIP ]     = "Задняя губа",
	[ TUNING_FRONT_LIP ]    = "Передняя губа",
	[ TUNING_FRONT_BUMP ]   = "Передний бампер",
	[ TUNING_REAR_BUMP ]    = "Задний бампер",
	[ TUNING_SPOILER ]      = "Спойлер",
	[ TUNING_BONNET ]       = "Капот",
	[ TUNING_EXHAUST ]      = "Глушитель",
	[ TUNING_SKIRT ]        = "Боковая юбка",
	[ TUNING_ROOF ]         = "Крыша",
	[ TUNING_FRONT_LIGHTS ] = "Передние фонари",
	[ TUNING_REAR_LIGHTS ]  = "Задние фонари",
	[ TUNING_SIREN ]        = "Мигалки",
	[ TUNING_RADIO ]        = "Рация",
	[ TUNING_SHIELD ]       = "Значок на багажнике",
	[ TUNNING_FENDER_PART ] = "Значки на фендерах",
	[ TUNING_LEFT_MIRROR ]  = "Левое зеркало",
	[ TUNING_RIGHT_MIRROR ] = "Правое зеркало",
	[ TUNING_DIFFUSER ]  	= "Диффузор",
	[ TUNING_SPLITTER ] 	= "Сплиттер",
	[ TUNING_BOOT ]         = "Багажник",
	[ TUNING_FRONT_RESH ]	= "Решётка радиатора",
	[ TUNING_MISC ]			= "Полосы на кузове",
	[ TUNING_MISC_FLIGTHS ]	= "Реснички передних фар",
	[ TUNING_MISC_BODY ]    = "Обвес",
}

-- Ценовые параметры тюнинга
TUNING_PARAMS = {
	[ TUNING_TASK_COLOR ] = { 0.25, 0.025, 0.025, 0.015, 0.01, 0.025 },
	[ TUNING_TASK_HYDRAULICS ] = { 0.50, 0.05, 0.05, 0.04, 0.02 },
	[ TUNING_TASK_SUSPENSION ] = { 
		[ 0 ] = { 0, 0, 0, 0, 0 },
        [ 1 ] = { 0.2, 0.04, 0.04, 0.03, 0.017 },
        [ 2 ] = { 0.15, 0.03, 0.03, 0.02, 0.015 },
	},
	[ TUNING_TASK_LIGHTSCOLOR ] = { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 },
	[ TUNING_TASK_TONING ] = {
		{ Name = "Сток", 		Level = 120, Price = { 0, 0, 0, 0, 0 } },
		{ Name = "25%", 		Level = 150, Price = { 0.012, 0.012, 0.012, 0.01, 0.006 } },
		{ Name = "50%", 		Level = 180, Price = { 0.014, 0.014, 0.014, 0.012, 0.008 } },
		{ Name = "75% ", 		Level = 220, Price = { 0.017, 0.017, 0.017, 0.014, 0.01 } },
		{ Name = "100%", 		Level = 250, Price = { 0.02, 0.02, 0.02, 0.017, 0.012 } },
	},
	[ TUNING_TASK_WHEELS ] = {
		{ Name = "Shield", 			Level = 1079, Price = 55000 },
		{ Name = "Vossen VPS304", 	Level = 1085, Price = 1200000 },
		{ Name = "BBS Gold", 		Level = 1074, Price = 250000 },
		{ Name = "Spin Aze", 		Level = 1076, Price = 150000 },
		{ Name = "Stance", 			Level = 1084, Price = 100000 },
		{ Name = "Vossen CVT", 		Level = 1097, Price = 450000 },
		{ Name = "Skice", 			Level = 1075, Price = 35000 },
		{ Name = "Vossen", 			Level = 1096, Price = 900000 },
		{ Name = "BBS Steel", 		Level = 1083, Price = 170000 },
		{ Name = "GoldMare", 		Level = 1098, Price = 190000 },
		{ Name = "Rize", 			Level = 1078, Price = 60000 },
		{ Name = "Vossen VPS301", 	Level = 1082, Price = 1750000 },
		{ Name = "Stack", 			Level = 1077, Price = 65000 },
	},
	[ TUNING_TASK_WHEELS_EDIT ] = { 0.075, 0.02, 0.02, 0.015, 0.0075 },
	[ TUNING_TASK_WHEELS_COLOR ] = { 0.09, 0.024, 0.024, 0.018, 0.009 },
}

VEHICLES_NO_NUMBERPLATES = {
	[ 6551 ] = true,
	[ 6552 ] = true,
}

PREMIUM_SETTINGS = {
	cost_by_duration = {
		[1] = 99,
		[3] = 299,
		[7] = 599,
		[14] = 799,
		[30] = 999,
		--[90] = 1999,
	},

	pack_ids = {
		[1] = 10001,
		[3] = 10002,
		[7] = 10003,
		[14] = 10004,
		[30] = 10005,
		--[90] = 1999,
	},

	-- premium discount
	discount_cost_by_duration = {
		[3] = 199,
		[7] = 399,
		[14] = 499,
		[30] = 799,
	},
	discount_pack_ids = {
		[3] = 10006,
		[7] = 10007,
		[14] = 10008,
		[30] = 10009,
	},

	fFactionMoneyMul = 1.5,
	fFactionExpMul = 2,
	fJobExpMul = 2,
	fJobMoneyMul = 1.2,
	fJobMoneyTaskMul = 2,
	fQuestsMoneyMul = 2,
	fQuestsExpMul = 2,
	fBusinessMul = 1.3,
	iFirstAids = 0,
	iCanisters = 1,
	iRepairboxes = 1,
	iTowtrucks = 0,
	bDeathSpawnSelector = true,
	fEXPMul = 2,
	fClanEXPMul = 2,
	fDealerCostMul = 0.85,
	tSkins = { },
	bNeonAccess = true,
	bWindowsColorAccess = true,
	fExpCoefficient = 2,
}

SHOP_SERVICES = {
	{
		sName = "Военный билет",
		iPrice = 399,
		sEvent = "onBuyMilitaryRequest",
	},
	{
		sName = "Сменить ник",
		iPrice = 149,
		sEvent = "onBuyNicknameRequest",
	},
	{
		sName = "Сменить пол",
		iPrice = 199,
		sEvent = "onBuyChangeSexRequest",
	},
	{
		sName = "Выйти из тюрьмы",
		iPrice = 299,
		sEvent = "onBuyJailFreeRequest",
	},
	{
		sName = "Слот для машины",
		iPrice = 50,
		sEvent = "onBuyCarSlotRequest",
	},
	{
		sName = "Слот для скина",
		iPrice = 50,
		sEvent = "onBuySkinSlotRequest",
	},
	{
		sName = "Смена региона номеров",
		iPrice = 199,
		sEvent = "OnPlayerTryBuyNumberRegion",
	},
	{
		sName = "Скрытие ника",
		iPrice = 119,
		iFinishPrice = 49,
	},
	{
		sName = "Смена флага",
		iPrice = 499,
		sEvent = "OnPlayerTryBuyNumberRegion",
	},
	{
		sName = "Свадебный набор",
		iPrice = 499,
	},
	{
		sName = "Бумаги на развод",
		iPrice = 499,
	},
	{
		sName = "Карточка выхода из тюрьмы",
		iPrice = 49,
	},
	{
		sName = "Обнуление социального рейтинга",
		iPrice = 249,
	},
	{
		sName = "Лечение болезни",
		iPrice = 149,
	},
	inventory_player = {
		name = "Расширение инвентаря",
		cost = 99,
		value = 25,
	},
	inventory_vehicle = {
		name = "Расширение инвентаря",
		cost = 49,
		value = 25,
	},
	inventory_house = {
		name = "Расширение инвентаря",
		cost = 99,
		value = 50,
	},
}

-- Радио
VEHICLE_RADIO = {
	{ FriendlyName = "Шансон",				Value = "http://chanson.hostingradio.ru:8041/chanson128.mp3" },
	{ FriendlyName = "Европа Плюс",			Value = "http://ep128.hostingradio.ru:8030/ep128" },
	{ FriendlyName = "Дорожное радио",		Value = "http://dorognoe.hostingradio.ru:8000/radio" },
	{ FriendlyName = "Русское радио",		Value = "http://listen.vdfm.ru:8000/rusradio" },
	{ FriendlyName = "Ретро ФМ",			Value = "http://retroserver.streamr.ru:8043/retro128" },
	{ FriendlyName = "Зайцев.FM",			Value = "https://zaycevfm.cdnvideo.ru/ZaycevFM_pop_128.mp3" },
	{ FriendlyName = "BBC Radio 1Xtra",		Value = "http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio1xtra_mf_p?s=1479892456&e=1479906856&h=ca3ff4bcbacc811fddddecaac280314a", Garage = true },
	{ FriendlyName = "BBC Radio 1", 		Value = "http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio1_mf_p" 	},
	{ FriendlyName = "BBC Radio 2", 		Value = "http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio2_mf_p" 	},
	{ FriendlyName = "NTS Radio",			Value = "http://stream-relay-geo.ntslive.net/stream" },
	{ FriendlyName = "Radio Monte Carlo", 	Value = "https://montecarlo.hostingradio.ru/montecarlo96.aacp" 	},
}

enum "eAccessLevels" {
	"ACCESS_LEVEL_INTERN",
	"ACCESS_LEVEL_HELPER",
	"ACCESS_LEVEL_SENIOR_HELPER",
	"ACCESS_LEVEL_MODERATOR",
	"ACCESS_LEVEL_SENIOR_MODERATOR",
	"ACCESS_LEVEL_GAME_MASTER",
	"ACCESS_LEVEL_ADMIN",
	"ACCESS_LEVEL_SENIOR_ADMIN",
	"ACCESS_LEVEL_SUPERVISOR",
	"ACCESS_LEVEL_HEAD_ADMIN",
	"ACCESS_LEVEL_DEVELOPER",
}

-- Уровни доступа
ACCESS_LEVEL_NAMES = {
	[ 0 ] = "Без прав",
	[ ACCESS_LEVEL_INTERN ] = "Стажёр",
	[ ACCESS_LEVEL_HELPER ] = "Хелпер",
	[ ACCESS_LEVEL_SENIOR_HELPER ] = "Старший Хелпер",
	[ ACCESS_LEVEL_MODERATOR ] = "Модератор",
	[ ACCESS_LEVEL_SENIOR_MODERATOR ] = "Старший Модератор",
	[ ACCESS_LEVEL_GAME_MASTER ] = "Гейм-мастер",
	[ ACCESS_LEVEL_ADMIN ] = "Администратор",
	[ ACCESS_LEVEL_SENIOR_ADMIN ] = "Старший Администратор",
	[ ACCESS_LEVEL_SUPERVISOR ] = "Управляющий сервера",
	[ ACCESS_LEVEL_HEAD_ADMIN ] = "Главный Администратор",
	[ ACCESS_LEVEL_DEVELOPER ] = "Разработчик",
}

-- Жизни автомобиля
VEHICLE_HEALTH_BROKEN		= 360.0
VEHICLE_HEALTH_CRASHED		= 300.0

LICENSES_DATA = {
	[ LICENSE_TYPE_AUTO ] = {
		iPrice = 18750,
		sName = "B",
		bEnabled = true,
	},
	[ LICENSE_TYPE_MOTO ] = {
		iPrice = 11250,
		sName = "A",
		bEnabled = true,
	},
	[ LICENSE_TYPE_TRUCK ] = {
		iPrice = 37500,
		sName = "C",
		bEnabled = true,
	},
	[ LICENSE_TYPE_BUS ] = {
		iPrice = 26250,
		sName = "D",
		bEnabled = true,
	},
	[ LICENSE_TYPE_AIRPLANE ] = {
		iPrice = 48750,
		sName = "Самолёт",
		bEnabled = true,
	},
	[ LICENSE_TYPE_HELICOPTER ] = {
		iPrice = 48750,
		sName = "Вертолёт",
		bEnabled = true,
	},
	[ LICENSE_TYPE_BOAT ] = {
		iPrice = 35000,
		sName = "Морской транспорт",
		bEnabled = true,
	},
}

-- Типы транспорта
VEHICLE_ALLOWED_NOLICENSE = {
	[468] = true,
	[471] = true,
	[572] = true,
}

VEHICLE_TYPE_BIKE = {
	[481] = true,
}

VEHICLE_TYPE_QUAD = {
	[471] = true,
}

DRIVE_TYPE_NAMES = {
	[ "fwd" ] = "Передний",
	[ "rwd" ] = "Задний",
	[ "awd" ] = "Полный",
}

-- Типы звуков
enum "eSoundType" {
	"SOUND_TYPE_2D",
	"SOUND_TYPE_3D",
}

WEAPONS_LIST = {
	[1 ] = { Level = 1, Price = 5000 , Ammo = nil,	Weight = 1  , Icon = "weapon_knuckle"   , Name = "Кастет"               },
	[5 ] = { Level = 1, Price = 10000, Ammo = nil,	Weight = 1  , Icon = "weapon_nightstick", Name = "Бита"                 },
	[16] = { Level = 1,	Price = 30000, Ammo = 6  ,	Weight = 1  , Icon = "16"               , Name = "Граната"              },
	[22] = { Level = 2,	Price = 20000, Ammo = 17 ,	Weight = 0.7, Icon = "22"               , Name = "Макар"                },
	[24] = { Level = 2,	Price = 50000, Ammo = 7  ,	Weight = 1  , Icon = "24"               , Name = "Дигл"                 },
	[25] = { Level = 2,	Price = 35000, Ammo = 30 ,	Weight = 1.5, Icon = "25"               , Name = "Дробовик"             },
	[26] = { Level = 2,	Price = 10000, Ammo = nil,	Weight = 1.5, Icon = "26"               , Name = "Двойной дробовик"     },
	[28] = { Level = 2,	Price = 40000, Ammo = nil,	Weight = 1.5, Icon = "28"               , Name = "Узи"                  },
	[29] = { Level = 2,	Price = 40000, Ammo = 30 ,	Weight = 1.5, Icon = "29"               , Name = "MP5"                  },
	[30] = { Level = 3,	Price = 35000, Ammo = 30 ,	Weight = 1.5, Icon = "30"               , Name = "AK-47"                },
	[31] = { Level = 3,	Price = 40000, Ammo = 90 ,	Weight = 1.5, Icon = "31"               , Name = "М4"                   },
	[32] = { Level = 3,	Price = 30000, Ammo = nil,	Weight = 1.5, Icon = "32"               , Name = "Тек"                  },
	[33] = { Level = 3,	Price = 35000, Ammo = 30 ,	Weight = 1.5, Icon = "33"               , Name = "Ружьё"                },
	[34] = { Level = 2,	Price = 70000, Ammo = 5  ,	Weight = 2  , Icon = "34"               , Name = "Снайперская винтовка" },
	[39] = { Level = 2,	Price = 50000, Ammo = 6  ,	Weight = 1  , Icon = "39"               , Name = "Бомба-липучка"        },
	[41] = { Level = 2,	Price = 50000, Ammo = 150,	Weight = 0.5, Icon = "41"               , Name = "Баллончик"            },
}

DRUGS = {
	{
		name = "Лёд",
		key = "snils",	
		regeneration = 5,
		regeneration_freq = 5,
		damage_mul = 0.95,
		price = 6000,
		duration = 60,
		desc = "Регенерация 5 HP за 5 секунд,\n-5% получения урона. Действует минуту",
		shop_only = "clanpanel",
	},
	{
		name = "Клён",
		key = "maria_ivanovna",
		regeneration = 6,
		regeneration_freq = 5,
		damage_mul = 0.9,
		price = 10600,
		duration = 60,
		desc = "Регенерация 6 HP за 5 секунд,\n-10% получения урона. Действует минуту",
		shop = "dealer",
	},
	{
		name = "Адреналин",
		key = "paketik_shlaka",
		regeneration = 5,
		regeneration_freq = 7,
		damage_mul = 0.85,
		price = 15200,
		duration = 60,
		desc = "Регенерация 7 HP за 5 секунд,\n-15% получения урона. Действует минуту",
		shop = "dealer",
	},
	{
		name = "Петрушка",
		key = "hash_1",
		regeneration = 3,
		regeneration_freq = 2,
		damage_mul = 1,
		duration = 16,
		desc = "Регенерация +3 HP каждые 2 с.\nДействует 16 с.",
	},
	{
		name = "Петрушка",
		key = "hash_2",
		regeneration = 5,
		regeneration_freq = 2,
		damage_mul = 1,
		duration = 20,
		desc = "Регенерация +5 HP каждые 2 с.\nДействует 20 с.",
	},
	{
		name = "Петрушка",
		key = "hash_3",
		regeneration = 9,
		regeneration_freq = 2,
		damage_mul = 1,
		duration = 24,
		desc = "Регенерация +9 HP каждые 2 с.\nДействует 24 с.",
	},
}

ALCOHOLS = {
	{
		add_health = 10,
		duration = 6 * 60,
		desc = "Дает +10% к макс. здоровью на 6 мин.",
	},
	{
		add_health = 20,
		duration = 10 * 60,
		desc = "Дает +20% к макс. здоровью на 10 мин.",
	},
	{
		add_health = 30,
		duration = 15 * 60,
		desc = "Дает +30% к макс. здоровью на 15 мин.",
	}
}

CASES_LIST = {
	[1] = { Name = "Бакланский", Price = 49000, Icon = "case_1", Items = {
		{ ID = 1, Amount = 3 },
		{ ID = 22, Amount = 2 }	} },
	[2] = { Name = "Стандартный", Price = 149000, Icon = "case_2", Items = {
		{ ID = 22, Amount = 4 },
		{ ID = 29, Amount = 2 },
		{ ID = 25, Amount = 1 } } },
	[3] = { Name = "Блатной", Price = 199000, Icon = "case_3", Items = {
		{ ID = 22, Amount = 2 },
		{ ID = 29, Amount = 3 },
		{ ID = 30, Amount = 2 },
		{ ID = 33, Amount = 1 } } },
	[4] = { Name = "Оружейный набор", Price = 0, Icon = "case_3", Items = {
		{ ID = 22, Amount = 1, Hidden = true },
		{ ID = 29, Amount = 1, Hidden = true },
		{ ID = 30, Amount = 1, Hidden = true },
		{ ID = 33, Amount = 1, Hidden = true } } },
	[5] = { Name = "Набор новичка", Price = 0, Icon = "case_3", Items = {
		{ ID = IN_LIGHTARMOR, Amount = 5 },
		{ ID = IN_JAILKEYS, Amount = 1 },
		{ ID = IN_FIRSTAID, Amount = 3 },
		{ ID = IN_REPAIRBOX, Amount = 3 },
		{ ID = IN_CANISTER, Amount = 3 } } },
	[6] = { Name = "Набор любителя", Price = 0, Icon = "case_3", Items = {
		{ ID = IN_MEDIUMARMOR, Amount = 5 },
		{ ID = IN_JAILKEYS, Amount = 3 },
		{ ID = IN_FIRSTAID, Amount = 5 },
		{ ID = IN_REPAIRBOX, Amount = 5 },
		{ ID = IN_CANISTER, Amount = 5 },
		{ ID = IN_VEHPROTECTOR, Amount = 2 },
		{ ID = 22, Amount = 2, Hidden = true } } },
	[7] = { Name = "Набор профи", Price = 0, Icon = "case_3", Items = {
		{ ID = IN_HEAVYARMOR, Amount = 5 },
		{ ID = IN_JAILKEYS, Amount = 5 },
		{ ID = IN_UNFINES, Amount = 15 },
		{ ID = IN_VEHPROTECTOR, Amount = 5 },
		{ ID = 22, Amount = 5, Hidden = true },
		{ ID = 30, Amount = 1, Hidden = true },
		{ ID = 33, Amount = 1, Hidden = true } } },
	[8] = { Name = "(АК-47 х5)", Price = 0, Icon = "case_3", Items = {
		{ ID = 30, Amount = 5, Hidden = true }, } },
	[9] = { Name = "(Гранаты х10)", Price = 0, Icon = "case_3", Items = {
		{ ID = 16, Amount = 10, Hidden = true }, } },
}

-- Родной город
HOMETOWN_NOVOROSSIYSK = 1
HOMETOWN_GORKY = 2
HOMETOWN_MOSCOW = 3

HOMETOWNS = {
	[HOMETOWN_NOVOROSSIYSK] = "Новороссийск",
	[HOMETOWN_GORKY] = "Горки",
	[HOMETOWN_MOSCOW] = "Москва",
}

-- Элементы инвентаря (inventory node)
enum "INVENTORY_NODES" {
    "IN_PASSPORT",
    "IN_JOB_HISTORY",
    "IN_VEHICLE_TEMP_KEY",
    "IN_CASE", -- +
    "IN_REPAIRBOX",
    "IN_FIRSTAID",
    "IN_UNWANTED",
    "IN_NEON",
    "IN_CLOTHES",
    "IN_HIDDEN_WEAPON",
    "IN_DRUGS",
    "IN_WEAPON",
    "IN_HANDS",
    "IN_JAILKEYS",
	"IN_CANISTER",
    "IN_LIGHTARMOR",
    "IN_MEDIUMARMOR",
    "IN_HEAVYARMOR",
    "IN_UNFINES",
    "IN_VEHPROTECTOR",
	"IN_DECAL",
	"IN_PAINTJOB",
    "IN_BOOSTER_DOUBLE_EXP_HOUR",
	"IN_BOOSTER_DOUBLE_EXP_SHIFT",
	"IN_BOOSTER_FREE_REPAIR",
	"IN_BOOSTER_FREE_FUEL",
	"IN_BOOSTER_STAMINA",
	"IN_JAILTIME",
	"IN_VEHICLE_TONER",
	"IN_ANGELA_HANDBAG",
	"IN_NEWYEAR_LETTER",
	"IN_MILITARY",
	"IN_ARMYFREE",
	"IN_SMARTWATCH",
	"IN_RP_CERT",
	"IN_RP_TICKET",
	"IN_VEHICLE_PASSPORT",
	"IN_FOOD",
	"IN_9MAY_RIBBON",
	"IN_1SEPTEMBER_FLOWER",
	"IN_TREASURE_MAP",
	"IN_POLICEID",
	"IN_HDD",
	"IN_TUTORIAL_DOCS",
	"IN_QUEST_MONEY",
	"IN_WEDDING_DIS",
	"IN_WEDDING_START",
	"IN_WEDDING_CHOCO",
	"IN_WEDDING_PANAMHAT",
	"IN_WEDDING_HANDBAG",
	"IN_WEDDING_NECKLACEHOPE",
	"IN_WEDDING_GLASSES_WOODBLACK",
	"IN_MEDBOOK",
	"IN_HOBBY_FISHING_ROD",
	"IN_HOBBY_FISHING_BAIT",
	"IN_HOBBY_HUNTING_RIFFLE",
	"IN_HOBBY_HUNTING_AMMO",
	"IN_HOBBY_DIGGING_SHOVEL",
	"IN_GUN_LICENSE",
	"IN_BAG_MONEY",
	"IN_BATTERY",
	"IN_QUEST_CASE",
	"IN_ASSEMBLY_VEHICLE",
	"IN_FREE_TAXI",
	"IN_TUTORIAL_HASH",
	"IN_BOTTLE_DIRTY",
	"IN_BOTTLE",
	"IN_ALCO",
	"IN_HASH_RAW",
	"IN_HASH_DRY",
	"IN_HASH",

	"IN_FOOD_LUNCHBOX",  -- прописать в SHunger_Shop.lua
	"IN_FOOD_SALAD",
	"IN_FOOD_SOUP",
	"IN_FOOD_NAVY_PASTA",
	"IN_FOOD_CARBONARA",
	"IN_FOOD_UKHA",
	"IN_FOOD_OMELETTE",
	"IN_FOOD_SPAGHETTI_FANICINI",
	"IN_FOOD_FISH_WITH_VEGETABLES",
	"IN_FOOD_CHEESE_SANDWICH",

	"IN_WEAPON_1_BRASSKNUCKLE",
	"IN_WEAPON_2_GOLFCLUB",
	"IN_WEAPON_3_NIGHTSTICK",
	"IN_WEAPON_4_KNIFE",
	"IN_WEAPON_5_BAT",
	"IN_WEAPON_6_SHOVEL",
	"IN_WEAPON_7_POOLSTICK",
	"IN_WEAPON_8_KATANA",
	"IN_WEAPON_9_CHAINSAW",
	"IN_WEAPON_10_DILDO",
	"IN_WEAPON_11_DILDO",
	"IN_WEAPON_12_VIBRATOR",
	"IN_WEAPON_13_VIBRATOR",
	"IN_WEAPON_14_FLOWER",
	"IN_WEAPON_15_CANE",
	"IN_WEAPON_16_GRENADE",
	"IN_WEAPON_17_TEARGAS",
	"IN_WEAPON_18_MOLOTOV",
	"IN_WEAPON_19_ROCKET",
	"IN_WEAPON_20_ROCKET",
	"IN_WEAPON_21_FREEFALL_BOMB",
	"IN_WEAPON_22_COLT_45",
	"IN_WEAPON_23_SILENCED",
	"IN_WEAPON_24_DEAGLE",
	"IN_WEAPON_25_SHOTGUN",
	"IN_WEAPON_26_SAWEDOFF",
	"IN_WEAPON_27_COMBAT_SHOTGUN",
	"IN_WEAPON_28_UZI",
	"IN_WEAPON_29_MP5",
	"IN_WEAPON_30_AK47",
	"IN_WEAPON_31_M4",
	"IN_WEAPON_32_TEC9",
	"IN_WEAPON_33_RIFLE",
	"IN_WEAPON_34_SNIPER",
	"IN_WEAPON_35_ROCKET_LAUNCHER",
	"IN_WEAPON_36_ROCKET_LAUNCHER_HS",
	"IN_WEAPON_37_FLAMETHROWER",
	"IN_WEAPON_38_MINIGUN",
	"IN_WEAPON_39_SATCHEL",
	"IN_WEAPON_40_BOMB",
	"IN_WEAPON_41_SPRAYCAN",
	"IN_WEAPON_42_FIRE_EXTINGUISHER",
	"IN_WEAPON_43_CAMERA",
	"IN_WEAPON_44_NIGHTVISION",
	"IN_WEAPON_45_INFRARED",
	"IN_WEAPON_46_PARACHUTE",
	"IN_TUTORIAL_CANISTER",
}

-- Статьи розыска
WANTED_REASONS_LIST = {
	["1.1"] = { name = "Убийство", desc = "Умышленное убийство другого игрока", duration = 30 },
	["1.2"] = { name = "Нарушение общественного порядка", desc = "Нарушение общественного порядка", duration = 5 },
	["1.3"] = { name = "Нападение на гос.служащего", desc = "Нападение на гос.служащего", duration = 20 },
	["1.4"] = { name = "Нападение на гражданского", desc = "Нападение на гражданского", duration = 10 },
	["1.5"] = { name = "Порча имущества", desc = "Умышленная порча частной собственности", duration = 15 },
	["1.6"] = { name = "Порча имущества", desc = "Умышленная порча государственной собственности", duration = 5 },
	["1.7"] = { name = "Вандализм", desc = "Порча общественной собственности (граффити)", duration = 5 },
	["1.8"] = { name = "Неподчинение", desc = "Неподчинение требованиям сотрудника гос.органов при исполнении", duration = 15 },
	["1.9"] = { name = "Ношение огнестрельного оружия", desc = "Выстрел из огнестрельно оружия", duration = 15 },
	["1.11"] = { name = "Неуплата штрафов", desc = "Сумма штрафов привысила 60 000 рублей", duration = 30 },
	["1.13"] = { name = "Хранение запрещенного оружия", desc = "Хранение оружия без лицензии", duration = 10 },
	["1.14"] = { name = "Нападение на инкассацию", desc = "Умышленное нанесение ущерба сотрудникам инкассации", duration = 20 },
	["2.1"] = { name = "ДТП", desc = "Скрыться с места ДТП", duration = 15 },
	["3.1"] = { name = "Побег", desc = "Побег из мест заключения", duration = 15 },
}

-- Штрафы
FINES_LIST = 
{
	[ 1 ] = {
		id = "1.8",
		name = "Неподчинение",
		cost = 1000,
		desc = "Неподчинение сотрудникам госорганов при исполнении",
	},
	[ 2 ] = {
		id = "1.10",
		name = "Ложный вызов",
		cost = 1000,
		desc = "Ложный вызов гос.сотрудников",
	},
	[ 3 ] = {
		id = "2.3",
		name = "Езда на поврежденном авто",
		cost = 150,
		desc = "Езда на дымящимся транспорте",
	},
	[ 4 ] = {
		id = "2.4",
		name = "Помеха движению",
		cost = 1000,
		desc = "Умышленное создание помехи транспортному потоку",
	},
	[ 5 ] = {
		id = "2.5",
		name = "Проезд через двойную сплошную",
		cost = 1500,
		desc = "Умышленый проезд через двойную сплошную",
	},
	[ 6 ] = {
		id = "2.6",
		name = "Езда по тротуарам",
		cost = 500,
		desc = "Умышленная езда не по проезжей части",
	},
	[ 7 ] = {
		id = "2.7",
		name = "Езда по обочине",
		cost = 500,
		desc = "Умышленная езда не по проезжей части",
	},
	[ 8 ] = {
		id = "2.8",
		name = "Проезд на красный свет светофора",
		cost = 1500,
		desc = "Проезд на красный свет светофора",
	},
	[ 9 ] = {
		id = "2.9",
		name = "Превышение скорости",
		cost = 1000,
		desc = "Превышение допустимой скорости, через фото фиксацию",
		manual_disabled = true,
	},
	[ 10 ] = {
		id = "2.10",
		name = "Нарушение требований сотрудника ДПС",
		cost = 3000,
		desc = "Нарушение требований сотрудника ДПС",
	},
	[ 11 ] = {
		id = "2.13",
		name = "Несоблюдение знаков правил дорожного движения",
		cost = 1000,
		desc = "Несоблюдение знаков правил дорожного движения",
	},
	[ 12 ] = {
		id = "2.14",
		name = "Виновник ДТП",
		cost = 1500,
		desc = "Виновник дорожно-транспортного происшествия",
	},
	[ 13 ] = {
		id = "2.15",
		name = "Езда по встречной полосе",
		cost = 2000,
		desc = "Умышленная езда по встречной полосе движения",
	},
	[ 14 ] = {
		id = "1.12",
		name = "Выход из игры во время РП процесса",
		cost = 3000,
		desc = "Вы вышли во время игры во время РП процесса",
	},
	[ 15 ] = {
		id = "1.13",
		name = "Хранение запрещенного оружия",
		cost = 10000,
		desc = "Хранение огнестрельного оружия без лицензии",
	},
	[ 16 ] = {
		id = "1.5",
		name = "Порча имущества",
		cost = 1500,
		desc = "Умышленная порча частной собственности",
	},
}

enum "eBoosterType" {
	"BOOSTER_DOUBLE_EXP",
	"BOOSTER_DOUBLE_MONEY",
	"BOOSTER_EXTENDED_SHIFT",
}

BOOSTERS_LIST = {
	[BOOSTER_DOUBLE_EXP] = {
		sDesc = "Опыт на\nработе на %s",
		iDuration = 60*60,
	},
	[BOOSTER_DOUBLE_MONEY] = {
		sDesc = "Денег на\nработе на %s",
		iDuration = 60*60,
	},
	[BOOSTER_EXTENDED_SHIFT] = {
		sDesc = "Час к смене\n на работе",
		iDuration = 60*60*24,
	},
}

REGISTERED_QUESTS = {
	"alexander_get_vehicle_bike",
	"jeka_testdrive",
	"oleg_courier",
	"angela_cinema",
	"alexander_debt",
	"alexander_talks",
	"angela_risks",
	"oleg_govhelp",
	"oleg_parkemployee",
	"jeka_race",
	"jeka_capture",
	"angela_dance_school",
	"ksusha_hotel",
	"fast_delivery",
	"return_of_history",
	"protection",
	"angela_problems",
	"long_awaited_meeting",
	"delivery_of_goods",
	"rescue_operation",
	"return_of_property",
	"unconscious_betrayal",
	"beginning_proceedings",
	"real_initiative",
	"good_game",
	"murderous_setup",
	"crazy_vacation",
	"the_inevitable_path",
	"possible_exposure",
	"bloody_forest",
	"long_awaited_revenge",
}

REGISTERED_URGENT_MILITARY_TASKS = {
	"military_3",
	"military_2",
	--"military_1",
}

URGENT_MILITARY_DIMENSION = 24242

URGENT_MILITARY_SKINS_BY_GENDER = {
	[0] = 128,
	[1] = 93,
}

URGENT_MILITARY_VACATION_TIMEOUT = 1200
URGENT_MILITARY_VACATION_LEN = 7200

URGENT_MILITARY_VACATION_FINE_EXP = 200

LEVELS_EXPERIENCE = {
	[1] = 2000,
	[2] = 3000,
	[3] = 4000,
	[4] = 6000,
	[5] = 8000,
	[6] = 10000,
	[7] = 15000,
	[8] = 20000,
	[9] = 25000,
	[10] = 30000,
	[11] = 35000,
	[12] = 40000,
	[13] = 45000,
	[14] = 50000,
	[15] = 55000,
	[16] = 60000,
	[17] = 70000,
	[18] = 75000,
	[19] = 80000,
	[20] = 90000,
	[21] = 105000,
	[22] = 125000,
	[23] = 145000,
}

for i = 24, 98 do
	LEVELS_EXPERIENCE[ i ] = LEVELS_EXPERIENCE[ i - 1 ] * 2
end

LEVELS_PASSIVE_EXPERIENCE = {
	[1] = 0,
	[2] = 25,
	[3] = 30,
	[4] = 35,
	[5] = 40,
	[6] = 45,
	[7] = 50,
	[8] = 55,
	[9] = 60,
	[10] = 65,
	[11] = 70,
	[12] = 85,
	[13] = 90,
	[14] = 110,
	[15] = 120,
	[16] = 130,
	[17] = 140,
	[18] = 150,
	[19] = 160,
	[20] = 180,
	[21] = 210,
	[22] = 220,
	[23] = 230,
}

for i = 24, 99 do
	LEVELS_PASSIVE_EXPERIENCE[ i ] = LEVELS_PASSIVE_EXPERIENCE[ i - 1 ] + 10
end

FACTION_DUTY_VALUE_FOR_DAY_OFF = 30
FACTION_DAY_OFF_VALUE = 7 -- 7 days
FACTION_JOIN_TIMEOUT = {
	himself = 3600 * 24 * 3,
	leader = 3600 * 24 * 5,
}

FACTION_PASSIVE_EXP = 100
FACTION_PASSIVE_RANK_EXP = 10

QUESTS_NPC = {
	[5] = {
		id = "angela",
		name = "Анжела",
		model = 131,
		position = Vector3( 1966.606, -244.374 + 860, 60.437 ),
		rotation = 132,
		interior = 0,
		dimension = 0,
		anim = {"bar", "barcustom_loop"},
		camera_to = { 1964.7762451172, -245.5888671875 + 860, 61.264789581299, 2059.5424804688, -217.80999755859 + 860, 46.334213256836, 0, 70 },
		player_position = Vector3( 1965.7386474609, -245.71063232422 + 860, 60.437831878662 ),
		player_rotation = 301,
		condition = function( self, data )
			return true
		end,
	},
	[ 6 ] = {
		id = "roman_near_house",

		name = "Роман",
		model = 205,  -- Оригинал 6733
		position = Vector3( 565.74, -519.72 + 860, 21.78 ),
		rotation = 0,
		interior = 0,
		dimension = 0,
		anim = {"bar", "barcustom_loop"},
		camera_to = { 564.46240234375, -517.53198242188 + 860, 22.864450454712, 615.95111083984, -599.90936279297 + 860, -0.86056792736053, 0, 70 },
		player_position = Vector3( 565.729, -518.983 + 860, 21.774 ),
		player_rotation = 181,
		condition = function( self, data )
			return true
		end,
	},
	[ 8 ] = {
		id = "head_western_cartel",
		name = "Глава западного картеля",
		model = 262,
		position = Vector3( 435.27, -1201.32, 1101.2 ),
		rotation = -90,
		interior = 1,
		dimension = 0,
		anim = {"bar", "barcustom_loop"},
		camera_to = { 437.27520751953, -1202.7087402344, 1102.4763183594, 357.85104370117, -1144.990234375, 1083.4925537109, 0, 70 },
		player_position = Vector3( 436.328, -1201.374, 1101.285 ),
		player_rotation = 90,
		condition = function( self, data )
			return true
		end,
	},
	[80] = {
		id = "ksusha",
		name = "Ксюша",
		model = 80,
		position = Vector3( 1967.589, -245.229 + 860, 60.431 ),
		rotation = 124,
		interior = 0,
		dimension = 0,
		anim = {"bar", "barcustom_loop"},
		camera_to = { 1965.4796142578, -246.48565673828 + 860, 61.310264587402, 2060.7409667969, -222.13592529297 + 860, 42.180828094482, 0, 70 },
		player_position = Vector3( 1966.460, -246.563 + 860, 60.430 ),
		player_rotation = 300,
		condition = function( self, data )
			local quests_enabled = localPlayer:getData( "quests_enabled" ) or { }
			return data and data.available and ( data.available.ksusha_hotel and quests_enabled.ksusha_hotel or data.available.return_of_property )
		end,
	},
	[ 108 ] = {
		id = "west_cartel_guard",
		name = "Охранник",
		model = 259,
		position = Vector3( -1942.9030, 680.8471, 18.3314 ),
		rotation = 278,
		interior = 0,
		dimension = 0,
		anim = {"bar", "barcustom_loop"},
		camera_to = { -1941.4010, 681.0048, 19.2556, -2038.4276, 678.2645, -4.1929, 0, 70 },
		player_position = Vector3( -1942.3248, 681.0596, 18.3151 ),
		player_rotation = 97,
		condition = function( self, data )
			return true
		end,
	},
	[ 108 ] = {
		id = "west_cartel_guard",
		name = "Охранник",
		model = 259,
		position = Vector3( -1942.9030, 680.8471 + 860, 18.3314 ),
		rotation = 278,
		interior = 0,
		dimension = 0,
		anim = {"bar", "barcustom_loop"},
		camera_to = { -1941.4010, 681.0048 + 860, 19.2556, -2038.4276, 678.2645 + 860, -4.1929, 0, 70 },
		player_position = Vector3( -1942.3248, 681.0596 + 860, 18.3151 ),
		player_rotation = 97,
		condition = function( self, data )
			return true
		end,
	},
	[ 109 ] = {
		id = "angela_rublevo_near_house",

		name = "Анжела",
		model = 131,
		position = Vector3( 672.96, -79.15 + 860, 20.9353 ),
		rotation = 180,
		interior = 0,
		dimension = 0,
		anim = {"bar", "barcustom_loop"},

		camera_to =  { 672.67474365234, -80.781150817871 + 860, 21.899507522583, 689.17639160156, 15.563193321228 + 860, 0.7935363650322, 0, 70 },
		player_position = Vector3( 672.9379, -79.9736 + 860, 20.9353 ),
		player_rotation = 0,

		condition = function( self, data )
			return true
		end,
	},
	[13] = {
		name = "Прапорщик",
		model = 126,
		position = Vector3(-2411.671, 781.708, 20.295),
		cam_position = Vector3(-2410.225, 781.744, 20.998),
		rotation = 260,
		dimension = URGENT_MILITARY_DIMENSION,
		point_position = Vector3( -2410.225, 781.744, 20 ),
		non_movable = true,
		anim = {"bar", "barcustom_loop"},
	},
	[14] = {
		name = "Лейтенант",
		model = 167,
		position = Vector3( -363.733, -788.347, 1061.424 ),
		rotation = 167,
		interior = 1,
		dimension = 1,
		non_movable = true,
		cam_position = Vector3( -363.74389648438, -789.80010986328, 1062.0611572266 ),
		point_position = Vector3( -363.645, -791.166, 1061.424 ),
		anim = {"bar", "barcustom_loop"},
	},
	[15] = {
		name = "Лейтенант",
		model = 167,
		position = Vector3( 1954.5, 132.941, 631.421 ),
		rotation = 171,
		interior = 1,
		dimension = 1,
		non_movable = true,
		cam_position = Vector3( 1954.3758544922, 131.48860168457, 632.08190917969 ),
		point_position = Vector3( 1954.273, 130.248, 631.421 ),
		anim = {"bar", "barcustom_loop"},
	},
	[16] = {
		name = "Доктор",
		model = 152,
		position = Vector3( 440.276, -1597.650, 1020.968 ),
		rotation = 188,
		interior = 1,
		dimension = 1,
		non_movable = true,
		cam_position = Vector3( 440.33020019531, -1599.3391113281, 1021.599609375 ),
		point_position = Vector3( 440.200, -1600.423, 1020.968 ),
		anim = {"bar", "barcustom_loop"},
	},
	[17] = {
		name = "Доктор",
		model = 152,
		position = Vector3( 1934.713, 313.360, 660.966 ),
		rotation = 184,
		interior = 1,
		dimension = 1,
		non_movable = true,
		cam_position = Vector3( 1934.9827880859, 312.04418945313, 661.65789794922 ),
		point_position = Vector3( 1934.190, 310.467, 660.966 ),
		anim = {"bar", "barcustom_loop"},
	},
	[18] = {
		name = "Лейтенант",
		model = 244,
		position = Vector3( 338.065, -1177.517, 1021.584 ),
		rotation = 173,
		interior = 1,
		dimension = 1,
		non_movable = true,
		cam_position = Vector3( 338.18930053711, -1179.0571289063, 1022.2232055664 ),
		point_position = Vector3( 337.996, -1180.206, 1021.584 ),
		anim = {"bar", "barcustom_loop"},
	},
	[19] = {
		name = "Лейтенант",
		model = 244,
		position = Vector3( 2195.8, 223.8, 601.002 ),
		rotation = 178,
		interior = 1,
		dimension = 1,
		non_movable = true,
		cam_position = Vector3( 2195.1525878906, 222.05239868164, 601.60559082031 ),
		point_position = Vector3( 2195.043, 220.833, 601.002 ),
		anim = {"bar", "barcustom_loop"},
	},
	[20] = {
		name = "Прапорщик",
		model = 126,
		position = Vector3(-2411.671, -79.708 + 860, 20.295),
		cam_position = Vector3(-2410.225, -79.744 + 860, 20.998),
		rotation = 260,
		non_movable = true,
		point_position = Vector3( -2410.225, -79.744 + 860, 20 ),
		anim = {"bar", "barcustom_loop"},
	},
	[21] = {
		name = "Клерк Федя",
		model = 1,
		position = Vector3( -11.971, -859.374, 1047.537 ),
		cam_position = Vector3( -11.558799743652, -861.46228027344, 1048.0739746094 ),
		rotation = 180,
		non_movable = true,
		interior = 1,
		dimension = 1,
		point_position = Vector3( -11.636, -861.620, 1047.537 ),
	},
	[22] = {
		name = "Клерк Петя",
		model = 1,
		position = Vector3( 2308.867, -56.292, 671.013 ),
		cam_position = Vector3( 2309.4094238281, -57.928890228271, 671.56707763672 ),
		rotation = 191,
		non_movable = true,
		interior = 1,
		dimension = 1,
		point_position = Vector3( 2309.163, -58.328, 671.013 ),
	},
	[24] = {
		name = "Лейтенант",
		model = 172,
		position = Vector3( -2658.089, 2840.229, 1540.466 ),
		rotation = 167,
		interior = 1,
		dimension = 1,
		non_movable = true,
		cam_position = Vector3( -2656.1101, 2836.2568, 1541.1746 ),
		point_position = Vector3( -2656.2421, 2840.2041, 1540.4663 ),
		anim = {"bar", "barcustom_loop"},
	},
	[25] = {
		name = "Лейтенант",
		model = 244,
		position = Vector3( -2037.1262207031, 1898.7932128906, 1647.4106445313 ),
		rotation = 178,
		interior = 1,
		dimension = 1,
		non_movable = true,
		cam_position = Vector3( -2037.9567871094, 1897.0020751953, 1647.7885742188 ),
		point_position = Vector3( -2037.1262207031, 1898.7932128906, 1647.4106445313 ),
		anim = {"bar", "barcustom_loop"},
	},
	[26] = {
		name = "Лейтенант",
		model = 167,
		position = Vector3( -1664.6494140625, 2643.5473632813, 1899.0100097656 ),
		rotation = 180,
		interior = 1,
		dimension = 1,
		non_movable = true,
		cam_position = Vector3( -1664.6029052734, 2642.3234863281, 1899.7777099609 ),
		point_position = Vector3( -1664.6494140625, 2643.5473632813, 1899.0100097656 ),
		anim = {"bar", "barcustom_loop"},
	},

	[72] = {
		id = "alexander",
		name = "Александр",
		model = 72,
		position = Vector3( 1763.129, -636.875 + 860, 60.856 ),
		rotation = 292,
		interior = 0,
		dimension = 0,
		radius = 2,
		camera_to = { 1764.85, -634.96 + 860, 61.86, 1700.66, -709.32 + 860, 43.14, 0, 70 },
		player_position = Vector3( 1764.321, -636.518 + 860, 60.856 ),
		player_rotation = 98,
	},

	[107] = {
		id = "jeka",
		name = "Жека",
		model = 107,
		position = Vector3( 1803.132, -701.700 + 860, 60.670 ),
		rotation = 0,
		interior = 0,
		dimension = 0,
		camera_to = { 1803.96484375, -699.73663330078 + 860, 61.501457214355, 1752.8323974609, -783.00163269043 + 860, 47.167930603027, 0, 70 },
		player_position = Vector3( 1803.251, -700.941 + 860, 60.667 ),
		player_rotation = 165,
	},

	[154] = {
		id = "oleg",
		name = "Олег",
		model = 154,
		position = Vector3( 1892.031, -782.807 + 860, 60.707 ),
		rotation = 200,
		interior = 0,
		dimension = 0,
		camera_to = { 1892.1201171875, -784.385726928711 + 860, 61.525260925293, 1895.8022460938, -686.97254943848 + 860, 45.182704925537, 0, 70 },
		player_position = Vector3( 1892.399, -783.566 + 860, 60.707 ),
		player_rotation = 16.2,
	},

	[286] = {
		id = "inspektor_dps",
		name = "Инспектор",
		model = 286,
		position = Vector3( 2195.8, 223.8, 601.002 ),
		rotation = 171,
		interior = 1,
		dimension = "UNIQUE_DIMENSION",
		non_movable = true,
		camera_to = { 2194.5971679688, 220.01824951172, 601.92407226563, 2234.3444824219, 310.65902709961, 587.62713623047, 0, 70 },
		player_position = Vector3( 2195.6726074219, 221.25318908691, 601.00189208984 ),
		player_rotation = 358,
	},
	[287] = {
		id = "inspector_pps",
		name = "Инспектор",
		model = 125,
		position = Vector3( 1954.5, 132.941, 631.421 ),
		rotation = 171,
		interior = 1,
		dimension = "UNIQUE_DIMENSION",
		non_movable = true,
		cam_position = Vector3( 1954.3758544922, 131.48860168457, 632.08190917969 ),
		point_position = Vector3( 1954.273, 130.248, 631.421 ),
		anim = {"bar", "barcustom_loop"},
	},
	[288] = {
		name = "Платный Врач",
		model = 41,
		position = Vector3( 1938.660, 313.363, 660.966 ),
		rotation = 180,
		interior = 1,
		dimension = 1,
		non_movable = true,
	},
	[289] = {
		name = "Платный Врач",
		model = 41,
		position = Vector3( 444.332, -1597.650, 1020.968 ),
		rotation = 180,
		interior = 1,
		dimension = 1,
		non_movable = true,
	},

	[1000] = {
		name = "Барыга",
		model = 227,
		position = Vector3( 1321.9,-2062.4 + 860,20.7 ),
		rotation = 0,
		interior = 0,
		dimension = 0,
		non_movable = true,
	},
	[1001] = {
		id = "huckster",
		
		name = "Барыга",
		model = 227,
		position = Vector3( -1361.5,232 + 860,18.95 ),
		rotation = 0,
		interior = 0,
		dimension = 0,
		camera_to = { -1361.3363037109, 233.6594543457 + 860, 19.821645736694, -1369.7991943359, 135.88082885742 + 860, 0.64560753107071, 0, 70 },
		player_position = Vector3( -1361.606, 232.692 + 860, 18.983 ),
		player_rotation = 189,
		non_movable = true,
	},
}

MILITARY_LEVEL_NAMES = {
	[1] = "Рядовой",
	[2] = "Ефрейтор",
	[3] = "Мл. сержант",
	[4] = "Сержант",
}

MILITARY_EXPERIENCE = {
	[0] = 0,
	[1] = 500,
	[2] = 1000,
	[3] = 1500,
}

enum "FACTIONS_LIST" {
	"F_ARMY",
	"F_POLICE_PPS_NSK",
	"F_POLICE_DPS_NSK",
	"F_MEDIC",
	"F_POLICE_PPS_GORKI",
	"F_POLICE_DPS_GORKI",
	"F_GOVERNMENT_NSK",
	"F_GOVERNMENT_GORKI",
	"F_FSIN",
	"F_POLICE_PPS_MSK",
	"F_POLICE_DPS_MSK",
	"F_MEDIC_MSK",
	"F_GOVERNMENT_MSK",
}

FACTIONS_NAMES = {
	[ F_ARMY ] = "Армия",
	[ F_POLICE_PPS_NSK ] = "ППС Новороссийска",
	[ F_POLICE_DPS_NSK ] = "ДПС Новороссийска",
	[ F_MEDIC ] = "Медики",
	[ F_MEDIC_MSK ] = "Медики Москвы",
	[ F_POLICE_PPS_GORKI ] = "ППС Горки Город",
	[ F_POLICE_DPS_GORKI ] = "ДПС Горки Город",
	[ F_GOVERNMENT_NSK ] = "Мэрия Новороссийска",
	[ F_GOVERNMENT_GORKI ] = "Мэрия Горки Город",
	[ F_FSIN			 ] = "ФСИН",
	[ F_POLICE_PPS_MSK ] = "ППС Москвы",
	[ F_POLICE_DPS_MSK ] = "ДПС Москвы",
	[ F_GOVERNMENT_MSK ] = "Мэрия Москвы",
}

FACTION_HOMETOWN = {
	[ F_ARMY ] 				= HOMETOWN_NOVOROSSIYSK,
	[ F_POLICE_PPS_NSK ] 	= HOMETOWN_NOVOROSSIYSK,
	[ F_POLICE_DPS_NSK ] 	= HOMETOWN_NOVOROSSIYSK,
	[ F_MEDIC ] 			= HOMETOWN_NOVOROSSIYSK,
	[ F_MEDIC_MSK ] 		= HOMETOWN_MOSCOW,
	[ F_POLICE_PPS_GORKI ] 	= HOMETOWN_GORKY,
	[ F_POLICE_DPS_GORKI ] 	= HOMETOWN_GORKY,
	[ F_GOVERNMENT_NSK ] 	= HOMETOWN_NOVOROSSIYSK,
	[ F_GOVERNMENT_GORKI ] 	= HOMETOWN_GORKY,
	[ F_FSIN ] 				= HOMETOWN_NOVOROSSIYSK,
	[ F_POLICE_PPS_MSK ] 	= HOMETOWN_MOSCOW,
	[ F_POLICE_DPS_MSK ] 	= HOMETOWN_MOSCOW,
	[ F_GOVERNMENT_MSK ] 	= HOMETOWN_MOSCOW,
}

FACTIONS_ENG_NAMES = {
	[ F_ARMY ] = "army",
	[ F_POLICE_PPS_NSK ] = "police_pps_nsk",
	[ F_POLICE_DPS_NSK ] = "police_dps_nsk",
	[ F_MEDIC ] = "medic",
	[ F_MEDIC_MSK ] = "medic_msk",
	[ F_POLICE_PPS_GORKI ] = "police_pps_gorki",
	[ F_POLICE_DPS_GORKI ] = "police_dps_gorki",
	[ F_GOVERNMENT_NSK ] = "government_nsk",
	[ F_GOVERNMENT_GORKI ] = "government_gorki",
	[ F_GOVERNMENT_MSK ] = "government_msk",
	[ F_FSIN ] = "fsin",
	[ F_POLICE_PPS_MSK ] = "police_pps_msk",
	[ F_POLICE_DPS_MSK ] = "police_dps_msk",
}

POLICEID_FACTIONS = {
    [ F_ARMY ] = true,
	[ F_POLICE_PPS_NSK ] = true,
	[ F_POLICE_DPS_NSK ] = true,
	[ F_MEDIC ] = true,
	[ F_MEDIC_MSK ] = true,
	[ F_POLICE_PPS_GORKI ] = true,
	[ F_POLICE_DPS_GORKI ] = true,
	[ F_GOVERNMENT_NSK ] = true,
	[ F_GOVERNMENT_GORKI ] = true,
	[ F_GOVERNMENT_MSK ] = true,
	[ F_FSIN ] = true,
	[ F_POLICE_PPS_MSK ] = true,
	[ F_POLICE_DPS_MSK ] = true,
}

FACTIONS_BY_CITYHALL = {
	[ F_GOVERNMENT_NSK ] = F_GOVERNMENT_NSK;
	[ F_ARMY ] = F_GOVERNMENT_NSK;
	[ F_POLICE_PPS_NSK ] = F_GOVERNMENT_NSK;
	[ F_MEDIC ] = F_GOVERNMENT_NSK;
	[ F_POLICE_DPS_NSK ] = F_GOVERNMENT_NSK;
	[ F_FSIN ] = F_GOVERNMENT_NSK;

	[ F_GOVERNMENT_GORKI ] = F_GOVERNMENT_GORKI;
	[ F_POLICE_PPS_GORKI ] = F_GOVERNMENT_GORKI;
	[ F_POLICE_DPS_GORKI ] = F_GOVERNMENT_GORKI;

	[ F_MEDIC_MSK ] = F_GOVERNMENT_MSK,
	[ F_POLICE_PPS_MSK ] = F_GOVERNMENT_MSK,
	[ F_POLICE_DPS_MSK ] = F_GOVERNMENT_MSK,
	[ F_GOVERNMENT_MSK ] = F_GOVERNMENT_MSK,
}

FACTIONS_LEVEL_NAMES = {
	[ F_ARMY ] = {
		[1] = "Сержант",
		[2] = "Старший сержант",
		[3] = "Старшина",
		[4] = "Прапорщик",
		[5] = "Старший прапорщик",
		[6] = "Лейтенант",
		[7] = "Старший лейтенант",
		[8] = "Капитан",
		[9] = "Майор",
		[10] = "Подполковник",
		[11] = "Полковник",
		[12] = "Генерал армии",
	},

	[ F_POLICE_PPS_NSK ] = {
		[1] = "Сержант",
		[2] = "Старший сержант",
		[3] = "Старшина",
		[4] = "Прапорщик",
		[5] = "Старший прапорщик",
		[6] = "Лейтенант",
		[7] = "Старший лейтенант",
		[8] = "Капитан",
		[9] = "Майор",
		[10] = "Подполковник",
		[11] = "Полковник",
		[12] = "Генерал МВД ППС",
	},

	[ F_POLICE_DPS_NSK ] = {
		[1] = "Сержант",
		[2] = "Старший сержант",
		[3] = "Старшина",
		[4] = "Прапорщик",
		[5] = "Старший прапорщик",
		[6] = "Лейтенант",
		[7] = "Старший лейтенант",
		[8] = "Капитан",
		[9] = "Майор",
		[10] = "Подполковник",
		[11] = "Полковник",
		[12] = "Генерал МВД ДПС",
	},

	[ F_MEDIC ] = {
		[1] = "Санитар",
		[2] = "Фармацевт",
		[3] = "Фельдшер",
		[4] = "Старший Провизор",
		[5] = "Врач-методист",
		[6] = "Врач-терапевт",
		[7] = "Врач-лаборант",
		[8] = "Врач-специалист",
		[9] = "Врач-психиатр",
		[10] = "Врач-хирург",
		[11] = "Зам. глав. врача",
		[12] = "Главный врач",
	},

	[ F_GOVERNMENT_NSK ] = {
		[1] = "Волонтер",
		[2] = "Работник Мэрии",
		[3] = "Охранник",
		[4] = "Зам. нач. охраны",
		[5] = "Начальник охраны",
		[6] = "Зам. Ген. прокурора",
		[7] = "Генеральный прокурор",
		[8] = "Министр финансов",
		[9] = "Министр транспорта",
		[10] = "Министр культуры",
		[11] = "Заместитель Мэра",
		[12] = "Мэр",
	},

	[ F_FSIN ] = {
		[1] = "Сержант",
		[2] = "Старший сержант",
		[3] = "Старшина",
		[4] = "Прапорщик",
		[5] = "Старший прапорщик",
		[6] = "Лейтенант",
		[7] = "Старший лейтенант",
		[8] = "Капитан",
		[9] = "Майор",
		[10] = "Подполковник",
		[11] = "Полковник",
		[12] = "Генерал ФСИН",
	},
}
FACTIONS_LEVEL_NAMES[ F_POLICE_PPS_GORKI ] = FACTIONS_LEVEL_NAMES[ F_POLICE_PPS_NSK ]
FACTIONS_LEVEL_NAMES[ F_POLICE_PPS_MSK ] = FACTIONS_LEVEL_NAMES[ F_POLICE_PPS_NSK ]
FACTIONS_LEVEL_NAMES[ F_POLICE_DPS_GORKI ] = FACTIONS_LEVEL_NAMES[ F_POLICE_DPS_NSK ]
FACTIONS_LEVEL_NAMES[ F_POLICE_DPS_MSK ] = FACTIONS_LEVEL_NAMES[ F_POLICE_DPS_NSK ]
FACTIONS_LEVEL_NAMES[ F_GOVERNMENT_GORKI ] = FACTIONS_LEVEL_NAMES[ F_GOVERNMENT_NSK ]
FACTIONS_LEVEL_NAMES[ F_GOVERNMENT_MSK ] = FACTIONS_LEVEL_NAMES[ F_GOVERNMENT_NSK ]
FACTIONS_LEVEL_NAMES[ F_MEDIC_MSK ] = FACTIONS_LEVEL_NAMES[ F_MEDIC ]

FACTIONS_SHORT_NAMES = {
	[ F_ARMY ] = "Армия",
	[ F_POLICE_PPS_NSK ] = "ППС НСК",
	[ F_POLICE_DPS_NSK ] = "ДПС НСК",
	[ F_MEDIC ] = "Медики",
	[ F_MEDIC_MSK ] = "Медики МСК",
	[ F_POLICE_PPS_GORKI ] = "ППС Горки",
	[ F_POLICE_DPS_GORKI ] = "ДПС Горки",
	[ F_GOVERNMENT_NSK ] = "Мэрия НСК",
	[ F_GOVERNMENT_GORKI ] = "Мэрия Горки",
	[ F_GOVERNMENT_MSK ] = "Мэрия МСК",
    [ F_FSIN ] = "ФСИН",
	[ F_POLICE_PPS_MSK ] = "ППС МСК",
	[ F_POLICE_DPS_MSK ] = "ДПС МСК",
}

FACTIONS_LEVEL_LIMITS = {
	[ F_GOVERNMENT_NSK ] = {
		[9] = 4;
		[10] = 3;
		[11] = 2;
	}
}
FACTIONS_LEVEL_LIMITS[ F_GOVERNMENT_GORKI ] = FACTIONS_LEVEL_LIMITS[ F_GOVERNMENT_NSK ]
FACTIONS_LEVEL_LIMITS[ F_GOVERNMENT_MSK ] = FACTIONS_LEVEL_LIMITS[ F_GOVERNMENT_NSK ]

FACTIONS_LEVEL_ICONS = {
	[ F_ARMY ] = 1;
	[ F_POLICE_PPS_NSK ] = 2;
	[ F_POLICE_DPS_NSK ] = 2;
	[ F_MEDIC ] = 4;
	[ F_MEDIC_MSK ] = 4;
	[ F_POLICE_PPS_GORKI ] = 2;
	[ F_POLICE_DPS_GORKI ] = 2;
	[ F_GOVERNMENT_NSK ] = 5;
	[ F_GOVERNMENT_GORKI ] = 5;
	[ F_GOVERNMENT_MSK ] = 5;
	[ F_FSIN ] = 2;
	[ F_POLICE_PPS_MSK ] = 2;
	[ F_POLICE_DPS_MSK ] = 2;
	-- [ F_EMERCOM ] = 3;
}

FACTION_EXPERIENCE = {
	[0] = 0,
	[1] = 7000,
	[2] = 9000,
	[3] = 12000,
	[4] = 20000,
	[5] = 30000,
	[6] = 36000,
	[7] = 50000,
	[8] = 60000,
	[9] = 70000,
	[10] = 80000,
}

FACTION_OWNER_LEVEL = #FACTION_EXPERIENCE + 2

CITYHALL_CONTROL_POSITIONS = {
	[ F_GOVERNMENT_NSK ] = {
		x = -75.359, y = -862.989, z = 1051.787;
		interior = 1;
		dimension = 1;
	};
	[ F_GOVERNMENT_MSK ] = {
		x = 1327.9840, y = 2553.9619, z = 2292.5400;
		interior = 3;
		dimension = 1;
	};
	[ F_GOVERNMENT_GORKI ] = {
		x = 2311.521, y = -97.073, z = 675.263;
		interior = 1;
		dimension = 1;
	};
}

FACTIONS_INFO_MENU_POSITIONS = {
	{
		faction = F_ARMY,
		city = 1,

		x = -2411.7228, y = -57.47 + 860, z = 20.25,
		interior = 0,
		dimension = 0,
	},
	{
		faction = F_POLICE_PPS_NSK,
		city = 1,

		x = -345.370, y = -789.214, z = 1065.125,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_POLICE_PPS_GORKI,
		city = 2,

		x = 1972.463, y = 131.990, z = 635.125,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_POLICE_PPS_MSK,
		city = 3,

		x = -1649.424, y = 2641.721, z = 1899.010,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_POLICE_DPS_NSK,
		city = 1,

		x = 325.401, y = -1168.858, z = 1021.578,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_POLICE_DPS_GORKI,
		city = 2,

		x = 2182.422, y = 232.313, z = 601.002,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_POLICE_DPS_MSK,
		city = 3,

		x = -2061.671, y = 1900.286, z = 1647.411,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_MEDIC,
		city = 1,

		x = 447.790, y = -1600.948, z = 1020.968,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_MEDIC,
		city = 2,

		x = 1941.932, y = 309.982, z = 660.966,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_MEDIC_MSK,
		city = 3,

		x = -2006.37, y = 1975.53, z = 1797.89,

		interior = 2,
		dimension = 2,
	},
	{
		faction = F_GOVERNMENT_NSK,
		city = 1,

		x = -61.670, y = -860.533, z = 1047.537,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_GOVERNMENT_MSK,
		city = 3,

		x = 1321.7767, y = 2450.1967, z = 2292.5500,
		interior = 3,
		dimension = 1,
	},
	{
		faction = F_GOVERNMENT_GORKI,
		city = 2,

		x = 2298.083, y = -98.918, z = 671.013,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_FSIN,
		city = 1,

		x = -2653.1518, y = 2840.8605, z = 1544.2125,
		interior = 1,
		dimension = 1,
	},
}

FACTION_SKINS_BY_GENDER = {
	[F_ARMY] = {
		[1] = {
			[0] = 101,
			[1] = 93,
		},
		[2] = {
			[0] = 101,
			[1] = 93,
		},
		[3] = {
			[0] = 102,
			[1] = 93,
		},
		[4] = {
			[0] = 102,
			[1] = 253,
		},
		[5] = {
			[0] = 109,
			[1] = 253,
		},
		[6] = {
			[0] = 109,
			[1] = 223,
		},
		[7] = {
			[0] = 128,
			[1] = 229,
		},
		[8] = {
			[0] = 206,
			[1] = 93,
		},
		[9] = {
			[0] = 220,
			[1] = 53,
		},
		[10] = {
			[0] = 252,
			[1] = 228,
		},
		[11] = {
			[0] = 252,
			[1] = 228,
		},
		[12] = {
			[0] = 59,
			[1] = 222,
		},
	},

	[F_POLICE_PPS_NSK] = {
		[1] = {
			[0] = 125,
			[1] = 249,
		},
		[2] = {
			[0] = 125,
			[1] = 249,
		},
		[3] = {
			[0] = 40,
			[1] = 250,
		},
		[4] = {
			[0] = 40,
			[1] = 248,
		},
		[5] = {
			[0] = 40,
			[1] = 248,
		},
		[6] = {
			[0] = 255,
			[1] = 211,
		},
		[7] = {
			[0] = 227,
			[1] = 211,
		},
		[8] = {
			[0] = 227,
			[1] = 243,
		},
		[9] = {
			[0] = 227,
			[1] = 246,
		},
		[10] = {
			[0] = 238,
			[1] = 247,
		},
		[11] = {
			[0] = 238,
			[1] = 247,
		},
		[12] = {
			[0] = 254,
			[1] = 242,
		},
	},

	[F_POLICE_DPS_NSK] = {
		[1] = {
			[0] = 233,
			[1] = 240,
		},
		[2] = {
			[0] = 233,
			[1] = 240,
		},
		[3] = {
			[0] = 237,
			[1] = 241,
		},
		[4] = {
			[0] = 144,
			[1] = 75,
		},
		[5] = {
			[0] = 144,
			[1] = 75,
		},
		[6] = {
			[0] = 235,
			[1] = 219,
		},
		[7] = {
			[0] = 235,
			[1] = 219,
		},
		[8] = {
			[0] = 255,
			[1] = 219,
		},
		[9] = {
			[0] = 286,
			[1] = 236,
		},
		[10] = {
			[0] = 238,
			[1] = 239,
		},
		[11] = {
			[0] = 238,
			[1] = 239,
		},
		[12] = {
			[0] = 254,
			[1] = 230,
		},
	},

	[F_MEDIC] = {
		[1] = {
			[0] = 231,
			[1] = 13,
		},
		[2] = {
			[0] = 231,
			[1] = 13,
		},
		[3] = {
			[0] = 226,
			[1] = 216,
		},
		[4] = {
			[0] = 226,
			[1] = 216,
		},
		[5] = {
			[0] = 274,
			[1] = 162,
		},
		[6] = {
			[0] = 274,
			[1] = 162,
		},
		[7] = {
			[0] = 275,
			[1] = 232,
		},
		[8] = {
			[0] = 225,
			[1] = 232,
		},
		[9] = {
			[0] = 276,
			[1] = 232,
		},
		[10] = {
			[0] = 152,
			[1] = 162,
		},
		[11] = {
			[0] = 36,
			[1] = 41,
		},
		[12] = {
			[0] = 224,
			[1] = 41,
		},
	},

	[F_GOVERNMENT_NSK] = {
		[1] = {
			[0] = 1,
			[1] = 2,
		},
		[2] = {
			[0] = 1,
			[1] = 2,
		},
		[3] = {
			[0] = 10,
			[1] = 12,
		},
		[4] = {
			[0] = 26,
			[1] = 28,
		},
		[5] = {
			[0] = 26,
			[1] = 28,
		},
		[6] = {
			[0] = 29,
			[1] = 32,
		},
		[7] = {
			[0] = 29,
			[1] = 32,
		},
		[8] = {
			[0] = 34,
			[1] = 35,
		},
		[9] = {
			[0] = 34,
			[1] = 35,
		},
		[10] = {
			[0] = 34,
			[1] = 35,
		},
		[11] = {
			[0] = 37,
			[1] = 44,
		},
		[12] = {
			[0] = 194,
			[1] = 52,
		},
	},

	[ F_FSIN ] = 
	{
		[1] = {
			[0] = 51,
			[1] = 55,
		},
		[2] = {
			[0] = 201,
			[1] = 181,
		},
		[3] = {
			[0] = 217,
			[1] = 221,
		},
		[4] = {
			[0] = 179,
			[1] = 180,
		},
		[5] = {
			[0] = 171,
			[1] = 55,
		},
		[6] = {
			[0] = 171,
			[1] = 170,
		},
		[7] = {
			[0] = 173,
			[1] = 229,
		},
		[8] = {
			[0] = 166,
			[1] = 310,
		},
		[9] = {
			[0] = 173,
			[1] = 172,
		},
		[10] = {
			[0] = 175,
			[1] = 174,
		},
		[11] = {
			[0] = 175,
			[1] = 174,
		},
		[12] = {
			[0] = 251,
			[1] = 158,
		},
	},
}

FACTION_SKINS_BY_GENDER[ F_POLICE_PPS_GORKI ] = FACTION_SKINS_BY_GENDER[ F_POLICE_PPS_NSK ]
FACTION_SKINS_BY_GENDER[ F_POLICE_PPS_MSK ] = FACTION_SKINS_BY_GENDER[ F_POLICE_PPS_NSK ]
FACTION_SKINS_BY_GENDER[ F_POLICE_DPS_GORKI ] = FACTION_SKINS_BY_GENDER[ F_POLICE_DPS_NSK ]
FACTION_SKINS_BY_GENDER[ F_POLICE_DPS_MSK ] = FACTION_SKINS_BY_GENDER[ F_POLICE_DPS_NSK ]
FACTION_SKINS_BY_GENDER[ F_GOVERNMENT_GORKI ] = FACTION_SKINS_BY_GENDER[ F_GOVERNMENT_NSK ]
FACTION_SKINS_BY_GENDER[ F_GOVERNMENT_MSK ] = FACTION_SKINS_BY_GENDER[ F_GOVERNMENT_NSK ]
FACTION_SKINS_BY_GENDER[ F_MEDIC_MSK ] = FACTION_SKINS_BY_GENDER[ F_MEDIC ]

FACTIONS_NEED_MILITARY = {
	[ F_ARMY ] = true;
	[ F_POLICE_PPS_NSK ] = true;
	[ F_POLICE_DPS_NSK ] = true;
	[ F_POLICE_PPS_GORKI ] = true;
	[ F_POLICE_DPS_GORKI ] = true;
	[ F_GOVERNMENT_NSK ] = true;
	[ F_GOVERNMENT_GORKI ] = true;
	[ F_GOVERNMENT_MSK ] = true;
	[ F_FSIN ] = true;
	[ F_POLICE_PPS_MSK ] = true;
	[ F_POLICE_DPS_MSK ] = true;
}

FACTION_RIGHTS = {
	DRIVEBY = {
		[ F_ARMY ] = true;
		[ F_POLICE_PPS_NSK ] = true;
		[ F_POLICE_DPS_NSK ] = true;
		[ F_POLICE_PPS_GORKI ] = true;
		[ F_POLICE_DPS_GORKI ] = true;
		[ F_FSIN ] = true;
		[ F_POLICE_PPS_MSK ] = true;
		[ F_POLICE_DPS_MSK ] = true;
	};
	WANTED_KNOW = {
		[ F_POLICE_PPS_NSK ] = true;
		[ F_POLICE_DPS_NSK ] = true;
		[ F_POLICE_PPS_GORKI ] = true;
		[ F_POLICE_DPS_GORKI ] = true;
		[ F_POLICE_PPS_MSK ] = true;
		[ F_POLICE_DPS_MSK ] = true;
	};
	JAILID = {
		[ F_POLICE_PPS_NSK ] = 1;
		[ F_POLICE_DPS_NSK ] = 1;
		[ F_POLICE_PPS_GORKI ] = 2;
		[ F_POLICE_DPS_GORKI ] = 2;
		[ F_POLICE_PPS_MSK ] = 3;
		[ F_POLICE_DPS_MSK ] = 3;
	};
	PRISONID = 
	{
		[ F_FSIN ] = 1;
		[ F_FSIN ] = 2;
		[ F_FSIN ] = 3;
	};
	MEGAPHONE = {
		[ F_POLICE_PPS_NSK ] = true;
		[ F_POLICE_DPS_NSK ] = true;
		[ F_POLICE_PPS_GORKI ] = true;
		[ F_POLICE_DPS_GORKI ] = true;
		[ F_GOVERNMENT_NSK ] = true;
		[ F_GOVERNMENT_GORKI ] = true;
		[ F_GOVERNMENT_MSK ] = true;
		[ F_POLICE_PPS_MSK ] = true;
		[ F_POLICE_DPS_MSK ] = true;
	};
	HEALTH = {
		[ F_MEDIC ] = true;
		[ F_MEDIC_MSK ] = true;
	};
	REANIMATION = {
		[ F_MEDIC ] = true;
		[ F_MEDIC_MSK ] = true;
	};
	DOC_CHECK = {
		[ F_POLICE_PPS_NSK ] = true;
		[ F_POLICE_DPS_NSK ] = true;
		[ F_POLICE_PPS_GORKI ] = true;
		[ F_POLICE_DPS_GORKI ] = true;
		[ F_POLICE_PPS_MSK ] = true;
		[ F_POLICE_DPS_MSK ] = true;
	};
	WANTED_GIVE = {
		[ F_POLICE_PPS_NSK ] = true;
		[ F_POLICE_DPS_NSK ] = true;
		[ F_POLICE_PPS_GORKI ] = true;
		[ F_POLICE_DPS_GORKI ] = true;
		[ F_POLICE_PPS_MSK ] = true;
		[ F_POLICE_DPS_MSK ] = true;
	};
	MUTE_GIVE = {
		[ F_POLICE_PPS_NSK ] = true;
		[ F_POLICE_DPS_NSK ] = true;
		[ F_POLICE_PPS_GORKI ] = true;
		[ F_POLICE_DPS_GORKI ] = true;
		[ F_POLICE_PPS_MSK ] = true;
		[ F_POLICE_DPS_MSK ] = true;
	};
	FINES_GIVE = {
		[ F_POLICE_PPS_NSK ] = true;
		[ F_POLICE_DPS_NSK ] = true;
		[ F_POLICE_PPS_GORKI ] = true;
		[ F_POLICE_DPS_GORKI ] = true;
		[ F_POLICE_PPS_MSK ] = true;
		[ F_POLICE_DPS_MSK ] = true;
	};
	HANDCUFFS = {
		[ F_ARMY ] = true;
		[ F_POLICE_PPS_NSK ] = true;
		[ F_POLICE_DPS_NSK ] = true;
		[ F_POLICE_PPS_GORKI ] = true;
		[ F_POLICE_DPS_GORKI ] = true;
		[ F_FSIN ] = true;
		[ F_POLICE_PPS_MSK ] = true;
		[ F_POLICE_DPS_MSK ] = true;
	};
	VEH_EJECT = {
		[ F_POLICE_PPS_NSK ] = true;
		[ F_POLICE_DPS_NSK ] = true;
		[ F_POLICE_PPS_GORKI ] = true;
		[ F_POLICE_DPS_GORKI ] = true;
		[ F_POLICE_PPS_MSK ] = true;
		[ F_POLICE_DPS_MSK ] = true;
	};
	STINGER = {
		[ F_POLICE_DPS_NSK ] = true;
		[ F_POLICE_DPS_GORKI ] = true;
		[ F_POLICE_DPS_MSK ] = true;
	};
	EVACUATION = {
		[ F_POLICE_DPS_NSK ] = true;
		[ F_POLICE_DPS_GORKI ] = true;
		[ F_POLICE_DPS_MSK ] = true;
	};
	ECONOMY = {
		[ F_GOVERNMENT_NSK ] = {
			[ F_GOVERNMENT_NSK ] = true;
		};
		[ F_GOVERNMENT_GORKI ] = {
			[ F_GOVERNMENT_GORKI ] = true;
		};
		[ F_GOVERNMENT_MSK ] = {
			[ F_GOVERNMENT_MSK ] = true;
		};
	};
}

REGISTERED_FACTIONS_TASKS = {
	[F_ARMY] = {
		"military_2",
		"military_4",
		"military_5",
		"military_6",
		"military_7",
	},
	[F_POLICE_PPS_NSK] = {
		"police_1",
		"pps_1",
		"police_2",
		"police_3",
	},
	[F_POLICE_DPS_NSK] = {
		"police_1",
		"dps_1",
		"dps_2",
		"dps_3",
		"dps_4",
	},
	[F_POLICE_PPS_GORKI] = {
		"police_1",
		"pps_1",
		"police_2",
		"police_3",
	},
	[F_POLICE_DPS_GORKI] = {
		"police_1",
		"dps_1",
		"dps_2",
		"dps_3",
		"dps_4",
	},
	[F_MEDIC] = {
		"medic_1",
		"medic_2",
		"medic_3",
		"medic_4",
		"medic_5",
	},
	[F_MEDIC_MSK] = {
		"medic_1",
		"medic_2",
		"medic_3",
		"medic_4",
		"medic_5",
	},
	[F_GOVERNMENT_NSK] = {
		"mayor_1",
		"mayor_2",
		"mayor_3",
		"mayor_4",
	},
	[F_GOVERNMENT_GORKI] = {
		"mayor_1",
		"mayor_2",
		"mayor_3",
		"mayor_4",
	},
	[F_GOVERNMENT_MSK] = {
		"mayor_1",
		"mayor_2",
		"mayor_3",
		"mayor_4",
	},
	[F_FSIN] = {
		"fsin_1",
		"fsin_2",
		"fsin_3",
		"fsin_4",
	},
	[F_POLICE_PPS_MSK] = {
		"police_1",
		"pps_1",
		"police_2",
		"police_3",
	},
	[F_POLICE_DPS_MSK] = {
		"police_1",
		"dps_1",
		"dps_2",
		"dps_3",
		"dps_4",
	},
}

FACTIONS_TASKS_PED_IDS = {
	[ F_POLICE_PPS_NSK ] = 14;
	[ F_POLICE_DPS_NSK ] = 18;
	[ F_POLICE_PPS_GORKI ] = 15;
	[ F_POLICE_DPS_GORKI ] = 19;
	[ F_GOVERNMENT_NSK ] = 21;
	[ F_GOVERNMENT_GORKI ] = 22;
	[ F_GOVERNMENT_MSK ] = 28;
	[ F_FSIN ] = 24;
	[ F_POLICE_PPS_MSK ] = 26;
	[ F_POLICE_DPS_MSK ] = 25;
	[ F_ARMY ] = 20;
}

WANTED_KNOW_TIMEOUT = 60 * 30
WANTED_KNOW_DISTANCE = 25

REGISTERED_FACTIONS_TRAINING = {
	-- название учения
	murder_nsk = {
		-- { Идентификатор квеста в учении, =Фракция, >=Ранг, ?Необязательный слот }
		-- Запрещено использовать обязательные слоты с одинаковыми идентификаторами
		--{ "pps", F_POLICE_PPS_NSK, 3 },
		{ "pps", F_POLICE_PPS_NSK, 5 },
		{ "dps", F_POLICE_DPS_NSK, 2 },
		{ "medic", F_MEDIC, 3 },
		-- Для ускорения обработки циклов, все необязательные слоты должны идти в конце. Запрещено использовать обязательные слоты после необязательных
		{ "s_dps", F_POLICE_DPS_NSK, 1, true },
		{ "s_dps", F_POLICE_DPS_NSK, 1, true },
		{ "s_dps", F_POLICE_DPS_NSK, 1, true },
	},
	murder_gorki = {
		{ "pps", F_POLICE_PPS_GORKI, 5 },
		{ "dps", F_POLICE_DPS_GORKI, 2 },
		{ "medic", F_MEDIC, 3 },
		{ "s_dps", F_POLICE_DPS_GORKI, 1, true },
		{ "s_dps", F_POLICE_DPS_GORKI, 1, true },
		{ "s_dps", F_POLICE_DPS_GORKI, 1, true },
	},
	military_delivery = {
		{ "pilot", F_ARMY, 6 },
		{ "driver", F_ARMY, 1 },
		{ "s_armed", F_ARMY, 1, true },
		{ "s_armed", F_ARMY, 1, true },
		{ "s_armed", F_ARMY, 1, true },
		{ "s_armed", F_ARMY, 1, true },
		{ "s_armed", F_ARMY, 1, true },
		{ "s_armed", F_ARMY, 1, true },
		{ "s_armed", F_ARMY, 1, true },
		{ "s_armed", F_ARMY, 1, true },
	},
	military_skydiving = {
		{ "aircraft", F_ARMY, 6 },
		{ "heli", F_ARMY, 1 },
		{ "heli", F_ARMY, 1 },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
		{ "s_skydiver", F_ARMY, 1, true },
	},
	ambassador_delivery = {
		{ "driver", F_POLICE_DPS_NSK, 5 },
		{ "s_fdriver", F_POLICE_DPS_NSK, 1, true },
		{ "s_post", F_POLICE_DPS_NSK, 1, true },
		{ "s_post", F_POLICE_DPS_NSK, 1, true },
		{ "s_post", F_POLICE_DPS_NSK, 1, true },
		{ "s_post", F_POLICE_DPS_NSK, 1, true },
		{ "s_post", F_POLICE_DPS_NSK, 1, true },
		{ "s_post", F_POLICE_DPS_NSK, 1, true },
		{ "s_armed", F_POLICE_DPS_NSK, 1, true },
		{ "s_armed", F_POLICE_DPS_NSK, 1, true },
		{ "s_armed", F_POLICE_DPS_NSK, 1, true },
		{ "s_armed", F_POLICE_DPS_NSK, 1, true },
		{ "s_armed", F_POLICE_DPS_NSK, 1, true },
		{ "s_armed", F_POLICE_DPS_NSK, 1, true },
		{ "s_armed", F_POLICE_DPS_NSK, 1, true },
		{ "s_armed", F_POLICE_DPS_NSK, 1, true },
	},
	ambassador_delivery_gorki = {
		{ "driver", F_POLICE_DPS_GORKI, 5 },
		{ "s_fdriver", F_POLICE_DPS_GORKI, 1, true },
		{ "s_post", F_POLICE_DPS_GORKI, 1, true },
		{ "s_post", F_POLICE_DPS_GORKI, 1, true },
		{ "s_post", F_POLICE_DPS_GORKI, 1, true },
		{ "s_post", F_POLICE_DPS_GORKI, 1, true },
		{ "s_post", F_POLICE_DPS_GORKI, 1, true },
		{ "s_post", F_POLICE_DPS_GORKI, 1, true },
		{ "s_armed", F_POLICE_DPS_GORKI, 1, true },
		{ "s_armed", F_POLICE_DPS_GORKI, 1, true },
		{ "s_armed", F_POLICE_DPS_GORKI, 1, true },
		{ "s_armed", F_POLICE_DPS_GORKI, 1, true },
		{ "s_armed", F_POLICE_DPS_GORKI, 1, true },
		{ "s_armed", F_POLICE_DPS_GORKI, 1, true },
		{ "s_armed", F_POLICE_DPS_GORKI, 1, true },
		{ "s_armed", F_POLICE_DPS_GORKI, 1, true },
	},
	demining = {
		{ "pps", F_POLICE_PPS_NSK, 4 },
		{ "army", F_ARMY, 4 },
		{ "medic", F_MEDIC, 3 },
		{ "dps", F_POLICE_DPS_NSK, 3 },
		{ "s_pps", F_POLICE_PPS_NSK, 1, true },
		{ "s_pps", F_POLICE_PPS_NSK, 1, true },
		{ "s_army", F_ARMY, 1, true },
		{ "s_medic", F_MEDIC, 1, true },
		{ "s_medic", F_MEDIC, 1, true },
		{ "s_dps", F_POLICE_DPS_NSK, 1, true },
		{ "s_dps", F_POLICE_DPS_NSK, 1, true },
		{ "s_dps", F_POLICE_DPS_NSK, 1, true },
		{ "s_dps", F_POLICE_DPS_NSK, 1, true },
	},
	cityhall_rating = {
		{ "mayor", F_GOVERNMENT_NSK, 12 },
		{ "s_armed", F_GOVERNMENT_NSK, 3, true },
		{ "s_armed", F_GOVERNMENT_NSK, 3, true },
		{ "s_armed", F_GOVERNMENT_NSK, 3, true },
		{ "s_armed", F_GOVERNMENT_NSK, 3, true },
		{ "s_armed", F_GOVERNMENT_NSK, 3, true },
		{ "s_armed", F_GOVERNMENT_NSK, 3, true },
		{ "s_armed", F_GOVERNMENT_NSK, 3, true },
		{ "s_armed", F_GOVERNMENT_NSK, 3, true },
		{ "s_armed", F_GOVERNMENT_NSK, 3, true },
		{ "s_armed", F_GOVERNMENT_NSK, 3, true },
		{ "s_armed", F_GOVERNMENT_NSK, 3, true },
		{ "s_armed", F_GOVERNMENT_NSK, 3, true },
	},
	cityhall_rating_gorki = {
		{ "mayor", F_GOVERNMENT_GORKI, 12 },
		{ "s_armed", F_GOVERNMENT_GORKI, 3, true },
		{ "s_armed", F_GOVERNMENT_GORKI, 3, true },
		{ "s_armed", F_GOVERNMENT_GORKI, 3, true },
		{ "s_armed", F_GOVERNMENT_GORKI, 3, true },
		{ "s_armed", F_GOVERNMENT_GORKI, 3, true },
		{ "s_armed", F_GOVERNMENT_GORKI, 3, true },
		{ "s_armed", F_GOVERNMENT_GORKI, 3, true },
		{ "s_armed", F_GOVERNMENT_GORKI, 3, true },
		{ "s_armed", F_GOVERNMENT_GORKI, 3, true },
		{ "s_armed", F_GOVERNMENT_GORKI, 3, true },
		{ "s_armed", F_GOVERNMENT_GORKI, 3, true },
		{ "s_armed", F_GOVERNMENT_GORKI, 3, true },
	},
	cityhall_rating_msk = {
		{ "mayor", F_GOVERNMENT_MSK, 12 },
		{ "s_armed", F_GOVERNMENT_MSK, 3, true },
		{ "s_armed", F_GOVERNMENT_MSK, 3, true },
		{ "s_armed", F_GOVERNMENT_MSK, 3, true },
		{ "s_armed", F_GOVERNMENT_MSK, 3, true },
		{ "s_armed", F_GOVERNMENT_MSK, 3, true },
		{ "s_armed", F_GOVERNMENT_MSK, 3, true },
		{ "s_armed", F_GOVERNMENT_MSK, 3, true },
		{ "s_armed", F_GOVERNMENT_MSK, 3, true },
		{ "s_armed", F_GOVERNMENT_MSK, 3, true },
		{ "s_armed", F_GOVERNMENT_MSK, 3, true },
		{ "s_armed", F_GOVERNMENT_MSK, 3, true },
		{ "s_armed", F_GOVERNMENT_MSK, 3, true },
	},
}

FACTIONS_TRAINING_MENU_POSITIONS = {
	{
		faction = F_ARMY,
		x = -2379.721, y = -182.897 + 860, z = 21.090,
		interior = 0,
		dimension = 0,
	},
	{
		faction = F_POLICE_PPS_NSK,
		x = -365.940, y = -787.468, z = 1061.424,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_POLICE_DPS_NSK,
		x = 332.878, y = -1176.925, z = 1021.584,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_MEDIC,
		x = 447.121, y = -1597.065, z = 1020.968,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_MEDIC_MSK,
		x = -1982.692, y = 1991.499, z = 1797.890,
		interior = 2,
		dimension = 2,
	},
	{
		faction = F_POLICE_PPS_GORKI,
		x = 1952.191, y = 133.947, z = 631.421,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_POLICE_DPS_GORKI,
		x = 2190.120, y = 224.256, z = 601.002,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_POLICE_DPS_MSK,
		x = -2046.745, y = 1899.999, z = 1647.411,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_GOVERNMENT_NSK,
		x = -60.234, y = -861.087, z = 1051.787,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_GOVERNMENT_MSK,

		x = 1347.8259, y = 2460.4475, z = 2292.5400,
		interior = 3,
		dimension = 1,
	},
	{
		faction = F_GOVERNMENT_GORKI,
		x = 2297.278, y = -98.532, z = 675.263,
		interior = 1,
		dimension = 1,
	},
	{
		faction = F_POLICE_PPS_MSK,
		x = -1668.440, y = 2644.148, z = 1899.010,
		interior = 1,
		dimension = 1,
	},
}

-- Минимальное время в КПЗ, за которое перевозят в тюрьму
PRISON_TIME = 5 * 60 * 1000

PLAYER_NAMETAG_COLORS = {
	0xffffff,
	0x3faf2b,
	0xbc0986,
	0xce6bb0,
	0xe29d1b,
	0x1cdbce,
	0x8573c6,
}

CASINO_GAME_FOOL = 1
CASINO_GAME_DICE = 2
CASINO_GAME_DICE_VIP = 3
CASINO_GAME_ROULETTE = 4
CASINO_GAME_CLASSIC_ROULETTE = 5
CASINO_GAME_SLOT_MACHINE_GOLD_SKULL = 6
CASINO_GAME_BLACK_JACK = 7
CASINO_GAME_SLOT_MACHINE_VALHALLA = 8
CASINO_GAME_LOTTERY = 9
CASINO_GAME_SLOT_MACHINE_CHICAGO = 10
CASINO_GAME_CLASSIC_ROULETTE_VIP = 11

CASINO_PREMIUM_GAMES = {

}

CASINO_GAMES_NAMES = {
	[ CASINO_GAME_FOOL ] = "Дурак",
	[ CASINO_GAME_DICE ] = "Кости",
	[ CASINO_GAME_DICE_VIP ] = "VIP Кости",
	[ CASINO_GAME_ROULETTE ] = "Русская рулетка",
	[ CASINO_GAME_CLASSIC_ROULETTE ] = "Классическая рулетка",
	[ CASINO_GAME_CLASSIC_ROULETTE_VIP ] = "Классическая рулетка VIP",
	[ CASINO_GAME_SLOT_MACHINE_GOLD_SKULL ] = "Золотой череп",
	[ CASINO_GAME_BLACK_JACK ] = "Блек Джек",
	[ CASINO_GAME_SLOT_MACHINE_VALHALLA ] = "Вальхалла",
	[ CASINO_GAME_SLOT_MACHINE_CHICAGO ] = "Чикаго",
}

CASINO_GAME_STRING_IDS = {
	[ CASINO_GAME_DICE ] = "bone",
	[ CASINO_GAME_ROULETTE ] = "rus_roulette",
	[ CASINO_GAME_CLASSIC_ROULETTE ] = "roulette",
	[ CASINO_GAME_CLASSIC_ROULETTE_VIP ] = "roulette",
	[ CASINO_GAME_BLACK_JACK ] = "blackjack",

	[ CASINO_GAME_SLOT_MACHINE_GOLD_SKULL ] = "gold_skull",
	[ CASINO_GAME_SLOT_MACHINE_VALHALLA ] = "valhalla",
	[ CASINO_GAME_SLOT_MACHINE_CHICAGO ] = "chicago",
}

CASINO_GAME_FOOL_VAR_NORMAL = 1
CASINO_GAME_FOOL_VAR_TRANSLATABLE = 2

CASINO_STATE_WAITING  = 1
CASINO_STATE_PLAYING  = 2
CASINO_STATE_ENDED    = 3

CASINO_PLAYER_STATE_PLAYING = 1
CASINO_PLAYER_STATE_WON 	= 2
CASINO_PLAYER_STATE_LOST 	= 3
CASINO_PLAYER_STATE_WAITING = 4
CASINO_PLAYER_STATE_READY 	= 5

enum "eCasinoId" {
	"CASINO_THREE_AXE",
	"CASINO_MOSCOW",
}

CASIONO_STRING_ID = {
	[ CASINO_THREE_AXE ] = "three_axe",
	[ CASINO_MOSCOW ] 	 = "moscovski",
}

-- Внутренний тюнинг
-- Типы деталей
P_TYPE_ENGINE       = 1
P_TYPE_TURBO        = 2
P_TYPE_TRANSMISSION = 3
P_TYPE_ECU          = 4
P_TYPE_BRAKES       = 5
P_TYPE_SUSPENSION   = 6
P_TYPE_TIRES        = 7

P_MAX_TYPES 		= 7

PARTS_IMAGE_NAMES = {
    [ P_TYPE_ENGINE ]       = "engine",
    [ P_TYPE_TURBO ]        = "turbo",
    [ P_TYPE_TRANSMISSION]  = "transmission",
    [ P_TYPE_ECU ]          = "ecu",
    [ P_TYPE_BRAKES ]       = "brakes",
    [ P_TYPE_SUSPENSION ]   = "suspension",
    [ P_TYPE_TIRES ]        = "tires",
}

PARTS_NAMES = {
	[ P_TYPE_ENGINE ]       = "Двигатель",
    [ P_TYPE_TURBO ]        = "Турбонаддув",
    [ P_TYPE_TRANSMISSION]  = "Трансмиссия",
    [ P_TYPE_ECU ]          = "Чиповка",
    [ P_TYPE_BRAKES ]       = "Тормоза",
    [ P_TYPE_SUSPENSION ]   = "Подвеска",
    [ P_TYPE_TIRES ]        = "Шины",
}

enum "internalTuningType" {
	"INTERNAL_PART_TYPE_R",
	"INTERNAL_PART_TYPE_X",
	"INTERNAL_PART_TYPE_F",
}

INTERNAL_PARTS_NAMES_TYPES = {
	[ INTERNAL_PART_TYPE_R ] = "R",
	[ INTERNAL_PART_TYPE_X ] = "X",
	[ INTERNAL_PART_TYPE_F ] = "F",
}

-- Индексы значений по деталям
P_TYPE          = 1
P_TIER          = 2
P_CLASS         = 3
P_MAXSPEED      = 4
P_ACCELERATION  = 5
P_HANDLING      = 6
P_NAME          = 7
P_WEAROFF 		= 8
P_INSTALLED		= 9
P_PRICE 		= 10
P_SELL			= 11
P_COEFFICIENT	= 12
P_FROM_CASE		= 13

-- Индексы для винилов
P_PRICE_TYPE	= 14
P_IMAGE			= 15
P_LAYER			= 16
P_LAYER_DATA 	= 17
P_SALE_NUMBER   = 18

-- Уровень детали (от дерьма до ультры)
PART_T1 = 1
PART_T2 = 2
PART_T3 = 3
PART_T4 = 4
PART_T5 = 5

PARTS_TIER_NAMES = {
	[ PART_T1 ] = "I",
	[ PART_T2 ] = "II",
	[ PART_T3 ] = "III",
	[ PART_T4 ] = "IV",
	[ PART_T5 ] = "V",
}

-- Уровень детали под уровень машины
PART_CLASS_1 = 1
PART_CLASS_2 = 2
PART_CLASS_3 = 3
PART_CLASS_4 = 4
PART_CLASS_5 = 5

-- Дефолтные множители суммы параметров
P_DEFAULT_MUL_MAX_VELOCITY 			= 2
P_DEFAULT_MUL_ENGINE_ACCELERATION 	= 5
P_DEFAULT_MUL_TRACTION_MULTIPLIER 	= 5
P_DEFAULT_MUL_TRACTION_LOSS 		= -0.5
P_DEFAULT_MUL_BRAKE_DECELERATION 	= 1
P_DEFAULT_MUL_TURN_MASS 			= -1
-- Общий делитель параметров для подгона мощностей деталей
P_DEFAULT_DIVISOR_MAXSPEED 		= 400
P_DEFAULT_DIVISOR_ACCELERATION 	= 250
P_DEFAULT_DIVISOR_HANDLING 		= 500
-- Множители для визуальной статистики машин
P_DEFAULT_MAXSPEED_MUL 		= 0.64
P_DEFAULT_ACCELERATION_MUL 	= 2.4
P_DEFAULT_ACCELERATION_SUB 	= 80
-- Для подсчета управляемости от баланса скорости и ускорения
P_DEFAULT_HANDLING_MUL_MAXSPEED 	= 0.7
P_DEFAULT_HANDLING_MUL_ACCELERATION = 0.6
P_DEFAULT_HANDLING_MUL_GLOBAL		= 0.6

VEHICLE_CLASSES_NAMES = {
	[ 1 ] = "A",
	[ 2 ] = "B",
	[ 3 ] = "C",
	[ 4 ] = "D",
	[ 5 ] = "S",
	[ 6 ] = "M",
}

-- Винил кейсы
VINYL_CASE_1_A = 1
VINYL_CASE_2_A = 2
VINYL_CASE_3_A = 3

VINYL_CASE_1_B = 4
VINYL_CASE_2_B = 5
VINYL_CASE_3_B = 6

VINYL_CASE_1_C = 7
VINYL_CASE_2_C = 8
VINYL_CASE_3_C = 9

VINYL_CASE_1_D = 10
VINYL_CASE_2_D = 11
VINYL_CASE_3_D = 12

VINYL_CASE_1_S = 13
VINYL_CASE_2_S = 14
VINYL_CASE_3_S = 15

VINYL_CASE_1_M = 16
VINYL_CASE_2_M = 17
VINYL_CASE_3_M = 18

VINYL_CASE_TIERS = {
    [ 1 ] = { 
        [ VINYL_CASE_1_A ] = true,
        [ VINYL_CASE_2_A ] = true,
        [ VINYL_CASE_3_A ] = true, 
    },
    [ 2 ] = { 
        [ VINYL_CASE_1_B ] = true,
        [ VINYL_CASE_2_B ] = true,
        [ VINYL_CASE_3_B ] = true, 
    },
    [ 3 ] = { 
        [ VINYL_CASE_1_C ] = true,
        [ VINYL_CASE_2_C ] = true,
        [ VINYL_CASE_3_C ] = true,
    },
    [ 4 ] = { 
        [ VINYL_CASE_1_D ] = true,
        [ VINYL_CASE_2_D ] = true,
        [ VINYL_CASE_3_D ] = true,  
    },
    [ 5 ] = { 
        [ VINYL_CASE_1_S ] = true,
        [ VINYL_CASE_2_S ] = true,
        [ VINYL_CASE_3_S ] = true,
    },
	[ 6 ] = {
		[ VINYL_CASE_1_M ] = true,
		[ VINYL_CASE_2_M ] = true,
		[ VINYL_CASE_3_M ] = true,
	},
}

--string.format( "VINYL_CASE_%s_%s", case_id, vehicle_class )
VINYL_CASE_TIERS_STR_CONVERT = {
    [ "VINYL_CASE_1_1" ] = VINYL_CASE_1_A,
    [ "VINYL_CASE_2_1" ] = VINYL_CASE_2_A,
	[ "VINYL_CASE_3_1" ] = VINYL_CASE_3_A, 
		
    [ "VINYL_CASE_1_2" ] = VINYL_CASE_1_B,
    [ "VINYL_CASE_2_2" ] = VINYL_CASE_2_B,
    [ "VINYL_CASE_3_2" ] = VINYL_CASE_3_B, 

    [ "VINYL_CASE_1_3" ] = VINYL_CASE_1_C,
    [ "VINYL_CASE_2_3" ] = VINYL_CASE_2_C,
    [ "VINYL_CASE_3_3" ] = VINYL_CASE_3_C,

    [ "VINYL_CASE_1_4" ] = VINYL_CASE_1_D,
    [ "VINYL_CASE_2_4" ] = VINYL_CASE_2_D,
    [ "VINYL_CASE_3_4" ] = VINYL_CASE_3_D,  

    [ "VINYL_CASE_1_5" ] = VINYL_CASE_1_S,
    [ "VINYL_CASE_2_5" ] = VINYL_CASE_2_S,
    [ "VINYL_CASE_3_5" ] = VINYL_CASE_3_S,

	[ "VINYL_CASE_1_6" ] = VINYL_CASE_1_M,
	[ "VINYL_CASE_2_6" ] = VINYL_CASE_2_M,
	[ "VINYL_CASE_3_6" ] = VINYL_CASE_3_M,
}

CONST_SUBSCRIPTION_DISCOUNT_END_TIMESTAMP = 1553644801 + ( 36 * 60 * 60 )

CONST_FIRST_CASES_EXP = 2500
CONST_MAX_CASES_EXP = 6000

-- Таксист частник
TAXI_LICENSE_ENDLESS = -1
TAXI_LICENSE_EXPIRED = -2
TAXI_LICENSE_NOT_PURCHASED = -3

TAXI_LICENSES = {
    [ 1 ] = { 11250, 48000, 49 },
    [ 2 ] = { 15000, 64000, 99 },
    [ 3 ] = { 22500, 96000, 129 },
    [ 4 ] = { 30000, 129000, 159 },
    [ 5 ] = { 37500, 160000, 199 },
}

TAXI_LICENSES_DURATIONS = {
    7, 30, TAXI_LICENSE_ENDLESS
}

-----------------------------------------------------
------ ЧАТ-КАНАЛЫ
-----------------------------------------------------

enum "eChatTypes" {
	"CHAT_TYPE_NORMAL",
	"CHAT_TYPE_ME",
	"CHAT_TYPE_ADMIN",
	"CHAT_TYPE_FACTION",
	"CHAT_TYPE_LOCALOOC",
	"CHAT_TYPE_DO",
	"CHAT_TYPE_TRY",
	"CHAT_TYPE_CLAN",
	"CHAT_TYPE_ALLFACTION",
	"CHAT_TYPE_TRADE",  
	"CHAT_TYPE_REPORT",
	"CHAT_TYPE_OFFGAME",
	"CHAT_TYPE_MEGAPHONE",
	"CHAT_TYPE_SMS",
	"CHAT_TYPE_JOB",
}

CHAT_CHANNELS_NAME = {
	[ CHAT_TYPE_NORMAL 	   ] = "Общий",
	[ CHAT_TYPE_ME 		   ] = "",
	[ CHAT_TYPE_FACTION    ] = "Фракция",
	[ CHAT_TYPE_LOCALOOC   ] = "",
	[ CHAT_TYPE_ADMIN      ] = "Админ",
	[ CHAT_TYPE_DO         ] = "",
	[ CHAT_TYPE_TRY        ] = "",
	[ CHAT_TYPE_CLAN       ] = "Клан",
	[ CHAT_TYPE_ALLFACTION ] = "Объявления фракций",
	[ CHAT_TYPE_TRADE      ] = "Торговый",
	[ CHAT_TYPE_REPORT     ] = "Репорт",
	[ CHAT_TYPE_OFFGAME    ] = "Оффтоп",
	[ CHAT_TYPE_MEGAPHONE  ] = "Мегафон",
	[ CHAT_TYPE_SMS		   ] = "СМС",
	[ CHAT_TYPE_JOB 	   ] = "Рабочий",
}

EVENTS_TIMES = {
	halloween = {
		from = 1603918800;
		to = 1605214799;
	};
	new_year = {
		from = 1608757200;
		to = 1610053199;
	};
	may_events = {
		from = 1619816400;
		to = 1620594000;
	};
}

CURRENT_EVENT = "may_events"
EVENT_COINS_VALUE_NAME   = CURRENT_EVENT .. "_2_event_coins"
EVENT_BOOSTER_VALUE_NAME = CURRENT_EVENT .. "_2_event_booster"

NEW_TUTORIAL_RELEASE_DATE = 1580334660