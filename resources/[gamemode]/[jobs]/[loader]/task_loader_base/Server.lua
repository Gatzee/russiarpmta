loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SVehicle")
Extend("SQuest")

addEventHandler("onResourceStart", resourceRoot, function()
	SQuest(QUEST_DATA)
end)

addEvent( "RemovePedFromVehicle", true )
addEventHandler( "RemovePedFromVehicle", resourceRoot, function( )
	client.vehicle = nil
end )

function onLoaderMarkerPass_handler( player )
	local job_class, job_id = player:GetJobClass( ), player:GetJobID( )
	if job_class ~= JOB_CLASS_LOADER then return end

	local money, exp = exports.nrp_handler_economy:GetEconomyJobData( job_id )

	money = math.floor( money * player:GetJobMoneyBonusMultiplier( ) * ( player:IsBoosterActive( BOOSTER_DOUBLE_MONEY ) and 2 or 1 ) * ( player:IsPremiumActive() and PREMIUM_SETTINGS.fJobMoneyMul or 1 ) )
	exp = math.floor( exp * ( player:IsBoosterActive( BOOSTER_DOUBLE_EXP ) and 2 or 1 ) )

	if exp and exp > 0 then
		exp = player:IsPremiumActive() and PREMIUM_SETTINGS.fJobExpMul * exp or exp
		player:GiveExp( exp, "LOADER_" .. job_id )
	end
	
	if money and money > 0 then
		local money, money_real, money_gov = exports.nrp_factions_gov_ui_control:GetJobGovEconomyPercent( player:GetShiftCity( ), money )
		player:GiveMoney( money, "job_salary", "loader" )
		triggerEvent( "onJobEarnMoney", player, job_class, money, "Задача", exp or 0 )
		triggerEvent( "onJobCoreEarnedMoney", player, money )
	end
	
	triggerEvent( "LoaderDaily_AddBox", player )
	triggerEvent( "onJobFinishedVoyage", player, money, exp )
end
addEvent( "onLoaderMarkerPass" )
addEventHandler( "onLoaderMarkerPass", resourceRoot, onLoaderMarkerPass_handler )