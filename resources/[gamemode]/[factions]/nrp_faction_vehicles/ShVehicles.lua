loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShVehicleConfig" )

--[[
	Посвещаю это сообщение капотнику ебаному.
	Чтоб твой рот негры выебали за кривые машины,
	За полное отсутствие закономерности в пеинтджобах,
	За рандомное наличие или отсутствие мигалок на крышах,
	За кривую Камри (ты как посмел блять?),
	За смесь ДПС и ППС в одном пеинджобе у Приоры и Панамеры (ну не ебанат ли?),
	И за 2 и более капотов у большинства машин.
	Респект тебе, конина ебаная.
]]

FACTION_VEHICLES_LIST = 
{
	------------------- ДПС НСК -----------------------
	-- Priora
	{ city = 0, x = 359.9, y = -2058.9 + 860, z = 20.5, iModel = 540, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 }  };
	{ city = 0, x = 355.3, y = -2058.9 + 860, z = 20.5, iModel = 540, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 }  };
	{ city = 0, x = 358.3, y = -2066.72 + 860, z = 20.5, iModel = 540, rz = 90, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 }  };
	{ city = 0, x = 358.3, y = -2070.57 + 860, z = 20.5, iModel = 540, rz = 90, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 }  };
	{ city = 0, x = 358.3, y = -2074.5 + 860, z = 20.5, iModel = 540, rz = 90, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 }  };
	{ city = 0, x = 359.9, y = -2082.3 + 860, z = 20.5, iModel = 540, rz = 0, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 }  };
	
	-- Panamera
	{ city = 0, x = 322.3, y = -2058.9 + 860,  z =20.4, iModel = 580, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = 326.3, y = -2058.9 + 860,  z =20.4, iModel = 580, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = 330.3, y = -2058.9 + 860,  z =20.4, iModel = 580, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = 334.3, y = -2058.9 + 860,  z =20.4, iModel = 580, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = 338.3, y = -2058.9 + 860,  z =20.4, iModel = 580, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	-- Mercedes G65
	{ city = 0, x = 322.3, y = -2058.9 + 860,  z =20.4, iModel = 579, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = 326.3, y = -2058.9 + 860,  z =20.4, iModel = 579, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = 330.3, y = -2058.9 + 860,  z =20.4, iModel = 579, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = 334.3, y = -2058.9 + 860,  z =20.4, iModel = 579, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = 338.3, y = -2058.9 + 860,  z =20.4, iModel = 579, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	-- Camry
	{ city = 0, x = 322.3, y = -2058.9 + 860,  z =20.4, iModel = 420, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 3, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = 326.3, y = -2058.9 + 860,  z =20.4, iModel = 420, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 3, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = 330.3, y = -2058.9 + 860,  z =20.4, iModel = 420, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 3, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = 334.3, y = -2058.9 + 860,  z =20.4, iModel = 420, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 3, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = 338.3, y = -2058.9 + 860,  z =20.4, iModel = 420, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 3, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	-- 2114
	{ city = 0, x = 322.3, y = -2058.9 + 860,  z =20.4, iModel = 426, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = 326.3, y = -2058.9 + 860,  z =20.4, iModel = 426, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = 330.3, y = -2058.9 + 860,  z =20.4, iModel = 426, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = 334.3, y = -2058.9 + 860,  z =20.4, iModel = 426, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = 338.3, y = -2058.9 + 860,  z =20.4, iModel = 426, rz = 180, pColor = {255,255,255}, iFaction = F_POLICE_DPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };

	------------------- ДПС ГОРКИ -----------------------
	-- Priora
	{ city = 1, x = 2173.7868, y = -614.294 + 860, z = 60.40, iModel = 540, rz = 40, pColor = {255,255,255}, iFaction = F_POLICE_DPS_GORKI, iMinLevel = 1, iPaintjob = 0,tuning_external = { [ TUNING_SIREN ] = 2 }  };
	{ city = 1, x = 2177.5634, y = -611.93 + 860, z = 60.40, iModel = 540, rz = 40, pColor = {255,255,255}, iFaction = F_POLICE_DPS_GORKI, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 }  };
	{ city = 1, x = 2180.54, y = -609.2895 + 860, z = 60.40, iModel = 540, rz = 40, pColor = {255,255,255}, iFaction = F_POLICE_DPS_GORKI, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 }  };
	{ city = 1, x = 2171.3662, y = -617.04 + 860, z = 60.40, iModel = 540, rz = 40, pColor = {255,255,255}, iFaction = F_POLICE_DPS_GORKI, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 }  };
	-- Panamera
	{ city = 1, x = 2228.8525, y = -672.1023 + 860, z = 60.40, iModel = 580, rz = 220, pColor = {255,255,255}, iFaction = F_POLICE_DPS_GORKI, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 1, x = 2225.9157, y = -674.7417 + 860, z = 60.40, iModel = 580, rz = 220, pColor = {255,255,255}, iFaction = F_POLICE_DPS_GORKI, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 1, x = 2222.7399, y = -676.0269 + 860, z = 60.40, iModel = 580, rz = 220, pColor = {255,255,255}, iFaction = F_POLICE_DPS_GORKI, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	-- Mercedes G65
	{ city = 1, x = 2234.5085, y = -659.4675 + 860, z = 60.40, iModel = 579, rz = 280, pColor = {255,255,255}, iFaction = F_POLICE_DPS_GORKI, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 1, x = 2237.2241, y = -662.6798 + 860, z = 60.40, iModel = 579, rz = 280, pColor = {255,255,255}, iFaction = F_POLICE_DPS_GORKI, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 1, x = 2231.7331, y = -669.4674 + 860, z = 60.40, iModel = 579, rz = 220, pColor = {255,255,255}, iFaction = F_POLICE_DPS_GORKI, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	-- Camry
	{ city = 1, x = 2227.2900, y = -650.0603 + 860, z = 60.40, iModel = 420, rz = 280, pColor = {255,255,255}, iFaction = F_POLICE_DPS_GORKI, iMinLevel = 3, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 1, x = 2229.6601, y = -653.3068 + 860, z = 60.40, iModel = 420, rz = 280, pColor = {255,255,255}, iFaction = F_POLICE_DPS_GORKI, iMinLevel = 3, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 1, x = 2232.4010, y = -656.24 + 860, z = 60.40, iModel = 420, rz = 280, pColor = {255,255,255}, iFaction = F_POLICE_DPS_GORKI, iMinLevel = 3, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	-- Lada 2114
	{ city = 1, x = 2188.0981, y = -604.6372 + 860, z = 60.40, iModel = 426, rz = 340, pColor = {255,255,255}, iFaction = F_POLICE_DPS_GORKI, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 1, x = 2190.9628, y = -608.0002 + 860, z = 60.40, iModel = 426, rz = 340, pColor = {255,255,255}, iFaction = F_POLICE_DPS_GORKI, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 1, x = 2193.5100, y = -611.03 + 860, z = 60.40, iModel = 426, rz = 340, pColor = {255,255,255}, iFaction = F_POLICE_DPS_GORKI, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };

	----------------- ППС НСК --------------------------
	-- Accord
	{ city = 0, x = -416.8, y = -1658.6 + 860, z = 20.5, iModel = 546, rz = 275, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 4, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -416.2, y = -1662.2 + 860, z = 20.5, iModel = 546, rz = 275, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 4, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -415.8, y = -1669.2 + 860, z = 20.5, iModel = 546, rz = 275, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 4, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -415.1, y = -1676.6 + 860, z = 20.5, iModel = 546, rz = 275, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 4, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -416.1, y = -1665.8 + 860, z = 20.5, iModel = 546, rz = 275, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 4, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -415.2, y = -1672.7 + 860, z = 20.5, iModel = 546, rz = 275, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 4, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	-- Camry
	{ city = 0, x = -416.8, y = -1658.6 + 860, z = 20.5, iModel = 420, rz = 275, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 5, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -416.2, y = -1662.2 + 860, z = 20.5, iModel = 420, rz = 275, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 5, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -415.8, y = -1669.2 + 860, z = 20.5, iModel = 420, rz = 275, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 5, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -415.1, y = -1676.6 + 860, z = 20.5, iModel = 420, rz = 275, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 5, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -416.1, y = -1665.8 + 860, z = 20.5, iModel = 420, rz = 275, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 5, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -415.2, y = -1672.7 + 860, z = 20.5, iModel = 420, rz = 275, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 5, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	-- Hunter
	{ city = 0, x = -410.4, y = -1687.8 + 860, z = 20.5, iModel = 400, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -406.7, y = -1687.6 + 860, z = 20.5, iModel = 400, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -403.5, y = -1687.3 + 860, z = 20.5, iModel = 400, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -400.1, y = -1687 + 860, z = 20.5, iModel = 400, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -396.4, y = -1686.7 + 860, z = 20.5, iModel = 400, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -393, y = -1686.3 + 860, z = 20.5, iModel = 400, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -389.5, y = -1686.3 + 860, z = 20.5, iModel = 400, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -385.7, y = -1686 + 860, z = 20.5, iModel = 400, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -382, y = -1685.8 + 860, z = 20.5, iModel = 400, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	-- Panamera
	{ city = 0, x = -364.7, y = -1684.6 + 860, z = 20.3, iModel = 580, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 6, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -368.1, y = -1684.8 + 860, z = 20.3, iModel = 580, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 6, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -371.5, y = -1685.1 + 860, z = 20.3, iModel = 580, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 6, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -375.5, y = -1685.3 + 860, z = 20.3, iModel = 580, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 6, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -378.5, y = -1685.5 + 860, z = 20.3, iModel = 580, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 6, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	-- 2114
	{ city = 0, x = -364.7, y = -1684.6 + 860, z = 20.3, iModel = 426, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 2, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -368.1, y = -1684.8 + 860, z = 20.3, iModel = 426, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 2, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -371.5, y = -1685.1 + 860, z = 20.3, iModel = 426, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 2, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -375.5, y = -1685.3 + 860, z = 20.3, iModel = 426, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 2, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -378.5, y = -1685.5 + 860, z = 20.3, iModel = 426, rz = 3, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_NSK, iMinLevel = 2, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };

	----------------- ППС ГОРКИ --------------------------
	-- Accord
	{ city = 1, x = 1932.45, y = -686.27 + 860, z = 60.43, iModel = 546, rz = 305, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_GORKI, iMinLevel = 4, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 1, x = 1934.9, y = -689.99 + 860, z = 60.43, iModel = 546, rz = 305, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_GORKI, iMinLevel = 4, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 1, x = 1936.89, y = -693.52 + 860, z = 60.43, iModel = 546, rz = 305, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_GORKI, iMinLevel = 4, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	-- Camry
	{ city = 1, x = 1939.36, y = -696.12 + 860, z = 60.43, iModel = 420, rz = 305, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_GORKI, iMinLevel = 5, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 1, x = 1942.01, y = -699.76 + 860, z = 60.43, iModel = 420, rz = 305, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_GORKI, iMinLevel = 5, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 1, x = 1943.97, y = -703.16 + 860, z = 60.43, iModel = 420, rz = 305, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_GORKI, iMinLevel = 5, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	-- Panamera
	{ city = 1, x = 1935.84, y = -711.94 + 860, z = 60.43, iModel = 580, rz = 240, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_GORKI, iMinLevel = 6, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 1, x = 1932, y = -714.33 + 860, z = 60.43, iModel = 580, rz = 240, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_GORKI, iMinLevel = 6, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 1, x = 1929.41, y = -716.88 + 860, z = 60.43, iModel = 580, rz = 240, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_GORKI, iMinLevel = 6, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	-- Hunter
	{ city = 1, x = 1918.61, y = -688.28 + 860, z = 60.43, iModel = 400, rz = 8, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_GORKI, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 1, x = 1929.9, y = -683.25 + 860, z = 60.43, iModel = 400, rz = 305, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_GORKI, iMinLevel = 1, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	-- 2114
	{ city = 1, x = 1909, y = -695.41 + 860, z = 60.43, iModel = 426, rz = 8, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_GORKI, iMinLevel = 2, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 1, x = 1911.87, y = -692.81 + 860, z = 60.43, iModel = 426, rz = 8, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_GORKI, iMinLevel = 2, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 1, x = 1915.6, y = -689.99 + 860, z = 60.43, iModel = 426, rz = 8, pColor = { 255, 255, 255 }, iFaction = F_POLICE_PPS_GORKI, iMinLevel = 2, iPaintjob = 1, tuning_external = { [ TUNING_SIREN ] = 2 } };
	
	----------------- Медики НСК --------------------------
	-- Ford Transit
	{ city = 0, x = 494.897, y = -2439.314 + 860, z = 20.969, iModel = 416, rz = 90, iFaction = F_MEDIC, iMinLevel = 1 };
	{ city = 0, x = 495.01, y = -2444.224 + 860, z = 20.969, iModel = 416, rz = 90, iFaction = F_MEDIC, iMinLevel = 1 };
	{ city = 0, x = 494.793, y = -2435.246 + 860, z = 20.969, iModel = 416, rz = 90, iFaction = F_MEDIC, iMinLevel = 1 };
	{ city = 0, x = 495.069, y = -2431.096 + 860, z = 20.969, iModel = 416, rz = 90, iFaction = F_MEDIC, iMinLevel = 1 };
	{ city = 0, x = 494.538, y = -2426.67 + 860, z = 20.969, iModel = 416, rz = 90, iFaction = F_MEDIC, iMinLevel = 1 };
	-- Газель
	{ city = 0, x = 494.897, y = -2439.314 + 860, z = 20.969, iModel = 482, rz = 90, iFaction = F_MEDIC, iMinLevel = 1, iPaintjob = 0 };
	{ city = 0, x = 495.01, y = -2444.224 + 860, z = 20.969, iModel = 482, rz = 90, iFaction = F_MEDIC, iMinLevel = 1, iPaintjob = 0 };
	{ city = 0, x = 494.793, y = -2435.246 + 860, z = 20.969, iModel = 482, rz = 90, iFaction = F_MEDIC, iMinLevel = 1, iPaintjob = 0 };
	{ city = 0, x = 495.069, y = -2431.096 + 860, z = 20.969, iModel = 482, rz = 90, iFaction = F_MEDIC, iMinLevel = 1, iPaintjob = 0 };
	{ city = 0, x = 494.538, y = -2426.67 + 860, z = 20.969, iModel = 482, rz = 90, iFaction = F_MEDIC, iMinLevel = 1, iPaintjob = 0 };
	-- Civic
	{ city = 0, x = 461.83, y = -2507.242 + 860, z = 20.221, iModel = 436, rz = 90, iFaction = F_MEDIC, iMinLevel = 3, iPaintjob = 0 };
	{ city = 0, x = 482.621, y = -2513.144 + 860, z = 20.221, iModel = 436, rz = 0, iFaction = F_MEDIC, iMinLevel = 3, iPaintjob = 0 };
	{ city = 0, x = 447.545, y = -2515.59 + 860, z = 20.221, iModel = 436, rz = 0, iFaction = F_MEDIC, iMinLevel = 3, iPaintjob = 0 };
	-- Niva
	{ city = 0, x = 470.377, y = -2459.13 + 860, z = 20.727, iModel = 543, rz = 0, iFaction = F_MEDIC, pColor = { 255, 255, 255 }, iMinLevel = 1, iPaintjob = 0 };
	{ city = 0, x = 474.377, y = -2459.13 + 860, z = 20.727, iModel = 543, rz = 0, iFaction = F_MEDIC, pColor = { 255, 255, 255 }, iMinLevel = 1, iPaintjob = 0 };
	{ city = 0, x = 478.377, y = -2459.13 + 860, z = 20.727, iModel = 543, rz = 0, iFaction = F_MEDIC, pColor = { 255, 255, 255 }, iMinLevel = 1, iPaintjob = 0 };
	{ city = 0, x = 482.377, y = -2459.13 + 860, z = 20.727, iModel = 543, rz = 0, iFaction = F_MEDIC, pColor = { 255, 255, 255 }, iMinLevel = 1, iPaintjob = 0 };
	{ city = 0, x = 486.377, y = -2459.13 + 860, z = 20.727, iModel = 543, rz = 0, iFaction = F_MEDIC, pColor = { 255, 255, 255 }, iMinLevel = 1, iPaintjob = 0 };

	----------------- Медики ГОРКИ --------------------------
	-- Civic
	{ city = 1, x = 1922.44, y = -514.81 + 860, z = 60.38, iModel = 436, rz = 336.97, iFaction = F_MEDIC, pColor = { 255, 255, 255 }, iMinLevel = 3, iPaintjob = 0 };
	-- Niva
	{ city = 1, x = 1919.17, y = -513.63 + 860, z = 60.46, iModel = 543, rz = 340.75, iFaction = F_MEDIC, pColor = { 255, 255, 255 }, iMinLevel = 1, iPaintjob = 0 };
	-- Газель
	{ city = 1, x = 1907.95, y = -507.64 + 860, z = 60.9, iModel = 482, rz = 291.26, iFaction = F_MEDIC, pColor = { 255, 255, 255 }, iMinLevel = 1, iPaintjob = 0 };
	-- Transit
	{ city = 1, x = 1922.44, y = -514.81 + 860, z = 60.38, iModel = 416, rz = 336.97, iFaction = F_MEDIC, pColor = { 255, 255, 255 }, iMinLevel = 1 };

	----------------- Армия --------------------------
	{ city = 0, x = -2356.5, y = 58.5 + 860, z = 20.2, iModel = 400, rz = 180, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 1, };
	{ city = 0, x = -2350.8, y = 58.5 + 860, z = 20.2, iModel = 400, rz = 180, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 1, };
	{ city = 0, x = -2344.9, y = 58.5 + 860, z = 20.2, iModel = 400, rz = 180, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 1, };
	{ city = 0, x = -2339.0, y = 58.5 + 860, z = 20.2, iModel = 400, rz = 180, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 1, };
	{ city = 0, x = -2333.6, y = 58.5 + 860, z = 20.2, iModel = 400, rz = 180, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 1, };
	{ city = 0, x = -2327.7, y = 58.5 + 860, z = 20.2, iModel = 400, rz = 180, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 1, };
	{ city = 0, x = -2321.7, y = 58.5 + 860, z = 20.2, iModel = 400, rz = 180, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 1, };
	{ city = 0, x = -2315.7, y = 58.5 + 860, z = 20.2, iModel = 400, rz = 180, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 1, };

	{ city = 0, x = -2356.5, y = 65.5 + 860, z = 20.2, iModel = 540, rz = 0, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 1, };
	{ city = 0, x = -2350.8, y = 65.5 + 860, z = 20.2, iModel = 540, rz = 0, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 1, };
	{ city = 0, x = -2344.9, y = 65.5 + 860, z = 20.2, iModel = 540, rz = 0, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 1, };
	{ city = 0, x = -2339.0, y = 65.5 + 860, z = 20.2, iModel = 540, rz = 0, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 1, };
	{ city = 0, x = -2333.6, y = 65.5 + 860, z = 20.2, iModel = 540, rz = 0, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 1, };
	{ city = 0, x = -2327.7, y = 65.5 + 860, z = 20.2, iModel = 579, rz = 0, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 7, };
	{ city = 0, x = -2321.7, y = 65.5 + 860, z = 20.2, iModel = 579, rz = 0, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 7, };
	{ city = 0, x = -2315.7, y = 65.5 + 860, z = 20.2, iModel = 579, rz = 0, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 7, };

	{ city = 0, x = -2339.3 ,y = 41.4 + 860, z = 20.2, iModel = 546, rz = 0, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 3, };
	{ city = 0, x = -2333.5 ,y = 41.4 + 860, z = 20.2, iModel = 546, rz = 0, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 3, };
	{ city = 0, x = -2327.7 ,y = 41.4 + 860, z = 20.2, iModel = 546, rz = 0, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 3, };
	{ city = 0, x = -2322.0 ,y = 41.4 + 860, z = 20.2, iModel = 546, rz = 0, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 3, };
	{ city = 0, x = -2345.1, y = 41.3 + 860, z = 20.8, iModel = 546, rz = 0, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 3, };
	{ city = 0, x = -2350.8, y = 41.3 + 860, z = 20.8, iModel = 546, rz = 0, pColor = {60,69,29}, iFaction = F_ARMY, iMinLevel = 3, };

	----------------- Мэрия НСК --------------------------
	{ city = 0, x = -7.149, y = -1637.5 + 860, z = 20.414, iModel = 540, rz = 0, iFaction = F_GOVERNMENT_NSK, pColor = { 0, 0, 0 }, iMinLevel = 1, windows_color = { 0, 0, 0, 230 } };
	{ city = 0, x = -2.628, y = -1636.9 + 860, z = 20.414, iModel = 540, rz = 0, iFaction = F_GOVERNMENT_NSK, pColor = { 0, 0, 0 }, iMinLevel = 1, windows_color = { 0, 0, 0, 230 } };
	{ city = 0, x = 1.364, y = -1637.48 + 860, z = 20.418, iModel = 540, rz = 0, iFaction = F_GOVERNMENT_NSK, pColor = { 0, 0, 0 }, iMinLevel = 1, windows_color = { 0, 0, 0, 230 } };
	{ city = 0, x = 5.627, y = -1637.508 + 860, z = 20.682, iModel = 445, rz = 0, iFaction = F_GOVERNMENT_NSK, pColor = { 0, 0, 0 }, iMinLevel = 3, windows_color = { 0, 0, 0, 230 } };
	{ city = 0, x = 9.524, y = -1637.505 + 860, z = 20.676, iModel = 445, rz = 0, iFaction = F_GOVERNMENT_NSK, pColor = { 0, 0, 0 }, iMinLevel = 3, windows_color = { 0, 0, 0, 230 } };
	{ city = 0, x = 13.528, y = -1637.477 + 860, z = 20.686, iModel = 445, rz = 0, iFaction = F_GOVERNMENT_NSK, pColor = { 0, 0, 0 }, iMinLevel = 3, windows_color = { 0, 0, 0, 230 } };
	{ city = 0, x = 17.284, y = -1637.32 + 860, z = 20.68, iModel = 579, rz = 0, iFaction = F_GOVERNMENT_NSK, pColor = { 0, 0, 0 }, iMinLevel = 4, windows_color = { 0, 0, 0, 230 } };
	{ city = 0, x = 21.079, y = -1637.507 + 860, z = 20.676, iModel = 579, rz = 0, iFaction = F_GOVERNMENT_NSK, pColor = { 0, 0, 0 }, iMinLevel = 4, windows_color = { 0, 0, 0, 230 } };
	{ city = 0, x = 25.011, y = -1637.455 + 860, z = 20.674, iModel = 579, rz = 0, iFaction = F_GOVERNMENT_NSK, pColor = { 0, 0, 0 }, iMinLevel = 4, windows_color = { 0, 0, 0, 230 } };
	{ city = 0, x = 21.177, y = -1615.788 + 860, z = 20.196, iModel = 507, rz = 180, iFaction = F_GOVERNMENT_NSK, pColor = { 0, 0, 0 }, iMinLevel = 5, windows_color = { 0, 0, 0, 230 } };
	{ city = 0, x = 17.24, y = -1615.775 + 860, z = 20.196, iModel = 507, rz = 180, iFaction = F_GOVERNMENT_NSK, pColor = { 0, 0, 0 }, iMinLevel = 5, windows_color = { 0, 0, 0, 230 } };
	{ city = 0, x = 13.457, y = -1615.714 + 860, z = 20.196, iModel = 507, rz = 180, iFaction = F_GOVERNMENT_NSK, pColor = { 0, 0, 0 }, iMinLevel = 5, windows_color = { 0, 0, 0, 230 } };

	----------------- Мэрия ГРК --------------------------
	{ city = 1, x = 2310.588, y = -970.816 + 860, z = 60.475, iModel = 540, rz = 297, iFaction = F_GOVERNMENT_GORKI, pColor = { 0, 0, 0 }, iMinLevel = 1, windows_color = { 0, 0, 0, 230 } };
	{ city = 1, x = 2308.795, y = -967.41 + 860, z = 60.475, iModel = 540, rz = 297, iFaction = F_GOVERNMENT_GORKI, pColor = { 0, 0, 0 }, iMinLevel = 1, windows_color = { 0, 0, 0, 230 } };
	{ city = 1, x = 2306.905, y = -964.041 + 860, z = 60.476, iModel = 540, rz = 297, iFaction = F_GOVERNMENT_GORKI, pColor = { 0, 0, 0 }, iMinLevel = 1, windows_color = { 0, 0, 0, 230 } };
	{ city = 1, x = 2305.75, y = -961.287 + 860, z = 60.743, iModel = 445, rz = 297, iFaction = F_GOVERNMENT_GORKI, pColor = { 0, 0, 0 }, iMinLevel = 3, windows_color = { 0, 0, 0, 230 } };
	{ city = 1, x = 2303.755, y = -958.004 + 860, z = 60.747, iModel = 445, rz = 297, iFaction = F_GOVERNMENT_GORKI, pColor = { 0, 0, 0 }, iMinLevel = 3, windows_color = { 0, 0, 0, 230 } };
	{ city = 1, x = 2306.433, y = -948.656 + 860, z = 60.737, iModel = 445, rz = 297, iFaction = F_GOVERNMENT_GORKI, pColor = { 0, 0, 0 }, iMinLevel = 3, windows_color = { 0, 0, 0, 230 } };
	{ city = 1, x = 2304.212, y = -944.666 + 860, z = 60.742, iModel = 579, rz = 297, iFaction = F_GOVERNMENT_GORKI, pColor = { 0, 0, 0 }, iMinLevel = 4, windows_color = { 0, 0, 0, 230 } };
	{ city = 1, x = 2301.631, y = -940.654 + 860, z = 60.743, iModel = 579, rz = 297, iFaction = F_GOVERNMENT_GORKI, pColor = { 0, 0, 0 }, iMinLevel = 4, windows_color = { 0, 0, 0, 230 } };
	{ city = 1, x = 2299.193, y = -935.999 + 860, z = 60.739, iModel = 579, rz = 297, iFaction = F_GOVERNMENT_GORKI, pColor = { 0, 0, 0 }, iMinLevel = 4, windows_color = { 0, 0, 0, 230 } };
	{ city = 1, x = 2296.162, y = -931.077 + 860, z = 60.262, iModel = 507, rz = 297, iFaction = F_GOVERNMENT_GORKI, pColor = { 0, 0, 0 }, iMinLevel = 5, windows_color = { 0, 0, 0, 230 } };
	{ city = 1, x = 2294.018, y = -926.997 + 860, z = 60.262, iModel = 507, rz = 297, iFaction = F_GOVERNMENT_GORKI, pColor = { 0, 0, 0 }, iMinLevel = 5, windows_color = { 0, 0, 0, 230 } };
	{ city = 1, x = 2291.366, y = -922.515 + 860, z = 60.263, iModel = 507, rz = 297, iFaction = F_GOVERNMENT_GORKI, pColor = { 0, 0, 0 }, iMinLevel = 5, windows_color = { 0, 0, 0, 230 } };

	----------------- ФСИН --------------------------
	
	--Микроавтобус
	{ city = 0, x = -2828.5629, y = 1625.1335 + 860, z = 14.1148, iModel = 416, rz = 330, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 1, iPaintjob = 0 };
	{ city = 0, x = -2832.7695, y = 1627.8767 + 860, z = 14.1148, iModel = 416, rz = 330, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 1, iPaintjob = 0 };
	{ city = 0, x = -2837.4304, y = 1631.0407 + 860, z = 14.1148, iModel = 416, rz = 330, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 1, iPaintjob = 0 };
	{ city = 0, x = -2841.7773, y = 1633.8212 + 860, z = 14.1205, iModel = 416, rz = 330, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 1, iPaintjob = 0 };
	{ city = 0, x = -2876.2456, y = 1668.0009 + 860, z = 14.1205, iModel = 416, rz = 245, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 1, iPaintjob = 0 };
	{ city = 0, x = -2873.7834, y = 1673.7736 + 860, z = 14.1205, iModel = 416, rz = 245, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 1, iPaintjob = 0 };
	{ city = 0, x = -2871.3659, y = 1679.3181 + 860, z = 14.1205, iModel = 416, rz = 245, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 1, iPaintjob = 0 };

	--УАЗ
	{ city = 0, x = -2771.9965, y = 1639.2307 + 860, z = 14.1251, iModel = 400, rz = 150, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 3, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -2776.2917, y = 1642.2668 + 860, z = 14.1251, iModel = 400, rz = 150, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 3, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -2782.8139, y = 1645.414 + 860, z = 14.1251, iModel = 400, rz = 150, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 3, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -2788.7963, y = 1648.634 + 860, z = 14.1251, iModel = 400, rz = 150, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 3, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -2795.8942, y = 1652.3347 + 860, z = 14.1251, iModel = 400, rz = 150, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 3, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -2767.298, y = 1636.904 + 860, z = 14.1251, iModel = 400, rz = 150, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 3, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -2792.2929, y = 1650.7185 + 860, z = 14.1251, iModel = 400, rz = 150, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 3, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -2779.4096, y = 1644.1481 + 860, z = 14.1251, iModel = 400, rz = 150, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 3, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -2785.5258, y = 1647.4838 + 860, z = 14.1251, iModel = 400, rz = 150, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 3, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
		
	--Патриот
	{ city = 0, x = -2774.2199, y = 1627.3579 + 860, z = 14.1251, iModel = 490, rz = 60, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 5, iPaintjob = 0 };
	{ city = 0, x = -2776.2058, y = 1623.2761 + 860, z = 14.1251, iModel = 490, rz = 60, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 5, iPaintjob = 0 };
	{ city = 0, x = -2778.155, y = 1619.893 + 860, z = 14.1251, iModel = 490, rz = 60, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 5, iPaintjob = 0 };
	{ city = 0, x = -2780.5205, y = 1615.7854 + 860, z = 14.1251, iModel = 490, rz = 60, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 5, iPaintjob = 0 };
	{ city = 0, x = -2782.8405, y = 1611.1364 + 860, z = 14.1251, iModel = 490, rz = 60, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 5, iPaintjob = 0 };
	{ city = 0, x = -2785.4038, y = 1606.7832 + 860, z = 14.1251, iModel = 490, rz = 60, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 5, iPaintjob = 0 };
	{ city = 0, x = -2771.8522, y = 1630.375 + 860, z = 14.1251, iModel = 490, rz = 60, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 5, iPaintjob = 0 };
	
	--Гелик
	{ city = 0, x = -2828.051, y = 1672.2167 + 860, z = 14.1205, iModel = 579, rz = 150, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -2832.3522, y = 1674.7575 + 860, z = 14.1205, iModel = 579, rz = 150, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -2837.081, y = 1677.6108 + 860, z = 14.1205, iModel = 579, rz = 150, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -2842.1142, y = 1680.4653 + 860, z = 14.1205, iModel = 579, rz = 150, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -2847.2424, y = 1683.7607 + 860, z = 14.1205, iModel = 579, rz = 150, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -2852.6711, y = 1686.8215 + 860, z = 14.1205, iModel = 579, rz = 150, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
	{ city = 0, x = -2855.977, y = 1690.6455 + 860, z = 14.1205, iModel = 579, rz = 150, pColor = { 255, 255, 255 }, iFaction = F_FSIN, iMinLevel = 6, iPaintjob = 0, tuning_external = { [ TUNING_SIREN ] = 2 } };
}

FACTION_NUMBER_TYPES = 
{
	[F_ARMY] = PLATE_TYPE_ARMY,
	[F_MEDIC] = PLATE_TYPE_REGULAR,
	[F_POLICE_PPS_NSK] = PLATE_TYPE_POLICE,
	[F_POLICE_DPS_NSK] = PLATE_TYPE_POLICE,
	[F_POLICE_PPS_GORKI] = PLATE_TYPE_POLICE,
	[F_POLICE_DPS_GORKI] = PLATE_TYPE_POLICE,
	[F_FSIN] = PLATE_TYPE_POLICE,
}

FACTIONS_VEHICLE_MARKERS = { 
	-- НСК
	{ x = 351.828, y = -2058.494 + 860, z = 20.763, faction = F_POLICE_DPS_NSK, city = 0 },
	{ x = 390.676, y = -2478.117 + 860, z = 20.995, faction = F_MEDIC, city = 0 },
	{ x = -366.676, y = -1671.288 + 860, z = 20.859, faction = F_POLICE_PPS_NSK, city = 0 },
	{ x = -2330.926, y = 22.878 + 860, z = 20.106, faction = F_ARMY, city = 0 },
	{ x = -4.682, y = -1648.725 + 860, z = 20.821, faction = F_GOVERNMENT_NSK, city = 0 },
	{ x = -2810.6813, y = 1615.2888 + 860, z = 14.1328, faction = F_FSIN, city = 0 },

	-- ГОРКИ
	{ x = 1939.4294, y = -728.2208 + 860, z = 60.773, faction = F_POLICE_PPS_GORKI, city = 1 },
	{ x = 1905.721, y = -504.583 + 860, z = 60.791, faction = F_MEDIC, city = 1 },
	{ x = 2207.904, y = -616.761 + 860, z = 60.662, faction = F_POLICE_DPS_GORKI, city = 1 },
	{ x = 2324.024, y = -984.881 + 860, z = 60.660, faction = F_GOVERNMENT_GORKI, city = 1 },
}

FACTIONS_VEHICLE_SIREN_OFFSET_POSITIONS = {
	[445] = { -0.57, 0.3, 0.932, -8, 0, 0 };
	[579] = { -0.63, 0.2, 1.11, -5, 0, 0 };
	[507] = { -0.38, 0.2, 0.85, -5, 0, 0 };
}

function GetVehicleMarkerPositionByFaction( city, faction )
	for k, v in pairs( FACTIONS_VEHICLE_MARKERS ) do
		if v.city == city and v.faction == faction then
			return Vector3( v.x, v.y, v.z )
		end
	end
end