Extend( "SPlayer" )

SDB_SEND_CONNECTIONS_STATS = true
Extend( "SDB" )
Extend( "ShTimelib" )
Extend( "SPlayerOffline" )

COLUMNS = {
        { Field = "business_id",    Type = "varchar(128)",		Null = "NO",    Key = "PRI",	Default = ""	},
        { Field = "userid",	        Type = "int(11)",			Null = "NO",	Key = "",       Default = 0     },
        { Field = "client_id",		Type = "char(36)",			Null = "YES",	Key = "",	    Default = NULL	},
        { Field = "balance",	    Type = "bigint(17)",		Null = "NO",	Key = "",       Default = 0     },
        { Field = "materials",	    Type = "int(11)",			Null = "NO",	Key = "",       Default = 0     },
        { Field = "purchase_date",	Type = "int(11)",			Null = "NO",	Key = "",       Default = 0     },
        { Field = "on_sale",	    Type = "int(11)",			Null = "NO",	Key = "",       Default = 0     },
        { Field = "sale_cost",	    Type = "int(11)",			Null = "NO",	Key = "",       Default = 0     },
        { Field = "gov_id",	        Type = "int(11)",			Null = "NO",	Key = "",       Default = 0     },
        { Field = "payment_date",	Type = "int(11)",			Null = "NO",	Key = "",       Default = 0     },
        { Field = "level",	        Type = "int(11)",			Null = "NO",	Key = "",       Default = 1     },
        { Field = "succes_value",	Type = "int(11)",			Null = "NO",	Key = "",       Default = 0     },
        { Field = "bribe_date",	    Type = "int(11)",			Null = "NO",	Key = "",       Default = 0     },
}
DB:createTable( "nrp_businesses", COLUMNS )

COLUMNS_REVERSE = { }
for i, v in pairs( COLUMNS ) do
    COLUMNS_REVERSE[ v.Field ] = true
end

