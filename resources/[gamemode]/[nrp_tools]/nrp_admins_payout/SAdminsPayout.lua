loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SPlayerOffline" )
Extend( "SDB" )
Extend( "ShTimelib" )

ACCESS_LEVEL_PAYOUTS = {
    [ 1 ] = 500000,
    [ 2 ] = 800000,
}

WEBHOOK = "https://hooks.slack.com/services/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"

function MakeWeeklyPayout( )
    local function Payout( client_id, amount )
        local player = GetPlayerFromClientID( client_id )
        if player then
            player:GiveMoney( amount, "admin_weekly_payout" )
        else
            client_id:GiveMoney( amount, "admin_weekly_payout" )
        end

        return true
    end

    local function Notify( text )
        --iprint(text)
        triggerEvent( "onSlackAlertRequest", root, WEBHOOK, "Выдача зарплаты", { 
            text            = text,
            color           = "#00ff00",
            attachment_type = "default"
        } )
    end

    local function PayAdmins( )
        DB:queryAsync( function( query )
            local result = query:poll( -1 )
            for i, v in pairs( result or { } ) do
                local client_id, access_level, nickname = v.client_id, v.accesslevel, v.nickname
                local payout = ACCESS_LEVEL_PAYOUTS[ access_level ]
                if payout and Payout( client_id, payout ) then
                    Notify( nickname .. " получил выплату *" .. format_price( payout ) .. " р.* (access_level = " .. access_level .. "/offline)" )
                end
            end
        end, { }, "SELECT client_id, accesslevel, nickname FROM nrp_players WHERE accesslevel>0" )
    end

    local function PayFromDatabase( )
        -- Кастомные выплаты
        CommonDB:queryAsync( function( query )
            local result = query:poll( -1 )
            for i, v in pairs( result or { } ) do
                if Payout( v.client_id, v.amount ) then
                    Notify( v.nickname .. " / id " .. v.client_id .. " получил выплату *" .. format_price( v.amount ) .. " р.* (database entry)" )
                end
            end

            PayAdmins( )
        end, { }, "SELECT client_id, nickname, amount FROM payouts.payouts_data WHERE server=? AND active='Yes'", tonumber( get( "server.number" ) ) )
    end

    PayFromDatabase( )
end

function WeeklyPayment_StartTimed( )
    if isTimer( WEEKLY_PAYMENT_TIMER ) then killTimer( WEEKLY_PAYMENT_TIMER ) end

    -- Первичная нормализация времени
    ExecAtWeekdays( "fri", function( )
        ExecAtTime( "23:59", function( )
            MakeWeeklyPayout( )

            -- Долбим по этому времени
            WEEKLY_PAYMENT_TIMER = setTimer( MakeWeeklyPayout, 7 * 24 * 60 * 60 * 1000, 0 )
        end )
    end )
end

WeeklyPayment_StartTimed( )