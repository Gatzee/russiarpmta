loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShVehicleConfig")

enum "eJobShiftAvaialbeStates" 
{
	"JOB_SHIFT_STATE_NEW",
    "JOB_SHIFT_STATE_ENDED",
    "JOB_SHIFT_STATE_AVAILABLE",
}

JOB_DATA = {}

DEFAULT_COMPANY_VEHICLE = "company_default"

SHIFT_DURATION = 5 * 60 * 60                          -- 5 часов
SHIFT_DURATION_PREMIUM = SHIFT_DURATION + 1 * 60 * 60 -- 6 часов
SHIFT_DURATION_APARTMENTS = 24 * 60 * 60              -- 24 часа
SHIFT_DURATION_APARTMENTS_WITH_DEBT = 8 * 60 * 60     -- 8 часов
SHIFT_BONUS_BOOSTER = 1 * 60 * 60                     -- доп время от бустера (1 час)

TAXI_LOCK_TIME = 7 * 24 * 60 * 60

ROMAN_NUMERALS = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X" }

function Player.GetShiftDuration( self )
    local iDuration
    if self:HasAnyApartment( true ) then
        iDuration = self:HasAnyHouseRentalDebt( ) and SHIFT_DURATION_APARTMENTS_WITH_DEBT or SHIFT_DURATION_APARTMENTS
    else
        iDuration = self:IsPremiumActive( ) and SHIFT_DURATION_PREMIUM or SHIFT_DURATION
    end
    
    return iDuration + ( self:IsBoosterActive( BOOSTER_EXTENDED_SHIFT ) and SHIFT_BONUS_BOOSTER or 0 )
end

function GetHintAboutLackLicense( license_type )
    local special_licenses = 
    {
        [ LICENSE_TYPE_AIRPLANE ] = true,
        [ LICENSE_TYPE_HELICOPTER ] = true,
        [ LICENSE_TYPE_BOAT ] = true,
    }
    
    if special_licenses[ license_type ] then
        return string.format( "У тебя нет прав на %s для этой работы!", utf8.lower( LICENSES_DATA[ license_type ].sName ) )
    end

    return string.format( "У тебя нет прав категории \"%s\" для этой работы!", LICENSES_DATA[ license_type ].sName )
end