-- Ценники и настройки
BUSINESSES_CONFIG = {
    -- Общее
    GENERAL = {
        max_materials = 151, -- Максимальное место на складе
        sell_amounts = { 44, 49, 58 }, -- Количество на продажу
        sell_thresholds = { 0, 44, 93 }, -- Пороги продажи по окупаемости
        sell_percentages = { 0.75, 0.85, 1 }, -- Процентаж выплаты за день
    },

    -- Индивидуальное
    smallshop = { 
        name = "Ларёк",
        cost = 2500000,
        daily_income = 92921,
        daily_business_coins = 3,
        material_cost = 1000,
        weekly_cost = 50000,
        max_balance = 580000,
        task = "Данный бизнес занимается продажей журналов",
        task_short = "Продажа журналов",
        max_weekly_income = 650446,
    },

    shop = {
        name = "Магазин",
        cost = 5000000,
        daily_income = 120699,
        daily_business_coins = 3,
        material_cost = 1000,
        weekly_cost = 100000,
        max_balance = 580000,
        task = "Данный бизнес занимается продажей продуктов питания",
        task_short = "Продажа прод. питания",
        max_weekly_income = 844891,
    },

    -- Магнит в г.Горки - особый ценник
    shop_1 = {
        uniq = true,
        cost = 7000000,
        daily_income = 164564,
        daily_business_coins = 3,
        material_cost = 1250,
        max_balance = 725000,
        weekly_cost = 100000,
        task = "Данный бизнес занимается продажей продуктов питания",
        task_short = "Продажа прод. питания",
        max_weekly_income = 1151946,
    },

    repairstore = {
        name = "СТО",
        cost = 8000000,
        daily_income = 190174,
        daily_business_coins = 6,
        material_cost = 1500,
        weekly_cost = 200000,
        max_balance = 870000,
        task = "Данный бизнес занимается ремонтом транспорта",
        task_short = "Ремонт транспорта",
        max_weekly_income = 1331221,
    },

    drugstore = {
        name = "Аптека",
        cost = 5000000,
        daily_income = 185627,
        daily_business_coins = 8,
        material_cost = 1750,
        weekly_cost = 200000,
        max_balance = 1015000,
        task = "Данный бизнес занимается продажей лекарств",
        task_short = "Продажа лекарств",
        max_weekly_income = 1299392,
    },

    gasstation = {
        name = "Заправка",
        cost = 12000000,
        daily_income = 266305,
        daily_business_coins = 9,
        material_cost = 1800,
        weekly_cost = 200000,
        max_balance = 1044000,
        task = "Данный бизнес занимается продажей топлива",
        task_short = "Продажа топлива",
        max_weekly_income = 1864134,
    },

    carsell_exclusive = {
        name = "Эксклюзив Салон",
        cost = 30000000,
        daily_income = 482442,
        daily_business_coins = 6,
        material_cost = 3000,
        weekly_cost = 350000,
        max_balance = 1740000,
        task = "Данный бизнес занимается продажей и обслуживанием автомобилей",
        task_short = "Продажа и обсл. авто",
        max_weekly_income = 3377093,
        icon = true,
    },

    carsell_premium = {
        name = "Премиум Салон",
        cost = 25000000,
        daily_income = 430715,
        daily_business_coins = 13,
        material_cost = 2500,
        weekly_cost = 250000,
        max_balance = 1450000,
        task = "Данный бизнес занимается продажей и обслуживанием автомобилей",
        task_short = "Продажа и обсл. авто",
        max_weekly_income = 3015002,
        icon = true,
    },

    carsell_standard = {
        name = "Стандарт Салон",
        cost = 20000000,
        daily_income = 366215,
        daily_business_coins = 17,
        material_cost = 2250,
        weekly_cost = 250000,
        max_balance = 1305000,
        task = "Данный бизнес занимается продажей и обслуживанием автомобилей",
        task_short = "Продажа и обсл. авто",
        max_weekly_income = 2563503,
        icon = true,
    },

    carsell_economy = {
        name = "Эконом Салон",
        cost = 15000000,
        daily_income = 311238,
        daily_business_coins = 19,
        material_cost = 2000,
        weekly_cost = 250000,
        max_balance = 1160000,
        task = "Данный бизнес занимается продажей и обслуживанием автомобилей",
        task_short = "Продажа и обсл. авто",
        max_weekly_income = 2178666,
        icon = true,
    },

    tradecentre = {
        name = "Торговый Центр",
        cost = 30000000,
        daily_income = 482442,
        daily_business_coins = 20,
        material_cost = 3000,
        weekly_cost = 350000,
        max_balance = 1740000,
        task = "Данный бизнес занимается сдачей площадей в аренду",
        task_short = "Сдача в аренду",
        max_weekly_income = 3377093,
    },

    tradecentre_plaza = {
        name = "ТЦ Плаза",
        cost = 32500000,
        daily_income = 519669,
        daily_business_coins = 20,
        material_cost = 3250,
        weekly_cost = 375000,
        max_balance = 1885000,
        max_weekly_income = 3637684,
        icon = true,
    },

    hotel_luxe = {
        name = "Гостиница Люкс",
        cost = 20000000,
        daily_income = 366215,
        daily_business_coins = 27,
        material_cost = 2250,
        weekly_cost = 250000,
        max_balance = 1305000,
        max_weekly_income = 2563503,
        task = "Данный бизнес занимается арендой номеров",
        task_short = "Аренда номеров",
        icon = true,
    },

    hotel_premium = {
        name = "Гостница Премиальная",
        cost = 25000000,
        daily_income = 445000,
        daily_business_coins = 30,
        material_cost = 2500,
        weekly_cost = 240000,
        max_balance = 1450000,
        max_weekly_income = 3115002,
        task = "Данный бизнес занимается арендой номеров",
        task_short = "Аренда номеров",
        icon = true,
    },

    hotel_nsk = {
        name = "Гостница Новороссийск",
        cost = 35000000,
        daily_income = 571182,
        daily_business_coins = 20,
        material_cost = 3500,
        weekly_cost = 400000,
        max_balance = 2030000,
        max_weekly_income = 3998275,
        task = "Данный бизнес занимается арендой номеров",
        task_short = "Аренда номеров",
        icon = true,
    },

    castle = {
        name = "Гостница Кастел",
        cost = 40000000,
        daily_income = 649207,
        daily_business_coins = 32,
        material_cost = 4000,
        weekly_cost = 400000,
        max_balance = 2320000,
        max_weekly_income = 4554449,
        task = "Данный бизнес занимается арендой номеров",
        task_short = "Аренда номеров",
    },

    hypermarket = {
        name = "Гипермаркет",
        cost = 17000000,
        daily_income = 334460,
        daily_business_coins = 27,
        material_cost = 2000,
        weekly_cost = 250000,
        max_balance = 1160000,
        task = "Данный бизнес занимается продажей товаров",
        task_short = "Продажа товаров",
        max_weekly_income = 2341220,
    },

    flowers = {
        name = "Магазин Цветов",
        cost = 3000000,
        daily_income = 92921,
        daily_business_coins = 25,
        material_cost = 1000,
        weekly_cost = 50000,
        max_balance = 580000,
        task = "Данный бизнес занимается продажей цветов",
        task_short = "Продажа цветов",
        max_weekly_income = 650446,
    },

    market = {
        name = "Магазин ИП",
        cost = 3000000,
        daily_income = 92921,
        daily_business_coins = 25,
        material_cost = 1000,
        weekly_cost = 50000,
        max_balance = 580000,
        task = "Данный бизнес занимается продажей товаров",
        task_short = "Продажа товаров",
        max_weekly_income = 650446,
    },

    circus = {
        name = "Цирк Шапито",
        cost = 20000000,
        daily_income = 366215 ,
        daily_business_coins = 36,
        material_cost = 2250,
        weekly_cost = 250000,
        max_balance = 1305000,
        task = "Данный бизнес занимается показом цирковых номеров",
        task_short = "Показ представлений",
        max_weekly_income = 2563503,
    },

    -- Торговый центр рублёво
    tradecentre_nika = {
        name = "ТЦ Ника",
        cost = 20000000,
        daily_income = 366214,
        daily_business_coins = 20,
        material_cost = 2250,
        weekly_cost = 250000,
        max_balance = 1305000,
        task = "Данный бизнес занимается сдачей помещений в аренду",
        task_short = "Сдача в аренду",
        max_weekly_income = 2563502,
        icon = true,
    },

    -- Новые бизнесы
    catering_restaurant_spassky = {
        name = "Ресторан спасский",
        cost = 40000000,
        daily_income = 643661,
        daily_business_coins = 44,
        material_cost = 4000,
        weekly_cost = 400000,
        max_balance = 2114000,
        task = "Данный бизнес занимается продажей изысканных блюд",
        task_short = "Продажа блюд",
        max_weekly_income = 4505630,
    },

    tradecentre_nikolsky_passage = {
        name = "Никольский пассаж",
        cost = 45000000,
        daily_income = 724119,
        daily_business_coins = 50,
        material_cost = 4500,
        weekly_cost = 450000,
        max_balance = 2378250,
        task = "Данный бизнес занимается арендой торговых площадей",
        task_short = "Аренда площадей",
        max_weekly_income = 5068833,
    },

    tradecentre_childrens_gum = {
        name = "Детский ГУМ",
        cost = 50000000,
        daily_income = 804577,
        daily_business_coins = 56,
        material_cost = 5000,
        weekly_cost = 500000,
        max_balance = 2642500,
        task = "Данный бизнес занимается арендой торговых площадей",
        task_short = "Аренда площадей",
        max_weekly_income = 5632037,
    },

    tradecentre_adult_world = {
        name = "ТЦ взрослый мир",
        cost = 30000000,
        daily_income = 482746,
        daily_business_coins = 33,
        material_cost = 3000,
        weekly_cost = 300000,
        max_balance = 1585500,
        task = "Данный бизнес занимается арендой торговых площадей",
        task_short = "Аренда площадей",
        max_weekly_income = 3379222,
    },

    catering_restaurant = {
        name = "Ресторан",
        cost = 20000000,
        daily_income = 321831,
        daily_business_coins = 22,
        material_cost = 2000,
        weekly_cost = 200000,
        max_balance = 1057000,
        task = "Данный бизнес занимается продажей блюд",
        task_short = "Продажа блюд",
        max_weekly_income = 2252815,
    },

    bank = {
        name = "Банк",
        cost = 35000000,
        daily_income = 563204,
        daily_business_coins = 39,
        material_cost = 3500,
        weekly_cost = 350000,
        max_balance = 1849750,
        task = "Данный бизнес занимается валютными операциями",
        task_short = "Валютные операции",
        max_weekly_income = 3942426,
    },

    tradecentre_spring = {
        name = "ТЦ весна",
        cost = 28000000,
        daily_income = 450563,
        daily_business_coins = 31,
        material_cost = 2800,
        weekly_cost = 280000,
        max_balance = 1479800,
        task = "Данный бизнес занимается арендой торговых площадей",
        task_short = "Аренда площадей",
        max_weekly_income = 3153941,
    },

    catering_cafe = {
        name = "Кафе",
        cost = 10000000,
        daily_income = 160915,
        daily_business_coins = 11,
        material_cost = 1000,
        weekly_cost = 100000,
        max_balance = 528500,
        task = "Данный бизнес занимается продажей готовых блюд",
        task_short = "Продажа блюд",
        max_weekly_income = 1126407,
    },

    school_private = {
        name = "Частная школа",
        cost = 30000000,
        daily_income = 482746,
        daily_business_coins = 33,
        material_cost = 3000,
        weekly_cost = 300000,
        max_balance = 1585500,
        task = "Данный бизнес занимается обучением детей",
        task_short = "Обучение",
        max_weekly_income = 3379222,
    },

    tradecentre_metropolis = {
        name = "ТЦ метрополис",
        cost = 40000000,
        daily_income = 643661,
        daily_business_coins = 44,
        material_cost = 4000,
        weekly_cost = 400000,
        max_balance = 2114000,
        task = "Данный бизнес занимается арендой торговых площадей",
        task_short = "Аренда площадей",
        max_weekly_income = 4505630,
    },

    tradecentre_tsum = {
        name = "ТЦ ЦУМ",
        cost = 60000000,
        daily_income = 965492,
        daily_business_coins = 67,
        material_cost = 6000,
        weekly_cost = 600000,
        max_balance = 3171000,
        task = "Данный бизнес занимается арендой торговых площадей",
        task_short = "Аренда площадей",
        max_weekly_income = 6758444,
    },

    school_dancing = {
        name = "Школа танцев",
        cost = 15000000,
        daily_income = 241373,
        daily_business_coins = 17,
        material_cost = 1500,
        weekly_cost = 150000,
        max_balance = 792750,
        task = "Данный бизнес занимается обучением танцев",
        task_short = "Обучение",
        max_weekly_income = 1689611,
    },

    tradecentre_book_house = {
        name = "Дом книги",
        cost = 20000000,
        daily_income = 321831,
        daily_business_coins = 22,
        material_cost = 2000,
        weekly_cost = 200000,
        max_balance = 1057000,
        task = "Данный бизнес занимается продажей книг",
        task_short = "Продажа книг",
        max_weekly_income = 2252815,
    },

    catering_restaurant_inpark = {
        name = "Ресторан в парке",
        cost = 18000000,
        daily_income = 289648,
        daily_business_coins = 20,
        material_cost = 1800,
        weekly_cost = 180000,
        max_balance = 951300,
        task = "Данный бизнес занимается продажей изысканных блюд",
        task_short = "Продажа блюд",
        max_weekly_income = 2027533,
    },

    tuning = {
        name = "Тюнинг",
        cost = 25000000,
        daily_income = 402288,
        daily_business_coins = 28,
        material_cost = 2500,
        weekly_cost = 250000,
        max_balance = 1321250,
        task = "Данный бизнес занимается доработкой транспортных средств",
        task_short = "Доработка ТС",
        max_weekly_income = 2816019,
    },

    cinema = {
        name = "Кинотеатр",
        cost = 19000000,
        daily_income = 305739,
        daily_business_coins = 21,
        material_cost = 1900,
        weekly_cost = 190000,
        max_balance = 1004150,
        task = "Данный бизнес занимается показом фильмов",
        task_short = "Показ фильмов",
        max_weekly_income = 2140174,
    },

    tradecentre_gum = {
        name = "ТЦ ГУМ",
        cost = 65000000,
        daily_income = 1045950,
        daily_business_coins = 72,
        material_cost = 6500,
        weekly_cost = 650000,
        max_balance = 3435250,
        task = "Данный бизнес занимается показом фильмов",
        task_short = "Показ фильмов",
        max_weekly_income = 7321648,
    },

    -- Новые бизнесы 2

    tuning_common = {
        name = "Тюнинг стандартный",
        cost = 15000000,
        daily_income = 241373,
        daily_business_coins = 17,
        material_cost = 1500,
        weekly_cost = 150000,
        max_balance = 792750,
        task = "Данный бизнес занимается доработкой транспортных средств",
        task_short = "Доработка ТС",
        max_weekly_income = 1689611,
    },

    construction = {
        name = "Стройка",
        cost = 27000000,
        daily_income = 434471,
        daily_business_coins = 30,
        material_cost = 2700,
        weekly_cost = 270000,
        max_balance = 1426950,
        task = "Данный бизнес занимается строительством жилых домов",
        task_short = "Строительство",
        max_weekly_income = 3041300,
    },

    plant = {
        name = "Завод",
        cost = 50000000,
        daily_income = 804577,
        daily_business_coins = 56,
        material_cost = 5000,
        weekly_cost = 500000,
        max_balance = 2642500,
        task = "Данный бизнес занимается производством сырья",
        task_short = "Производство",
        max_weekly_income = 5632037,
    },

    bus_depot = {
        name = "Автобусный парк",
        cost = 15000000,
        daily_income = 241373,
        daily_business_coins = 17,
        material_cost = 1500,
        weekly_cost = 150000,
        max_balance = 792750,
        task = "Данный бизнес занимается обслуживанием общественного транспорта",
        task_short = "Обслуживание ТС",
        max_weekly_income = 1689611,
    },

    hotel_gorki = {
        name = "Отель Горки",
        cost = 19000000,
        daily_income = 305739,
        daily_business_coins = 21,
        material_cost = 1900,
        weekly_cost = 190000,
        max_balance = 1004150,
        task = "Данный бизнес занимается сдачей номеров",
        task_short = "Сдача номеров",
        max_weekly_income = 2140174,
    },

    oter_marriott = {
        name = "Отель Марриотт",
        cost = 35000000,
        daily_income = 563204,
        daily_business_coins = 13,
        material_cost = 3500,
        weekly_cost = 350000,
        max_balance = 1849750,
        task = "Данный бизнес занимается сдачей номеров",
        task_short = "Сдача номеров",
        max_weekly_income = 3942426,
    },

    apart_hotel_gorki = {
        name = "Аппарт Отель Горки",
        cost = 12000000,
        daily_income = 193098,
        daily_business_coins = 13,
        material_cost = 1200,
        weekly_cost = 120000,
        max_balance = 634200,
        task = "Данный бизнес занимается сдачей номеров",
        task_short = "Сдача номеров",
        max_weekly_income = 1351689,
    },

    apart_hotel_nsk = {
        name = "Аппарт Отель НСК",
        cost = 15000000,
        daily_income = 241373,
        daily_business_coins = 17,
        material_cost = 1500,
        weekly_cost = 150000,
        max_balance = 792750,
        task = "Данный бизнес занимается сдачей номеров",
        task_short = "Сдача номеров",
        max_weekly_income = 1689611,
    },

    apart_hotel_msk = {
        name = "Аппарт Отель МСК",
        cost = 18000000,
        daily_income = 289648,
        daily_business_coins = 20,
        material_cost = 1800,
        weekly_cost = 180000,
        max_balance = 951300,
        task = "Данный бизнес занимается сдачей номеров",
        task_short = "Сдача номеров",
        max_weekly_income = 2027533,
    },

    private_dump = {
        name = "Частная свалка",
        cost = 20000000,
        daily_income = 321831,
        daily_business_coins = 22,
        material_cost = 2000,
        weekly_cost = 200000,
        max_balance = 1057000,
        task = "Данный бизнес занимается сбором и хранением отходов",
        task_short = "Хранение отходов",
        max_weekly_income = 2252815,
    },

    strip_club = {
        name = "Стрип клуб",
        cost = 25000000,
        daily_income = 402288,
        daily_business_coins = 28,
        material_cost = 2500,
        weekly_cost = 250000,
        max_balance = 1321250,
        task = "Данный бизнес занимается взрослым развлечением",
        task_short = "Развлечения для 18+",
        max_weekly_income = 2816019,
    },

    transport_service = {
        name = "Транспортный сервис",
        cost = 16000000,
        daily_income = 257465,
        daily_business_coins = 18,
        material_cost = 1600,
        weekly_cost = 160000,
        max_balance = 845600,
        task = "Данный бизнес занимается транспортным обслуживанием",
        task_short = "Обслуживание ТС",
        max_weekly_income = 1802252,
    },

    private_warehouse = {
        name = "Частный склад",
        cost = 10000000,
        daily_income = 160915,
        daily_business_coins = 11,
        material_cost = 1000,
        weekly_cost = 100000,
        max_balance = 528500,
        task = "Данный бизнес занимается хранением товаров",
        task_short = "Хранение товаров",
        max_weekly_income = 1126407,
    },

    hotel_ukraine = {
        name = "Гостиница Украина",
        cost = 65000000,
        daily_income = 1045950,
        daily_business_coins = 72,
        material_cost = 6500,
        weekly_cost = 650000,
        max_balance = 3435250,
        task = "Данный бизнес занимается сдачей номеров",
        task_short = "Сдача номеров",
        max_weekly_income = 7321648,
    },

    nsk_airport = {
        name = "Аэропорт НСК",
        cost = 40000000,
        daily_income = 643661,
        daily_business_coins = 44,
        material_cost = 4000,
        weekly_cost = 400000,
        max_balance = 2114000,
        task = "Данный бизнес занимается воздушной перевозкой",
        task_short = "Воздушные перевозки",
        max_weekly_income = 4505630,
    },

    grk_airport = {
        name = "Аэропорт ГРК",
        cost = 30000000,
        daily_income = 482746,
        daily_business_coins = 33,
        material_cost = 3000,
        weekly_cost = 300000,
        max_balance = 1585500,
        task = "Данный бизнес занимается воздушной перевозкой",
        task_short = "Воздушные перевозки",
        max_weekly_income = 3379222,
    },

    moskovsky_port = {
        name = "Московский Порт",
        cost = 55000000,
        daily_income = 885034,
        daily_business_coins = 61,
        material_cost = 5500,
        weekly_cost = 550000,
        max_balance = 2906750,
        task = "Данный бизнес занимается погрузкой кораблей",
        task_short = "Погрузка кораблей",
        max_weekly_income = 6195241,
    },

    private_parking = {
        name = "Частная парковка",
        cost = 4000000,
        daily_income = 64366,
        daily_business_coins = 4,
        material_cost = 400,
        weekly_cost = 40000,
        max_balance = 211400,
        task = "Данный бизнес занимается сдачей парковочных мест",
        task_short = "Сдача парковочных мест",
        max_weekly_income = 450563,
    },

    railway_station = {
        name = "Вокзал",
        cost = 45000000,
        daily_income = 724119,
        daily_business_coins = 50,
        material_cost = 4500,
        weekly_cost = 450000,
        max_balance = 2378250,
        task = "Данный бизнес занимается транспортировкой грузов",
        task_short = "Транспортировка грузов",
        max_weekly_income = 5068833,
    },

    shipyard = {
        name = "Верфь",
        cost = 20000000,
        daily_income = 321831,
        daily_business_coins = 22,
        material_cost = 2000,
        weekly_cost = 200000,
        max_balance = 1057000,
        task = "Данный бизнес занимается обслуживанием морской техники",
        task_short = "Обслуживание морской техники",
        max_weekly_income = 2252815,
    },

    workshop = {
        name = "Мастерская",
        cost = 22000000,
        daily_income = 354014,
        daily_business_coins = 24,
        material_cost = 2200,
        weekly_cost = 220000,
        max_balance = 1162700,
        task = "Данный бизнес занимается обслуживанием гоночного транспорта",
        task_short = "Обслуживание гоночного транспорта",
        max_weekly_income = 2478096,
    },

    clothing_store = {
        name = "Магазин одежды",
        cost = 15000000,
        daily_income = 241373,
        daily_business_coins = 17,
        material_cost = 1500,
        weekly_cost = 150000,
        max_balance = 792750,
        task = "Данный бизнес занимается продажей одежды",
        task_short = "Продажа одежды",
        max_weekly_income = 1689611,
    },

    moscow_central_bank = {
        name = "Московский центральный банк",
        cost = 70000000,
        daily_income = 1126407,
        daily_business_coins = 78,
        material_cost = 7000,
        weekly_cost = 700000,
        max_balance = 3699500,
        task = "Данный бизнес занимается регулированием и финансированием банков",
        task_short = "Финансирование банков",
        max_weekly_income = 7884852,
    },

    gun_shop = {
        name = "Оружейный магазин",
        cost = 30000000,
        daily_income = 482746,
        daily_business_coins = 33,
        material_cost = 3000,
        weekly_cost = 300000,
        max_balance = 1585500,
        task = "Данный бизнес занимается продажей оружия",
        task_short = "Продажа оружия",
        max_weekly_income = 3379222,
    },

    tretyakov_gallery = {
        name = "Третьяковская галерея",
        cost = 55000000,
        daily_income = 885034,
        daily_business_coins = 61,
        material_cost = 5500,
        weekly_cost = 550000,
        max_balance = 2906750,
        task = "Данный бизнес занимается продажей искусства",
        task_short = "Продажа искусства",
        max_weekly_income = 6195241,
    },

    sawmill = {
        name = "Лесопилка",
        cost = 40000000,
        daily_income = 643661,
        daily_business_coins = 44,
        material_cost = 4000,
        weekly_cost = 400000,
        max_balance = 2114000,
        task = "Данный бизнес занимается обработкой древесины",
        task_short = "Обработка древесины",
        max_weekly_income = 4505630,
    },
}

