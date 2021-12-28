loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SDB" )

NEED_LEVEL = 10

addEventHandler( "onResourceStart", resourceRoot, function( )
    DB:createTable( "nrp_user_invite_codes", 
        {
            { Field = "ckey"         , Type = "varchar(128)"     , Null = "NO", Key = "PRI" , };
            { Field = "owner_id"     , Type = "int(11) unsigned" , Null = "NO", Key = ""    , };
            { Field = "is_activated" , Type = "boolean"          , Null = "NO", Key = ""    , Default = 0 };
        } 
    )
	DB:exec( "CREATE INDEX owner_id ON nrp_user_invite_codes( owner_id )" )

    setTimer( function()
        for i, player in pairs( GetPlayersInGame() ) do
            onPlayerReadyToPlay_handler( player )
        end
    end, 1000, 1 )
end )

function CreateInviteCode( player, level )
    local owner_id = player:GetID()
    local code = owner_id .. "-" .. level .. md5( math.random() ):sub( 1, 4 )
    DB:exec( "INSERT INTO nrp_user_invite_codes( ckey, owner_id ) VALUES( ?, ? )", code, owner_id )

	SendElasticGameEvent( player:GetClientID( ), "fullrp_invite_get", {
		code = code,
	} )
    return code
end

function onPlayerReadyToPlay_handler( player )
    player = isElement( player ) and player or source

    if not player:HasFinishedTutorial() then return end

    if not player:GetPermanentData( "fullrp_invite_showfirst" ) then
        triggerClientEvent( player, "ShowInviteUserInfo", resourceRoot )

        player:SetPermanentData( "fullrp_invite_showfirst", true )
        SendElasticGameEvent( player:GetClientID( ), "fullrp_invite_showfirst" )
    end

    local level = player:GetLevel()
    if level < NEED_LEVEL then return end

    DB:queryAsync( function( query )
        local result = query:poll( -1 )
        if not result then return end
        if not isElement( player ) then return end

        local available_codes = {}
        for i, code in pairs( result ) do
            if code.is_activated == 0 then
                table.insert( available_codes, code.ckey )
            end
        end

        -- Первичная выдача кодов после релиза
        local total_codes_count = math.floor( ( level - NEED_LEVEL ) / 2 ) + 1
        if #result < total_codes_count then
            for i = #result + 1, total_codes_count do
                local code = CreateInviteCode( player, NEED_LEVEL + ( i - 1 ) * 2 )
                table.insert( available_codes, code )
            end
        end

        triggerClientEvent( player, "onInviteCodesReceive", player, available_codes )
    end, { }, "SELECT ckey, is_activated FROM nrp_user_invite_codes WHERE owner_id = ?", player:GetID() )
end
addEvent( "onPlayerReadyToPlay" )
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )

addEvent( "OnPlayerLevelUp" )
addEventHandler( "OnPlayerLevelUp", root, function( level )
    if level < NEED_LEVEL then return end
    if level % 2 ~= 0 then return end
    local player = source
    local code = CreateInviteCode( player, level )

    if level == NEED_LEVEL then
        triggerClientEvent( player, "ShowInviteUserInfo", resourceRoot )
        triggerClientEvent( player, "onInviteCodesReceive", player, { code } )
    else
        triggerClientEvent( player, "onNewInviteCodeReceive", player, code )
    end
end )

addEvent( "onPlayerInviteCodeUse" )
addEventHandler( "onPlayerInviteCodeUse", root, function( code )
    DB:queryAsync( function( query )
        local result = query:poll( -1 )
        if not result or #result == 0 then return end

        local owner = GetPlayer( result[ 1 ].owner_id )
        if owner then
            triggerClientEvent( owner, "onInviteCodeUse", owner, code )
        end
    end, { }, "SELECT owner_id FROM nrp_user_invite_codes WHERE ckey = ?", code )

    SendElasticGameEvent( source:GetClientID( ), "fullrp_invite_use", {
        code = code,
    } )
end )