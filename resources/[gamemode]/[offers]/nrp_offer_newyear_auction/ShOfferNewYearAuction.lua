loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )

OFFER_NAME = "new_year_auction"

OFFER_START_DATE = getTimestampFromString( "05 января 2021 00:00" )
OFFER_END_DATE   = getTimestampFromString( "05 января 2021 23:59" )

COST_DROP_TIMEOUT = 100
CONST_OFFER_TIMEOUT = 60 * 60 * 1

CONST_OUTBID_INTERVAL = 60 * 60 * 1
CONST_OUTBID_MSG_CHECK_TIME = 5 * 60

CONST_MIN_RATE = 3500