local INCOME_COEFS_BY_LEVEL = { 1, 1.700785848, 2.551178772 }

local CUSTOM_DAILY_INCOME_BY_LEVEL = {
    smallshop         = { 92921  , 151063  , 226595  },
    shop              = { 120699 , 201460  , 302190  },
    shop_1            = { 164564 , 255516  , 383274  },
    repairstore       = { 190174 , 323698  , 485548  },
    drugstore         = { 185627 , 305532  , 458298  },
    gasstation        = { 266305 , 411676  , 617514  },
    carsell_exclusive = { 482442 , 835333  , 1253000 },
    carsell_premium   = { 430715 , 684206  , 1026310 },
    carsell_standard  = { 366215 , 586817  , 880226  },
    carsell_economy   = { 311238 , 489429  , 734143  },
    tradecentre       = { 482442 , 835333  , 1253000 },
    tradecentre_plaza = { 519669 , 903754  , 1355631 },
    flowers           = { 92921  , 158286  , 237429  },
    hypermarket       = { 334460 , 518317  , 777476  },
    hotel_luxe        = { 366215 , 586817  , 880226  },
    hotel_premium     = { 445000 , 681349  , 1022024 },
    hotel_nsk         = { 571182 , 972175  , 1458262 },
    market            = { 92921  , 158286  , 237429  },
    castle            = { 649207 , 1094730 , 1642095 },
    circus            = { 366215 , 586817  , 880226  },
    tradecentre_nika  = { 366214 , 586817  , 880226  },
}

