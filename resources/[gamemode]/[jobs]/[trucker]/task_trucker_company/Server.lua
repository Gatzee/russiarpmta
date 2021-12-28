loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SVehicle")
Extend("SQuest")

addEventHandler("onResourceStart", resourceRoot, function()
	SQuest(QUEST_DATA)
end)

MARKER_PAYOUT = 0.6
RETURN_PAYOUT = 1 - MARKER_PAYOUT

function onTruckerMarkerPass_handler( is_return, meters )
	local rewards = {}
	local job_class, job_id = client:GetJobClass( ), client:GetJobID( )
	if job_class ~= JOB_CLASS_TRUCKER then return end

	local TRUCKER_JOB_DELIVERY_DISTANCE = client:getData( "TRUCKER_JOB_DELIVERY_DISTANCE" )
	local TRUCKER_JOB_DELIVERY_UNLOAD_1 = client:getData( "TRUCKER_JOB_DELIVERY_UNLOAD_1" )
	local TRUCKER_JOB_DELIVERY_UNLOAD_2 = client:getData( "TRUCKER_JOB_DELIVERY_UNLOAD_2" )
	if meters or not TRUCKER_JOB_DELIVERY_DISTANCE or ( not is_return and not TRUCKER_JOB_DELIVERY_UNLOAD_1 ) or ( is_return and not TRUCKER_JOB_DELIVERY_UNLOAD_2 ) then
		triggerEvent( "DetectPlayerAC", client, "42" )
		return
	end

	if is_return then
		client:SetPrivateData( "TRUCKER_JOB_DELIVERY_TARGET_NUM", false )
		client:SetPrivateData( "TRUCKER_JOB_DELIVERY_DISTANCE", false )
		client:SetPrivateData( "TRUCKER_JOB_DELIVERY_UNLOAD_2", false )
	else
		client:SetPrivateData( "TRUCKER_JOB_DELIVERY_UNLOAD_1", false )
	end

	meters = TRUCKER_JOB_DELIVERY_DISTANCE

	local money, exp = exports.nrp_handler_economy:GetEconomyJobData( job_id )
	money, exp = math.floor( money * meters ), math.floor( exp * meters )

	money = math.floor( money * client:GetJobMoneyBonusMultiplier( ) * ( client:IsBoosterActive( BOOSTER_DOUBLE_MONEY ) and 2 or 1 ) * ( client:IsPremiumActive() and PREMIUM_SETTINGS.fJobMoneyMul or 1 ) )
	exp = math.floor( exp * ( client:IsBoosterActive( BOOSTER_DOUBLE_EXP ) and 2 or 1 ) )

	if exp and exp > 0 then
		exp = math.floor( is_return and exp * RETURN_PAYOUT or exp * MARKER_PAYOUT )
		exp = client:IsPremiumActive() and PREMIUM_SETTINGS.fJobExpMul * exp or exp
		exp = client:GiveExp( exp, "TRUCKER_" .. job_id )
		table.insert(rewards, { type = "exp", value = exp })
	end
	
	if money and money > 0 then
		money = math.floor( is_return and money * RETURN_PAYOUT or money * MARKER_PAYOUT )
		money, money_real, money_gov = exports.nrp_factions_gov_ui_control:GetJobGovEconomyPercent( client:GetShiftCity( ), money )
		table.insert(rewards, { type = "soft", value = money })
		client:GiveMoney( money, "job_salary", "trucker" )
		triggerEvent( "onJobEarnMoney", client, job_class, money, "Задача", exp or 0 )
		triggerEvent( "onJobCoreEarnedMoney", client, money )
	end
	
	if #rewards > 0 then
		client:PlaySound( SOUND_TYPE_2D, ":nrp_shop/sfx/reward_small.mp3" )
		client:ShowRewards(unpack(rewards))
	end

	if is_return then
		local prev_reward = client:getData( "trucker_prev_reward" )
		triggerEvent( "onJobFinishedVoyage", client, money + prev_reward.money, exp + prev_reward.exp )
	else
		client:setData( "trucker_prev_reward", { money = money, exp = exp }, false )
		client:setData( "last_voyage", false, false )
	end
end
addEvent( "onTruckerMarkerPass", true )
addEventHandler( "onTruckerMarkerPass", resourceRoot, onTruckerMarkerPass_handler )