CONST_DISTANCE_ACCESSORIES_SYNC = 30

CONST_ACCESSORIES_SLOTS_NAME = {
    [1] = "Голова",
    [2] = "Лицо",
    [3] = "Шея",
    [4] = "Спина / плечо",
    [5] = "Пояс",
}

CONST_ACCESSORIES_SLOTS_IDS = {
    [1] = "head",
    [2] = "face",
    [3] = "neck",
    [4] = "back",
    [5] = "belt",
}

CONST_ACCESSORIES_SLOTS_IDS_REVERT = { }

for key, value in pairs( CONST_ACCESSORIES_SLOTS_IDS ) do
    CONST_ACCESSORIES_SLOTS_IDS_REVERT[ value ] = key
end

CONST_ACCESSORIES_INFO = {
    bananaN = {
        slot = "belt",
        name = "Потайной карман Найки",
        model = 1776,

        premium = true,
    },

    chain = {
        slot = "neck",
        name = "Крест на цепи",
        model = 2221,

        premium = true,
    },

    eye = {
        slot = "face",
        name = "Повязка на глаз",
        model = 2453,

        premium = true,
    },

    wings = {
        slot = "back",
        name = "Белые крылья",
        model = 742,

        premium = true,
    },

    cap2 = {
        slot = "head",
        name = "Еврейская шляпа",
        model = 2216,

        premium = true,
    },

    cap1 = {
        slot = "head",
        name = "Военная шляпа",
        model = 2215,

        level = 8,
        soft_cost = 100000,
    },

    butterfly1 = {
        slot = "neck",
        name = "Бабочка серая",
        model = 2212,

        level = 6,
        soft_cost = 75000,
    },

    chainp1 = {
        slot = "belt",
        name = "Тройная цепь",
        model = 2223,

        level = 10,
        soft_cost = 150000,
    },

    coffer = {
        slot = "back",
        name = "Футляр гитары",
        model = 2342,

        level = 8,
        soft_cost = 120000,
    },

    glasses1 = {
        slot = "face",
        name = "Очки",
        model = 2353,

        level = 12,
        soft_cost = 170000,
    },

    handbag = {
        slot = "belt",
        name = "Женская сумка (бежевая)",
        model = 2429,

        level = 6,
        soft_cost = 75000,
    },

    handbag_blue = {
        slot = "belt",
        name = "Женская сумка (голубая)",
        model = 2438,

        level = 8,
        soft_cost = 90000,
    },

    handbag_gr = {
        slot = "belt",
        name = "Женская сумка (зеленая)",
        model = 2683,

        level = 10,
        soft_cost = 100000,
    },

    mask_blue = {
        slot = "face",
        name = "Респиратор голубой",
        model = 2861,

        level = 18,
        soft_cost = 450000,
    },

    scarf_bl = {
        slot = "neck",
        name = "Голубой шарф",
        model = 2867,

        level = 12,
        soft_cost = 180000,
    },

    scarf_g = {
        slot = "neck",
        name = "Зеленый шарф",
        model = 2880,

        level = 14,
        soft_cost = 200000,
    },

    scarf_y = {
        slot = "neck",
        name = "Желтый шафр",
        model = 2881,

        level = 12,
        soft_cost = 190000,
    },

    scarf_deserted_r = {
        slot = "neck",
        name = "Красный пустынный\nшарф",
        model = 1572,

        level = 12,
        soft_cost = 110000,
        time_new = 1578603600, --10 января 2020 00:00
        time_start = "1 января 2020 23:59",
    },

    scarf_deserted_y = {
        slot = "neck",
        name = "Желтый пустынный\nшарф",
        model = 1558,

        level = 12,
        soft_cost = 110000,
        time_new = 1579467601, --20 января 2020 00:00
        time_start = "15 января 2020 00:00",
    },

    tie_y = {
        slot = "neck",
        name = "Желтый галстук",
        model = 741,

        level = 16,
        soft_cost = 220000,
    },

    wreath = {
        slot = "head",
        name = "Венок",
        model = 753,

        level = 16,
        soft_cost = 300000,
    },

    backpack = {
        slot = "back",
        name = "Рюкзак",
        model = 955,

        hidden = true,
    },

    baff = {
        slot = "face",
        name = "Маскировочный платок",
        model = 956,

        level = 2,
        hard_cost = 49,
    },

    banana = {
        slot = "belt",
        name = "Потайной карман Томми",
        model = 1775,

        level = 2,
        hard_cost = 119,
    },

    bananaS  = {
        slot = "belt",
        name = "Потайной карман Суприм",
        model = 1977,

        level = 2,
        hard_cost = 149,
    },

    butterfly2 = {
        slot = "neck",
        name = "Бабочка зеленая",
        model = 2213,

        level = 2,
        hard_cost = 39,
    },

    butterfly3 = {
        slot = "neck",
        name = "Бабочка красная",
        model = 2214,

        level = 2,
        hard_cost = 59,
    },

    cap6 = {
        slot = "head",
        name = "Джазовая шляпа",
        model = 2220,

        level = 2,
        hard_cost = 139,
    },

    cap3 = {
        slot = "head",
        name = "Женская шляпа",
        model = 2217,

        level = 2,
        hard_cost = 89,
    },

    cap4 = {
        slot = "head",
        name = "Шляпа лепрекона",
        model = 2218,

        level = 2,
        hard_cost = 299,
    },

    cap5 = {
        slot = "head",
        name = "Шляпа ведьмы",
        model = 2219,

        level = 2,
        hard_cost = 249,
    },

    chain2 = {
        slot = "neck",
        name = "Медальон",
        model = 2222,

        level = 2,
        hard_cost = 179,
    },

    horse = {
        slot = "head",
        name = "Маска Коня",
        model = 2814,

        block_slots = { face = true },

        level = 2,
        hard_cost = 599,
    },

    glasses2 = {
        slot = "face",
        name = "Круглые очки",
        model = 2354,

        level = 2,
        hard_cost = 69,
    },

    glasses3 = {
        slot = "face",
        name = "Тактические очки",
        model = 2355,

        level = 2,
        hard_cost = 279,
    },

    guitar1 = {
        slot = "back",
        name = "Электро гитара",
        model = 2420,

        level = 2,
        hard_cost = 119,
    },

    guitar2 = {
        slot = "back",
        name = "Золотая электро гитара",
        model = 2425,

        level = 2,
        hard_cost = 219,
    },

    guitar3 = {
        slot = "back",
        name = "Рок-гитара",
        model = 2427,

        level = 2,
        hard_cost = 319,
    },

    handbag_gr_bl = {
        slot = "belt",
        name = "Женская сумка (черная)",
        model = 2702,

        level = 2,
        hard_cost = 49,
    },

    handbag_grey = {
        slot = "belt",
        name = "Женская сумка (серая)",
        model = 2703,

        level = 2,
        hard_cost = 39,
    },

    handbag_red = {
        slot = "belt",
        name = "Женская сумка (красная)",
        model = 2767,

        level = 2,
        hard_cost = 69,
    },

    helmet = {
        slot = "head",
        name = "Каска под пиво",
        model = 2766,

        level = 2,
        hard_cost = 189,
    },

    katana = {
        slot = "back",
        name = "Катана",
        model = 2821,

        level = 2,
        hard_cost = 459,
    },

    mask2 = {
        slot = "face",
        name = "Противогаз",
        model = 2823,

        level = 2,
        hard_cost = 259,
    },

    mask_saw = {
        slot = "face",
        name = "Маска клоуна",
        model = 2837,

        level = 2,
        hard_cost = 289,
    },

    mask_v = {
        slot = "face",
        name = "Маска Гая Фокса",
        model = 2839,

        level = 2,
        hard_cost = 439,
    },

    mask_mick = {
        slot = "face",
        name = "Маска Мика Томпсона",
        model = 1462,

        level = 12,
        soft_cost = 200000,
        time_new = 1578603600, --10 января 2020 00:00
        time_start = "1 января 2020 23:59",
    },

    mask_grey = {
        slot = "face",
        name = "Респиратор черный",
        model = 2856,

        level = 2,
        hard_cost = 369,
    },

    mask_red = {
        slot = "face",
        name = "Респиратор красный",
        model = 2857,

        level = 2,
        hard_cost = 279,
    },

    mask_gold = {
        slot = "face",
        name = "Золотая маска",
        model = 2858,

        level = 2,
        hard_cost = 159,
    },

    mask_3 = {
        slot = "face",
        name = "Красная маска",
        model = 2859,

        level = 2,
        hard_cost = 129,
    },

    scarf = {
        slot = "neck",
        name = "Красный шарф",
        model = 2860,

        level = 2,
        hard_cost = 69,
    },

    scarf_b = {
        slot = "neck",
        name = "Черный шарф",
        model = 2866,

        level = 2,
        hard_cost = 139,
    },

    scream = {
        slot = "face",
        name = "Маска крика",
        model = 638,

        block_slots = { head = true },

        level = 2,
        hard_cost = 339,
    },

    scuba = {
        slot = "back",
        name = "Баллоны",
        model = 640,

        level = 2,
        hard_cost = 379,
    },

    station = {
        slot = "back",
        name = "Радиостанция",
        model = 948,

        level = 2,
        hard_cost = 399,
    },

    tie_red = {
        slot = "neck",
        name = "Красный галстук",
        model = 637,

        level = 2,
        hard_cost = 189,
    },

    tie_gr = {
        slot = "neck",
        name = "Серый галстук",
        model = 639,

        level = 2,
        hard_cost = 259,
    },

    wings_2 = {
        slot = "back",
        name = "Черные крылья",
        model = 743,

        level = 2,
        hard_cost = 589,
    },

    cap = {
        slot = "head",
        name = "Кепка UFC",
        model = 2647,

        hidden = true,
    },

    helmet_p = {
        slot = "head",
        name = "Каска Королевской Битвы",
        model = 2769,

        block_slots = { face = true },

        hidden = true,
    },

    police_siren = {
        slot = "head",
        name = "Синее ведёрко",
        model = 1455,

        block_slots = { face = true },

        hidden = true,
    },

    pumpkin = {
        slot = "face",
        name = "Маска “Тыква”",
        model = 1349,

        block_slots = { face = true },

        hidden = true,
    },

    nightmare = {
        slot = "face",
        name = "Маска “Кошмар”",
        model = 1429,

        block_slots = { face = true },

        hidden = true,
    },

    hell_wings = {
        slot = "back",
        name = "Адские крылья",
        model = 1347,

        hidden = true,
    },

    scythe = {
        slot = "back",
        name = "Коса смерти",
        model = 1372,

        hidden = true,
    },

    helmet_avg = {
        slot = "head",
        name = "Шлем AVG",
        model = 1265,

        level = 2,
        soft_cost = 130000,
        time_new = 2075378900,
    },

    helmet_black = {
        slot = "head",
        name = "Шлем чёрный",
        model = 1233,

        level = 2,
        soft_cost = 100000,
        time_new = 2075378900,
    },

    m2_asce11 = {
        slot = "neck",
        name = "Молот Тора",
        model = 2670,

        hard_cost = 49,
        hidden = true,
    },

    m2_asce19 = {
        slot = "face",
        name = "Маска череп",
        model = 1415,

        hard_cost = 149,
        hidden = true,
    },

    cylinder_hat = {
        slot = "head",
        name = "Цилиндр",
        model = 1574,

        level = 2,
        soft_cost = 150000,
        time_new = 1577394000,
    },

    scarf_deserted_g = { --m2_asce05
        slot = "neck",
        name = "Зеленый пустынный\nшарф",
        model = 1733,

        level = 2,
        soft_cost = 120000,
        time_new = 1577825940, --31 декабря 2019 23:59
    },

    mask_scorp = {
        slot = "face",
        name = "Маска Скорпиона",
        model = 1549,

        hard_cost = 200,
        hidden = true,
    },

    m2_asce22 = {
        slot = "face",
        name = "Маска Watch",
        model = 1343,

        hard_cost = 99,
        hidden = true,
    },

    m2_asce07 = {
        slot = "head",
        name = "Жиганка",
        model = 1777,

        hard_cost = 69,
        hidden = true,
    },

    m2_asce06 = {
        slot = "head",
        name = "Немецкий шлем",
        model = 1773,

        level = 2,
        soft_cost = 90000,
        time_new = 1589414340, -- 13 мая 23:59
        time_start = "7 мая 2020 00:00",
    },

    m2_asce17 = {
        slot = "head",
        name = "Шлем с рогами",
        model = 1436,

        hard_cost = 99,
        hidden = true,
    },

    deer_mask = {
        slot = "head",
        name = "Маска “Под Оленя”",
        model = 939,

        block_slots = { face = true },

        hidden = true,
    },

    beard_santa = {
        slot = "face",
        name = "Борода Мороза",
        model = 911,

        hidden = true,
    },

    new_year_hat = {
        slot = "head",
        name = "Новогодняя Шапка",
        model = 912,

        hidden = true,
    },

    new_year_scarf = {
        slot = "neck",
        name = "Новогодний Шарф",
        model = 942,

        hidden = true,
    },

    scarf_deserted_w = { --m2_asce23
        slot = "neck",
        name = "Белый пустынный\nшарф",
        model = 1344,

        level = 2,
        soft_cost = 130000,
        time_new = 1577825940, --31 декабря 2019 23:59
    },

    pendant_1 = { --m2_asce09
        slot = "neck",
        name = "Кулон",
        model = 2672,

        level = 2,
        soft_cost = 120000,
        time_new = 1577825940, --31 декабря 2019 23:59
    },

    diamond_bag = {
        slot = "belt",
        name = "Сумка с бриллиантом",
        model = 1337,

        level = 2,
        wedded = true,
        hidden = true,
    },

    diamond_hope = {
        slot = "neck",
        name = "Алмаз хоуп",
        model = 1338,

        level = 2,
        wedded = true,
        hidden = true,
    },

    panam_hat = {
        slot = "head",
        name = "Шляпа Panam Hat",
        model = 1365,

        level = 2,
        wedded = true,
        hidden = true,
    },

    wood_black_glasses = {
        slot = "face",
        name = "Очки Wood Black",
        model = 1339,

        level = 2,
        wedded = true,
        hidden = true,
    },

    m2_asce20 = {
        slot = "belt",
        name = "Меч",
        model = 1409,

        level = 2,
        soft_cost = 210000,
        time_new = 1585170000, --Tue, 28 Mar 2020 00:00
        time_start = "19 марта 2020 00:00",
    },

    m2_asce21 = {
        slot = "belt",
        name = "Мечи",
        model = 1369,

        hard_cost = 449,
        hidden = true,
    },

    m2_asce01 = {
        slot = "back",
        name = "Кориченвый кожаный\nрюкзак",
        model = 1441,

        level = 2,
        soft_cost = 100000,
        time_new = 1585170000, --Tue, 28 Mar 2020 00:00
        time_start = "19 марта 2020 00:00",
    },

    m2_asce02 = {
        slot = "back",
        name = "Черный кожаный\nрюкзак",
        model = 1449,

        level = 2,
        soft_cost = 130000,
        time_new = 1584565140,
        time_start = "12 марта 2020 00:00",
    },

    m2_asce03 = {
        slot = "back",
        name = "Оранжевый кожаный\nрюкзак",
        model = 1450,

        level = 2,
        soft_cost = 125000,
        time_new = 1585871945,
        time_start = "26 марта 2020 00:00",
    },

    m3_acse14 = {
        slot = "head",
        name = "Ковбойская шляпа",
        model = 2476,

        level = 2,
        soft_cost = 190000,
        time_new = 1586379600,
        time_start = "2 апреля 2020 00:00",
    },

    m3_acse11 = {
        slot = "back",
        name = "Наплечник черный",
        model = 2041,

        level = 2,
        soft_cost = 190000,
        time_new = 1588204740,
        time_start = "23 апреля 2020 00:00",
    },

    m3_acse03 = {
        slot = "face",
        name = "Платок с черепом",
        model = 964,

        level = 2,
        soft_cost = 119000,
        time_new = 1588809540, -- 6 may 2020 23:59
        time_start = "30 апреля 2020 00:00",
    },

    m3_acse10 = {
        slot = "face",
        name = "Маска Джейсона",
        model = 2040,

        hidden = true,
    },

    m3_acse15 = {
        slot = "head",
        name = "Ковбойская шляпа\nкоричневая",
        model = 2358,

        level = 2,
        soft_cost = 189000,
        time_new = 1587599940,
        time_start = "16 апреля 2020 00:00",
    },

    m3_acse02 = {
        slot = "back",
        name = "Наплечник золотой",
        model = 944,

        hidden = true,
    },

    m3_acse04 = {
        slot = "back",
        name = "Рюкзак\nLouis Vuitton",
        model = 1348,

        level = 2,
        soft_cost = 149000,
        time_new = 1587599940,
        time_start = "16 апреля 2020 00:00",
    },

    m3_acse17 = {
        slot = "head",
        name = "Кепка Red Bull",
        model = 2464,

        hidden = true,
    },

    m3_acse18 = {
        slot = "head",
        name = "Кепка Шумахера",
        model = 2465,

        hidden = true,
    },

    m3_acse19 = {
        slot = "head",
        name = "Шлем Red Bull",
        model = 2466,

        hidden = true,
    },

    m3_acse20 = {
        slot = "head",
        name = "Шлем Petronas",
        model = 2468,

        hidden = true,
    },

    m3_acse05 = {
        slot = "face",
        name = "Маска доктора",
        model = 1362,

        hidden = true,
    },

    m3_acse06 = {
        slot = "head",
        name = "Кожаная фуражка",
        model = 1431,

        level = 2,
        soft_cost = 149000,
        time_new = 1587070800,
        time_start = "9 апреля 2020 00:00",
    },

    m3_acse07 = {
        slot = "neck",
        name = "Серебряная цепь",
        model = 1685,

        hidden = true,
    },

    m2_asce12 = {
        slot = "back",
        name = "Бронежилет суприм",
        model = 2042,

        hard_cost = 119,
        hidden = true,
    },

    m3_acse09 = {
        slot = "face",
        name = "Маска Бейна",
        model = 2039,

        hidden = true
    },

    m3_acse01 = {
        slot = "head",
        name = "Сомбреро",
        model = 935,

        hidden = true
    },

    m3_acse08 = {
        slot = "neck",
        name = "Золотая цепь",
        model = 2038,

        level = 2,
        soft_cost = 139000,
        time_new = 1590008340,
        time_start = "14 мая 2020 00:00",
    },

    m3_acse13 = {
        slot = "belt",
        name = "Сумка\nLouis Vuitton",
        model = 2043,

        level = 2,
        soft_cost = 129000,
        time_new = 1590267600,
        time_start = "21 мая 2020 00:00",
    },

    m3_acse16 = {
        slot = "neck",
        name = "Шипастый ошейник",
        model = 2359,

        level = 2,
        soft_cost = 129000,
        time_new = 	1590267600,
        time_start = "21 мая 2020 00:00",
    },

    m2_asce012 = {
        slot = "head",
        name = "Треуголка",
        model = 2671,

        hard_cost = 170,
        hidden = true,
    },

    m2_asce08 = {
        slot = "belt",
        name = "Кобура",
        model = 2062,

        hard_cost = 190,
        hidden = true,
    },

    m3_acse32 = {
        slot = "head",
        name = "Военная каска",
        model = 760,

        hard_cost = 190,
        hidden = true,
    },

    m3_acse33 = {
        slot = "head",
        name = "Шлем пилота",
        model = 761,

        hard_cost = 190,
        hidden = true,
    },

    m3_acse34 = {
        slot = "belt",
        name = "Пулеметная лента",
        model = 762,

        hard_cost = 190,
        hidden = true,
    },

    m3_acse23 = {
        slot = "belt",
        name = "Армейский подсумок",
        model = 763,

        hard_cost = 190,
        hidden = true,
    },

    m3_acse24 = {
        slot = "head",
        name = "Балаклава специальная",
        model = 764,

        soft_cost = 190,
        hidden = true,
    },

    m3_acse25 = {
        slot = "head",
        name = "Шлем апокалипсис",
        model = 765,

        soft_cost = 190,
        hidden = true,
    },

    m3_acse26 = {
        slot = "face",
        name = "Кибер очки",
        model = 766,

        soft_cost = 190,
        hidden = true,
    },

    m3_acse27 = {
        slot = "face",
        name = "Маска PayDay",
        model = 767,

        soft_cost = 190,
        hidden = true,
    },

    m3_acse28 = {
        slot = "face",
        name = "Маска Судная ночь",
        model = 768,

        soft_cost = 190,
        hidden = true,
    },

    m3_acse29 = {
        slot = "head",
        name = "Шлем Хищник",
        model = 769,

        soft_cost = 190,
        hidden = true,
    },

    m3_acse30 = {
        slot = "face",
        name = "Очки Гогглы",
        model = 770,

        soft_cost = 190,
        hidden = true,
    },

    m3_acse31 = {
        slot = "face",
        name = "Маска череп",
        model = 771,

        soft_cost = 190,
        hidden = true,
    },
}