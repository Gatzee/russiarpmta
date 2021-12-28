loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SPlayer")
Extend("SVehicle")
Extend("SQuest")

addEventHandler( "onResourceStart", resourceRoot, function()
	SQuest( QUEST_DATA )
end )

addEventHandler( "onResourceStop", resourceRoot, function()
	local target_players = {}
	for k, v in pairs( getElementsByType( "player" ) ) do
		if v:GetJobClass( ) == JOB_CLASS_HCS then
			table.insert( target_players, v )
		end
	end

	for k, v in pairs( target_players ) do
		v:TakeWeapon( 15 )
	end
end )

function onHcsFinishedCutting_handler()
	local rewards = {}
	local job_class, job_id = source:GetJobClass( ), source:GetJobID( )
	if job_class ~= JOB_CLASS_HCS then return end

	local money, exp = exports.nrp_handler_economy:GetEconomyJobData( job_id )

	money = math.floor( money * source:GetJobMoneyBonusMultiplier( ) * ( source:IsBoosterActive( BOOSTER_DOUBLE_MONEY ) and 2 or 1 ) * ( source:IsPremiumActive() and PREMIUM_SETTINGS.fJobMoneyMul or 1 ) )
	exp = math.floor( exp * ( source:IsBoosterActive( BOOSTER_DOUBLE_EXP ) and 2 or 1 ) )

	if exp and exp > 0 then
		exp = source:IsPremiumActive() and PREMIUM_SETTINGS.fJobExpMul * exp or exp
		exp = source:GiveExp( exp, "HCS_" .. job_id )
		table.insert(rewards, { type = "exp", value = exp })
	end
	
	if money and money > 0 then 
		table.insert(rewards, { type = "soft", value = money })
		source:GiveMoney( money, "job_salary", "hcs" )
		triggerEvent( "onJobEarnMoney", source, job_class, money, "Задача", exp or 0 )
		triggerEvent( "onJobCoreEarnedMoney", source, money )
	end
	
	if #rewards > 0 then
		source:PlaySound( SOUND_TYPE_2D, ":nrp_shop/sfx/reward_small.mp3" )
		source:ShowRewards(unpack(rewards))
	end

	triggerEvent( "onJobFinishedVoyage", source, money, exp )
end
addEvent( "onHcsFinishedCutting" )
addEventHandler( "onHcsFinishedCutting", root, onHcsFinishedCutting_handler )