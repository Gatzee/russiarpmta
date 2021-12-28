function abbreviate_number( number )
	if number >= 1000 then
		number = math.floor( number / 1000 )

		if number >= 1000 then
			number = ( math.floor( number / 100 ) / 10 ) .."M"
		else
			number = number .."K"
		end
	end
	return number
end

REGISTERED_ITEMS.soft = {
	Give = function( player, params )
		player:GiveMoney( params.count, "sale", "march_offer" )
	end;

	uiCreateItem = function( id, params, bg, fonts )
		local img = ibCreateContentImage( 0, 0, 90, 90, "other", id, bg ):center( )
		ibCreateLabel( 45, 72, 0, 0, abbreviate_number( params.count ), img )
			:ibBatchData( { font = ibFonts.oxaniumbold_14, align_x = "center", align_y = "center" } )
		return img
	end;

	uiCreateBigItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 80, 120, 120, "other", id, bg ):center_x( )

		ibCreateLabel( 0, 210, 0, 0, abbreviate_number( params.count ), bg )
			:ibBatchData( { font = ibFonts.oxaniumbold_30, align_x = "center", align_y = "top" })
			:center_x( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Игровая валюта"
		}
	end;
}