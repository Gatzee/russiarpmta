PAYOUT_METHOD_DONATE = 1
PAYOUT_METHOD_PACK = 2

PAYMENT_SYSTEM_ENUM_CONVERSION = {
    unitpay = 1,
    gamemoney = 2,
}

TRANSACTIONS_CACHE = { }

PAYOUT_METHODS = {
    [ PAYOUT_METHOD_DONATE ] = function( data, player )
		SendElasticGameEvent( data.client_id, "f4r_f4_currency_deposit_success" )

        if isElement( player ) then
            player:GiveDonate( data.sum, "real_payment" )
            triggerClientEvent( player, "onDonatePaymentSuccess", player, data.sum )

            player:ShowSuccess( "Спасибо за покупку!\nВаш счёт успешно пополнен на " .. data.sum .. " р.!" )

            player:SetPermanentData( "donate_total", ( player:GetPermanentData( "donate_total" ) or 0 ) + data.sum )
            player:SetPermanentData( "donate_transactions", ( player:GetPermanentData( "donate_transactions" ) or 0 ) + 1 )
            player:SetPermanentData( "donate_last_date", getRealTime( ).timestamp )
            
            triggerEvent( "onPlayerDonate", root, data.client_id, data.sum, data.transaction_id, 0, true )
            triggerEvent( "onPlayerPayment", root, data.client_id, 0, data.sum, data.transaction_id, 0, nickname, "soft_purchase" )
            return true
        else
            data.client_id:GiveDonate( data.sum, "real_payment" )
            DB:exec( "UPDATE nrp_players SET donate_total=`donate_total`+?, donate_last_date=?, donate_transactions=`donate_transactions`+1 WHERE client_id=?", data.sum, getRealTime( ).timestamp, data.client_id )
            
            triggerEvent( "onPlayerDonate", root, data.client_id, data.sum, data.transaction_id, 0, true )
            triggerEvent( "onPlayerPayment", root, data.client_id, 0, data.sum, data.transaction_id, 0, "OFFLINE", "soft_purchase" )
            return true
        end
    end,

    [ PAYOUT_METHOD_PACK ] = function( data, player )
        local pack_id = data.params.pack_id

        local pack = PACKS[ pack_id ]
        if not pack then
            WriteLog( "payments", "ERR_NO_PACK: %s не смог получить пак %s, номер транзакции %s", data.client_id, pack_id, data.transaction_id )
            return false
        end
        
        if not player and not pack.fn_offline then
            WriteLog( "payments", "OFFLINE: %s не смог получить пак %s, номер транзакции %s", data.client_id, pack_id, data.transaction_id )
            return false
        end

        if player then
            local result = pack:fn( player, 0, data.transaction_id, data.sum )
            player:ShowSuccess( ( "Набор '%s' успешно оплачен. Спасибо за покупку!" ):format( pack.name ) )
            triggerEvent( "onPlayerPackPurchase", player, data.client_id, pack_id, data.sum, data.transaction_id )
            return result
        else
            return pack:fn_offline( data.client_id, 0, data.transaction_id, data.sum )
        end
    end,
}

function onPayment( _, client_id )
    local player = GetPlayerFromClientID( client_id )
    if player then
        StartProcessingPayments( player )
    end
end

function StartProcessingPayments( player )
    local player = isElement( player ) and player or source
    APIDB:queryAsync( function( query )
        if not isElement( player ) then
            dbFree( query )
            return
        end
        local result = query:poll( 0 )
        local finished = { }

        for i, v in pairs( result ) do
            local result = ProcessPayout( v.client_id, tonumber( v.amount ), tonumber( v.id ), fromJSON( v.params ), fromJSON( v.details ), tonumber( PAYMENT_SYSTEM_ENUM_CONVERSION[ v.system ] ) )
            if result then
                table.insert( finished, v.id )
            end
        end
    
        if #finished > 0 then
            APIDB:exec( "UPDATE TransactionsNew SET `status`=? WHERE id IN (??)", "delivered", table.concat( finished, ", " ) )
        end
    end, { }, "SELECT * FROM TransactionsNew WHERE client_id=? AND game_server=? AND status=?", player:GetClientID( ), SERVER_NUMBER, "paid" )
end
addEventHandler( "onPlayerReadyToPlay", root, StartProcessingPayments )

function onResourceStart_handler( )
    setTimer( function( )
        iprint( "Starting processing transactions..." )
        for i, v in pairs( GetPlayersInGame( ) ) do
            StartProcessingPayments( v )
        end
    end, 2000, 1 )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function ProcessPayout( client_id, sum, transaction_id, params, details, payment_system )
    if TRANSACTIONS_CACHE[ transaction_id ] then
		WriteLog( "donate", "TRANSACTION_DUPLICATE: Ошибка принятия доната %s р., client_id: %s, transaction_id: %s", tostring( sum ), tostring( client_id ), tostring( transaction_id ) )
		return true
	end

    local data = {
        client_id = client_id,
        sum = sum,
        transaction_id = transaction_id,
        params = params,
        details = details,
    }

    local payment_method = ( params.pack_id or 0 ) == 0 and PAYOUT_METHOD_DONATE or PAYOUT_METHOD_PACK
    iprint( "PAYMENT METHOD", payment_method, params.pack_id, params.pack_id or 0, ( params.pack_id or 0 ) == 0, params )
    local purch_type =
        payment_method == PAYOUT_METHOD_DONATE and "hard" or
        payment_method == PAYOUT_METHOD_PACK and ( params.pack_id >= 10000 and "premium" or "pack" )
    
    if PAYOUT_METHODS[ payment_method ] then
        local result = PAYOUT_METHODS[ payment_method ]( data, GetPlayerFromClientID( client_id ) )
        if result then
            TRANSACTIONS_CACHE[ data.transaction_id ] = true
            WriteLog( "payments", "[%s] платеж %s р., client_id: %s, purch_type: %s", transaction_id, sum, client_id, purch_type )
            SendElasticGameEvent( client_id, "payment", {
                money            = tonumber( sum ),
                gross            = tonumber( details.sum_recieved ),
                currency         = tostring( details.currency ),
                money_orig       = tostring( details.sum_original ),
                operator_type    = tostring( details.payment_method ) .. "_" .. tostring( details.payment_method_operator ),
                transaction_id   = tonumber( transaction_id ),
                purch_type       = tostring( purch_type ),
                purchase_source  = tostring( params.source or "game" ),
                payment_system   = tonumber( payment_system ),
                is_first_payment = not not details.is_first_payment,
            } )
        end
        return result
    end
end

if SERVER_NUMBER > 100 then
    addCommandHandler( "make_payment_pack", function ( player, cmd, pack_id, sum )
        PAYOUT_METHODS[ PAYOUT_METHOD_PACK ]( {
            params = {
                pack_id = tonumber( pack_id ) or 0,
            },
            client_id = player:GetClientID( ),
            transaction_id = 0,
            sum = tonumber( sum ) or 0,
        }, player )
    end )
end