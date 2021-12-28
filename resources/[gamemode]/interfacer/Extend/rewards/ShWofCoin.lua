REGISTERED_ITEMS.wof_coin = {
	available_params = 
	{
		coin_type = { required = true, desc = "Тип жетона (gold - VIP, default - Обычный)", from_id = true },
		count = { required = true, desc = "Количество" },
		source = { desc = "Аргумент передаваемый в GiveCoins" },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 120, 120 },
	},

	Give = function( player, params, args )
		player:GiveCoins( params.count, ( params.id or params.coin_type ), args.source or params.source, "NRPDszx5x" )
	end;

	uiCreateItem = function( id, params, bg, sx, sy )
		local csx, csy = GetBetterRewardContentSize( id, sx, sy )
		local img = ibCreateContentImage( 0, 0, csx, csy, "other", "wof_coin_".. ( params.id or params.coin_type ), bg ):center( )
		ibCreateLabel( csx/2, csy*0.8, 0, 0, params.count, img )
			:ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )
		return img
	end;

	uiCreateRewardItem = function( id, params, bg )
		ibCreateContentImage( 0, 110, 120, 120, "other", "wof_coin_".. ( params.id or params.coin_type ), bg ):center_x( )

		ibCreateLabel( 0, 238, 0, 0, params.count, bg )
			:ibBatchData( { font = ibFonts.bold_34, align_x = "center", align_y = "top" })
			:center_x( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = ( params.id or params.coin_type ) == "gold" and "VIP жетон" or "Жетон",
			description = ( params.id or params.coin_type ) == "gold" and "Для VIP колеса фортуны" or "Для колеса фортуны",
		}
	end;
}