APARTMENTS_CLASSES = {
	[1] = {
		cost = 400000;
		cost_day = 1490;

		apartament_class = 1,

		discount_cost = 349000;

		count_vehicles = 1;
		count_skins = 4;

		upgrades = {
			{
				cost = 6000;
				profit = 90;
			};
			{
				cost = 8000;
				profit = 175;
			};
			{
				cost = 10000;
				profit = 235;
			};
		};

		interior = 1;
		exit_position = Vector3( 192.567, -414.860, 514.542 );
		control_position = Vector3( 196.890, -409.804, 514.542 );

		bed_position = { 
			{ x = 188.8, y = -410.9, z = 515.153, r = 0 },
			{ x = 188.8, y = -409.87, z = 515.153, r = 0 },
		 };
		
		wardrobe_position = Vector3( 188.924, -407.138, 514.542 );
		wardrobe_camera_position = Vector3( 192.310, -409.728, 514.542 );
		wardrobe_camera_target = Vector3( 188.924, -407.138, 514.542 );
		wardrobe_ped_position = Vector3( 188.924, -407.138, 514.542 );
		wardrobe_ped_rotation = 238;
		
		cooking_position = Vector3( 197.815, -407.698, 514.542 );

		inventory_max_weight = 75;
		inventory_position = { x = 192.234, y = -410.147, z = 514.542 };

		--card_game_position = Vector3( 192.354, -407.129, 514.542 );
	};

	[2] = {
		cost = 1500000;
		cost_day = 3490;

		apartament_class = 2,

		discount_cost = 1290000;

		count_vehicles = 2;
		count_skins = 6;

		upgrades = {
			{
				cost = 22500;
				profit = 345;
			};
			{
				cost = 30000;
				profit = 650;
			};
			{
				cost = 37500;
				profit = 880;
			};
		};

		interior = 1;
		exit_position = Vector3( 243.563, -348.405, 456.434  );
		control_position = Vector3( 245.989, -355.767, 456.427 );

		bed_position =  { 
			{ x = 243.539, y = -343.504, z = 456.785, r = 0 },
			{ x = 243.539, y = -344.304, z = 456.785, r = 0 },
		 };

		wardrobe_position = Vector3( 252.540, -349.104, 456.427 );
		wardrobe_camera_position = Vector3( 249.879, -347.115, 456.427 );
		wardrobe_camera_target = Vector3( 252.540, -349.104, 456.427 );
		wardrobe_ped_position = Vector3( 252.540, -349.104, 456.427 );
		wardrobe_ped_rotation = 54;
		
		cooking_position = Vector3( 254.616, -343.240, 456.427 );

		inventory_max_weight = 100;
		inventory_position = { x = 253.287, y = -353.831, z = 456.427 };

		-- card_game_position = Vector3( 248.298, -344.797, 456.426 );
	};

	[3] = {
		cost = 3000000;
		cost_day = 6990;

		apartament_class = 3,

		discount_cost = 2490000;

		count_vehicles = 3;
		count_skins = 8;

		upgrades = {
			{
				cost = 45000;
				profit = 700;
			};
			{
				cost = 60000;
				profit = 1300;
			};
			{
				cost = 75000;
				profit = 1750;
			};
		};

		interior = 1;
		exit_position = Vector3( 250.789, -459.086, 465.054  );
		control_position = Vector3( 244.271, -458.219, 465.047 );

		bed_position = { 
			--Левая сторона
			{ x = 254.5, y = -444.21, z = 469.31, r = 180 },
			--Правая сторона
			{ x = 254.5, y = -445.25, z = 469.31, r = 180 },
		};
		
		wardrobe_position = Vector3( 247.061, -446.238, 468.541 );
		wardrobe_camera_position = Vector3( 244.781, -443.122, 468.541 );
		wardrobe_camera_target = Vector3( 247.061, -446.238, 468.541 );
		wardrobe_ped_position = Vector3( 247.061, -446.238, 468.541 );
		wardrobe_ped_rotation = 37;
		
		cooking_position = Vector3( 255.392, -444.996, 465.047 );

		inventory_max_weight = 125;
		inventory_position = { x = 245.604, y = -450.341, z = 468.541 };

		-- card_game_position = Vector3( 246.465, -442.623, 465.046 );
	};

	[4] = {
		interior = 1;
		exit_position = Vector3( 219.492, -347.537, 472.437 );
		control_position = Vector3( 219.694, -349.740, 472.429 );

		bed_position = { 
			{ x = 226.57, y = -349.646, z = 476.390, r = 90 },
			{ x = 227.73, y = -349.646, z = 476.390, r = 90 },
		 };
		
		wardrobe_position = Vector3{ x = 219.835, y = -345.869, z = 475.984 };
		wardrobe_camera_position = Vector3{ x = 221.998, y = -342.729, z = 475.991 };
		wardrobe_camera_target = Vector3{ x = 219.835, y = -345.869, z = 475.984 };
		wardrobe_ped_position = Vector3{ x = 219.835, y = -345.869, z = 475.984 };
		wardrobe_ped_rotation = 327;
		
		cooking_position = Vector3{ x = 226.345, y = -342.142, z = 472.429 };

		inventory_position = { x = 224.299, y = -342.175, z = 475.987 };

		-- card_game_position = Vector3{ x = 225.6, y = -349.078, z = 472.429 };
	};

	[5] = {
		interior = 1;
		exit_position = Vector3( -109.587, -1778.673, 3936.981 );
		control_position = Vector3( -99.720, -1769.872, 3936.988);

		bed_position = { 
			{ x = -100.2, y = -1774.844, z = 3941.709, r = 90 },
			{ x = -101.37, y = -1774.844, z = 3941.709, r = 90 },
		};
		
		wardrobe_position = Vector3{ x = -99.279, y = -1769.928, z = 3940.966 };
		wardrobe_camera_position = Vector3{ x = -103.368, y = -1768.792, z = 3940.971 };
		wardrobe_camera_target = Vector3{ x = -99.279, y = -1769.928, z = 3940.966 };
		wardrobe_ped_position = Vector3{ x = -99.279, y = -1769.928, z = 3940.966 };
		wardrobe_ped_rotation = 70;
		
		cooking_position = Vector3{ x = -98.959, y = -1774.330, z = 3936.981 };

		inventory_position = { x = -105.944, y = -1783.695, z = 3940.958 };

		-- card_game_position = Vector3{ x = -107.372, y = -1771.788, z = 3936.989 };
	};

	[6] = {
		interior = 1;
		exit_position = Vector3( -103.191, -2465.599, 4823.998 );
		control_position = Vector3{ x = -106.6255, y = -2459.7019, z = 4823.998 };

		bed_position = { 
			{ x = -111.424, y = -2467.09, z = 4828.535, r = 0 },
			{ x = -111.424, y = -2468.2, z = 4828.535, r = 0 },
		};

		wardrobe_position = Vector3{ x = -106.126, y = -2468.979, z = 4827.834 };
		wardrobe_camera_position = Vector3{ x = -104.771, y = -2465.920, z = 4827.826 };
		wardrobe_camera_target = Vector3{ x = -106.126, y = -2468.979, z = 4827.834 };
		wardrobe_ped_position = Vector3{ x = -106.126, y = -2468.979, z = 4827.834 };
		wardrobe_ped_rotation = 335;
		
		cooking_position = Vector3{ x = -108.330, y = -2459.242, z = 4823.998 };

		inventory_position = { x = -114.168, y = -2458.205, z = 4823.998 };

        -- card_game_position = Vector3{ x = -106.148, y = -2465.145, z = 4823.998 };
	};

	[7] = {
		interior = 1;
		exit_position = Vector3( -1995.3326, -74.5052, 901.7713 );
		
		control_position = Vector3( -2000.6931, -73.5010, 901.6328 );

		bed_position = { { x = -1999.8020, y = -66.0006, z = 902.2731, r = 0 }, };

		inventory_position = { x = -1993.825, y = -66.193, z = 901.607 };

		--wardrobe_position        = Vector3{ x = -1994.6602,  y = -66.3066, z = 901.6072 };
		--wardrobe_camera_position = Vector3{ x = -1997.2666,  y = -68.5235, z = 903.0009 };
		--wardrobe_camera_target   = Vector3{ x = -1926.6589,  y = -7.5160,  z = 867.0476 };
		--wardrobe_ped_position    = Vector3{ x = -1994.6602,  y = -66.3066, z = 901.6072 };
		--wardrobe_ped_rotation    = 126;
		
		--cooking_position = Vector3{ x = -2002.8315, y = -66.0323, z = 901.6072 };
		--card_game_position = Vector3{ x = -2004.671, y = -72.983, z = 901.625 };
	};

	[8] = {
		cost = 25000000;
		cost_day = 62900;

		apartament_class = 8,

		discount_cost = 19900000;

		count_vehicles = 8;
		count_skins = 4;

		upgrades = {
			{
				cost = 375000;
				profit = 6290;
			};
			{
				cost = 500000;
				profit = 12580;
			};
			{
				cost = 625000;
				profit = 22010;
			};
		};

		interior = 10;
		exit_position = Vector3( 1402.1, -1905.28, 2299.35 );
		control_position = Vector3{ x = 1398.806, y = -1899.836, z = 2299.33 };

		bed_position = { 
			{ x = 1395.325, y = -1902.504, z = 2299.792, r = -90 },
			{ x = 1396.315, y = -1902.349, z = 2299.793, r = -90 },
		};

		wardrobe_position = Vector3{ x = 1392.63, y = -1904.31, z = 2299.34 };
		wardrobe_camera_position = Vector3{ x = 1395.324, y = -1903.646, z = 2299.616 };
		wardrobe_camera_target = Vector3{ x = 1295.638, y = -1899.505, z = 2292.870 };
		wardrobe_ped_position = Vector3{ x = 1391.792, y = -1903.672, z = 2299.336 };
		wardrobe_ped_rotation = 270;
		
		cooking_position = Vector3{ x = 1407.22, y = -1897.5, z = 2299.34 };

		inventory_position = { x = 1392.593, y = -1899.278, z = 2299.336 };
		inventory_max_weight = 400;
	};
}

