local PLAYER_PHONE_INDIVIDUALIZATION_DATA = { }

addEventHandler( "onResourceStart", resourceRoot, function()
    
    DB:createTable( "nrp_player_phone",
	{
        { Field = "player_id",         Type = "int(11) unsigned",   Null = "NO", Key = "PRI", },
        { Field = "phone_wallpaper",   Type = "text",	            Null = "NO", Key = "",    },
        { Field = "phone_sounds",      Type = "text",	            Null = "NO", Key = "",    },
        { Field = "current_wallpaper", Type = "text",	            Null = "NO", Key = "",    },
        { Field = "current_sounds",    Type = "text",	            Null = "NO", Key = "",    },
    })

    setTimer( function() 
        for k, v in pairs( getElementsByType( "player" ) ) do
            if v:IsInGame() then
                LoadIndividualizationDataPhone( v )
            end
        end
    end, 1000, 1 )
end )

function onPlayerReady_handler( pPlayer )
	local pPlayer = pPlayer or source
    LoadIndividualizationDataPhone( pPlayer )
end
addEvent("onPlayerReadyToPlay", true)
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReady_handler, true, "high+1000000" )

function onIgChange(key)
    if key ~= '_ig' then return end
    LoadIndividualizationDataPhone( source )
end
addEventHandler("onElementDataChange", root, onIgChange)

addEvent( "onPlayerPreLogout", true )
addEventHandler( "onPlayerPreLogout", root, function ( )
    PLAYER_PHONE_INDIVIDUALIZATION_DATA[ source ] = nil
end )

function LoadIndividualizationDataPhone( player )

    local default_wallpaper = 
    { 
        [ "bg_1" ] = true,
    }
    local default_sound = 
    {
        [ "ringtone_5" ]     = true,
        [ "message_2" ]      = true,
        [ "notification_2" ] = true,
    }
    local current_sound = 
    {
        [ "ringtone" ]     = "ringtone_5",
        [ "message" ]      = "message_2",
        [ "notification" ] = "notification_2",
    }
    local player_id = player:GetUserID()
    DB:exec( 
        "INSERT IGNORE INTO nrp_player_phone ( player_id, phone_wallpaper, phone_sounds, current_wallpaper, current_sounds ) VALUES( ?, ?, ?, ?, ? )", 
        player_id, toJSON( default_wallpaper ), toJSON( default_sound ), "bg_1", toJSON( current_sound ) 
    )
    
    DB:queryAsync( function( qh, player )
        if not isElement( player ) then
            dbFree( qh )
            return
        end
        local result = qh:poll( -1 )
        if result and #result > 0 then
            PLAYER_PHONE_INDIVIDUALIZATION_DATA[ player ] = {
                wallpapers = fromJSON( result[ 1 ].phone_wallpaper ), 
                sounds = fromJSON( result[ 1 ].phone_sounds ), 
            }
            triggerClientEvent( player, "onClientUpdateIndividualizationPhone", player, result[ 1 ] )
        end
    end, { player }, "SELECT phone_wallpaper, phone_sounds, current_wallpaper, current_sounds FROM nrp_player_phone WHERE player_id=? LIMIT 1", player_id )
end

function GetPlayerWallpapers( player )
    local data = PLAYER_PHONE_INDIVIDUALIZATION_DATA[ player ]
    return data and data.wallpapers
end

function GiveWallpaper( player, wallpaper_id )
    local user_id = player:GetUserID()
    DB:queryAsync( function( qh, player, user_id, wallpaper_id )
        local result = qh:poll( -1 )
        if result and #result > 0 then
            local wallpapers = fromJSON( result[ 1 ].phone_wallpaper )
            wallpapers[ wallpaper_id ] = true
            local wallpapers_json = toJSON( wallpapers )
            DB:exec( "UPDATE nrp_player_phone SET phone_wallpaper = ? WHERE player_id = ? LIMIT 1", wallpapers_json, user_id )

            if isElement( player ) then
                PLAYER_PHONE_INDIVIDUALIZATION_DATA[ player ].wallpapers = wallpapers
                triggerClientEvent( player, "onClientUpdateIndividualizationPhone", player, { phone_wallpaper = wallpapers_json } )
            end
        end
    end, { player, user_id, wallpaper_id }, "SELECT phone_wallpaper FROM nrp_player_phone WHERE player_id=? LIMIT 1", user_id )
