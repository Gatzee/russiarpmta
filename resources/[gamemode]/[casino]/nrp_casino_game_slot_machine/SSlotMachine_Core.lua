Extend( "SPlayer" )
Extend( "SCasino" )
Extend( "SInterior" )

SLOT_MACHINE_ROOM = {}

function onServerSlotMachinePreStart_handler( casino_id, game_id )
	local player = client
	if not isElement( player ) or not game_id or not CASINO_GAME_STRING_IDS[ game_id ] then return end

	player:Teleport( SLOT_MACHINE_GAME_POSITION, player:GetUniqueDimension( ) )
	
	player:CompleteDailyQuest( "play_casino" )
	player:SetPrivateData( "in_casino", true )

	SLOT_MACHINE_ROOM[ player ] = 
	{
		casino_id      = casino_id,
		game_id 	   = game_id,
		unic_game_id   = GenerateUniqId(),
		bet_sum		   = 0,
		reward_sum	   = 0,
		lost_sum	   = 0,
		lost_count_bet = 0,
		win_count_bet  = 0,
		start_time     = getRealTimestamp(),
	}

	onCasinoSlotStart( player, game_id, CASIONO_STRING_ID[ SLOT_MACHINE_ROOM[ player ].casino_id ], SLOT_MACHINE_ROOM[ player ].unic_game_id )
end
addEvent( "onServerSlotMachinePreStart", true )
addEventHandler( "onServerSlotMachinePreStart", resourceRoot, onServerSlotMachinePreStart_handler )

function onServerSlotMachineLeaveRequest_handler( player, leave_reason, pre_log_out )
	local player = player or client
	if not isElement( player ) then return end

	local game_room = SLOT_MACHINE_ROOM[ player ]
	if not game_room then return end

	local lost_sum = game_room.bet_sum - game_room.reward_sum
	if lost_sum > 0 then
		player:AddCasinoGameLoseAmount( lost_sum )
	end

	if not pre_log_out then
		GivePlayerSlotMachineReward( player )
		
		local casino_leave_data = exports.nrp_casino_lobby:GetCasinoLeavePosition( game_room.casino_id )
		player:Teleport( casino_leave_data.position:AddRandomRange( 3 ), casino_leave_data.dimension, casino_leave_data.interior )
		player:SetPrivateData( "in_casino", false )
	end

	onCasinoSlotLeave( player, game_room.game_id, game_room.unic_game_id, game_room.bet_sum, game_room.reward_sum, game_room.lost_count_bet, game_room.win_count_bet, game_room.start_time, leave_reason )
	
	SLOT_MACHINE_ROOM[ player ] = nil
end
addEvent( "onServerSlotMachineLeaveRequest", true )
addEventHandler( "onServerSlotMachineLeaveRequest", resourceRoot, onServerSlotMachineLeaveRequest_handler )

function onServerCasinoSlotMachinePlay_handler( bet_id )
	local player = client
	local game_room = SLOT_MACHINE_ROOM[ player ]
	if not game_room then return end

	local bet = BETS[ game_room.casino_id ][ bet_id ]
	if not isElement( player ) or not bet then return end

	local game_room = SLOT_MACHINE_ROOM[ player ]
	if not game_room then return end
	
	-- Учет автоматической игры
	GivePlayerSlotMachineReward( player )

	if not player:TakeMoney( bet, "casino", CASINO_GAME_STRING_IDS[ game_room.game_id ] ) then return end
	game_room.bet_sum = game_room.bet_sum + bet 

	local result_items = GenerateSlotMachineItems( game_room.game_id )
	local combination_coeff = CalculateCombinationsCoefficient( game_room.game_id, result_items )

	local winning_amount = bet * (combination_coeff or 1)
	
	if combination_coeff then
		player:SetPermanentData( "slot_machine_win_data", { winning_amount = winning_amount, game_id = game_room.game_id, casino_id = game_room.casino_id  } )
		game_room.win_count_bet = game_room.win_count_bet + 1
		game_room.reward_sum    = game_room.reward_sum + winning_amount
	else
		game_room.lost_count_bet = game_room.lost_count_bet + 1
		winning_amount = nil
	end

	triggerEvent( "onCasinoPlayersGame", root, game_room.game_id, { player } )

	triggerClientEvent( player, "onCasinoSlotMachineGenerated", resourceRoot, game_room.game_id, result_items, winning_amount )

	-- Retention task "slot10"
	triggerEvent( "onSlotMachinePlay", player )
end
addEvent( "onServerCasinoSlotMachinePlay", true )
addEventHandler( "onServerCasinoSlotMachinePlay", resourceRoot, onServerCasinoSlotMachinePlay_handler )


function GivePlayerSlotMachineReward( player )
	if not isElement( player ) then return end

	local win_data = player:GetPermanentData( "slot_machine_win_data" )
	if win_data and win_data.winning_amount > 0 then
		player:GiveMoney( win_data.winning_amount, "casino", CASINO_GAME_STRING_IDS[ win_data.game_id ] )
		
		player:SetPermanentData( "slot_machine_win_data", nil )
		player:AddCasinoGameWinAmount( win_data.casino_id, win_data.game_id, win_data.winning_amount )
	end
end

function onServerCasinoTryTakeReward_handler()
	GivePlayerSlotMachineReward( client )
end
addEvent( "onServerCasinoTryTakeReward", true )
addEventHandler( "onServerCasinoTryTakeReward", resourceRoot, onServerCasinoTryTakeReward_handler )

function onPlayerCompleteLogin_handler( player )
	local player = isElement( player ) and player or source
	GivePlayerSlotMachineReward( player )
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler ) 

function onPlayerPreLogout_handler( reason )
	onServerSlotMachineLeaveRequest_handler( source, reason, true )
end
addEvent( "onPlayerPreLogout" )
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_handler )

function onResourceStop_handler()
    for k, v in pairs( GetPlayersInGame() ) do
        if SLOT_MACHINE_ROOM[ v ] then
			v:ShowError( "Слот машины отключены сервером" )
			onServerSlotMachineLeaveRequest_handler( v, "resource_stop", false )
        end
    end
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_handler )