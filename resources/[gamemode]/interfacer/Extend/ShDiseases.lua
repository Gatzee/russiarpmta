Import( "Globals" )

TREATING_COOLDOWN = 15 * 60
COST_BUY_TREAT = 20000

enum "eDiseases" {
    "DIS_ABSCESS",
    "DIS_ARVI",
    "DIS_FLU",
    "DIS_PSYCHOSIS",
    "DIS_OVEREATING",
    "DIS_INFECTION",
    "DIS_RUBELLA",
    "DIS_GUNSHOT",
    "DIS_FRACTURE",
    "DIS_DRUG_ADDICT",
    "DIS_ALCOHOLISM",
    "DIS_STARVATION",
}

DISEASES_INFO = {
    [ DIS_ABSCESS ] = {
        name = "Абсцесс",
        name_eng = "abscess",
        note = "Постарайтесь избегать переохлаждения и по возможности ночуйте дома",
        debuffs = {
            [ 1 ] = {
                max_health = 100,
                max_calories = 90,
            },
            [ 2 ] = {
                max_health = 90,
                max_calories = 75,
            },
            [ 3 ] = {
                max_health = 80,
                max_calories = 60,
            },
        },
    },
    [ DIS_ARVI ] = {
        name = "ОРВИ",
        name_eng = "orvi",
        note = "Постарайтесь избегать переохлаждения и по возможности ночуйте дома",
        debuffs = {
            [ 1 ] = {
                max_health = 80,
                max_calories = 80,
                max_stamina = 80,
            },
            [ 2 ] = {
                max_health = 75,
                max_calories = 75,
                max_stamina = 80,
            },
            [ 3 ] = {
                max_health = 70,
                max_calories = 60,
                max_stamina = 80,
            },
        },
    },
    [ DIS_FLU ] = {
        name = "Грипп",
        name_eng = "flu",
        note = "Постарайтесь избегать переохлаждения и по возможности ночуйте дома",
        debuffs = {
            [ 1 ] = {
                max_health = 80,
                max_calories = 80,
                max_stamina = 80,
            },
            [ 2 ] = {
                max_health = 75,
                max_calories = 75,
                max_stamina = 80,
            },
            [ 3 ] = {
                max_health = 70,
                max_calories = 60,
                max_stamina = 80,
            },
        },
    },
    [ DIS_PSYCHOSIS ] = {
        name = "Психоз",
        name_eng = "psychosis",
        note = "Воздержитесь от проявлений агрессии",
        debuffs = {
            [ 1 ] = {
                max_health = 100,
                max_calories = 90,
            },
            [ 2 ] = {
                max_health = 90,
                max_calories = 75,
            },
            [ 3 ] = {
                max_health = 80,
                max_calories = 60,
            },
        },
    },
    [ DIS_OVEREATING ] = {
        name = "Переедание",
        name_eng = "binge_eating",
        note = "Воздержитесь от переедания",
        debuffs = {
            [ 1 ] = {
                max_health = 90,
                max_calories = 80,
                max_stamina = 80,
            },
            [ 2 ] = {
                max_health = 75,
                max_calories = 70,
                max_stamina = 80,
            },
            [ 3 ] = {
                max_health = 60,
                max_calories = 50,
                max_stamina = 70,
            },
        },
    },
    [ DIS_INFECTION ] = {
        name = "Инфекционные заболевания",
        name_eng = "infectious",
        note = "Постарайтесь избегать переохлаждения и по возможности ночуйте дома",
        debuffs = {
            [ 1 ] = {
                max_health = 90,
                max_calories = 90,
                max_stamina = 80,
            },
            [ 2 ] = {
                max_health = 75,
                max_calories = 75,
                max_stamina = 80,
            },
            [ 3 ] = {
                max_health = 60,
                max_calories = 60,
                max_stamina = 80,
            },
        },
    },
    [ DIS_RUBELLA ] = {
        name = "Краснуха",
        name_eng = "rubella",
        note = "Постарайтесь избегать переохлаждения и по возможности ночуйте дома",
        debuffs = {
            [ 1 ] = {
                max_health = 90,
                max_calories = 90,
            },
            [ 2 ] = {
                max_health = 75,
                max_calories = 75,
            },
            [ 3 ] = {
                max_health = 60,
                max_calories = 60,
            },
        },
    },
    [ DIS_GUNSHOT ] = {
        name = "Огнестрельное ранение",
        name_eng = "gunshot",
        note = "Постарайтесь избегать вооруженных конфликтов",
        debuffs = {
            [ 1 ] = {
                max_health = 60,
                max_calories = 90,
                max_stamina = 80,
            },
            [ 2 ] = {
                max_health = 55,
                max_calories = 75,
                max_stamina = 70,
            },
            [ 3 ] = {
                max_health = 50,
                max_calories = 60,
                max_stamina = 60,
            },
        },
    },
    [ DIS_FRACTURE ] = {
        name = "Перелом",
        name_eng = "fracture",
        note = "Проявляйте осторожность",
        debuffs = {
            [ 1 ] = {
                max_health = 70,
                max_calories = 90,
                max_stamina = 70,
            },
            [ 2 ] = {
                max_health = 60,
                max_calories = 75,
                max_stamina = 65,
            },
            [ 3 ] = {
                max_health = 50,
                max_calories = 60,
                max_stamina = 60,
            },
        },
    },
    [ DIS_DRUG_ADDICT ] = {
        name = "Наркозависимость",
        name_eng = "drug",
        note = "Воздержитесь от чрезмерного употребления наркотиков",
        debuffs = {
            [ 1 ] = {
                max_health = 90,
                max_calories = 80,
            },
            [ 2 ] = {
                max_health = 75,
                max_calories = 70,
            },
            [ 3 ] = {
                max_health = 60,
                max_calories = 60,
            },
        },
    },
    [ DIS_ALCOHOLISM ] = {
        name = "Алкоголизм",
        name_eng = "alcoholism",
        note = "Воздержитесь от чрезмерного употребления алкоголя",
        debuffs = {
            [ 1 ] = {
                max_health = 70,
                max_calories = 75,
            },
            [ 2 ] = {
                max_health = 65,
                max_calories = 70,
            },
            [ 3 ] = {
                max_health = 55,
                max_calories = 60,
            },
        },
    },
    [ DIS_STARVATION ] = {
        name = "Голодание",
        name_eng = "starvation",
        note = "Старайтесь потреблять пищу вовремя",
        debuffs = {
            [ 1 ] = {
                max_health = 90,
                max_calories = 80,
                max_stamina = 60,
            },
            [ 2 ] = {
                max_health = 75,
                max_calories = 70,
                max_stamina = 55,
            },
            [ 3 ] = {
                max_health = 60,
                max_calories = 50,
                max_stamina = 50,
            },
        },
    },
}