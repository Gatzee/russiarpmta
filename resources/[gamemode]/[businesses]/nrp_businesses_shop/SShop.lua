Extend( "Globals" )
Extend( "SPlayer" )

function PlayerWantBuyItem_handler( type, index )
	if not client then return end

	if not SHOP_ITEMS[ type ] then return end

	local item = SHOP_ITEMS[ type ][ index ]
	if not SHOP_ITEMS[ type ] then return end

	if #exports.nrp_businesses:GetOwnedBusinesses( client ) < 1 then
		client:ErrorWindow( "Ты не бизнесмен!" )
		return
	end

	if not client:HasMoney( item.cost ) then
		client:ErrorWindow( "Недостаточно денег!" )
		return
	end

	if type == "skins" then
		if client:HasSkin( item.id ) then
			client:ErrorWindow( "Ты уже купил эту одежду!" )
			return
		end

		client:GiveSkin( item.id )
		client:InfoWindow( "Одежда успешно приобретёна и добавлена в гардероб!" )

		triggerEvent( "OnBusinessShopBuyItem", client, item.cost, type .. item.id )

	elseif type == "secretary" then
		local office_data = client:GetPermanentData( "office_data" )
		if not office_data then
			client:ShowError( "У тебя нет офиса" )
			return
		end

		office_data.secretary = item.id
		client:SetPermanentData( "office_data", office_data )
		client:InfoWindow( "Ты успешно нанял новую секретаршу!" )

		triggerEvent( "RequestOfficeReEnterPlayers", root, client )
		triggerEvent( "OnBusinessShopBuyItem", client, item.cost, type .. item.id )

	elseif type == "office" then
		local office_data = client:GetPermanentData( "office_data" )
		if not office_data then
			office_data = {
				deposit = 0;
				secretary = nil;
			}
		end

		office_data.class = item.id
		office_data.cost_buy = item.cost
		office_data.last_pay = getRealTime( ).timestamp + ( 3600 * 24 )

		client:SetPermanentData( "office_data", office_data )
		client:InfoWindow( "Ты успешно приобрел офис!" )

		triggerEvent( "RequestOfficeReEnterPlayers", root, client )
		triggerEvent( "OnBusinessShopBuyOffice", client, office_data.cost_buy, "office".. office_data.class, false )

		triggerClientEvent( client, "ToggleGPS", client, { x = 2134.796, y = 2602.605, z = 8.312 } )
	end

	client:TakeMoney( item.cost, "business_shop", "business_shop_purchase" )

	WriteLog(
        "businesses_shop",
        "[Покупка предмета] %s [TYPE:%s] [ID:%s] [COST:%s]",
        client, type, item.id, item.cost
    )
end
addEvent( "PlayerWantBuyItem", true )
addEventHandler( "PlayerWantBuyItem", resourceRoot, PlayerWantBuyItem_handler )