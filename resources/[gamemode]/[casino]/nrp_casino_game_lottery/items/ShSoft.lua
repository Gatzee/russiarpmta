function abbreviate_number( number )
	if number >= 1000000 then
		number = string.format( "%.1fM", number / 1000000 ):gsub( "%.0+", "" )
	elseif number >= 1000 then
		number = string.format( "%.3fK", number / 1000 ):gsub( "0+K", "K" )
	end
	return number
end

REGISTERED_ITEMS.soft = {
	rewardPlayer_func = function( player, params )
		player:GiveMoney( params.count, params.source_class, params.source_class_type )
	end;

	uiCreatePlayersTopItem_func = function( id, params, bg )
		local lbl = ibCreateLabel( 0, 0, 0, 0, format_price( params.count ), bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_18 ):center_y( )
		ibCreateImage( lbl:ibGetAfterX( 7 ), 0, 24, 24, ":nrp_shared/img/money_icon.png", bg ):center_y( )
	end;

	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		local content_img = ibCreateContentImage( 20, 18, 90, 90, "other", id, bg )
		ibCreateLabel( 0, 55, 90, 0, format_price( params.count ), content_img, COLOR_WHITE, 1, 1, "center", "top", ibFonts.oxaniumbold_18 )
		return content_img
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 102, 60, 120, 120, "other", id, bg )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = format_price( params.count ) .. " р.",
			img = ":nrp_shop/img/cases/items/big/".. id ..".png",
		}
	end;
}