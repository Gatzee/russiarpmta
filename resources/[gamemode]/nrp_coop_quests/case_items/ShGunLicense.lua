REGISTERED_CASE_ITEMS.license_gun = {
	rewardPlayer_func = function( player, params )
        local time_left = getRealTimestamp()
        
        local licenses = player:GetPermanentData( "gun_licenses" ) or {}
        licenses.expires = time_left + 30 * 24 * 60 * 60

        player:SetPermanentData( "gun_licenses", licenses )
        player:SetPrivateData( "gun_licenses", licenses.expires )

        player:InventoryRemoveAllNodesByType( IN_GUN_LICENSE )
        player:InventoryAddItem( IN_GUN_LICENSE, nil, 1 )
	end;

    uiCreateItem_func = function( id, params, bg, fonts )
        ibCreateContentImage( 0, 0, 90, 90, "other", id, bg ):center( )
	end;

    uiCreateRewardItem_func = function( id, params, bg, fonts )
        ibCreateContentImage( 0, 0, 120, 120, "other", id, bg ):center( )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Лицензия на оружие",
		}
	end;

	uiGetContentTextureRolling = function( id, params )
		return "other", id, 120, 120
	end;

	uiDrawItemInRolling = function( pos_x, pos_y, texture, size_x, size_y, alpha, id, params, fonts )
		dxDrawImage( pos_x - math.floor( size_x / 2 ), pos_y - math.floor( size_y / 2 ), size_x, size_y, texture, 0, 0, 0, tocolor( 255, 255, 255, alpha ), true )
	end;
}