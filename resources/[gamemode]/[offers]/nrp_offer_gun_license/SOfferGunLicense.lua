loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

CONST_OFFER_TIME_SECONDS = 24 * 60 * 60

CONST_LEFT_UNTIL_END_GUN_LICENSE_SECONDS = 2 * 24 * 60 * 60 


function onPlayerReadyToPlay_handler( player )
    local player = player or source

    local gun_licenses = player:GetPermanentData( "gun_licenses" )
    local offer_gun_license_bought = player:GetPermanentData( "offer_gun_license_bought" )
    if not gun_licenses or offer_gun_license_bought then 
        return false
    end
    
    local timestamp = getRealTimestamp()
    local diff_time = gun_licenses.expires - timestamp
    if diff_time <= 0 or diff_time > CONST_LEFT_UNTIL_END_GUN_LICENSE_SECONDS then
        return false
    end
    
    local time_left = player:GetPermanentData( "offer_gun_license_time_left" )
    if time_left and time_left < timestamp then
        return false
    end

    if not time_left then
        time_left = timestamp + CONST_OFFER_TIME_SECONDS
        player:SetPrivateData( "offer_gun_license_time_left", time_left )
        player:SetPermanentData( "offer_gun_license_time_left", time_left )

        onLicenseGunOfferShowFirst( player )
        triggerClientEvent( player, "onShowOfferWeaponLicense", resourceRoot, true )
    else
        player:SetPrivateData( "offer_gun_license_time_left", time_left )
    end

    triggerClientEvent( player, "ShowSplitOfferInfo", root, "gun_license", time_left - getRealTimestamp() )
end
addEvent( "onPlayerReadyToPlay", true )
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )

if SERVER_NUMBER > 100 then
    addCommandHandler( "show_gun_license_offer", onPlayerReadyToPlay_handler )

	addCommandHandler( "clear_gun_license_offer", function( player ) 
		player:ShowInfo("Оффер очищен")
        
        player:SetPermanentData( "offer_gun_license_bought", nil )
        player:SetPermanentData( "offer_gun_license_time_left", nil )
        player:SetPrivateData( "offer_gun_license_time_left", nil )
    end )
    
    addCommandHandler( "ready_gun_license_offer", function( player ) 
		player:ShowInfo("Оффер подготовлен")
        
        local timestamp = getRealTimestamp()
        local gun_licenses = player:GetPermanentData( "gun_licenses" )
        gun_licenses.expires = timestamp + CONST_LEFT_UNTIL_END_GUN_LICENSE_SECONDS - 1 * 24 * 60
        player:SetPermanentData( "gun_licenses", gun_licenses )
	end )
end