loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SDB")
Extend("ShUtils")
Extend("SPlayer")

local REWARDS = 
{
	[2] = 
	{
		pSource = { money = 3000 },
		pTarget = { money = 5000 },
	},

	[6] = 
	{
		pSource = { money = 15000, exp = 400 },
		pTarget = { money = 10000, exp = 400 },
	},

	[8] = 
	{
		pSource = { money = 20000 },
		pTarget = { money = 25000 },
	},

	[10] = 
	{
		pSource = { donate = 30 },
		pTarget = { },
	},

	[24] = 
	{
		pSource = { },
		pTarget = { donate = 100 },
	},
}

local SYMBOLS = 
{ 
	{ "a", "b", "c", "d", "e", "g", "j", "k", "m", "n", "p", "q", "r", "s", "t", "u", "v" },
	{ "w", "y", "z", "f", "h" },
}

local function symb( index )
	local index = index or 1
	return string.upper( SYMBOLS[index][math.random(1, #SYMBOLS[index])] )
end

function GenerateCodeByUserID( iUserID )
	local sCode = ""
	local pNumbers = {}
	for i = 1, 6 do
		local symbol = string.sub( tostring(iUserID), i, i )
		pNumbers[i] = symbol and symbol == "" and symb(2) or symbol
	end

	-- TOTAL LEN = 9
	-- FORMAT: X00X00X00

	sCode = symb()..pNumbers[1]..pNumbers[2]..symb()..pNumbers[3]..pNumbers[4]..symb()..pNumbers[5]..pNumbers[6]

	return sCode
end

function GetUIDFromCode( sCode )
	local sUID = ""


	local custom_codes = MariaGet("ref_codes")
	if custom_codes then
		custom_codes = fromJSON(custom_codes)
	end

	if custom_codes and custom_codes[sCode] then
		return custom_codes[sCode], true
	end

	for i= 1, 9 do
		local symbol = string.sub(sCode, i, i)
		if tonumber(symbol) then
			sUID = sUID..symbol
		end
	end

	return tonumber(sUID)
end

function OnPlayerLogin()
	if isElement(source) then
		local sCurrentCode = source:GetPermanentData("ref_code")
		if not sCurrentCode then
			source:SetPermanentData("ref_code", GenerateCodeByUserID( source:GetUserID() ) )
		end
	end
end
addEvent("onPlayerReadyToPlay", true)
addEventHandler("onPlayerReadyToPlay", root, OnPlayerLogin)

function OnPlayerLevelUp( level )
	if REWARDS[level] then
		local iRefferer = source:GetPermanentData("refferer")
		iRefferer = tostring( iRefferer ) ~= "0" and iRefferer
		if iRefferer then

			local updated_rewards = source:GetPermanentData("ref_rewards") or {}
			for k,v in pairs(REWARDS[level].pTarget) do
				updated_rewards[k] = (updated_rewards[k] or 0) + v
			end

			source:SetPermanentData("ref_rewards", updated_rewards)

			local pPlayer = GetPlayer( iRefferer, true )
			if pPlayer then
				-- ONLINE
				local updated_rewards = pPlayer:GetPermanentData("ref_rewards") or {}

				for k,v in pairs(REWARDS[level].pSource) do
					updated_rewards[k] = (updated_rewards[k] or 0) + v 
				end

				if level == 5 then
					pPlayer:SetPermanentData("total_refferals", (pPlayer:GetPermanentData("total_refferals") or 0) + 1)

					local total_refferals = pPlayer:GetPermanentData("total_refferals")
					if total_refferals == 5 then
						updated_rewards.premium = (updated_rewards.premium or 0) + 1
					elseif total_refferals == 20 then
						updated_rewards.premium = (updated_rewards.premium or 0) + 1
					end
				end

				pPlayer:SetPermanentData("ref_rewards", updated_rewards)

				pPlayer:ShowSuccess("Вы получили бонусы за достижение "..source:GetNickName().." "..level.." уровня!")
			else
				-- OFFLINE
				DB:queryAsync(function(queryHandler, iRefferer)
					local result = dbPoll(queryHandler,0)
					if type ( result ) ~= "table" or #result == 0 then
			    		return
			   		end

			   		local updated_rewards = result[1].ref_rewards and fromJSON(result[1].ref_rewards) or {}
			   		local total_refferals = result[1].total_refferals or 0
					
					for k,v in pairs(REWARDS[level].pSource) do
						updated_rewards[k] = (updated_rewards[k] or 0) + v 
					end

					if level == 5 then
						total_refferals = total_refferals + 1
						if total_refferals == 5 then
							updated_rewards.premium = (updated_rewards.premium or 0) + 1
						elseif total_refferals == 20 then
							updated_rewards.premium = (updated_rewards.premium or 0) + 1
						end
					end
					DB:exec("UPDATE nrp_players SET ref_rewards = ?, total_refferals = ? WHERE id = ?", toJSON(updated_rewards), total_refferals, iRefferer)

				end, { iRefferer }, "SELECT id, ref_rewards, total_refferals FROM nrp_players WHERE id = ? LIMIT 1", iRefferer)
			end
		end
	end
end
addEventHandler("OnPlayerLevelUp", root, OnPlayerLevelUp)

function OnPlayerTryApplyCode( sCode )
	local referrer = client:GetPermanentData("refferer")
	referrer = tostring( referrer ) ~= "0" and referrer
	if referrer then
		client:ErrorWindow("Ты уже активировал код другого игрока!")
		return 
	end

	if not tostring(sCode) then 
		client:ErrorWindow("Некорректный код!")
		return 
	end
	sCode = tostring(sCode)

	if client:GetLevel() > 1 then
		client:ErrorWindow("Активировать код можно только на первом уровне!")
		return false
	end

	local iTargetUID, is_custom_code = GetUIDFromCode( sCode )

	if iTargetUID == client:GetUserID() then
		client:ErrorWindow("Нельзя активировать собственный код!")
		return false
	end

	DB:queryAsync(function(queryHandler, pPlayer, sCode )
		local result = dbPoll(queryHandler,0)
		if type ( result ) ~= "table" or #result == 0 then
			pPlayer:ErrorWindow("Код не найден")
			return
		end

		local data = result[ 1 ]

		local target_from = { data.last_serial, data.reg_serial }
		local target_to = { pPlayer:GetPermanentData( "reg_serial" ), getPlayerSerial( pPlayer ) }

		for i, serial_from in pairs( target_from ) do
			for n, serial_to in pairs( target_to ) do
				if serial_from == serial_to then
					pPlayer:ErrorWindow( "Данный код нельзя активировать. Попробуйте другой" )
					return false
				end
			end
		end

		triggerEvent( "onPlayerUseInviteCode", pPlayer, sCode, data.client_id, is_custom_code )

		pPlayer:SetPermanentData("refferer", iTargetUID)
		pPlayer:InfoWindow("Ты успешно активировал код игрока "..data.nickname.."!")

		DB:exec("UPDATE nrp_players SET refferer = ? WHERE id = ?", iTargetUID, pPlayer:GetUserID())

		SendElasticGameEvent( data.client_id, "f4r_f4_refferals_code_activate_success" )

	end, { client, sCode }, "SELECT id, nickname, client_id, last_serial, reg_serial FROM nrp_players WHERE id = ? LIMIT 1", iTargetUID)
end
addEvent("OnPlayerTryApplyCode", true)
addEventHandler("OnPlayerTryApplyCode", root, OnPlayerTryApplyCode)

function OnPlayerRequestRefferalsData()
	local data = 
	{
		my_code = client:GetPermanentData("ref_code"),
		rewards = client:GetPermanentData("ref_rewards") or {},
		refferals = {},
	}

	local custom_codes = MariaGet("ref_codes")
	if custom_codes then
		custom_codes = fromJSON(custom_codes)
	end

	for k,v in pairs(custom_codes or {}) do
		if v == client:GetUserID() then
			data.my_code = k
		end
	end

	DB:queryAsync(function(queryHandler, data, pPlayer)
		local result = dbPoll(queryHandler,0)
		if type ( result ) == "table" and #result >= 1 then
			data.refferer = { name = result[1].nickname, level = result[1].level, online = not not GetPlayer( result[1].id, true ) }
		end

		DB:queryAsync(function(queryHandler, data, pPlayer)
			local result = dbPoll(queryHandler,0)
			if type ( result ) ~= "table" or #result == 0 then
				triggerClientEvent(pPlayer, "OnClientReceiveRefferalsData", pPlayer, data)
				return
			end

			for k,v in pairs(result) do
				local pPlayer = GetPlayer( v.id )
				if pPlayer then
					table.insert( data.refferals, { id = v.id } )
				else
					table.insert( data.refferals, { 
						name = pPlayer and pPlayer:GetNickName() or v.nickname,
						level = pPlayer and pPlayer:GetLevel() or v.level,
					} )
				end
			end

			triggerClientEvent( pPlayer, "OnClientReceiveRefferalsData", pPlayer, data )

		end, { data, pPlayer }, "SELECT id, level, nickname FROM nrp_players WHERE refferer = ?", pPlayer:GetUserID())

	end, { data, client }, "SELECT id, level, nickname FROM nrp_players WHERE id = ? LIMIT 1", client:GetPermanentData("refferer") or 0)
end
addEvent("OnPlayerRequestRefferalsData", true)
addEventHandler("OnPlayerRequestRefferalsData", root, OnPlayerRequestRefferalsData)

function OnPlayerReceiveRefferalRewards()
	local rewards = client:GetPermanentData("ref_rewards") or {}
	local gave_any_reward = false
	for k,v in pairs(rewards) do
		gave_any_reward = true
		if k == "money" then
			client:GiveMoney( v, "refferal" )
		elseif k == "donate" then
			client:GiveDonate( v, "refferal" )
		elseif k == "exp" then
			client:GiveExp( v )
		elseif k == "premium" then
			client:GivePremiumExpirationTime( v )
		end
	end

	if gave_any_reward then
		client:SetPermanentData( "ref_rewards", {} )

		client:InfoWindow( "Ты успешно забрал реферальные награды!" )
		triggerClientEvent( client, "onCleanRefRewardsRequest", client )

		SendElasticGameEvent( client:GetClientID( ), "f4r_f4_refferals_reward_take_success" )
	else
		client:ErrorWindow( "Реферальных наград нет на счету" )
	end
end
addEvent("OnPlayerReceiveRefferalRewards", true)
addEventHandler("OnPlayerReceiveRefferalRewards", root, OnPlayerReceiveRefferalRewards)