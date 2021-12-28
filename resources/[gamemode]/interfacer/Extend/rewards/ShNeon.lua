Import( "ShNeons" )

REGISTERED_ITEMS.neon = {
	available_params = 
	{
		id = { required = true, desc = "ID" },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 300, 160 },
	},

	IsValid = function( self, item )
		local params = item.params or item

		if not NEONS_RU_NAMES[ params.id ] then
			return false, "Неон с указанным ID не найден"
		end

		return true
	end,

	Give = function( player, params, args, cost )
		player:GiveNeon( {
			cost = cost * 1000,
			neon_image = params.id,
			sell_cost = math.floor( ( cost * 1000 ) * 0.2 ),
			takeoffs_count = 0
		} )
	end;
	
	uiCreateItem = function( id, params, bg, sx, sy )
		local csx, csy = GetBetterRewardContentSize( id, sx, sy )
		return ibCreateContentImage( 0, 0, csx, csy, id, params.id, bg ):center( )
	end;
	
	uiCreateRewardItem = function( id, params, bg )
		ibCreateContentImage( 0, 0, 300, 160, id, params.id, bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Неон " .. NEONS_RU_NAMES[ params.id ];
		}
	end;
}