OFFER_CONFIG = {
	start_date  = 0,
	finish_date = 0,
}

function GetSegment( player, weapon_shop_purchase )
	if not player then return end
	weapon_shop_purchase = weapon_shop_purchase or 0
	local segment = 1

	for k, v in ipairs( SEGMENTS ) do
		if weapon_shop_purchase >= v.count then
			segment = k
		end
	end

	return segment
end

addEventHandler( "onPlayerReadyToPlay", root, function ( )
	local timestamp = getRealTimestamp( )
    if timestamp < OFFER_CONFIG.start_date or timestamp > OFFER_CONFIG.finish_date then return end
    
	local weapon_shop_purchase = source:GetPermanentData( "weapon_shop_purchase" ) or 0
	local segment = GetSegment( source, weapon_shop_purchase )
	source:SetPrivateData( "weapon_shop_segment", segment )

	local licenses = source:GetPermanentData( "gun_licenses" )
	local has_player_active_gun_license = licenses and IsPlayerGunLicenseActive( licenses.expires ) or false
	if not has_player_active_gun_license then return end
	
	if not source:GetPermanentData( "offer_pack_gun_showfirst" ) then
		source:SetPermanentData( "offer_pack_gun_showfirst", true )

		-- analytics
		local client_id = source:GetClientID( )

		SendElasticGameEvent( client_id, "offer_pack_gun_showfirst", { } )

        SendElasticGameEvent( client_id, "offer_pack_gun_segment_change", {
            segment_num = segment,
        } )
	end

	triggerClientEvent( source, "ActivateGunShopOffer", resourceRoot, OFFER_CONFIG.finish_date )
end, true, "high+9999999" )

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
	if key ~= "weapon_packs_offer" then return end

	if not value or next( value ) == nil then
		OFFER_CONFIG = {
			start_date  = 0,
			finish_date = 0,
		}
	else
		OFFER_CONFIG = {
			start_date  = getTimestampFromString( value[ 1 ].start_date ),
			finish_date = getTimestampFromString( value[ 1 ].finish_date ),
		}
	end
end )
--После запуска ресурса обновляем все даты
triggerEvent( "onSpecialDataRequest", getResourceRootElement( ), "weapon_packs_offer" )

-- Тестирование
if SERVER_NUMBER > 100 then
	addCommandHandler( "set_weapon_shop_purchase", function( player, cmd, count )
		count = tonumber( count )

		if not count or count < 0 then player:ShowInfo( "формат: reset_double_mayhem count" ) return end

		player:SetPermanentData( "weapon_shop_purchase", count )
		player:ShowInfo( "установлена сумма покупок " .. count )
	end )

	addCommandHandler( "reset_weapon_shop_show_first", function( player )
		player:SetPermanentData( "offer_pack_gun_showfirst", nil )
		player:ShowInfo( "сброшен первый показ окна" )
	end )

	addCommandHandler( "get_weapon_shop_purchase", function( player )
		iprint( "weapon_shop_purchase ", player:GetPermanentData( "weapon_shop_purchase" ) )
	end )
end

--[[ -- TEMP
setTimer( function( )
	local source = GetPlayer( 9 )
	local timestamp = getRealTimestamp( )
    if timestamp < OFFER_CONFIG.start_date or timestamp > OFFER_CONFIG.finish_date then return end
    
	local weapon_shop_purchase = source:GetPermanentData( "weapon_shop_purchase" ) or 0
	local segment = GetSegment( source, weapon_shop_purchase )
	source:SetPrivateData( "weapon_shop_segment", segment )
	
	if not source:GetPermanentData( "offer_pack_gun_showfirst" ) then
		source:SetPermanentData( "offer_pack_gun_showfirst", true )

		-- analytics
		local client_id = source:GetClientID( )

		SendElasticGameEvent( client_id, "offer_pack_gun_showfirst", { } )

        SendElasticGameEvent( client_id, "offer_pack_gun_segment_change", {
            segment_num = segment,
        } )
	end

	source:SetPermanentData( "gun_licenses", nil )
	source:SetPrivateData( "gun_licenses", nil )

	triggerClientEvent( source, "ActivateGunShopOffer", resourceRoot, OFFER_CONFIG.finish_date )
end, 1000, 1) ]]