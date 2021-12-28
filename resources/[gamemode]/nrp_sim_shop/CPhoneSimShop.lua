loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CInterior" )
Extend( "CPlayer" )
Extend( "ib" )
Extend( "ShUtils" )

SIM_POSITIONS = {
	{ x = 35.424530029297, y = -2255.6300048828, z = 20.823999404907 },
	{ x = 382.8244934082, y = -2020.3588867188, z = 20.979698181152 },
	{ x = 336.38983154297, y = -1914.7312011719, z = 20.97608757019 },
	{ x = 112.01319122314, y = -1766.7988891602, z = 20.984712600708 },
	{ x = 40.266139984131, y = -1649.526550293, z = 20.820650100708 },
	{ x = 239.34432983398, y = -1544.0877685547, z = 20.900699615479 },
	{ x = 46.018810272217, y = -1390.8857421875, z = 20.807649612427 },
	{ x = -303.95001220703, y = -1565.5916137695, z = 21.000272750854 },
	{ x = -170.32562255859, y = -1807.4286499023, z = 21.018600463867 },
	{ x = -487.79162597656, y = -1773.0534057617, z = 20.992853164673 },
	{ x = -653.33453369141, y = -1940.8101806641, z = 21.002540588379 },
	{ x = -1340.7576904297, y = -1724.0159912109, z = 21.004560470581 },
	{ x = -1035.2707519531, y = -1653.3114624023, z = 20.996049880981 },
	{ x = -1218.1373291016, y = -1514.2189331055, z = 21.064565658569 },
	{ x = -1262.8510742188, y = -1221.0014648438, z = 21.062145233154 },
	{ x = -879.91162109375, y = -1514.7028808594, z = 20.995609283447 },
	{ x = -738.77398681641, y = -1756.852722168, z = 20.993774414063 },
	{ x = 417.4499206543, y = -1203.6719970703, z = 20.804653167725 },
	{ x = 285.10861206055, y = -1658.307434082, z = 21.003314971924 },
	{ x = 642.26599121094, y = -1940.8426513672, z = 20.970874786377 },
	{ x = 430.25173950195, y = -2342.2554931641, z = 20.817932128906 },
	{ x = 250.8572845459, y = -2234.8594970703, z = 20.83603477478 },
	{ x = -492.53771972656, y = 673.8098144531, z = 20.907375335693 },
	{ x = -335.51867675781, y = 673.9166259766, z = 20.907375335693 },
	{ x = -44.1018409729, y = 674.0233154297, z = 20.909950256348 },
	{ x = -153.12530517578, y = 612.7897949219, z = 20.90912437439 },
	{ x = -121.85342407227, y = 519.3044433594, z = 20.90912437439 },
	{ x = -316.51364135742, y = 519.1293945313, z = 20.908863067627 },
	{ x = -470.46362304688, y = 380.2349853516, z = 20.908863067627 },
	{ x = -327.42028808594, y = 382.6452636719, z = 20.908863067627 },
	{ x = 392.05212402344, y = -139.37713623047, z = 20.906700134277 },
	{ x = 2142.2006835938, y = -1119.6155090332, z = 60.672527313232 },
	{ x = 1845.8122558594, y = -878.25889587402, z = 60.628547668457 },
	{ x = 1931.9057617188, y = -808.35578155518, z = 60.628547668457 },
	{ x = 1756.0170898438, y = -680.63516235352, z = 60.612922668457 },
	{ x = 2192.8869628906, y = -1095.8086090088, z = 60.620346069336 },
	{ x = 2053.4372558594, y = -953.06842041016, z = 60.680335998535 },
	{ x = 2167.4338378906, y = -908.79138183594, z = 60.614608764648 },
	{ x = 363.57641601563, y = -1791.6834716797, z = 20.975212097168 },
	{ x = 393.87841796875, y = -1523.4696044922, z = 20.971012115467 },
	{ x = 341.70303344727, y = -2119.1904296875, z = 20.847059249878 },
	{ x = 465.42675781252, y = -2187.4320068359, z = 20.793287277222 },
	{ x = 214.94369506836, y = -2532.6779785156, z = 20.826738357544 },
}

for i, n in pairs( SIM_POSITIONS ) do

	local config = { }
	config.elements = { }
	config.x, config.y, config.z = n.x, n.y + 860, n.z

	config.radius = 2
	config.marker_text = "Магазин\nСим-карт"
	config.keypress = "lalt"
	config.text = "ALT Взаимодействие"

	tpoint = TeleportPoint( config )
	
	tpoint.marker:setColor( 0, 190, 245, 50 )
	tpoint:SetImage( { "img/marker_icon.png", 255, 255, 255, 255, 1.1 } )
	tpoint.element:setData( "material", true, false )
	
    tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 190, 245, 245, 1.45 } )
	
	tpoint.PostJoin = function( self, player )
		triggerServerEvent( "onSimShopJoinRequest", resourceRoot )
	end

	tpoint.PostLeave = function( self, player )
		ShowSimShopUI_handler( false )
	end

end

function GetSIMShopPositions()
	return SIM_POSITIONS
end