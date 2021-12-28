REGISTERED_ITEMS.license_vehicle = {
	rewardPlayer_func = function( player, params )
        player:SetLicenseState( params.license_type, LICENSE_STATE_TYPE_PASSED )
        player:CompleteDailyQuest( "np_get_b_rights" )
	end;

    uiCreateItem_func = function( id, params, bg, fonts )
        img = ibCreateContentImage( 0, 0, 90, 90, "other", id .. "_" .. params.license_type, bg ):center( )
	end;

    uiCreateRewardItem_func = function( id, params, bg, fonts )
        ibCreateContentImage( 0, 0, 120, 120, "other", id .. "_" .. params.license_type, bg ):center( )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Права категории \"" .. LICENSES_DATA[ params.license_type ].sName .. "\"",
		}
	end;

	uiGetContentTextureRolling = function( id, params )
		return "other", id .. "_" .. params.license_type, 120, 120
	end;

	uiDrawItemInRolling = function( pos_x, pos_y, texture, size_x, size_y, alpha, id, params, fonts )
		dxDrawImage( pos_x - math.floor( size_x / 2 ), pos_y - math.floor( size_y / 2 ), size_x, size_y, texture, 0, 0, 0, tocolor( 255, 255, 255, alpha ), true )
	end;
}