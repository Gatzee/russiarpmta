-- LOAD_FROM_BACKUP = "cases_info/20210513_132528_backup.json"

NEW_CASES_CSV_FILE_NAMES = { 
	-- [ "case_id" ] = "file_name.csv",
	-- [ "case_id" ] = true,
	bp_season_47  = true,
	bp_season_46  = true,
	bp_season_45  = true,
	bp_season_44  = true,
	bp_season_43  = true,
	vinyl_summer2 = true,

}

NEW_CASES_START_DATE = {
	-- [ "case_id" ] = "2020-01-01 00:00:00",

	bp_season_47  = "2000-01-01 00:00:00",
	bp_season_46  = "2000-01-01 00:00:00",
	bp_season_45  = "2000-01-01 00:00:00",
	bp_season_44  = "2000-01-01 00:00:00",
	bp_season_43  = "2000-01-01 00:00:00",
	vinyl_summer2 = "2000-01-01 00:00:00",
}

NEW_CASES_END_DATE = {
	-- [ "case_id" ] = "2020-01-14 00:00:00",

	bp_season_47  = "2000-01-01 00:00:00",
	bp_season_46  = "2000-01-01 00:00:00",
	bp_season_45  = "2000-01-01 00:00:00",
	bp_season_44  = "2000-01-01 00:00:00",
	bp_season_43  = "2000-01-01 00:00:00",
	vinyl_summer2 = "2000-01-01 00:00:00",
}

CASES_MARKED_AS_NEW = { 
	-- "case_id",
}

CASES_MARKED_AS_HIT = { 
	-- "bronze",
	-- "silver",
}

CASES_POSITIONS = {
	-- [ "case_id" ] = 0,
	bp_season_47  = 0,
	bp_season_46  = 0,
	bp_season_45  = 0,
	bp_season_44  = 0,
	bp_season_43  = 0,
	vinyl_summer2 = 0,
}

CASE_BATTLES = {
	-- { "oldyear", "newyear" },
	-- {"Дворцовый",
	-- "Однокомнатный"},
	-- {"Волчий",
	-- "Медвежий"},
	-- {"Подполье",
	-- "Разведка"},
}

CASES_WITH_FAKE_CHANCES = {
	-- [ "gold_a" ] = true,
	-- [ "gold_b" ] = true,
	-- [ "titan" ] = true,
	-- [ "platinum" ] = true,
}

UpdateCasesInfo( 
	UpdateDataInCommonDB
)