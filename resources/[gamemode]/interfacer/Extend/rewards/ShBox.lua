local CONST_BOX_NAMES = {
	[1] = "Пакет игрока начинающий";
	[2] = "Пакет игрока стартовый";
	-- [3] = "Аптечка + канистра";
	-- [4] = "Рем. комплект + канистра + аптечка";
	-- [5] = "Канистра + Рем. комплект 2шт";
}

local CONST_BOX_ITEMS = {
	[ 1 ] = { car_evac = { count = 2 }, firstaid = { count = 2 }, jailkeys = { count = 2 }, repairbox = { count = 2 } },
	[ 2 ] = { car_evac = { count = 2 }, firstaid = { count = 2 }, jailkeys = { count = 3 }, premium = { days = 1 }, repairbox = { count = 2 }, },
}

REGISTERED_ITEMS.box = {
	available_params = 
	{
		number = { required = true, desc = "ID", from_id = true },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 120, 120 },
		{ 300, 240 },
	},

	IsValid = function( self, item )
		local params = item.params or item

		if not CONST_BOX_ITEMS[ ( params.id or params.number ) ] then
			return false, "Набор с указанным ID не найден"
		end

		return true
	end,

	Give = function( player, params )
		for id, param in pairs( params.items or CONST_BOX_ITEMS[ ( params.id or params.number ) ] ) do
			REGISTERED_ITEMS[ id ].Give( player, param )
		end
	end;

	GetAnalyticsData = function( player, params )
		return {
			id = ( params.id or params.number ),
		}
	end;

	uiCreateItem = function( id, params, bg, sx, sy )
		local csx, csy = GetBetterRewardContentSize( id, sx, sy )
		return ibCreateContentImage( 0, 0, csx, csy, "other", "box" .. ( params.id or params.number ), bg ):center( )
	end;

	uiCreateRewardItem = function( id, params, bg )
		ibCreateContentImage( 0, 20, 300, 240, "other", "box" .. ( params.id or params.number ), bg ):center_x( )

		local area_bg = ibCreateArea( 0, 260, 96, 96, bg )
		local counter = 0
		for id, param in pairs( params.items or CONST_BOX_ITEMS[ ( params.id or params.number ) ] ) do
			local min_bg = ibCreateArea( counter * 96, 0, 96, 96, area_bg )
			REGISTERED_ITEMS[ id ].uiCreateItem( id, param, min_bg, 96, 96 )

			local description_data = REGISTERED_ITEMS[ id ].uiGetDescriptionData( id, param )
			if description_data then
				min_bg:ibDeepSet( "disabled", true ):ibData( "disabled", false )
				min_bg:ibAttachTooltip( description_data.title )
			end

			counter = counter + 1
		end

		area_bg:ibData( "sx", counter * 96 ):center_x( )
	end;

	uiGetDescriptionData = function( id, params )
		return {
			title = params.name or CONST_BOX_NAMES[ ( params.id or params.number ) ] or "Набор";
		}
	end;
}