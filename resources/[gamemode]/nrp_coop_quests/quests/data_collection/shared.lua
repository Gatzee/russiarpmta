COOP_QUESTS_CONFIG[ QUEST_TYPE_DATA_COLLECTION ] = 
{
	name = "Сбор документов",
	desc = "Вам с напарником нужно будет приехать на несколько точек сбора данных. Побеждает команда, набравшая большее количество данных. Если убить одного из противников, то можно отобрать часть данных.",

	respawn_positions = 
	{
		{ x = 292.132, y = 1985.044, z = 8.496 },
		{ x = 648.618, y = 1946.626, z = 7.828 },
	},

	vehicle_respawn_positions = 
	{	
		{ x = 292.126, y = 1980.709, z = 7.896, rz = 90 },
		{ x = 644.680, y = 1942.662, z = 7.891, rz = 75 },
	},

	data_positions = 
	{
		{ x = 521.93, y = 2433.22, z = 13.47 },
		{ x = -426.32, y = 2389.33, z = 14.22 },
		{ x = -704.56, y = 2218.86, z = 19.13 },
		{ x = -530.76, y = 2234.63, z = 15.37 },
		{ x = -662.94, y = 1805.91, z = 8.29 },
		{ x = -876.66, y = 1816.49, z = 9 },
		{ x = -1250.91, y = 2089.34, z = 10.21 },
		{ x = -1266.11, y = 2649.18, z = 16.9 },
		{ x = -1268.45, y = 2863.64, z = 15.35 },
		{ x = -464.23, y = 2707.26, z = 15.32 },
	},

	stages = 
	{
		[1] = 
		{
			is_mirrored = true,

			global = 
			{
				OnStarted = function( self, quest )
					quest:SetTaskTimer( 60, function( )
						if quest:GetTeamData( 1, "entered_start_vehicle" ) then
							for k,v in pairs( quest.teams[2] ) do
								if not isPedInVehicle( v.element ) then
									v.element:TakeCoopQuestAttempts( 1 )
								end
							end
						elseif quest:GetTeamData( 2, "entered_start_vehicle" ) then
							for k,v in pairs( quest.teams[1] ) do
								if not isPedInVehicle( v.element ) then
									v.element:TakeCoopQuestAttempts( 1 )
								end
							end
						end

						quest.failed = true
						quest:FinishQuest( )
					end)

					local function GetRandomPoints( points_amount )
						local point_ids = { }
						local output = { }

						for i = 1, points_amount do
							table.insert( point_ids, i )
						end

						for i = 1, 6 do
							local rand = math.random( 1, #point_ids )
							table.insert( output, point_ids[ rand ] )
							table.remove( point_ids, rand )
						end

						return output
					end

					local point_ids = GetRandomPoints( #quest.quest_conf.data_positions )
					quest:SetQuestData( "point_ids", point_ids, true )
				end,

				OnFinished = function( self, quest )
				end,
			},

			teams = 
			{
				[1] = 
				{
					task_name = "Садитесь в транспорт",

					OnStarted = function( self, quest, team )
						local vehicle_conf = QUEST_START_LOCATIONS[ quest:GetTeamData( team, "start_location" ) ].vehicle_conf
						local vehicle = Vehicle.CreateTemporary( 424, vehicle_conf.x, vehicle_conf.y, vehicle_conf.z, 0, 0, vehicle_conf.rz or 0 )
						setVehicleColor( vehicle, 80, 80, 80 )
						vehicle.dimension = quest.dimension
						vehicle.locked = false
						vehicle:SetStatic( true )

						quest:SetTeamData( team, "score", 0 )
						quest.quest_elements["start_vehicle"..team] = vehicle
						--quest:SyncElement( vehicle )

						addEventHandler("onVehicleEnter", vehicle, function( player )
							if quest.stage ~= 1 then return end

							local team_id = quest:GetPlayerTeam( player )

							if team_id == team then
								toggleAllControls( player, false )

								local occupants = getVehicleOccupants( source )
								local total_occupants = 0

								for k,v in pairs( occupants ) do
									total_occupants = total_occupants + 1
								end

								if total_occupants >= 2 then
									quest:SetTeamTask( team_id, _, "Ожидание другой команды" )
									quest:SetTeamData( team_id, "entered_start_vehicle", true )

									if quest:GetTeamData( team_id == 1 and 2 or 1, "entered_start_vehicle" ) then
										quest:FinishStage( )
									end
								end
							end
						end)

						addEventHandler("onVehicleStartEnter", vehicle, function( player, seat, jacked )
							if jacked then 
								cancelEvent( ) 
							end

							if quest:GetPlayerTeam( player ) ~= team then
								cancelEvent( )
							end
						end)
					end,

					OnFinished = function( self, quest, team )
					end,

					OnFinished_Client = function( self )
						toggleAllControls( true )
						toggleControl("change_camera", false)
					end,
				},
			},
		},

		[2] = 
		{
			is_mirrored = true,

			global = 
			{
				OnStarted = function( self, quest )
					quest:SetQuestData( "respawns_enabled", true, true )
					quest:SetQuestData( "vehicle_respawns_enabled", true, false )
					quest:ToggleImmortality( false )

					quest:SetTaskTimer( 60*10, function( ) 
						quest.ignore_rewards = true

						local team_1_score = quest:GetTeamData( 1, "score" ) or 0
						local team_2_score = quest:GetTeamData( 2, "score" ) or 0

						if team_1_score > team_2_score then
							for k,v in pairs( quest.teams[1] ) do
								v.element:GiveCoopQuestKeys( team_1_score >= 4 and 2 or 1 )
							end

							for k,v in pairs( quest.teams[2] ) do
								v.element:GiveCoopQuestKeys( 1 )
							end

							quest:OnTeamWon( 1 )
						elseif team_2_score > team_1_score then
							for k,v in pairs( quest.teams[2] ) do
								v.element:GiveCoopQuestKeys( team_2_score >= 4 and 2 or 1 )
							end

							for k,v in pairs( quest.teams[1] ) do
								v.element:GiveCoopQuestKeys( 1 )
							end

							quest:OnTeamWon( 2 )
						elseif team_1_score == team_2_score then
							for k,v in pairs( quest.players_list ) do
								v:GiveCoopQuestKeys( team_1_score >= 4 and 2 or 1 )
							end

							quest:OnTeamWon( -1 )
						end
					end)
				end,

				OnStarted_Client = function( self )
					local point_ids = GetCoopQuestData( "point_ids" )
					local quest_conf = GetCoopQuestConfig( )

					for k,v in pairs( point_ids ) do
						local position = quest_conf.data_positions[ v ]

						local p_conf = 
						{
							x = position.x,
							y = position.y,
							z = position.z,
							id = v,
						}

						CreateDataCollectionPoint( p_conf, true )
					end

					triggerEvent( "RefreshRadarBlips", localPlayer )
					triggerEvent( "ToggleGPS", localPlayer, false )

					ShowUI_DataCollection( true )
					ToggleCoopQuestOpponentBlips( true )
				end,

				OnFinished = function( self, quest )
				end,

				OnPlayerWasted = function( self, quest, player, killer )
					local victim_team = quest:GetPlayerTeam( player )
					local killer_team = quest:GetPlayerTeam( killer )

					if not victim_team or not killer_team then return end

					local victim_points = quest:GetTeamData( victim_team, "score" )
					if victim_points >= 1 then
						quest:SetTeamData( victim_team, "score", victim_points - 1 )

						local killer_points = quest:GetTeamData( killer_team, "score" )
						quest:SetTeamData( killer_team, "score", killer_points + 1 )
					end

					triggerClientEvent( quest.players_list, "OnClientTeamScoresSynced", resourceRoot, { quest:GetTeamData( 1, "score" ), quest:GetTeamData( 2, "score" ) } )
				end,
			},

			teams = 
			{
				[1] = 
				{
					task_name = "Соберите больше данных, убивая противников",

					OnStarted = function( self, quest, team )
						quest.quest_elements["start_vehicle"..team]:SetStatic( false )
					end,

					OnFinished = function( self, quest, team )
					end,
				},
			},
		},
	},

	OnStarted = function( self, quest, team )
	end,

	OnFinished = function( self, quest, team )
	end,

	OnFinished_Client = function( self )
		CleanUpQuestDataPoints( )
		StopDiggingMinigame( )
		ShowUI_DataCollection( false )
	end
}