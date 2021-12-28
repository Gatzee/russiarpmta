VIP_HOUSES_LIST = 
{
	{
		hid = "vh1",
		name = "Вилла 'Око'",
		cost = 50000000,
		daily_cost = 169990,
		parking_slots = 10,
		clothing_slots = 15,
		class = "Вилла",
		village_class = 3,
		dropoff_days = -30,

		parking_marker_position = { x = 1320.38, y = -716.902 +860, z = 15.45, interior = 0, dimension = 0 },
		sell_marker_position = { x = 1300.258, y = -734.934 +860, z = 14.972, interior = 0, dimension = 0 },
		control_marker_position = { x = 1311.541, y = -747.747 +860, z = 19.16, interior = 0, dimension = 0 },

		bed_position = { 
			{ x = 1300.981, y = -726.156 +860, z = 19.648, r = 0 }, 
			{ x = 1300.981, y = -727.256 +860, z = 19.648, r = 0 }, 
		},
		
		wardrobe_position = { x = 1306.467, y = -725.474 +860, z = 19.169 };
		wardrobe_camera_position = { x = 1303.492, y = -727.751 +860, z = 19.183 };
		wardrobe_camera_target = { x = 1306.467, y = -725.474 +860, z = 19.169 };
		wardrobe_ped_position = { x = 1306.467, y = -725.474 +860, z = 19.169 };
		wardrobe_ped_rotation = 130;

		cooking_position = { x = 1302.28, y = -725.299 +860, z = 14.981 };

		reset_position = { x = 1301.824, y = -844.459 +860, z = 14.206 },
		spawn_position = { x = 1308.567, y = -745.412 +860, z = 19.175 },

		inventory_position = { x = 1305.354, y = -740.221 +860, z = 14.981 },

		-- card_game_position = { x = 1311.648, y = -750.866, z = 14.991 },

		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 1050000, reduction = 15000 },
			{ name = "Новая частная охрана", cost = 1400000, reduction = 25000 },
			{ name = "Новый дворецкий", cost = 1750000, reduction = 35000 },
		},

		client_create = function( self )
			-- Бассейн
			Water( 
			    1305, -781 +860, 13.7,
			    1315, -781 +860, 13.7,
			    1305, -764 +860, 13.7,
			    1315, -764 +860, 13.7,
			    false
			)

			-- Джакузи
			Water( 
			    1308, -722 +860, 14,
			    1315, -722 +860, 14,
			    1308, -718 +860, 14,
			    1313, -718 +860, 14,
			    true
			)
		end,

		server_create = function( self )
		end,

		doors = 
		{
			{
		        model = 17303,
		        x = 1312.66, y = -759.864 +860, z = 15.481,
		        rz = 0,
		        move = {
		            x = -2.3,
		        }
		    },
		    -- Сверху над основным входом
		    {
				x = 1315.09, y = -757.451 +860, z = 19.7018,
				objects = {
					{
				        model = 17305,
				        x = 1315.09, y = -757.451 +860, z = 19.7018,
				        rz = 0,
				        move = {
				            rz = 90,
				        }
				    },
				    {
				        visual = true,
				        model = 17290,
				        x = 1314.12, y = -757.451 +860, z = 19.7018,
				    },
				}
		    },

		    -- Дверь слева от дома
		    {
		        model = 17297,
		        x = 1302.12, y = -737.484 +860, z = 15.4803,
		        rz = 0,
		        move = {
		            y = 2,
		        }
		    },

		    -- Дверь-жалюзи слева от дома
		    {
		        model = 17292,
		        x = 1299, y = -727.362 +860, z = 15.481,
		        rz = 0,
		        move = {
		            y = 1.1,
		        }
		    },

		    -- Дверь сзади над гаражом
		    {
		        model = 17294,
		        x = 1311.15, y = -723.719 +860, z = 19.7679,
		        rz = 0,
		        move = {
		            x = 2.5,
		        }
		    },

		    -- Балкон
		    {
		        model = 17298,
		        x = 1316.95, y = -737.763 +860, z = 19.7018,
		        rz = 0,
		        move = {
		            y = 2,
		        }
		    },


		    ----------------------
		    -- Внутренние двери

		    -- 2 этаж, Первая
		    {
		        model = 17302,
		        visual = true,
		        x = 1315.13, y = -750.18 +860, z = 19.4754,
		        rz = 0,
		        move = {
		            rz = 90,
		        }
		    },
		    {
		        model = 17304,
		        x = 1313.98, y = -750.18 +860, z = 19.4754,
		        rz = 0,
		        move = {
		            rz = 90,
		        }
		    },

		    -- 2 этаж Слева
		    {
		        model = 17301,
		        x = 1313.64, y = -743.232 +860, z = 19.4754,
		        rz = 0,
		        move = {
		            rz = 90,
		        }
		    },

		    -- 2 этаж Вторая слева
		    {
		        model = 17295,
		        x = 1308.58, y = -730.47 +860, z = 19.4754,
		        rz = 0,
		        radius = 1.7,
		        move = {
		            rz = 90,
		        }
		    },

		    -- 2 этаж Туалет
		    {
		        model = 17300,
		        x = 1307.44, y = -742.133 +860, z = 19.4754,
		        rz = 0,
		        move = {
		            rz = 90,
		        }
		    },

		    -- 2 этаж Еще один туалет
		    {
		        model = 17296,
		        x = 1306.36, y = -733.354 +860, z = 19.4754,
		        rz = 0,
		        radius = 1.7,
		        move = {
		            rz = -90,
		        }
		    },

		    -- 1 этаж В гараж
		    {
		        model = 17293,
		        x = 1316.33, y = -722.808 +860, z = 15.7574,
		        rz = 0,
		        move = {
		            rz = -90,
		        }
		    },

		    -- 1 этаж Ванная
		    {
		        model = 17299,
		        x = 1316.68, y = -739.567 +860, z = 15.2972,
		        rz = 0,
		        move = {
		            rz = -90,
		        }
		    },

		    -- Входные ворота
		    {
		        x = 1290.728, y = -837.295 +860, z = 14.972,
		        radius = 10,
		        duration = 2500,
		        radial_enabled = true,
		        name = "Ворота",
		        vehicle_allowed = true,
		        objects = {
			        {
						x = 1287.5, y = -837.45 +860, z = 15.42,
				        rz = 180,
				        model = 10856,
				        move = {
				            rz = -110,
				        },
				    },
				    {
						x = 1293.95, y = -837.45 +860, z = 15.42,
				        rz = 0,
				        model = 10856,
				        move = {
				            rz = 110,
				        },
					},
				},
		    },

		    -- Гараж
		    {
		        x = 1314.77, y = -715.692 +860, z = 14,
		        objects =
		        {
					{
						x = 1314.77, y = -715.692 +860, z = 15.8099,
						rz = 90,
						model = 2933,
						move = {
				            z = 2.3,
				            ry = 90,
				        },
				    },
				},
		        duration = 2000,
		        radius = 6,
		        name = "Гараж",
		        vehicle_allowed = true,
		        radial_enabled = true,
		    },
		},
	},

	{
		hid = "cottage1",
		name = "Коттедж 1",
		cost = 9000000,
		daily_cost = 19900,
		parking_slots = 7,
		clothing_slots = 11,
		class = "Уникальный (5-ый)",
		cottage_class = 5,
		apartments_class = 4,
		dropoff_days = -21,
	
		parking_marker_position = { x = -2055.822, y = 395.411 +860, z = 17.33, interior = 0, dimension = 0, rot = 326.145 },
		sell_marker_position = { x = -2064.288, y = 400.493 +860, z = 18.419 },
		enter_marker_position = { x = -2064.288, y = 400.493 +860, z = 18.419 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 220500, reduction = 3374 },
			{ name = "Новая частная охрана", cost = 252000, reduction = 5620 },
			{ name = "Новый дворецкий", cost = 283500, reduction = 6747 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage2",
		name = "Коттедж 2",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 10,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
	
		parking_marker_position = { x = 2270.418, y = -1181.401 +860, z = 60.785, interior = 0, dimension = 0, rot = 340.778 },
		sell_marker_position = { x = 2253.652, y = -1188.854 +860, z = 61.777 },
		enter_marker_position = { x = 2253.652, y = -1188.854 +860, z = 61.777 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 112500, reduction = 1700 },
			{ name = "Новая частная охрана", cost = 150000, reduction = 3300 },
			{ name = "Новый дворецкий", cost = 187500, reduction = 4375 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage3",
		name = "Коттедж 3",
		cost = 4500000,
		daily_cost = 10990,
		parking_slots = 4,
		clothing_slots = 8,
		class = "Средний (2-ый)",
		cottage_class = 2,
		apartments_class = 4,
		dropoff_days = -21,
	
		parking_marker_position = { x = 2211.958, y = -1153.283 +860, z = 60.662, interior = 0, dimension = 0, rot = 67 },
		sell_marker_position = { x = 2228.91, y = -1155.47 +860, z = 60.881 },
		enter_marker_position = { x = 2228.91, y = -1155.47 +860, z = 60.881 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 67500, reduction = 1000 },
			{ name = "Новая частная охрана", cost = 90000, reduction = 2000 },
			{ name = "Новый дворецкий", cost = 112500, reduction = 2625 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage4",
		name = "Коттедж 4",
		cost = 2500000,
		daily_cost = 6290,
		parking_slots = 3,
		clothing_slots = 4,
		class = "Низкий (1-ый)",
		cottage_class = 1,
		apartments_class = 4,
		dropoff_days = -21,
	
		parking_marker_position = { x = 2230.042, y = -1107.307 +860, z = 60.741, interior = 0, dimension = 0, rot = 67 },
		sell_marker_position = { x = 2242.517, y = -1116.881 +860, z = 60.969 },
		enter_marker_position = { x = 2242.517, y = -1116.881 +860, z = 60.969 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 37500, reduction = 575 },
			{ name = "Новая частная охрана", cost = 50000, reduction = 1115 },
			{ name = "Новый дворецкий", cost = 62500, reduction = 1435 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage5",
		name = "Коттедж 5",
		cost = 6000000,
		daily_cost = 14490,
		parking_slots = 5,
		clothing_slots = 9,
		class = "Высокий (3-ый)",
		cottage_class = 3,
		apartments_class = 4,
		dropoff_days = -21,
	
		parking_marker_position = { x = 2007.896, y = -243.503 +860, z = 60.435, interior = 0, dimension = 0, rot = 140.615 },
		sell_marker_position = { x = 2020.558, y = -246.831 +860, z = 60.588 },
		enter_marker_position = { x = 2020.558, y = -246.831 +860, z = 60.588 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 90000, reduction = 1400 },
			{ name = "Новая частная охрана", cost = 120000, reduction = 2550 },
			{ name = "Новый дворецкий", cost = 150000, reduction = 3550 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage6",
		name = "Коттедж 6",
		cost = 6000000,
		daily_cost = 14490,
		parking_slots = 5,
		clothing_slots = 9,
		class = "Высокий (3-ый)",
		cottage_class = 3,
		apartments_class = 4,
		dropoff_days = -21,
	
		parking_marker_position = { x = 1956.457, y = -273.071 +860, z = 60.404, interior = 0, dimension = 0, rot = 318.5 },
		sell_marker_position = { x = 1937.642, y = -271.765 +860, z = 60.405 },
		enter_marker_position = { x = 1937.642, y = -271.765 +860, z = 60.405 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 147000, reduction = 2249 },
			{ name = "Новая частная охрана", cost = 168000, reduction = 3746 },
			{ name = "Новый дворецкий", cost = 189000, reduction = 4498 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "villa1",
		name = "Вилла 1",
		cost = 15000000,
		daily_cost = 49990,
		parking_slots = 8,
		clothing_slots = 15,
		class = "Вилла",
		village_class = 1,
		dropoff_days = -30,
		img = "vh2",

		relative_center = { x = 16.469, y = -454.486 +860, z = 20.732, rx = 0, ry = 0, rz = 0 },

		parking_marker_position = { x = -7.777, y = -447.422 +860, z = 21.1, interior = 0, dimension = 0, rot = 180 },
		sell_marker_position = { x = 29.994, y = -451.209 +860, z = 20.733, interior = 0, dimension = 0 },
		control_marker_position = { x = 3.658, y = -460.845 +860, z = 20.721, interior = 0, dimension = 0 },

		bed_position = { { x = 14.457, y = -454.515 +860, z = 21.121, r = 270 }, { x = 21.078, y = -451.543, z = 21.121, r = 0 }, },

		wardrobe_position = { x = 8.809, y = -451.958 +860, z = 20.732 };
		wardrobe_camera_position = { x = 10.955, y = -456.203 +860, z = 20.721 };
		wardrobe_camera_target = { x = 8.809, y = -451.958 +860, z = 20.732 };
		wardrobe_ped_position = { x = 8.809, y = -451.958 +860, z = 20.732 };
		wardrobe_ped_rotation = 212;

		cooking_position = { x = -0.1, y = -462.11 +860, z = 20.721 },

		inventory_position = { x = 11.820, y = -459.818 +860, z = 20.733 },

		-- card_game_position = { x = 20.323, y = -454.911, z = 20.7 },

		reset_position = { x = 0.662, y = -478.892 +860, z = 20.698 },
		spawn_position = { x = 23.636, y = -454.215 +860, z = 20.74 },

		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 315000, reduction = 5000 },
			{ name = "Новая частная охрана", cost = 420000, reduction = 9000 },
			{ name = "Новый дворецкий", cost = 525000, reduction = 12250 },
		},

		client_create = function( self )
		end,

		server_create = function( self )
		end,

		doors =
		{
			{
		        model = 17303,
		        x = 27.6, y = -454.128 +860, z = 20.732,
		        rz = 90,
		        move = {
		            y = -2,
		            rz = 0,
		        }
		    },

		    -- Дверь слева от дома
		    {
		        model = 17294,
		        x = 10.2, y = -462.454 +860, z = 20.732,
		        rz = 0,
		        move = {
		            x = 2,
		            rz = 0,
		        }
		    },

		    -- Входные ворота
		    {
		        x = -7.582, y = -475.536 +860, z = 20.733,
		        radius = 10,
		        duration = 2500,
		        radial_enabled = true,
		        name = "Ворота",
		        vehicle_allowed = true,
		        objects = {
			        {
						x = -10.1, y = -475.516 +860, z = 20.733,
				        rz = 90,
				        model = 1235,
				        move = {
				            rz = 110,
				        },
				    },
				    {
						x = -4.05, y = -475.51 +860, z = 20.733,
				        rz = -90,
				        model = 1235,
				        move = {
				            rz = -110,
				        },
					},
				},
		    },

		    -- Гараж
		    {
		        x = -7.696, y = -452.487 +860, z = 21.098,
		        objects =
		        {
					{
						x = -7.6, y = -452.397 +860, z = 21.098,
						rz = 90,
						model = 17291,
						move = {
				            z = 1.4,
				            y = 1.5,
				            ry = 80,
				            rz = 0,
				        },
				    },
				},
		        duration = 2000,
		        radius = 6,
		        name = "Гараж",
		        vehicle_allowed = true,
		        radial_enabled = true,
		    },
		},
	},

	{
		hid = "villa2",
		name = "Вилла 2",
		cost = 15000000,
		daily_cost = 49990,
		parking_slots = 8,
		clothing_slots = 15,
		class = "Вилла",
		village_class = 1,
		dropoff_days = -30,
		relative = "villa1",
	
		relative_center = { x = 32.799, y = -401.034 +860, z = 20.732, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "villa3",
		name = "Вилла 3",
		cost = 15000000,
		daily_cost = 49990,
		parking_slots = 8,
		clothing_slots = 15,
		class = "Вилла",
		village_class = 1,
		dropoff_days = -30,
		relative = "villa1",
	
		relative_center = { x = 63.537, y = -296.802 +860, z = 20.732, rx = 0, ry = 0, rz = -22.8 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "villa4",
		name = "Вилла 4",
		cost = 20000000,
		daily_cost = 69990,
		parking_slots = 9,
		clothing_slots = 15,
		class = "Вилла",
		village_class = 2,
		dropoff_days = -30,
		img = "vh3",
		relative = "villa1",
	
		relative_center = { x = 13.769, y = -512.323 +860, z = 20.74, rx = 0, ry = 0, rz = 0 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 420000, reduction = 6500 },
			{ name = "Новая частная охрана", cost = 560000, reduction = 12000 },
			{ name = "Новый дворецкий", cost = 700000, reduction = 16500 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "villa5",
		name = "Вилла 5",
		cost = 20000000,
		daily_cost = 69990,
		parking_slots = 9,
		clothing_slots = 15,
		class = "Вилла",
		village_class = 2,
		dropoff_days = -30,
		img = "vh3",
		relative = "villa1",
	
		relative_center = { x = 27.594, y = -576.046 +860, z = 20.74, rx = 0, ry = 0, rz = 17.4 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 420000, reduction = 6500 },
			{ name = "Новая частная охрана", cost = 560000, reduction = 12000 },
			{ name = "Новый дворецкий", cost = 700000, reduction = 16500 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "villa6",
		name = "Вилла 6",
		cost = 15000000,
		daily_cost = 49990,
		parking_slots = 8,
		clothing_slots = 15,
		class = "Вилла",
		village_class = 1,
		dropoff_days = -30,
		relative = "villa1",
	
		relative_center = { x = 295.721, y = -668.707 +860, z = 20.732, rx = 0, ry = 0, rz = 95 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "villa7",
		name = "Вилла 7",
		cost = 15000000,
		daily_cost = 49990,
		parking_slots = 8,
		clothing_slots = 15,
		class = "Вилла",
		village_class = 1,
		dropoff_days = -30,
		relative = "villa1",
	
		relative_center = { x = 100.35, y = -242.448 +860, z = 20.732, rx = 0, ry = 0, rz = -40.2 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "villa8",
		name = "Вилла 8",
		cost = 15000000,
		daily_cost = 49990,
		parking_slots = 8,
		clothing_slots = 15,
		class = "Вилла",
		village_class = 1,
		dropoff_days = -30,
		relative = "villa1",
	
		relative_center = { x = 143.691, y = -202.083 +860, z = 20.732, rx = 0, ry = 0, rz = -50 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "villa9",
		name = "Вилла 9",
		cost = 15000000,
		daily_cost = 49990,
		parking_slots = 8,
		clothing_slots = 15,
		class = "Вилла",
		village_class = 1,
		dropoff_days = -30,
		relative = "villa1",
	
		relative_center = { x = 186.739, y = -169.682 +860, z = 20.73, rx = 0, ry = 0, rz = -53.7 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "villa10",
		name = "Вилла 10",
		cost = 15000000,
		daily_cost = 49990,
		parking_slots = 8,
		clothing_slots = 15,
		class = "Вилла",
		village_class = 1,
		dropoff_days = -30,
		relative = "villa1",
	
		relative_center = { x = 37.528, y = -641.52 +860, z = 20.732, rx = 0, ry = 0, rz = 35.5 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "villa11",
		name = "Вилла 11",
		cost = 20000000,
		daily_cost = 69990,
		parking_slots = 9,
		clothing_slots = 15,
		class = "Вилла",
		village_class = 2,
		dropoff_days = -30,
		img = "vh3",
		relative = "villa1",
	
		relative_center = { x = 111.385, y = -670.746 +860, z = 20.74, rx = 0, ry = 0, rz = 69 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 420000, reduction = 6500 },
			{ name = "Новая частная охрана", cost = 560000, reduction = 12000 },
			{ name = "Новый дворецкий", cost = 700000, reduction = 16500 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "villa12",
		name = "Вилла 12",
		cost = 20000000,
		daily_cost = 69990,
		parking_slots = 9,
		clothing_slots = 15,
		class = "Вилла",
		village_class = 2,
		dropoff_days = -30,
		img = "vh3",
		relative = "villa1",
	
		relative_center = { x = 181.501, y = -675.829 +860, z = 20.74, rx = 0, ry = 0, rz = 90 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 420000, reduction = 6500 },
			{ name = "Новая частная охрана", cost = 560000, reduction = 12000 },
			{ name = "Новый дворецкий", cost = 700000, reduction = 16500 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "villa13",
		name = "Вилла 13",
		cost = 20000000,
		daily_cost = 69990,
		parking_slots = 9,
		clothing_slots = 15,
		class = "Вилла",
		village_class = 2,
		dropoff_days = -30,
		img = "vh3",
		relative = "villa1",
	
		relative_center = { x = 237.465, y = -674.079 +860, z = 20.74, rx = 0, ry = 0, rz = 93.7 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 420000, reduction = 6500 },
			{ name = "Новая частная охрана", cost = 560000, reduction = 12000 },
			{ name = "Новый дворецкий", cost = 700000, reduction = 16500 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "villa14",
		name = "Вилла 14",
		cost = 15000000,
		daily_cost = 49990,
		parking_slots = 8,
		clothing_slots = 15,
		class = "Вилла",
		village_class = 1,
		dropoff_days = -30,
		relative = "villa1",
	
		relative_center = { x = 352.924, y = -662.419 +860, z = 20.732, rx = 0, ry = 0, rz = 94.5 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "cottage41",
		name = "Коттедж 41",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		img = "cottage4_2",
	
		relative_center = { x = 490.931, y = -527.052 +860, z = 21.736, rx = 0, ry = 0, rz = 0 },
	
		parking_marker_position = { x = 490.841, y = -518.007 +860, z = 20.975, interior = 0, dimension = 0, rot = 326.145 },
		sell_marker_position = { x = 489.777, y = -525.831 +860, z = 21.736 },
		enter_marker_position = { x = 489.777, y = -525.831 +860, z = 21.736 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 112500, reduction = 1700 },
			{ name = "Новая частная охрана", cost = 150000, reduction = 3300 },
			{ name = "Новый дворецкий", cost = 187500, reduction = 4375 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage42",
		name = "Коттедж 42",
		cost = 7500000,
		daily_cost = 17790,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		img = "cottage4_2",
	
		relative_center = { x = 521.417, y = -526.992 +860, z = 21.732, rx = 0, ry = 0, rz = 0 },
	
		parking_marker_position = { x = 520.403, y = -517.486 +860, z = 20.939, interior = 0, dimension = 0, rot = 326.145 },
		sell_marker_position = { x = 520.3, y = -525.341 +860, z = 21.732 },
		enter_marker_position = { x = 520.3, y = -525.341 +860, z = 21.732 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 112500, reduction = 1700 },
			{ name = "Новая частная охрана", cost = 150000, reduction = 3300 },
			{ name = "Новый дворецкий", cost = 187500, reduction = 4375 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage43",
		name = "Коттедж 43",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage42",
	
		relative_center = { x = 494.258, y = -559.807 +860, z = 21.732, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage44",
		name = "Коттедж 44",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage42",
	
		relative_center = { x = 562.435, y = -559.807 +860, z = 21.732, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage45",
		name = "Коттедж 45",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage41",
	
		relative_center = { x = 592.908, y = -559.772 +860, z = 21.736, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage46",
		name = "Коттедж 46",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage42",
	
		relative_center = { x = 589.57, y = -526.992 +860, z = 21.732, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage47",
		name = "Коттедж 47",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage42",
	
		relative_center = { x = 593.126, y = -306.435 +860, z = 21.736, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage48",
		name = "Коттедж 48",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage41",
	
		relative_center = { x = 623.612, y = -306.386 +860, z = 21.732, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage49",
		name = "Коттедж 49",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage41",
	
		relative_center = { x = 596.459, y = -339.19 +860, z = 21.732, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage50",
		name = "Коттедж 50",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage41",
	
		relative_center = { x = 664.627, y = -339.191 +860, z = 21.732, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage51",
		name = "Коттедж 51",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage42",
	
		relative_center = { x = 695.107, y = -339.144 +860, z = 21.736, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage52",
		name = "Коттедж 52",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage42",
	
		relative_center = { x = 691.77, y = -306.377 +860, z = 21.732, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "cottage53",
		name = "Коттедж 53",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage41",
	
		relative_center = { x = 547.075, y = -214.486 +860, z = 21.732, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage54",
		name = "Коттедж 54",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		img = "cottage4_2",
	
		relative_center = { x = 614.761, y = -206.414 +860, z = 21.732, rx = 0, ry = 0, rz = 0 },
	
		parking_marker_position = { x = 616.8534, y = -216.7295 +860, z = 20.9357, interior = 0, dimension = 0, rot = 326.145 },
		sell_marker_position = { x = 615.915, y = -207.34 +860, z = 21.732 },
		enter_marker_position = { x = 615.915, y = -207.34 +860, z = 21.732 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 112500, reduction = 1700 },
			{ name = "Новая частная охрана", cost = 150000, reduction = 3300 },
			{ name = "Новый дворецкий", cost = 187500, reduction = 4375 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage55",
		name = "Коттедж 55",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage42",
	
		relative_center = { x = 645.243, y = -202.721 +860, z = 21.736, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage56",
		name = "Коттедж 56",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage41",
	
		relative_center = { x = 639.967, y = -152.752 +860, z = 21.736, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage57",
		name = "Коттедж 57",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage41",
	
		relative_center = { x = 609.463, y = -152.796 +860, z = 21.732, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage58",
		name = "Коттедж 58",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage41",
	
		relative_center = { x = 541.305, y = -152.809 +860, z = 21.732, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage59",
		name = "Коттедж 59",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage41",
	
		relative_center = { x = 538.355, y = -119.713 +860, z = 21.736, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage60",
		name = "Коттедж 60",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage42",
	
		relative_center = { x = 568.5, y = -119.989 +860, z = 21.732, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage61",
		name = "Коттедж 61",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage41",
	
		relative_center = { x = 636.66, y = -119.986 +860, z = 21.732, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage62",
		name = "Коттедж 62",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -15,
		img = "cottage4_2",
	
		relative_center = { x = 620.111, y = -251.177 +860, z = 21.732, rx = 0, ry = 0, rz = 0 },
	
		parking_marker_position = { x = 619.847, y = -240.979 +860, z = 20.935, interior = 0, dimension = 0, rot = 326.145 },
		sell_marker_position = { x = 620.985, y = -249.579 +860, z = 21.738 },
		enter_marker_position = { x = 620.985, y = -249.579 +860, z = 21.738 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 112500, reduction = 1700 },
			{ name = "Новая частная охрана", cost = 150000, reduction = 3300 },
			{ name = "Новый дворецкий", cost = 187500, reduction = 4375 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage63",
		name = "Коттедж 63",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage62",
	
		relative_center = { x = 552.429, y = -259.243 +860, z = 21.732, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage64",
		name = "Коттедж 64",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage62",
	
		relative_center = { x = 673.905, y = -74.044 +860, z = 21.732, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage65",
		name = "Коттедж 65",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage62",
	
		relative_center = { x = 650.531, y = -247.466 +860, z = 21.728, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage66",
		name = "Коттедж 66",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage42",
	
		relative_center = { x = 643.857, y = -74.421 +860, z = 21.736, rx = 0, ry = 0, rz = 90 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "cottage67",
		name = "Коттедж 67",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage62",
	
		relative_center = { x = 640.814, y = -526.983 +860, z = 21.732, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage68",
		name = "Коттедж 68",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage62",
	
		relative_center = { x = 708.969, y = -526.99 +860, z = 21.732, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage69",
		name = "Коттедж 69",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage62",
	
		relative_center = { x = 739.453, y = -527.049 +860, z = 21.728, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage70",
		name = "Коттедж 70",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage62",
	
		relative_center = { x = 736.125, y = -559.808 +860, z = 21.732, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage71",
		name = "Коттедж 71",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage62",
	
		relative_center = { x = 667.944, y = -559.812 +860, z = 21.732, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage72",
		name = "Коттедж 72",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage62",
	
		relative_center = { x = 637.466, y = -559.773 +860, z = 21.728, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage73",
		name = "Коттедж 73",
		cost = 9000000,
		daily_cost = 19990,
		parking_slots = 7,
		clothing_slots = 11,
		class = "Элитный (5-ый)",
		cottage_class = 5,
		apartments_class = 5,
		dropoff_days = -15,
		img = "cottage5_2",
	
		relative_center = { x = 522.679, y = -564.208 +860, z = 21.773, rx = 0, ry = 0, rz = 0 },
	
		parking_marker_position = { x = 530.741, y = -566.647 +860, z = 20.576, interior = 0, dimension = 0, rot = 180 },
		sell_marker_position = { x = 524.447, y = -565.837 +860, z = 21.773 },
		enter_marker_position = { x = 524.447, y = -565.837 +860, z = 21.773 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 135000, reduction = 2000 },
			{ name = "Новая частная охрана", cost = 180000, reduction = 4000 },
			{ name = "Новый дворецкий", cost = 225000, reduction = 5250 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage74",
		name = "Коттедж 74",
		cost = 9000000,
		daily_cost = 19990,
		parking_slots = 7,
		clothing_slots = 11,
		class = "Элитный (5-ый)",
		cottage_class = 5,
		apartments_class = 5,
		dropoff_days = -15,
		img = "cottage5_2",
	
		relative_center = { x = 707.714, y = -564.196 +860, z = 21.773, rx = 0, ry = 0, rz = 0 },
	
		parking_marker_position = { x = 699.403, y = -566.057 +860, z = 20.575, interior = 0, dimension = 0, rot = 180 },
		sell_marker_position = { x = 706.02, y = -566.099 +860, z = 21.773 },
		enter_marker_position = { x = 706.02, y = -566.099 +860, z = 21.773 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 135000, reduction = 2000 },
			{ name = "Новая частная охрана", cost = 180000, reduction = 4000 },
			{ name = "Новый дворецкий", cost = 225000, reduction = 5250 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage75",
		name = "Коттедж 75",
		cost = 9000000,
		daily_cost = 19990,
		parking_slots = 7,
		clothing_slots = 11,
		class = "Элитный (5-ый)",
		cottage_class = 5,
		apartments_class = 5,
		dropoff_days = -21,
		relative = "cottage73",
	
		relative_center = { x = 561.165, y = -522.612 +860, z = 21.773, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage76",
		name = "Коттедж 76",
		cost = 9000000,
		daily_cost = 19990,
		parking_slots = 7,
		clothing_slots = 11,
		class = "Элитный (5-ый)",
		cottage_class = 5,
		apartments_class = 5,
		dropoff_days = -21,
		relative = "cottage73",
	
		relative_center = { x = 569.734, y = -157.181 +860, z = 21.773, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage77",
		name = "Коттедж 77",
		cost = 9000000,
		daily_cost = 19990,
		parking_slots = 7,
		clothing_slots = 11,
		class = "Элитный (5-ый)",
		cottage_class = 5,
		apartments_class = 5,
		dropoff_days = -21,
		relative = "cottage73",
	
		relative_center = { x = 576.959, y = -216.332 +860, z = 21.664, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage78",
		name = "Коттедж 78",
		cost = 9000000,
		daily_cost = 19990,
		parking_slots = 7,
		clothing_slots = 11,
		class = "Элитный (5-ый)",
		cottage_class = 5,
		apartments_class = 5,
		dropoff_days = -21,
		relative = "cottage73",
	
		relative_center = { x = 608.217, y = -115.603 +860, z = 21.773, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage79",
		name = "Коттедж 79",
		cost = 9000000,
		daily_cost = 19990,
		parking_slots = 7,
		clothing_slots = 11,
		class = "Элитный (5-ый)",
		cottage_class = 5,
		apartments_class = 5,
		dropoff_days = -21,
		relative = "cottage74",
	
		relative_center = { x = 580.105, y = -251.523 +860, z = 21.773, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage80",
		name = "Коттедж 80",
		cost = 9000000,
		daily_cost = 19990,
		parking_slots = 7,
		clothing_slots = 11,
		class = "Элитный (5-ый)",
		cottage_class = 5,
		apartments_class = 5,
		dropoff_days = -21,
		relative = "cottage73",
	
		relative_center = { x = 624.871, y = -343.577 +860, z = 21.773, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage81",
		name = "Коттедж 81",
		cost = 9000000,
		daily_cost = 19990,
		parking_slots = 7,
		clothing_slots = 11,
		class = "Элитный (5-ый)",
		cottage_class = 5,
		apartments_class = 5,
		dropoff_days = -21,
		relative = "cottage73",
	
		relative_center = { x = 663.366, y = -302 +860, z = 21.773, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage82",
		name = "Коттедж 82",
		cost = 9000000,
		daily_cost = 19990,
		parking_slots = 7,
		clothing_slots = 11,
		class = "Элитный (5-ый)",
		cottage_class = 5,
		apartments_class = 5,
		dropoff_days = -21,
		relative = "cottage74",
	
		relative_center = { x = 669.217, y = -522.607 +860, z = 21.773, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage83",
		name = "Коттедж 83",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -15,
		img = "cottage6_2",
	
		relative_center = { x = 693.909, y = -456.257 +860, z = 21.573, rx = 0, ry = 0, rz = 0 },
	
		parking_marker_position = { x = 679.36, y = -467.899 +860, z = 20.56, interior = 0, dimension = 0, rot = 180 },
		sell_marker_position = { x = 693.611, y = -457.19 +860, z = 21.573 },
		enter_marker_position = { x = 693.611, y = -457.19 +860, z = 21.573 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 172500, reduction = 2650 },
			{ name = "Новая частная охрана", cost = 230000, reduction = 5000 },
			{ name = "Новый дворецкий", cost = 287500, reduction = 6725 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage84",
		name = "Коттедж 84",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage83",
	
		relative_center = { x = 638.67, y = -610.131 +860, z = 21.573, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage85",
		name = "Коттедж 85",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage83",
	
		relative_center = { x = 727.499, y = -610.129 +860, z = 21.579, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "cottage86",
		name = "Коттедж 86",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage83",
	
		relative_center = { x = 789.059, y = -620.446 +860, z = 21.55, rx = 0, ry = 0, rz = 270 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage87",
		name = "Коттедж 87",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage83",
	
		relative_center = { x = 789.226, y = -531.557 +860, z = 21.579, rx = 0, ry = 0, rz = 270 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage88",
		name = "Коттедж 88",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage83",
	
		relative_center = { x = 754.163, y = -477.575 +860, z = 21.579, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage89",
		name = "Коттедж 89",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage83",
	
		relative_center = { x = 605.046, y = -456.257 +860, z = 21.573, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage90",
		name = "Коттедж 90",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage83",
	
		relative_center = { x = 591.71, y = -676.871 +860, z = 21.573, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage91",
		name = "Коттедж 91",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage83",
	
		relative_center = { x = 502.846, y = -676.872 +860, z = 21.573, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage92",
		name = "Коттедж 92",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -15,
		img = "cottage6_2",
	
		relative_center = { x = 638.652, y = -676.911 +860, z = 21.579, rx = 0, ry = 0, rz = 0 },
	
		parking_marker_position = { x = 653.13, y = -688.153 +860, z = 20.55, interior = 0, dimension = 0, rot = 180 },
		sell_marker_position = { x = 639.125, y = -677.691 +860, z = 21.579 },
		enter_marker_position = { x = 639.125, y = -677.691 +860, z = 21.579 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 172500, reduction = 2650 },
			{ name = "Новая частная охрана", cost = 230000, reduction = 5000 },
			{ name = "Новый дворецкий", cost = 287500, reduction = 6725 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage94",
		name = "Коттедж 94",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage92",
	
		relative_center = { x = 727.539, y = -676.872 +860, z = 21.573, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage95",
		name = "Коттедж 95",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage92",
	
		relative_center = { x = 502.837, y = -610.13 +860, z = 21.573, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage96",
		name = "Коттедж 96",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage92",
	
		relative_center = { x = 591.718, y = -610.126 +860, z = 21.579, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage97",
		name = "Коттедж 97",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage92",
	
		relative_center = { x = 693.901, y = -389.52 +860, z = 21.573, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage98",
		name = "Коттедж 98",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage92",
	
		relative_center = { x = 605.039, y = -389.519 +860, z = 21.573, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage99",
		name = "Коттедж 99",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -15,
		img = "cottage6_2",
	
		relative_center = { x = 640.997, y = -449.774 +860, z = 21.573, rx = 0, ry = 0, rz = 0 },
	
		parking_marker_position = { x = 637.6, y = -468.992 +860, z = 20.557, interior = 0, dimension = 0, rot = 180 },
		sell_marker_position = { x = 639.853, y = -449.184 +860, z = 21.573 },
		enter_marker_position = { x = 639.853, y = -449.184 +860, z = 21.573 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 172500, reduction = 2650 },
			{ name = "Новая частная охрана", cost = 230000, reduction = 5000 },
			{ name = "Новый дворецкий", cost = 287500, reduction = 6725 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage100",
		name = "Коттедж 100",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -15,
		img = "cottage6_2",
	
		relative_center = { x = 538.793, y = -617.412 +860, z = 21.573, rx = 0, ry = 0, rz = 0 },
	
		parking_marker_position = { x = 535.689, y = -596.398 +860, z = 20.554, interior = 0, dimension = 0, rot = 0 },
		sell_marker_position = { x = 538.019, y = -617.061 +860, z = 21.573 },
		enter_marker_position = { x = 538.019, y = -617.061 +860, z = 21.573 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 172500, reduction = 2650 },
			{ name = "Новая частная охрана", cost = 230000, reduction = 5000 },
			{ name = "Новый дворецкий", cost = 287500, reduction = 6725 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage101",
		name = "Коттедж 101",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage99",
	
		relative_center = { x = 538.716, y = -670.397 +860, z = 21.579, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage102",
		name = "Коттедж 102",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage99",
	
		relative_center = { x = 691.645, y = -616.62 +860, z = 21.579, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "cottage103",
		name = "Коттедж 103",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage100",
	
		relative_center = { x = 640.998, y = -396.802 +860, z = 21.573, rx = 0, ry = 0, rz = 0 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage104",
		name = "Коттедж 104",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage100",
	
		relative_center = { x = 691.659, y = -669.598 +860, z = 21.579, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage105",
		name = "Коттедж 105",
		cost = 11500000,
		daily_cost = 26990,
		parking_slots = 8,
		clothing_slots = 11,
		class = "Элитный (6-ой)",
		cottage_class = 6,
		apartments_class = 6,
		dropoff_days = -21,
		relative = "cottage99",
	
		relative_center = { x = 795.708, y = -567.454 +860, z = 21.579, rx = 0, ry = 0, rz = 270 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage106",
		name = "Коттедж 106",
		cost = 9000000,
		daily_cost = 19990,
		parking_slots = 7,
		clothing_slots = 11,
		class = "Элитный (5-ый)",
		cottage_class = 5,
		apartments_class = 5,
		dropoff_days = -15,
		img = "cottage6_2",
	
		relative_center = { x = 545.059, y = -78.887 +860, z = 21.54, rx = 0, ry = 0, rz = 0 },
	
		parking_marker_position = { x = 529.043, y = -77.396 +860, z = 20.342, interior = 0, dimension = 0, rot = 90 },
		sell_marker_position = { x = 544.345, y = -78.635 +860, z = 21.54 },
		enter_marker_position = { x = 544.345, y = -78.635 +860, z = 21.54 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 135000, reduction = 2000 },
			{ name = "Новая частная охрана", cost = 180000, reduction = 4000 },
			{ name = "Новый дворецкий", cost = 225000, reduction = 5250 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage107",
		name = "Коттедж 107",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage41",
	
		relative_center = { x = 537.418, y = -43.748 +860, z = 20.5, rx = 0, ry = 0, rz = 90 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage108",
		name = "Коттедж 108",
		cost = 7500000,
		daily_cost = 17990,
		parking_slots = 6,
		clothing_slots = 11,
		class = "Элитный (4-ый)",
		cottage_class = 4,
		apartments_class = 4,
		dropoff_days = -21,
		relative = "cottage106",
	
		relative_center = { x = 590.435, y = -25.564 +860, z = 21.54, rx = 0, ry = 0, rz = 180 },
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "cottage109",
		name = "Коттедж 109",
		cost = 9000000,
		daily_cost = 19990,
		parking_slots = 7,
		clothing_slots = 11,
		class = "Элитный (5-ый)",
		cottage_class = 5,
		apartments_class = 5,
		dropoff_days = -21,
		img = "cottage6_2",
	
		relative_center = { x = 607.0662, y = -68.2485 +860, z = 21.421, rx = 0, ry = 0, rz = 0 },
	
		parking_marker_position = { x = 614.404, y = -62.769 +860, z = 20.6978, interior = 0, dimension = 0, rot = 220 },
		sell_marker_position = { x = 607.6281, y = -58.7665 +860, z = 21.421 },
		enter_marker_position = { x = 607.0662, y = -68.4485 +860, z = 21.421 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 135000, reduction = 2000 },
			{ name = "Новая частная охрана", cost = 180000, reduction = 4000 },
			{ name = "Новый дворецкий", cost = 225000, reduction = 5250 },
		},
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "country1",
		name = "Деревенский дом 1",
		cost = 200000,
		daily_cost = 890,
		parking_slots = 2,
		clothing_slots = 1,
		class = "Деревенский дом",
		country_class = 1,
		apartments_class = 7,
		dropoff_days = -14,
	
		parking_marker_position = { x = -2067.6882, y = -973.1931 +860, z = 25.2596, interior = 0, dimension = 0, rot = 130 },
		enter_marker_position = { x = -2069.8608, y = -960.9497 +860, z = 25.6839 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 3000, reduction = 45 },
			{ name = "Новая частная охрана", cost = 4000, reduction = 88 },
			{ name = "Новый дворецкий", cost = 5000, reduction = 118 },
		},
	
		img = "country_1",
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},

	{
		hid = "country2",
		name = "Деревенский дом 2",
		cost = 200000,
		daily_cost = 890,
		parking_slots = 2,
		clothing_slots = 1,
		class = "Деревенский дом",
		country_class = 1,
		apartments_class = 7,
		dropoff_days = -14,
	
		parking_marker_position = { x = -1947.1662, y = -932.0298 +860, z = 23.934, interior = 0, dimension = 0, rot = 176 },
		enter_marker_position = { x = -1953.5042, y = -928.1714 +860, z = 24.0432 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 3000, reduction = 45 },
			{ name = "Новая частная охрана", cost = 4000, reduction = 88 },
			{ name = "Новый дворецкий", cost = 5000, reduction = 118 },
		},
	
		img = "country_1",
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "country3",
		name = "Деревенский дом 3",
		cost = 200000,
		daily_cost = 890,
		parking_slots = 2,
		clothing_slots = 1,
		class = "Деревенский дом",
		country_class = 1,
		apartments_class = 7,
		dropoff_days = -14,
	
		parking_marker_position = { x = -1897.409, y = -919.1934 +860, z = 19.0276, interior = 0, dimension = 0, rot = 250 },
		enter_marker_position = { x = -1901.5192, y = -923.9249 +860, z = 19.0276 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 3000, reduction = 45 },
			{ name = "Новая частная охрана", cost = 4000, reduction = 88 },
			{ name = "Новый дворецкий", cost = 5000, reduction = 118 },
		},
	
		img = "country_1",
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "country4",
		name = "Деревенский дом 4",
		cost = 200000,
		daily_cost = 890,
		parking_slots = 2,
		clothing_slots = 1,
		class = "Деревенский дом",
		country_class = 1,
		apartments_class = 7,
		dropoff_days = -14,
	
		parking_marker_position = { x = -1920.5852, y = -1012.6742 +860, z = 24.6955, interior = 0, dimension = 0, rot = 273 },
		enter_marker_position = { x = -1922.3208, y = -1021.4057 +860, z = 25.0704 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 3000, reduction = 45 },
			{ name = "Новая частная охрана", cost = 4000, reduction = 88 },
			{ name = "Новый дворецкий", cost = 5000, reduction = 118 },
		},
	
		img = "country_1",
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "country5",
		name = "Деревенский дом 5",
		cost = 200000,
		daily_cost = 890,
		parking_slots = 2,
		clothing_slots = 1,
		class = "Деревенский дом",
		country_class = 1,
		apartments_class = 7,
		dropoff_days = -14,
	
		parking_marker_position = { x = -2006.8408, y = -1018.8824 +860, z = 25.0514, interior = 0, dimension = 0, rot = 47 },
		enter_marker_position = { x = -1997.3818, y = -1014.3985 +860, z = 25.2912 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 3000, reduction = 45 },
			{ name = "Новая частная охрана", cost = 4000, reduction = 88 },
			{ name = "Новый дворецкий", cost = 5000, reduction = 118 },
		},
	
		img = "country_1",
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "country6",
		name = "Деревенский дом 6",
		cost = 200000,
		daily_cost = 890,
		parking_slots = 2,
		clothing_slots = 1,
		class = "Деревенский дом",
		country_class = 1,
		apartments_class = 7,
		dropoff_days = -14,
	
		parking_marker_position = { x = -1891.5635, y = 418.2558 +860, z = 18.2876, interior = 0, dimension = 0, rot = 47 },
		enter_marker_position = { x = -1887.5157, y = 412.3815 +860, z = 18.3035 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 3000, reduction = 45 },
			{ name = "Новая частная охрана", cost = 4000, reduction = 88 },
			{ name = "Новый дворецкий", cost = 5000, reduction = 118 },
		},
	
		img = "country_1",
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "country7",
		name = "Деревенский дом 7",
		cost = 200000,
		daily_cost = 890,
		parking_slots = 2,
		clothing_slots = 1,
		class = "Деревенский дом",
		country_class = 1,
		apartments_class = 7,
		dropoff_days = -14,
	
		parking_marker_position = { x = -1874.9296, y = 419.9134 +860, z = 18.3095, interior = 0, dimension = 0, rot = 44 },
		enter_marker_position = { x = -1872.3079, y = 426.191 +860, z = 18.4958 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 3000, reduction = 45 },
			{ name = "Новая частная охрана", cost = 4000, reduction = 88 },
			{ name = "Новый дворецкий", cost = 5000, reduction = 118 },
		},
	
		img = "country_1",
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "country8",
		name = "Деревенский дом 8",
		cost = 200000,
		daily_cost = 890,
		parking_slots = 2,
		clothing_slots = 1,
		class = "Деревенский дом",
		country_class = 1,
		apartments_class = 7,
		dropoff_days = -14,
	
		parking_marker_position = { x = -1980.1632, y = 393.0756 +860, z = 17.4451, interior = 0, dimension = 0, rot = 245 },
		enter_marker_position = { x = -1983.5026, y = 387.177 +860, z = 17.4881 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 3000, reduction = 45 },
			{ name = "Новая частная охрана", cost = 4000, reduction = 88 },
			{ name = "Новый дворецкий", cost = 5000, reduction = 118 },
		},
	
		img = "country_1",
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "country9",
		name = "Деревенский дом 9",
		cost = 200000,
		daily_cost = 890,
		parking_slots = 2,
		clothing_slots = 1,
		class = "Деревенский дом",
		country_class = 1,
		apartments_class = 7,
		dropoff_days = -14,
	
		parking_marker_position = { x = -1998.3702, y = 399.8081 +860, z = 17.4163, interior = 0, dimension = 0, rot = 345 },
		enter_marker_position = { x = -2005.8937, y = 395.2532 +860, z = 17.4829 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 3000, reduction = 45 },
			{ name = "Новая частная охрана", cost = 4000, reduction = 88 },
			{ name = "Новый дворецкий", cost = 5000, reduction = 118 },
		},
	
		img = "country_1",
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "country10",
		name = "Деревенский дом 10",
		cost = 200000,
		daily_cost = 890,
		parking_slots = 2,
		clothing_slots = 1,
		class = "Деревенский дом",
		country_class = 1,
		apartments_class = 7,
		dropoff_days = -14,
	
		parking_marker_position = { x = -2006.4989, y = 432.6159 +860, z = 17.2606, interior = 0, dimension = 0, rot = 70 },
		enter_marker_position = { x = -2006.7622, y = 440.4958 +860, z = 17.7251 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 3000, reduction = 45 },
			{ name = "Новая частная охрана", cost = 4000, reduction = 88 },
			{ name = "Новый дворецкий", cost = 5000, reduction = 118 },
		},
	
		img = "country_1",
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "country11",
		name = "Деревенский дом 11",
		cost = 200000,
		daily_cost = 890,
		parking_slots = 2,
		clothing_slots = 1,
		class = "Деревенский дом",
		country_class = 1,
		apartments_class = 7,
		dropoff_days = -14,
	
		parking_marker_position = { x = -2065.9223, y = 447.5394 +860, z = 17.3975, interior = 0, dimension = 0, rot = 180 },
		enter_marker_position = { x = -2050.6098, y = 454.6456 +860, z = 17.6752 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 3000, reduction = 45 },
			{ name = "Новая частная охрана", cost = 4000, reduction = 88 },
			{ name = "Новый дворецкий", cost = 5000, reduction = 118 },
		},
	
		img = "country_1",
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
	
	{
		hid = "country12",
		name = "Деревенский дом 12",
		cost = 200000,
		daily_cost = 890,
		parking_slots = 2,
		clothing_slots = 1,
		class = "Деревенский дом",
		country_class = 1,
		apartments_class = 7,
		dropoff_days = -14,
	
		parking_marker_position = { x = -1784.6412, y = 409.1993 +860, z = 19.0498, interior = 0, dimension = 0, rot = 115 },
		enter_marker_position = { x = -1792.3142, y = 414.2155 +860, z = 19.0257 },
	
		services_prefix = "Снижает содержание на ",
		services = {
			{ name = "Новая частная уборщица", cost = 3000, reduction = 45 },
			{ name = "Новая частная охрана", cost = 4000, reduction = 88 },
			{ name = "Новый дворецкий", cost = 5000, reduction = 118 },
		},
	
		img = "country_1",
	
		client_create = function( self )
		end,
	
		server_create = function( self )
		end,
	
		doors = { },
	},
}

VIP_HOUSES_INVENTORY_MAX_WEIGHTS = {
	cottage = {
		[ 1 ] = 125,
		[ 2 ] = 150,
		[ 3 ] = 150,
		[ 4 ] = 150,
		[ 5 ] = 175,
		[ 6 ] = 200,
	},
	village = {
		[ 1 ] = 300,
		[ 2 ] = 400,
		[ 3 ] = 600,
	},
	country = {
		[ 1 ] = 50,
	},
}

VIP_HOUSES_REVERSE = { }
for _, v in pairs( VIP_HOUSES_LIST ) do
	VIP_HOUSES_REVERSE[ v.hid ] = v
end

function table.copy( obj, seen )
	if type( obj ) ~= 'table' then return obj end
	if seen and seen[ obj ] then return seen[ obj ] end
	local s = seen or { }
	local res = setmetatable( { }, getmetatable( obj ) )
	s[ obj ] = res
	for k, v in pairs( obj ) do res[ table.copy(k, s) ] = table.copy( v, s ) end
	return res
end

RELATIVE_CONFIGS = table.copy( VIP_HOUSES_REVERSE )

local function RotateVector( x, y, angle )
	local rad = math.rad( angle )
	local nx = (x or 0) * math.cos( rad ) - (y or 0) * math.sin( rad )
	local ny = (x or 0) * math.sin( rad ) + (y or 0) * math.cos( rad )

	return nx, ny
end

local function ApplyRelativeData( conf )
	local pParent = RELATIVE_CONFIGS[ conf.relative ]

	local vecCenter = Vector3( pParent.relative_center.x, pParent.relative_center.y, pParent.relative_center.z )
	local vecRotation = Vector3( pParent.relative_center.rx, pParent.relative_center.ry, pParent.relative_center.rz )

	local vecNewCenter = Vector3( conf.relative_center.x, conf.relative_center.y, conf.relative_center.z )
	local vecNewRotation = Vector3( conf.relative_center.rx, conf.relative_center.ry, conf.relative_center.rz )

	local pRelativeKeysList = 
	{
		"reset_position",
		"spawn_position",
		"enter_marker_position",
		"sell_marker_position",
		"parking_marker_position",
		"control_marker_position",
		"wardrobe_position",
		"card_game_position",
		"wardrobe_camera_position",
		"wardrobe_camera_target",
		"wardrobe_ped_position",
		"cooking_position",
		"inventory_position",
	}

	for i, key in pairs( pRelativeKeysList ) do
		if pParent[key] then
			local vecRelativePosition = Vector3( pParent[key].x, pParent[key].y, pParent[key].z ) - vecCenter

			local x, y = RotateVector( vecRelativePosition.x, vecRelativePosition.y, vecNewRotation.z )
			x = x + vecNewCenter.x
			y = y + vecNewCenter.y

			conf[key] = { x = x, y = y, z = pParent[key].z }
		end
	end

	local beds = pParent.bed_position
	if beds then
		local newBeds = {  }
		for i,v in pairs( beds ) do 
			local vecRelativePosition = Vector3( v.x, v.y, v.z ) - vecCenter

			local x, y = RotateVector( vecRelativePosition.x, vecRelativePosition.y, vecNewRotation.z )
			x = x + vecNewCenter.x
			y = y + vecNewCenter.y

			local r = ( v.r or 0 ) + vecNewRotation.z

			newBeds[i] = { x = x, y = y, z = v.z, r = r }
		end
		conf.bed_position = newBeds
	end

	
	if pParent.parking_marker_position and pParent.parking_marker_position.rot then
		conf.parking_marker_position.rot = (pParent.parking_marker_position.rot or 0) + vecNewRotation.z
	end

	conf.wardrobe_ped_rotation = (pParent.wardrobe_ped_rotation or 0) + vecNewRotation.z

	conf.cost           = conf.cost or pParent.cost
	conf.services       = conf.services or pParent.services
	conf.daily_cost     = conf.daily_cost or pParent.daily_cost
	conf.parking_slots  = conf.parking_slots or pParent.parking_slots
	conf.clothing_slots = conf.clothing_slots or pParent.clothing_slots
	conf.img 			= conf.img or pParent.img
end

for k, config in pairs( VIP_HOUSES_LIST ) do
	if config.relative then
		ApplyRelativeData( config )
	end
	if not config.inventory_max_weight then
		if config.cottage_class then
			config.inventory_max_weight = VIP_HOUSES_INVENTORY_MAX_WEIGHTS.cottage[ config.cottage_class ]
		elseif config.village_class then
			config.inventory_max_weight = VIP_HOUSES_INVENTORY_MAX_WEIGHTS.village[ config.village_class ]
		elseif config.country_class then
			config.inventory_max_weight = VIP_HOUSES_INVENTORY_MAX_WEIGHTS.country[ config.country_class ]
		end
		if not config.inventory_max_weight then
			Debug( "cannot define inventory_max_weight " .. config.hid, 1 )
		end
	end
end	