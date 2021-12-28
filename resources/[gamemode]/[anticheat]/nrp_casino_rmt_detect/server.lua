loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "SPlayer" )

DATA_RELEVANT_TIME_LIMIT = 2 * 60 * 60
NEED_PROFIT_TO_PANIC = 1000000

function onCasinoPlayerWon_handler( won_money, lobby_players )
    local player = source

    local data = player:GetPermanentData( "casino_money_transfer_data" ) or { }
    data[ GetLastGameIndex( data ) ].profit = won_money
    
    local total_profit = 0
    local players_string = ""
    local timestamp = getRealTimestamp()

    for k, v in pairs( data ) do 
        if v.timestamp + DATA_RELEVANT_TIME_LIMIT < timestamp or not v.profit then 
            data[ k ] = nil
        else
            total_profit = total_profit + v.profit
            players_string = players_string .. " " .. v.players_history
        end
    end
    player:SetPermanentData( "casino_money_transfer_data", data )

    if total_profit >= NEED_PROFIT_TO_PANIC then 
        WriteLog( "casino_money_transfer", "[CASINO_MONEY_TRANSFER] Игрок %s, Суммарный доход %s, История лобби %s", player, format_price( total_profit ), players_string )
        
        if SERVER_NUMBER > 100 then
            local debug_casino_game_log = string.format( "[CASINO_MONEY_TRANSFER] Игрок %s, Суммарный доход %s, История лобби %s", player:GetID( ), format_price( total_profit ), players_string )
            outputDebugString( debug_casino_game_log )
            outputConsole( debug_casino_game_log )
        end
    end
end
addEvent( "onCasinoPlayerWon" )
addEventHandler( "onCasinoPlayerWon", root, onCasinoPlayerWon_handler )


function onCasinoPlayersGame_handler( game_id, players, rmt_detect )
    if not rmt_detect then return end

    local game_data = 
    { 
        players_history = ConvertPlayersToString( players ), 
        timestamp = getRealTimestamp(),
    }

	for k, v in pairs( players ) do
        local data = v:GetPermanentData( "casino_money_transfer_data" ) or { }
        table.insert( data,  game_data )

        v:SetPermanentData( "casino_money_transfer_data", data )
	end
end
addEvent( "onCasinoPlayersGame" )
addEventHandler( "onCasinoPlayersGame", root, onCasinoPlayersGame_handler )


function ConvertPlayersToString( players )
    local uids = ""
    for k, v in pairs( players ) do 
        uids = uids .. " " .. v:GetID( )
    end
    
    return "( " .. uids .. " )"
end

function GetLastGameIndex( data )
    local last_game_timestamp = 0
    local last_game_index = 0
    
    for k, v in pairs( data ) do 
        if v.timestamp > last_game_timestamp then 
            last_game_timestamp = v.timestamp
            last_game_index = k
        end
    end

    return last_game_index
end



--------------------------------------------------------------------------------------------------------
-- Тестирование
--------------------------------------------------------------------------------------------------------

if SERVER_NUMBER > 100 then
    addCommandHandler( "resetprofit", function( player )
        for k, v in pairs( getElementsByType( "player" ) ) do
            v:SetPermanentData( "casino_money_transfer_data", nil )
        end
        player:ShowInfo( "Сумма сброшена " )
    end )

    addCommandHandler( "setpanicprofit", function( player, cmd, newvalue )
        if not newvalue or not tonumber( newvalue ) then player:ShowError( "Нужно указать новое кол-во денег\nExample: setpanicprofit 228000" ) return end

        NEED_PROFIT_TO_PANIC = tonumber( newvalue )
        player:ShowInfo( "Логи теперь будут отправлятся если суммарный зароботок будет больше чем: ".. newvalue )
    end )

    addCommandHandler( "setresettime", function( player, cmd, newvalue )
        if not newvalue or tonumber( newvalue ) then player:ShowError( "Нужно указать время сброса данных(в секундах)\nExample: setresettime 7200" ) return end
        
        DATA_RELEVANT_TIME_LIMIT = tonumber( newvalue )
        player:ShowInfo( "Настройка успешно применена" )
    end )
end