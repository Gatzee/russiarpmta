
CONST_COUNT_MOVE_BOX = 5

-- Точки взятия груза
PICKUP_POINTS =
{
	Vector3( -2895.5085, 1857.4794, 14.0817 ),
	Vector3( -2896.9304, 1864.9062, 14.0817 ),
	Vector3( -2909.8422, 1836.7854, 14.0817 ),
	Vector3( -2908.5756, 1829.3668, 14.0817 ),
	Vector3( -2885.5144, 1812.3945, 14.0817 ),
	Vector3( -2883.9492, 1805.0368, 14.0817 ),
	Vector3( -2911.7692, 1807.6047, 14.0817 ),
	Vector3( -2911.2482, 1802.4821, 14.0817 ),
	Vector3( -2921.1467, 1850.4084, 14.0817 ),
	Vector3( -2922.2653, 1857.7836, 14.0817 ),
}



-- Направления
DELIVERY_TARGETS =
{
	Vector3( -2817.6572, 1929.8645, 14.0958 ),
	Vector3( -2658.8195, 1938.3051, 14.0844 ),
}

QUEST_DATA = {
	id = "task_jail_1";

	title = "Грузчик";
	description = "";

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Отнеси ящики к цеху";

			Setup = {
				client = function()

					StartQuestTimerFail( 10 * 60 * 1000, "Перенеси ящики", "Слишком медленно!", function()
						triggerServerEvent( "onPlayerFailJailQuest", localPlayer, "task_jail_1" )
					end )

					local count_places_box = 0
					function CreatePointTakeBox()

						local pickup_point = PICKUP_POINTS[ math.random( 1, #PICKUP_POINTS ) ]
						CreateQuestPoint( pickup_point, function()
							CEs.marker:destroy( )
							CreatePointPlaceBox()
							StartCarrying( { model = 3052 } )
						end, _, 2, 0, 0, false, "mouse1", "Нажми 'ЛКМ' чтобы взять коробку", "cylinder" )
						CEs.marker.accepted_elements = { player = true }

					end

					function CreatePointPlaceBox()

						local target = DELIVERY_TARGETS[ math.random( 1, #DELIVERY_TARGETS ) ]
						CreateQuestPoint( target, function()
							CEs.marker:destroy( )
							StopCarrying( )
							count_places_box = count_places_box + 1
							if count_places_box == CONST_COUNT_MOVE_BOX then
								triggerServerEvent( "task_jail_1_end_step_1", localPlayer )
								triggerEvent( "onClientCreateJobMarkers", localPlayer )

								triggerServerEvent( "onPlayerCompleteJailQuest", localPlayer )
							else
								CreatePointTakeBox()
							end
						end, _, 2, 0, 0, false, _, _, "cylinder" )
						CEs.marker.accepted_elements = { player = true }

					end
					CreatePointTakeBox()
				end;
			};
			CleanUp = {
				client = function( )
					StopCarrying( )
				end;
			};
		};

	};

	GiveReward = function( player )
		player:GiveMoney( 250, "job_salary", QUEST_DATA.id )
	end;

}