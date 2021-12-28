REGISTERED_ITEMS.assembl_detail = {
	available_params = 
	{
		id = { required = true, desc = "ID" },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 120, 120 },
	},

	Give = function( player, params )
		exports.nrp_assembly_vehicle:GiveAssemblyVehicleDetail( params.id == 1 and "battle_pass" or "battle_pass_prem", player )
	end;

	-- isExchangeAvailable = function( player, params )
	-- 	return player:InventoryGetItemCount( IN_ASSEMBL_DETAIL, { params.id } ) > 0 -- or
	-- end;

	uiCreateItem = function( id, params, bg, sx, sy )
		local csx, csy = GetBetterRewardContentSize( id, sx, sy )
		return ibCreateContentImage( 0, 0, csx, csy, "other", "assembl_detail_0" .. params.id, bg ):center( )
	end;
	
	uiCreateRewardItem = function( id, params, bg )
		ibCreateContentImage( 0, 0, 120, 120, "other", "assembl_detail_0" .. params.id, bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = exports.nrp_assembly_vehicle:GetAssemblyVehicleDetailById( params.id ).name;
			description = "Для акции\n\"Сборка машины\""
		}
	end;
}