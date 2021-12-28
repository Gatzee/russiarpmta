loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "ShSkin" )
Extend( "ShAccessories" )

local SAVED_POSITIONS = { }

function ClientRequestDataAndShowUIShop_handler( show_state )
	if not client then return end
	
	if show_state then
		if client:IsInEventLobby( ) then return end

		local player_gender_skin_list = {}
		local player_gender = client:GetGender()
		for k, v in pairs( client:GetSkins( ) ) do
			if SKINS_GENDERS[ v ] == player_gender then
				player_gender_skin_list[ k ] = v
			end
		end

		triggerClientEvent( client, "ReciveShowUIShopData", resourceRoot, player_gender_skin_list, client:GetOwnedAccessories( ), client:GetAccessories( ) )

		triggerEvent( "onPlayerSkinshopOpen", client )
	end

	SAVED_POSITIONS[ client ] = show_state and { client.position, client.interior, client.dimension } or nil

	client:setData( "is_in_clothes_shop", show_state, false )
end
addEvent( "ClientRequestDataAndShowUIShop", true )
addEventHandler( "ClientRequestDataAndShowUIShop", root, ClientRequestDataAndShowUIShop_handler )


function PlayerWantBuyClothes_handler( model, slot )
	local player = client or source
	if not player then return end

	local player_gender = player:GetGender( )
	local clothes = BOUTIQUE_ASSORTMENT[ player_gender ][ model ]
	if not clothes then return end
	
	if player:HasSkin( clothes.model ) then
		player:ShowError( "Вы уже приобрели эту одежду" )
		return
	end

	local item_blocked = false
	local blocked_text = ""
	if clothes.blocked then
		if clothes.blocked.unlock and not player:IsUnlocked( clothes.blocked.unlock ) then
			item_blocked = true
			blocked_text = clothes.blocked.hint
		end

		if clothes.blocked.premium and ( not player:IsPremiumActive( ) ) then
			item_blocked = true
			blocked_text = "Доступно с премиумом"
		end
	end

	if item_blocked then
		player:ShowError( blocked_text )
		return
	end

	local is_offer_available = false
	local cost = clothes.cost
	if ( ( player:GetPermanentData( "offer_skin" ) or { } ).time_to or 0 ) >= getRealTimestamp( ) then
		is_offer_available = true
		cost = math.floor( cost * 0.85 ) -- 15% discount
	end

	if not player:TakeMoney( cost, "skin_purchase" ) then
		player:EnoughMoneyOffer( "Clothes purchase", cost, "PlayerWantBuyClothes", player, model, slot )
		return
	end

	player:GiveSkin( clothes.model )
	player:ShowInfo( "Вы успешно приобрели одежду, спасибо за покупку!" )

	triggerEvent( "onPlayerSomeDo", player, "buy_skin" ) -- achievements

	WriteLog( "money/special", "Покупка: %s приобрёл скин %s за %s", player, clothes.model, cost )
	triggerEvent( "onPlayerSkinPurchase", player, clothes.model, cost )
	triggerClientEvent( player, "UpdatePlayerBuyCloth", resourceRoot, model )

	-- offer
	if is_offer_available then
		triggerEvent( "onPlayerBoughtSkinViaOffer", player, clothes.model, cost )
	end
end
addEvent( "PlayerWantBuyClothes", true )
addEventHandler( "PlayerWantBuyClothes", root, PlayerWantBuyClothes_handler )


function PlayerWantUseSkin_handler( model )
	if not client then return end

	local skins_list = client:GetPermanentData( "skins" ) or { [ "s1" ] = client.model }
	local slot_index = nil
	for slot, skin_model in pairs( skins_list ) do
		if skin_model == model then
			slot_index = slot
			break
		end
	end

	if not slot_index then return end

	local save_skin = skins_list[ slot_index ]
	skins_list[ slot_index ] = skins_list[ "s1" ]
	skins_list[ "s1" ] = save_skin

	client.model = save_skin
	client:SetPermanentData( "skins", skins_list )

	triggerClientEvent( client, "HideUIShop", resourceRoot )
end
addEvent( "PlayerWantUseSkin", true )
addEventHandler( "PlayerWantUseSkin", resourceRoot, PlayerWantUseSkin_handler )

addEventHandler( "onPlayerPreLogout", root, function( )
	local pos = SAVED_POSITIONS[ source ]
	if pos then
		source.position = pos[ 1 ]
		source.interior = pos[ 2 ]
		source.dimension = pos[ 3 ]
		SAVED_POSITIONS[ source ] = nil
	end
end )