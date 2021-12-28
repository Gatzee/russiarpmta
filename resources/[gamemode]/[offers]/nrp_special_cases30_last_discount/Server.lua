loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

CONST_END_TIME = getTimestampFromString( "23 февраля 2020 23:59" )

function onPlayerCompleteLogin_handler( )
	local timestamp = getRealTime().timestamp
	if timestamp > CONST_END_TIME then return end
	if not source:HasFinishedBasicTutorial( ) then return end

	triggerClientEvent( source, "OnSpecialCases30LastDiscount", resourceRoot )
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerCompleteLogin_handler, true, "high+9999999" )