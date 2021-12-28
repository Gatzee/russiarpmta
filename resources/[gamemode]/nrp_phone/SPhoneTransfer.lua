loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "ShTimelib" )

TRANSFER_LIMIT = 30000
TRANSFER_DAILY_LIMIT = 150000

TRANSFERS_CACHE = { }
DAILY_TRANSFERS_CACHE = { }

-- Каждый день в полночь очистка общей суммы переводов
function StartTimedCleanup( )
    ExecAtTime( "00:00", function( self )
        TRANSFERS_CACHE = { }
        DAILY_TRANSFERS_CACHE = { }
        setTimer( StartTimedCleanup, MS10MINS, 1 )
    end )
end

function onPhoneTransferRequest_handler( name, amount )
    if not client then return end
    local user_id = client:GetUserID()

    local amount_preparse = amount

    local target, amount, name = _, math.abs( math.floor( amount ) ), utf8.lower( name )
    for i, v in pairs( getElementsByType( "player" ) ) do
        if v:IsInGame() and utf8.lower( v:GetNickName() ) == name then
            target = v
            break
        end
    end

    if client:getData( "transfer" ) then
        client:ShowError( "Нельзя переводить деньги во время переноса" )
        return
    end

    if client:GetLevel() < 6 then
        client:ShowError( "Можно переводить деньги только с 6 уровня" )
        return
    end

    if not target then
        client:ShowError( "Игрок не в сети" )
        return
    end

    if client == target then
        client:ShowError("Нельзя переводить деньги самому себе!")
        return
    end

    if not tonumber( amount ) or amount < 50 then
        client:ShowError("Некорректная сумма")
        return
	end

    if client:GetMoney() < amount then
        client:ShowError( "Недостаточно средств для перевода!" )
        return
    end

    if target:GetLevel() < 3 then
        client:ShowError( "Игрок должен быть 3 уровня или выше чтобы принимать переводы" )
        return
    end

    local serials_client = {
        client.serial,
        client:GetPermanentData( "reg_serial" ),
        client:GetPermanentData( "last_serial" ),
    }
    local serials_target = {
        target.serial,
        target:GetPermanentData( "reg_serial" ),
        target:GetPermanentData( "last_serial" ),
    }
    for i, v in pairs( serials_client ) do
        for k, n in pairs( serials_target ) do
            if v == n then
                client:ShowError( "Нельзя передать деньги этому игроку" )
                return
            end
        end
    end

    local target_id = target:GetClientID()

    if not TRANSFERS_CACHE[ user_id ] then TRANSFERS_CACHE[ user_id ] = { } end

    -- Проверка на сумму одному игроку
    local transfer_info = table.copy( TRANSFERS_CACHE[ user_id ][ target_id ] or { } )

    local transferred_amount = transfer_info.amount or 0
    local transferred_timestamp = transfer_info.timestamp or 0
    local then_date = getRealTime( transferred_timestamp )
    local now_date = getRealTime()

    if  ( then_date.monthday ~= now_date.monthday ) or 
        ( then_date.month ~= now_date.month ) or 
        ( then_date.year ~= now_date.year ) then
            transferred_amount = 0
            transferred_timestamp = now_date.timestamp
    end

    if transferred_amount + amount > TRANSFER_LIMIT then
        client:ShowError( "Вы можете перевести не более " .. format_price( TRANSFER_LIMIT - transferred_amount ) .. " р. этому игроку" )
        return
    end

    transfer_info.amount = transferred_amount + amount
    transfer_info.timestamp = transferred_timestamp

    -- Проверка на общий перевод
    if not DAILY_TRANSFERS_CACHE[ user_id ] then DAILY_TRANSFERS_CACHE[ user_id ] = 0 end
    if DAILY_TRANSFERS_CACHE[ user_id ] + amount >= TRANSFER_DAILY_LIMIT then
        client:ShowError( "Вы можете переводить не более " .. format_price( TRANSFER_DAILY_LIMIT ) .. " р. в день (осталось: " .. ( TRANSFER_DAILY_LIMIT - DAILY_TRANSFERS_CACHE[ user_id ] ) .. " р.)"  )
        return
    end
    DAILY_TRANSFERS_CACHE[ user_id ] = DAILY_TRANSFERS_CACHE[ user_id ] + amount

    TRANSFERS_CACHE[ user_id ][ target_id ] = transfer_info

    client:TakeMoney( amount, "phone_transfer_send" )
    target:GiveMoney( amount, "phone_transfer_recieve" )

    WriteLog( "transfer", "%s перевёл %s игроку %s", client, amount, target )

    client:ShowSuccess( "Ты перевёл " .. amount .. "р. игроку " .. target:GetNickName() )
    target:ShowSuccess( client:GetNickName() .. " перевёл тебе " .. amount )

    iprint( client, "перевел", amount, target, amount_preparse )
end
addEvent( "onPhoneTransferRequest", true )
addEventHandler( "onPhoneTransferRequest", root, onPhoneTransferRequest_handler )

-- Обработка рестарта
function onResourceStop_transferHandler( )
    setElementData( root, "TRANSFERS_CACHE", TRANSFERS_CACHE, false )
    setElementData( root, "DAILY_TRANSFERS_CACHE", DAILY_TRANSFERS_CACHE, false )
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_transferHandler )

function onResourceStart_transferHandler( )
    TRANSFERS_CACHE = getElementData( root, "TRANSFERS_CACHE" ) or { }
    DAILY_TRANSFERS_CACHE = getElementData( root, "DAILY_TRANSFERS_CACHE" ) or { }

    StartTimedCleanup()
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_transferHandler )