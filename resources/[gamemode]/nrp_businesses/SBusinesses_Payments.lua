local CONST_3DAY_IN_SEC = 3 * 24 * 60 * 60
local TMP_SKIP_WEEKLY_PAYMENT = 1594587600 -- 13.07.2020 00:00

function TakeWeeklyPayment( business_id )
    if HasOwner( business_id ) then
		local last_weekly_payment_date = GetBusinessData( business_id, "last_weekly_payment_date" ) or 0
		local timestamp = getRealTimestamp( )

		if timestamp < TMP_SKIP_WEEKLY_PAYMENT then return end
		if (timestamp - last_weekly_payment_date) < CONST_3DAY_IN_SEC then return end

        local payment = GetBusinessConfig( business_id, "weekly_cost" )
        local balance = GetBusinessData( business_id, "balance" )

        local player = GetPlayer( GetBusinessData( business_id, "userid" ), true )
        local client_id = GetBusinessData( business_id, "client_id" )

        -- Если нужно забрать бизнес и перепроверить приложение форбс
        if balance < 0 then
            triggerEvent( "onBusinessFuckup", root, client_id, business_id )

            WriteLog( 
                "businesses", 
                "[%s/%s/%s] [Утеря бизнеса] Текущий баланс: %s, требуется: %s",
                business_id, GetBusinessData( business_id, "client_id" ), GetBusinessData( business_id, "client_id" ):GetNickName( ), balance, payment
            )

            ResetBusiness( business_id )
            UpdateBusinessBlips( )

            local target = player or client_id
            target:PhoneNotification( {
                title = "Потеря бизнеса",
                msg = "Ваш бизнес `" .. GetBusinessConfig( business_id, "name" ) .. "` был продан в счёт долгов"
            } )
        
        -- Если нужно просто снять баланс
        else
            SetBusinessData( business_id, "balance", balance - payment )
            WriteLog( 
                "businesses", 
                "[%s/%s/%s] [Еженедельная плата] Снято: %s, баланс: %s",
                business_id, GetBusinessData( business_id, "client_id" ), GetBusinessData( business_id, "client_id" ):GetNickName( ), payment, balance - payment
            )

            local target = player or client_id
            target:PhoneNotification( {
                title = "Уплата аренды и налогов",
                msg = "С лицевого счёта бизнеса `" .. GetBusinessConfig( business_id, "name" ) .. "` было снято " .. payment .. " р. в налоговую и за аренду"
			} )

			SetBusinessData( business_id, "last_weekly_payment_date", timestamp )
        end

        -- Сразу сохраняем бизнес
        SaveBusinessData( business_id )
    end
end

function TakeBusinessesPayment( )
    for i, v in pairs( BUSINESSES ) do
        TakeWeeklyPayment( v.id )
    end
end

function WeeklyPayment_StartTimed( )
    if isTimer( WEEKLY_PAYMENT_TIMER ) then killTimer( WEEKLY_PAYMENT_TIMER ) end

    -- Первичная нормализация времени
    ExecAtWeekdays( "sun", function( )
        ExecAtTime( "15:00", function( )
            TakeBusinessesPayment( )

            -- Долбим по этому времени
            WEEKLY_PAYMENT_TIMER = setTimer( TakeBusinessesPayment, 7 * 24 * 60 * 60 * 1000, 0 )
        end )
    end )
end

WeeklyPayment_StartTimed( )

-- Тестирование

if SERVER_NUMBER > 100 then
    addCommandHandler( "update_businesses", function( player, cmd )
        TakeBusinessesPayment( )
    end )
end