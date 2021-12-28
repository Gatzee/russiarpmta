QUEST_CONF = {
	dialogs = {
		start = {
			{ name = "Ксюша", voice_line = "Ksusha_long_awaited_monolog_1", text = [[Привет моя радость.
Я соскучилась по тебе. Часто вспоминаю, как хорошо с тобой было...]] },
			{ name = "Ксюша", text = [[Я хочу попросить тебя об одной услуге, ты ведь не откажешь?
Мне очень надо встретиться с Александром, он вроде твой хороший товарищ.]] },
			{ name = "Ксюша", text = [[Но сейчас совсем пропал. Я знаю, что у него помощник есть - Роман.
И по слухам ты с ним знаком. Познакомишь с ним,
а потом мы проведем время вместе.]]},
		},
		roman_house = {
			{ name = "Ксюша", voice_line = "Ksusha_long_awaited_monolog_2", text = [[Черт! Его нет дома,
думаю ты не откажешься составить мне компанию и подождать его.]] },
		},
		roman_talk = {
			{ name = "Ксюша", voice_line = "Ksusha_long_awaited_monolog_3a", text = "Здравствуй, приятно познакомиться.", 						   },
			{ name = "Роман", voice_line = "Roman_long_awaited_monolog_1a",  text = "Привет, взаимно.", 										   },
			{ name = "Ксюша", voice_line = "Ksusha_long_awaited_monolog_3b", text = "У меня есть деловое предложение к Александру.", 			   },
			{ name = "Роман", voice_line = "Roman_long_awaited_monolog_1b",  text = "Говори я тебя слушаю.", 									   },
			{ name = "Ксюша", voice_line = "Ksusha_long_awaited_monolog_3c", text = "Мне лично надо с ним пообщаться!", 					 	   },
			{ name = "Роман", voice_line = "Roman_long_awaited_monolog_1c",  text = "Он сейчас занят. Можешь сказать мне, я передам.", 		   },
			{ name = "Ксюша", voice_line = "Ksusha_long_awaited_monolog_3d", text = "Ты слышишь меня?! Мне лично надо поговорить с Александром!", },
			{ name = "Роман", voice_line = "Roman_long_awaited_monolog_1d",  text = "Я тебя услышал, но ничего не могу сделать.", 				   },
			{ name = "Ксюша", voice_line = "Ksusha_long_awaited_monolog_3e", text = "Спасибо." 												   },
		},
	},

	positions = {
		outer_office = { pos = Vector3( 2192.69, 2636.22, 8.07 ), rot = Vector3( 0, 0, 85 ), cz = 90 },
		inner_office = { pos = Vector3( 4.07, -657.77, 2267.0 ), rot = Vector3( 0, 0, 267 ), cz = 270 },

		ksusha_spawn = { model = 80, pos = Vector3( 14.95, -663.5, 2267.26 ), rot = 57 },
		ksusha_start_dialog_position = { pos = Vector3( 14.4015, -663.0650, 2267.7639 ), rot = Vector3( 0, 0, 228 ), cz = 130 },
		ksusha_start_dialog_matrix = { 13.981706619263, -662.42053222656, 2268.5632324219, 79.28050994873, -736.52081298828, 2252.9040527344, 0, 70 },


		ksusha_vehicle_spawn = { pos = Vector3( 2172.8557, 2641.6474, 7.7610 ), rot = Vector3( 0, 0, 138 ) },

		ksusha_leave_matrix = { 2182.1403808594, 2639.5534667969, 12.208093643188, 2091.2451171875, 2670.919921875, -15.254717826843, 0, 70 },
		leave_office_vehicle_path = {
			{ x = 2168.1525878906, y = 2636.0773925781, z = 7.7281632423401, speed_limit = 25, distance = 1 },
			{ x = 2154.1757812511, y = 2645.4443359375, z = 7.7273988723755, speed_limit = 25, distance = 1 },
			{ x = 2138.0270996094, y = 2660.2382812512, z = 7.7241945266724, speed_limit = 25, distance = 1 },
			{ x = 2105.9216308594, y = 2689.0983886719, z = 7.7236299514771, speed_limit = 25, distance = 1 },
		},

		podmoskov_camera_path = {
			{ m = { -236.00523376465, 670.62091064453, 33.537467956543, -201.16769409181, 586.55902099609, -7.9347643852234, 0, 70 } },
			{ m = { -215.26000976563, 619.30010986328, 29.219743728638, -190.69577026367, 525.74609375123, 3.83773708343511, 0, 70 } },
			{ m = { -200.29618835449, 566.33789062511, 26.711776733398, -187.33828735352, 470.66580200195, 0.65525233745575, 0, 70 } },
			{ m = { -195.86978149414, 511.51278686523, 25.649097442627, -192.03601074219, 416.64932250977, -5.7551202774048, 0, 70 } },
			{ m = { -198.69923400879, 487.78848266602, 25.892063140869, -100.50851440431, 488.64129638672, 6.97498369216921, 0, 70 } },
			{ m = { -136.45971679688, 487.64810180664, 27.799472808838, -38.764034271241, 486.45080566406, 6.48938703536991, 0, 70 } },
		},

		dummy_vehicles = {
			{ pos = Vector3( 2168.2802734375, 2645.5544433594, 7.5303893089294 ), rot = Vector3( 359.51538085938, 359.99981689453, 318.68389892578 ), model = 550  },
			{ pos = Vector3( 2160.0322265625, 2653.0490722656, 7.5256242752075 ), rot = Vector3( 359.56860351563, 359.97692871094, 139.46328735352 ), model = 555  },
			{ pos = Vector3( 2155.9221191406, 2656.8762207031, 7.5280699729919 ), rot = Vector3( 359.51715087891, 359.99139404297, 140.65936279297 ), model = 533  },
			{ pos = Vector3( 2147.4536132813, 2664.4987792969, 7.5280189514161 ), rot = Vector3( 359.41754150391, 359.97067260742, 317.69662475586 ), model = 6530 },
			{ pos = Vector3( 2143.4184570313, 2668.3251953125, 7.5278315544128 ), rot = Vector3( 359.42510986328, 359.97955322266, 318.49694824219 ), model = 6528 },
			{ pos = Vector3( 2139.0285644531, 2672.0236816406, 7.5274314880371 ), rot = Vector3( 359.48959350586, 0.0059814453125, 316.32269287109 ), model = 535  },
		},
		
		podmoskov_ksusha_veh_spawn = { pos = Vector3( -234.67425537109, 667.69122314453, 28.61600494385 ), rot = Vector3( 0, 0, 200 ) },
		podmoskov_ksusha_veh_path = {
			{ x = -221.48966979981, y = 635.182431408203, z = 24.698833465576, speed_limit = 80, distance = 1 },
			{ x = -204.50028991699, y = 585.746152478516, z = 22.481613159181, speed_limit = 60, distance = 1 },
			{ x = -197.34059143066, y = 549.139221119141, z = 21.255495071411, speed_limit = 50, distance = 1 },
			{ x = -195.12385559082, y = 502.036131281251, z = 20.585123062134, speed_limit = 40, distance = 1 },
			{ x = -174.40650939941, y = 488.013302566406, z = 20.549297332764, speed_limit = 30, distance = 1 },
			{ x = -112.70402526855, y = 487.562981828125, z = 20.550708770752, speed_limit = 70, distance = 1 },
			{ x = -57.662876129151, y = 484.926752781251, z = 20.549282073975, speed_limit = 70, distance = 1 },
			{ x = 13.9297504425051, y = 464.011749267583, z = 20.078241348267, speed_limit = 30, distance = 1 },
			{ x = 79.1856231689452, y = 425.610992431643, z = 20.079055786133, speed_limit = 30, distance = 1 },
			{ x = 173.396499633793, y = 387.611633300782, z = 20.078042984009, speed_limit = 30, distance = 1 },
			{ x = 223.719070434511, y = 377.266479492192, z = 20.700401306152, speed_limit = 30, distance = 1 },
			{ x = 269.395599365233, y = 350.083953857421, z = 20.078969955444, speed_limit = 30, distance = 1 },
			{ x = 304.810852050782, y = 282.058654785162, z = 20.102718353271, speed_limit = 30, distance = 1 },
			{ x = 339.467407226561, y = 151.334167480471, z = 20.102571487427, speed_limit = 30, distance = 1 },
			{ x = 379.606994628911, y = -1.6109852790833, z = 20.092342376709, speed_limit = 30, distance = 1 },
			{ x = 397.829498291022, y = -75.457069396973, z = 20.076124191284, speed_limit = 30, distance = 1 },
			{ x = 411.129608154313, y = -168.09730529785, z = 20.081855773926, speed_limit = 30, distance = 1 },
			{ x = 428.367767333982, y = -304.12585449219, z = 20.081235885621, speed_limit = 30, distance = 1 },
			{ x = 431.802947998051, y = -365.48751831055, z = 20.081663131714, speed_limit = 30, distance = 1 },
			{ x = 431.978668212892, y = -535.41888427734, z = 20.080514907837, speed_limit = 30, distance = 1 },
			{ x = 435.067962646488, y = -608.61779785156, z = 20.084310531616, speed_limit = 30, distance = 1 },
			{ x = 443.456695556647, y = -740.87084960938, z = 20.102800369263, speed_limit = 30, distance = 1 },
			{ x = 443.982879638676, y = -913.77838134766, z = 20.103380203247, speed_limit = 30, distance = 1 },
			{ x = 443.516510009775, y = -1089.8568115234, z = 20.102113723755, speed_limit = 30, distance = 1 },
			{ x = 444.254119873054, y = -1155.9865722656, z = 19.970794677734, speed_limit = 30, distance = 1 },
			{ x = 445.011352539063, y = -1202.6883544922, z = 19.972747802734, speed_limit = 30, distance = 1 },
			{ x = 445.191253662112, y = -1273.3940429688, z = 19.973350524902, speed_limit = 30, distance = 1 },
			{ x = 445.457733154312, y = -1438.4753417969, z = 20.111989974976, speed_limit = 30, distance = 1 },
			{ x = 444.476287841811, y = -1663.3140869141, z = 20.168340682983, speed_limit = 30, distance = 1 },
			{ x = 444.415771484383, y = -1800.9613037109, z = 20.134731292725, speed_limit = 30, distance = 1 },
			{ x = 444.551910400392, y = -1903.3487548828, z = 20.130329132028, speed_limit = 30, distance = 1 },
			{ x = 442.995361328131, y = -1919.4260253906, z = 20.125076293945, speed_limit = 30, distance = 1 },
			{ x = 411.135040283212, y = -1924.5872802734, z = 20.130887985229, speed_limit = 30, distance = 1 },
			{ x = 304.649658203131, y = -1925.1358642578, z = 20.130931854248, speed_limit = 30, distance = 1 },
			{ x = 209.972656251213, y = -1925.1588134766, z = 20.133001327515, speed_limit = 30, distance = 1 },
			{ x = 95.2511749267582, y = -1924.9776611328, z = 20.127361297607, speed_limit = 30, distance = 1 },
			{ x = 48.7221641540531, y = -1925.7806396484, z = 20.128679275513, speed_limit = 30, distance = 1 },
			{ x = -11.836001396179, y = -1947.4060058594, z = 20.123149871826, speed_limit = 30, distance = 1 },
			{ x = -86.128952026367, y = -1949.9212646484, z = 20.184957504272, speed_limit = 30, distance = 1 },
			{ x = -173.74963378906, y = -1950.1358642578, z = 20.185781478882, speed_limit = 30, distance = 1 },
			{ x = -339.79119873047, y = -1950.5452880859, z = 20.167058944702, speed_limit = 30, distance = 1 },
			{ x = -516.73797607422, y = -1948.6212158203, z = 20.163427352905, speed_limit = 30, distance = 1 },
			{ x = -723.51751708984, y = -1949.7220458984, z = 20.161457061768, speed_limit = 30, distance = 1 },
			{ x = -836.03845214844, y = -1949.8233642578, z = 20.161388397217, speed_limit = 30, distance = 1 },
			{ x = -869.69616699219, y = -1949.7640380859, z = 20.160673141479, speed_limit = 30, distance = 1 },
			{ x = -871.74316406251, y = -1913.1483154297, z = 20.163711547852, speed_limit = 30, distance = 1 },
			{ x = -859.86505126953, y = -1845.4750976563, z = 20.165567398071, speed_limit = 30, distance = 1 },
			{ x = -842.22979736328, y = -1746.0340576172, z = 20.161827087402, speed_limit = 30, distance = 1 },
			{ x = -817.69042968751, y = -1729.5635986328, z = 20.158708572388, speed_limit = 30, distance = 1 },
		},

		bandit_veh_spawn_1 = { pos = Vector3( -367.64880371094, 487.44998168945, 20.697925567627 ), rot = Vector3( 0, 0, 270 ) },
		bandit_veh_path_1 = {
			{ x = -275.71496582031, y = 488.21282958984, z = 20.722497940063, speed_limit = 30, distance = 1 },
			{ x = -212.11338806152, y = 488.24752807617, z = 20.723386764526, speed_limit = 30, distance = 1 },
			{ x = -125.45027923584, y = 487.90652465821, z = 20.723390579224, speed_limit = 30, distance = 1 },
			{ x = -55.407600402832, y = 484.02648925781, z = 20.723737716675, speed_limit = 30, distance = 1 },

			{ x = 79.1856231689452, y = 425.610992431643, z = 20.079055786133, speed_limit = 30, distance = 1 },
			{ x = 173.396499633793, y = 387.611633300782, z = 20.078042984009, speed_limit = 30, distance = 1 },
			{ x = 223.719070434511, y = 377.266479492192, z = 20.700401306152, speed_limit = 30, distance = 1 },
			{ x = 269.395599365233, y = 350.083953857421, z = 20.078969955444, speed_limit = 30, distance = 1 },
			{ x = 304.810852050782, y = 282.058654785162, z = 20.102718353271, speed_limit = 30, distance = 1 },
			{ x = 339.467407226561, y = 151.334167480471, z = 20.102571487427, speed_limit = 30, distance = 1 },
			{ x = 379.606994628911, y = -1.6109852790833, z = 20.092342376709, speed_limit = 30, distance = 1 },
			{ x = 397.829498291022, y = -75.457069396973, z = 20.076124191284, speed_limit = 30, distance = 1 },
			{ x = 411.129608154313, y = -168.09730529785, z = 20.081855773926, speed_limit = 30, distance = 1 },
			{ x = 428.367767333982, y = -304.12585449219, z = 20.081235885621, speed_limit = 30, distance = 1 },
			{ x = 431.802947998051, y = -365.48751831055, z = 20.081663131714, speed_limit = 30, distance = 1 },
			{ x = 431.978668212892, y = -535.41888427734, z = 20.080514907837, speed_limit = 30, distance = 1 },
			{ x = 435.067962646488, y = -608.61779785156, z = 20.084310531616, speed_limit = 30, distance = 1 },
			{ x = 443.456695556647, y = -740.87084960938, z = 20.102800369263, speed_limit = 30, distance = 1 },
			{ x = 443.982879638676, y = -913.77838134766, z = 20.103380203247, speed_limit = 30, distance = 1 },
			{ x = 443.516510009775, y = -1089.8568115234, z = 20.102113723755, speed_limit = 30, distance = 1 },
			{ x = 444.254119873054, y = -1155.9865722656, z = 19.970794677734, speed_limit = 30, distance = 1 },
			{ x = 445.011352539063, y = -1202.6883544922, z = 19.972747802734, speed_limit = 30, distance = 1 },
			{ x = 445.191253662112, y = -1273.3940429688, z = 19.973350524902, speed_limit = 30, distance = 1 },
			{ x = 445.457733154312, y = -1438.4753417969, z = 20.111989974976, speed_limit = 30, distance = 1 },
			{ x = 444.476287841811, y = -1663.3140869141, z = 20.168340682983, speed_limit = 30, distance = 1 },
			{ x = 444.415771484383, y = -1800.9613037109, z = 20.134731292725, speed_limit = 30, distance = 1 },
			{ x = 444.551910400392, y = -1903.3487548828, z = 20.130329132028, speed_limit = 30, distance = 1 },
			{ x = 442.995361328131, y = -1919.4260253906, z = 20.125076293945, speed_limit = 30, distance = 1 },
			{ x = 411.135040283212, y = -1924.5872802734, z = 20.130887985229, speed_limit = 30, distance = 1 },
			{ x = 304.649658203131, y = -1925.1358642578, z = 20.130931854248, speed_limit = 30, distance = 1 },
			{ x = 209.972656251213, y = -1925.1588134766, z = 20.133001327515, speed_limit = 30, distance = 1 },
			{ x = 95.2511749267582, y = -1924.9776611328, z = 20.127361297607, speed_limit = 30, distance = 1 },
			{ x = 48.7221641540531, y = -1925.7806396484, z = 20.128679275513, speed_limit = 30, distance = 1 },
			{ x = -11.836001396179, y = -1947.4060058594, z = 20.123149871826, speed_limit = 30, distance = 1 },
			{ x = -86.128952026367, y = -1949.9212646484, z = 20.184957504272, speed_limit = 30, distance = 1 },
			{ x = -173.74963378906, y = -1950.1358642578, z = 20.185781478882, speed_limit = 30, distance = 1 },
			{ x = -339.79119873047, y = -1950.5452880859, z = 20.167058944702, speed_limit = 30, distance = 1 },
			{ x = -516.73797607422, y = -1948.6212158203, z = 20.163427352905, speed_limit = 30, distance = 1 },
			{ x = -723.51751708984, y = -1949.7220458984, z = 20.161457061768, speed_limit = 30, distance = 1 },
			{ x = -836.03845214844, y = -1949.8233642578, z = 20.161388397217, speed_limit = 30, distance = 1 },
			{ x = -869.69616699219, y = -1949.7640380859, z = 20.160673141479, speed_limit = 30, distance = 1 },
			{ x = -871.74316406251, y = -1913.1483154297, z = 20.163711547852, speed_limit = 30, distance = 1 },
			{ x = -859.86505126953, y = -1845.4750976563, z = 20.165567398071, speed_limit = 30, distance = 1 },
			{ x = -842.22979736328, y = -1746.0340576172, z = 20.161827087402, speed_limit = 30, distance = 1 },
			{ x = -817.69042968751, y = -1729.5635986328, z = 20.158708572388, speed_limit = 30, distance = 1 },
		},

		bandit_veh_spawn_2 = { pos = Vector3( -350.87387084961, 482.98040771484, 20.697925567627 ), rot = Vector3( 0, 0, 270 ) },
		bandit_veh_path_2 = {
			{ x = -278.82940673828, y = 483.47216796875, z = 20.722337722778, speed_limit = 28, distance = 1 },
			{ x = -148.85591125488, y = 483.82159423828, z = 20.723379135132, speed_limit = 28, distance = 1 },
			{ x = -72.653083801271, y = 482.17605590821, z = 20.721029281616, speed_limit = 28, distance = 1 },
			{ x = -42.707401275635, y = 477.94085693359, z = 20.725284576416, speed_limit = 28, distance = 1 },
		},

		roman_house_veh_spawn = { pos = Vector3( 514.73596191406, -507.82440185547, 20.582344055176 ), rot = Vector3( 0, 0, 270 ) },
		roman_house_veh_come_path = {
			{ x = 547.12298583984, y = -506.88400268555, z = 20.550981521606, speed_limit = 15, distance = 1 },
		},
		roman_house_come_matrix =  { 518.82824707031, -499.80581665039, 24.869316101074, 602.38763427734, -549.81225585938, 2.1275043487549, 0, 70 },

		ksuha_come_roman_house_path = {
			{ x = 550.63153076172, y = -505.06051635742, z = 20.699312210083 },
			{ x = 553.08178710938, y = -513.16668701172, z = 20.933687210083 },
			{ x = 557.99963378906, y = -517.31280517578, z = 20.996187210083 },
			{ x = 558.07958984375, y = -519.54510498047, z = 21.773986816406 },
		},

		roman_door = { pos = Vector3( 558.75, -521.15, 21.27 ), rot = Vector3( 0, 0, 18 ) },
		ksuha_door_talk = { pos = Vector3( 558.44012451172, -520.65173339844, 21.773986816406 ), rot = Vector3( 0, 0, 216 ) },
		ksuha_player_talk = { pos = Vector3( 558.68786621094, -520.90863037109, 21.773986816406 ), rot = Vector3( 0, 0, 23 ) },
		roman_door_matrix =  { 559.03430175781, -522.03894042969, 22.711553573608, 531.34887695313, -428.84619140625, -0.71129083633423, 0, 70 },

		ksuha_go_vehicle_path = {
			{ x = 557.48925781251, y = -516.57598876953, z = 20.933687210083 },
			{ x = 553.21954345703, y = -513.45599365234, z = 20.933687210083 },
			{ x = 552.58911132813, y = -509.47238159181, z = 20.762256622314 },
			{ x = 548.45263671875, y = -504.75668334961, z = 20.699312210083 },
		},
		wait_roman_matrix = { 538.79022216797, -502.1728515625, 23.941732406616, 629.47344970703, -539.72943115234, 4.8090567588806, 0, 70 },
		
		roman_veh_spawn = { pos = Vector3( 617.75006103516, -527.29052734375, 20.383541107178 ), rot = Vector3( 0, 0, 0 ) },
		roman_veh_path = {
			{ x = 617.00476074219, y = -504.61138916016, z = 20.319000244141, speed_limit = 15, distance = 1 },
			{ x = 604.36791992188, y = -502.79803466797, z = 20.317811965942, speed_limit = 15, distance = 1 },
			{ x = 560.60736083984, y = -502.30569458008, z = 20.318857192993, speed_limit = 15, distance = 1 },
			{ x = 553.74023437511, y = -509.06256103516, z = 20.415756225586, speed_limit = 15, distance = 1 },
			{ x = 553.46166992188, y = -519.84790039063, z = 20.552873611451, speed_limit = 15, distance = 1 },
		},
		roman_talk_path = {
			{ x = 554.72143554688, y = -515.86822509766, z = 20.933687210083 },
			{ x = 553.30560302734, y = -513.41021728516, z = 20.933687210083 },
		},

		player_talk = { pos = Vector3( 552.62786865234, -512.84136962891, 20.937463760376 ), rot = Vector3( 0, 0, 220 ) },
		talk_roman_matrix =  { 552.27453613281, -511.86804199219, 21.999877929688, 607.76806640625, -589.84594726563, -6.9813032150269, 0, 70 },
		ksusha_go_talk_path = {
			{ x = 550.0945, y = -504.7996, z = 20.6993 },
			{ x = 551.7962, y = -506.5098, z = 20.6993 },
			{ x = 553.6510, y = -512.6924, z = 20.9361, rz = 166 },
		},

		ksusha_leave_to_vehicle_path = {
			{ x = 553.6510, y = -512.6924, z = 20.9361 },
			{ x = 551.7962, y = -506.5098, z = 20.6993 },
			{ x = 550.0945, y = -504.7996, z = 20.6993 },
		},

		ksuha_leave_path = {
			{ x = 570.26159667969, y = -507.18536376953, z = 20.704395294189, speed_limit = 15, distance = 1 },
			{ x = 606.97570800781, y = -506.98388671875, z = 20.699312210083, speed_limit = 15, distance = 1 },
			{ x = 613.55187988281, y = -514.35906982422, z = 20.699312210083, speed_limit = 15, distance = 1 },
			{ x = 613.23852539063, y = -527.47149658203, z = 20.699312210083, speed_limit = 15, distance = 1 },
		},
	},
}

