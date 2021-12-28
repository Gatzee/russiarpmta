local current_info
local window_queue = {}

function OnInfoWindowClose_handler()
    if #window_queue == 0 then
        showCursor( false )
        current_info = false
    else
        local data = window_queue[ 1 ]
        table.remove( window_queue, 1 )
        current_info = ibInfo( data )
    end
end

function onInfoWindow_handler( text, title )
    local data = { 
        title = title or eventName == "onErrorWindow" and "ОШИБКА" or "ИНФОРМАЦИЯ",
        text = text, 
        fn = OnInfoWindowClose_handler,
    } 
    
    if current_info then
        table.insert( window_queue, data )
        return
    end

    showCursor( true )
    current_info = ibInfo( data )
end
addEvent( "onErrorWindow", true )
addEventHandler( "onErrorWindow", root, onInfoWindow_handler )

addEvent( "onInformationWindow", true )
addEventHandler( "onInformationWindow", root, onInfoWindow_handler )