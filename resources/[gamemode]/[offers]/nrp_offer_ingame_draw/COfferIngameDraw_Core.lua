Extend( "ib" )
Extend( "CPlayer" )

ibUseRealFonts( true )

function onClientShowOfferIngameDraw_handler( data, is_show_first )
    if data then OFFER_DATA = data end

    if is_show_first and not INIT_OFFER then
        CHECK_ANY_WINDOW_TMR = setTimer( function( )
            if ibIsAnyWindowActive( ) then return end
            killTimer( CHECK_ANY_WINDOW_TMR )

            localPlayer:setData( "offer_ingame_draw", OFFER_END_DATE, false )
            if data.remaining_time > 0 then
                onClientStartIngameDraw_handler( data.remaining_time )
            elseif data.remaining_time == 0 then
                onClientPlayerTakeTicket_handler( )
            end
            
            if data.remaining_time == 0 and not data.contact then
                ShowIngameDrawContactsUI( true, OFFER_DATA )
            elseif data.is_offer_active then
                ShowIngameDrawMainUI( true, OFFER_DATA )
            end
        end, 1000, 0 )
    else    
        ShowIngameDrawMainUI( true, OFFER_DATA )
    end
end
addEvent( "onClientShowOfferIngameDraw", true )
addEventHandler( "onClientShowOfferIngameDraw", resourceRoot, onClientShowOfferIngameDraw_handler )

function onClientPlayerTakeTicket_handler( ticket_code )
    if ticket_code then OFFER_DATA.ticket_code = ticket_code end

    triggerEvent( "onClientShowIngameDrawOfferInfo", root, OFFER_NAME, 
    {
        ticket_code = OFFER_DATA.ticket_code,
        task_name = "Розыгрыш призов",
        time_left = -1,
    } )
end
addEvent( "onClientPlayerTakeTicket", true )
addEventHandler( "onClientPlayerTakeTicket", resourceRoot, onClientPlayerTakeTicket_handler )

function onClientStartIngameDraw_handler( remaining_time )
    OFFER_DATA.remaining_time = remaining_time
    
    setTimer( function()
        triggerServerEvent( "onServerPlayerTryGetTicket", resourceRoot )
    end, math.max( 1050, remaining_time * 1000 + 1000), 1 )
        
    triggerEvent( "onClientShowIngameDrawOfferInfo", root, OFFER_NAME, 
    { 
        time_left = remaining_time,
        task_name = "Отыграть " .. CONST_INGAME_TIME_HOURS .. " часов",
        task_desc = "Розыгрыш призов",
    } )
end
addEvent( "onClientStartIngameDraw", true )
addEventHandler( "onClientStartIngameDraw", resourceRoot, onClientStartIngameDraw_handler )