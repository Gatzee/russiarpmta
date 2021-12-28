loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SPlayerOffline" )
Extend( "SDB" )
Extend( "ShTimelib" )

WEBHOOK = "https://hooks.slack.com/services/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"

PAYOUT_UPDATE_FREQ = 10 * 60 * 1000
PAYOUT_MAX_DELAY = 30 * 60 * 1000

PAYOUTS = { }
DELAYED_PAYOUTS = { }

function onResourceStart( )
    CommonDB:createTable( "admin_payouts", 
        {
            { Field = "client_id",		Type = "char(36)",		Null = "NO",	Key = "PRI", 	Default = ""	};
            { Field = "server_id",		Type = "smallint(3)",	Null = "NO",    Key = "",		Default = "0"	};
            { Field = "payout",			Type = "int(11)",	    Null = "NO",	Key = "", 		Default = "0"	};
        } 
    )
    CommonDB:exec( "CREATE INDEX server_id ON admin_payouts( server_id )" )

    setTimer( UpdatePayouts, PAYOUT_UPDATE_FREQ, 0 )
    UpdatePayouts( )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart )

function UpdatePayouts( )
    CommonDB:queryAsync( function( query )
        local result = query:poll( -1 )
        if not result then return end
        PAYOUTS = { }
        for i, v in pairs( result ) do
            PAYOUTS[ v.client_id ] = v
        end
    end, { }, "SELECT client_id, server_id, payout FROM admin_payouts", SERVER_NUMBER )
end

function onPlayerCompleteLogin_payHandler( )
    local client_id = source:GetClientID( )
    local data = PAYOUTS[ client_id ]
    if not data or data.server_id ~= SERVER_NUMBER or data.payout <= 0 then return end
    
    source:GiveDonate( data.payout, "admin_payout" )
    CommonDB:exec( "UPDATE admin_payouts SET payout = payout - ? WHERE client_id = ? LIMIT 1", data.payout, client_id )
    data.payout = 0
    
    SendElasticGameEvent( client_id, "admin_salary_income_take", {
        sum = payout,
        currency = "hard",
    } )
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_payHandler )

function SetPayoutServer_handler( server_id )
    if server_id == SERVER_NUMBER then
        client:ShowError( "Нельзя выбрать этот сервер" )
        return
    end

    local client_id = client:GetClientID( )
    if PAYOUTS[ client_id ] and PAYOUTS[ client_id ].server_id ~= 0 then
        client:ShowError( "Вы уже указали сервер" )
        return
    end

    PAYOUTS[ client_id ] = { server_id = server_id }
    CommonDB:exec( [[
        INSERT INTO admin_payouts (client_id, server_id) VALUES (?, ?)
        ON DUPLICATE KEY UPDATE server_id = ?
    ]], client_id, server_id, server_id )
end
addEvent( "AP:SetPayoutServer", true )
addEventHandler( "AP:SetPayoutServer", root, SetPayoutServer_handler )

local function Notify( text )
    triggerEvent( "onSlackAlertRequest", root, WEBHOOK, "Выдача зарплаты", { 
        text            = text,
        color           = "#00ff00",
        attachment_type = "default"
    } )
end

function SavePayout( client_id, payout )
    CommonDB:exec( [[
        INSERT INTO admin_payouts (client_id, payout) VALUES (?, ?)
        ON DUPLICATE KEY UPDATE payout = payout + ?
    ]], client_id, payout, payout )
end

function Player:AddRewardPayout( payout, task_id )
    local client_id = self:GetClientID( )
    local nickname = self:GetNickName( )
    local access_level = self:GetAccessLevel( )
    SavePayout( client_id, payout )

    WriteLog( "admin/payout", "[TASK_REWARD] %s (CLIENT_ID:%s) получил награду за таск %s", nickname, client_id, payout )
    
    SendElasticGameEvent( client_id, "admin_achive_reward", {
        admin_name = nickname,
        achievement_num = task_id,
        sum = payout,
        currency = "hard",
    } )
end