GEs = { }

QUEST_DATA = {
	id = "long_awaited_meeting",
	is_company_quest = true,

	title = "Долгожданная встреча",
	description = "Удивительная Ксюша, в прошлом мы хорошо провели время, её точно стоит навестить и расслабиться.",

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 2188.5498, 2626.4980, 8.1721 ),
	
	quests_request = { "angela_problems" },
	level_request = 10,

	OnAnyFinish = {
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			
			if player.dimension == player:GetUniqueDimension() then
				if player.interior ~= 0 then
					player.interior = 0
					player.position = QUEST_CONF.positions.outer_office.pos
				end
				ExitLocalDimension( player )
			end

			player:TakeAllWeapons( true )			
		end,
		client = function()
			ShowNPCs( )
			toggleControl( "enter_exit", true )
			toggleControl( "enter_passenger", true )
			WatchToElement( false )
			fadeCamera( true )
		end,
	},

	tasks = {

		{
			name = "Отправляйся в Moscow City",

			Setup = {
				client = function( )
					GEs.handlers = {}
					local positions = QUEST_CONF.positions

					CreateQuestPoint( positions.outer_office.pos, function( self, player )
						CEs.marker.destroy( )
						EnterLocalDimension( )

						fadeCamera( false, 1.5 )
						CEs.timer = setTimer( triggerServerEvent, 1700, 1, "long_awaited_meeting_step_1", localPlayer )
					end, _, 1, _, _, function( )
						if localPlayer.vehicle then
							return false, "Выйди из машины, чтобы зайти в офис"
						end
						return true
					end )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				server = function( player )

				end
			},

			event_end_name = "long_awaited_meeting_step_1",
		},

		{
			name = "Долгожданная встреча...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					localPlayer.interior = 1
					localPlayer.position = positions.inner_office.pos
					localPlayer.rotation = positions.inner_office.rot

					setPedCameraRotation( localPlayer, positions.inner_office.cz )

					GEs.ksusha_bot = CreateAIPed( positions.ksusha_spawn.model, positions.ksusha_spawn.pos, positions.ksusha_spawn.rot )
					LocalizeQuestElement( GEs.ksusha_bot )
					SetUndamagable( GEs.ksusha_bot, true )

					CreateQuestPoint( positions.ksusha_spawn.pos, function( self, player )
						CEs.marker.destroy( )
						
						setCameraMatrix( unpack( positions.ksusha_start_dialog_matrix ) )
						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.start } )

						StartPedTalk( GEs.ksusha_bot, nil, true )
						localPlayer.position = positions.ksusha_start_dialog_position.pos
						localPlayer.rotation = positions.ksusha_start_dialog_position.rot

						CEs.dialog:next( )

						local t = {}

						t.DialogPart_2 = function()
							CEs.dialog:next( )
							setTimerDialog( t.DialogPart_3, 9500 )
						end

						t.DialogPart_3 = function()
							CEs.dialog:next( )
							setTimerDialog( function()
								fadeCamera( false, 1.5 )
								CEs.timer = setTimer( function()
									triggerServerEvent( "long_awaited_meeting_step_2", localPlayer )
								end, 1500, 1 )
							end, 13000, 1 )
						end

						setTimerDialog( t.DialogPart_2, 6300 )
					end, _, 1, 1 )

					CEs.timer = setTimer( fadeCamera, 250, 1, true, 1.5 )
				end,
				server = function( player )
					local vehicle = CreateTemporaryVehicle( player, 6531, QUEST_CONF.positions.ksusha_vehicle_spawn.pos, QUEST_CONF.positions.ksusha_vehicle_spawn.rot )
					vehicle:SetColor( 100, 100, 100 )
					vehicle:SetNumberPlate( "1:м555ур178" )
					setElementSyncer( vehicle, false )

					player:SetPrivateData( "temp_vehicle", vehicle )
					player.interior = 1
				end,
			},

			CleanUp = {
				client = function()
					FinishQuestCutscene( { ignore_fade_blink = true } )
					StopPedTalk( GEs.ksusha_bot )
				end,
				server = function( player )

				end
			},

			event_end_name = "long_awaited_meeting_step_2",
		},

		{
			name = "Садись в машину Ксюши",

			Setup = {
				client = function( )
					HideNPCs( )
					
					local positions = QUEST_CONF.positions

					localPlayer.interior = 0
					localPlayer.position = positions.outer_office.pos
					localPlayer.rotation = positions.outer_office.rot
					setPedCameraRotation( localPlayer, positions.outer_office.cz )

					GEs.ksusha_bot.interior = 0
					GEs.ksusha_bot.position = positions.outer_office.pos + Vector3( 3, 0, 0)
					GEs.ksusha_bot.rotation = positions.outer_office.rot
					
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					table.insert( GEs, WatchElementCondition( temp_vehicle, {
						condition = function( self, conf )
							if self.element.health <= 370 or self.element.inWater then
								FailCurrentQuest( "Машина Ксюши уничтожена", "fail_destroy_vehicle" )
								return true
							end
						end,
					} ) )

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=G чтобы сесть на пассажирское место",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					CreateQuestPoint( temp_vehicle.position, function( self, player )
						CEs.marker.destroy( )
					end, _, 5 )

					local handlers = {}
					handlers.OnStartEnter = function( player, seat )
						if player ~= localPlayer then return end
						if seat ~= 1 then
							localPlayer:ShowError( "Садись вперёд на пассажирское место" )
							cancelEvent( )
						end
						CEs.hint:destroy( )
					end
					addEventHandler( "onClientVehicleStartEnter", temp_vehicle, handlers.OnStartEnter )
					
					local CheckBothInVehicle = function()
						if localPlayer.vehicle and GEs.ksusha_bot.vehicle then
							toggleControl( "enter_exit", false )
							toggleControl( "enter_passenger", false )

							removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, handlers.OnStartEnter )
							removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.handlers.OnEnter )

							setCameraMatrix( unpack( positions.ksusha_leave_matrix ) )
							SetAIPedMoveByRoute( GEs.ksusha_bot, positions.leave_office_vehicle_path, false )
							
							CEs.timer = setTimer( function()
								fadeCamera( false, 1.5 )
								CEs.timer = setTimer( triggerServerEvent, 1500, 1, "long_awaited_meeting_step_3", localPlayer )
							end, 2000, 1 )
						end
					end

					GEs.handlers.OnEnter = function( vehicle, seat )
						if vehicle ~= temp_vehicle then return end
						CheckBothInVehicle()
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.handlers.OnEnter )

					AddEnterVehiclePattern( GEs.ksusha_bot, temp_vehicle, 0, CheckBothInVehicle )
					
					CEs.dummy_vehicles = {}
					for k, v in pairs( positions.dummy_vehicles ) do
						CEs.dummy_vehicles[ k ] = createVehicle( v.model, v.pos, v.rot )
						CEs.dummy_vehicles[ k ]:SetColor( math.random( 0, 255 ), math.random( 0, 255 ), math.random( 0, 255 ) )
						CEs.dummy_vehicles[ k ]:SetNumberPlate( "1:o" .. math.random( 111, 999 ) .. "сo001" )
						LocalizeQuestElement( CEs.dummy_vehicles[ k ] )
					end

					CEs.timer = setTimer( fadeCamera, 150, 1, true, 1.5 )
				end,
				server = function( player )
					player.interior = 0
				end,
			},

			CleanUp = {
				client = function()
					removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.handlers.OnEnter )
				end,
				server = function( player )

				end
			},

			event_end_name = "long_awaited_meeting_step_3",
		},

		{
			name = "Расправься с преследователями",

			Setup = {
				client = function( )
					EnableCheckQuestDimension( true )
					
					local positions = QUEST_CONF.positions
					CleanupAIPedPatternQueue( GEs.ksusha_bot )
					removePedTask( GEs.ksusha_bot )
					
					setElementVelocity( GEs.ksusha_bot.vehicle, 0, 0, 0 )
					setCameraMatrix( unpack( positions.podmoskov_camera_path[ 1 ].m ) )

					GEs.ksusha_bot.vehicle.position = positions.podmoskov_ksusha_veh_spawn.pos
					GEs.ksusha_bot.vehicle.rotation = positions.podmoskov_ksusha_veh_spawn.rot
					
					local t = {}

					t.CreateAttackBots = function()
						CEs.attack_veh = {}
						CEs.attack_bots = {}
						CEs.attackers = {}
						CEs.followers = {}

						for i = 1, 1 do
							local pos = positions[ "bandit_veh_spawn_" .. i ]
							CEs.attack_veh[ i ] = createVehicle( 445, pos.pos, pos.rot )
							CEs.attack_veh[ i ]:SetColor( 0, 0, 0 )
							CEs.attack_veh[ i ]:SetNumberPlate( "1:o" .. math.random( 111, 999 ) .. "oo001" )
							LocalizeQuestElement( CEs.attack_veh[ i ] )

							for j = 1, 2 do
								local bot = CreateAIPed( math.random( 0, 1 ) == 1 and 21 or 22, Vector3( 0, 0, 0 ), 0 )
								LocalizeQuestElement( bot )
								
								givePedWeapon( bot, 28, 999999, true )
								setPedStat( bot, 76, 1000 )
								setPedStat( bot, 22, 1000 )
								
								warpPedIntoVehicle( bot, CEs.attack_veh[ i ], j - 1 )

								if j == 1 then
									table.insert( CEs.followers, { old_state = false, bot = bot } )
								else
									table.insert( CEs.attackers, { old_state = false, bot = bot } )
								end

								if j ~= 1 then
									addEventHandler( "onClientPedWasted", bot, function()
										if CEs.attack_veh[ i ].controller and not CEs.attack_veh[ i ].controller.dead then
											CleanupAIPedPatternQueue( CEs.attack_veh[ i ].controller )
											removePedTask( CEs.attack_veh[ i ].controller )

											SetAIPedMoveByRoute( CEs.attack_veh[ i ].controller, {
												{ x = 304.9860, y = 297.4588, z = 20.7024, speed_limit = 30, distance = 1 },
												{ x = 279.9860, y = 346.4588, z = 20.7024, speed_limit = 30, distance = 1 },
												{ x = 320.9860, y = 383.4588, z = 20.7024, speed_limit = 30, distance = 1 },
												{ x = 521.9860, y = 455.4588, z = 20.7024, speed_limit = 30, distance = 1 },
											}, false)
										end
									end )
								end
							end

							SetAIPedMoveByRoute( CEs.attack_veh[ i ].controller, positions[ "bandit_veh_path_" .. i ], false)
						end
					end

					t.StartDrive = function()
						CEs.camera_move = CameraFromTo( _, positions.podmoskov_camera_path[ 2 ].m, 2700, "Linear" )
						CEs.timer = setTimer( t.TwoCamera, 2700, 1 )
					end

					t.TwoCamera = function()
						CEs.camera_move = CameraFromTo( _, positions.podmoskov_camera_path[ 3 ].m, 2500, "Linear" )
						CEs.timer = setTimer( t.ThreeCamera, 2500, 1 )
					end

					t.ThreeCamera = function()
						CEs.camera_move = CameraFromTo( _, positions.podmoskov_camera_path[ 4 ].m, 2200, "Linear" )
						CEs.timer = setTimer( t.FourCamera, 2200, 1 )
					end

					t.FourCamera = function()
						CEs.camera_move = CameraFromTo( _, positions.podmoskov_camera_path[ 5 ].m, 1800, "Linear" )
						CEs.timer = setTimer( t.FiveCamera, 1800, 1 )

						t.StartAttackAI()
					end

					t.StartAttackAI = function()
						t.StartBotsDriveBy = function()
							for k, v in pairs( CEs.attackers ) do
								setPedWeaponSlot( v.bot, 4 )
								setPedDoingGangDriveby( v.bot, true )
								setPedControlState( v.bot, "vehicle_fire", true )
							end
						end

						t.RefreshTarget = function()
							for k, v in pairs( CEs.attackers ) do
								setPedAimTarget( v.bot, GEs.ksusha_bot.vehicle.position )
							end
						end

						t.StartBotsDriveBy()
						CEs.shoot_timer = setTimer( t.RefreshTarget, 1000, 0 )
					end

					t.FiveCamera = function()
						CEs.camera_move = CameraFromTo( _, positions.podmoskov_camera_path[ 6 ].m, 2500, "Linear" )
						CEs.timer = setTimer( function()
							fadeCamera( false, 0.5 )
							CEs.timer = setTimer( t.OnEndCutScene, 510, 1 )
						end, 2000, 1 )
					end
					
					t.OnEndCutScene = function()
						localPlayer:ShowInfo( "Нажми ПКМ для того, чтобы прицелиться" )
						CEs.timer_info = setTimer( function()
							localPlayer:ShowInfo( "Уничтожь машину бандитов или прикончи водителя!" )
						end, 1500, 1 )

						fadeCamera( true, 0.5 )
						FinishQuestCutscene( { ignore_fade_blink = true } )
						
						CEs.fail_tmr = setTimer( function()
							GEs.ksusha_bot.vehicle.health = GEs.ksusha_bot.vehicle.health - 200
						end, 20 * 1000, 0 )
						
						CEs.check_tmr = setTimer( t.CheckLeaveBandits, 1000, 0 )
					end

					t.CheckLeaveBandits = function()
						local count = 0 

						for k, v in pairs( CEs.attack_veh ) do
							if ( v.position - localPlayer.position ).length >= 300 then
								count = count + 1
							end
						end

						if count == 1 then
							fadeCamera( false, 1 )
							CEs.timer = setTimer( function()
								setPedWeaponSlot( localPlayer, 0 )
								setPedDoingGangDriveby( localPlayer, false )
								setPedControlState( localPlayer, "vehicle_fire", false )

								CleanupAIPedPatternQueue( GEs.ksusha_bot )
								removePedTask( GEs.ksusha_bot )

								triggerServerEvent( "long_awaited_meeting_step_4", localPlayer )
							end, 1000, 1 )
						end
					end

					GEs.handlers.FireproOfVehicle = function()
						for k, v in pairs( CEs.attack_veh ) do
							if v == source then
								source.health = source.health - 10
								break
							end 
						end
					end
					addEventHandler( "onClientVehicleDamage", root, GEs.handlers.FireproOfVehicle )

					CEs.timer = setTimer( function()
						fadeCamera( true, 1.5 )
						StartQuestCutscene( { ignore_fade_blink = true } )
						
						CEs.timer = setTimer( t.StartDrive, 1500, 1 )
					end, 300, 1 )

					CEs.start_driver = setTimer( function()
						t.CreateAttackBots()
					end, 500, 1 )

					CEs.start_move_tmr = setTimer( SetAIPedMoveByRoute, 1000, 1, GEs.ksusha_bot, positions.podmoskov_ksusha_veh_path, false )
				end,
				server = function( player )
					player:GiveWeapon( 29, 2000, false, true )
				end,
			},

			CleanUp = {
				client = function()
					removeEventHandler( "onClientVehicleDamage", root, GEs.handlers.FireproOfVehicle )
					FinishQuestCutscene( { ignore_fade_blink = true } )
				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					if isElement( vehicle ) then
						setElementSyncer( vehicle, true )
					end
				end
			},

			event_end_name = "long_awaited_meeting_step_4",
		},

		{
			name = "Поговори с Романом",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )

					local t = {}

					GEs.handlers.OnBell = function()
						local sound = playSound( ":nrp_house_call/files/door_bell.mp3" )
						sound.volume = 0.4

						CEs.timer = setTimer( t.StartAfterBellDialog, 1000, 1 )
					end

					t.OnKsuhaExit = function()
						SetAIPedMoveByRoute( GEs.ksusha_bot, positions.ksuha_come_roman_house_path, false )
					end

					t.StartRomanCome = function()
						CleanupAIPedPatternQueue( GEs.ksusha_bot )
						removePedTask( GEs.ksusha_bot )
						setElementVelocity( GEs.ksusha_bot.vehicle, 0, 0, 0 )

						localPlayer.vehicle.position = positions.roman_house_veh_spawn.pos
						localPlayer.vehicle.rotation = positions.roman_house_veh_spawn.rot
						
						GEs.ksusha_bot.vehicle.position = positions.roman_house_veh_spawn.pos
						GEs.ksusha_bot.vehicle.rotation = positions.roman_house_veh_spawn.rot
						
						setCameraMatrix( unpack( positions.roman_house_come_matrix ) )
						StartQuestCutscene()
						
						SetAIPedMoveByRoute( GEs.ksusha_bot, positions.roman_house_veh_come_path, false, function()
							FinishQuestCutscene()
							
							CreateAIPed( localPlayer )
							for k, v in pairs( { localPlayer, GEs.ksusha_bot } ) do
								AddExitVehiclePattern( v, v == GEs.ksusha_bot and t.OnKsuhaExit or nil )
							end

							removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, GEs.handlers.onStartEnter )
							t.RingDoorBell()
						end )

						GEs.handlers.onStartEnter = function( player, seat, door )
							cancelEvent()
						end
						addEventHandler( "onClientVehicleStartEnter", temp_vehicle, GEs.handlers.onStartEnter )
					end

					t.RingDoorBell = function()
						CreateQuestPoint( positions.roman_door.pos, function( self, player )
							CEs.marker.destroy( )
							GEs.handlers.OnBell()
						end, _, 1 )
					end

					t.StartAfterBellDialog = function()
						setCameraMatrix( unpack( positions.roman_door_matrix ) )
						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.roman_house } )

						GEs.ksusha_bot.position = positions.ksuha_door_talk.pos
						GEs.ksusha_bot.rotation = positions.ksuha_door_talk.rot

						localPlayer.position = positions.ksuha_player_talk.pos
						localPlayer.rotation = positions.ksuha_player_talk.rot

						StartPedTalk( GEs.ksusha_bot, nil, true )
						CEs.dialog:next( )
						setTimerDialog( function()
							triggerServerEvent( "long_awaited_meeting_step_5", localPlayer )
						end, 6500 )
					end

					t.StartRomanCome()
				end,
				server = function( player )
					player:TakeAllWeapons( true )	
				end,
			},

			CleanUp = {
				client = function( data, failed )
					StopPedTalk( GEs.ksusha_bot )
					FinishQuestCutscene()
				end,
				server = function( player )

				end
			},

			event_end_name = "long_awaited_meeting_step_5",
		},

		{
			name = "Подожди Романа в машине",

			Setup = {
				client = function( )
					toggleControl( "enter_passenger", true )
					local positions = QUEST_CONF.positions
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=G чтобы сесть на пассажирское место",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					CreateQuestPoint( temp_vehicle.position, function( self, player )
						CEs.marker.destroy( )
					end, _, 5 )

					local handlers = {}
					handlers.OnStartEnter = function( player, seat )
						if player ~= localPlayer then return end
						if seat ~= 1 then
							localPlayer:ShowError( "Садись вперёд на пассажирское место" )
							cancelEvent( )
						end
						CEs.hint:destroy( )
					end
					addEventHandler( "onClientVehicleStartEnter", temp_vehicle, handlers.OnStartEnter )
					
					local CheckBothInVehicle = function()
						if localPlayer.vehicle and GEs.ksusha_bot.vehicle then
							toggleControl( "enter_passenger", false )
							removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, handlers.OnStartEnter )
							removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.handlers.OnEnter )

							fadeCamera( false, 1.5 )
							CEs.timer = setTimer( triggerServerEvent, 2500, 1, "long_awaited_meeting_step_6", localPlayer )
						end
					end

					GEs.handlers.OnEnter = function( vehicle, seat )
						if vehicle ~= temp_vehicle then return end
						CheckBothInVehicle()
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.handlers.OnEnter )

					SetAIPedMoveByRoute( GEs.ksusha_bot, positions.ksuha_go_vehicle_path, false, function()
						AddEnterVehiclePattern( GEs.ksusha_bot, temp_vehicle, 0, CheckBothInVehicle )
					end )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function()
					removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.handlers.OnEnter )
				end,
				server = function( player )

				end
			},

			event_end_name = "long_awaited_meeting_step_6",
		},

		{
			name = "Приезд Романа...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					
					StartQuestCutscene()
					setCameraMatrix( unpack( positions.wait_roman_matrix ) )
					
					GEs.roman_bot = CreateAIPed( 6733, Vector3( 0, 0, 0 ) )

					LocalizeQuestElement( GEs.roman_bot )
					SetUndamagable( GEs.roman_bot, true )

					GEs.roman_veh = createVehicle( 6539, positions.roman_veh_spawn.pos, positions.roman_veh_spawn.rot )
					LocalizeQuestElement( GEs.roman_veh )

					GEs.roman_veh:SetColor( 0, 0, 0 )
					GEs.roman_veh:SetNumberPlate( "1:м777oр099" )

					warpPedIntoVehicle( GEs.roman_bot, GEs.roman_veh )
					SetAIPedMoveByRoute( GEs.roman_bot, positions.roman_veh_path, false, function()
						AddExitVehiclePattern( GEs.roman_bot, function()
							SetAIPedMoveByRoute( GEs.roman_bot, positions.roman_talk_path, false, function()
								triggerServerEvent( "long_awaited_meeting_step_7", localPlayer )
							end )
						end )
					end )

					fadeCamera( true, 2 )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function()
					FinishQuestCutscene()
				end,
				server = function( player )

				end
			},

			event_end_name = "long_awaited_meeting_step_7",
		},

		{
			name = "Поговорите с Романом",

			Setup = {
				client = function( )
					toggleControl( "enter_passenger", true )

					local positions = QUEST_CONF.positions
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )

					local t = {}

					t.CheckBothReady = function()
						if not CEs.marker and CEs.ksusha_ready then
							t.StartTalk()
						end
					end

					t.CreatePointTalk = function()
						CreateQuestPoint( positions.player_talk.pos, function( self, player )
							CEs.marker.destroy( )
							CEs.marker = nil
							t.CheckBothReady()
						end, _, 1 )
						AddExitVehiclePattern( localPlayer )
						AddExitVehiclePattern( GEs.ksusha_bot, function()
							SetAIPedMoveByRoute( GEs.ksusha_bot, positions.ksusha_go_talk_path, false, function()
								CEs.ksusha_ready = true
								t.CheckBothReady()
							end )
						end )
					end

					t.StartTalk = function()
						setCameraMatrix( unpack( positions.talk_roman_matrix ) )
						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.roman_talk } )

						localPlayer.position = positions.player_talk.pos
						localPlayer.rotation = positions.player_talk.rot

						GEs.ksusha_bot.position = Vector3( positions.ksusha_go_talk_path[ 3 ].x, positions.ksusha_go_talk_path[ 3 ].y, positions.ksusha_go_talk_path[ 3 ].z )
						GEs.ksusha_bot.rotation = Vector3( 0,0, positions.ksusha_go_talk_path[ 3 ].rz )

						GEs.roman_bot.rotation = Vector3( 0, 0, 3 )

						StartPedTalk( GEs.ksusha_bot, nil, true )
						CEs.dialog:next()

						setTimerDialog( t.RomanDialog_1, 1600 )
					end

					t.RomanDialog_1 = function()
						StopPedTalk( GEs.ksusha_bot )
						StartPedTalk( GEs.roman_bot, nil, true )
						CEs.dialog:next()
						setTimerDialog( t.KsushaDialog_2, 1600 )
					end

					t.KsushaDialog_2 = function()
						StopPedTalk( GEs.roman_bot )
						StartPedTalk( GEs.ksusha_bot, nil, true )
						CEs.dialog:next()
						setTimerDialog( t.RomanDialog_2, 2600 )
					end

					t.RomanDialog_2 = function()
						StopPedTalk( GEs.ksusha_bot )
						StartPedTalk( GEs.roman_bot, nil, true )
						CEs.dialog:next()
						setTimerDialog( t.KsushaDialog_3, 1800 )
					end

					t.KsushaDialog_3 = function()
						StopPedTalk( GEs.roman_bot )
						StartPedTalk( GEs.ksusha_bot, nil, true )
						CEs.dialog:next()
						setTimerDialog( t.RomanDialog_3, 1600 )
					end

					t.RomanDialog_3 = function()
						StopPedTalk( GEs.ksusha_bot )
						StartPedTalk( GEs.roman_bot, nil, true )
						CEs.dialog:next()
						setTimerDialog( t.KsushaDialog_4, 3600 )
					end

					t.KsushaDialog_4 = function()
						StopPedTalk( GEs.roman_bot )
						StartPedTalk( GEs.ksusha_bot, nil, true )
						CEs.dialog:next()
						setTimerDialog( t.RomanDialog_4, 3600 )
					end

					t.RomanDialog_4 = function()
						StopPedTalk( GEs.ksusha_bot )
						StartPedTalk( GEs.roman_bot, nil, true )
						CEs.dialog:next()
						setTimerDialog( t.KsushaDialog_5, 3600 )
					end

					t.KsushaDialog_5 = function()
						StopPedTalk( GEs.roman_bot )
						StartPedTalk( GEs.ksusha_bot, nil, true )
						CEs.dialog:next()
						setTimerDialog( function()
							fadeCamera( false, 1 )
							CEs.timer = setTimer( t.KsuhaLeave, 1000, 1 )
						end, 500 )
					end

					t.KsuhaLeave = function()
						localPlayer.rotation = Vector3( 0, 0, 353 )

						CEs.dialog:destroy_with_animation( )

						setCameraMatrix( unpack( positions.wait_roman_matrix ) )
						WatchToElement( true, GEs.ksusha_bot )

						SetAIPedMoveByRoute( GEs.ksusha_bot, positions.ksusha_leave_to_vehicle_path, false, function()
							AddEnterVehiclePattern( GEs.ksusha_bot, temp_vehicle, 0, function()
								SetAIPedMoveByRoute( GEs.ksusha_bot, positions.ksuha_leave_path, false, function()
									triggerServerEvent( "long_awaited_meeting_step_8", localPlayer )
								end )
							end )
						end )
						fadeCamera( true, 1 )
					end

					t.CreatePointTalk() 		
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function()
					FinishQuestCutscene()
					WatchToElement( false )
				end,
				server = function( player )

				end
			},

			event_end_name = "long_awaited_meeting_step_8",
		},
	},

	GiveReward = function( player )
		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, 
		{
			rewards = { money = QUEST_DATA.rewards.money, exp = QUEST_DATA.rewards.exp }
		} )

		player:SituationalPhoneNotification(
			{ title = "Роман", msg = "Привет, заедешь ко мне? Есть что обсудить!" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "delivery_of_goods" then
						return "cancel"
					end
					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true,
			}
		)
	end,

	rewards = {
		money = 3000,
		exp = 3500,
	},
	no_show_rewards = true,
}
