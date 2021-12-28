QUEST_DATA = {
	id = "urgent_military_2";

	title = "Начало срочной службы";
	description = "";

	replay_timeout = 0;

	CheckToStart = function(player)
		return true
	end;

	tasks = {
		[1] = {
			name = "Знакомство с прапорщиком";

			Setup = {
				client = function()
					CreateQuestPointToNPCWithDialog( 13, {
						{
							text = [[— Здравия желаю, салага! Я прапорщик Заёпкин.
									Не путать буквы в фамилии, а то два наряда
									вне очереди впиндюрю!]];
						};
						{
							text = [[— Сейчас оставь свои вещи в казарме и бегом
									возвращайся ко мне! У меня есть для тебя
									очень полезное занятие.]];
						};
					}, "PlayerAction_Urgent_Militaty_step_3", _, true )
				end;
			};

			event_end_name = "PlayerAction_Urgent_Militaty_step_3";
		};
		[2] = {
			name = "Изучи меню статистики";

			Setup = {
				client = function()
					CreateQuestPoint( Vector3(  -2410.987, -57.26 + 860, 20  ), "PlayerAction_Urgent_Militaty_step_4" )
				end;
			};

			event_end_name = "PlayerAction_Urgent_Militaty_step_4";
		};
	};

	rewards = {
		military_exp = 100;
	};

	success_text = "Задача выполнена! Вы получили +100 очков ранга";
}