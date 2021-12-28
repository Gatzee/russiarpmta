loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )

DATA_NAME = "offer_piggy_bank"
MIN_LEVEL = 6
MAX_LEVEL = 10
MIN_CONVERT_VALUE = 139 * 1000

ALLOW_JOBS = {
    [ JOB_CLASS_FARMER ] 		= true,
    [ JOB_CLASS_TAXI_PRIVATE ]  = true,
    [ JOB_CLASS_MECHANIC ] 		= true,
    [ JOB_CLASS_TRASHMAN ] 		= true,
    [ JOB_CLASS_COURIER ] 		= true,
    [ JOB_CLASS_PARK_EMPLOYEE ] = true,
    [ JOB_CLASS_LOADER ] 		= true,
}

DISCOUNTS_BY_LEVEL = {
    [ 6 ] = 0.2,
    [ 7 ] = 0.25,
    [ 8 ] = 0.3,
    [ 9 ] = 0.3,
}

function getPriceOfTax( amount, level )
    local value = 1 - ( DISCOUNTS_BY_LEVEL[ level ] or 0 )
    return math.ceil( ( amount / 1000 ) * value )
end