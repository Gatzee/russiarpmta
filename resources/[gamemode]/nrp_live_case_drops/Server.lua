loadstring(exports.interfacer:extend("Interfacer"))( )
Extend("SPlayer")

CLEAR_INTERVAL = 30 * 60 * 1000  -- интервал очистки старых дропов

CLEAR_TIMER = nil
DROPS_TO_SHOW = { }

addEvent( "onPlayerRequestLiveCaseDropInfo", true )
addEventHandler( "onPlayerRequestLiveCaseDropInfo", root, function ( )
    local player = client or source
    if DROPS_TO_SHOW[ 1 ] then
        triggerClientEvent( player, "onPlayerReceiveLiveCaseDropInfo", player, DROPS_TO_SHOW[ 1 ] )
    end
end )

function AddDropToLiveCaseStack( case_id, drop_title, player )

    if not isElement( player ) then return end

    local case = {
        case_id    = case_id,
        drop_text  = drop_title,
        owner      = player:GetNickName( )
    }

    DROPS_TO_SHOW[ #DROPS_TO_SHOW + 1 ] = case
    
    if #DROPS_TO_SHOW > 10 then
        table.remove( DROPS_TO_SHOW, 1 )
        -- Перезапускаем таймер очистки, т.к. дроп для очистки уже удалили
        if CLEAR_TIMER then
            CLEAR_TIMER:reset( )
        end
    end

    if not CLEAR_TIMER then
        CLEAR_TIMER = setTimer( function( )
            table.remove( DROPS_TO_SHOW, 1 )
            if #DROPS_TO_SHOW == 0 then
                CLEAR_TIMER:destroy( )
                CLEAR_TIMER = nil
            end
        end, CLEAR_INTERVAL, 0 )
    end
end

--testing
if SERVER_NUMBER > 100 then 
    addCommandHandler( "livedrop", function( player ) 
        triggerEvent( "onPlayerRequestLiveCaseDropInfo", player )
    end )
end