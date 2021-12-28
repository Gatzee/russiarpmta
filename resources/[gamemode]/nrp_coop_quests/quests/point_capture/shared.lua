POINT_STATE_NEUTRAL = 1
POINT_STATE_CAPTURING = 2
POINT_STATE_CAPTURED = 3
POINT_STATE_CONFLICT = 4

ZONE_STATUS_UPDATE_INTERVAL = 1
CAPTURE_ZONE_RADIUS = 7
CAPTURE_TOTAL_DURATION = 5*60

TEAM_COLORS = 
{
	{ 50, 200, 50 },
	{ 200, 50, 50 },
}

COOP_QUESTS_CONFIG[ QUEST_TYPE_POINT_CAPTURE ] = 
{
	name = "Удержание",
	desc = "На удержании точки вам с напарником предстоит первым удержать точку в течение заданного времени.",

	respawn_positions = 
	{
		{ x = 292.132, y = 1985.044, z = 8.496 },
		{ x = 660.319, y = 1978.671, z = 11.70 },
	},

	cp_positions = 
	{
		{ 
			point = { x = 2400.17, y = 2746.12, z = 6.94 },
			respawn_positions = 
			{
				{ x = 2222.597, y = 2733.532, z = 7.871 },
				{ x = 2569.536, y = 2685.318, z = 8.074 },
			},
		},
		{
			point = { x = -1489.76, y = 2245.28, z = 10.13 },
			respawn_positions = 
			{
				{ x = -1369.224, y = 2113.482, z = 10.924 },
				{ x = -1594.402, y = 2386.520, z = 10.224 },
			},
		},
	},

	GetRespawnPosition = function( self, quest, team )
		local location_id = quest:GetQuestData( "cp_location" )
		return Vector3( quest.quest_conf.cp_positions[ location_id ].respawn_positions[team] )
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
					quest:SetTaskTimer( 100, function( ) 
						quest:FinishStage( )
					end)
				end,

				OnFinished = function( self, quest )
				end,

				OnStarted_Client = function( self )
					CreateControlPointObjects( )
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
					task_name = "Доберитесь до цели",

					OnStarted = function( self, quest, team )
						quest.quest_elements["start_vehicle"..team]:SetStatic( false )
					end,

					OnFinished = function( self, quest, team )
					end,

					OnStarted_Client = function( self, quest )
						local cp_id = GetCoopQuestData( "cp_location" )
						local quest_conf = GetCoopQuestConfig( )
						local cp_pos = quest_conf.cp_positions[ cp_id ].point

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
								SetTeamData( "reached_first_location", true )
								self:destroy( )
							end
						end

						table.insert( COOP_QUEST_CLIENT_ELEMENTS, target_point )
						table.insert( COOP_QUEST_STAGE_ELEMENTS, target_point )
					end,
				},
			},
		},

		[3] = 
		{
			is_mirrored = true,

			global = 
			{
				OnStarted = function( self, quest )
					quest:SetQuestData( "respawns_enabled", true, true )
					quest:ToggleImmortality( false )

					local cp_id = quest:GetQuestData( "cp_location" )
					local cp_pos = quest.quest_conf.cp_positions[ cp_id ].point
					local cp_config = 
					{
						x = cp_pos.x,
						y = cp_pos.y,
						z = cp_pos.z,
						dimension = quest.dimension,
					}

					local control_point = CreateControlPoint( cp_config, quest )

					quest.quest_elements.control_point = control_point

					quest:SetTaskTimer( 15*60, function( ) 
						control_point:OnGlobalTimeExpired( )
					end)
				end,

				OnFinished = function( self, quest )
				end,
			},

			teams = 
			{
				[1] = 
				{
					task_name = "Захватите и удержите точку",

					OnStarted = function( self, quest, team )
					end,

					OnFinished = function( self, quest, team )
					end,

					OnStarted_Client = function( self )
						local cp_id = GetCoopQuestData( "cp_location" )
						local quest_conf = GetCoopQuestConfig( )
						local cp_pos = quest_conf.cp_positions[ cp_id ].point

						ShowUI_ControlPoints( true, { time_left = 15*60, scores = { 0, 0 }, position = cp_pos } )
					end,

					OnFinished_Client = function( self )
						ShowUI_ControlPoints( false )
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
		DestroyControlPointObjects( )
	end,
}