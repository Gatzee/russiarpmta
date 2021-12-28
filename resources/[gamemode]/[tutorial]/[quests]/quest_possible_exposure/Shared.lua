QUEST_CONF = {
	dialogs = {
		start = {
			{ name = "Роман", voice_line = "Roman_possible_exposure_1", text = "Привет, боец! Нам нужно в заброшенный поселок.\nКсения находится там!" },
			{ name = "Роман", text = "Основная сложность это добраться до неё.\nТак как поселок захвачен западным картелем." },
			{ name = "Роман", text = "Держи оружие и бронежилет.\nБудем прорываться с боем!" },			
		},
		
		roman_phrase = {
			{ name = "Роман", voice_line = "Roman_possible_exposure_2", text = "Давай в объезд.\nСо стороны леса зайдем!" },
		},

		ksusha_phrase = {
			{ name = "Ксюша", voice_line = "Ksusha_possible_exposure_1", text = "Охренеть вы во время! У нас тут война идет!" },
			{ name = "Ксюша", text = "Сейчас вообще не до вас!\nХватит целиться в меня!" },
			{ name = "Ксюша", text = "Да, блин! Не иметься, а?!\nДа плевать я хотела на вас!" },
			{ name = "Ксюша", text = "Это был твой компаньон!\nНеожиданно?!" },
		},

		finish = {
			{ name = "Роман", voice_line = "Roman_possible_exposure_3", text = "Ты какого хрена не дал ей сказать?!\nЯ же почти достал всю нужную информацию!" },
			{ name = "Роман", text = "Мда...\nПридется по другому второго грабителя выискивать.\nЯ передам Александру. Будем думать как." },
		},
	},

	positions = {
		roman_spawn 	= { pos = Vector3( 565.74, -519.72, 21.75 ), rot = Vector3( 0, 0, 0 ) },
		roman_veh_spawn = { pos = Vector3( 553.47, -517.50, 20.62 ), rot = Vector3( 0, 0, 5 ) },

		static_vehs = 
		{
			{ pos = Vector3( -1445.81, 979.64, 21.67 ),  rot = Vector3( 0, 0, 50 ),  vehicle_id = 445 },
			{ pos = Vector3( -1475.22, 936.64, 21.32 ),  rot = Vector3( 0, 0, 0 ),   vehicle_id = 445 },
			{ pos = Vector3( -1366.73, 920.11, 20.91 ),  rot = Vector3( 0, 0, 30 ),  vehicle_id = 445 },
			{ pos = Vector3( -1276.99, 921.12, 22.73 ),  rot = Vector3( 0, 0, 0 ),   vehicle_id = 445 },
			{ pos = Vector3( -1197.28, 873.56, 21.14 ),  rot = Vector3( 0, 0, 50 ),  vehicle_id = 445 },
			{ pos = Vector3( -1088.08, 911.46, 21.62 ),  rot = Vector3( 0, 0, 20 ),  vehicle_id = 445 },
			{ pos = Vector3( -1087.51, 903.11, 21.54 ),  rot = Vector3( 0, 0, 10 ),  vehicle_id = 445 },
			{ pos = Vector3( -1087.82, 894.49, 21.14 ),  rot = Vector3( 0, 0, 40 ),  vehicle_id = 445 },
			{ pos = Vector3( -1112.20, 1049.62, 20.49 ), rot = Vector3( 0, 0, 317 ), vehicle_id = 445 },
			{ pos = Vector3( -1141.10, 767.97,  21.35 ), rot = Vector3( 0, 0, 148 ), vehicle_id = 445 },
			{ pos = Vector3( -1213.60, 692.171, 21.14 ), rot = Vector3( 0, 0, 180 ), vehicle_id = 445 },
			{ pos = Vector3( -1263.98, 1001.38, 21.16 ), rot = Vector3( 0, 0, 135 ), vehicle_id = 445 },
			{ pos = Vector3( -953.24, 971.22, 21 ), rot = Vector3( 0, 0, 0 ), vehicle_id = 6527 },
			{ pos = Vector3( -941.69, 971.1, 21 ),  rot = Vector3( 0, 0, 0 ), vehicle_id = 6527 },
			{ pos = Vector3( -781.81, 991.82,  20.70 ), rot = Vector3( 0, 0, 220 ), vehicle_id = 445 },
			{ pos = Vector3( -838.05, 1006.92, 21.04 ), rot = Vector3( 0, 0, 50 ),  vehicle_id = 445 },
			{ pos = Vector3( -869.14, 1006.07, 21.02 ), rot = Vector3( 0, 0, 0 ),  vehicle_id = 6527 },
			{ pos = Vector3( -852.67, 974.59,  20.71 ), rot = Vector3( 0, 0, 0 ),   vehicle_id = 6527 },
			{ pos = Vector3( -899.38, 940.17,  20.71 ), rot = Vector3( 0, 0, 150 ), vehicle_id = 6527 },
			{ pos = Vector3( -875.12, 876.62,  20.91 ), rot = Vector3( 0, 0, 120 ), vehicle_id = 445 },
			{ pos = Vector3( -885.41, 856.03,  20.91 ), rot = Vector3( 0, 0, 0 ), 	vehicle_id = 445 },
			{ pos = Vector3( -906.91, 879.88,  20.91 ), rot = Vector3( 0, 0, 0 ), 	vehicle_id = 6527 },
			{ pos = Vector3( -943.39, 846.09,  20.91 ), rot = Vector3( 0, 0, 100 ), vehicle_id = 445 },
			{ pos = Vector3( -959.41, 886.53,  20.91 ), rot = Vector3( 0, 0, 0 ), 	vehicle_id = 6527 },
			{ pos = Vector3( -759.3522,  905.1604, 20.9316 ), rot = Vector3( 0, 0, 217 ), vehicle_id = 445 },
			{ pos = Vector3( -936.4647,  798.0441, 20.7248 ), rot = Vector3( 0, 0, 0 ),   vehicle_id = 445 },
			{ pos = Vector3( -997.0488,  711.9203, 20.7214 ), rot = Vector3( 0, 0, 177 ), vehicle_id = 445 },
			{ pos = Vector3( -912.3392, 1024.6854, 21.0317 ), rot = Vector3( 0, 0, 70 ),  vehicle_id = 6527 },
			{ pos = Vector3( -981.1063,  798.2446, 20.8388 ), rot = Vector3( 0, 0, 355 ), vehicle_id = 445 },
			{ pos = Vector3( -905.2045,  813.2105, 20.7277 ), rot = Vector3( 0, 0, 255 ), vehicle_id = 6527 },
			{ pos = Vector3( -850.2573,  904.8609, 20.8816 ), rot = Vector3( 0, 0, 13 ),  vehicle_id = 445 },
			{ pos = Vector3( -798.7089, 959.7063, 20.6970 ), rot = Vector3( 0, 0, 234 ), vehicle_id = 6527 },
			{ pos = Vector3( -790.8604, 896.0139, 20.9080 ), rot = Vector3( 0, 0, 187 ), vehicle_id = 6527 },
			{ pos = Vector3( -969.5494, 729.8238, 20.6998 ), rot = Vector3( 0, 0, 18 ), vehicle_id = 6527 },
			{ pos = Vector3( -753.5494, 967.8238, 21.0998 ), rot = Vector3( 180, 0, 100 ), vehicle_id = 445 },
		},

		east_cartel_static_bots =
		{
			{ pos = Vector3( -785.3486, 992.5574, 20.6970 ),  rot = Vector3( 0, 0, 170 ), skin_id = 259, },
			{ pos = Vector3( -907.5783, 816.4820, 20.6998 ),  rot = Vector3( 0, 0, 330 ), skin_id = 259, },
			{ pos = Vector3( -870.9595, 1003.026, 21.0326 ),  rot = Vector3( 0, 0, 229 ), skin_id = 258, },
			{ pos = Vector3( -908.5170, 876.5640, 20.9066 ),  rot = Vector3( 0, 0, 166 ), skin_id = 258, },
			{ pos = Vector3( -961.6719, 884.0839, 20.9066 ),  rot = Vector3( 0, 0, 206 ), skin_id = 258, },
			{ pos = Vector3( -901.8295, 936.7536, 20.7034 ),  rot = Vector3( 0, 0, 235 ), skin_id = 259  },
			{ pos = Vector3( -918.1333, 1021.4532, 20.6882 ), rot = Vector3( 0, 0, 273 ), skin_id = 258, },
			{ pos = Vector3( -1067.1405, 710.1925, 21.0883 ), rot = Vector3( 0, 0, 270 ), skin_id = 259, },
			{ pos = Vector3( -757.1342, 902.7401, 20.9080 ),  rot = Vector3( 0, 0, 124 ), skin_id = 258, },
			{ pos = Vector3( -965.2189, 771.5310, 20.9107 ), rot = Vector3( 0, 0, 27 ), skin_id = 258, },
			{ pos = Vector3( -972.4535, 731.2364, 20.6998 ), rot = Vector3( 0, 0, 117 ), skin_id = 258, },
			{ pos = Vector3( -850.5758, 976.1575, 20.7034 ), rot = Vector3( 0, 0, 52 ),  skin_id = 258, },
		},

		east_cartel_static_bots_plant = 
		{
			{ pos = Vector3( -956.57, 988.21, 25 ), rot = Vector3( 0, 0, 177 ), skin_id = 259 },
			{ pos = Vector3( -931.19, 986.34, 27 ), rot = Vector3( 0, 0, 177 ), skin_id = 259 },
			{ pos = Vector3( -949.98, 983.12, 22 ), rot = Vector3( 0, 0, 177 ), skin_id = 259 },
			{ pos = Vector3( -930.71, 963.21, 22 ), rot = Vector3( 0, 0, 177 ), skin_id = 259 },
		},

		west_cartel_static_bots =
		{
			{ pos = Vector3( -837.9318, 1004.8675, 21.0194 ), rot = Vector3( 0, 0, 94 ),  skin_id = 22, },			
			{ pos = Vector3( -846.2371, 911.8972, 20.7107 ), rot = Vector3( 0, 0, 264 ), skin_id = 22, },
			{ pos = Vector3( -873.4627, 879.6150, 20.9066 ), rot = Vector3( 0, 0, 70 ),  skin_id = 22, },
			{ pos = Vector3( -883.6464, 859.1961, 20.9066 ), rot = Vector3( 0, 0, 60 ),  skin_id = 22, },
			{ pos = Vector3( -934.6824, 801.4047, 20.6998 ), rot = Vector3( 0, 0, 69 ),  skin_id = 22, },
			{ pos = Vector3( -946.9592, 847.2149, 20.9456 ), rot = Vector3( 0, 0, 15 ),  skin_id = 22, },
			{ pos = Vector3( -978.7394, 801.3886, 20.9107 ), rot = Vector3( 0, 0, 47 ),  skin_id = 21, },
			{ pos = Vector3( -997.7467, 708.9026, 20.6998 ), rot = Vector3( 0, 0, 65 ),  skin_id = 21, },
			{ pos = Vector3( -794.2512, 957.0546, 20.6970 ), rot = Vector3( 0, 0, 337 ), skin_id = 21, },
			{ pos = Vector3( -790.1246, 899.8140, 20.9065 ), rot = Vector3( 0, 0, 278 ), skin_id = 21, },
			{ pos = Vector3( -1039.0301, 727.0386, 20.6101 ), rot = Vector3( 0, 0, 87 ), skin_id = 21, },
			{ pos = Vector3( -1045.5115, 720.0624, 20.2107 ), rot = Vector3( 0, 0, 113 ), skin_id = 21 },
		},

		countryside_static_bots =
		{
			{ pos = Vector3( -1197.2312, 876.5143, 21.1399 ), rot = Vector3( 0, 0, 96 ),  skin_id = 21 },
			{ pos = Vector3( -1262.5205, 999.3085, 21.1399 ), rot = Vector3( 0, 0, 119 ), skin_id = 22 },
			{ pos = Vector3( -1274.1831, 924.5936, 22.3814 ), rot = Vector3( 0, 0, 90 ),  skin_id = 21 },
			{ pos = Vector3( -1366.5919, 923.3529, 20.9071 ), rot = Vector3( 0, 0, 88 ),  skin_id = 22 },
			{ pos = Vector3( -1472.8459, 939.2204, 21.2630 ), rot = Vector3( 0, 0, 28 ),  skin_id = 21 },
			{ pos = Vector3( -1446.0622, 976.4515, 21.3738 ), rot = Vector3( 0, 0, 84 ),  skin_id = 22 },
		},

		effects =
		{
			{ pos = Vector3( -816.0700, 971.0022, 35.4822 ), rot = Vector3( 270, 0, 0 ), effect_id = "smoke50lit" },
			{ pos = Vector3( -806.0257, 966.6703, 35.4758 ), rot = Vector3( 270, 0, 0 ), effect_id = "smoke50lit" },
			{ pos = Vector3( -773.9899, 932.5153, 23.2389 ), rot = Vector3( 270, 0, 0 ), effect_id = "smoke50lit" },
			{ pos = Vector3( -843.0603, 947.0527, 30.5602 ), rot = Vector3( 270, 0, 0 ), effect_id = "smoke50lit" },
			{ pos = Vector3( -901.1006, 1008.412, 36.4949 ), rot = Vector3( 270, 0, 0 ), effect_id = "smoke50lit" },
			{ pos = Vector3( -766.8511, 933.1292, 24.5769 ), rot = Vector3( 270, 0, 0 ), effect_id = "fire" },
			{ pos = Vector3( -805.2586, 967.0522, 34.9339 ), rot = Vector3( 270, 0, 0 ), effect_id = "fire" },
			{ pos = Vector3( -823.3960, 941.8014, 34.3029 ), rot = Vector3( 270, 0, 0 ), effect_id = "fire" },
			{ pos = Vector3( -812.2381, 879.3352, 34.6866 ),  rot = Vector3( 270, 0, 0 ), effect_id = "fire" },
			{ pos = Vector3( -753.5494, 967.8238, 21.6998 ), rot = Vector3( 270, 0, 0 ), effect_id = "fire" },
			{ pos = Vector3( -895.7144, 1006.5869, 26.5333 ), rot = Vector3( 270, 0, 0 ), effect_id = "fire" },
			{ pos = Vector3( -894.8458, 1012.1304, 34.1406 ), rot = Vector3( 270, 0, 0 ), effect_id = "fire" },
			{ pos = Vector3( -829.2652, 985.19366, 34.9082 ), rot = Vector3( 270, 0, 0 ), effect_id = "fire" },
			{ pos = Vector3( -889.3700, 816.34130, 25.1714 ), rot = Vector3( 270, 0, 0 ), effect_id = "fire" },
			{ pos = Vector3( -964.9885, 927.5593, 25.2569 ), rot = Vector3( 270, 0, 0 ), effect_id = "fire" },
			{ pos = Vector3( -967.3123, 925.2309, 25.3558 ), rot = Vector3( 270, 0, 0 ), effect_id = "fire" },
			{ pos = Vector3( -879.4634, 956.3894, 28.7584 ), rot = Vector3( 270, 0, 0 ), effect_id = "fire" },
			{ pos = Vector3( -886.7338, 946.8374, 25.7070 ), rot = Vector3( 270, 0, 0 ), effect_id = "fire" },
			{ pos = Vector3( -926.7552, 854.6013, 25.8949 ), rot = Vector3( 270, 0, 0 ), effect_id = "fire" },
			{ pos = Vector3( -985.5825, 784.0999, 31.7758 ), rot = Vector3( 270, 0, 0 ), effect_id = "fire" },
		},

		country = { pos = Vector3( -714.81, 1020.5, 19.7 ) },
		detour_path =
		{
			Vector3( -1152.11, 1111.65, 19.7 ),
			Vector3( -1384.86, 1140.01, 19.7 ),
			Vector3( -1614.55, 1084.67, 19.7 ),
			Vector3( -1614.52, 975.8, 20.14 ),
			Vector3( -1343.51, 907.16, 19.91 ),
			Vector3( -1101.5, 895.1, 20.14 ),
		},

		vehicle_country_parking = { pos = Vector3( -1101.5, 895.1, 20.14 ), rot = Vector3( 0, 0, 303 ) },

		ksusha_spawn = { pos = Vector3( -968.51, 907.74, 21 ), rot = Vector3( 0, 0, 53 ), skin_id = 80, },
		head_cartel_spawn = { pos = Vector3( -961.91, 902.93, 21 ), rot = Vector3( 0, 0, 53 ), skin_id = 262 },
		
		escape_1_path_1 = 
		{
			{ x = -968.51, y = 907.74, z = 21 },
			{ x = -978.11, y = 915.47, z = 21 },
			{ x = -949.25, y = 969.46, z = 21 },
		},

		escape_1_camera_1 = { pos = Vector3( -1004.0404, 918.3353, 27.7011 ) },
		escape_1_camera_2 = { pos = Vector3( -966.8724,  928.7738, 31.1487 ) },

		attack_path_roman = 
		{
			{ x = -1085.9073, y = 890.2487, z = 21 },
			{ x = -1052.8005, y = 905.9351, z = 21 },
			{ x = -1011.4700, y = 936.0158, z = 21 },
			{ x = -971.7051,  y = 964.6984, z = 21 },
		},
	
		escape_2_camera_1 = { pos = Vector3( -932.4036, 959.7527, 30.0883 ) },
		escape_2_camera_2 = { pos = Vector3( -936.2365, 984.5766, 23.0747 ) },

		east_cartel_veh_cutscene_spawn = { pos = Vector3( -882.8473, 995.0959, 21.1511 ), rot = Vector3( 0, 0, 97 ), vehicle_id = 445 },
		east_cartel_veh_path = 
		{
			{ x = -898.6796, y = 992.3788, z = 21.0860 },
		},

		player_escape_2 = { pos = Vector3( -955.3193, 972.4057, 21.1243 ), rot = Vector3( 0, 0, 298 ) },
		roman_escape_2 = { pos = Vector3( -939.1253, 980.7611, 21.1226 ), rot = Vector3( 0, 0, 278 ) },
		escape_2_path_roman =
		{
			{ x = -928.5963, y = 979.9663, z = 21.1157, move_type = 7 },
			{ x = -924.7193, y = 989.7613, z = 21.1108, move_type = 7 },
		},

		ksusha_escape_2 = { pos = Vector3( -939.7496, 971.9600, 21.1189 ), rot = Vector3( 0, 0, 267 ) },
		escape_2_path_ksusha =
		{
			{ x = -921.03979492188, y = 977.3984375, z = 21.118076324463, move_type = 7 },
		},
		escape_2_1_path_ksusha =
		{
			{ x = -925.623046875, y = 990.84893798828, z = 21.110704421997, move_type = 7 },
		},

		head_cartel_escape_2 = { pos = Vector3( -940.1799, 969.9786, 21.1200 ), rot = Vector3( 0, 0, 271 ) },
		escape_2_path_head_cartel =
		{
			{ x = -920.5217, y = 972.6181, z = 21, move_type = 7 },
		},
		escape_2_1_path_head_cartel =
		{
			{ x = -908.9345, y = 949.3300, z = 21, move_type = 7 },
		},

		ksusha_roof = { pos = Vector3( -951.081, 1022.697, 55.169 ), rot = Vector3( 0, 0, 270 ) },
		roman_roof = { pos = Vector3( -949.878, 1022.394, 55.169 ), rot = Vector3( 0, 0, 77 ) },
		player_roof = { pos = Vector3( -948.722, 1023.725, 55.169 ), rot = Vector3( 0, 0, 114 ) },

		head_cartel_ksusha_view = { pos = Vector3( -953.0979, 1040.0032, 21.1186 ), rot = Vector3( 0, 0, 168 ) },

		out_plant_player = { pos = Vector3( -945.0461, 981.5587, 21.1149 ), rot = Vector3( 0, 0, 158 ) },
		out_plant_roman = { pos = Vector3( -957.8329, 970.0531, 21.1260 ), rot = Vector3( 0, 0, 160 ) },

		out_plant_bots = {
			{ pos = Vector3( -960.1507, 939.6680, 20.9612 ), rot = Vector3( 0, 0, 48 ), skin_id = 258 },
			{ pos = Vector3( -968.3444, 935.7357, 20.9612 ), rot = Vector3( 0, 0, 15 ), skin_id = 259 },
		},

		pre_finish_camera_matrix = { 559.1967, -513.7012, 24.081, 484.0262, -572.7712, -5.2460, 0, 70 },
		finish_veh_parking = { pos = Vector3( 552.9448, -517.2547, 20.6220 ), rot = Vector3( 0, 0, 171 ) },
		finish_path_player = {
			{ x = 553.7231, y = -521.0644, z = 20.9336, move_type = 4 },
			{ x = 552.7537, y = -521.7506, z = 20.9336, move_type = 4 },
		},
		finish_path_roman = {
			{ x = 550.2532, y = -518.7333, z = 20.9336, move_type = 4 },
			{ x = 551.7543, y = -521.8426, z = 20.9336, move_type = 4 },
		},
		finish_player = { pos = Vector3( 552.7537, -521.7506, 20.9336 ), rot = Vector3( 0, 0, 90 ) },
		finish_roman =  { pos = Vector3( { x = 551.7543, y = -521.8426, z = 20.9336 } ), rot = Vector3( 0, 0, 270 ) },
		finish_camera_matrix = { 553.6722, -522.0753, 21.8573, 456.9536, -509.04586, 0.04565, 0, 70 },
	},

	player_weapons = {
		{ weapon_id = 29, ammo = 999 },
	},

	quest_vehicle_id = 6539,
}

