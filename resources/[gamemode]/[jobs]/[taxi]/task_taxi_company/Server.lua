loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SVehicle" )
Extend( "SQuest" )

COUNTER = { }

addEventHandler( "onResourceStart", resourceRoot, function ( )
	SQuest( QUEST_DATA )
end )

addEventHandler( "onPlayerQuit", root, function ( )
	COUNTER[ source ] = nil
end )

function onTaxiDeliveryPass_handler( meters_pickup, meters_delivery )
	local job_class, job_id = client:GetJobClass( ), client:GetJobID( )
	if job_class ~= JOB_CLASS_TAXI then return end

	local timestamp = getRealTimestamp( )
	local mul = 1
	if timestamp < ( COUNTER[ client ] or 0 ) then
		mul = 0
	end
	COUNTER[ client ] = timestamp + 20

	local money, exp = exports.nrp_handler_economy:GetEconomyJobData( job_id )

	money = math.floor( money * client:GetJobMoneyBonusMultiplier( ) * ( client:IsBoosterActive( BOOSTER_DOUBLE_MONEY ) and 2 or 1 ) * ( client:IsPremiumActive() and PREMIUM_SETTINGS.fJobMoneyMul or 1 ) )
	exp = math.floor( exp * ( client:IsBoosterActive( BOOSTER_DOUBLE_EXP ) and 2 or 1 ) )

	if exp and exp > 0 then
		exp = client:IsPremiumActive() and PREMIUM_SETTINGS.fJobExpMul * exp or exp
		client:GiveExp( exp * mul, "TAXI_" .. job_id )
	end
	
	if money and money > 0 then
		local money, money_real, money_gov = exports.nrp_factions_gov_ui_control:GetJobGovEconomyPercent( client:GetShiftCity( ), money )
		client:GiveMoney( money * mul, "job_salary", "taxi" )
		triggerEvent( "onJobEarnMoney", client, job_class, money, "Задача", exp or 0 )
		triggerEvent( "onJobCoreEarnedMoney", client, money )
	end
	
	triggerEvent( "TaxiDaily_AddDelivery", client, meters_pickup, meters_delivery )

	triggerEvent( "onJobFinishedVoyage", client, money, exp )
end
addEvent( "onTaxiDeliveryPass", true )
addEventHandler( "onTaxiDeliveryPass", resourceRoot, onTaxiDeliveryPass_handler )