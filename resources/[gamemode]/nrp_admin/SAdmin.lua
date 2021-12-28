loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SVehicle")
Extend("ShVehicleConfig")
Extend("SPlayer")
Extend("SDB")
Extend( "SUtils" )

function InitUI()
	-- Проверяем права
	local iAccessLevel = client:GetAccessLevel()
	local sAccount = getAccountName(getPlayerAccount(client))
	local bACLRights = isObjectInACLGroup( "user."..sAccount, aclGetGroup( "Admin" ) )

	if iAccessLevel >= 1 or bACLRights then
		triggerClientEvent( client, "AP:InitUI", resourceRoot, iAccessLevel, bACLRights )
	end
end
addEvent("AP:InitUI", true)
addEventHandler("AP:InitUI", root, InitUI)

function ExecuteCommand( cmd, ... )
	local args = {...}
	local str = table.concat(args, " ")
	executeCommandHandler( cmd, client or source, str )
end
addEvent("AP:ExecuteCommand", true)
addEventHandler("AP:ExecuteCommand", root, ExecuteCommand)

-- Player Info

function OnPlayersInformationRequested( sKey, sValue )
	local sValue = tonumber(sValue) or sValue

	if sKey == "name" then
		sValue = "%"..sValue.."%"
	end

	local query_list = 
	{
		id = "SELECT * FROM nrp_players WHERE id=?",
		name = "SELECT * FROM nrp_players WHERE nickname LIKE ?",
		serial = "SELECT * FROM nrp_players WHERE reg_serial = ? OR last_serial = ?",
		ip = "SELECT * FROM nrp_players WHERE reg_ip = ? OR last_ip = ?",
		client_id = "SELECT * FROM nrp_players WHERE client_id = ?",
	}

	DB:queryAsync(function( query, admin )
		if not query then return end
		if not isElement( admin ) then 
			dbFree( query )
			return 
		end

		local data = dbPoll( query, 0 )
		if type(data) ~= "table" or #data < 1 then return end

		local pListToSend = {}

		for k,v in pairs(data) do
			local row = 
			{
				id = v.id,
				nickname = v.nickname,
				ip = v.last_ip,
				serial = v.last_serial,
			}

			table.insert(pListToSend, row)
		end

		triggerClientEvent( admin, "AP:ReceivePlayersList", resourceRoot, pListToSend )
	end, { client }, query_list[sKey], sValue, sValue)
end
addEvent("AP:OnPlayersInformationRequested", true)
addEventHandler("AP:OnPlayersInformationRequested", root, OnPlayersInformationRequested)

function OnPlayerInformationRequested( sID )
	local pTarget = GetPlayer( sID, true )

	DB:queryAsync(GetPlayerDatabaseInformation, { client, pTarget }, "SELECT * FROM nrp_players WHERE id=? LIMIT 1", sID)
end
addEvent("AP:OnPlayerInformationRequested", true)
addEventHandler("AP:OnPlayerInformationRequested", root, OnPlayerInformationRequested)