GEs = { }

QUEST_DATA = {
	id = "possible_exposure",
	is_company_quest = true,

	title = "Возможное разоблачение",
	description = "Это конец! Нужно все обставить так, чтобы меня не смогли заподозрить.",

	CheckToStart = function( player )
		if player.interior ~= 0 or player.dimension ~= 0 then return end
		return true
	end,

	restart_position = Vector3( 556.4246, -496.3263, 20.9102 ),

	quests_request = { "the_inevitable_path" },
	level_request = 20,

	OnAnyFinish = {
		client = function()
			fadeCamera( true, 1 )
			toggleControl( "enter_exit", true )
		end,
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			DisableQuestEvacuation( player )
			
			ExitLocalDimension( player )
			RestoreWeapon( player )
		end,
	},

	tasks = {
		{
			name = "Встретиться с Романом",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateMarkerToCutsceneNPC( {
						id = "roman_near_house",
						dialog = QUEST_CONF.dialogs.start,
						radius = 1,
						callback = function( )
							CEs.marker.destroy( )
							EnterLocalDimension( )

							CEs.dialog:next( )
							StartPedTalk( FindQuestNPC( "roman_near_house" ).ped, nil, true )

							setTimerDialog( function()
								CEs.dialog:next( )
								setTimerDialog( function()
									CEs.dialog:next( )
									setTimerDialog( function()
										triggerServerEvent( "possible_exposure_step_1", localPlayer )
									end, 4300 )
								end, 4700, 1 )	
							end, 4400, 1 )
						end
					} )
				end,

				server = function( player )
					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, QUEST_CONF.quest_vehicle_id, positions.roman_veh_spawn.pos, positions.roman_veh_spawn.rot )
					vehicle:SetNumberPlate( "1:м421кр178" )
					vehicle:SetColor( 0, 0, 0 )
					
					player:SetPrivateData( "temp_vehicle", vehicle )
				end
			},

			CleanUp = {
				client = function( data, failed )
					StopPedTalk( FindQuestNPC( "roman_near_house" ).ped )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "possible_exposure_step_1",
		},

		{
			name = "Садись в машину",

			Setup = {
				client = function( )
					HideNPCs()
					EnableCheckQuestDimension( true )

					local positions = QUEST_CONF.positions

					CreateStaticElements()

					local fake_npc_roman = FindQuestNPC( "roman_near_house" )
					GEs.roman_bot = CreateAIPed( fake_npc_roman.model, fake_npc_roman.position, fake_npc_roman.rotation )
					LocalizeQuestElement( GEs.roman_bot )
					SetUndamagable( GEs.roman_bot, true )
					setPedStat( GEs.roman_bot, 76, 1000 )
					setPedStat( GEs.roman_bot, 22, 1000 )

					GEs.follow_interface = CreateFollowInterface()
					--GEs.follow_interface:follow( GEs.roman_bot )

					GEs.check_roman_dist = setTimer( function()
						local distance = (localPlayer.position - GEs.roman_bot.position).length
						if distance > 150 then
							FailCurrentQuest( "Ты оставил Романа одного!" )
						elseif distance > 50 then
							localPlayer:ShowError( "Вернись за Романом!" )
						end
					end, 2000, 0 )
					
					GEs.temp_vehicle = localPlayer:getData( "temp_vehicle" )
					table.insert( GEs, WatchElementCondition( GEs.temp_vehicle, {
						condition = function( self, conf )
							if self.element.health <= 360 or self.element.inWater then
								FailCurrentQuest( "Машина Романа уничтожена" )
								return true
							elseif self.element:GetFuel( ) <= 0 then
								FailCurrentQuest( "Закончилось топливо!" )
								return true
							end
						end,
					} ) )

					CreateQuestPoint( GEs.temp_vehicle.position, function( self, player )
						CEs.marker.destroy( )
					end, _, 5 )
					
					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F чтобы сесть на водительское место",
						condition = function( )
							return isElement( GEs.temp_vehicle ) and ( localPlayer.position - GEs.temp_vehicle.position ).length <= 4
						end
					} )

					GEs.OnClientVehicleStartEnter_handler = function( player, seat )
						if (player == localPlayer and seat ~= 0) or GEs.blowed then
							cancelEvent( )
							localPlayer:ShowError( "Садись за руль" )
						elseif player == localPlayer and CEs.hint then
							CEs.hint:destroy()
							CEs.hint = nil
						end
					end
					addEventHandler( "onClientVehicleStartEnter", GEs.temp_vehicle, GEs.OnClientVehicleStartEnter_handler )

					CEs.OnClientVehicleEnter_handler = function( ped )
						if ped == localPlayer then
							warpPedIntoVehicle( GEs.roman_bot, GEs.temp_vehicle, 1 )
						end

						if localPlayer.vehicle == GEs.temp_vehicle and GEs.roman_bot.vehicle == GEs.temp_vehicle then
							removeEventHandler( "onClientVehicleEnter", GEs.temp_vehicle, CEs.OnClientVehicleEnter_handler )
							triggerServerEvent( "possible_exposure_step_2", localPlayer )
						end
					end
					addEventHandler( "onClientVehicleEnter", GEs.temp_vehicle, CEs.OnClientVehicleEnter_handler )
				end,
				server = function( player )
					GiveQuestWeapon( player, QUEST_CONF.player_weapons )
				end,
			},

			event_end_name = "possible_exposure_step_2",
		},

		{
			name = "Прибыть на место",

			Setup = {
				client = function( )
					toggleControl( "enter_exit", false )

					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.country.pos, function( self, player )
						CEs.marker.destroy( )
						GEs.dialog = CreateDialog( QUEST_CONF.dialogs.roman_phrase, nil, true )
						GEs.dialog:next()

						GEs.destroy_dialog_tmr = setTimer( function()
							GEs.dialog:destroy()
						end, 2300, 1 )

						triggerServerEvent( "possible_exposure_step_3", localPlayer )
					end, _, 15, _, _, function( self, player )
						if localPlayer.vehicle ~= GEs.temp_vehicle then
							return false, "А где машина Романа?"
						elseif GEs.roman_bot.vehicle ~= GEs.temp_vehicle then
							return false, "А где Роман?"
						end
						return true
					end )
					CEs.marker.slowdown_coefficient = nil
				end,
				server = function( player )
					player.vehicle.locked = true
				end,
			},

			event_end_name = "possible_exposure_step_3",
		},

		{
			name = "Начать атаку с тыла",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CEs.func_create_next_point = function( point_id )
						CreateQuestPoint( positions.detour_path[ point_id ], function( self, player )
							CEs.marker.destroy( )
							if #positions.detour_path == point_id then
								fadeCamera( false, 1 )
								GEs.follow_interface:stop_follow( GEs.roman_bot )

								CEs.end_step_tmr = setTimer( function( )
									localPlayer.vehicle.position = positions.vehicle_country_parking.pos
									localPlayer.vehicle.rotation = positions.vehicle_country_parking.rot

									triggerServerEvent( "possible_exposure_step_4", localPlayer )
								end, 1000, 1 )
							else
								CEs.func_create_next_point( point_id + 1 )
							end
						end, _, 15, _, _, function( self, player )
							if localPlayer.vehicle ~= GEs.temp_vehicle then
								return false, "А где машина Романа?"
							elseif GEs.roman_bot.vehicle ~= GEs.temp_vehicle then
								return false, "А где Роман?"
							end
							return true
						end )
						
						if #positions.detour_path ~= point_id then 
							CEs.marker.slowdown_coefficient = nil
						end
					end
					CEs.func_create_next_point( 1 )

					StartQuestTimerFail( 1.5 * 60 * 1000, "Начать атаку с тыла", "Слишком медленно!" )
				end,
				server = function( player )

				end,
			},

			event_end_name = "possible_exposure_step_4",
		},

		{
			name = "...",

			Setup = {
				client = function( )
					GEs.temp_vehicle.frozen = true
					CreateAIPed( localPlayer )
					for i, v in pairs( { localPlayer, GEs.roman_bot } ) do
						AddAIPedPatternInQueue( v, AI_PED_PATTERN_VEHICLE_EXIT, { } )
					end

					local positions = QUEST_CONF.positions

					GEs.east_cartel_static_bots_plant = CreateStaticBots( positions.east_cartel_static_bots_plant, false, nil, 300 )

					GEs.ksusha_bot = CreateAIPed( positions.ksusha_spawn.skin_id, positions.ksusha_spawn.pos, positions.ksusha_spawn.rot.z )
					LocalizeQuestElement( GEs.ksusha_bot )
					SetUndamagable( GEs.ksusha_bot, true )
					setPedStat( GEs.ksusha_bot, 76, 1000 )
					setPedStat( GEs.ksusha_bot, 22, 1000 )

					GEs.head_cartel_bot = CreateAIPed( positions.head_cartel_spawn.skin_id, positions.head_cartel_spawn.pos, positions.head_cartel_spawn.rot.z )
					LocalizeQuestElement( GEs.head_cartel_bot )
					givePedWeapon( GEs.head_cartel_bot, 29, 3000, true )
					SetUndamagable( GEs.head_cartel_bot, true )
					setPedStat( GEs.head_cartel_bot, 76, 1000 )
					setPedStat( GEs.head_cartel_bot, 22, 1000 )

					setCameraMatrix( positions.escape_1_camera_1.pos )
					CEs.watch_element_interface = WatchToElementInterface( GEs.ksusha_bot )

					StartQuestCutscene( )

					SetAIPedMoveByRoute( GEs.ksusha_bot, positions.escape_1_path_1, false )
					SetAIPedMoveByRoute( GEs.head_cartel_bot, positions.escape_1_path_1, false )

					CEs.change_camera_first = function()
						CEs.watch_element_interface:change_camera_position( positions.escape_1_camera_2.pos )
					end
					CEs.change_camera_tmr = setTimer( CEs.change_camera_first, 9000, 1 )

					CEs.func_fade_camera = function( )
						local fade_time = 1
						fadeCamera( false, fade_time )
						CEs.end_step_tmr = setTimer( function()
							GEs.ksusha_bot.position = positions.ksusha_escape_2.pos
							GEs.ksusha_bot.rotation = positions.ksusha_escape_2.rot
		
							GEs.head_cartel_bot.position = positions.head_cartel_escape_2.pos
							GEs.head_cartel_bot.rotation = positions.head_cartel_escape_2.rot
							triggerServerEvent( "possible_exposure_step_5", localPlayer )
						end, fade_time * 1000, 1 )
					end
					CEs.fade_camera_tmr = setTimer( CEs.func_fade_camera, 15000, 1 )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function( data, failed )
					ClearAIPed( localPlayer )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "possible_exposure_step_5",
		},

		{
			name = "Расправься с бандитами",

			Setup = {
				client = function( )
					GEs.temp_vehicle.frozen = false

					local positions = QUEST_CONF.positions
				
					local need_kills = #GEs.east_cartel_static_bots_plant
					CEs.plant_bot_dead = function()
						CEs.count_kills = (CEs.count_kills or 0) + 1
						CEs.blips_enemy[ source ]:destroy()

						if CEs.count_kills == need_kills then
							if isTimer( GEs.refresh_target_tmr ) then killTimer( GEs.refresh_target_tmr ) end
							GEs.attack_roman_interface:destroy()
							GEs.attack_plant_bots_interface:destroy()
							
							local fade_time = 2
							fadeCamera( false, fade_time )
							GEs.attack_interface_1.distance_no_spread = 1
							GEs.attack_interface_2.distance_no_spread = 1
							CEs.end_step_tmr = setTimer( triggerServerEvent, fade_time * 1000, 1, "possible_exposure_step_6", localPlayer )
						end
					end

					CEs.blips_enemy = {}
					for k, v in pairs( GEs.east_cartel_static_bots_plant ) do
						CEs.blips_enemy[ v ] = createBlipAttachedTo( v, 0, 1 )
						addEventHandler( "onClientPedWasted", v, CEs.plant_bot_dead )
					end
					
					givePedWeapon( GEs.roman_bot, 29, 3000, true )
					SetAIPedMoveByRoute( GEs.roman_bot, positions.attack_path_roman, false )

					CEs.start_attack_tmr = setTimer( function()
						GEs.attack_plant_bots_interface = CreateAttackBotsInterface( table.copy( GEs.east_cartel_static_bots_plant ), { GEs.roman_bot } )
						GEs.attack_roman_interface = CreateAttackBotsInterface( { GEs.roman_bot }, table.copy( GEs.east_cartel_static_bots_plant ), nil, true )
						GEs.refresh_target_tmr = setTimer( function()
							GEs.attack_plant_bots_interface:refresh_targets()
							GEs.attack_roman_interface:refresh_targets()
						end, 250, 0 )
					end, 25000, 1 )

					StartQuestTimerFail( 4 * 60 * 1000, "Расправься с бандитами", "Ксюша сбежала!" )
				end,
				server = function( player )

				end,
			},

			event_end_name = "possible_exposure_step_6",
		},

		{
			name = "...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					
					localPlayer.position = positions.player_escape_2.pos
					localPlayer.rotation = positions.player_escape_2.rot

					GEs.follow_interface:stop_follow( GEs.roman_bot )

					setCameraMatrix( positions.escape_2_camera_1.pos )
					CEs.watch_element_interface = WatchToElementInterface( GEs.ksusha_bot )

					givePedWeapon( GEs.ksusha_bot, 29, 3000, true )
					StartQuestCutscene( )

					local func_set_attack = function( bot, state, target )
						if state then
							setPedAimTarget( bot, target.position )
						else
							setPedWeaponSlot( bot, 0 )
						end
						setPedControlState( bot, "aim_weapon", state )
						setPedControlState( bot, "fire", state )
					end

					SetAIPedMoveByRoute( GEs.ksusha_bot, positions.escape_2_path_ksusha, false, function()
						func_set_attack( GEs.ksusha_bot, true, GEs.east_carteh_veh_bots[ math.random(1, #GEs.east_carteh_veh_bots) ] )
					end )

					SetAIPedMoveByRoute( GEs.head_cartel_bot, positions.escape_2_path_head_cartel, false, function()
						func_set_attack( GEs.head_cartel_bot, true, GEs.east_carteh_veh_bots[ math.random(1, #GEs.east_carteh_veh_bots) ] )
					end )

					CEs.next_cutscene_move_tmr = setTimer( function()
						func_set_attack( GEs.ksusha_bot, false )
						func_set_attack( GEs.head_cartel_bot, false )

						SetAIPedMoveByRoute( GEs.ksusha_bot, positions.escape_2_1_path_ksusha, false )
						SetAIPedMoveByRoute( GEs.head_cartel_bot, positions.escape_2_1_path_head_cartel, false )
					end, 8000, 1 )

					GEs.east_cartel_veh = CreateQuestVehicle( positions.east_cartel_veh_cutscene_spawn )

					GEs.east_carteh_veh_bots = {}
					for i = 0, 0 do
						local bot = CreateAIPed( 21, Vector3() )
						LocalizeQuestElement( bot )
						SetUndamagable( bot, true )
						givePedWeapon( bot, 29, 3000, true )
						setPedStat( bot, 76, 1000 )
						setPedStat( bot, 22, 1000 )

						warpPedIntoVehicle( bot, GEs.east_cartel_veh, i )
						SetAIPedMoveByRoute( bot, positions.east_cartel_veh_path, false, function( )
							for k, v in pairs( GEs.east_carteh_veh_bots ) do
								AddAIPedPatternInQueue( v, AI_PED_PATTERN_VEHICLE_EXIT, {
									end_callback = {
										func = function()
											setPedAimTarget( v, GEs.head_cartel_bot.position )
											setPedControlState( v, "aim_weapon", true )
											setPedControlState( v, "fire", true )
										end,
										args = { },
									}
								} )
							end
						end )

						table.insert( GEs.east_carteh_veh_bots, bot )
					end

					CEs.change_camera_first = function()
						GEs.roman_bot.position = positions.roman_escape_2.pos
						GEs.roman_bot.rotation = positions.roman_escape_2.rot

						SetAIPedMoveByRoute( GEs.roman_bot, positions.escape_2_path_roman, false )
						CEs.watch_element_interface:change_camera_target( GEs.roman_bot, positions.escape_2_camera_2.pos )
					end
					CEs.change_camera_tmr = setTimer( CEs.change_camera_first, 10000, 1 )

					CEs.change_camera_second = function()
						for k, v in pairs( GEs.east_carteh_veh_bots ) do
							setPedControlState( v, "aim_weapon", false )
							setPedControlState( v, "fire", false )
						end
					end
					CEs.change_camera_tmr_2 = setTimer( CEs.change_camera_second, 14000, 1 )

					CEs.func_fade_camera = function( )
						local fade_time = 1
						fadeCamera( false, fade_time )
						CEs.end_step_tmr = setTimer( triggerServerEvent, fade_time * 1000, 1, "possible_exposure_step_7", localPlayer )
					end
					CEs.fade_camera_tmr = setTimer( CEs.func_fade_camera, 13000, 1 )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function( data, failed )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "possible_exposure_step_7",
		},

		{
			name = "Убей Ксюшу",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					for k, v in pairs( { GEs.roman_bot, GEs.ksusha_bot, GEs.head_cartel_bot } ) do
						CleanupAIPedPatternQueue( v )
						removePedTask( v )
					end

					ToggleMoveControls( false )
					localPlayer.position = positions.player_roof.pos
					localPlayer.rotation = positions.player_roof.rot

					GEs.roman_bot.position = positions.roman_roof.pos
					GEs.roman_bot.rotation = positions.roman_roof.rot

					GEs.ksusha_bot.position = positions.ksusha_roof.pos
					GEs.ksusha_bot.rotation = positions.ksusha_roof.rot
					
					GEs.head_cartel_bot.position = positions.head_cartel_ksusha_view.pos
					GEs.head_cartel_bot.rotation = positions.head_cartel_ksusha_view.rot
					setPedWeaponSlot( GEs.head_cartel_bot, 0 )

					GEs.ksusha_bot.health = 10
					SetUndamagable( GEs.ksusha_bot, false )

					givePedWeapon( GEs.roman_bot, 24, 100, true )
					setPedAimTarget( GEs.roman_bot, GEs.ksusha_bot.position + Vector3( 0, -0.2, 0 ) )
					setPedControlState( GEs.roman_bot, "aim_weapon", true )

					CEs.dialog_ksusha = CreateDialog( QUEST_CONF.dialogs.ksusha_phrase, nil, true )
					
					CEs.dialog_id = 0
					CEs.dialog_times = { 3000, 4800, 3900 }

					CEs.func_next_dialog = function()
						CEs.dialog_ksusha:next()
						CEs.dialog_id = CEs.dialog_id + 1
						if CEs.dialog_times[ CEs.dialog_id ] then
							CEs.phrase_tmr = setTimer( CEs.func_next_dialog, CEs.dialog_times[ CEs.dialog_id ], 1 )
						end
					end
					CEs.func_next_dialog()
					StartPedTalk( GEs.ksusha_bot, nil, true )

					CEs.func_start_cutscene = function()
						SetAIPedMoveByRoute( GEs.roman_bot, {
							{ x = -951.4621, y = 1021.6624, z = 55.1589, move_type = 4 },
						}, false, function()
							GEs.roman_bot.rotation = Vector3( 0, 0, 77 )
							setPedAimTarget( GEs.roman_bot, GEs.ksusha_bot.position + Vector3(  0, 4, 0 ) )
						end )
						CEs.start_move_head_cartel_tmr = setTimer( CEs.func_start_move_head_cartel, 1000, 1 )
					end

					CEs.func_start_move_head_cartel = function()
						local head_cartel_pos = GEs.ksusha_bot.position
						SetAIPedMoveByRoute( GEs.head_cartel_bot, {
							{ x = head_cartel_pos.x, y = head_cartel_pos.y, z = head_cartel_pos.z, move_type = 7, distance = 2 },
						}, false, function()
							CEs.look_tmr = setTimer( function()
								GEs.head_cartel_bot.rotation = Vector3( 0, 0, 235 )
								setPedAnimation( GEs.head_cartel_bot, "on_lookers", "lkup_loop", 100, false, false, false, true, 250, false )

								CEs.end_tmr = setTimer( function()
									local fade_time = 1
									fadeCamera( false, fade_time )
									CEs.end_step_tmr = setTimer( triggerServerEvent, fade_time * 1000, 1, "possible_exposure_step_8", localPlayer )
								end, 1500, 1 )
							end, 500, 1 )
						end )
					end

					addEventHandler( "onClientPedWasted", GEs.ksusha_bot, function()
						if isTimer( CEs.fail_tmr ) then killTimer( CEs.fail_tmr ) end
						if isTimer( CEs.phrase_tmr ) then killTimer( CEs.phrase_tmr ) end

						CEs.bg_progress_bar:destroy()
						CEs.dialog_ksusha:destroy()

						setGameSpeed( 0.2 )
						CEs.reset_game_speed_tmr = setTimer( setGameSpeed, 2000, 1, 1 )
						CEs.move_camera = MoveCameraAndWatchElement( nil, Vector3( -951.77, 1024.87, 59.52 ), 3000, GEs.ksusha_bot )

						CEs.start_move_roman_tmr = setTimer( CEs.func_start_cutscene, 3000, 1 )
					end )

					
					local fail_time = 14000
					CEs.start_ticks = getTickCount()
					CEs.bg_progress_bar = ibCreateImage( 0, 0, 500, 20, ":nrp_casino_game_classic_roulette/img/bg_progress_bar.png", nil ):center( nil, _SCREEN_Y / 4 )
					CEs.progress_bar = ibCreateImage( 0, 0, 500, 20, _, CEs.bg_progress_bar, 0xFFFFDE96 )
						:ibOnRender( function()
							local fProgress = (getTickCount() - CEs.start_ticks) / (fail_time - 2000)
							if fProgress <= 1 then
								local size_x = interpolateBetween( 0, 0, 0, 500, 0, 0, fProgress, "Linear" )
								CEs.progress_bar:ibBatchData( {
									sx = 500 - size_x,
								})
							else
								CEs.bg_progress_bar:destroy()
							end
						end )

					CEs.progress_bar_text = ibCreateLabel( 0, 0, 500, 20, "Убей Ксюшу", CEs.bg_progress_bar, 0xFF000000, _, _, "center", "center", ibFonts.semibold_12 )

					CEs.fail_tmr = setTimer( function()
						FailCurrentQuest( "Ксюша раскрыла тебя!" )
						setTimer( function()
							localPlayer.position = QUEST_CONF.positions.out_plant_player.pos
							localPlayer.rotation = QUEST_CONF.positions.out_plant_player.rot
						end, 250, 1 )
					end, fail_time, 1 )

					setPedWeaponSlot( localPlayer, 2 )
				end,
				server = function( player )
					player:GiveWeapon( 24, 7, true, true, "quest_possible_exposure" )
				end,
			},

			CleanUp = {
				client = function( data, failed )
					setGameSpeed( 1 )
					ToggleMoveControls( true )
				end,
			},

			event_end_name = "possible_exposure_step_8",
		},

		{
			name = "Расправься с бандитами",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					GEs.ksusha_bot:destroy()
					GEs.head_cartel_bot:destroy()

					GEs.east_cartel_out_plant_bots = CreateStaticBots( positions.out_plant_bots, false, nil, 300 )
					GEs.attack_out_plant_bots = CreateAttackBotsInterface( table.copy( GEs.east_cartel_out_plant_bots ), { GEs.roman_bot } )
					GEs.attack_roman_interface = CreateAttackBotsInterface( { GEs.roman_bot }, table.copy( GEs.east_cartel_out_plant_bots ), nil, true )
					
					GEs.refresh_out_plant_target_tmr = setTimer( function()
						GEs.attack_out_plant_bots:refresh_targets()
						GEs.attack_roman_interface:refresh_targets()
					end, 250, 0 )

					localPlayer.position = positions.out_plant_player.pos
					localPlayer.rotation = positions.out_plant_player.rot

					GEs.roman_bot.position = positions.out_plant_roman.pos
					GEs.roman_bot.rotation = positions.out_plant_roman.rot
					setPedControlState( GEs.roman_bot, "aim_weapon", false )
					
					local need_kills = #GEs.east_cartel_out_plant_bots
					CEs.count_kills = 0
					CEs.plant_bot_dead = function()
						CEs.count_kills = CEs.count_kills + 1
						CEs.blips_enemy[ source ]:destroy()

						if CEs.count_kills == need_kills then
							if isTimer( GEs.refresh_out_plant_target_tmr ) then killTimer( GEs.refresh_out_plant_target_tmr ) end
							GEs.attack_roman_interface:destroy()
							GEs.attack_out_plant_bots:destroy()
							
							triggerServerEvent( "possible_exposure_step_9", localPlayer )
						end
					end

					CEs.blips_enemy = {}
					for k, v in pairs( GEs.east_cartel_out_plant_bots ) do
						CEs.blips_enemy[ v ] = createBlipAttachedTo( v, 0, 1 )
						addEventHandler( "onClientPedWasted", v, CEs.plant_bot_dead )
					end

					givePedWeapon( GEs.roman_bot, 29, 3000, true )
					setCameraTarget( localPlayer )
					fadeCamera( true, 1 )
				end,
				server = function( player )

				end,
			},

			event_end_name = "possible_exposure_step_9",
		},

		{
			name = "Садись в машину Романа",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					setPedWeaponSlot( GEs.roman_bot, 0 )
					GEs.follow_interface:follow( GEs.roman_bot )

					CreateQuestPoint( GEs.temp_vehicle.position, function( self, player )
						CEs.marker.destroy( )
					end, _, 5 )
					
					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F чтобы сесть на водительское место",
						condition = function( )
							return isElement( GEs.temp_vehicle ) and ( localPlayer.position - GEs.temp_vehicle.position ).length <= 4
						end
					} )

					CEs.OnClientVehicleEnter_handler = function( ped )
						if localPlayer.vehicle == GEs.temp_vehicle and GEs.roman_bot.vehicle == GEs.temp_vehicle then
							setPedWeaponSlot( GEs.roman_bot, 0 )
							removeEventHandler( "onClientVehicleEnter", GEs.temp_vehicle, CEs.OnClientVehicleEnter_handler )
							triggerServerEvent( "possible_exposure_step_10", localPlayer )
						end
					end
					addEventHandler( "onClientVehicleEnter", GEs.temp_vehicle, CEs.OnClientVehicleEnter_handler )
				end,
				server = function( player )

				end,
			},

			event_end_name = "possible_exposure_step_10",
		},

		{
			name = "Отвези Романа домой",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					CEs.func_start_move_cutscene = function()
						GEs.temp_vehicle.frozen = true
						
						setCameraMatrix( unpack( positions.pre_finish_camera_matrix ) )
						StartQuestCutscene()
						localPlayer.frozen = false

						GEs.follow_interface:stop_follow( GEs.roman_bot )

						CreateAIPed( localPlayer )
						for k, v in pairs( { localPlayer, GEs.roman_bot } ) do
							AddAIPedPatternInQueue( v, AI_PED_PATTERN_VEHICLE_EXIT, {
								end_callback = {
									func = function()
										SetAIPedMoveByRoute( v, v == localPlayer and  positions.finish_path_player or positions.finish_path_roman, false, function()
											CleanupAIPedPatternQueue( v )
											removePedTask( v )

											CEs.count_end_route = (CEs.count_end_route or 0) + 1
											if CEs.count_end_route == 2 then
												CEs.func_dialog()
											end
											if v == localPlayer then
												localPlayer.position = positions.finish_player.pos
												localPlayer.rotation = positions.finish_player.rot
											else
												GEs.roman_bot.position = positions.finish_roman.pos
												GEs.roman_bot.rotation = positions.finish_roman.rot
											end
										end )
									end,
									args = { },
								}
							} )
						end
						
						CEs.end_move_tmr = setTimer( function()
							CleanupAIPedPatternQueue( localPlayer )
							removePedTask( localPlayer )
							localPlayer.position = positions.finish_player.pos
							localPlayer.rotation = positions.finish_player.rot

							CleanupAIPedPatternQueue( GEs.roman_bot )
							removePedTask( GEs.roman_bot )
							GEs.roman_bot.position = positions.finish_roman.pos
							GEs.roman_bot.rotation = positions.finish_roman.rot
							
							CEs.func_dialog()
						end, 18000, 1 )
					end

					CEs.func_dialog = function()
						if isTimer( CEs.end_move_tmr ) then killTimer( CEs.end_move_tmr ) end
						
						local fade_time = 1
						fadeCamera( false, fade_time )
						CEs.fade_tmr = setTimer( function( )
							setCameraMatrix( unpack( positions.finish_camera_matrix ) )
							fadeCamera( true, fade_time )
							StartPedTalk( GEs.roman_bot, nil, true )

							CEs.dialog = CreateDialog( QUEST_CONF.dialogs.finish )
							CEs.dialog:next()

							setTimerDialog( function()
								CEs.dialog:next()
								setTimerDialog( CEs.func_end_step, 9400, 1 )
							end, 4000 )
						end, fade_time * 1000, 1 )
					end

					CEs.func_end_step = function()
						local fade_time = 1
						fadeCamera( false, fade_time )
						CEs.end_step_tmr = setTimer( function( )
							FinishQuestCutscene()
							triggerServerEvent( "possible_exposure_step_11", localPlayer )
						end, fade_time * 1000, 1 )
					end

					CreateQuestPoint( positions.finish_veh_parking.pos, function( self, player )
						CEs.marker.destroy( )

						localPlayer.vehicle.position = positions.finish_veh_parking.pos
						localPlayer.vehicle.rotation = positions.finish_veh_parking.rot

						local fade_time = 1
						fadeCamera( false, fade_time )
						CEs.dialog_tmr = setTimer( CEs.func_start_move_cutscene, fade_time * 1000, 1 )
					end, _, 1.8, _, _, function( self, player )
						if localPlayer.vehicle ~= GEs.temp_vehicle then
							return false, "А где машина Романа?"
						elseif GEs.roman_bot.vehicle ~= GEs.temp_vehicle then
							return false, "А где Роман?"
						end
						return true
					end )

				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function( data, failed )
					ClearAIPed( localPlayer )
					FinishQuestCutscene()
				end,
			},

			event_end_name = "possible_exposure_step_11",
		},
	},

	GiveReward = function( player )
		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, 
		{
			rewards = { money = QUEST_DATA.rewards.money, exp = QUEST_DATA.rewards.exp }
		} )

		player:SituationalPhoneNotification(
			{ title = "Неизвестный номер", msg = "Они всё знают" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "bloody_forest" then
						return "cancel"
					end
					
					local result = getRealTime( ).timestamp - self.ts >= 60
					if result then
						player:SituationalPhoneNotification(
							{ title = "Роман", msg = "Привет. Это Роман, есть работенка для тебя." },
							{
								condition = function( self, player, data, config )
									local current_quest = player:getData( "current_quest" )
									if current_quest and current_quest.id == "bloody_forest" then
										return "cancel"
									end
									return getRealTime( ).timestamp - self.ts >= 60
								end,
								save_offline = true,
							}
						)
					end

					return result
				end,
				save_offline = true,
			}
		)
	end,

	rewards = {
		money = 10000,
		exp = 15000,
	},

	no_show_rewards = true,
}