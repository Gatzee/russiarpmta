loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )
Extend( "CAI" )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )

local TARGET_ELEMENT = nil

function WatchToElement( state, element )
	removeEventHandler( "onClientPreRender", root, UpdateCamera )
	TARGET_ELEMENT = nil
	if state then
		TARGET_ELEMENT = element
		addEventHandler( "onClientPreRender", root, UpdateCamera )
	end
end

function UpdateCamera()
	if isElement( TARGET_ELEMENT ) then
		local x, y, z = getCameraMatrix()
		local look = TARGET_ELEMENT.position
		setCameraMatrix( x, y, z, look.x, look.y, look.z )
	end
end

function AddEnterVehiclePattern( ped, vehicle, seat, callback, ... )
	AddAIPedPatternInQueue( ped, AI_PED_PATTERN_VEHICLE_ENTER, {
		vehicle = vehicle;
		seat = seat;
		end_callback = {
			func = callback or (function() return true end),
			args = { ... },
		}
	} )
end

function AddExitVehiclePattern( ped, callback, ... )
	AddAIPedPatternInQueue( ped, AI_PED_PATTERN_VEHICLE_EXIT, { 
		end_callback = {
			func = callback or (function() return true end),
			args = { ... },
		}
	} )
end