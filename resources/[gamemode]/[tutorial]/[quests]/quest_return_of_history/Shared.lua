QUEST_CONF = {
	dialogs = {
		start = {
			{ name = "Роман", voice_line = "Roman_return_of_history_monolog_1", text = [[Ну привет, Александр сейчас залег на дно, 
прошлое дело с бандитами, его потрепало...]] },
			{ name = "Роман", text = [[И все же он просил передать тебе информацию, о каком-то твоем, случае.
Хотя постой, бесплатно я информацию не передаю. Услуга за услугу, сам понимаешь.
Давай-ка прокатимся.]]},
		},
		office = {
			{ name = "Роман", voice_line = "Roman_return_of_history_monolog_2", text = [[Как тебе новые места? Впервые такие видишь? 
Ладно, давай ближе к делу. Я передам тебе документы, 
их нужно доставить в Западный картель и договориться с бандитами.]] },
			{ name = "Роман", text = [[По слухам ты умеешь находить с ними общий язык.
Вот и покажешь свою ценность.]]},
		},
		finish = {
			{ name = "Охранник", voice_line = "Guard_return_of_history_monolog_1", text = [[Эй, епт, ты куда?! Подохнуть хочешь!?
Аааа, бродяга. У тебя знакомый кейс. Ну давай посмотрим...
Расклад такой, беги отсюда, пока жив! Мы с такими как ты не работаем...]] },
		},
	},

	positions = {
		roman_spawn 	= { pos = { x = 565.74,   y = -519.72, z = 21.75 }, rot = { x = 0, y = 0, z = 0 } },
		roman_veh_spawn = { pos = { x = 554.01,   y = -518.82, z = 19.93 }, rot = { x = 0, y = 0, z = 5 } },

		-- Рублево: Выезд
		path_to_start_veh = {
			{ x = 554.97668457031, y = -515.32891845703, z = 20.933687210083 },
			{ x = 551.94665527344, y = -515.57781982422, z = 20.933687210083 },
			{ x = 552.42565917969, y = -518.90478515625, z = 20.933687210083 },
		},
		path_to_rublevo = {
			{ x = 552.93640136719, y = -507.10726928711, z = 20.318374633789, speed_limit = 10 },
			{ x = 540.98535156251, y = -502.49835205078, z = 20.318756103516, speed_limit = 10 },
			{ x = 489.89120483398, y = -502.74511718751, z = 20.317358016968, speed_limit = 10 },
		},
		matrix_rublevo = { 567.57843017578, -502.84701538086, 25.908462524414, 471.14215087891, -523.96105957031, 9.9634828567505, 0, 70 },


		-- Москва: Въезд в город
		moscow_enter_veh_spawn_iter_1 = { pos = Vector3( -387.5625, 1643.0935058594, 18.018350601196 ), rot = Vector3( 0, 0, 16 ), },
		moscow_enter_veh_path_iter_1 = {
			{ x = -410.353, y = 1707.612, z = 17.479, speed_limit = 35, distance = 10 },
			{ x = -491.677, y = 1891.543, z = 17.484, speed_limit = 35, distance = 10 },
			{ x = -542.473, y = 2004.765, z = 15.820, speed_limit = 35, distance = 10 },
			{ x = -575.176, y = 2036.497, z = 14.813, speed_limit = 35, distance = 10 },
			{ x = -609.797, y = 2063.774, z = 14.915, speed_limit = 35, distance = 10 },
			{ x = -624.662, y = 2094.624, z = 15.258, speed_limit = 35, distance = 10 },
		},

		moscow_enter_camera_path_iter_1 = {
			{ m = { -379.20965576171, 1666.0465087891, 24.605060577393, -465.95571899414, 1647.2569580078, -21.460922241211, 0, 70 }, duration = 2300 },
			{ m = { -467.81243896484, 1880.5900878906, 24.242265701294, -567.70471191406, 1883.8985595703, 21.9875488281251, 0, 70 }, duration = 10000 },
		},

		moscow_enter_veh_spawn_iter_2 = { pos = Vector3( -549.9935, 2022.5543, 15.7578 ), rot = Vector3( 358.5460, 0.9944, 42.3870 ) },
		moscow_enter_veh_path_iter_2 = {
			{ x = -565.0936, y = 2035.9257, z = 15.3078, speed_limit = 24 , distance = 10 },
			{ x = -601.4210, y = 2060.8085, z = 15.2424, speed_limit = 24 , distance = 10 },
			{ x = -618.0317, y = 2087.2192, z = 15.5584, speed_limit = 24 , distance = 10 },
			{ x = -623.1879, y = 2111.0644, z = 15.6701, speed_limit = 24 , distance = 10 },
			{ x = -595.9630, y = 2166.7482, z = 15.6660, speed_limit = 24 , distance = 10 },
		},

		moscow_enter_camera_path_iter_2 = {
			{ m = { -551.82501220703, 2030.8671875111, 15.822140693665, -644.48852539063, 2067.8686523438, 9.1607551574707, 0, 70 }, duration = 2500 },
			{ m = { -576.46752929688, 2049.8376464844, 15.109772682191, -670.44647216797, 2083.9829101563, 13.678499221802, 0, 70 }, duration = 1500 },
			{ m = { -601.03167724609, 2067.5031738281, 15.107598304749, -679.62615966797, 2129.2714843751, 17.863927841187, 0, 70 }, duration = 2000 },
			{ m = { -613.15350341797, 2094.1179199219, 15.965225219727, -691.94598388672, 2155.5981445313, 19.419216156006, 0, 70 }, duration = 2000 },
			{ m = { -618.71807861328, 2115.0146484375, 17.889266967773, -701.93115234375, 2167.3464355469, 36.246250152588, 0, 70 }, duration = 3500 },
		},


		-- Москва: Въезд в Кремль
		kremlin_enter_veh_spawn_iter_1 = { pos = Vector3( -473.20989990234, 2021.3946533203, 14.787704467773 ), rot = Vector3( 0, 0, 285 ) },
		kremlin_enter_veh_path_iter_1 = {
			{ x = -472.81890869141, y = 2023.4693603516, z = 14.816773414612, speed_limit = 20, distance = 1 },
			{ x = -433.16314697266, y = 2015.8970947266, z = 18.974119186401, speed_limit = 20, distance = 1 },
			{ x = -410.52618408203, y = 2012.9962158203, z = 20.950649261475, speed_limit = 20, distance = 1 },
			{ x = -379.94616699219, y = 2018.9473876953, z = 21.021284103394, speed_limit = 20, distance = 1 },
			{ x = -363.88653564453, y = 2020.5002441406, z = 21.025911331177, speed_limit = 20, distance = 1 },
		},

		kremlin_enter_camera_path_iter_1 = {
			{ m = { -473.11239624023, 2022.6290283203, 19.343536376953, -375.5119934082, 2003.3991699219, 9.1269779205322, 0, 70 }, duration = 2100 },
			{ m = { -439.51898193359, 2013.2490234375, 20.607976913452, -339.61245727539, 2013.6882324219, 16.307888031006, 0, 70 }, duration = 3600 },
			{ m = { -430.10800170898, 2010.1431884766, 23.028961181641, -338.48104858398, 2023.7557373047, 60.701236724854, 0, 70 }, duration = 3300 }
		},


		-- Москва: Кремль
		kremlin_veh_spawn_iter_1 = { pos = Vector3( -373.9294, 2019.7572, 21.0242 ), rot = Vector3( 0, 0, 276 ) },
		kremlin_veh_path_iter_1 = {
			{ x = -265.95147705078, y = 2044.9223632813, z = 21.024309158325, speed_limit = 30, distance = 1 },
			{ x = -13.724502563477, y = 2079.8664550781, z = 21.019071578979, speed_limit = 40, distance = 1 },
		},

		kremlin_camera_path_iter_1 = {
			{ m = { -392.37094116211, 2016.6557617188, 25.730445861816, -293.06414794922, 2027.0740966797, 20.287755966187, 0, 70 }, duration = 1000 },
			{ m = { -270.14569091797, 2037.0676269531, 26.674879074097, -195.65417480469, 2103.7062988281, 29.8825244903561, 0, 70 }, duration = 8000 },
		},
			
		kremlin_veh_spawn_iter_2 = { pos = Vector3( -15.000208854675, 2072.8852539063, 21.404237747192 ), rot = Vector3( 0, 0, 328.94943237305 ) },
		kremlin_veh_path_iter_2 = {
			{ x = 42.7924423217771, y = 2173.3662109375, z = 21.022201538086, speed_limit = 32, distance = 1 },
			{ x = 225.550018310551, y = 2311.2463378906, z = 21.025192260742, speed_limit = 32, distance = 1 },
			{ x = 217.850189208981, y = 2345.3703613281, z = 21.026243209839, speed_limit = 32, distance = 1 },
		},

		kremlin_camera_path_iter_2 = {
			{ m = { -20.586277008057, 2069.8181152344, 29.851819992065, 30.7934875488281, 2147.1879882813, -7.2159147262573, 0, 70 }, duration = 2000 },
			{ m = { 38.948684692383, 2168.8959960938, 28.005220413208, 85.594573974609, 2250.9116210938, -3.1968364715576, 0, 70 }, duration = 5000 },
			{ m = { 106.81216430664, 2281.833984375, 25.90029335022, 148.06195068359, 2369.1455078125, 1.3844835758209, 0, 70 }, duration = 5000 },
			{ m = { 126.383666992191, 2314.4047851563, 25.293243408203, 166.854904174811, 2402.7214355469, 1.58132302761081, 0, 70 }, duration = 2700 },
		},


		-- Москва: Выезд из Кремля
		kremlin_out_veh_spawn_iter_1 = { pos = Vector3( 47.743019104004, 2597.6362304688, 21.287427139282 ), rot = Vector3( 0, 0, 309 ) },
		kremlin_out_veh_path_iter_1 = {
			{ x = 61.674549102783, y = 2610.7604980469, z = 21.223887634277, speed_limit = 15, distance = 1 },
			{ x = 120.59078979492, y = 2603.7412109375, z = 21.224032592773, speed_limit = 15, distance = 1 },
			{ x = 145.92550659181, y = 2573.1503906252, z = 21.224875640869, speed_limit = 15, distance = 1 },
		},

		kremlin_out_camera_path_iter_1 = {
			{ m = { 46.738864898682, 2596.6240234375, 25.121341705322, 127.71729278564, 2650.2587890625, 1.3348031044006, 0, 70 },  duration = 2000 },
			{ m = { 60.084434509277, 2608.8327636719, 25.772577285767, 49.421070098877, 2705.259765625, 50.024040222168, 0, 70 },  duration = 5000 },
		},
		
		kremlin_out_veh_spawn_iter_2 = { pos = Vector3( 156.7735748291, 2542.0510253906, 21.088850021362 ), rot = Vector3( 0.6116943359375, 359.99829101563, 218.37010192871 ) },
		kremlin_out_veh_path_iter_2 = {
			{ x = 220.57069396973, y = 2465.8662109375, z = 21.024415969849, speed_limit = 25, distance = 1 },
			{ x = 262.50344848633, y = 2413.3776855469, z = 21.022853851318, speed_limit = 25, distance = 1 },
		},

		kremlin_out_camera_path_iter_2 = {
			{ m = { 164.12399291992, 2550.3706054688, 25.682786941528, 162.98207092285, 2450.3818359375, 24.701503753662, 0, 70 }, duration = 2000 },
			{ m = { 195.27867126465, 2515.5166015625, 26.549268722534, 119.34077453613, 2450.5419921875, 23.125566482544, 0, 70 }, duration = 5000 },
		},

		kremlin_out_veh_spawn_iter_3 = { pos = Vector3( 266.37222290039, 2407.9963378906, 21.090963363647 ), rot = Vector3( 0.74203491210938, 359.9811706543, 192.59005737305 ) },
		kremlin_out_veh_path_iter_3 = {
			{ x = 289.66714477539, y = 2302.8295898438, z = 18.409070968628, speed_limit = 25, distance = 1 },
			{ x = 305.45858764648, y = 2226.0310058594, z = 16.212070465088, speed_limit = 25, distance = 1 },
		},

		kremlin_out_camera_path_iter_3 = {
			{ m = { 273.44967651367, 2406.4858398438, 24.899709701538, 316.82708740234, 2321.1997070313, 25.298316955566, 0, 70 }, duration = 1000 },
			{ m = { 277.64849853516, 2341.0366210938, 49.986541748047, 365.78689575195, 2294.8288574219, 69.808116912842, 0, 70 }, duration = 5000 },
		},


		-- Москва: Набережная
		embankment_veh_spawn_iter_1 = { pos = Vector3( 398.60174560547, 1956.9744873047, 8.3002347946167 ), rot = Vector3( 0, 0, 270 ) },
		embankment_veh_path_iter_1 = {
			{ x = 535.93609619141, y = 1950.4416503906, z = 7.9193453788757, speed_limit = 45, distance = 1 },
			{ x = 685.83538818359, y = 1907.4605712891, z = 7.9193415641785, speed_limit = 45, distance = 1 },
			{ x = 763.02838134766, y = 1877.8892822266, z = 7.9191341400146, speed_limit = 43, distance = 1 },
			{ x = 860.60473632813, y = 1831.4055175781, z = 7.9160122871399, speed_limit = 43, distance = 1 },
		},

		embankment_camera_path_iter_1 = {
			{ m = { 401.88302612305, 1962.4215087891, 11.747743606567, 498.43222045898, 1957.5102539063, -13.828300476074, 0, 70 }, duration = 1000 },
			{ m = { 523.71777343751, 1957.4044189453, 11.121502876282, 621.06774902344, 1941.7924804688, -5.5891523361206, 0, 70 }, duration = 4000 },
			{ m = { 644.82446289063, 1926.2198486328, 10.531196594238, 740.70129394531, 1897.8026123047, 10.8427743911741, 0, 70 }, duration = 4000 },
			{ m = { 719.30444335938, 1901.6801757813, 11.447566986084, 818.94653320313, 1893.8176269531, 14.5506467819212, 0, 70 }, duration = 2200 },
			{ m = { 788.69470214844, 1908.2231445313, 14.753730773926, 879.59729003906, 1910.9062512311, 56.3411903381355, 0, 70 }, duration = 3000 },
		},


		-- Москва: Арбат
		arbat_veh_spawn_iter_1 = { pos = Vector3( 655.09088134766, 2285.3996582031, 15.144400596619 ), rot = Vector3( 359.70074462891, 359.73370361328, 274.07995605469 ) },
		arbat_veh_path_iter_1 = {
			{ x = 793.17962646484, y = 2291.6286621094, z = 13.054629325867, speed_limit = 60, distance = 1 },
			{ x = 1087.0202636719, y = 2313.2536621094, z = 11.354766845703, speed_limit = 60, distance = 1 },
			{ x = 1290.4826660156, y = 2319.5263671875, z = 9.4932699203491, speed_limit = 60, distance = 1 },
			{ x = 1438.9619140625, y = 2322.6486816406, z = 9.3393287658691, speed_limit = 60, distance = 1 },
			{ x = 1534.0679931641, y = 2345.9729003906, z = 9.1953077316284, speed_limit = 60, distance = 1 },
		},

		arbat_camera_path_iter_1 = {
			{ m = { 633.47961425781, 2283.7145996094, 28.837491989136, 849.02551269531, 2303.1179199219, 18.12417459487921, 0, 70 }, duration = 2500 },
			{ m = { 1098.1844482422, 2316.8884277344, 28.837491989136, 1198.0557861328, 2321.0766601563, 18.47120380401611, 0, 70 }, duration = 14000 },
			{ m = { 1436.7341308594, 2325.9304199219, 28.837491989136, 1535.9385986328, 2337.4099121094, 18.00390243530311, 0, 70 }, duration = 9000 },
		},


		-- Москва: Подъезд к офису
		moscow_city_veh_spawn_iter_1 = { pos = Vector3( 1946.0352783203, 2449.9887695313, 11.340530014038 ), rot = Vector3( 357.32073974609, 0.9295654296875, 282.21392822266 ) },
		moscow_city_veh_path_iter_1 = {
			{ x = 2011.3612060547, y = 2464.3305664063, z = 7.4916400909424, speed_limit = 20, distance = 1 },
			{ x = 2032.2100830078, y = 2469.1403808594, z = 7.4949374198914, speed_limit = 15, distance = 1 },
			{ x = 2028.0817871094, y = 2507.7712402344, z = 7.4949059486389, speed_limit = 20, distance = 1 },
			{ x = 2036.6193847656, y = 2513.9736328125, z = 7.4841566085815, speed_limit = 20, distance = 1 },
			{ x = 2073.8586425781, y = 2522.3039550781, z = 7.4962902069092, speed_limit = 20, distance = 1 },
			{ x = 2170.9372558594, y = 2543.9062511111, z = 7.4973578453064, speed_limit = 20, distance = 1 },
			{ x = 2174.4409179688, y = 2544.8957519531, z = 7.4954762458801, speed_limit = 20, distance = 1 },
			{ x = 2176.4753417969, y = 2565.3183593751, z = 7.4955306053162, speed_limit = 20, distance = 1 },
			{ x = 2185.7788085938, y = 2589.1557617188, z = 7.4955911636353, speed_limit = 20, distance = 1 },
			{ x = 2192.9916992188, y = 2598.5251464844, z = 7.4967384338379, speed_limit = 20, distance = 1 },
			{ x = 2192.9577636719, y = 2610.2250976563, z = 7.4947295188904, speed_limit = 20, distance = 1 },
			{ x = 2175.8500976563, y = 2625.4426269531, z = 7.4921431541443, speed_limit = 20, distance = 1 },
			{ x = 2175.7580566406, y = 2637.0180664063, z = 7.4967145919811, speed_limit = 20, distance = 1 },
		},

		moscow_city_camera_path_iter_1 = {
			{ m = { 1944.0362548828, 2449.3798828125, 14.355025291443, 2041.0761718750, 2464.6147460938, -4.3840484619141, 0, 70 }, duration = 2000 },
			{ m = { 2006.3128662109, 2462.2094726563, 10.304183006287, 2103.8859863281, 2483.8796386719, 7.15918636322020, 0, 70 }, duration = 4000 },
			{ m = { 2030.6804199219, 2470.3061523438, 10.598737716675, 2028.4077148438, 2569.9291992188, 2.22802901268010, 0, 70 }, duration = 2500 },
		},

		moscow_city_camera_path_iter_2 = {
			{ m = { 2012.974609375, 2509.9440917969, 18.607999801636, 2109.2919921875, 2531.8229980469, 2.9781682491302, 0, 70 }, duration = 1000 },
		},

		moscow_city_camera_path_iter_3 = {
			{ m = { 2202.92578125, 2575.0581054688, 41.282238006592, 2125.0615234375, 2549.02734375, -15.810437202454, 0, 70 }, duration = 1000 },
		},

		-- Мелкая поебень..
		west_gates = { pos = Vector3( -1942.0588134766, 663.52799072266, 18.485349655151 ), rot = Vector3( 0, 0, 10 ) },
		office_out_position   = { pos = Vector3( 2136.45, 2601.18, 8.31 ), rot = Vector3( 0, 0, 315 ), cz = 60 },
		office_inner_position = { pos = Vector3( -103.402, -2463.578, 4406.249 ), rot = Vector3( 0, 0, 177 ), cz = 178 },

		roman_office_position = { pos = Vector3( -92.8670, -2478.1679, 4406.2646 ), rot = Vector3( 0, 0, 88 ) },
		roman_dialog_position = { pos = Vector3( -93.5658, -2478.1679, 4406.2646 ), rot = Vector3( 0, 0, 269 ) },
		roman_dialog_matrix =   { -94.321655273438, -2477.5744628906, 4407.2465820313, -2.6594526767731, -2511.3012695313, 4385.7861328125, 0, 70 },

		office_veh_spawn    = { pos = Vector3( 2161.24, 2650.83, 6.87 ), rot = Vector3( 0, 0, 0 ) },

		-- Западный картель
		western_cartel_position = { pos = Vector3( -1935.4866, 656.4975, 18.0015 ), rot = Vector3( 0, 0, 0 ) },

		bandit_spawn = { pos = Vector3( -1942.9030, 680.8471, 18.3314 ), rot = 280 },
		bandit_dialog_position = { pos = Vector3( -1942.3248, 681.0596, 18.3151 ), rot = Vector3( 0, 0, 97 ) },
		bandit_dialog_matrix =  { -1941.4010, 681.0048, 19.2556, -2038.4276, 678.2645, -4.1929, 0, 70 },

		finish_mission_point = { pos = Vector3( -1941.4724, 683.2324, 18.4226 ) },
	},
}

