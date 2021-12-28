addEvent( "onPlayerOrderRevenge", true )
addEventHandler( "onPlayerOrderRevenge", localPlayer, function ( nickname )
    if not nickname then
        components.orderMenu( false )
    else
        components.orderMenu( true, nickname )
    end
end )

addEvent( "onPlayerGetOrientations", true )
addEventHandler( "onPlayerGetOrientations", localPlayer, function ( data )
    fillOrientationsMenu( data )
end )

addEvent( "onPlayerShowOrderComplete", false )
addEventHandler( "onPlayerShowOrderComplete", localPlayer, function ( data )
    components.resultWindow( true, data.result, data.nickname, data.skin_id )
end )