APARTMENTS_COMPLEX_LIST = {
	[1] = Vector3( -1040.028, -1591.311, 20.984 );
	[2] = Vector3( -1193.999, -1749.236, 20.793 );
	[3] = Vector3( -1237.683, -1591.154, 21.004 );
	[4] = Vector3( -922.273, -1760.94, 20.992 );
	[5] = Vector3( 335.365, -2365.278, 20.745 );
	[6] = Vector3( 2082.726, -1267.327, 60.546 );
	[7] = Vector3( -11.038, -1843.904, 20.965 );
	[8] = Vector3( 1962.906, -1016.039, 60.548 );
	[9] = Vector3( -749.403, -1848.172, 20.996 );
	[10] = Vector3( 141.005, -2266.219, 20.716 );
	[11] = Vector3( 127.379, -1477.469, 20.847 );
	[12] = Vector3( 2183.186, -399.19, 60.738 );
	[13] = Vector3( 2381.445, -729.71, 60.815 );
	[14] = Vector3( 2005.288, 1183.267, 17.036 );
	[15] = Vector3( -362.182, 336.705, 39.064 );
	[16] = Vector3( -538.399, 356.982, 39.067 );
	[17] = Vector3( -374.946, 603.361, 38.493 );
	[18] = Vector3( -64.696, 606.072, 20.698 );
	[19] = Vector3( 865.07, 2224.16, 9.2 );
	[20] = Vector3( 1419.43, 2248.7, 9.27 );
	[21] = Vector3( 1750.0500488281, 2325.2800292969, 8.7728872299194 );
	[22] = Vector3( 1667.7513427734, 2459.0732421875, 9.8351516723633 );
	[23] = Vector3( 1652.5100097656, 2558.3100585938, 8.8772249221802 );
	[24] = Vector3( 1537.7700195313, 2613.6599121094, 11.24494934082 );
	[25] = Vector3( 1489.3922119141, 2570.3806152344, 11.245594024658 );
	[26] = Vector3( 1215.5200195313, 2611.2600097656, 11.24494934082 );
	[27] = Vector3( -816.78997802734, 2723.7800292969, 15.503887176514 );
	[28] = Vector3( -998.95367431641, 2633.7023925781, 15.523909568787 );
	[29] = Vector3( -1258.0953369141, 2856.9948730469, 16.335548400879 );
	[30] = Vector3( -1394.3900146484, 2710, 15.467325210571 );
	[31] = Vector3( 2069.146, 2561.146, 8.307 );
	[32] = Vector3( 2072.751, 2634.946, 8.310 );
	[33] = Vector3( 2397.686, 2552.344, 12.758 );
	[34] = Vector3( 2433.205, 2384.098, 38.888 );
	[35] = Vector3( 2130.908, 2359.378, 8.073 );
	[36] = Vector3( 2181.05, 2292.42, 7.08 );
}

