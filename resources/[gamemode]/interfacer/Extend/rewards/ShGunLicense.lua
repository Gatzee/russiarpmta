REGISTERED_ITEMS.license_gun = {
	available_params = 
	{
		count = { required = true, desc = "Количество дней" },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 120, 120 },
	},

	Give = function( player, params )
        local current_time = getRealTimestamp( )
        
        local licenses = player:GetPermanentData( "gun_licenses" ) or { }
		local diff_time = ( licenses.expires or 0 ) - current_time

		if diff_time > 0 then
			current_time = licenses.expires
		end

        licenses.expires = current_time + ( params.count or 1 ) * 24 * 60 * 60

        player:SetPermanentData( "gun_licenses", licenses )
        player:SetPrivateData( "gun_licenses", licenses.expires )
	end;

    uiCreateItem = function( id, params, bg, sx, sy )
    	local csx, csy = GetBetterRewardContentSize( id, sx, sy )
        local img = ibCreateContentImage( 0, 0, csx, csy, "other", id, bg ):center( )
		ibCreateLabel( csx/2, csy*0.8, 0, 0, ( params.count or 1 ) .. " д.", img )
			:ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )
        return img
	end;

    uiCreateRewardItem = function( id, params, bg )
        ibCreateContentImage( 0, 0, 120, 120, "other", id, bg ):center( )
        
		ibCreateLabel( 0, 238, 0, 0, ( params.count or 1 ) .. " дн.", bg )
			:ibBatchData( { font = ibFonts.bold_34, align_x = "center", align_y = "top" })
			:center_x( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Лицензия на оружие",
		}
	end;
}

function IsPlayerGunLicenseActive( expiration_time )
	local current_time = getRealTimestamp( )
	local diff_time = expiration_time - current_time

	return diff_time >= 0
end