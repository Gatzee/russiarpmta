loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )

POINTS = {
	{ x = -393.564, y = -1748.316 + 860, z = 20.797 },
	{ x = 498.196, y = -1655.166 + 860, z = 20.749 },
	{ x = -816.864, y = -1224.219 + 860, z = 15.790 },
	{ x = -1033.049, y = -687.950 + 860, z = 22.925 },
	{ x = -2099.443, y = 476.655 + 860, z = 17.915 },
	{ x = 418.626, y = -867.653, z = 21.00 },
	{ x = 687.254, y = -160.564 + 860, z = 20.701 },
	{ x = 2375.194, y = -1742.761 + 860, z = 73.924 },
	{ x = 1905.213, y = -752.251 + 860, z = 60.707 },
	{ x = 2496.150, y = 2561.761 + 860, z = 7.872 },
	{ x = -729.659, y = 2185.247 + 860, z = 19.539 },

}

addEvent( "onPlayerGotPointInMedicTask5", true )

addEventHandler( "onClientResourceStart", resourceRoot, function ( )
	CQuest( QUEST_DATA )
end )