APARTMENTS_LIST = {
	[1] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -1035.579, -1634.213 + 860, 21.769 );
		parking_position = Vector3( -1037.96, -1631.055 + 860, 20.938 );
		vehicle_position = Vector3( -1036.745, -1625.106 + 860, 20.773 );

		vehicle_rotation = Vector3( 0, 0, 0 );
	};
	[2] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -1062.793, -1611.18 + 860, 21.769 );
		parking_position = Vector3( -1059.693, -1613.467 + 860, 20.992 );
		vehicle_position = Vector3( -1053, -1612.234 + 860, 20.781 );

		vehicle_rotation = Vector3( 0, 0, 270 );
	};
	[3] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -1063.159, -1571.965 + 860, 21.769 );
		parking_position = Vector3( -1059.535, -1569.549 + 860, 20.992 );
		vehicle_position = Vector3( -1053, -1570.306 + 860, 20.781 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[4] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -1035.555, -1548.635 + 860, 21.769 );
		parking_position = Vector3( -1037.981, -1551.813 + 860, 20.934 );
		vehicle_position = Vector3( -1036.825, -1556.625 + 860, 20.781 );

		vehicle_rotation = Vector3( 0, 0, 90 );
	};
	[5] = {
		class = 1;
		max_count = 15;

		enter_position = Vector3( -1207.359, -1798.495 + 860, 21.004 );
		parking_position = Vector3( -1203.149, -1802.098 + 860, 21.004 );
		vehicle_position = Vector3( -1193.166, -1798.174 + 860, 20.793 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[6] = {
		class = 1;
		max_count = 15;

		enter_position = Vector3( -1178.178, -1776.296 + 860, 21 );
		parking_position = Vector3( -1182.089, -1779.337 + 860, 21.14 );
		vehicle_position = Vector3( -1192.854, -1776.73 + 860, 20.793 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[7] = {
		class = 1;
		max_count = 15;

		enter_position = Vector3( -1178.112, -1705.362 + 860, 21.004 );
		parking_position = Vector3( -1181.913, -1708.406 + 860, 21.004 );
		vehicle_position = Vector3( -1193.11, -1705.43 + 860, 20.793 );

		vehicle_rotation = Vector3( 0, 0, 0 );
	};
	[8] = {
		class = 1;
		max_count = 15;

		enter_position = Vector3( -1318.976, -1596.857 + 860, 21 );
		parking_position = Vector3( -1315.181, -1593.841 + 860, 21.004 );
		vehicle_position = Vector3( -1310.431, -1597.199 + 860, 20.793 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[9] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -1318.465, -1632.617 + 860, 21.13 );
		parking_position = Vector3( -1321.955, -1628.299 + 860, 21.004 );
		vehicle_position = Vector3( -1319.828, -1620.9 + 860, 20.793 );

		vehicle_rotation = Vector3( 0, 0, 90 );
	};
	[10] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -1232.467, -1633.12 + 860, 21.13 );
		parking_position = Vector3( -1229.42, -1628.496 + 860, 21.004 );
		vehicle_position = Vector3( -1231.955, -1620.758 + 860, 20.789 );

		vehicle_rotation = Vector3( 0, 0, 90 );
	};
	[11] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -1170.208, -1632.805 + 860, 21.004 );
		parking_position = Vector3( -1167.411, -1628.506 + 860, 21.004 );
		vehicle_position = Vector3( -1169.887, -1620.824 + 860, 20.793 );

		vehicle_rotation = Vector3( 0, 0, 270 );
	};
	[12] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -1270.301, -1551.12 + 860, 21.079 );
		parking_position = Vector3( -1267.768, -1554.647 + 860, 21 );
		vehicle_position = Vector3( -1269.961, -1560.642 + 860, 20.793 );

		vehicle_rotation = Vector3( 0, 0, 90 );
	};
	[13] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -1202.801, -1551.388 + 860, 21.079 );
		parking_position = Vector3( -1200.104, -1554.665 + 860, 21.004 );
		vehicle_position = Vector3( -1202.336, -1560.474 + 860, 20.793 );

		vehicle_rotation = Vector3( 0, 0, 270 );
	};
	[14] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -947.232, -1724.128 + 860, 21.179 );
		parking_position = Vector3( -943.881, -1721.302 + 860, 20.992 );
		vehicle_position = Vector3( -937.725, -1723.821 + 860, 20.781 );

		vehicle_rotation = Vector3( 0, 0, 0 );
	};
	[15] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -947.862, -1791.963 + 860, 21.179 );
		parking_position = Vector3( -944.665, -1789.239 + 860, 20.984 );
		vehicle_position = Vector3( -937.841, -1791.647 + 860, 20.781 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[16] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -890.527, -1769.126 + 860, 20.984 );
		parking_position = Vector3( -894.551, -1771.812 + 860, 21.125 );
		vehicle_position = Vector3( -905.167, -1770.156 + 860, 20.781 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[17] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( 268.89, -2373.2 + 860, 21 );
		parking_position = Vector3( 266.6, -2369.91 + 860, 20.6 );
		vehicle_position = Vector3( 265.7, -2364.7 + 860, 20.39 );

		vehicle_rotation = Vector3( 0, 0, 270 );
	};
	[18] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( 334.79, -2373.1 + 860, 21 );
		parking_position = Vector3( 331.29, -2369.6 + 860, 20.7 );
		vehicle_position = Vector3( 335.2, -2364.81 + 860, 20.39 );

		vehicle_rotation = Vector3( 0, 0, 270 );
	};
	[19] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( 397.2, -2372.81 + 860, 21 );
		parking_position = Vector3( 394.2, -2369.31 + 860, 20.7 );
		vehicle_position = Vector3( 398.2, -2364.81 + 860, 20.39 );

		vehicle_rotation = Vector3( 0, 0, 270 );
	};
	[20] = {
		class = 1;
		max_count = 50;

		enter_position = Vector3( 2134.666, -1385.697 + 860, 62.427 );
		parking_position = Vector3( 2136.572, -1384.628 + 860, 62.427 );
		vehicle_position = Vector3( 2129.372, -1370.124 + 860, 60.548 );

		vehicle_rotation = Vector3( 0, 0, 294 );
	};
	[21] = {
		class = 1;
		max_count = 50;

		enter_position = Vector3( 2155.45, -1297.719 + 860, 61.47 );
		parking_position = Vector3( 2154.329, -1301.867 + 860, 60.679 );
		vehicle_position = Vector3( 2145.436, -1303.283 + 860, 60.546 );

		vehicle_rotation = Vector3( 0, 0, 25 );
	};
	[22] = {
		class = 1;
		max_count = 50;

		enter_position = Vector3( 2105.615, -1192.169 + 860, 61.47 );
		parking_position = Vector3( 2104.604, -1196.135 + 860, 60.679 );
		vehicle_position = Vector3( 2096.031, -1197.958 + 860, 60.546 );

		vehicle_rotation = Vector3( 0, 0, 25 );
	};
	[23] = {
		class = 1;
		max_count = 50;

		enter_position = Vector3( 2008.142, -1245.999 + 860, 62.427 );
		parking_position = Vector3( 2009.252, -1247.961 + 860, 62.427 );
		vehicle_position = Vector3( 2023.01, -1241.92 + 860, 60.548 );

		vehicle_rotation = Vector3( 0, 0, 205 );
	};
	[24] = {
		class = 1;
		max_count = 50;

		enter_position = Vector3( 2050.397, -1337.161 + 860, 62.427 );
		parking_position = Vector3( 2051.403, -1339.03 + 860, 62.427 );
		vehicle_position = Vector3( 2064.633, -1331.313 + 860, 60.548 );

		vehicle_rotation = Vector3( 0, 0, 205 );
	};
	[25] = {
		class = 1;
		max_count = 50;

		enter_position = Vector3( 1983.313, -1119.424 + 860, 62.427 );
		parking_position = Vector3( 1985.176, -1118.625 + 860, 62.427 );
		vehicle_position = Vector3( 1976.421, -1103.664 + 860, 60.548 );

		vehicle_rotation = Vector3( 0, 0, 294 );
	};
	[26] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -53.081, -1923.869 + 860, 21.919 );
		parking_position = Vector3( -51.044, -1927.053 + 860, 20.981 );
		vehicle_position = Vector3( -45.259, -1916.513 + 860, 20.859 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[27] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -53.095, -1881.598 + 860, 21.919 );
		parking_position = Vector3( -51.605, -1879.075 + 860, 20.981 );
		vehicle_position = Vector3( -45.259, -1875.644 + 860, 20.771 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[28] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -53.055, -1854.256 + 860, 21.919 );
		parking_position = Vector3( -51.681, -1851.92 + 860, 20.981 );
		vehicle_position = Vector3( -45.259, -1844.747 + 860, 20.762 );

		vehicle_rotation = Vector3( 0, 0, 0 );
	};
	[29] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -53.114, -1822.289 + 860, 21.983 );
		parking_position = Vector3( -51.567, -1824.676 + 860, 20.981 );
		vehicle_position = Vector3( -45.259, -1830.004 + 860, 20.762 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[30] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -53.038, -1807.193 + 860, 21.983 );
		parking_position = Vector3( -51.628, -1804.961 + 860, 20.981 );
		vehicle_position = Vector3( -45.259, -1800.407 + 860, 20.762 );

		vehicle_rotation = Vector3( 0, 0, 0 );
	};
	[31] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -52.939, -1779.894 + 860, 21.983 );
		parking_position = Vector3( -51.512, -1777.43 + 860, 20.981 );
		vehicle_position = Vector3( -45.259, -1771.49 + 860, 20.77 );

		vehicle_rotation = Vector3( 0, 0, 0 );
	};
	[32] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -8.569, -1787.68 + 860, 21.742 );
		parking_position = Vector3( -6.32, -1789.421 + 860, 20.747 );
		vehicle_position = Vector3( -0.012, -1793.613 + 860, 20.747 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[33] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( 26.909, -1815.126 + 860, 21.742 );
		parking_position = Vector3( 25.327, -1812.831 + 860, 20.747 );
		vehicle_position = Vector3( 21.734, -1823.044 + 860, 20.747 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[34] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( 23.288, -1884.529 + 860, 21.744 );
		parking_position = Vector3( 21.651, -1887.132 + 860, 20.747 );
		vehicle_position = Vector3( 17.156, -1876.717 + 860, 20.747 );

		vehicle_rotation = Vector3( 0, 0, 90 );
	};
	[35] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -12.953, -1905.56 + 860, 21.744 );
		parking_position = Vector3( -15.709, -1905.003 + 860, 20.747 );
		vehicle_position = Vector3( -21.514, -1903.071 + 860, 20.747 );

		vehicle_rotation = Vector3( 0, 0, 90 );
	};
	[36] = {
		class = 2;
		max_count = 50;

		enter_position = Vector3( 2047.164, -1057.176 + 860, 62.43 );
		parking_position = Vector3( 2048.12, -1059.141 + 860, 62.43 );
		vehicle_position = Vector3( 2033.45, -1063.788 + 860, 60.548 );

		vehicle_rotation = Vector3( 0, 0, 25 );
	};
	[37] = {
		class = 2;
		max_count = 50;

		enter_position = Vector3( 2003.339, -963.521 + 860, 62.426 );
		parking_position = Vector3( 2002.558, -961.495 + 860, 62.426 );
		vehicle_position = Vector3( 1989.239, -968.91 + 860, 60.549 );

		vehicle_rotation = Vector3( 0, 0, 25 );
	};
	[38] = {
		class = 2;
		max_count = 50;

		enter_position = Vector3( 1937.253, -919.258 + 860, 62.426 );
		parking_position = Vector3( 1935.354, -920.378 + 860, 62.426 );
		vehicle_position = Vector3( 1942.63, -932.569 + 860, 60.547 );

		vehicle_rotation = Vector3( 0, 0, 294 );
	};
	[39] = {
		class = 2;
		max_count = 50;

		enter_position = Vector3( 1924.308, -1064.078 + 860, 62.426 );
		parking_position = Vector3( 1925.032, -1065.769 + 860, 62.426 );
		vehicle_position = Vector3( 1937.456, -1058.6 + 860, 60.548 );

		vehicle_rotation = Vector3( 0, 0, 25 );
	};
	[40] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -684.6, -1797 + 860, 21.5 );
		parking_position = Vector3( -682.71, -1800.71 + 860, 20.79 );
		vehicle_position = Vector3( -693.91, -1807.91 + 860, 20.79 );

		vehicle_rotation = Vector3( 0, 0, 80 );
	};
	[41] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -683.6, -1834 + 860, 21.6 );
		parking_position = Vector3( -687.91, -1835.71 + 860, 20.79 );
		vehicle_position = Vector3( -695.8, -1832.91 + 860, 20.6 );

		vehicle_rotation = Vector3( 0, 0, 350 );
	};
	[42] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -754.3, -1821 + 860, 21.6 );
		parking_position = Vector3( -755.91, -1816.71 + 860, 20.89 );
		vehicle_position = Vector3( -754.3, -1809.21 + 860, 20.79 );

		vehicle_rotation = Vector3( 0, 0, 258 );
	};
	[43] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -743.5, -1905.91 + 860, 21.7 );
		parking_position = Vector3( -741.21, -1902.6 + 860, 20.79 );
		vehicle_position = Vector3( -747.41, -1899.81 + 860, 20.79 );

		vehicle_rotation = Vector3( 0, 0, 270 );
	};
	[44] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -795.6, -1779.5 + 860, 21.6 );
		parking_position = Vector3( -794, -1782.71 + 860, 20.79 );
		vehicle_position = Vector3( -779.21, -1796.1 + 860, 20.6 );

		vehicle_rotation = Vector3( 0, 0, 82 );
	};
	[45] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -809.8, -1814 + 860, 21.79 );
		parking_position = Vector3( -807.1, -1816.8 + 860, 20.79 );
		vehicle_position = Vector3( -793.71, -1818.71 + 860, 20.79 );

		vehicle_rotation = Vector3( 0, 0, 172 );
	};
	[46] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -821.6, -1914.5 + 860, 21.79 );
		parking_position = Vector3( -819, -1916.91 + 860, 20.79 );
		vehicle_position = Vector3( -810.6, -1917.5 + 860, 20.79 );

		vehicle_rotation = Vector3( 0, 0, 182 );
	};
	[47] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( 168.1, -2318.81 + 860, 21.2 );
		parking_position = Vector3( 169.89, -2316.1 + 860, 20.79 );
		vehicle_position = Vector3( 176.39, -2317.6 + 860, 20.6 );

		vehicle_rotation = Vector3( 0, 0, 178 );
	};
	[48] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( 191.6, -2298.91 + 860, 21.2 );
		parking_position = Vector3( 193.3, -2296.2 + 860, 20.79 );
		vehicle_position = Vector3( 204.39, -2296.31 + 860, 20.6 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[49] = {
		class = 3;
		max_count = 50;

		enter_position = Vector3( 100.462, -1468.023 + 860, 21.833 );
		parking_position = Vector3( 98.253, -1463.644 + 860, 20.851 );
		vehicle_position = Vector3( 106.096, -1452.927 + 860, 20.615 );

		vehicle_rotation = Vector3( 0, 0, 270 );
	};
	[50] = {
		class = 3;
		max_count = 50;

		enter_position = Vector3( 163.591, -1488.521 + 860, 21.606 );
		parking_position = Vector3( 168.019, -1488.994 + 860, 20.847 );
		vehicle_position = Vector3( 174.633, -1491.527 + 860, 20.822 );

		vehicle_rotation = Vector3( 0, 0, 90 );
	};
	[51] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( 2164.474, -354.517 + 860, 61.708 );
		parking_position = Vector3( 2162.87, -352.186 + 860, 60.738 );
		vehicle_position = Vector3( 2162.532, -362.07 + 860, 60.582 );

		vehicle_rotation = Vector3( 0, 0, 22 );
	};
	[52] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( 2201.166, -444.155 + 860, 61.708 );
		parking_position = Vector3( 2201.931, -446.641 + 860, 60.738 );
		vehicle_position = Vector3( 2193.612, -438.806 + 860, 60.582 );

		vehicle_rotation = Vector3( 0, 0, 203 );
	};
	[53] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( 2364.951, -675.352 + 860, 61.673 );
		parking_position = Vector3( 2365.132, -679.933 + 860, 60.815 );
		vehicle_position = Vector3( 2356.984, -674.987 + 860, 60.82 );

		vehicle_rotation = Vector3( 0, 0, 17 );
	};
	[54] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( 2398.962, -784.754 + 860, 61.679 );
		parking_position = Vector3( 2399.171, -789.655 + 860, 60.815 );
		vehicle_position = Vector3( 2392.808, -786.602 + 860, 60.82 );

		vehicle_rotation = Vector3( 0, 0, 201 );
	};
	[55] = {
		class = 3;
		max_count = 10;

		enter_position = Vector3( 2061.021, 1151.372 + 860, 17.039 );
		parking_position = Vector3( 2062, 1148.581 + 860, 16.395 );
		vehicle_position = Vector3( 2055.895, 1143.976 + 860, 16.387 );

		vehicle_rotation = Vector3( 0, 0, 100 );
	};
	[56] = {
		class = 3;
		max_count = 10;

		enter_position = Vector3( 2035.228, 1169.252 + 860, 17.039 );
		parking_position = Vector3( 2036.763, 1165.333 + 860, 16.391 );
		vehicle_position = Vector3( 2031.223, 1161.18 + 860, 16.389 );

		vehicle_rotation = Vector3( 0, 0, 100 );
	};
	[57] = {
		class = 3;
		max_count = 10;

		enter_position = Vector3( 2005.288, 1183.267 + 860, 17.036 );
		parking_position = Vector3( 2006.07, 1179.204 + 860, 16.39 );
		vehicle_position = Vector3( 2002.58, 1175.587 + 860, 16.161 );

		vehicle_rotation = Vector3( 0, 0, 100 );
	};
	[58] = {
		class = 3;
		max_count = 10;

		enter_position = Vector3( 1972.544 + 860, 1195.221 + 860, 17.039 );
		parking_position = Vector3( 1974.693, 1194.906 + 860, 16.393 );
		vehicle_position = Vector3( 1973.934, 1185.518 + 860, 16.161 );

		vehicle_rotation = Vector3( 0, 0, 100 );
	};
	[59] = {
		class = 3;
		max_count = 10;

		enter_position = Vector3( 1960.725, 1194.448 + 860, 17.039 );
		parking_position = Vector3( 1964.148, 1192.318 + 860, 16.394 );
		vehicle_position = Vector3( 1961.535, 1187.197 + 860, 16.161 );

		vehicle_rotation = Vector3( 0, 0, 100 );
	};


	-- Подмосковье
	[60] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -311.346, 341.201 + 860, 21.286 );
		parking_position = Vector3( -313.57, 338.219 + 860, 20.905 );
		vehicle_position = Vector3( -320.608, 333.817 + 860, 20.544 );

		vehicle_rotation = Vector3( 0, 0, 0 );
	};
	[61] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -386.015, 358.888 + 860, 21.261 );
		parking_position = Vector3( -383.889, 363.252 + 860, 20.905 );
		vehicle_position = Vector3( -377.491, 367.974 + 860, 20.332 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[62] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -413.575, 421.256 + 860, 21.261 );
		parking_position = Vector3( -411.884, 424.315 + 860, 20.908 );
		vehicle_position = Vector3( -406.944, 428.782 + 860, 20.324 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[63] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -413.505, 327.31 + 860, 21.286 );
		parking_position = Vector3( -411.583, 330.374 + 860, 20.905 );
		vehicle_position = Vector3( -406.763, 333.375 + 860, 20.331 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[64] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -569.3, 327.556 + 860, 21.269 );
		parking_position = Vector3( -566.497, 324.663 + 860, 20.91 );
		vehicle_position = Vector3( -558.433, 335.626 + 860, 20.332 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[65] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -511.51, 436.007 + 860, 21.27 );
		parking_position = Vector3( -514.518, 431.607 + 860, 20.909 );
		vehicle_position = Vector3( -519.602, 426.465 + 860, 20.332 );

		vehicle_rotation = Vector3( 0, 0, 0 );
	};
	[66] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -408.611, 696.101 + 860, 21.286 );
		parking_position = Vector3( -405.106, 695.425 + 860, 20.913 );
		vehicle_position = Vector3( -399.539, 691.703 + 860, 20.327 );

		vehicle_rotation = Vector3( 0, 0, 90 );
	};
	[67] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -492.069, 635.381 + 860, 21.272 );
		parking_position = Vector3( -490.274, 639.093 + 860, 20.907 );
		vehicle_position = Vector3( -481.874, 630.273 + 860, 20.334 );

		vehicle_rotation = Vector3( 0, 0, 0 );
	};
	[68] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -380.508, 586.108 + 860, 20.935 );
		parking_position = Vector3( -383.36, 580.779 + 860, 20.908 );
		vehicle_position = Vector3( -388.199, 578.089 + 860, 20.332 );

		vehicle_rotation = Vector3( 0, 0, 0 );
	};
	[69] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -284.041, 556.917 + 860, 21.27 );
		parking_position = Vector3( -286.055, 552.864 + 860, 20.908 );
		vehicle_position = Vector3( -294.475, 565.359 + 860, 20.336 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[70] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -122.235, 648.805 + 860, 21.272 );
		parking_position = Vector3( -119.543, 652.186 + 860, 20.909 );
		vehicle_position = Vector3( -115.283, 656.652 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[71] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -123.947, 586.238 + 860, 20.948 );
		parking_position = Vector3( -119.304, 591.125 + 860, 20.909 );
		vehicle_position = Vector3( -116.014, 595.896 + 860, 20.331 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[72] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -11.534, 635.294 + 860, 21.27 );
		parking_position = Vector3( -13.548, 631.881 + 860, 20.909 );
		vehicle_position = Vector3( -22.652, 644.649 + 860, 20.329 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[73] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -31.777, 532.835 + 860, 20.997 );
		parking_position = Vector3( -34.415, 536.984 + 860, 20.916 );
		vehicle_position = Vector3( -40.189, 540.526 + 860, 20.334 );

		vehicle_rotation = Vector3( 0, 0, 270 );
	};
	[74] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -282.449, 659.581 + 860, 20.997 );
		parking_position = Vector3( -279.864, 656.135 + 860, 20.92 );
		vehicle_position = Vector3( -274.462, 651.606 + 860, 20.341 );

		vehicle_rotation = Vector3( 0, 0, 270 );
	};
	[75] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -494.247, 533.292 + 860, 20.997 );
		parking_position = Vector3( -496.506, 535.9 + 860, 20.922 );
		vehicle_position = Vector3( -502.805, 540.951 + 860, 20.322 );

		vehicle_rotation = Vector3( 0, 0, 90 );
	};
	[76] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -511.46, 420.79 + 860, 21.27 );
		parking_position = Vector3( -514.39, 417.35 + 860, 20.9 );
		vehicle_position = Vector3( -520.41, 412.49 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 0 );
	};
	[77] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -511.51, 405.96 + 860, 21.27 );
		parking_position = Vector3( -514.7, 402.18 + 860, 20.9 );
		vehicle_position = Vector3( -519.81, 395.66 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 0 );
	};
	[78] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -569.15, 297.61 + 860, 21.26 );
		parking_position = Vector3( -565.09, 300.31 + 860, 20.91 );
		vehicle_position = Vector3( -560.19, 306.49 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 181 );
	};
	[79] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -569.25, 312.71 + 860, 21.26 );
		parking_position = Vector3( -566.1, 310.33 + 860, 20.91 );
		vehicle_position = Vector3( -559.75, 320.45 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 179 );
	};
	[80] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -569.58, 342.48 + 860, 21.26 );
		parking_position = Vector3( -566.17, 344.82 + 860, 20.91 );
		vehicle_position = Vector3( -559.74, 352.6 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 179 );
	};
	[81] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -569.19, 357.54 + 860, 21.26 );
		parking_position = Vector3( -566.22, 354.98 + 860, 20.91 );
		vehicle_position = Vector3( -559.75, 368.28 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[82] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -569.2, 372.56 + 860, 21.26 );
		parking_position = Vector3( -565.59, 375.21 + 860, 20.91 );
		vehicle_position = Vector3( -559.94, 379.29 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 176 );
	};
	[83] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -413.35, 342.49 + 860, 21.28 );
		parking_position = Vector3( -411.07, 345.56 + 860, 20.9 );
		vehicle_position = Vector3( -408.19, 350.17 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 179 );
	};
	[84] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -413.96, 312.3 + 860, 21.28 );
		parking_position = Vector3( -410.33, 310.1 + 860, 20.9 );
		vehicle_position = Vector3( -408, 319.23 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 178 );
	};
	[85] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -413.59, 297.5 + 860, 21.28 );
		parking_position = Vector3( -410.98, 299.99 + 860, 20.9 );
		vehicle_position = Vector3( -408.43, 304.84 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 178 );
	};
	[86] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -386.21, 373.99 + 860, 21.26 );
		parking_position = Vector3( -382.87, 377.09 + 860, 20.9 );
		vehicle_position = Vector3( -378.83, 380.04 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 178 );
	};
	[87] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -386.37, 343.99 + 860, 21.26 );
		parking_position = Vector3( -383.49, 341.15 + 860, 20.9 );
		vehicle_position = Vector3( -378.85, 350.38 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[88] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -386.16, 324.98 + 860, 21.26 );
		parking_position = Vector3( -382.74, 322.18 + 860, 20.9 );
		vehicle_position = Vector3( -378.71, 333.35 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[89] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -385.97, 309.84 + 860, 21.26 );
		parking_position = Vector3( -382.85, 306.97 + 860, 20.9 );
		vehicle_position = Vector3( -378.6, 316.84 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[90] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -386.16, 294.8 + 860, 21.26 );
		parking_position = Vector3( -383.43, 292.1 + 860, 20.9 );
		vehicle_position = Vector3( -378.53, 302.56 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 180 );
	};
	[91] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -492.15, 620.4 + 860, 21.27 );
		parking_position = Vector3( -490.17, 622.83 + 860, 20.9 );
		vehicle_position = Vector3( -482.56, 620.86 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 309 );
	};
	[92] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -492.24, 650.32 + 860, 21.27 );
		parking_position = Vector3( -490.28, 653.16 + 860, 20.9 );
		vehicle_position = Vector3( -481.73, 650.62 + 860, 20.34 );

		vehicle_rotation = Vector3( 0, 0, 53 );
	};
	[93] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -475.03, 533.25 + 860, 20.99 );
		parking_position = Vector3( -472.84, 536.88 + 860, 20.91 );
		vehicle_position = Vector3( -476.64, 540.78 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 268 );
	};
	[94] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -393.66, 696.15 + 860, 21.28 );
		parking_position = Vector3( -389.13, 695.47 + 860, 20.9 );
		vehicle_position = Vector3( -385.87, 691.84 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 268 );
	};
	[95] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -423.64, 696.22 + 860, 21.28 );
		parking_position = Vector3( -420.89, 695.11 + 860, 20.9 );
		vehicle_position = Vector3( -416.81, 691.75 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 269 );
	};
	[96] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -438.51, 696.35 + 860, 21.28 );
		parking_position = Vector3( -435.04, 694.94 + 860, 20.91 );
		vehicle_position = Vector3( -431.15, 691.67 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 269 );
	};
	[97] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -380.66, 608.17 + 860, 20.93 );
		parking_position = Vector3( -384.56, 605.35 + 860, 20.9 );
		vehicle_position = Vector3( -388.81, 600.58 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 181 );
	};
	[98] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -284, 571.7 + 860, 21.27 );
		parking_position = Vector3( -285.75, 568.75 + 860, 20.9 );
		vehicle_position = Vector3( -293.94, 571.65 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 307 );
	};
	[99] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -284.09, 541.99 + 860, 21.27 );
		parking_position = Vector3( -286.05, 538.64 + 860, 20.9 );
		vehicle_position = Vector3( -294.4, 542.07 + 860, 20.34 );

		vehicle_rotation = Vector3( 0, 0, 235 );
	};
	[100] = {
		class = 2;
		max_count = 30;

		enter_position = Vector3( -301.92, 659.85 + 860, 20.99 );
		parking_position = Vector3( -304.14, 655.11 + 860, 20.9 );
		vehicle_position = Vector3( -296.87, 650.97 + 860, 20.34 );

		vehicle_rotation = Vector3( 0, 0, 270 );
	};
	[101] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -310.79, 356.14 + 860, 21.28 );
		parking_position = Vector3( -315.89, 353.44 + 860, 20.9 );
		vehicle_position = Vector3( -320.88, 348.89 + 860, 20.54 );

		vehicle_rotation = Vector3( 0, 0, 0 );
	};
	[102] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -310.7, 371.15 + 860, 21.28 );
		parking_position = Vector3( -315.86, 368.09 + 860, 20.9 );
		vehicle_position = Vector3( -320.86, 364.33 + 860, 20.54 );

		vehicle_rotation = Vector3( 0, 0, 359 );
	};
	[103] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -121.86, 664.11 + 860, 21.27 );
		parking_position = Vector3( -119.49, 666.68 + 860, 20.9 );
		vehicle_position = Vector3( -114.98, 669.02 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 359 );
	};
	[104] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -121.95, 633.84 + 860, 21.27 );
		parking_position = Vector3( -120.26, 636.86 + 860, 20.9 );
		vehicle_position = Vector3( -115.19, 640 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 359 );
	};
	[105] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -124.31, 608.11 + 860, 20.95 );
		parking_position = Vector3( -119.32, 611.18 + 860, 20.9 );
		vehicle_position = Vector3( -115.25, 614.52 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 359 );
	};
	[106] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -11.54, 650.26 + 860, 21.27 );
		parking_position = Vector3( -13.61, 647.56 + 860, 20.9 );
		vehicle_position = Vector3( -21.8, 650.44 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 307 );
	};
	[107] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -11.43, 620.33 + 860, 21.27 );
		parking_position = Vector3( -13.64, 617.11 + 860, 20.91 );
		vehicle_position = Vector3( -22.27, 621.86 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 235 );
	};
	[108] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -12.75, 532.98 + 860, 20.99 );
		parking_position = Vector3( -10.73, 537.79 + 860, 20.9 );
		vehicle_position = Vector3( -19.35, 539.86 + 860, 20.33 );

		vehicle_rotation = Vector3( 0, 0, 269 );
	};
	[109] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -413.64, 436.33 + 860, 21.26 );
		parking_position = Vector3( -411.67, 439.12 + 860, 20.9 );
		vehicle_position = Vector3( -406.29, 442.9 + 860, 20.32 );

		vehicle_rotation = Vector3( 0, 0, 359 );
	};
	[110] = {
		class = 1;
		max_count = 30;

		enter_position = Vector3( -413.39, 406.28 + 860, 21.26 );
		parking_position = Vector3( -411.94, 409.2 + 860, 20.9 );
		vehicle_position = Vector3( -406.36, 413.32 + 860, 20.32 );

		vehicle_rotation = Vector3( 0, 0, 359 );
	};

	-- МСК
	[111] = {
		class = 3;
		max_count = 10;

		enter_position = Vector3( 865.07, 2224.16 + 860, 9.2 );
		parking_position = Vector3( 841.673, 2225.605 + 860, 9.424 );
		vehicle_position = Vector3( 847.982, 2226.708 + 860, 9.201 );
		vehicle_rotation = Vector3( 0, 0, 183.138 );
	};

	[112] = {
		class = 3;
		max_count = 10;

		enter_position = Vector3( 884.805, 2225.800 + 860, 9.2 );
		parking_position = Vector3( 905.710, 2232.227 + 860, 9.209 );
		vehicle_position = Vector3( 899.665, 2231.762 + 860, 9.201 );
		vehicle_rotation = Vector3( 0, 0, 185.254 );
	};

	[113] = {
		class = 3;
		max_count = 25;

		enter_position = Vector3( 1419.43, 2217.18 + 860, 9.27 );
		parking_position = Vector3( 1419.242, 2222.754 + 860, 9.267 );
		vehicle_position = Vector3( 1415.462, 2217.189 + 860, 9.267 );
		vehicle_rotation = Vector3( 0, 0, 90 );
	};

	[114] = {
		class = 3;
		max_count = 25;

		enter_position = Vector3( 1419.43, 2232.7 + 860, 9.27 );
		parking_position = Vector3( 1419.262, 2238.661 + 860, 9.267 );
		vehicle_position = Vector3( 1415.382, 2233.104 + 860, 9.124 );
		vehicle_rotation = Vector3( 0, 0, 90 );
	};

	[115] = {
		class = 3;
		max_count = 25;

		enter_position = Vector3( 1419.43, 2248.7 + 860, 9.27 );
		parking_position = Vector3( 1419.316, 2254.099 + 860, 9.275 );
		vehicle_position = Vector3( 1415.602, 2248.733 + 860, 9.133 );
		vehicle_rotation = Vector3( 0, 0, 90 );
	};

	[116] = {
		class = 3;
		max_count = 25;

		enter_position = Vector3( 1419.43, 2263.56 + 860, 9.27 );
		parking_position = Vector3( 1419.327, 2269.525 + 860, 9.267 );
		vehicle_position = Vector3( 1415.697, 2264.193 + 860, 9.145 );
		vehicle_rotation = Vector3( 0, 0, 90 );
	};

	[117] = {
		class = 3;
		max_count = 25;

		enter_position = Vector3( 1419.43, 2296.37 + 860, 9.22 );
		parking_position = Vector3( 1419.980, 2302.110 + 860, 9.220 );
		vehicle_position = Vector3( 1415.635, 2296.601 + 860, 9.303 );
		vehicle_rotation = Vector3( 0, 0, 90 );
	};

	[118] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( 1756.84, 2294.79 + 860, 8.77 );
		parking_position = Vector3( 1755.2983398438, 2299.4675292969 + 860, 8.7728872299194 );
		vehicle_position = Vector3( 1750.8937988281, 2292.7399902344 + 860, 8.5697622299194 );
		vehicle_rotation = Vector3( 0, 0, 0 );
	};

	[119] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( 1753.62, 2310.01 + 860, 8.77 );
		parking_position = Vector3( 1752.1739501953, 2315.0524902344 + 860, 8.7728872299194 );
		vehicle_position = Vector3( 1747.4415283203, 2308.7192382813 + 860, 8.5697622299194 );
		vehicle_rotation = Vector3( 0, 0, 0 );
	};

	[120] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( 1719.7099609375, 2270.6201171875 + 860, 8.7728872299194 );
		parking_position = Vector3( 1718.673828125, 2276.1831054688 + 860, 8.7728872299194 );
		vehicle_position = Vector3( 1733.6372070313, 2288.9572753906 + 860, 8.5697622299194 );
		vehicle_rotation = Vector3( 0, 0, 100 );
	};

	[121] = {
		class = 3;
		max_count = 20;

		enter_position = Vector3( 1710.6800537109, 2307.5300292969 + 860, 9.2471122741699 );
		parking_position = Vector3( 1712.5461425781, 2304.2758789063 + 860, 8.7700777053833 );
		vehicle_position = Vector3( 1716.7794189453, 2309.1408691406 + 860, 8.5697622299194 );
		vehicle_rotation = Vector3( 0, 0, 0 );
	};

	[122] = {
		class = 3;
		max_count = 20;

		enter_position = Vector3( 1713.2600097656, 2296.3500976563 + 860, 9.2471122741699 );
		parking_position = Vector3( 1713.2415771484, 2300.4211425781 + 860, 8.7728872299194 );
		vehicle_position = Vector3( 1719.4516601563, 2297.6508789063 + 860, 8.5697622299194 );
		vehicle_rotation = Vector3( 0, 0, 0 );
	};

	[123] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( 1750.0500488281, 2325.2800292969 + 860, 8.7728872299194 );
		parking_position = Vector3( 1749.3227539063, 2330.3723144531 + 860, 8.7728872299194 );
		vehicle_position = Vector3( 1744.3591308594, 2323.7373046875 + 860, 8.5697622299194 );
		vehicle_rotation = Vector3( 0, 0, 0 );
	};

	[124] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( 1747.0200195313, 2340.4799804688 + 860, 8.7700777053833 );
		parking_position = Vector3( 1745.6561279297, 2345.6936035156 + 860, 8.7728872299194 );
		vehicle_position = Vector3( 1741.0787353516, 2339.2463378906 + 860, 8.5697622299194 );
		vehicle_rotation = Vector3( 0, 0, 0 );
	};

	[125] = {
		class = 3;
		max_count = 50;

		enter_position = Vector3( 1667.7513427734, 2459.0732421875 + 860, 9.8351516723633 );
		parking_position = Vector3( 1667.3779296875, 2452.037109375 + 860, 8.8772249221802 );
		vehicle_position = Vector3( 1661.1721191406, 2459.2033691406 + 860, 8.6742887496948 );
		vehicle_rotation = Vector3( 0, 0, 0 );
	};

	[126] = {
		class = 3;
		max_count = 20;

		enter_position = Vector3( 1695.9000244141, 2513.1899414063 + 860, 9.3337125778198 );
		parking_position = Vector3( 1692.021484375, 2515.5783691406 + 860, 8.8772249221802 );
		vehicle_position = Vector3( 1696.3074951172, 2521.9904785156 + 860, 8.6819124221802 );
		vehicle_rotation = Vector3( 0, 0, 90 );
	};

	[127] = {
		class = 3;
		max_count = 20;

		enter_position = Vector3( 1684.3000488281, 2513.2700195313 + 860, 9.3337125778198 );
		parking_position = Vector3( 1687.8570556641, 2515.8310546875 + 860, 8.8772249221802 );
		vehicle_position = Vector3( 1684.3536376953, 2521.7033691406 + 860, 8.6771650314331 );
		vehicle_rotation = Vector3( 0, 0, 90 );
	};

	[128] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( 1621.5799560547, 2558.0900878906 + 860, 8.8772249221802 );
		parking_position = Vector3( 1626.8917236328, 2558.2365722656 + 860, 8.8772249221802 );
		vehicle_position = Vector3( 1621.0887451172, 2552.1201171875 + 860, 8.6740999221802 );
		vehicle_rotation = Vector3( 0, 0, 180 );
	};

	[129] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( 1636.9699707031, 2558.1999511719 + 860, 8.8772249221802 );
		parking_position = Vector3( 1642.3735351563, 2558.1169433594 + 860, 8.8772249221802 );
		vehicle_position = Vector3( 1637.27734375, 2552.0239257813 + 860, 8.6778497695923 );
		vehicle_rotation = Vector3( 0, 0, 90 );
	};

	[130] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( 1652.5100097656, 2558.3100585938 + 860, 8.8772249221802 );
		parking_position = Vector3( 1657.8927001953, 2558.4448242188 + 860, 8.8772249221802 );
		vehicle_position = Vector3( 1652.5079345703, 2552.0493164063 + 860, 8.673903465271 );
		vehicle_rotation = Vector3( 0, 0, 90 );
	};

	[131] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( 1668.0699462891, 2558.1398925781 + 860, 8.8772249221802 );
		parking_position = Vector3( 1673.5913085938, 2558.443359375 + 860, 8.8772249221802 );
		vehicle_position = Vector3( 1668.0485839844, 2552.3017578125 + 860, 8.6699838638306 );
		vehicle_rotation = Vector3( 0, 0, 90 );
	};

	[132] = {
		class = 3;
		max_count = 50;

		enter_position = Vector3( 1537.7700195313, 2613.6599121094 + 860, 11.24494934082 );
		parking_position = Vector3( 1531.0334472656, 2613.5808105469 + 860, 10.191534996033 );
		vehicle_position = Vector3( 1515.4848632813, 2613.9829101563 + 860, 9.9472742080688 );
		vehicle_rotation = Vector3( 0, 0, 0 );
	};

	[133] = {
		class = 3;
		max_count = 50;

		enter_position = Vector3( 1489.3922119141, 2570.3806152344 + 860, 11.245594024658 );
		parking_position = Vector3( 1482.6547851563, 2570.6840820313 + 860, 10.294010162354 );
		vehicle_position = Vector3( 1489.0098876953, 2564.0612792969 + 860, 10.090885162354 );
		vehicle_rotation = Vector3( 0, 0, 90 );
	};

	[134] = {
		class = 3;
		max_count = 50;

		enter_position = Vector3( 1215.5200195313, 2611.2600097656 + 860, 11.24494934082 );
		parking_position = Vector3( 1208.8426513672, 2611.3452148438 + 860, 10.334674835205 );
		vehicle_position = Vector3( 1193.3170166016, 2532.27734375 + 860, 11.037975311279 );
		vehicle_rotation = Vector3( 0, 0, 90 );
	};

	[135] = {
		class = 3;
		max_count = 50;

		enter_position = Vector3( 1194.6300048828, 2584.580078125 + 860, 11.287048339844 );
		parking_position = Vector3( 1201.4296875, 2584.1750488281 + 860, 10.327037811279 );
		vehicle_position = Vector3( 1174.0148925781, 2532.1079101563 + 860, 11.046441078186 );
		vehicle_rotation = Vector3( 0, 0, 90 );
	};

	[136] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( -816.78997802734, 2723.7800292969 + 860, 15.503887176514 );
		parking_position = Vector3( -816.66973876953, 2718.7768554688 + 860, 15.503887176514 );
		vehicle_position = Vector3( -810.24359130859, 2723.8444824219 + 860, 15.300762176514 );
		vehicle_rotation = Vector3( 0, 0, 0 );
	};

	[137] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( -816.94000244141, 2739.25 + 860, 15.503887176514 );
		parking_position = Vector3( -816.87939453125, 2734.2885742188 + 860, 15.503887176514 );
		vehicle_position = Vector3( -809.96630859375, 2739.6357421875 + 860, 15.300762176514 );
		vehicle_rotation = Vector3( 0, 0, 0 );
	};

	[138] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( -816.51544189453, 2754.8303222656 + 860, 15.503887176514 );
		parking_position = Vector3( -816.43011474609, 2749.9523925781 + 860, 15.503887176514 );
		vehicle_position = Vector3( -810.03106689453, 2755.5620117188 + 860, 15.300762176514 );
		vehicle_rotation = Vector3( 0, 0, 0 );
	};

	[139] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( -816.29327392578, 2770.7607421875 + 860, 15.503887176514 );
		parking_position = Vector3( -816.53247070313, 2765.763671875 + 860, 15.503887176514 );
		vehicle_position = Vector3( -809.84204101563, 2771.0744628906 + 860, 15.300762176514 );
		vehicle_rotation = Vector3( 0, 0, 270 );
	};

	[140] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( -998.95367431641, 2633.7023925781 + 860, 15.523909568787 );
		parking_position = Vector3( -1004.6456298828, 2633.5134277344 + 860, 15.523909568787 );
		vehicle_position = Vector3( -998.79388427734, 2619.5239257813 + 860, 15.336262702942 );
		vehicle_rotation = Vector3( 0, 0, 90 );
	};

	[141] = {
		class = 3;
		max_count = 20;

		enter_position = Vector3( -969.65997314453, 2635.8701171875 + 860, 15.664213180542 );
		parking_position = Vector3( -965.85852050781, 2635.1789550781 + 860, 15.531575202942 );
		vehicle_position = Vector3( -969.85083007813, 2629.9382324219 + 860, 15.328450202942 );
		vehicle_rotation = Vector3( 0, 0, 270 );
	};

	[142] = {
		class = 3;
		max_count = 20;

		enter_position = Vector3( -958.13000488281, 2636.0900878906 + 860, 15.664213180542 );
		parking_position = Vector3( -961.90307617188, 2635.3366699219 + 860, 15.531575202942 );
		vehicle_position = Vector3( -958.05798339844, 2630.2272949219 + 860, 15.328450202942 );
		vehicle_rotation = Vector3( 0, 0, 270 );
	};

	[143] = {
		class = 3;
		max_count = 50;

		enter_position = Vector3( -1258.0953369141, 2856.9948730469 + 860, 16.335548400879 );
		parking_position = Vector3( -1257.9989013672, 2849.8796386719 + 860, 15.327951431274 );
		vehicle_position = Vector3( -1269.4271240234, 2876.486328125 + 860, 15.135149002075 );
		vehicle_rotation = Vector3( 0, 0, 90 );
	};

	[144] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( -1394.3900146484, 2710 + 860, 15.467325210571 );
		parking_position = Vector3( -1394.6983642578, 2704.9035644531 + 860, 15.467325210571 );
		vehicle_position = Vector3( -1399.9011230469, 2710.3815917969 + 860, 15.467325210571 );
		vehicle_rotation = Vector3( 0, 0, 0 );
	};

	[145] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( -1394.4548339844, 2725.7788085938 + 860, 15.467325210571 );
		parking_position = Vector3( -1394.4888916016, 2720.4313964844 + 860, 15.467325210571 );
		vehicle_position = Vector3( -1399.4860839844, 2725.8720703125 + 860, 15.467325210571 );
		vehicle_rotation = Vector3( 0, 0, 0 );
	};

	[146] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( -1394.7352294922, 2694.5319824219 + 860, 15.460796356201 );
		parking_position = Vector3( -1394.5914306641, 2688.9475097656 + 860, 15.460796356201 );
		vehicle_position = Vector3( -1399.7673339844, 2694.5812988281 + 860, 15.460796356201 );
		vehicle_rotation = Vector3( 0, 0, 0 );
	};

	[147] = {
		class = 3;
		max_count = 30;

		enter_position = Vector3( -1394.373046875, 2678.9533691406 + 860, 15.467325210571 );
		parking_position = Vector3( -1394.3022460938, 2673.3498535156 + 860, 15.467325210571 );
		vehicle_position = Vector3( -1399.6989746094, 2678.689453125 + 860, 15.467325210571 );
		vehicle_rotation = Vector3( 0, 0, 0 );
	};

	-- Апартаменты сити
	[148] = 
	{
		class = 8;
		max_count = 10;

		enter_position = Vector3( 2075, 2556.81, 8.31 );
		parking_position = Vector3( 2068.737, 2557.924 + 860, 8.307 );
		vehicle_position = Vector3( 2068.653, 2549.869 + 860, 8 );
		vehicle_rotation = Vector3( 0, 0, 240 );
	};

	[149] = 
	{
		class = 8;
		max_count = 10;

		enter_position = Vector3( { x = 2063.47, y = 2564.65 + 860, z = 8.31 } );
		parking_position = Vector3( 2059.251, 2566.115, 8.310 );
		vehicle_position = Vector3( 2054.333, 2562.330, 8 );
		vehicle_rotation = Vector3( 0, 0, 222 );
	};

	[150] = 
	{
		class = 8;
		max_count = 10;

		enter_position = Vector3( { x = 2066.86, y = 2631.51, z = 8.31 } );
		parking_position = Vector3( 2071.539, 2635.848, 8.31 );
		vehicle_position = Vector3( 2069.113, 2639.781, 7.663 );
		vehicle_rotation = Vector3( 0, 0, 117.164 );
	};

	[151] = 
	{
		class = 8;
		max_count = 10;

		enter_position = Vector3( { x = 2079.27, y = 2637.95, z = 8.31 } );
		parking_position = Vector3( 2082.485, 2640.188, 8.31 );
		vehicle_position = Vector3( 2078.496, 2643.972, 7.661 );
		vehicle_rotation = Vector3( 0, 0, 106.007 );
	};

	[152] = 
	{
		class = 8;
		max_count = 10;

		enter_position = Vector3( { x = 2361.22, y = 2524.03, z = 8.25 } );
		parking_position = Vector3( 2358.189, 2527.258, 8.238 );
		vehicle_position = Vector3( 2357.225, 2520.618, 7.661 );
		vehicle_rotation = Vector3( 0, 0, 223 );
	};

	[153] = 
	{
		class = 8;
		max_count = 10;

		enter_position = Vector3( { x = 2434.43, y = 2416.92, z = 8.07 } );
		parking_position = Vector3( 2436.211, 2413.515, 8.072 );
		vehicle_position = Vector3( 2441.144, 2422.395, 7.656 );
		vehicle_rotation = Vector3( 0, 0, 294 );
	};

	[154] = 
	{
		class = 8;
		max_count = 10;

		enter_position = Vector3( { x = 2379, y = 2394.04, z = 8.08 } );
		parking_position = Vector3( 2377.219, 2397.211, 8.076 );
		vehicle_position = Vector3( 2379.336, 2385.508, 7.666 );
		vehicle_rotation = Vector3( 0, 0, 75 );
	};

	[155] = 
	{
		class = 8;
		max_count = 10;

		enter_position = Vector3( { x = 2106.424, y = 2359.897, z = 8.954 } );
		parking_position = Vector3( 2099.497, 2363.799, 8.075 );
		vehicle_position = Vector3( 2101.365, 2353.838, 7.663 );
		vehicle_rotation = Vector3( 0, 0, 96 );
	};

	[156] = 
	{
		class = 8;
		max_count = 10;

		enter_position = Vector3( { x = 2115.359, y = 2339.240, z = 8.960 } );
		parking_position = Vector3( 2109.451, 2342.522, 8.072 );
		vehicle_position = Vector3( 2111.707, 2333.407, 7.665 );
		vehicle_rotation = Vector3( 0, 0, 94 );
	};

	[157] = 
	{
		class = 8;
		max_count = 10;

		enter_position = Vector3( { x = 2181.05, y = 2292.42, z = 8.08 } );
		parking_position = Vector3( 2178.941, 2296.108, 8.072 );
		vehicle_position = Vector3( 2180.392, 2284.166, 7.665 );
		vehicle_rotation = Vector3( 0, 0, 104 );
	};

	[158] = 
	{
		class = 8;
		max_count = 10;

		enter_position = Vector3( { x = 2153.33, y = 2360.94, z = 8.08 } );
		parking_position = Vector3( 2155.978, 2357.85, 8.1 );
		vehicle_position = Vector3( 2166.898, 2365.144, 7.461 );
		vehicle_rotation = Vector3( 0, 0, 293 );
	};

	[159] = 
	{
		class = 8;
		max_count = 10;

		enter_position = Vector3( { x = 2146.07, y = 2377.45, z = 8.08 } );
		parking_position = Vector3( 2147.845, 2373.251, 8.1 );
		vehicle_position = Vector3( 2157.007, 2386.189, 7.461 );
		vehicle_rotation = Vector3( 0, 0, 294 );
	};

	[160] = 
	{
		class = 8;
		max_count = 10;

		enter_position = Vector3( { x = 2223.35, y = 2311.19, z = 8.08 } );
		parking_position = Vector3( 2224.465, 2307.48, 8.076 );
		vehicle_position = Vector3( 2224.155, 2317.983, 7.662 );
		vehicle_rotation = Vector3( 0, 0, 266 );
	};

	[161] = 
	{
		class = 8;
		max_count = 10;

		enter_position = Vector3( { x = 2430.38, y = 2347.59, z = 9.07 } );
		parking_position = Vector3( 2426.026, 2345.92, 9.074 );
		vehicle_position = Vector3( 2421.402, 2335.791, 7.666 );
		vehicle_rotation = Vector3( 0, 0, 224 );
	};

	[162] = 
	{
		class = 8;
		max_count = 10;

		enter_position = Vector3( { x = 2426.35, y = 2497.59, z = 8.26 } );
		parking_position = Vector3( 2422.878, 2493.584, 8.072 );
		vehicle_position = Vector3( 2434.895, 2493.65, 7.662 );
		vehicle_rotation = Vector3( 0, 0, 293 );
	};
}

CONST_METERING_DEVICE_TYPE = {
    NOT_METER = 0,
    LOW       = 1,
    MEDIUM    = 2,
    HIGH      = 3,
}

DEFAULT_METERING_DEVICE_FACTOR = {
    [ CONST_METERING_DEVICE_TYPE.NOT_METER ] = 1,
    [ CONST_METERING_DEVICE_TYPE.LOW       ] = 0.9,
    [ CONST_METERING_DEVICE_TYPE.MEDIUM    ] = 0.8,
    [ CONST_METERING_DEVICE_TYPE.HIGH      ] = 0.65
}