function GetPlayerDatabaseInformation( query, pAdmin, pTarget )
	if not query then return end
	if not isElement( pAdmin ) then
		dbFree( query )
		return 
	end

	local data = dbPoll(query, 0)
	if type(data) ~= "table" or #data < 1 then return end

	if data[1] then data = data[1] end

	local pFieldsToSend = { "id", "nickname", "exp", "level", "donate", "money", "skin", "gender", 
	"reg_serial", "last_serial", "reg_ip", "last_ip", "reg_date", "last_date", "playing_time", "muted", "banned", "accesslevel", 
	"faction_id", "faction_level" }

	local pToSend = {}

	for k,v in pairs(pFieldsToSend) do
		pToSend[v] = data[v] or "?"
	end

	pToSend.licenses = data.licenses and fromJSON( data.licenses ) or {}
	pToSend.banned_serials = data.banned_serials and fromJSON( data.banned_serials ) or {}
	pToSend.permanent_data = data.permanent_data and fromJSON( data.permanent_data ) or {}
	pToSend.banned = data.banned and data.banned > 0 and data.banned - getRealTime().timestamp or 0
	pToSend.muted = data.muted and data.muted > 0 and data.muted - getRealTime().timestamp or 0
	pToSend.clan_id = data.clan_id
	pToSend.clan_level = data.clan_rank
	pToSend.military_date = pToSend.permanent_data.military_date

	-- Target is currently online
	if isElement(pTarget) then
		pToSend.nickname = pTarget:GetNickName()
		pToSend.money = pTarget:GetMoney()
		pToSend.level = pTarget:GetLevel()
		pToSend.exp = pTarget:GetExp()
		pToSend.skin = pTarget.model
		pToSend.donate = pTarget:GetDonate()
		pToSend.online = true
		pToSend.accesslevel = pTarget:GetAccessLevel()
		pToSend.faction_id = pTarget:GetFaction()
		pToSend.faction_level = pTarget:GetFactionLevel()
		pToSend.clan_id = pTarget:GetClanID()
		pToSend.clan_level = pTarget:GetClanRank()

		local iMuted = pTarget:GetPermanentData("muted")
		pToSend.muted = iMuted and iMuted > 0 and iMuted - getRealTime().timestamp or 0
	end

	pToSend.vehicles = {}

	-- Looking for vehicles
	DB:queryAsync(
		function( query, pAdmin, pToSend )
			if not isElement( pAdmin ) then
				dbFree( query )
				return 
			end

			local result = query:poll( -1 )
			if type ( result ) == "table" and #result >= 0 then
				for i, veh in pairs(result) do
					local tab = 
					{
						id = veh.id,
						model = veh.model,
						number_plate = veh.number_plate,
					}

					if tonumber(veh.owner_pid) and tonumber(veh.owner_pid) < 0 then
						tab.deleted = { veh.deleted, veh.comment }
					end

					table.insert( pToSend.vehicles, tab )
				end
			end
			triggerClientEvent( pAdmin, "AP:ReceivePlayerInformation", resourceRoot, pToSend )
		end, { pAdmin, pToSend },
		"SELECT id, model, number_plate, deleted, comment, owner_pid FROM nrp_vehicles WHERE owner_pid=? OR owner_pid=?", "p:"..pToSend.id, -tonumber(pToSend.id)
	)
end

-- Banlist

function OnPlayerRequestBanlist(  )
	local function GetBanlist( query, pAdmin )
		if not query then return end
		if not isElement( pAdmin ) then
			dbFree( query )
			return 
		end

		local data = dbPoll(query, 0)
		if type(data) ~= "table" then return end

		local pBans = getBans()
		for i, ban in pairs(pBans) do
			for k, player in pairs(data) do
				if player.last_serial == ban.serial then
					data[k].admin = ban.admin
					data[k].reason = ban.reason
					data[k].time = ban.time
				end
			end
		end

		triggerClientEvent( pAdmin, "AP:ReceiveBanlist", resourceRoot, data )
	end

	DB:queryAsync(GetBanlist, { client }, "SELECT id, nickname, banned, banned_serials, last_serial  FROM nrp_players WHERE banned > ?", getRealTime().timestamp)
end
addEvent("AP:OnPlayerRequestBanlist", true)
addEventHandler("AP:OnPlayerRequestBanlist", root, OnPlayerRequestBanlist)

-- Account Manager

function OnAccountsListRequest(queryHandler, pPlayer)
	local result = dbPoll ( queryHandler, 0 )
    if type ( result ) ~= "table"  then
        return
    end

    if not isElement(pPlayer) then
        return
    end

    local sAccountName = getAccountName(getPlayerAccount(pPlayer))

    triggerClientEvent(pPlayer,"AP:ReceiveAccountsList",resourceRoot,result,sAccountName)
end

