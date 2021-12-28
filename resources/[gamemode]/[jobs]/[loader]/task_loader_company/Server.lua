loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SVehicle")
Extend("SQuest")

addEventHandler("onResourceStart", resourceRoot, function()
	SQuest(QUEST_DATA)
end)

VEHICLE_LOCATIONS = {
	-- НСК
	[ 0 ] = {
		{ position = Vector3( -804.454, -1183.961, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
		{ position = Vector3( -804.454, -1177.961, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
		{ position = Vector3( -804.454, -1171.961, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
		{ position = Vector3( -804.454, -1165.961, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
		{ position = Vector3( -804.454, -1148.793, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
		{ position = Vector3( -804.454, -1142.793, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
		{ position = Vector3( -804.454, -1136.793, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
		{ position = Vector3( -804.454, -1130.793, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
		{ position = Vector3( -772.44, -1183.961, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
		{ position = Vector3( -772.44, -1177.961, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
		{ position = Vector3( -772.44, -1171.961, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
		{ position = Vector3( -772.44, -1165.961, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
		{ position = Vector3( -772.44, -1148.793, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
		{ position = Vector3( -772.44, -1142.793, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
		{ position = Vector3( -772.44, -1136.793, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
		{ position = Vector3( -772.44, -1130.793, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
		{ position = Vector3( -772.411, -1102.043, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( -775.411, -1102.043, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( -778.411, -1102.043, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( -781.411, -1102.043, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( -784.411, -1102.043, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( -787.411, -1102.043, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( -790.411, -1102.043, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( -793.411, -1102.043, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( -796.411, -1102.043, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( -799.411, -1102.043, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( -802.411, -1102.043, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( -805.411, -1102.043, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( -808.411, -1102.043, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( -811.411, -1102.043, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( -814.411, -1102.043, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( -817.411, -1102.043, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
	},
	-- Горки
	--[ 1 ] = { },
}

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