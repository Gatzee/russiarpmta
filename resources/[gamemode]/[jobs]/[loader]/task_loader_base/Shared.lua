-- Точки взятия груза
PICKUP_POINTS = {
	-- НСК
	[ 0 ] = {
		Vector3( -1441.363, -1596.854, 21.121 ),
		Vector3( -1431.08, -1596.854, 21.121 ),
		Vector3( -1423.333, -1602.248, 21.121 ),
		Vector3( -1423.333, -1621.179, 21.121 ),
		Vector3( -1431.355, -1626.399, 21.121 ),
		Vector3( -1441.873, -1626.399, 21.121 ),
		Vector3( -1446.604, -1615.13, 21.121 ),
		Vector3( -1446.604, -1606.62, 21.121 ),
	},
	-- Горки
	[ 1 ] = {
		Vector3( 2398.653, -1713.352 + 860, 73.927 ),
		Vector3( 2398.653, -1719.9 + 860, 73.927 ),
		Vector3( 2398.653, -1726.283 + 860, 73.927 ),
	}
}

-- Направления
DELIVERY_TARGETS = {
	-- НСК
	[ 0 ] = {
		Vector3( -1488.665, -1631.611 + 860, 21.121 ),
		Vector3( -1497.038, -1620.744 + 860, 21.121 ),
		Vector3( -1509.259, -1621.45 + 860, 21.121 ),
		Vector3( -1512.19, -1565.697 + 860, 21.121 ),
		Vector3( -1518.54, -1532.486 + 860, 21.121 ),
		Vector3( -1525.687, -1526.384 + 860, 21.121 ),
	},
	-- Горки
	[ 1 ] = {
		Vector3( 2451.759, -1747.708 + 860, 73.929 ),
		Vector3( 2454.339, -1742.864 + 860, 73.925 ),
		Vector3( 2484.413, -1759.255 + 860, 73.946 ),
		Vector3( 2497.215, -1702.046 + 860, 75.053 ),
	},
}

addEvent( "onLoaderEarnMoney", true )

QUEST_DATA = {
	id = "task_loader_base";

	title = "Грузчик на подработке";
	description = "";

	CheckToStart = function( player )
		return player:GetJobClass( ) == JOB_CLASS_LOADER
	end;

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Разгрузи Газель";

			Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )
					local pickup_points = PICKUP_POINTS[ city ]
					local pickup_point = pickup_points[ math.random( 1, #pickup_points ) ]

					CreateQuestPoint( pickup_point, 
						function()
							CEs.marker:destroy()
							triggerServerEvent( "PlayerAction_Task_Loader_1_step_1", localPlayer )
						end
					, _, 2, 0, 0, false, "lalt", "Нажми 'ALT' чтобы взять коробку", "cylinder", 0, 255, 0, 20 )
					CEs.marker.accepted_elements = { player = true }
				end;
			};

			event_end_name = "PlayerAction_Task_Loader_1_step_1";
		};
		[2] = {
			name = "Отнеси коробку на склад";

			Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )
					local targets = DELIVERY_TARGETS[ city ]
					local target = targets[ math.random( 1, #targets ) ]

					StartCarrying( { model = 3052 } )

					CreateQuestPoint( target, 
						function()
							CEs.marker:destroy( )
							triggerServerEvent( "PlayerAction_Task_Loader_1_step_2", localPlayer )
						end
					, _, 2, 0, 0, false, _, _, "cylinder", 255, 100, 255, 20 )

					CEs.marker.accepted_elements = { player = true }
				end;
			};
			CleanUp = {
				client = function()
					StopCarrying( )
					triggerServerEvent( "FarmerDaily_AddBox", localPlayer )
				end;
			};
			event_end_name = "PlayerAction_Task_Loader_1_step_2";
		};
	};

	GiveReward = function( player )
		triggerEvent( "onLoaderMarkerPass", resourceRoot, player )
		StartAgain( player )
	end;

	no_show_rewards = true;
	no_show_success = true;
}

function StartAgain( player )
	setTimer( function()
		if not isElement( player ) then return end
		triggerEvent( "onJobRequestAnotherTask", player, player, false )
	end, 50, 1 )
end