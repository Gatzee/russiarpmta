loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "SPlayer" )
Extend( "ShAccessories" )
Extend( "ShSkin" )

local SAVED_POSITIONS = { }

function PlayerWantShowUIWardrobe_handler( show_state, id, number )	
	if show_state then
		if source:IsInEventLobby( ) then return end

		local player_gender_skin_list = {}
		local player_gender = source:GetGender()
		for k, v in pairs( source:GetSkins( ) ) do
			if SKINS_GENDERS[ v ] == player_gender then
				player_gender_skin_list[ k ] = v
			end
		end

		source:triggerEvent( "ReceiveShowUIWardrobeData", resourceRoot, id, number, player_gender_skin_list, source:GetOwnedAccessories( ), source:GetAccessories( ) )

		source:CompleteDailyQuest( "visit_wardrobe" )
	end

	SAVED_POSITIONS[ source ] = show_state and source.position or nil

	source:setData( "is_in_wardrobe", show_state, false )
end
addEvent( "PlayerWantShowUIWardrobe", true )
addEventHandler( "PlayerWantShowUIWardrobe", root, PlayerWantShowUIWardrobe_handler )

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
end
addEvent( "PlayerWantUseSkin", true )
addEventHandler( "PlayerWantUseSkin", resourceRoot, PlayerWantUseSkin_handler )

function PlayerWantChangeAccessoriesSlot_handler( model, slot, accessory_id, position, rotation, scale )
	if not client then return end
	if not model then return end

	model = tonumber( model )

	local accessories = client:GetAccessories( model )
	if slot then
		if accessory_id then
			local info = CONST_ACCESSORIES_INFO[ accessory_id ]
			if not info then return end

			if not client:GetOwnedAccessories( )[ accessory_id ] and not ( info.premium and client:IsPremiumActive( ) ) then return end

			accessories[ slot ] = {
				id = accessory_id;

				position = position;
				rotation = rotation;
				scale = scale;
			}
		else
			accessories[ slot ] = nil
		end
	else
		accessories = { }
	end

	client:SetAccessories( accessories, model )
end
addEvent( "PlayerWantChangeAccessoriesSlot", true )
addEventHandler( "PlayerWantChangeAccessoriesSlot", resourceRoot, PlayerWantChangeAccessoriesSlot_handler )

function CheckPlayerSkinsInInventory( player )
    player = source or player

	local item_container = player:InventoryGetItem( IN_CLOTHES )
	for i = 2, #item_container do
		local skin_model = item_container[ i ].attributes[ 1 ]
		player:GiveSkin( skin_model )
	end

	player:InventoryRemoveItem( IN_CLOTHES )
end
addEventHandler( "onPlayerReadyToPlay", root, CheckPlayerSkinsInInventory )

addEventHandler( "onPlayerPreLogout", root, function( )
	if SAVED_POSITIONS[ source ] then
		source.position = SAVED_POSITIONS[ source ]
		SAVED_POSITIONS[ source ] = nil
	end
end )