local ACCESS_LEVEL_ALIASES = {
    [ ACCESS_LEVEL_INTERN ] = "intern",
    [ ACCESS_LEVEL_HELPER ] = "helper",
    [ ACCESS_LEVEL_SENIOR_HELPER ] = "senior_helper",
    [ ACCESS_LEVEL_MODERATOR ] = "moderator",
    [ ACCESS_LEVEL_SENIOR_MODERATOR ] = "senior_moderator",
    [ ACCESS_LEVEL_GAME_MASTER ] = "game_master",
    [ ACCESS_LEVEL_ADMIN ] = "admin",
    [ ACCESS_LEVEL_SENIOR_ADMIN ] = "senior_admin",
    [ ACCESS_LEVEL_SUPERVISOR ] = "supervisor",
    [ ACCESS_LEVEL_HEAD_ADMIN ] = "head_admin",
    [ ACCESS_LEVEL_DEVELOPER ] = "developer",
}

function AddAdminPayout( client_id, nickname, access_level, payout )
    SavePayout( client_id, payout )

    WriteLog( "admin/payout", "[SUCCESS] %s (CLIENT_ID:%s) получил %s", nickname, client_id, payout )
    Notify( nickname .. " / id " .. client_id .. " получил выплату *" .. format_price( payout ) .. " р.* (access_level = " .. access_level .. ")" )

    SendElasticGameEvent( client_id, "admin_salary_income", {
        admin_name = nickname,
        access_level = access_level,
        position_name = tostring( ACCESS_LEVEL_ALIASES[ access_level ] ),
        sum = payout,
        currency = "hard",
    } )
end

function AddAdminPayoutDelayed( player )
    local access_level = player:GetAccessLevel( )
    local payout_info = ADMIN_PAYOUT_INFO[ access_level ]
    if not payout_info then return end

    local client_id = player:GetClientID( )
    local nickname = player:GetNickName( )
    local payout = player:GetPermanentData( "admin_payout" ) or payout_info.value

    WriteLog( "admin/payout", "[DELAYED] %s (CLIENT_ID:%s) получит %s", nickname, client_id, payout )

    table.insert( DELAYED_PAYOUTS, {
        timer = setTimer( AddAdminPayout, math.random( PAYOUT_MAX_DELAY ), 1, client_id, nickname, access_level, payout ),
        client_id = client_id,
        nickname = nickname,
        access_level = access_level,
        payout = payout,
    } )
end

function CheckAdminPayoutTime( player, worked_time, time_passed )
    local worked_time_in_month = worked_time.month.time + worked_time.session
    local old_worked_hours_in_month = math.floor( worked_time_in_month / 3600 )
    local new_worked_hours_in_month = math.floor( ( worked_time_in_month + time_passed ) / 3600 )

    if new_worked_hours_in_month > old_worked_hours_in_month then
        AddAdminPayoutDelayed( player )
    end
end

function onResourceStop_payoutHandler()
    for i, v in pairs( DELAYED_PAYOUTS ) do
        if isTimer( v.timer ) then
            AddAdminPayout( v.client_id, v.nickname, v.access_level, v.payout )
        end
    end
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_payoutHandler )

addEvent( "onPlayerAccessLevelChange" )
addEventHandler( "onPlayerAccessLevelChange", root, function( old_access_level, new_access_level )
    if old_access_level == new_access_level then return end
    source:SetPermanentData( "admin_payout", nil )
    -- onPlayerPreLogout_payoutHandler( source )
    -- onPlayerCompleteLogin_payoutHandler( source )
end )





----------------------------------------------------------------------------------------

if SERVER_NUMBER > 100 then

    addCommandHandler( "reset_payout_server", function( player )
        PAYOUTS[ player:GetClientID( ) ] = nil
        CommonDB:exec( [[
            INSERT INTO admin_payouts (client_id, server_id) VALUES (?, ?)
            ON DUPLICATE KEY UPDATE server_id = ?
        ]], player:GetClientID( ), 0, 0 )
        outputConsole( "Вы успешно сбросили сервер для выплаты", player )
    end )

end