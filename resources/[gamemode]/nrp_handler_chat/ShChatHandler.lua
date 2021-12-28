loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShUtils" )

CHAT_FACTION_SHORT_NAMES = {
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

CHAT_FACTIONS_SHORT_LEVEL_NAMES = {
    [ F_ARMY ] = {
        [1] = "Сержант",
        [2] = "Ст. сержант",
        [3] = "Старшина",
        [4] = "Прапорщик",
        [5] = "Ст. прапорщик",
        [6] = "Лейтенант",
        [7] = "Ст. лейтенант",
        [8] = "Капитан",
        [9] = "Майор",
        [10] = "Подполковник",
        [11] = "Полковник",
        [12] = "Ген. армии",
    },

    [ F_POLICE_PPS_NSK ] = {
        [1] = "Сержант",
        [2] = "Ст. сержант",
        [3] = "Старшина",
        [4] = "Прапорщик",
        [5] = "Ст. прапорщик",
        [6] = "Лейтенант",
        [7] = "Ст. лейтенант",
        [8] = "Капитан",
        [9] = "Майор",
        [10] = "Подполковник",
        [11] = "Полковник",
        [12] = "Ген. МВД ППС",
    },

    [ F_POLICE_DPS_NSK ] = {
        [1] = "Сержант",
        [2] = "Ст. сержант",
        [3] = "Старшина",
        [4] = "Прапорщик",
        [5] = "Ст. прапорщик",
        [6] = "Лейтенант",
        [7] = "Ст. лейтенант",
        [8] = "Капитан",
        [9] = "Майор",
        [10] = "Подполковник",
        [11] = "Полковник",
        [12] = "Ген. МВД ДПС",
    },

    [ F_MEDIC ] = {
        [1] = "Санитар",
        [2] = "Фармацевт",
        [3] = "Фельдшер",
        [4] = "Ст. Провизор",
        [5] = "Врач-методист",
        [6] = "Врач-терапевт",
        [7] = "Врач-лаборант",
        [8] = "Врач-специалист",
        [9] = "Врач-психиатр",
        [10] = "Врач-хирург",
        [11] = "Зам. гл. врача",
        [12] = "Гл. врач",
    },

    [ F_GOVERNMENT_NSK ] = {
        [1] = "Волонтер",
        [2] = "Работник Мэрии",
        [3] = "Охранник",
        [4] = "Зам. нач. охраны",
        [5] = "Нач. охраны",
        [6] = "Зам. ген. прокурора",
        [7] = "Ген. прокурор",
        [8] = "Мин. финансов",
        [9] = "Мин. транспорта",
        [10] = "Мин. культуры",
        [11] = "Зам. Мэра",
        [12] = "Мэр",
    },

    [ F_FSIN ] = {
        [1] = "Сержант",
        [2] = "Ст. сержант",
        [3] = "Старшина",
        [4] = "Прапорщик",
        [5] = "Ст. прапорщик",
        [6] = "Лейтенант",
        [7] = "Ст. лейтенант",
        [8] = "Капитан",
        [9] = "Майор",
        [10] = "Подполковник",
        [11] = "Полковник",
        [12] = "Ген. ФСИН",
    },
}

CHAT_FACTIONS_SHORT_LEVEL_NAMES[ F_POLICE_PPS_GORKI ] = CHAT_FACTIONS_SHORT_LEVEL_NAMES[ F_POLICE_PPS_NSK ]
CHAT_FACTIONS_SHORT_LEVEL_NAMES[ F_POLICE_PPS_MSK ] = CHAT_FACTIONS_SHORT_LEVEL_NAMES[ F_POLICE_PPS_NSK ]
CHAT_FACTIONS_SHORT_LEVEL_NAMES[ F_POLICE_DPS_GORKI ] = CHAT_FACTIONS_SHORT_LEVEL_NAMES[ F_POLICE_DPS_NSK ]
CHAT_FACTIONS_SHORT_LEVEL_NAMES[ F_POLICE_DPS_MSK ] = CHAT_FACTIONS_SHORT_LEVEL_NAMES[ F_POLICE_DPS_NSK ]
CHAT_FACTIONS_SHORT_LEVEL_NAMES[ F_GOVERNMENT_GORKI ] = CHAT_FACTIONS_SHORT_LEVEL_NAMES[ F_GOVERNMENT_NSK ]
CHAT_FACTIONS_SHORT_LEVEL_NAMES[ F_GOVERNMENT_MSK ] = CHAT_FACTIONS_SHORT_LEVEL_NAMES[ F_GOVERNMENT_NSK ]
CHAT_FACTIONS_SHORT_LEVEL_NAMES[ F_MEDIC_MSK ] = CHAT_FACTIONS_SHORT_LEVEL_NAMES[ F_MEDIC ]