local BUSINESS_LEVEL_CONFIG_FNS = {
    cost = function( business_id, default_value, level )
        return default_value * level
    end,

    daily_income = function( business_id, default_value, level )
        local type = string.gsub( business_id, "_%d+$", "" )
        return CUSTOM_DAILY_INCOME_BY_LEVEL[ type ] and CUSTOM_DAILY_INCOME_BY_LEVEL[ type ][ level ]
            or math.ceil( default_value * INCOME_COEFS_BY_LEVEL[ level ] )
    end,

    daily_business_coins = function( business_id, default_value, level )
        return math.floor( default_value * ( 1.5 ^ ( level - 1 ) ) )
    end,

    material_cost = function( business_id, default_value, level )
        return default_value * level
    end,

    weekly_cost = function( business_id, default_value, level )
        return default_value * level
    end,

    max_balance = function( business_id, default_value, level )
        return default_value * level
    end,

    max_weekly_income = function( business_id, default_value, level )
        return math.ceil( default_value * INCOME_COEFS_BY_LEVEL[ level ] )
    end,
}

-- Сохраняемые динамические данные
BUSINESSES_DATA = { }

local economy_gov_col_gorki = createColPolygon( 
    766.843, 810.115,
    1441.938, -746.776,
    1423.772, -2566.652,
    2453.478, -2781.978,
    2886.809, 980.540,
    766.843, 810.115
)

