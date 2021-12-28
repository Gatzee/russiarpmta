REGISTERED_ITEMS.assembl_detail = {
	uiCreateItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, "other", "assembl_detail_0" .. params.id, bg ):center( )
	end;
	
	uiCreateRewardItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 120, 120, "other", "assembl_detail_0" .. params.id, bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = exports.nrp_assembly_vehicle:GetAssemblyVehicleDetailById( params.id ).name;
			description = "Для акции\n\"Сборка машины\""
		}
	end;
}