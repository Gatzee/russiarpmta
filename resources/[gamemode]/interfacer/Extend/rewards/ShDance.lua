Import( "ShDances" )

REGISTERED_ITEMS.dance = {
	available_params = 
	{
		id = { required = true, desc = "ID" },
	},

	available_content_sizes = 
	{
		{ 50, 50 },
		{ 90, 90 },
		{ 300, 250 },
	},

	IsValid = function( self, item )
		local params = item.params or item

		if not DANCES_LIST[ params.id ] then
			return false, "Танец с указанным ID не найден"
		end

		return true
	end,

	Give = function( player, params )
		player:AddDance( params.id )
	end;

	checkHasItem = function( player, params )
		return player:HasDance( params.id )
	end;

	isExchangeAvailable = function( player, params )
		return player:HasDance( params.id )
	end;

	uiCreateItem = function( id, params, bg, sx, sy )
		local csx, csy = GetBetterRewardContentSize( id, sx, sy )
		return ibCreateContentImage( 0, 0, csx, csy, "animation", params.id, bg ):center( )
	end;
	
	uiCreateRewardItem = function( id, params, bg )
		ibCreateContentImage( 0, 0, 300, 250, "animation", params.id, bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = DANCES_LIST[ params.id ].name;
			description = "Движение.\nСтановится доступным\nв школе танцев"
		}
	end;
}