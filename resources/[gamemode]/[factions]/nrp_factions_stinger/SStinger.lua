loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SVehicle" )
Extend( "SPlayer" )

STINGERS = { }
STINGERS_TIMERS = { }

function OnCreateStingerRequest_handler( x, y, z, rx, ry, rz )
	local vehicle = source.vehicle

	if not FACTION_RIGHTS.STINGER[ source:GetFaction( ) ] then return end
	if not FACTION_RIGHTS.STINGER[ vehicle:GetFaction() ] then return end
	if not source:IsOnFactionDuty() then return end

	if isElement( STINGERS[ source ] ) then destroyElement( STINGERS[ source ] ) end
	if isTimer( STINGERS_TIMERS[ source ] ) then killTimer( STINGERS_TIMERS[ source ] ) end

	STINGERS[ source ] = createObject( STINGER_OBJECT_ID, x, y, z, rx, ry, rz )
	STINGERS_TIMERS[ source ] = setTimer( 
		function( object, player ) 
			if isElement( object ) then 
				destroyElement( object ) 
			end
			STINGERS_TIMERS[ player ] = nil
		end, 
	STINGER_DURATION, 1, STINGERS[ source ], source )

	triggerClientEvent( "OnStingerCreate", source, STINGERS[ source ] )

	removeEventHandler( "onPlayerQuit", source, onPlayerLeave_handler )
	addEventHandler( "onPlayerQuit", source, onPlayerLeave_handler )
end
addEvent( "OnCreateStingerRequest", true )
addEventHandler( "OnCreateStingerRequest", root, OnCreateStingerRequest_handler )

function onPlayerLeave_handler( )
	if isElement( STINGERS[ source ] ) then destroyElement( STINGERS[ source ] ) end
	if isTimer( STINGERS_TIMERS[ source ] ) then killTimer( STINGERS_TIMERS[ source ] ) end
end