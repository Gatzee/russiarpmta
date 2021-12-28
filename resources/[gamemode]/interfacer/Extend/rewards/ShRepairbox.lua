REGISTERED_ITEMS.repairbox = {
	available_params = 
	{
		count = { required = true, desc = "Количество" },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 120, 120 },
	},

	Give = function( player, params )
		player:InventoryAddItem( IN_REPAIRBOX, nil, params.count )
	end;

	uiCreateItem = function( id, params, bg, sx, sy )
		local csx, csy = GetBetterRewardContentSize( id, sx, sy )
		local img = ibCreateContentImage( 0, 0, csx, csy, "other", id, bg ):center( )

		if params.count > 1 then
			ibCreateLabel( csx/2, csy*0.8, 0, 0, "X".. params.count, img )
				:ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )
		end
		
		return img
	end;

	uiCreateRewardItem = function( id, params, bg )
		ibCreateContentImage( 0, 110, 120, 120, "other", id, bg ):center_x( )

		ibCreateLabel( 0, 238, 0, 0, "x" .. params.count, bg )
			:ibBatchData( { font = ibFonts.bold_34, align_x = "center", align_y = "top" })
			:center_x( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Ремкомплект";
			description = "Позволяет мгновенно\nвосстановить транспорт\nв дороге"
		}
	end;
}