local economy_gov_col_nsk = createColPolygon( 
    -3096.5918, 1888.2307,
    -3035.4666, 1988.7473,
    -2936.3083, 2043.0806,
    -2766.5166, 2077.0391,
    -2541.0332, 2075.6807,
    -2301.9668, 2003.6891,
    -2068.3335, 1843.4056,
    -1936.575, 1559.514,
    -1899.9, 1236.2306,
    -1874.0918, 1039.2725,
    -1735.5416, 876.2725,
    -1527.7167, 717.3474,
    -1299.5167, 572.0057,
    -1116.1418, 398.4409,
    -878.4335, 142.4705,
    -696.4168, -68.0712,
    -489.9501, -380.4879,
    -337.8167, -751.3128,
    -13.175, -952.799,
    325.05, -928.349,
    657.1625, -906.6157,
    954.6376, -910.6906,
    1136.6542, -1039.7323,
    1353.9875, -1163.3406,
    1392.7001, -1256.9901,
    1389.3042, -1334.4152,
    1419.8667, -1424.0652,
    1451.1083, -1525.9402,
    1480.9917, -1611.5151,
    1489.8208, -1850.7328,
    1491.8584, -1988.6036,
    1475.5583, -2133.9453,
    1461.975, -2241.2537,
    1427.3375, -2379.2754,
    1385.2291, -2513.0713,
    1369.6084, -2729.499,
    1319.3501, -2919.2666,
    1100.6584, -3059.175,
    657.8417, -3063.25,
    201.4418, -3052.3833,
    -28.1166, -2841.8416,
    -161.2333, -2541.6499,
    -345.9667, -2268.1721,
    -659.7416, -2167.6555,
    -1109.35, -2178.2205,
    -1587.4833, -2205.3872,
    -2003.1333, -2338.6548,
    -2417.425, -2371.2549,
    -2682.3, -2333.2214,
    -2970.2666, -2194.6714,
    -3134.625, -1855.0881,
    -3110.175, -1577.0825,
    -2985.2083, -1370.616,
    -2987.925, -1194.0326,
    -3138.7002, -995.7159,
    -3218.8418, -540.6742,
    -3160.4333, -229.6159,
    -3108.8169, 187.6943,
    -3062.6333, 534.0693,
    -3025.9585, 961.6424,
    -3009.6584, 1291.7174,
    -3084.3667, 1633.4137,
    -3096.5918, 1888.2307
)

