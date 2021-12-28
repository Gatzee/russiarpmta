loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SInterior" )
Extend( "SDB" )

BOARD_DATA = {}

addEventHandler("onResourceStart", resourceRoot, function()
	DB:createTable("nrp_faction_boards", { 
	    { Field = "id",			Type = "int(11) unsigned",			Null = "NO",	Key = "",			Default = 0 };
	    { Field = "message",	Type = "text",						Null = "YES",	Key = "",			Default = NULL };
	    { Field = "ads",		Type = "text",						Null = "YES",	Key = "",			Default = NULL };
	}) 

	for k,v in pairs(BOARDS_LIST) do
		CreateBoard( v )
	end

	LoadBoardsData()
end)

addEventHandler("onResourceStop", resourceRoot, function()
	for k,v in pairs(BOARD_DATA) do
		--SaveBoard(v)
	end
end)

function CreateBoard( config )
	config.accepted_elements = { player = true }
	config.radius = 1.5
	config.marker_text = config.title or "Информация"
	config.keypress = "lalt"
	config.text = "ALT Взаимодействие"
	local board = TeleportPoint(config)
	board.element:setData( "material", true, false )
	board:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 50, 200, 255, 1.2 } )
	board.element:setData("ignore_dist", true)
	board.marker:setColor(0,50,200,50)
	board.id = config.faction

	board.PostJoin = function(board, player)
		local faction_id = player:GetFaction()

		local board_data = 
		{
			id = BOARD_DATA[board.id].id,
			message = BOARD_DATA[board.id].message,
			ads = BOARD_DATA[board.id].ads,
		}

		local data = 
		{
			board = board_data,
			is_faction = faction_id and faction_id == BOARD_DATA[board.id].id,
			is_leader = faction_id and faction_id == BOARD_DATA[board.id].id and player:IsHasFactionControlRights( ),
			is_level_3 = faction_id and faction_id == BOARD_DATA[board.id].id and player:GetFactionLevel() >= 3,
		}
		triggerClientEvent(player, "FB:ShowUI", resourceRoot, true, data)	
	end

	board.PostLeave = function(board, player)
		triggerClientEvent(player, "FB:ShowUI", resourceRoot, false) 
	end

	if not BOARD_DATA[config.faction] then
		BOARD_DATA[config.faction] = { id = config.faction, element = board, message = {}, ads = {} }
	end
end

function LoadBoardsData()
	DB:queryAsync(function(query)
		local result = dbPoll(query, 0)
		if not result or #result <= 0 then
	        return
	    end

		for k,v in pairs(result) do
			if BOARD_DATA[v.id] then
				BOARD_DATA[v.id].message = v.message and fromJSON(v.message) or {}
				BOARD_DATA[v.id].ads = v.ads and FixTableKeys( fromJSON(v.ads) ) or {}
			end
	    end
	end,{}, "SELECT * FROM nrp_faction_boards")
end

function SaveBoard( data )
	if data then
		DB:queryAsync(function(query, data)
			local result = dbPoll(query, 0)
			if result and #result >= 1  then
				DB:exec("UPDATE nrp_faction_boards SET message = ?, ads = ? WHERE id = ?", data.message and toJSON(data.message), data.ads and toJSON(data.ads), data.id )
			else
				DB:exec("INSERT INTO nrp_faction_boards (id, message, ads) VALUES (?,?,?)", data.id, data.message and toJSON(data.message), data.ads and toJSON(data.ads) )
		    end
		end,{data}, "SELECT id FROM nrp_faction_boards WHERE id = ?", data.id)
	end
end

