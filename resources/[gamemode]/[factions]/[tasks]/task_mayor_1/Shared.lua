CONST_NEED_COUNT_PLAYER = 20
CONST_REWARD_EXP = 600

addEvent( "PlayerAction_PassportShowSuccess", true )
addEvent( "PlayerAction_JailedSuccess", true )

QUEST_DATA = {
	id = "task_mayor_1";

	title = "Сытый город";
	description = "";

	CheckToStart = function( player )
		return player:IsInFaction()
	end;

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Поговори с клерком";

			Setup = {
				client = function( )
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction() ], {
						{
							text = [[— Здравствуйте, у нас снова проблема с голодающими,
									необходимо накормить ]].. CONST_NEED_COUNT_PLAYER ..[[ горожан, для выполнения
									требуемого плана.]];
						};
						{
							text = [[Подойди к игроку и используя радиальное меню
									на “TAB”, чтобы накормить бесплатно.]];
							info = true;
						};
					}, "task_mayor_1_end_step_1", _, true )
				end;
			};
		};
		[2] = {
			name = "Выполни план";

			Setup = {
				server = function( player, data )
					player:setData( "fed_players", { count = 0 }, false )
					addEventHandler( "OnPlayerTryGiveFreeFood", player, OnPlayerTryGiveFreeFood_handler )
				end;
			};

			CleanUp = {
				server = function( player )
					removeEventHandler( "OnPlayerTryGiveFreeFood", player, OnPlayerTryGiveFreeFood_handler )
					player:setData( "fed_players", nil, false )
					player:CompleteDailyQuest( "mayor_wellfed_city" )
				end;
			};
		};
	};
	GiveReward = function( player )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_mayor_1", CONST_REWARD_EXP )
	end;

	rewards = {
		faction_exp = CONST_REWARD_EXP;
	};

	success_text = "Задача выполнена! Вы получили +".. CONST_REWARD_EXP .." очков ранга";
}

function OnPlayerTryGiveFreeFood_handler( pTarget )
	local fed_players = source:getData( "fed_players" )
	local user_id = pTarget:GetUserID()
	if fed_players[ user_id ] then
		source:ShowInfo( "Вы уже накормили этого гражданина" )
		return
	end
	fed_players[ user_id ] = true
	fed_players.count = fed_players.count + 1
	source:setData( "fed_players", fed_players, false )

	local maxCalories = source:getData( "max_calories" ) or 100
	pTarget:SetCalories( maxCalories )
	pTarget:ShowInfo( "Вас бесплатно накормил сотрудник мэрии" )

	local count_checked = CONST_NEED_COUNT_PLAYER - fed_players.count
	if count_checked == 0 then
		triggerEvent( "task_mayor_1_end_step_2", source )
	else
		source:ShowInfo( "По плану осталось еще ".. count_checked .." чел." )
	end
end