end

function GiveSound( player, sound_id, is_bought )
    local user_id = player:GetUserID()
    DB:queryAsync( function( qh, player, user_id, sound_id )
        local result = qh:poll( -1 )
        if result and #result > 0 then
            local sounds = fromJSON( result[ 1 ].phone_sounds )
            sounds[ sound_id ] = true
            local sounds_json = toJSON( sounds )
            DB:exec( "UPDATE nrp_player_phone SET phone_sounds = ? WHERE player_id = ? LIMIT 1", sounds_json, user_id )

            if isElement( player ) then
                PLAYER_PHONE_INDIVIDUALIZATION_DATA[ player ].sounds = sounds
                triggerClientEvent( player, "onClientUpdateIndividualizationPhone", player, { phone_sounds = sounds_json, buy_sound = is_bought and sound_id } )
            end
        end
    end, { player, user_id, sound_id }, "SELECT phone_sounds FROM nrp_player_phone WHERE player_id=? LIMIT 1", user_id )
end

function onServerBuySoundPhone_handler( price, currency, sound_group, sound_id )
	if not client then return end

    if TakePlayerPrice( client, price, currency ) then
        GiveSound( client, sound_id, true )

        -- Аналитика :- покупка рингтонов
        triggerEvent( "onPlayerBuyPhoneSound", client, currency, price, sound_group, sound_id )
	else
		client:ShowError( "Недостаточно средств" )
    end
end
addEvent( "onServerBuySoundPhone", true )
addEventHandler( "onServerBuySoundPhone", root, onServerBuySoundPhone_handler )


function onServerBuyWallpaperPhone_handler( price, currency, wallpaper_id )
	if not client then return end

    if TakePlayerPrice( client, price, currency ) then
        GiveWallpaper( client, wallpaper_id )

        -- Аналитика :- покупка обоев
		triggerEvent( "onPlayerBuyPhoneWallpaper", client, currency, price, wallpaper_id )
	else
		client:ShowError( "Недостаточно средств" )
    end
end
addEvent( "onServerBuyWallpaperPhone", true )
addEventHandler( "onServerBuyWallpaperPhone", root, onServerBuyWallpaperPhone_handler )

function TakePlayerPrice( player, price, currency )
    if currency == "soft" then
		return player:TakeMoney( price, "phone_wallpaper_purchase" )
	elseif currency == "hard" then
        return player:TakeDonate( price, "phone_wallpaper_purchase" )
	end
end


function onServerSetSoundPhone_handler( sound_group, sound_id )
    DB:queryAsync( function( qh, player, sound_group, sound_id )
        if not isElement( player ) then
            dbFree( qh )
            return
        end
        local result = qh:poll( -1 )
        if result and #result > 0 then
            local current_sounds = fromJSON( result[ 1 ].current_sounds )
            current_sounds[ sound_group ] = sound_id
            current_sounds = toJSON( current_sounds )
            DB:exec( "UPDATE nrp_player_phone SET current_sounds = ? WHERE player_id = ? LIMIT 1", current_sounds, player:GetUserID() )
            triggerClientEvent( player, "onClientUpdateIndividualizationPhone", player, { current_sounds = current_sounds } )
        end
    end, { client, sound_group, sound_id }, "SELECT current_sounds FROM nrp_player_phone WHERE player_id=? LIMIT 1", client:GetUserID() )
end
addEvent( "onServerSetSoundPhone", true )
addEventHandler( "onServerSetSoundPhone", root, onServerSetSoundPhone_handler )

function onServerSetWallpaperPhone_handler( wallpaper_id )
    DB:exec( "UPDATE nrp_player_phone SET current_wallpaper = ? WHERE player_id = ? LIMIT 1", wallpaper_id, client:GetUserID() )
end
addEvent( "onServerSetWallpaperPhone", true )
addEventHandler( "onServerSetWallpaperPhone", root, onServerSetWallpaperPhone_handler )