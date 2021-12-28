loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )
Extend( "CAI" )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )

function CreateFollowInterface()
	GEs.follows = {}
	GEs.StartFolowPedToPlayer = function( ped )
		GEs.follows[ ped ] = CreatePedFollow( ped )
		GEs.follows[ ped ].distance = 3
		GEs.follows[ ped ]:start( localPlayer )
	end

	GEs.StopFollowToPlayer = function( ped )
		if GEs.follows[ ped ] then
			GEs.follows[ ped ]:destroy()
		end
	end
end

function DestroyFollowInterface()
	GEs.follows = nil
end


function CreateFollowHandlers( bots )
	if not GEs.handlers then
		GEs.handlers = {}
	end
	
	GEs.handlers.bots = bots
	
	GEs.handlers.OnPlayerVehicleEnter = function()
		if not GEs.handlers then return end

		for k, v in pairs( bots ) do
			if isElement( v ) then
				GEs.StopFollowToPlayer( v )
				AddAIPedPatternInQueue( v, AI_PED_PATTERN_VEHICLE_ENTER, {
					vehicle = localPlayer.vehicle;
					seat = k;
				} )
			end
		end
	end
	addEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.handlers.OnPlayerVehicleEnter )

	GEs.handlers.OnPlayerVehicleExit = function()
		if not GEs.handlers then return end

		for k, v in pairs( bots ) do
			if isElement( v ) then
				AddAIPedPatternInQueue( v, AI_PED_PATTERN_VEHICLE_EXIT, {
					end_callback = {
						func = function()
							GEs.StartFolowPedToPlayer( v )
						end,
						args = { },
					}
				} )
			end
		end
	end
	addEventHandler( "onClientPlayerVehicleExit", localPlayer, GEs.handlers.OnPlayerVehicleExit )
end

function DestroyFollowHandlers()
	if GEs.handlers and GEs.handlers.bots then
		for k, v in pairs( GEs.handlers.bots ) do
			GEs.StopFollowToPlayer( v )
		end
	end

	removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.handlers.OnPlayerVehicleEnter )
	removeEventHandler( "onClientPlayerVehicleExit", localPlayer, GEs.handlers.OnPlayerVehicleExit )
end