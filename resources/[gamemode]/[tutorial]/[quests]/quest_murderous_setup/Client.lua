loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )
Extend( "CAI" )

ibUseRealFonts( true )

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

function OnPlayerVehicleEnter()
	if not GEs.handlers then return end

	for k, v in pairs( GEs.handlers.bots ) do
		if isElement( v ) then
			GEs.StopFollowToPlayer( v )
			AddAIPedPatternInQueue( v, AI_PED_PATTERN_VEHICLE_ENTER, {
				vehicle = localPlayer.vehicle;
				seat = k;
			} )
		end
	end
end

function OnPlayerVehicleExit()
	if not GEs.handlers then return end

	for k, v in pairs( GEs.handlers.bots ) do
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

function CreateFollowHandlers( bots )
	if not GEs.handlers then 
		CreateFollowInterface()
		GEs.handlers = {} 
	end
	
	GEs.handlers.bots = bots
	
	
	addEventHandler( "onClientPlayerVehicleEnter", localPlayer, OnPlayerVehicleEnter )
	addEventHandler( "onClientPlayerVehicleExit", localPlayer, OnPlayerVehicleExit )

	for k, v in pairs( GEs.handlers.bots ) do
		GEs.StartFolowPedToPlayer( v )
	end
end

function DestroyFollowHandlers()
	if GEs.handlers then
		if GEs.handlers.bots then
			for k, v in pairs( GEs.handlers.bots ) do
				GEs.StopFollowToPlayer( v )
			end
		end
	end

	removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, OnPlayerVehicleEnter )
	removeEventHandler( "onClientPlayerVehicleExit", localPlayer, OnPlayerVehicleExit )
end