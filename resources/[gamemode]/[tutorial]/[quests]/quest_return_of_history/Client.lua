loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )
Extend( "CAI" )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )

function WatchToLocalPlayerVehicle( state )
	removeEventHandler( "onClientPreRender", root, UpdateCamera )
	if state then
		addEventHandler( "onClientPreRender", root, UpdateCamera )
	end
end

function UpdateCamera()
	local veh = getPedOccupiedVehicle( localPlayer )
	if veh then
		local x, y, z = getCameraMatrix()
		local look = veh.position
		setCameraMatrix( x, y, z, look.x, look.y, look.z )
	end
end

function CreateGates( positions )
	GEs.west_gates = createObject( 6282, positions.west_gates.pos, positions.west_gates.rot )
	setObjectScale( GEs.west_gates, 1.13 )
	LocalizeQuestElement( GEs.west_gates )
end