function LoadBusinessData( business_id, business_info )
    DB:queryAsync( function( query, business_id )
        local result = dbPoll( query, -1 )

        -- Бизнес существует
        if result[ 1 ] then
            BUSINESSES_DATA[ business_id ] = result[ 1 ]
            --iprint( "Loaded business from config:", business_id )

            if BUSINESSES_DATA[ business_id ].userid ~= 0 then
                StartBusinessTimer( business_id )
            end

        -- Бизнес не существует, нужно создать дефолт конфиг
        else
            DB:exec( "INSERT INTO nrp_businesses(business_id) VALUES(?)", business_id )
            BUSINESSES_DATA[ business_id ] = { business_id = business_id, userid = 0, client_id = "", balance = 0, materials = 0, purchase_date = 0, on_sale = 0, level = 1, succes_value = 0 }
            --iprint( "Created new business entry:", business_id )

		end

		--if not BUSINESSES_DATA[ business_id ].gov_id or BUSINESSES_DATA[ business_id ].gov_id == 0 then
			if isInsideColShape( economy_gov_col_gorki, business_info.x, business_info.y, business_info.z ) then
				BUSINESSES_DATA[ business_id ].gov_id = F_GOVERNMENT_GORKI
            elseif isInsideColShape( economy_gov_col_nsk, business_info.x, business_info.y, business_info.z ) then
                BUSINESSES_DATA[ business_id ].gov_id = F_GOVERNMENT_NSK
            else
                BUSINESSES_DATA[ business_id ].gov_id = F_GOVERNMENT_MSK
			end
		--end

        triggerEvent( "onBusinessLoad", resourceRoot, business_id, BUSINESSES_DATA[ business_id ] )
        
    end, { business_id }, "SELECT * FROM nrp_businesses WHERE business_id=? LIMIT 1", business_id )
