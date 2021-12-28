Import( "ShSkin" )

REGISTERED_ITEMS.skin = {
	available_params = 
	{
		model = { required = true, desc = "ID", from_id = true },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 130, 160 },
		{ 300, 220 },
		{ 300, 280 },
	},

	IsValid = function( self, item )
		local params = item.params or item

		if not SKINS_NAMES[ params.id or params.model ] then
			return false, "Скин с указанным ID не найден"
		end

		return true
	end,

	Give = function( player, params )
		player:GiveSkin( params.id or params.model )
	end;

	checkHasItem = function( player, params )
		return player:HasSkin( params.id or params.model )
	end;

	isExchangeAvailable = function( player, params )
		return player:HasSkin( params.id or params.model ) or SKINS_GENDERS[ params.id or params.model ] ~= player:GetGender( )
	end;

	uiCreateItem = function( id, params, bg, sx, sy )
		local csx, csy = GetBetterRewardContentSize( id, sx, sy )
		return ibCreateContentImage( 0, 0, csx, csy, id, params.id or params.model, bg ):center( )
	end;
	
	uiCreateRewardItem = function( id, params, bg )
		ibCreateContentImage( 0, 40, 300, 280, id, params.id or params.model, bg ):center_x( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Скин " .. SKINS_NAMES[ params.id or params.model ];
			description = "Комплект одежды.\nСтановится доступен\nв гардеробе"
		}
	end;
}