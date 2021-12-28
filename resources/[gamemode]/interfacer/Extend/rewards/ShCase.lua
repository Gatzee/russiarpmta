REGISTERED_ITEMS.case = {
	available_params = 
	{
		id = { required = true, desc = "ID кейса" },
		count = {},
		name = {},
	},

	available_content_sizes = 
	{
		{ 130, 90 },
		{ 360, 280 },
		{ 372, 252 },
	},

	Give = function( player, params )
		player:GiveCase( params.id, params.count or 1 )
	end;

	uiCreateItem = function( id, params, bg, sx, sy )
		local csx, csy = GetBetterRewardContentSize( id, sx, sy )
		local img = ibCreateContentImage( 0, 0, csx, csy, "case", params.id, bg ):center( 0, -10 )

		if ( params.count or 1 ) > 1 then
			ibCreateLabel( sx/2, sy*0.85, 0, 0, "X".. params.count, bg )
				:ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" } )
		end
		
		return img
	end;

	uiCreateRewardItem = function( id, params, bg )
		ibCreateContentImage( 0, 0, 372, 252, "case", params.id, bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = params.name or "Кейс";
			description = params.desc;
		}
	end;
}