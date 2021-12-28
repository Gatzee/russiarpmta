loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SVehicle")
Extend("SQuest")

addEventHandler("onResourceStart", resourceRoot, function()
	SQuest(QUEST_DATA)
end)

function onDriverRoutePass_handler( serviced_passangers, fail_stops )
	local job_class, job_id = client:GetJobClass( ), client:GetJobID( )
	if job_class ~= JOB_CLASS_DRIVER then return end

	local money, exp = exports.nrp_handler_economy:GetEconomyJobData( job_id )
	money, exp = math.floor( money * serviced_passangers ), math.floor( exp * serviced_passangers )

	money = math.floor( money * client:GetJobMoneyBonusMultiplier( ) * ( client:IsBoosterActive( BOOSTER_DOUBLE_MONEY ) and 2 or 1 ) * ( client:IsPremiumActive() and PREMIUM_SETTINGS.fJobMoneyMul or 1 ) )
	exp = math.floor( exp * ( client:IsBoosterActive( BOOSTER_DOUBLE_EXP ) and 2 or 1 ) )

	if exp and exp > 0 then
		exp = client:IsPremiumActive() and PREMIUM_SETTINGS.fJobExpMul * exp or exp
		client:GiveExp( exp, "DRIVER_" .. job_id )
	end
	
	if money and money > 0 then
		local money, money_real, money_gov = exports.nrp_factions_gov_ui_control:GetJobGovEconomyPercent( client:GetShiftCity( ), money )
		client:GiveMoney( money, "job_salary", "driver" )
		triggerEvent( "onJobEarnMoney", client, job_class, money, "Задача", exp or 0 )
		triggerEvent( "onJobCoreEarnedMoney", client, money )
	end
	
	triggerEvent( "DriverDaily_AddRoute", client )
	triggerEvent( "onJobFinishedVoyage", client, money, exp )
end
addEvent( "onDriverRoutePass", true )
addEventHandler( "onDriverRoutePass", resourceRoot, onDriverRoutePass_handler )