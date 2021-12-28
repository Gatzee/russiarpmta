loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SVehicle")
Extend("Globals")
Extend("SQuest")

addEventHandler("onResourceStart", resourceRoot, function()
	SQuest(QUEST_DATA)
end)

function onMechanicCompletedRepairLap_handler( player )
	local rewards = {}
	local job_class, job_id = player:GetJobClass( ), player:GetJobID( )
	if job_class ~= JOB_CLASS_MECHANIC then return end

	local money, exp = exports.nrp_handler_economy:GetEconomyJobData( job_id )

	money = math.floor( money * player:GetJobMoneyBonusMultiplier( ) * ( player:IsBoosterActive( BOOSTER_DOUBLE_MONEY ) and 2 or 1 ) * ( player:IsPremiumActive() and PREMIUM_SETTINGS.fJobMoneyMul or 1 ) )
	exp = math.floor( exp * ( player:IsBoosterActive( BOOSTER_DOUBLE_EXP ) and 2 or 1 ) )

	if exp and exp > 0 then
		exp = player:IsPremiumActive() and PREMIUM_SETTINGS.fJobExpMul * exp or exp
		exp = player:GiveExp( exp, "MECHANIC_" .. job_id )
		table.insert(rewards, { type = "exp", value = exp })
	end
	
	if money and money > 0 then 
		local money, money_real, money_gov = exports.nrp_factions_gov_ui_control:GetJobGovEconomyPercent( 1, money )
		table.insert(rewards, { type = "soft", value = money })
		player:GiveMoney( money, "job_salary", "mechanic" )
		triggerEvent( "onJobEarnMoney", player, job_class, money, "Задача", exp or 0 )
		triggerEvent( "onJobCoreEarnedMoney", player, money )
	end
	
	if #rewards > 0 then
		player:PlaySound( SOUND_TYPE_2D, ":nrp_shop/sfx/reward_small.mp3" )
		player:ShowRewards(unpack(rewards))
	end

	triggerEvent( "onJobFinishedVoyage", player, money, exp )
end
addEvent( "onMechanicCompletedRepairLap" )
addEventHandler( "onMechanicCompletedRepairLap", root, onMechanicCompletedRepairLap_handler )