function UpdateAccountsList(pPlayer)
	local pPlayer = pPlayer or client
	local sAccountName = getAccountName(getPlayerAccount(pPlayer))
    local iUserID = pPlayer:GetUserID() or -1
	DB:queryAsync(OnAccountsListRequest, { pPlayer }, 
	"SELECT id, nickname, client_id FROM nrp_players WHERE id = '"..iUserID.."' OR client_id = '"..sAccountName.."'")
end

addEvent("AP:UpdateAccountsList", true)
addEventHandler("AP:UpdateAccountsList", root, UpdateAccountsList)

function SwitchAccount(pPlayer,iUserID)
    local iCurrentUserID = pPlayer:GetUserID() or -1
    local sCurrentClientID = pPlayer:GetClientID()
    local sAccountName = getAccountName(getPlayerAccount(pPlayer))

    DB:exec("UPDATE nrp_players SET client_id = ? WHERE id = ? LIMIT 1",sAccountName,iCurrentUserID)
    DB:exec("UPDATE nrp_players SET client_id = ? WHERE id = ? LIMIT 1",sCurrentClientID,iUserID)

    outputChatBox("Аккаунт успешно переключен, перезайдите.",pPlayer,50,200,50)
end

function DeleteAccount(pPlayer,iUserID)
    local iCurrentUserID = pPlayer:GetUserID()

    if iUserID == iCurrentUserID then
        outputChatBox("Вы не можете удалить свой текущий аккаунт!",pPlayer,200,50,50)
        return false
    end

    DB:exec("DELETE FROM nrp_players WHERE id = ? LIMIT 1",iUserID)

    outputChatBox("Аккаунт удалён",pPlayer,50,200,50)
end

function StashAccount(pPlayer)
    local iCurrentUserID = pPlayer:GetUserID()
    local sAccountName = getAccountName(getPlayerAccount(pPlayer))

    DB:exec("UPDATE nrp_players SET client_id = ? WHERE id = ? LIMIT 1",sAccountName,iCurrentUserID)
    
    outputChatBox("Аккаунт успешно отвязан, перезайдите.",pPlayer,50,200,50) 
end

addEvent("AP:AccountActionAttempt",true)
addEventHandler("AP:AccountActionAttempt",root,function(iAction,iUserID)
    if iUserID then
        iUserID = tonumber(iUserID)
    end

    if iAction == 1 then
        DeleteAccount(client,iUserID)
    elseif iAction == 2 then
        StashAccount(client)
    elseif iAction == 3 then
        SwitchAccount(client,iUserID)
    end
end)

-- Admins List

function OnAdminsListRequest(queryHandler, pPlayer)
	local result = dbPoll ( queryHandler, 0 )
    if type ( result ) ~= "table"  then
        return
    end

    if not isElement(pPlayer) then
        return
    end

    local pVisibleResult = {}
    local iAccessLevel = pPlayer:GetAccessLevel()

	if iAccessLevel >= ACCESS_LEVEL_DEVELOPER then
		pVisibleResult = result
	else
		for k,v in pairs(result) do
			if v.accesslevel <= iAccessLevel then
				table.insert(pVisibleResult, v)
			end
	    end
	end
	
	for i, data in pairs( pVisibleResult ) do
		local admin_data = data.admin_data and fromJSON( data.admin_data ) or {}
		local worked_time = admin_data.worked_time
		data.worked_time = worked_time and ( worked_time.month.time + worked_time.session ) or 0
		data.tasks_completed = 0
		if admin_data.tasks then
			for task_id, task in pairs( admin_data.tasks ) do
				if task.completed then
					data.tasks_completed = data.tasks_completed + 1
				end
			end
		end
		data.rating = admin_data.rating and admin_data.rating.total or 0
		data.payout = data.admin_payout
		data.admin_data = nil
	end
	
    triggerClientEvent( pPlayer, "AP:ReceiveAdminsList", resourceRoot, pVisibleResult )
end

