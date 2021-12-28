REGISTERED_ITEMS.hard = {
	available_params = 
	{
		count = { required = true, desc = "Количество" },
		source = { required = true, desc = "1-ый аргумент передаваемый в GiveDonate" },
		source_type = { required = true, desc = "2-ой аргумент передаваемый в GiveDonate" },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 120, 120 },
	},
	
	Give = function( player, params, args )
		player:GiveDonate( params.count, args.source or params.source, args.source_type or params.source_type )
	end;

	uiCreateItem = function( id, params, bg, sx, sy )
		local csx, csy = GetBetterRewardContentSize( id, sx, sy )
		local img = ibCreateContentImage( 0, 0, csx, csy, "other", id, bg ):center( )
		ibCreateLabel( csx/2, csy*0.8, 0, 0, abbreviate_number( params.count ), img )
			:ibBatchData( { font = ibFonts.bold_18, align_x = "center", align_y = "center" } )
		return img
	end;

	uiCreateRewardItem = function( id, params, bg )
		ibCreateContentImage( 0, 110, 120, 120, "other", id, bg ):center_x( )

		ibCreateLabel( 0, 238, 0, 0, abbreviate_number( params.count ), bg )
			:ibBatchData( { font = ibFonts.bold_34, align_x = "center", align_y = "top" })
			:center_x( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Рубли"
		}
	end;
}