function OnPlayerUpdateDailyMessage( board_id, msg, time )
	if not isElement(client) then return end
	if not BOARD_DATA[board_id] then return end
	
	local faction_id = client:GetFaction()

	if not client:IsHasFactionControlRights( ) then
		client:ShowError("Изменять это сообщение может только лидер и его заместители!")
		return false
	end

	local pBoard = BOARD_DATA[board_id]
	local time = time or 24*60*60

	pBoard.message = 
	{
		text = msg,
		updated = getRealTime().timestamp,
		expires = getRealTime().timestamp + time,
		name = client:GetNickName(),
		user = client:GetUserID(),
	}

	client:ShowSuccess("Повестка дня обновлена")
	ForceSync(client, board_id)

	SaveBoard( pBoard )

	for k,v in pairs(getElementsByType("player")) do
		if v:GetFaction() == faction_id then
			v:ShowInfo("Повестка дня обновлена, ознакомьтесь с ней у доски объявлений")
		end
	end
end
addEvent("OnPlayerUpdateDailyMessage", true)
addEventHandler("OnPlayerUpdateDailyMessage", root, OnPlayerUpdateDailyMessage)

function OnPlayerAdsAction( board_id, sAction, data )
	if not isElement(client) then return end
	if not BOARD_DATA[board_id] then return end

	local pAds = BOARD_DATA[board_id].ads or {}
	local faction_id = client:GetFaction()

	if client:GetFactionLevel() < 3 then
		client:ShowError("Размещать объявления можно только с третьего уровня во фракции!")
		return false
	end

	if sAction == "add" then
		for k,v in pairs(pAds) do
			if v.user == client:GetUserID() then
				client:ShowError("Нельзя разместить здесь больше одного объявления")
				return false
			end
		end

		local ad_body = 
		{
			msg = data.msg,
			user = client:GetUserID(),
			name = client:GetNickName(),
			updated = getRealTime().timestamp,
			expires = getRealTime().timestamp + ( data.time or 24*60*60 ),
		}

		table.insert(pAds, ad_body)

		client:ShowSuccess("Объявление успешно добавлено!")
		ForceSync(client, board_id)
		SaveBoard( BOARD_DATA[board_id] )
	elseif sAction == "edit" then
		local ad_body = pAds[ data.id ]
		if not ad_body then
			client:ShowError("Объявление не найдено")
			return false
		end

		if ad_body.user ~= client:GetUserID() then
			if not client:IsHasFactionControlRights( ) then
				client:ShowError("Нельзя редактировать чужие объявления")
				return false
			end
		end

		ad_body.msg = data.msg
		ad_body.updated = getRealTime().timestamp
		ad_body.last_edit = client:GetNickName()

		client:ShowSuccess("Объявление успешно отредактировано!")
		ForceSync(client, board_id)
		SaveBoard( BOARD_DATA[board_id] )
	elseif sAction == "remove" then
		local ad_body = pAds[ data.id ]
		if not ad_body then
			client:ShowError("Объявление не найдено")
			return false
		end

		if ad_body.user ~= client:GetUserID() then
			if not client:IsHasFactionControlRights( ) then
				client:ShowError("Нельзя убирать чужие объявления")
				return false
			end
		end

		if not table.remove( pAds, data.id ) then
			pAds[ data.id ] = nil
		end

		client:ShowSuccess("Объявление успешно удалено!")
		ForceSync(client, board_id)
		SaveBoard( BOARD_DATA[board_id] )
	end
end
addEvent("OnPlayerAdsAction", true)
addEventHandler("OnPlayerAdsAction", root, OnPlayerAdsAction)

function ForceSync( player, iBoard )
	local faction_id = player:GetFaction()

	local board_data = 
	{
		id = BOARD_DATA[iBoard].id,
		message = BOARD_DATA[iBoard].message,
		ads = BOARD_DATA[iBoard].ads,
	}

	local data = 
	{
		board = board_data,
		is_faction = faction_id and faction_id == BOARD_DATA[iBoard].id,
		is_leader = faction_id and player:IsHasFactionControlRights( ),
		is_level_3 = faction_id and player:GetFactionLevel() >= 3,
	}
	triggerClientEvent(player, "FB:ForceSync", resourceRoot, data)	
end