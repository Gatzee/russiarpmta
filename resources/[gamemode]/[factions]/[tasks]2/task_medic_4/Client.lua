loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "ShSkin" )

addEventHandler( "onClientResourceStart", resourceRoot, function ( )
	CQuest( QUEST_DATA )

	for i, v in pairs( POSITIONS.patient ) do
		local model = BOUTIQUE_LIST[ math.random( 1, #BOUTIQUE_LIST ) ].id
		local ped = Ped( model, Vector3( v ) )

		ped.dimension = v.dimension
		ped.interior = v.interior
		ped:setAnimation( "INT_HOUSE","BED_Loop_L", -1, true, false, false, false )
		ped.collisions = false
		ped.frozen = true
	end
end )