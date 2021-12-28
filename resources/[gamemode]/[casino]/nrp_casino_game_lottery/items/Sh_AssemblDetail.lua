REGISTERED_ITEMS.assembl_detail = {
	rewardPlayer_func = function( player, params )
		exports.nrp_assembly_vehicle:GiveAssemblyVehicleDetail( "lottery", player )
	end;

	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		return ibCreateContentImage( 102, 60, 90, 90, "other", "assembl_detail_0" .. params.id, bg )
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 102, 60, 120, 120, "other", "assembl_detail_0" .. params.id, bg )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = exports.nrp_assembly_vehicle:GetAssemblyVehicleDetailById( params.id ).name;
			description = "Для акции\n\"Сборка машины\""
		}
	end;
}