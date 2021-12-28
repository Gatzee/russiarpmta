loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SDB" )
Extend( "SPlayerCommon" )

MIN_TIME_NOPAYMENT = 72 * 60 * 60
MIN_TIME_ONEPAYMENT = 48 * 60 * 60

-- Отмечаем что он новый юзер если завершил туториал
function onPlayerFinishTutorialGlobally_handler( )
    local player = source

    player:GetCommonData( { "ready_3days_upd" }, { player }, function( result, player )
        if not isElement( player ) then return end -- Игрок вышел за время запроса
        local ready_3days_upd = result.ready_3days_upd

        -- Если нет тестовой группы - определяем можно ли её подбирать
        if not ready_3days_upd then
            player:SetCommonData( { ready_3days_upd = getRealTime( ).timestamp } )
        end
    end )
end
addEvent( "onPlayerFinishTutorialGlobally" )
addEventHandler( "onPlayerFinishTutorialGlobally", root, onPlayerFinishTutorialGlobally_handler )

function onPlayerCompleteLogin_handler( player )
    local player = isElement( player ) and player or source
    if not player:HasFinishedTutorial( ) then return end

    player:GetCommonData( { "ready_3days_upd", "started_3days", "group_3days" }, { player }, function( result, player )
        if not isElement( player ) then return end -- Игрок вышел за время запроса

        local ready_3days_upd, started_3days, group_3days = result.ready_3days_upd, result.started_3days, result.group_3days

        -- Если готов к распределению в группу
        if ready_3days_upd and not started_3days and not group_3days then
            CommonDB:queryAsync( function( query, player )
                if not isElement( player ) then return end
                local result = query:poll( -1 )

                -- Вообще не заплатили за 72 часа
                if #result <= 0 and getRealTime( ).timestamp - ready_3days_upd >= MIN_TIME_NOPAYMENT then
                    player:SetCommonData( { group_3days = "group_72h" } )
                    triggerEvent( "on3daysGroupLoaded", player, "group_72h", true )

                -- Заплатил 1 раз и прошло 48 часов с этого платежа
                elseif #result == 1 and getRealTime( ).timestamp - result[ 1 ].date >= MIN_TIME_ONEPAYMENT then
                    player:SetCommonData( { group_3days = "group_48h" } )
                    triggerEvent( "on3daysGroupLoaded", player, "group_48h", true )

                end
            end, { player },
            "SELECT date FROM payments WHERE client_id=? LIMIT 1", player:GetClientID( )
        )

        -- Если уже распределен в группу
        elseif started_3days and group_3days then
            triggerEvent( "on3daysGroupLoaded", player, group_3days )

        end
    end )
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )

function onResourceStart_handler( )
    for i, v in pairs( getElementsByType( "player" ) ) do
        if v:IsInGame( ) then
            onPlayerCompleteLogin_handler( v )
        end
    end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )