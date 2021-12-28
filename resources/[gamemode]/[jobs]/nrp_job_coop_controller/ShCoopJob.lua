loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShUtils" )

enum "eJobState" 
{
	"LOBBY_STATE_WAIT_PLAYERS",
	"LOBBY_STATE_START_WORK",
}

enum "eJobSearchState" 
{
	"SEARCH_STATE_START",
    "SEARCH_STATE_WAIT",
    "SEARCH_STATE_CANCEL",
    "SEARCH_STATE_END",
}

JOB_DATA = {}

ROMAN_NUMERALS = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X" }

SHIFT_DURATION = 5 * 60 * 60 -- 5 часов
SHIFT_DURATION_PREMIUM = SHIFT_DURATION + 1 * 60 * 60 -- 6 часов
SHIFT_DURATION_APARTMENTS = 24 * 60 * 60 -- 24 часа
SHIFT_DURATION_APARTMENTS_WITH_DEBT = 8 * 60 * 60 -- 8 часов
SHIFT_CHANGE_TIME = 8 * 60 * 60 -- 8 утра по МСК
SHIFT_BONUS_BOOSTER = 1 * 60 * 60 -- доп время от бустера (1 час)

ORDER_SEARCH_TIME = 10 * 1000 --Время на поиск заказов
ORDER_GIVE_TIME = 15 * 1000 --Время на выдачу реальных заказов

SEARCH_TIMEOUT_TIME = 60

function Player.GetShiftDuration( self )
	if not isElement( self ) then return end

    local iDuration
    if self:HasAnyApartment( true ) then
        iDuration = self:HasAnyHouseRentalDebt( ) and SHIFT_DURATION_APARTMENTS_WITH_DEBT or SHIFT_DURATION_APARTMENTS
    else
        iDuration = self:IsPremiumActive( ) and SHIFT_DURATION_PREMIUM or SHIFT_DURATION
    end

	return iDuration + ( self:IsBoosterActive( BOOSTER_EXTENDED_SHIFT ) and SHIFT_BONUS_BOOSTER or 0 )
end

function GetHintAboutLackLicense( license_type, is_show_player )
    local special_licenses = 
    {
        [ LICENSE_TYPE_AIRPLANE ] = true,
        [ LICENSE_TYPE_HELICOPTER ] = true,
        [ LICENSE_TYPE_BOAT ] = true,
    }

    if special_licenses[ license_type ] then
        return string.format( (is_show_player and "У тебя " or "У игрока") .. "нет прав на %s для этой работы!", utf8.lower( LICENSES_DATA[ license_type ].sName ) )
    end

    return string.format( (is_show_player and "У тебя " or "У игрока") .. "нет прав категории \"%s\" для этой работы!", LICENSES_DATA[ license_type ].sName )
end