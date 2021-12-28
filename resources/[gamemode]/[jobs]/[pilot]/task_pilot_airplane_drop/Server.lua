loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SVehicle")
Extend("SQuest")

addEventHandler("onResourceStart", resourceRoot, function()
	SQuest(QUEST_DATA)
end)

TAKEOFF_TIME = 0.25 * 60000
LAST_TAKEOFF = getTickCount()



function OnPlayerTryTakePilotVehicle( pPlayer )
	local iTimeLeft = math.floor( (LAST_TAKEOFF + TAKEOFF_TIME - getTickCount() ) / 1000 )

	if iTimeLeft >= 5 then
		pPlayer:SetPrivateData("pilot:time_to_takeoff", iTimeLeft)
		triggerEvent( "PlayerAction_Task_Pilot_3_step_1", pPlayer )
	else
		triggerEvent( "PlayerAction_Task_Pilot_3_step_1", pPlayer )
		triggerEvent( "PlayerAction_Task_Pilot_3_step_2", pPlayer )
	end

	LAST_TAKEOFF = getTickCount() + TAKEOFF_TIME
end
addEvent("OnPlayerTryTakePilotVehicle", true)
addEventHandler("OnPlayerTryTakePilotVehicle", resourceRoot, OnPlayerTryTakePilotVehicle)

function onPilotMarkerPass_handler( player, distance_mul )
	local job_class, job_id = player:GetJobClass( ), player:GetJobID( )
	if job_class ~= JOB_CLASS_PILOT then return end

	local money, exp = exports.nrp_handler_economy:GetEconomyJobData( job_id )

	local rewards = {}

	money, exp = math.floor( money * distance_mul ), math.floor( exp * distance_mul )

	money = math.floor( money * player:GetJobMoneyBonusMultiplier( ) * ( player:IsBoosterActive( BOOSTER_DOUBLE_MONEY ) and 2 or 1 ) * ( player:IsPremiumActive() and PREMIUM_SETTINGS.fJobMoneyMul or 1 ) )
	exp = math.floor( exp * ( player:IsBoosterActive( BOOSTER_DOUBLE_EXP ) and 2 or 1 ) )
	
	if exp and exp > 0 then
		exp = player:IsPremiumActive() and PREMIUM_SETTINGS.fJobExpMul * exp or exp
		exp = player:GiveExp( exp, "PILOT_" .. job_id )
		table.insert(rewards, { type = "exp", value = exp })
	end
	
	if money and money > 0 then
		local money, money_real, money_gov = exports.nrp_factions_gov_ui_control:GetJobGovEconomyPercent( player:GetShiftCity( ), money )
		player:GiveMoney( money, "job_salary", "pilot" )
		triggerEvent( "onJobEarnMoney", player, job_class, money, "Задача", exp or 0 )
		triggerEvent( "onJobCoreEarnedMoney", player, money )

		table.insert(rewards, { type = "soft", value = money })
	end

	if #rewards > 0 then
		player:ShowRewards(unpack(rewards))
	end

	triggerEvent( "onJobFinishedVoyage", player, money, exp )
end
addEvent( "onPilotMarkerPass", true )
addEventHandler( "onPilotMarkerPass", resourceRoot, onPilotMarkerPass_handler )

function onPilotRespawnPosition_handler( player )
	if player then
		toggleControl( player, "enter_exit", true )
		setTimer(function()
			player.position = PLAYER_RESPAWN_POSITION:AddRandomRange(5)
		end, 500, 1)
	end
end
addEvent( "onPilotRespawnPosition", true )
addEventHandler( "onPilotRespawnPosition", resourceRoot, onPilotRespawnPosition_handler )