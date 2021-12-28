function onViphouseWardrobeEnter_handler( id )
	local house_owner = GetVipHouseKeyByID( id, "owner" )
	if house_owner == source:GetUserID( ) or house_owner == source:GetPermanentData( "wedding_at_id" ) then
		if ( GetVipHouseKeyByID( id, "paid_days" ) or 0 ) < 0 then
			source:ShowInfo( "Оплати долг за дом!" )
			return
		end
		setPedWeaponSlot( source, 0 )
		triggerEvent( "PlayerWantShowUIWardrobe", source, true, 0, id )
	else
		source:ShowInfo( "Это не твой гардероб" )
	end
end
addEvent( "onViphouseWardrobeEnter", true )
addEventHandler( "onViphouseWardrobeEnter", root, onViphouseWardrobeEnter_handler )

function onViphouseCookingEnter_handler( id )
	local house_owner = GetVipHouseKeyByID( id, "owner" )
	if house_owner == source:GetUserID( ) or house_owner == source:GetPermanentData( "wedding_at_id" ) then
		if ( GetVipHouseKeyByID( id, "paid_days" ) or 0 ) < 0 then
			source:ShowInfo( "Оплати долг за дом!" )
			return
		end
		triggerEvent( "onPlayerWantShowCookingUI", source )
	else
		source:ShowInfo( "Ты не можешь готовить еду в чужом доме" )
	end
end
addEvent( "onViphouseCookingEnter", true )
addEventHandler( "onViphouseCookingEnter", root, onViphouseCookingEnter_handler )


function onCheckCanGuestAccessToVillage_handler( id, is_approved, player_id )
	if not isElement( client ) then return end

    local hid = VIP_HOUSES[ id ].hid

	if is_approved then
		local player = GetPlayer( player_id )
		if player and player:IsInGame() then
			player:ShowInfo( "Владелец виллы одобрил ваш запрос." )
			player:SetPrivateData( "in_villa", hid )
		end

	elseif is_approved == false then
		local player = GetPlayer( player_id )
		if player and player:IsInGame() then
			player:ShowInfo( "Владелец виллы запретил вам доступ." )
			player:SetPrivateData( "in_villa", false )
		end

	else
		local house_owner_id = GetVipHouseKeyByID( id, "owner" )
		if not house_owner_id then
			client:ShowInfo( "У этого дома нету владельца." )
			return

		elseif house_owner_id == client:GetUserID( ) then
			client:ShowInfo( "Вы владелец виллы, попробуйте еще раз." )
			client:SetPrivateData( "in_villa", hid )
			return

		elseif house_owner_id == client:GetPermanentData( "wedding_at_id" ) then
			client:ShowInfo( "Вы совладелец виллы, попробуйте еще раз." )
			client:SetPrivateData( "in_villa", hid )
			return
		end

        local house_owner = GetPlayer( house_owner_id )

        if not isElement( house_owner ) or not house_owner:IsInGame( ) then
            client:ShowInfo( "Владелец виллы вышел из игры." )
            return
        end

		local distance = getDistanceBetweenPoints3D( house_owner.position, client.position )

		if distance < 30 and house_owner.dimension == client.dimension and house_owner.interior == client.interior then
			triggerClientEvent( house_owner, "onPlayerAskAccessToVillage", resourceRoot, id, client:GetNickName( ), client:GetUserID( ) )
		else
			client:ShowInfo( "Владельца виллы нету поблизости." )
		end
	end
end
addEvent( "onCheckCanGuestAccessToVillage", true )
addEventHandler( "onCheckCanGuestAccessToVillage", resourceRoot, onCheckCanGuestAccessToVillage_handler )
