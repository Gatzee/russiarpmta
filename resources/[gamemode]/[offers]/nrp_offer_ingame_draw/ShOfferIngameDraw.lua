loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )

OFFER_NAME = "summer_draw_21"

OFFER_DURATION_DAYS = 21
OFFER_DURATION_SEC = OFFER_DURATION_DAYS * 86400

OFFER_START_DATE = getTimestampFromString( "10 июня 2021 00:00" )
OFFER_END_DATE   = OFFER_START_DATE + OFFER_DURATION_SEC

OFFER_END_SUMMING_RESULT_DATE = OFFER_END_DATE + 3 * 86400

CONST_INGAME_TIME_HOURS = 30
CONST_INGAME_TIME_SEC   = CONST_INGAME_TIME_HOURS * 3600

function IsOfferActive()
    local timestamp = getRealTimestamp()
    return timestamp > OFFER_START_DATE and timestamp < OFFER_END_DATE
end

function IsOfferSummingResults()
    local timestamp = getRealTimestamp()
    return timestamp > OFFER_START_DATE and timestamp < OFFER_END_SUMMING_RESULT_DATE
end

function IsContactDataValid( contact_type, contact_text )
    if not contact_type or not contact_text then return false end

    local contact_patterns =
    {
        [ "email" ]    = { min_len = 12, example = "name@mail.ru", regex = "^[A-Za-z0-9]+@[%a]+%.[%a%d]+$", },
        [ "discord" ]  = { min_len = 5,  example = "Name#0000",    regex = "^.+#%d%d%d%d$",                 },
        [ "vk" ]       = { min_len = 10, example = "vk.com/name",  regex = "^vk.com/[A-Za-z0-9_]+$",        },
        [ "telegram" ] = { min_len = 4,  example = "name",         regex = "^[A-Za-z0-9_]+$",               },
        [ "whatsapp" ] = { min_len = 10, example = "89999999999",  regex = "^%d+$",                         },
    }

    local cur_contact_pattern = contact_patterns[ contact_type ]
    if not cur_contact_pattern then return false end
    
    if utf8.len( contact_text ) > 64 or utf8.len( contact_text ) < cur_contact_pattern.min_len or not string.find( contact_text, cur_contact_pattern.regex ) then
        return false, cur_contact_pattern.example
    end

    return true
end