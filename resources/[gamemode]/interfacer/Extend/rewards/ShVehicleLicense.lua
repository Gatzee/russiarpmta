REGISTERED_ITEMS.license_vehicle = {
	available_params = 
	{
		license_type = { required = true, desc = "Категория прав" },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 120, 120 },
	},

	Give = function( player, params )
        player:SetLicenseState( params.license_type, LICENSE_STATE_TYPE_PASSED )
        player:CompleteDailyQuest( "np_get_b_rights" )
	end;

    uiCreateItem = function( id, params, bg, sx, sy )
    	local csx, csy = GetBetterRewardContentSize( id, sx, sy )
        img = ibCreateContentImage( 0, 0, csx, csy, "other", id .. "_" .. params.license_type, bg ):center( )
        return img
	end;

    uiCreateRewardItem = function( id, params, bg )
        ibCreateContentImage( 0, 0, 120, 120, "other", id .. "_" .. params.license_type, bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Права категории \"" .. LICENSES_DATA[ params.license_type ].sName .. "\"",
		}
	end;
}