function UpdateAdminsList(pPlayer)
	local pPlayer = pPlayer or client
	DB:queryAsync( OnAdminsListRequest, { pPlayer }, 
		"SELECT id, nickname, accesslevel, admin_data, admin_payout FROM nrp_players WHERE accesslevel > 0"
	)
end

addEvent("AP:UpdateAdminsList", true)
addEventHandler("AP:UpdateAdminsList", root, UpdateAdminsList)

function SetAdminRightsLevel( iUserID, iLevel )
	local pPlayer = GetPlayer( iUserID, true )
	if pPlayer then
		pPlayer:SetAccessLevel(iLevel)
	else
		DB:queryAsync( function( query )
			local result = query:poll( -1 )
			if not result or not result[ 1 ] then return end
			onPlayerAccessLevelChange_ratingHandler( result[ 1 ].accesslevel or 0, iLevel or 0 )
		end, { }, "SELECT accesslevel FROM nrp_players WHERE id = ?", iUserID )
	end

	DB:exec( "UPDATE nrp_players SET accesslevel = ?, check_serial = 1 WHERE id = ?", iLevel, iUserID )
end

addEvent("AP:RightsActionAttempt",true)
addEventHandler("AP:RightsActionAttempt",root,function(iAction,iUserID,...)
	local iSourceUserID = client:GetUserID()
    local iUserID = tonumber(iUserID)

	if iUserID == iSourceUserID then
		client:ShowError("Вы не можете изменить собственный уровень доступа!")
		return false
	end

	local args = { ... }

	local client = client
	
	local function ContinueSearchingTarget( iTargetAccessLevel )
		if not isElement( client ) then return end

		if iTargetAccessLevel >= client:GetAccessLevel() then
			client:ShowError("Уровень доступа цели выше вашего!")
			return false
		end

		if iAction == 1 then
			SetAdminRightsLevel( iUserID, 0 )
		elseif iAction == 2 then
			local access_level = client:GetAccessLevel()		

			if access_level ~= 9 and args[1] <= access_level then
				SetAdminRightsLevel( iUserID, args[1] )
			elseif access_level == 9 and args[1] < access_level then
				SetAdminRightsLevel( iUserID, args[1] )
			else
				client:ShowError("Вы не можете присвоить уровень прав выше собственного!")
			end
		elseif iAction == 3 then
			SetAdminRightsLevel( iUserID, 1 )
		end

		UpdateAdminsList(client)
	end

    local iTargetAccessLevel = 0
    local pPlayer = GetPlayer( iUserID, true )
	if pPlayer then
		iTargetAccessLevel = pPlayer:GetAccessLevel()
		ContinueSearchingTarget( iTargetAccessLevel )
	else
		DB:queryAsync(
			function( query )
				local result = query:poll( -1 )
				if result and result[1] then
					iTargetAccessLevel = result[1].accesslevel
				end
				ContinueSearchingTarget( iTargetAccessLevel )
			end, { },
			"SELECT accesslevel FROM nrp_players WHERE id=? LIMIT 1", iUserID
		)
	end
end)

function OnFactionsMembersListRequest( iFactionID )
	local function GetFactionMembers( query, pAdmin, iFactionID )
		if not query then return end
		if not isElement( pAdmin ) then
			dbFree( query )
			return 
		end

		local data = dbPoll(query, 0)
		if type(data) ~= "table" then return end

		for k,v in pairs(data) do
			local pPlayer = GetPlayer(v.id, true)
			if isElement(pPlayer) then
				v.faction_id = pPlayer:GetFaction()
				v.faction_level = pPlayer:GetFactionLevel()
				v.faction_exp = pPlayer:GetFactionExp()
			end
		end

		triggerClientEvent( pAdmin, "AP:ReceiveFactionMembers", resourceRoot, iFactionID, data )
	end

	DB:queryAsync(GetFactionMembers, { client, iFactionID }, "SELECT id, nickname, faction_id, faction_level, faction_exp, faction_warns FROM nrp_players WHERE faction_id = ?", iFactionID)