end

function SaveBusinessData( business_id )
    local query_table = { }

    for i, v in pairs( BUSINESSES_DATA[ business_id ] ) do
		table.insert( query_table, dbPrepareString( DB, "`??`=?", i, type( v ) == "table" and toJSON( v, true ) or v ) )
    end

    local query_str = table.concat( { "UPDATE nrp_businesses SET ", table.concat( query_table, ", " ), dbPrepareString( DB, " WHERE business_id=? LIMIT 1", business_id ) }, '' )
	DB:exec( query_str )
end

-- Постоянные данные
function GetBusinessData( business_id, key )
    if COLUMNS_REVERSE[ key ] then
        if not  BUSINESSES_DATA[ business_id ] then
            WriteLog( "businesses/error_get_data", "Ошибка получения данных бизнеса %s, данных %s", business_id, key )
        end

        return BUSINESSES_DATA[ business_id ][ key ] 
    end
end

function SetBusinessData( business_id, key, value )
    if COLUMNS_REVERSE[ key ] then 
        BUSINESSES_DATA[ business_id ][ key ] = value
    end
end

-- Хардкод-данные вида ценников
function GetBusinessDefaultConfig( business_id, key )
    -- Конкретный конфиг
    if BUSINESSES_CONFIG[ business_id ] and BUSINESSES_CONFIG[ business_id ][ key ] ~= nil then
        return BUSINESSES_CONFIG[ business_id ][ key ]
    else
        -- Конфиг категории бизнеса
        local business_category = string.gsub( business_id, "_%d+$", "" )
        if BUSINESSES_CONFIG[ business_category ] and BUSINESSES_CONFIG[ business_category ][ key ] then
            return BUSINESSES_CONFIG[ business_category ][ key ]

        -- Общий конфиг
        else
            return BUSINESSES_CONFIG.GENERAL[ key ]
        end
    end
end

function GetBusinessConfig( business_id, key )
    local value = GetBusinessDefaultConfig( business_id, key )
    if BUSINESS_LEVEL_CONFIG_FNS[ key ] then
        value = BUSINESS_LEVEL_CONFIG_FNS[ key ]( business_id, value, GetBusinessData( business_id, "level" ) or 1 )
    end
    return value
end

-- Сброс бизнеса
function ResetBusiness( business_id )
    KillBusinessTimer( business_id )
    BUSINESSES_DATA[ business_id ] = { business_id = business_id, userid = 0, client_id = "", balance = 0, materials = 0, purchase_date = 0, on_sale = 0, level = 1, succes_value = 0 }
    SaveBusinessData( business_id )

    UpdateBusinessBlips( )
end

-- Проверки на владение
function HasOwner( business_id )
    return GetBusinessData( business_id, "userid" ) > 0
end

function IsOwnedBy( business_id, player )
    return GetBusinessData( business_id, "userid" ) == player:GetUserID( )
end

function GetOwnedBusinesses( player )
    local owned_businesses = { }
    local userid = player:GetUserID( )
    for i, v in pairs( BUSINESSES ) do
        if GetBusinessData( v.id, "userid" ) == userid then
            table.insert( owned_businesses, v.id )
        end
    end
    return owned_businesses
end

function GetOwnedBusinessesData( player )
    local owned_businesses = { }
    local userid = player:GetUserID( )
    for i, v in pairs( BUSINESSES ) do
        if GetBusinessData( v.id, "userid" ) == userid then
            table.insert( owned_businesses, {
				business_id = v.id;
				name = GetBusinessConfig( v.id, "name" );
				level = GetBusinessData( v.id, "level" );
				succes_value = GetBusinessData( v.id, "succes_value" );
				balance = GetBusinessData( v.id, "balance" );
				materials = GetBusinessData( v.id, "materials" );
				max_weekly_income = GetBusinessConfig( v.id, "max_weekly_income" );
				max_balance = GetBusinessConfig( v.id, "max_balance" );
				max_materials = GetBusinessConfig( v.id, "max_materials" );
                material_cost = GetBusinessConfig( v.id, "material_cost" );
                icon = GetBusinessConfig( v.id, "icon" );
			} )
        end
    end
    return owned_businesses
end

-- Для ебучего F1
function GetOwnedBusinessesPositions( player )
    local owned_businesses = { }
    local userid = player:GetUserID( )
    for i, v in pairs( BUSINESSES ) do
        if GetBusinessData( v.id, "userid" ) == userid then
            table.insert( owned_businesses, { x = v.x, y = v.y, z = v.z } )
        end
    end
    return owned_businesses
end

-- Проверки на продажу. -1 - любому игроку, 0 - не продаётся, выше - userid кому продавать
function IsOnSale( business_id )
    local on_sale = GetBusinessData( business_id, "on_sale" )
    return ( on_sale > 0 or on_sale == -1 ) and on_sale
end

