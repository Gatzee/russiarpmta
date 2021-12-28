
PODIUM_BANK = {}

PODIUM_DANCE_DATA = {}

function CreatePodiumBankDatabase()
    DB:createTable( "nrp_podium_bank",
	{
        { Field = "dance_id",    Type = "int(11) unsigned", Null = "NO", Key = "PRI", },
        { Field = "dance_pay",   Type = "text",             Null = "NO", Key = "",    },
    })
    DB:queryAsync( LoadPodiumBank, {}, "SELECT dance_id, dance_pay FROM nrp_podium_bank" )
end

function LoadPodiumBank( qh )
    local result = qh:poll( -1 )
    if #result == 0 then 
        for k, v in pairs( PODIUM_DANCE_GIRLS ) do
            DB:exec( "INSERT IGNORE INTO nrp_podium_bank ( dance_id, dance_pay ) VALUES( ?, ? )", k, 0 )
            PODIUM_BANK[ k ] = { dance_pay = 0 }
        end
    else
        for k, v in pairs( result ) do
            PODIUM_BANK[ v.dance_id ] = { dance_pay = tonumber( v.dance_pay ) }
        end
    end
end

function onServerPlayerWantOpenPodiumDance_handler()
    triggerClientEvent( client, "onClientShowPodiumUI", resourceRoot, true, PODIUM_BANK )
end
addEvent( "onServerPlayerWantOpenPodiumDance", true )
addEventHandler( "onServerPlayerWantOpenPodiumDance", root, onServerPlayerWantOpenPodiumDance_handler )

-- Игрок хочет внести всю сумму
function onServerPlayerWantBuyPodiumDance_handler( dance_id )
    if IsDanceProcess() then return end

    local dance = PODIUM_DANCE_GIRLS[ dance_id ]
    if not dance or not isElement( client ) then return end
    
    local money_value = dance.price - PODIUM_BANK[ dance_id ].dance_pay
    if money_value == 0 then return end

    if client:TakePlayerPrice( money_value, dance.currency, "podium_" .. dance_id ) then
        OnPlayerPayPodiumDance( money_value, dance, dance_id, client )
    else
        client:ShowError( "У Вас недостаточно средств для покупки" )
    end
end
addEvent( "onServerPlayerWantBuyPodiumDance", true )
addEventHandler( "onServerPlayerWantBuyPodiumDance", root, onServerPlayerWantBuyPodiumDance_handler )

-- Игрок хочет внести часть денег
function onServerPlayerWantPayMoney_handler( dance_id, money_value )
    if IsDanceProcess() then return end

    local dance = PODIUM_DANCE_GIRLS[ dance_id ]
    money_value = tonumber( money_value )
    if not dance or not isElement( client ) or not money_value then return end
    if money_value == 0 or dance.price - PODIUM_BANK[ dance_id ].dance_pay < money_value then return end

    if client:TakePlayerPrice( money_value, dance.currency, "podium_" .. dance_id ) then
        OnPlayerPayPodiumDance( money_value, dance, dance_id, client )
    else
        client:ShowError( "У Вас недостаточно средств для оплаты" )
    end
end
addEvent( "onServerPlayerWantPayMoney", true )
addEventHandler( "onServerPlayerWantPayMoney", root, onServerPlayerWantPayMoney_handler )


-- Танец оплачен, запускаем
function StartPodiumDance( dance_id )
    if IsDanceProcess() then 
        client:ShowInfo( "Танец уже идёт, кайфуй" )
        return 
    end

    PODIUM_DANCE_DATA.start_timestamp = getRealTimestamp()
    PODIUM_DANCE_DATA.dance_id = dance_id
    PODIUM_DANCE_DATA.anim_id = math.random( 1, 3 )

    triggerClientEvent( GetPlayersInStripClub(), "onClientStartPodiumDance", resourceRoot, PODIUM_DANCE_DATA )
end

-- Танец в процессе?
function IsDanceProcess()
    local timestamp = getRealTimestamp()
    if PODIUM_DANCE_DATA.dance_id and PODIUM_DANCE_DATA.start_timestamp and timestamp < PODIUM_DANCE_DATA.start_timestamp + PODIUM_DANCE_GIRLS[ PODIUM_DANCE_DATA.dance_id ].dance_duration then
        return true
    end
    return false
end

----------------------------------------------------------
-- Работа с бд
----------------------------------------------------------

-- Обновление данных в бд о внесении денег в банк танцовщицы
function OnPlayerPayPodiumDance( pay_money, dance, dance_id, player )
    
    -- Обновление внесенных денег в стрип-клуб для табла
    player:OnBoughtService( pay_money, dance.currency )
    
    PODIUM_BANK[ dance_id ].dance_pay = PODIUM_BANK[ dance_id ].dance_pay + pay_money
    
    -- Если сумма соответствует нужной, то начинаем танец
    if PODIUM_BANK[ dance_id ].dance_pay == dance.price then
        DB:exec( "UPDATE nrp_podium_bank SET dance_pay = ? WHERE dance_id = ? LIMIT 1", 0, dance_id )
        PODIUM_BANK[ dance_id ].dance_pay = 0

        StartPodiumDance( dance_id )
    else
        triggerClientEvent( GetPlayersInStripClub(), "onClientRefreshPodiumBank", resourceRoot, PODIUM_BANK )
        DB:exec( "UPDATE nrp_podium_bank SET dance_pay = ? WHERE dance_id = ? LIMIT 1", PODIUM_BANK[ dance_id ].dance_pay, dance_id )
    end

    -- Аналитика :- Игрок купил танец на подиуме
    triggerEvent( "onPlayerPurchaseStripDance", player, true, false, dance_id, pay_money, dance.currency )
end