function abbreviate_number( number )
	if number >= 1000000 then
		number = string.format( "%.3fM", number / 1000000 ):gsub( "(%..-)0+M", "%1M" ):gsub( "%.M", "M" )
	elseif number >= 1000 then
		number = string.format( "%.3fK", number / 1000 ):gsub( "(%..-)0+K", "%1K" ):gsub( "%.K", "K" )
	end
	return number
end

REGISTERED_ITEMS.soft = {
	available_params = 
	{
		count = { required = true, desc = "Сумма" },
		source = { desc = "1-ый аргумент передаваемый в GiveMoney" },
		source_type = { desc = "2-ой аргумент передаваемый в GiveMoney" },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 120, 120 },
	},

	Give = function( player, params, args )
		player:GiveMoney( params.count, args.source or params.source, args.source_type or params.source_type )
	end;

	GetAnalyticsData = function( player, params )
		return {
			id = abbreviate_number( params.count ),
			cost = math.floor( params.count / 1000 ),
		}
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
			title = "Игровая валюта"
		}
	end;
}