function CanBeSold( business_id )
    if GetBusinessData( business_id, "balance" ) <= 0 then
        return false, "Счёт бизнеса должен быть положительным!"
    end

    --[[ if getRealTimestamp( ) - GetBusinessData( business_id, "purchase_date" ) <= 3 * 24 * 60 * 60 then  -- Ограничение на продажу бизнеса 3 дня
        return false, "Не прошло 3 дня с момента покупки бизнеса"
    end]]

    if not GetBusinessData( business_id, "client_id" ):GetNickName( ) then 
        return false, "Не получилось найти владельца, попробуйте ещё раз!"
    end

    return true
end

-- Поиск бизнесов на продажу для игрока
function GetBusinessesOnSaleFor( player )
    local user_id = player and player:GetUserID( ) or -1

    local businesses = { }

    for i, v in pairs( BUSINESSES ) do
        local business_id = v.id
        local on_sale = IsOnSale( business_id )
        if on_sale == -1 or on_sale == user_id then
            table.insert( businesses, 
                {
                    business_id = business_id,
                    name = GetBusinessConfig( business_id, "name" ),
                    task_short = GetBusinessConfig( business_id, "task_short" ),
                    level = GetBusinessData( business_id, "level" ),
                    balance = GetBusinessData( business_id, "balance" ),
                    cost = GetBusinessData( business_id, "sale_cost" ),
                    owner_name = GetBusinessData( business_id, "client_id" ):GetNickName( ) or "Неизвестный",
                }
            )
        end
    end

    return businesses
end

-- Пороги продажи бизнеса
function GetBusinessSellMinMaxCost( business_id )
    local cost = GetBusinessConfig( business_id, "cost" )
    return math.floor( cost * 0.75 + 0.5 ), cost * 3
end

-- Чтение конфигов при старте
function onResourceStart_handler( )
    for i, v in pairs( BUSINESSES ) do
        LoadBusinessData( v.id, v )
    end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

-- Запись при отключении. На самом деле нахуй не нужно, на на всякий
function onResourceStop_handler( )
    for i, v in pairs( BUSINESSES ) do
        SaveBusinessData( v.id )
    end
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_handler )

-- Тестирование
if SERVER_NUMBER > 100 then
    addCommandHandler( "business_data", function( ply, cmd, business_id, level )
        if not ply:IsAdmin( ) then return end

        local config = BUSINESSES_CONFIG[ business_id ] or BUSINESSES_CONFIG[ string.gsub( business_id, "_%d+$", "" ) ]
        if not config then 
            outputConsole( "Бизнес не найден", ply )
            return
        end

        level = tonumber( level ) or 1
        outputConsole( "=============[ "..business_id.." ("..level .." ур) ]==============", ply )

        local params_to_read = 
        { 
            "name",
            "cost",
            "daily_income",
            "daily_business_coins",
            "material_cost",
            "weekly_cost",
            "max_balance",
            "task",
            "task_short",
            "max_weekly_income",
        }

        for k,v in pairs( params_to_read ) do
            local value = config[ v ] or "NONE"

            if tonumber( value ) then
                if BUSINESS_LEVEL_CONFIG_FNS[ v ] then
                    value = BUSINESS_LEVEL_CONFIG_FNS[ v ]( business_id, value, level )
                end
               value =  format_price( value )
            end

            outputConsole( v .. "     = " .. value, ply )
        end

        local calculated_params = 
        {
            businesses_money_1day = function( value )
                return math.floor( value / 90 )
            end,

            businesses_money_2day = function( value )
                return math.floor( value * 0.85 )
            end,

            businesses_money_3day = function( value )
                return math.floor( value * 0.75 )
            end,
        }

        local day1
        for k, v in pairs( calculated_params ) do
            local value = v( day1 or config.cost )
            if not day1 then day1 = value end

            outputConsole( k .. " = " .. value )
        end

        outputConsole( "______________________________________________________", ply )
    end)

    addCommandHandler( "ignore_business_limit", function( ply )
        if not ply:IsAdmin( ) then return end

        local state = ply:getData( "test_ignore_business_limit" )
        ply:setData( "test_ignore_business_limit", not state )
        outputChatBox( "Ограничение на покупку бизнесов: "..( state and "Включено (Прод)" or "Отключено (Тест)" ), ply, 255, 255, 255 )
    end )

    addCommandHandler( "goto_business", function( ply, cmd, id )
        if not ply:IsAdmin( ) then return end
        if not id then return end

        local id = tonumber( id )

        if not id or not BUSINESSES[ id ] then
            outputChatBox( "Бизнес не найден", ply, 255, 255, 255 )
        end

        ply.position = Vector3( 0, 0, 0 )
        ply.frozen = true

        setTimer(function( ply, id )
            if not isElement( ply ) then return end
            ply.position = Vector3{ x = BUSINESSES[ id ].x, y = BUSINESSES[ id ].y, z = BUSINESSES[ id ].z }
            ply.frozen = false
        end, 800, 1, ply, id)
    end )

    addCommandHandler( "take_business_daily_payment", function( ply, cmd, business_id )
        if not ply:IsAdmin( ) then return end

        if not BUSINESSES_DATA[ business_id ] then
            outputChatBox( "Бизнес не найден", ply, 255, 255, 255 )
            return
        end

        TakeBusinessDailyPayment( business_id )
    end )

    addCommandHandler( "set_business_succes_value", function( ply, cmd, business_id, value )
        if not ply:IsAdmin( ) then return end

        if not BUSINESSES_DATA[ business_id ] then
            outputChatBox( "Бизнес не найден", ply, 255, 255, 255 )
            return
        end

        SetBusinessData( business_id, "succes_value", math.min( tonumber( value ) or 0, MAX_SUCCES_VALUE ) )
    end )
end