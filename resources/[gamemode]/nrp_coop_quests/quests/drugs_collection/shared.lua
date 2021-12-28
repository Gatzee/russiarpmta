COOP_QUESTS_CONFIG[ QUEST_TYPE_DRUGS_COLLECTION ] = 
{
	name = "Чистый кэш",
	desc = "В этом задании вам необходимо собрать реагенты для варки мыла, достать недостающие у конкурентов и сбыть их скупщику первыми.",

	respawn_positions = 
	{
		{
			{ x = -544.892, y = 1449.169, z = 8.298 },
			{ x = -599.067, y = 1589.317, z = 8.299 },
		},
		{
			{ x = 733.606, y = 2430.117, z = 15.521 },
			{ x = 542.893, y = 2247.802, z = 18.209 },
		},
	},

	item_positions = 
	{
		{ x = 1246.43, y = 2743.07, z = 9.13 },
		{ x = -265.75, y = 2859.66, z = 14.14 },
	},

	target_positions =
	{
		{ x = -824.23, y = 1443.02, z = 6.7 },
		{ x = 561.39, y = 2418.29, z = 13.47 },
	},

	GetRespawnPosition = function( self, quest, team )
		if quest.stage <= 2 then
			return Vector3( 1428.896, 2721.899, 9.898 )
		else
			local location_id = quest:GetQuestData( "cp_location" )
			return Vector3( quest.quest_conf.respawn_positions[ location_id ][ team ] )
		end
	end,

	stages = 
	{
		[1] = 
		{
			is_mirrored = true,

			global = 
			{
				OnStarted = function( self, quest )
					local location_id = FORCED_QUEST_LOCATION or math.random( 1, 2 )
					quest:SetQuestData( "cp_location", location_id, true )

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

					quest:ToggleDriveBy( false )
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
							if quest.stage ~= 1 then return end
							if jacked then cancelEvent() end
						end)
					end,

					OnFinished = function( self, quest, team )
					end,

					OnStarted_Client = function( self, quest )
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
			global = 
			{
				OnStarted = function( self, quest )
					quest:SetTaskTimer( 60*5, function( )
						local failed_team = false

						if not quest:GetTeamData( 1, "reached_first_location" ) then
							failed_team = 1
						elseif not quest:GetTeamData( 2, "reached_first_location" ) then
							failed_team = 2
						end

						if failed_team then
							for k,v in pairs( quest.teams[ failed_team ] ) do
								v.element:TakeCoopQuestAttempts( 1 )
							end

							quest.failed = true
							quest:FinishQuest( )
							return
						end

						quest:FinishStage( )
					end)
				end,

				OnFinished = function( self, quest )
				end,

				OnFinished_Client = function( self )
				end,

				OnTeamDataChanged = function( self, quest, team, key, value )
					if key == "reached_first_location" then
						if quest:GetTeamData( team == 1 and 2 or 1, "reached_first_location" ) then
							quest:FinishStage( )
						end
					end
				end,
			},

			teams = 
			{
				[1] = 
				{
					task_name = "Заберите жир из больницы",

					OnStarted = function( self, quest, team )
						quest.quest_elements["start_vehicle"..team]:SetStatic( false )
					end,

					OnFinished = function( self, quest, team )
					end,

					OnStarted_Client = function( self )
						local quest_conf = GetCoopQuestConfig( )
						local cp_pos = quest_conf.item_positions[ 1 ]

						local target_point = TeleportPoint( {
							x = cp_pos.x, y = cp_pos.y, z = cp_pos.z,
							radius = 4,
							gps = true,
							dimension = localPlayer.dimension,
							keypress = false,
						} )

						target_point.accepted_elements = { vehicle = true, player = true }
						target_point.marker.markerType = "checkpoint"
						target_point.elements = {}
						target_point.elements.blip = createBlipAttachedTo(target_point.marker, 41, 5, 250, 100, 100)
						target_point.elements.blip.position = target_point.marker.position

						triggerEvent( "RefreshRadarBlips", localPlayer )

						target_point.PostJoin = function( self, element )
							if element == localPlayer then
								self:destroy( )
							end
						end

						CreateQuestItemPickup( cp_pos.x, cp_pos.y, cp_pos.z, 1, true )

						table.insert( COOP_QUEST_CLIENT_ELEMENTS, target_point )
						table.insert( COOP_QUEST_STAGE_ELEMENTS, target_point )
					end,
				},

				[2] = 
				{
					task_name = "Заберите глицерин с заправки",

					OnStarted = function( self, quest, team )
						quest.quest_elements["start_vehicle"..team]:SetStatic( false )
					end,

					OnFinished = function( self, quest, team )
					end,

					OnStarted_Client = function( self, quest )
						local quest_conf = GetCoopQuestConfig( )
						local cp_pos = quest_conf.item_positions[ 2 ]

						local target_point = TeleportPoint( {
							x = cp_pos.x, y = cp_pos.y, z = cp_pos.z,
							radius = 4,
							gps = true,
							dimension = localPlayer.dimension,
							keypress = false,
						} )

						target_point.accepted_elements = { vehicle = true, player = true }
						target_point.marker.markerType = "checkpoint"
						target_point.elements = {}
						target_point.elements.blip = createBlipAttachedTo(target_point.marker, 41, 5, 250, 100, 100)
						target_point.elements.blip.position = target_point.marker.position

						triggerEvent( "RefreshRadarBlips", localPlayer )

						target_point.PostJoin = function( self, element )
							if element == localPlayer then
								self:destroy( )
							end
						end

						CreateQuestItemPickup( cp_pos.x, cp_pos.y, cp_pos.z, 2, true )

						table.insert( COOP_QUEST_CLIENT_ELEMENTS, target_point )
						table.insert( COOP_QUEST_STAGE_ELEMENTS, target_point )
					end,
				},
			},
		},

		[3] = 
		{
			global = 
			{
				OnStarted = function( self, quest )
					quest:SetQuestData( "respawns_enabled", true, true )
					quest:ToggleImmortality( false )

					local cp_id = quest:GetQuestData( "cp_location" )
					local cp_pos = quest.quest_conf.target_positions[ cp_id ]

					local col = createColSphere( cp_pos.x, cp_pos.y, cp_pos.z, 8 )
					col.dimension = quest.dimension

					quest:PinElementToStage( col )
					quest.col_finish = col

					addEventHandler( "onColShapeHit", col, function( element, dim )
						if not dim then return end
						if getElementType( element ) ~= "player" then return end

						local team_counters = { 0, 0 }

						local col_players = getElementsWithinColShape( col, "player" )
						for k,v in pairs( col_players ) do
							local team_id = quest:GetPlayerTeam( v )
							if not team_id then return end

							local is_item_on_point = quest:GetQuestData( "item_on_point" )

							if quest:GetPlayerData( v, "holding_item" ) then
								team_counters[ team_id ] = team_counters[ team_id ] + 1

								if team_counters[ team_id ] >= ( is_item_on_point and 1 or 2 ) then
									quest:OnTeamWon( team_id )
									break
								end
							end
						end
					end)

					quest:SetTaskTimer( 10*60, function( ) 
						local team_counters = { 0, 0 }

						local col_players = getElementsWithinColShape( col, "player" )
						for k,v in pairs( col_players ) do
							local team_id = quest:GetPlayerTeam( v )
							if not team_id then return end

							if quest:GetPlayerData( v, "holding_item" ) then
								team_counters[ team_id ] = team_counters[ team_id ] + 1
							end
						end

						if team_counters[ 1 ] > team_counters[ 2 ] then
							quest:OnTeamWon( 1 )
						elseif team_counters[ 2 ] > team_counters[ 1 ] then
							quest:OnTeamWon( 2 )
						else
							quest:OnTeamWon( -1 )
						end
					end)
				end,

				OnFinished = function( self, quest )
				end,

				OnPlayerWasted = function( self, quest, player )
					if quest:GetPlayerData( player, "holding_item" ) then
						OnPlayerTryDropQuestItem( player )
					end
				end,

				OnStarted_Client = function( self )
					local cp_id = GetCoopQuestData( "cp_location" )
					local cp_pos = GetCoopQuestConfig().target_positions[ cp_id ]

					local target_point = TeleportPoint( {
						x = cp_pos.x, y = cp_pos.y, z = cp_pos.z,
						radius = 8,
						gps = true,
						dimension = localPlayer.dimension,
						keypress = false,
					} )

					target_point.accepted_elements = { player = true }
					target_point.marker.markerType = "checkpoint"
					target_point.elements = {}
					target_point.elements.blip = createBlipAttachedTo(target_point.marker, 41, 5, 250, 100, 100)
					target_point.elements.blip.position = target_point.marker.position

					triggerEvent( "RefreshRadarBlips", localPlayer )

					target_point.PostJoin = function( self, element )
					end

					table.insert( COOP_QUEST_CLIENT_ELEMENTS, target_point )
					table.insert( COOP_QUEST_STAGE_ELEMENTS, target_point )
				end
			},

			teams = 
			{
				[1] = 
				{
					task_name = "Убей вражескую команду и отбери глицерин",

					OnStarted = function( self, quest, team )
					end,

					OnFinished = function( self, quest, team )
					end,
				},

				[2] = 
				{
					task_name = "Убей вражескую команду и отбери жир",

					OnStarted = function( self, quest, team )
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
		CleanUpQuestItemPickups( )
		StopItemMinigame( )
	end
}