end
addEvent("AP:OnFactionsMembersListRequest", true)
addEventHandler("AP:OnFactionsMembersListRequest", root, OnFactionsMembersListRequest)

function OnPlayerApplyFactionAction( sAction, data )
	local pTarget = GetPlayer(data.uid, true)

	if sAction == "setrank" then
		data.value = math.max(1, math.min(data.value, FACTION_OWNER_LEVEL))
		if isElement(pTarget) then
			triggerEvent("AP:ExecuteCommand", client, "setfactionlevel", pTarget:GetID(), data.value)
		else
			triggerEvent("AP:ExecuteCommand", client, "offsetfactionlevel", data.uid, data.value)
		end
	elseif sAction == "giveexp" then
		if isElement(pTarget) then
			pTarget:GiveFactionExp( data.value )
		else
			DB:exec( "UPDATE nrp_players SET faction_exp = ? WHERE id = ? LIMIT 1", data.oldvalue+data.value, data.uid )
		end
	elseif sAction == "remove" then
		if isElement(pTarget) then
			triggerEvent("AP:ExecuteCommand", client, "setfaction", pTarget:GetID(), 0)
		else
			triggerEvent("AP:ExecuteCommand", client, "offsetfaction", data.uid, 0)
		end
	end
end
addEvent("AP:OnPlayerApplyFactionAction", true)
addEventHandler("AP:OnPlayerApplyFactionAction", root, OnPlayerApplyFactionAction)

function OnAdminRequestPlayerData( pPlayer )
	if isElement(pPlayer) then
		local data = {}
		data.element = pPlayer
		data.muted = pPlayer.muted
		data.frozen = pPlayer.frozen
		data.immortal = pPlayer:IsImmortal()
		data.jailed = pPlayer:getData("jailed")
		data.clan_banned = pPlayer:GetPermanentData("clan_banned")
		data.rating = pPlayer:GetSocialRating()

		triggerClientEvent( client, "AP:ReceivePlayerData", resourceRoot, data )
	end
end
addEvent("AP:RequestPlayerData", true)
addEventHandler("AP:RequestPlayerData", root, OnAdminRequestPlayerData)

function ChangeAdminPayout( user_id, new_value )
	if client:GetAccessLevel( ) < ACCESS_LEVEL_SUPERVISOR then return end

	if client:GetUserID( ) == user_id then
		client:ShowError( "Вы не можете изменить собственную зарплату!" )
		return false
	end

	local client = client
	
	local function ContinueSearchingTarget( target_access_level )
		if not isElement( client ) then return end

		if target_access_level >= client:GetAccessLevel( ) then
			client:ShowError( "Уровень доступа цели выше вашего!" )
			return false
		end

		local payout_info = ADMIN_PAYOUT_INFO[ target_access_level ]
		if not payout_info then
			client:ShowError( "Для этого уровня доступа нельзя назначить зарплату" )
			return false
		end

		local min = payout_info.value - 20
		local max = payout_info.value * 2
		if new_value < min or new_value > max then
			client:ShowError( "Значение должно быть от " .. min .. " до " .. max )
			return false
		end

		local target = GetPlayer( user_id )
		if target then
			target:SetPermanentData( "admin_payout", new_value )
		else
			DB:exec( "UPDATE nrp_players SET admin_payout = ? WHERE id=? LIMIT 1", new_value, user_id )
		end

		UpdateAdminsList( client )
	end

    local target = GetPlayer( user_id )
	if target then
		ContinueSearchingTarget( target:GetAccessLevel() )
	else
		DB:queryAsync(
			function( query )
				local result = query:poll( -1 )
				if result and result[ 1 ] then
					ContinueSearchingTarget( result[ 1 ].accesslevel )
				end
			end, { },
			"SELECT accesslevel FROM nrp_players WHERE id=? LIMIT 1", user_id
		)
	end
end
addEvent( "AP:ChangeAdminPayout", true )
addEventHandler( "AP:ChangeAdminPayout", root, ChangeAdminPayout )
