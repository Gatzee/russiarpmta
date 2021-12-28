function onGameTimeRecieve_handler( time, weather )
    setTime( unpack( time ) )
    setWeather( weather )
end
addEvent( "onGameTimeRecieve", true )
addEventHandler( "onGameTimeRecieve", root, onGameTimeRecieve_handler )