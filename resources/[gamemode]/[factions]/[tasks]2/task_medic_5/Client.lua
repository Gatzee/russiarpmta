loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )

POINTS = {
	{ x = -393.564, y = -1748.316, z = 20.797 },
	{ x = 498.196, y = -1655.166, z = 20.749 },
	{ x = -816.864, y = -1224.219, z = 15.790 },
	{ x = -1033.049, y = -687.950, z = 22.925 },
	{ x = -2099.443, y = 476.655, z = 17.915 },
	{ x = 37.638, y = 367.910, z = 20.697 },
	{ x = 687.254, y = -160.564, z = 20.701 },
	{ x = 2375.194, y = -1742.761, z = 73.924 },
	{ x = 1905.213, y = -752.251, z = 60.707 },
	{ x = 2496.150, y = 2561.761, z = 7.872 },
	{ x = -729.659, y = 2185.247, z = 19.539 },
	{ x = -2090.016, y = 2825.249, z = 3.397 },
	{ x = 1246.691, y = 2231.052, z = 8.810 },
	{ x = 2152.875, y = 2649.428, z = 7.877 },
}

addEvent( "onPlayerGotPointInMedicTask5", true )

addEventHandler( "onClientResourceStart", resourceRoot, function ( )
	CQuest( QUEST_DATA )
end )