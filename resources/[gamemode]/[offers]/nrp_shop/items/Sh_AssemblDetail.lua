REGISTERED_ITEMS.assembl_detail = {
	rewardPlayer_func = function( player, params )
		exports.nrp_assembly_vehicle:GiveAssemblyVehicleDetail( "case", player )
	end;

    uiCreateItem_func = function( id, params, bg, fonts )
        ibCreateContentImage( 0, 0, 90, 90, "other", "assembl_detail_0" .. params.id, bg ):center( )
	end;

    uiCreateRewardItem_func = function( id, params, bg, fonts )
        ibCreateContentImage( 0, 0, 120, 120, "other", "assembl_detail_0" .. params.id, bg ):center( )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = exports.nrp_assembly_vehicle:GetAssemblyVehicleDetailById( params.id ).name;
			description = "Для акции\n\"Сборка машины\""
		}
	end;

	uiGetContentTextureRolling = function( id, params )
		return "other", "assembl_detail_0" .. params.id, 120, 120
	end;

	uiDrawItemInRolling = function( pos_x, pos_y, texture, size_x, size_y, alpha, id, params, fonts )
		dxDrawImage( pos_x - math.floor( size_x / 2 ), pos_y - math.floor( size_y / 2 ), size_x, size_y, texture, 0, 0, 0, tocolor( 255, 255, 255, alpha ), true )
	end;
}