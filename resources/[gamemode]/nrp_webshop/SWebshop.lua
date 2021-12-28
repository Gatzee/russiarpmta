loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SWebshop" )
Extend( "SDB" )
Extend( "SPlayerCommon" )
Extend( "SPlayerOffline" )

TRANSACTIONS_CACHE = { }
-- transaction.client_id, transaction.amount, transaction.id, transaction.params
function onPackRecieve( client_id, pack_id, transaction_id, profit, ingame, sum )
--function onPackRecieve( client_id, sum, transaction_id, params, details )
    if TRANSACTIONS_CACHE[ transaction ] then
		WriteLog( "shop/error.log", "TRANSACTION_DUPLICATE: Ошибка покупки пака %s, client_id: %s", tostring( pack_id ), tostring( client_id ) )
		return true
    end

    --iprint( "rcv test", client_id, pack_id, transaction_id, profit, ingame, sum )

    local pack = PACKS[ pack_id ]
    if not pack then
        WriteLog( "shop/error.log", "ERR_NO_PACK: %s не смог получить пак %s, номер транзакции %s", client_id, pack_id, transaction_id )
        --iprint( "err2" )
        return false
    end

    local player = GetPlayerFromClientID( client_id )

    if not player and not pack.fn_offline then
        WriteLog( "shop/error.log", "OFFLINE: %s не смог получить пак %s, номер транзакции %s", client_id, pack_id, transaction_id )
        --iprint( "err1" )
        return false
    end

    --iprint( "success" )

    if player then
        local result = pack:fn( player, profit, transaction_id, sum )
        WriteLog( "shop/success.log", "%s оплатил пак %s (#%s), результат: %s, номер транзакции %s ", player, pack.name, pack_id, result, transaction_id )

        player:ShowSuccess( ( "Набор '%s' успешно оплачен. Спасибо за покупку!" ):format( pack.name ) )

        TRANSACTIONS_CACHE[ transaction_id ] = true

        triggerEvent( "onPlayerPackPurchase", player, client_id, pack, sum, transaction_id )
        return true

    else
        local result = pack:fn_offline( client_id, profit, transaction_id, sum )
        WriteLog( "shop/success.log", "%s оплатил пак %s (#%s), результат: %s, номер транзакции %s ", client_id, pack.name, pack_id, result, transaction_id )
        TRANSACTIONS_CACHE[ transaction_id ] = true

    end

    -- Любой платеж
    triggerEvent( "onPlayerPayment", root, client_id, player:GetLevel( ), sum, transaction_id, player:GetUserID( ), player:GetNickName( ), "pack_purchase_id" .. pack_id )
end