GEs = { }

QUEST_DATA = {
	id = "return_of_history",
	is_company_quest = true,

	title = "Возвращение истории",
	description = "Нужно выяснить, что предпринял Александр и что делать дальше. Все равно кроме него навряд ли мне кто-то поможет... ",

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 556.4246, -496.3263, 20.9102 ),

	quests_request = { "angela_dance_school" },
	level_request = 4,

	OnAnyFinish = {
		server = function( player )
			DestroyAllTemporaryVehicles( player )

			if player.dimension == player:GetUniqueDimension() then
				if player.interior ~= 0 then
					player.interior = 0
					player.position = QUEST_CONF.positions.office_out_position.pos
					player.rotation = QUEST_CONF.positions.office_out_position.rot
				end
				ExitLocalDimension( player )
			end

			player:InventoryRemoveItem( IN_QUEST_CASE )
		end,
		client = function()
			WatchToLocalPlayerVehicle( false )
			ShowNPCs( )
		end
	},

	tasks = {

		{
			name = "Встретиться с помощником",

			Setup = {
				client = function( )
					CreateMarkerToCutsceneNPC( {
						id = "roman_near_house",
						dialog = QUEST_CONF.dialogs.start,
						callback = function( )
							CEs.marker.destroy( )
							EnterLocalDimension( )
							CEs.dialog:next( )
							StartPedTalk( FindQuestNPC( "roman_near_house" ).ped, nil, true )

							local t = {}

							t.NextDialog = function()
								CEs.dialog:next( )
								setTimerDialog( t.EndDialog, 14300 )
							end

							t.EndDialog = function()
								triggerServerEvent( "return_of_history_step_1", localPlayer )
							end

							setTimerDialog( t.NextDialog, 5800 )
						end
					} )
				end,
				server = function( player )
					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, 6539, positions.roman_veh_spawn.pos, positions.roman_veh_spawn.rot )
					vehicle:SetNumberPlate( "1:м421кр178" )
					vehicle:SetColor( 0, 0, 0 )
					setElementSyncer( vehicle, false )
					
					player:SetPrivateData( "temp_vehicle", vehicle )
				end,
			},

			CleanUp = {
				client = function( data, failed )
					StopPedTalk( FindQuestNPC( "roman_near_house" ).ped )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "return_of_history_step_1",
		},

		{
			name = "Садись в машину",

			Setup = {
				client = function( )
					HideNPCs( )

					local positions = QUEST_CONF.positions
					CreateGates( positions )
					
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=G чтобы сесть на пассажирское место",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					table.insert( GEs, WatchElementCondition( temp_vehicle, {
						condition = function( self, conf )
							if self.element.health <= 370 or self.element.inWater then
								FailCurrentQuest( "Машина Романа уничтожена!", "fail_destroy_vehicle" )
								return true
							elseif self.element:GetFuel() <= 0 then
								FailCurrentQuest( "Кончилось топливо!" )
								return true
							end
						end,
					} ) )

					local handlers = {}
					local function CheckBothInVehicle( )
						if localPlayer.vehicle and GEs.bot.vehicle then
							removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, handlers.OnStartEnter )
							removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, handlers.OnEnter )
							triggerServerEvent( "return_of_history_step_2", localPlayer )
						end
					end

					handlers.OnStartEnter = function( player, seat )
						if player ~= localPlayer then return end
						if seat == 0 then
							cancelEvent( )
							localPlayer:ShowError( "Роман сам тебя отвезёт" )
						end
					end
					addEventHandler( "onClientVehicleStartEnter", temp_vehicle, handlers.OnStartEnter )

					handlers.OnEnter = function( vehicle, seat )
						if vehicle ~= temp_vehicle then return end
						CEs.hint:destroy()
						CheckBothInVehicle( )
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, handlers.OnEnter )

					GEs.bot = CreateAIPed( FindQuestNPC( "roman_near_house" ).model, Vector3( positions.roman_spawn.pos.x, positions.roman_spawn.pos.y, positions.roman_spawn.pos.z ) )
					LocalizeQuestElement( GEs.bot )
					SetUndamagable( GEs.bot, true )
					
					SetAIPedMoveByRoute( GEs.bot, positions.path_to_start_veh, false, function( )
						AddAIPedPatternInQueue( GEs.bot, AI_PED_PATTERN_VEHICLE_ENTER, {
							vehicle = temp_vehicle;
							seat = 0;
							end_callback = {
								func = CheckBothInVehicle,
								args = { },
							}
						} )
					end )

				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					vehicle.frozen = true
				end,
			},

			CleanUp = {
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					if isElement( vehicle ) then
						vehicle.frozen = false
					end
				end
			},

			event_end_name = "return_of_history_step_2",
		},

		{
			name = "Отправление в Moscow City",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					setCameraMatrix( unpack( positions.matrix_rublevo ) )
					StartQuestCutscene( )

					SetAIPedMoveByRoute( GEs.bot, positions.path_to_rublevo, false )
					
					local t ={}
					t.FadeCamera = function( )
						fadeCamera( false, 1.5 )
						CEs.timer = setTimer( triggerServerEvent, 1550, 1, "return_of_history_step_3", localPlayer )
					end
					CEs.timer = setTimer( t.FadeCamera, 2000, 1 )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function( data, failed )
					CleanupAIPedPatternQueue( GEs.bot )
					removePedTask( GEs.bot )
					setElementVelocity( GEs.bot.vehicle, 0, 0, 0 )

					if failed then FinishQuestCutscene() end
				end,
			},

			event_end_name = "return_of_history_step_3",
		},

		{
			name = "Прибытие в Moscow City",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					GEs.bot.vehicle.position = positions.moscow_enter_veh_spawn_iter_1.pos
					GEs.bot.vehicle.rotation = positions.moscow_enter_veh_spawn_iter_1.rot
					SetAIPedMoveByRoute( GEs.bot, positions.moscow_enter_veh_path_iter_1, false )

					fadeCamera( false, 0 )
					StartQuestCutscene( { ignore_fade_blink = true } )
					setCameraMatrix( unpack( positions.moscow_enter_camera_path_iter_1[ 1 ].m ) )

					local t = {}
					t.EnterMoscowIter1 = function( )
						CEs.camera_move = CameraFromTo( _, positions.moscow_enter_camera_path_iter_1[ 2 ].m, 12000, "Linear" )
						CEs.timer = setTimer( t.FadeCameraIter1, 10500, 1 )
					end

					t.FadeCameraIter1 = function()
						fadeCamera( false, 1.5 )

						CleanupAIPedPatternQueue( GEs.bot )
						removePedTask( GEs.bot )
						setElementVelocity( GEs.bot.vehicle, 0, 0, 0 )

						GEs.bot.vehicle.position = positions.moscow_enter_veh_spawn_iter_2.pos
						GEs.bot.vehicle.rotation = positions.moscow_enter_veh_spawn_iter_2.rot
						SetAIPedMoveByRoute( GEs.bot, positions.moscow_enter_veh_path_iter_2, false )

						CEs.timer = setTimer( t.EndInter1, 1550, 1 )
					end

					t.EndInter1 = function()
						setCameraMatrix( unpack( positions.moscow_enter_camera_path_iter_2[ 1 ].m ) )
							
						fadeCamera( true, 1.5 )
						t.EnterMoscowIter2_1()
					end

					t.EnterMoscowIter2_1 = function()
						CEs.camera_move = CameraFromTo( _, positions.moscow_enter_camera_path_iter_2[ 2 ].m, 2500, "Linear" )
						CEs.timer = setTimer( t.EnterMoscowIter2_2, 2500, 1 )
					end

					t.EnterMoscowIter2_2 = function()
						CEs.camera_move = CameraFromTo( _, positions.moscow_enter_camera_path_iter_2[ 3 ].m, 2000, "Linear" )
						CEs.timer = setTimer( t.EnterMoscowIter2_3, 2000, 1 )
					end

					t.EnterMoscowIter2_3 = function()
						CEs.camera_move = CameraFromTo( _, positions.moscow_enter_camera_path_iter_2[ 4 ].m, 2000, "Linear" )
						CEs.timer = setTimer( t.EnterMoscowIter2_4, 2000, 1 )
					end

					t.EnterMoscowIter2_4 = function()
						CEs.camera_move = CameraFromTo( _, positions.moscow_enter_camera_path_iter_2[ 5 ].m, 3500, "Linear" )
						CEs.timer = setTimer( t.FadeCameraIter2, 2000, 1 )
					end

					t.FadeCameraIter2 = function()
						fadeCamera( false, 1.5 )
						CEs.timer = setTimer( t.EnterMoscowEnd, 1550, 1 )
					end

					t.EnterMoscowEnd = function()
						triggerServerEvent( "return_of_history_step_4", localPlayer )
					end
					
					CEs.timer = setTimer( function()
						GEs.background_sound = playSound( "files/sfx/background.ogg" )
						fadeCamera( true, 1.5 )
						t.EnterMoscowIter1()
					end, 200, 1 )
				end,
			},

			CleanUp = {
				client = function( data, failed )
					CleanupAIPedPatternQueue( GEs.bot )
					removePedTask( GEs.bot )
					setElementVelocity( GEs.bot.vehicle, 0, 0, 0 )

					if failed then FinishQuestCutscene() end
				end,
			},

			event_end_name = "return_of_history_step_4",
		},

		{
			name = "Въезд в Кремль",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					
					StartQuestCutscene( { ignore_fade_blink = true } )
					setCameraMatrix( unpack( positions.kremlin_enter_camera_path_iter_1[ 1 ].m ) )

					GEs.bot.vehicle.position = positions.kremlin_enter_veh_spawn_iter_1.pos
					GEs.bot.vehicle.rotation = positions.kremlin_enter_veh_spawn_iter_1.rot
						
					SetAIPedMoveByRoute( GEs.bot, positions.kremlin_enter_veh_path_iter_1, false )

					local t = {}
					t.PreStartEnterKremlin = function()
						fadeCamera( true, 1.5 )
						t.EnterKremlin1()
					end
					
					t.EnterKremlin1 = function( )
						CEs.camera_move = CameraFromTo( _, positions.kremlin_enter_camera_path_iter_1[ 2 ].m, 3600, "Linear" )
						CEs.timer = setTimer( t.EnterKremlin2, 3600, 1 )
					end

					t.EnterKremlin2 = function( )
						CEs.camera_move = CameraFromTo( _, positions.kremlin_enter_camera_path_iter_1[ 3 ].m, 3300, "Linear" )
						CEs.timer = setTimer( t.EnterKremlinFadeCamere, 3100, 1 )
					end

					t.EnterKremlinFadeCamere = function()
						fadeCamera( false, 0.5 )
						CEs.timer = setTimer( t.KremlinEnd, 500, 1 )
					end

					t.KremlinEnd = function()
						triggerServerEvent( "return_of_history_step_5", localPlayer )
					end

					CEs.timer = setTimer( t.PreStartEnterKremlin, 1000, 1 )
				end,
			},

			CleanUp = {
				client = function( data, failed )
					if failed then FinishQuestCutscene() end
				end,
			},

			event_end_name = "return_of_history_step_5",
		},

		{
			name = "Кремль...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					
					StartQuestCutscene( { ignore_fade_blink = true } )
					setCameraMatrix( unpack( positions.kremlin_camera_path_iter_1[ 1 ].m ) )

					GEs.bot.vehicle.position = positions.kremlin_veh_spawn_iter_1.pos
					GEs.bot.vehicle.rotation = positions.kremlin_veh_spawn_iter_1.rot
						
					SetAIPedMoveByRoute( GEs.bot, positions.kremlin_veh_path_iter_1, false )

					local t = {}
					t.Kremlin1PreStart = function()
						fadeCamera( true, 1.5 )
						t.Kremlin1()
					end
					
					t.Kremlin1 = function( )
						CEs.camera_move = CameraFromTo( _, positions.kremlin_camera_path_iter_1[ 2 ].m, 8000, "Linear" )
						CEs.timer = setTimer( t.Kremlin1End, 6500, 1 )
					end

					t.Kremlin1End = function()
						CEs.timer_start_vehicle = setTimer( function()
							CleanupAIPedPatternQueue( GEs.bot )
							removePedTask( GEs.bot )
							setElementVelocity( GEs.bot.vehicle, 0, 0, 0 )

							GEs.bot.vehicle.position = positions.kremlin_veh_spawn_iter_2.pos
							GEs.bot.vehicle.rotation = positions.kremlin_veh_spawn_iter_2.rot
							SetAIPedMoveByRoute( GEs.bot, positions.kremlin_veh_path_iter_2, false )
						end, 1000, 1 )

						fadeCamera( false, 1 )
						CEs.timer = setTimer( t.Kremlin2PreStart, 2500, 1 )
					end

					t.Kremlin2PreStart = function( )
						setCameraMatrix( unpack( positions.kremlin_camera_path_iter_2[ 1 ].m ) )

						fadeCamera( true, 1.5 )
						t.Kremlin2()
					end

					t.Kremlin2 = function()
						CEs.camera_move = CameraFromTo( _, positions.kremlin_camera_path_iter_2[ 2 ].m, 7000, "Linear" )
						CEs.timer = setTimer( t.Kremlin3, 7000, 1 )
					end

					t.Kremlin3 = function()
						CEs.camera_move = CameraFromTo( _, positions.kremlin_camera_path_iter_2[ 3 ].m, 6000, "Linear" )
						CEs.timer = setTimer( t.Kremlin4, 6000, 1 )
					end

					t.Kremlin4 = function()
						CEs.camera_move = CameraFromTo( _, positions.kremlin_camera_path_iter_2[ 4 ].m, 3000, "Linear" )
						CEs.timer = setTimer( t.KremlinEnd, 500, 1 )
					end

					t.KremlinEnd = function()
						fadeCamera( false, 1.5 )
						CEs.timer = setTimer( function()
							triggerServerEvent( "return_of_history_step_6", localPlayer )
						end, 1550, 1 )
					end

					t.Kremlin1PreStart()
				end,
			},

			CleanUp = {
				client = function( data, failed )
					if failed then FinishQuestCutscene() end
				end,
			},

			event_end_name = "return_of_history_step_6",
		},

		{
			name = "Выезд из Кремля...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					
					StartQuestCutscene( { ignore_fade_blink = true } )
					setCameraMatrix( unpack( positions.kremlin_out_camera_path_iter_1[ 1 ].m ) )

					CleanupAIPedPatternQueue( GEs.bot )
					removePedTask( GEs.bot )
					setElementVelocity( GEs.bot.vehicle, 0, 0, 0 )

					GEs.bot.vehicle.position = positions.kremlin_out_veh_spawn_iter_1.pos
					GEs.bot.vehicle.rotation = positions.kremlin_out_veh_spawn_iter_1.rot
					
					SetAIPedMoveByRoute( GEs.bot, positions.kremlin_out_veh_path_iter_1, false )

					local t = {}
					t.KremlinOut_1_PreStart = function()
						fadeCamera( true, 1.5 )
						t.KremlinOut_1()
					end
					
					t.KremlinOut_1 = function( )
						CEs.camera_move = CameraFromTo( _, positions.kremlin_out_camera_path_iter_1[ 2 ].m, 4500, "Linear" )
						CEs.timer = setTimer( function()
							CleanupAIPedPatternQueue( GEs.bot )
							removePedTask( GEs.bot )
							
							GEs.bot.vehicle.position = positions.kremlin_out_veh_spawn_iter_2.pos
							GEs.bot.vehicle.rotation = positions.kremlin_out_veh_spawn_iter_2.rot
					
							SetAIPedMoveByRoute( GEs.bot, positions.kremlin_out_veh_path_iter_2, false )

							fadeCamera( false, 1.5 )
							CEs.timer = setTimer( t.KremlinOut_2, 1550, 1 )
						end, 4000, 1 )
					end

					t.KremlinOut_2 = function( )
						fadeCamera( true, 1 )
						setCameraMatrix( unpack( positions.kremlin_out_camera_path_iter_2[ 1 ].m ) )
						CEs.camera_move = CameraFromTo( _, positions.kremlin_out_camera_path_iter_2[ 2 ].m, 5000, "Linear" )
						CEs.timer = setTimer( function()
							fadeCamera( false, 1 )
							CEs.timer = setTimer( t.KremlinOut_3, 1000, 1 )
						end, 4500, 1 )
					end

					t.KremlinOut_3 = function( )
						fadeCamera( true, 1 )
						setCameraMatrix( unpack( positions.kremlin_out_camera_path_iter_3[ 1 ].m ) )
						CEs.camera_move = CameraFromTo( _, positions.kremlin_out_camera_path_iter_3[ 2 ].m, 6500, "Linear" )
						CEs.timer = setTimer( t.KremlinOutEnd, 6500, 1 )
					end

					t.KremlinOutEnd = function()
						fadeCamera( false, 1.5 )
						CEs.timer = setTimer( function()
							triggerServerEvent( "return_of_history_step_7", localPlayer )
						end, 1550, 1 )
					end	

					t.KremlinOut_1_PreStart()
				end,
			},

			CleanUp = {
				client = function( data, failed )
					if failed then FinishQuestCutscene() end
				end,
			},

			event_end_name = "return_of_history_step_7",
		},

		{
			name = "Набережная...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					
					StartQuestCutscene( { ignore_fade_blink = true } )
					setCameraMatrix( unpack( positions.embankment_camera_path_iter_1[ 1 ].m ) )

					GEs.bot.vehicle.position = positions.embankment_veh_spawn_iter_1.pos
					GEs.bot.vehicle.rotation = positions.embankment_veh_spawn_iter_1.rot
					
					CleanupAIPedPatternQueue( GEs.bot )
					removePedTask( GEs.bot )
					setElementVelocity( GEs.bot.vehicle, 0, 0, 0 )

					SetAIPedMoveByRoute( GEs.bot, positions.embankment_veh_path_iter_1, false )

					local t = {}
					t.PreStartEmbankment = function()
						fadeCamera( true, 1.5 )
						t.Embankment1()
					end
					
					t.Embankment1 = function( )
						CEs.camera_move = CameraFromTo( _, positions.embankment_camera_path_iter_1[ 2 ].m, 5000, "Linear" )
						CEs.timer = setTimer( t.Embankment2, 5000, 1 )
					end

					t.Embankment2 = function( )
						CEs.camera_move = CameraFromTo( _, positions.embankment_camera_path_iter_1[ 3 ].m, 5000, "Linear" )
						CEs.timer = setTimer( t.Embankment3, 5000, 1 )
					end

					t.Embankment3 = function( )
						CEs.camera_move = CameraFromTo( _, positions.embankment_camera_path_iter_1[ 4 ].m, 3500, "Linear" )
						CEs.timer = setTimer( t.Embankment4, 3500, 1 )
					end

					t.Embankment4 = function( )
						CEs.camera_move = CameraFromTo( _, positions.embankment_camera_path_iter_1[ 5 ].m, 4000, "Linear" )
						CEs.timer = setTimer( t.EmbankmentFadeCamere, 4000, 1 )
					end

					t.EmbankmentFadeCamere = function()
						fadeCamera( false, 1.5 )
						CEs.timer = setTimer( t.EmbankmentEnd, 1550, 1 )
					end

					t.EmbankmentEnd = function()
						triggerServerEvent( "return_of_history_step_8", localPlayer )
					end

					CEs.timer = setTimer( t.PreStartEmbankment, 1000, 1 )
				end,
			},

			CleanUp = {
				client = function( data, failed )
					if failed then FinishQuestCutscene() end
				end,
			},

			event_end_name = "return_of_history_step_8",
		},

		{
			name = "Арбат...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					
					StartQuestCutscene( { ignore_fade_blink = true } )
					setCameraMatrix( unpack( positions.arbat_camera_path_iter_1[ 1 ].m ) )

					GEs.bot.vehicle.position = positions.arbat_veh_spawn_iter_1.pos
					GEs.bot.vehicle.rotation = positions.arbat_veh_spawn_iter_1.rot
					
					CleanupAIPedPatternQueue( GEs.bot )
					removePedTask( GEs.bot )
					setElementVelocity( GEs.bot.vehicle, 0, 0, 0 )

					SetAIPedMoveByRoute( GEs.bot, positions.arbat_veh_path_iter_1, false )

					local t = {}
					t.PreStartArbat = function()
						fadeCamera( true, 1.5 )
						t.Arbat1()
					end
					
					t.Arbat1 = function( )
						CEs.camera_move = CameraFromTo( _, positions.arbat_camera_path_iter_1[ 2 ].m, 13000, "Linear" )
						CEs.timer = setTimer( t.Arbat2, 13000, 1 )
					end

					t.Arbat2 = function( )
						CEs.camera_move = CameraFromTo( _, positions.arbat_camera_path_iter_1[ 3 ].m, 9000, "Linear" )
						CEs.timer = setTimer( t.ArbatFadeCamere, 6000, 1 )
					end

					t.ArbatFadeCamere = function()
						fadeCamera( false, 1.5 )
						CEs.timer = setTimer( t.ArbatEnd, 1550, 1 )
					end

					t.ArbatEnd = function()
						triggerServerEvent( "return_of_history_step_9", localPlayer )
					end

					t.PreStartArbat()
				end,
			},

			CleanUp = {
				client = function( data, failed )
					if failed then FinishQuestCutscene() end
				end,
			},

			event_end_name = "return_of_history_step_9",
		},
		
		{
			name = "Прибытие в офис...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					localPlayer.vehicle.position = positions.moscow_city_veh_spawn_iter_1.pos
					localPlayer.vehicle.rotation = positions.moscow_city_veh_spawn_iter_1.rot
					
					StartQuestCutscene( { ignore_fade_blink = true } )
					setCameraMatrix( unpack( positions.moscow_city_camera_path_iter_1[ 1 ].m ) )

					GEs.bot.vehicle.position = positions.moscow_city_veh_spawn_iter_1.pos
					GEs.bot.vehicle.rotation = positions.moscow_city_veh_spawn_iter_1.rot

					CleanupAIPedPatternQueue( GEs.bot )
					removePedTask( GEs.bot )
					setElementVelocity( GEs.bot.vehicle, 0, 0, 0 )

					SetAIPedMoveByRoute( GEs.bot, positions.moscow_city_veh_path_iter_1, false )

					local t = {}
					
					t.MoscowCity_1 = function()
						CEs.camera_move = CameraFromTo( _, positions.moscow_city_camera_path_iter_1[ 2 ].m, 4000, "Linear" )
						CEs.timer = setTimer( t.MoscowCity_2, 4010, 1 )
					end

					t.MoscowCity_2 = function()
						CEs.camera_move = CameraFromTo( _, positions.moscow_city_camera_path_iter_1[ 3 ].m, 4000, "Linear" )
						CEs.timer = setTimer( t.MoscowCity_3, 4010, 1 )
					end

					t.MoscowCity_3 = function()
						fadeCamera( false, 1 )
						CEs.timer = setTimer( function()
							setCameraMatrix( unpack( positions.moscow_city_camera_path_iter_2[ 1 ].m ) )
							fadeCamera( true, 1 )
							CEs.timer = setTimer( t.MoscowCity_4, 5000, 1 )
						end, 1000, 1 )
					end

					t.MoscowCity_4 = function()
						fadeCamera( false, 1 )
						CEs.timer = setTimer( function()
							setCameraMatrix( unpack( positions.moscow_city_camera_path_iter_3[ 1 ].m ) )
							fadeCamera( true, 1 )
							WatchToLocalPlayerVehicle( true )
							CEs.timer = setTimer( t.MoscowCityEnd, 15000, 1 )
						end, 1000, 1 )
					end

					t.MoscowCityEnd = function()
						WatchToLocalPlayerVehicle( false )
						CreateAIPed( localPlayer )
						for i, v in pairs( { localPlayer, GEs.bot } ) do
							AddAIPedPatternInQueue( v, AI_PED_PATTERN_VEHICLE_EXIT, { } )
						end
						
						fadeCamera( false, 1.5 )
						CEs.timer_delay = setTimer( function( )
							triggerServerEvent( "return_of_history_step_10", localPlayer )
						end, 1550, 1 )
					end

					fadeCamera( true, 1.5 )
					CEs.timer = setTimer( t.MoscowCity_1, 1500, 1 )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function( )
					WatchToLocalPlayerVehicle( false )
					FinishQuestCutscene()
				end,
			},

			event_end_name = "return_of_history_step_10",
		},

		{
			name = "Войдите в офис",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					SetAIPedMoveByRoute( GEs.bot, {
						{ x = positions.office_out_position.pos.x, y = positions.office_out_position.pos.y, z = positions.office_out_position.pos.z, distance = 1 },
					}, false, function()
						GEs.bot.position = positions.roman_office_position.pos
						GEs.bot.interior = 1
					end )

					CreateQuestPoint( positions.office_out_position.pos, function( self, player )
						CEs.marker.destroy( )
						fadeCamera( false, 1.5 )
						CEs.timer = setTimer( triggerServerEvent, 1550, 1, "return_of_history_step_11", localPlayer )
					end, _, 1, _, _,
					function( )
						if localPlayer.vehicle then
							return false, "Покинь транспортное средство"
						end
						return true
					end )			
				end,
				server = function( player )

				end,
			},

			event_end_name = "return_of_history_step_11",
		},

		{
			name = "Поговори с Романом",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					localPlayer.interior = 1
					localPlayer.position = positions.office_inner_position.pos
					localPlayer.rotation = positions.office_inner_position.rot
					setPedCameraRotation( localPlayer, positions.office_inner_position.cz )
					
					CleanupAIPedPatternQueue( GEs.bot )
					removePedTask( GEs.bot )

					GEs.bot.interior = 1
					GEs.bot.position = positions.roman_office_position.pos
					GEs.bot.rotation = positions.roman_office_position.rot

					CreateQuestPoint( positions.roman_office_position.pos, function( self, player )
						CEs.marker.destroy( )
						
						localPlayer.position = positions.roman_dialog_position.pos
						localPlayer.rotation = positions.roman_dialog_position.rot
						
						setCameraMatrix( unpack( positions.roman_dialog_matrix ) )
						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.office } )

						StartPedTalk( GEs.bot, nil, true )
						CEs.dialog:next( )

						local t = {}
						t.NextDialog = function()
							CEs.dialog:next( )
							setTimerDialog( t.EndDialog, 6000 )
						end

						t.EndDialog = function()
							StopPedTalk( GEs.bot )
							triggerServerEvent( "return_of_history_step_12", localPlayer )
						end
						setTimerDialog( t.NextDialog, 11000 )
					end, _, 1, 1 )
					
					fadeCamera( true, 1.5 )
				end,
				server = function( player )
					player.interior = 1
				end,
			},

			CleanUp = {
				client = function( )
					StopPedTalk( GEs.bot )
					FinishQuestCutscene()
				end,
			},

			event_end_name = "return_of_history_step_12",
		},

		{
			name = "Покинь офис",

			Setup = {
				client = function( )
					CreateQuestPoint( QUEST_CONF.positions.office_inner_position.pos, function( self, player )
						CEs.marker.destroy( )
						fadeCamera( false, 1.5 )
						CEs.timer = setTimer( triggerServerEvent, 1550, 1, "return_of_history_step_13", localPlayer )
					end, _, 1, 1 )	
				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					destroyElement( vehicle )

					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, 603, positions.office_veh_spawn.pos, positions.office_veh_spawn.rot )
					vehicle:SetNumberPlate( "1:o" .. math.random( 111, 999 ) .. "oo" .. math.random( 10, 99 ) )
					player:SetPrivateData( "temp_vehicle", vehicle )
					vehicle:SetColor( 0, 0, 0 )

					player:InventoryAddItem( IN_QUEST_CASE, nil, 1 )
				end,
			},

			event_end_name = "return_of_history_step_13",
		},

		{
			name = "Садись в автомобиль",

			Setup = {
				client = function( )
					GEs.bot:destroy()
					GEs.bot = nil
					
					local positions = QUEST_CONF.positions

					localPlayer.interior = 0
					localPlayer.position = positions.office_out_position.pos
					localPlayer.rotation = positions.office_out_position.rot
					setPedCameraRotation( localPlayer, positions.office_out_position.cz )

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F чтобы сесть на водительское место",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					CreateQuestPoint( positions.office_veh_spawn.pos, function( self, player )
						CEs.marker.destroy( )
					end )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					table.insert( GEs, WatchElementCondition( temp_vehicle, {
						condition = function( self, conf )
							if self.element.health <= 370 or self.element.inWater then
								FailCurrentQuest( "Машина Романа уничтожена!", "fail_destroy_vehicle" )
								return true
							elseif self.element:GetFuel() <= 0 then
								FailCurrentQuest( "Кончилось топливо!" )
								return true
							end
						end,
					} ) )

					local handlers = {}
					handlers.OnStartEnter = function( player, seat )
						if player ~= localPlayer then return end
						if seat ~= 0 then
							localPlayer:ShowError( "Садись на водительское место" )
							cancelEvent( )
						end
					end
					addEventHandler( "onClientVehicleStartEnter", temp_vehicle, handlers.OnStartEnter )

					handlers.OnEnter = function( vehicle, seat )
						if vehicle ~= temp_vehicle then return end
						CEs.hint:destroy()

						removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, handlers.OnStartEnter )
						removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, handlers.OnEnter )
						triggerServerEvent( "return_of_history_step_14", localPlayer )
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, handlers.OnEnter )

					fadeCamera( true, 1.5 )
				end,
				server = function( player )
					player.interior = 0
				end,
			},

			event_end_name = "return_of_history_step_14",
		},

		{
			name = "Отвези кейс",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					GEs.bot = CreateAIPed( 259, positions.bandit_spawn.pos, positions.bandit_spawn.rot )
					LocalizeQuestElement( GEs.bot )
					SetUndamagable( GEs.bot, true )

					CreateQuestPoint( positions.western_cartel_position.pos, function( self, player )
						CEs.marker.destroy( )
						
						local handlers = {}
						handlers.OnExit = function( player, seat )
							removeEventHandler( "onClientPlayerVehicleExit", localPlayer, handlers.OnExit )
							triggerServerEvent( "return_of_history_step_15", localPlayer )
						end

						if localPlayer.vehicle then
							localPlayer.vehicle.frozen = true
							localPlayer.vehicle.engineState = false
							localPlayer:ShowError( "Покиньте транспорт, чтобы продолжить" )
							addEventHandler( "onClientPlayerVehicleExit", localPlayer, handlers.OnExit )
						else
							handlers.OnExit()
						end
					end )
				end,
				server = function( player )

				end,
			},

			event_end_name = "return_of_history_step_15",
		},

		{
			name = "Поговори с охранником",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					CreateQuestPoint( positions.bandit_spawn.pos, function( self, player )
						CEs.marker.destroy( )

						localPlayer.position = positions.bandit_dialog_position.pos
						localPlayer.rotation = positions.bandit_dialog_position.rot

						setCameraMatrix( unpack( positions.bandit_dialog_matrix ) )
						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.finish } )
						CEs.dialog:next( )
						StartPedTalk( GEs.bot, nil, true )

						setTimerDialog( function() 
							fadeCamera( false, 1 ) 
							CEs.timer = setTimer( triggerServerEvent, 1000, 1, "return_of_history_step_16", localPlayer )
						end, 14000 )
					end, _, 1 )	
				end,
				server = function( player )
					player:InventoryRemoveItem( IN_QUEST_CASE )
				end,
			},

			CleanUp = {
				client = function( )
					StopPedTalk( GEs.bot )
					FinishQuestCutscene()
				end,
			},

			event_end_name = "return_of_history_step_16",
		},
	},

	GiveReward = function( player )
		player:SituationalPhoneNotification(
			{ title = "Незнакомый номер", msg = "Это Западный картель. До нас дошли слухи, что ты поднялся, мы готовы с тобой работать. Подъезжай!" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "protection" then
						return "cancel"
					end
					return getRealTime().timestamp - self.ts >= 60 and player:GetLevel() >= 10
				end,
				save_offline = true,
			}
		)

		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, 
		{
			rewards = { money = QUEST_DATA.rewards.money, exp = QUEST_DATA.rewards.exp, package = QUEST_DATA.rewards.package }
		} )

		player:GivePremiumExpirationTime( 1 )
		player:InventoryAddItem( IN_FIRSTAID, nil, 1 )
        player:InventoryAddItem( IN_REPAIRBOX, nil, 1 )
        player:InventoryAddItem( IN_JAILKEYS, nil, 3 )
        
		player:ShowInfo( "Вы получили пакет новичка 'Стартовый'" )
	end,

	rewards = {
		money = 500,
		exp = 1500,
		package = { id = "start", name = "Пакет новичка 'Стартовый'", desc = "Премиум х1\nАптечка х1\nРемкомплект х1\nКарточка освобождения х3" }
	},
	no_show_rewards = true,
}
