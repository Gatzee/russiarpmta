CSV_FILE_PATH = "csv/1.csv"

FILTER_START_DATE = "1.04.2021" -- парсятся только те спешлы, у которых start_date <= FILTER_START_DATE и finish_date > getRealTime().timestamp

-- LOAD_FROM_BACKUP = "backups/20210424_114536.json"

local function ParseSpecialOffers()
    UpdateSpecialOffers(
        UpdateDataInCommonDB
    )
end
addCommandHandler( "parse_special_offers", ParseSpecialOffers )
addCommandHandler( "parse_specials", ParseSpecialOffers )
addCommandHandler( "parse_special", ParseSpecialOffers )