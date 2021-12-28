loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShVehicleConfig" )

function math.round( num,  idp )
	local mult = 10 ^ ( idp or 0 )
	return math.floor( num * mult + 0.5 ) / mult
end

PROGRESS_POINT_COUNT = 6
FREE_COIN_PERIOD = 180

enum "eWheelRewardTypes" {
	"TYPE_SOFT",
	"TYPE_EXP",
	"TYPE_INVENTORY",
	"TYPE_BOOST_PLUS_50",
	"TYPE_BOOST_X2",
	"TYPE_BOOST_DEFAULT",
	"TYPE_BOOST",
}

enum "eWheelRewardSections" {
	"SECTION_SMALL",
	"SECTION_MEDIUM",
	"SECTION_INVENTORY",
	"SECTION_BOOST_PLUS_50",
	"SECTION_BOOST_X2",
	"SECTION_JACKPOT",
}

TOOLTIP_NAMES = {
	fuelcan = "Канистра",
	firstaid = "Аптечка",
	license_gun = "Лицензия на оружие",
	repairbox = "Рем. комплект",
	jailkeys = "Карточка выхода из тюрьмы",
	wof_coin = "Жетон VIP",
}

-- типы наград
WHEEL_REWARD_TYPES = {
	[ TYPE_SOFT ] = {
		img = "files/img/reward_soft.png",
		font_size = 14,
	},
	[ TYPE_EXP ] = {
		img = "files/img/reward_exp.png",
		font_size = 16,
	},
	[ TYPE_INVENTORY ] = {
		img = "files/img/reward_inventory.png",
	},
	[ TYPE_BOOST_PLUS_50 ] = {
		name = "+50%",
		font_size = 20,
	},
	[ TYPE_BOOST_X2 ] = {
		name = "x2",
		font_size = 26,
	},
}

-- стоимость и аналитика
ROULETTE_CONFIG = {
	[ "default" ] = {
		name = "Обычное колесо",
		cost = 20,
		analytics = "common"
	},
	[ "gold" ] = {
		name = "VIP колесо",
		cost = 75,
		analytics = "vip"
	}
}

Player.GetCostRoullete = function( self, roullete_type )
	if roullete_type == "default" then
		return ROULETTE_CONFIG[ roullete_type ].cost, false
	end

	local cost, coupon_discount_value = self:GetCostWithCouponDiscount( "special_vip_wof", ROULETTE_CONFIG[ roullete_type ].cost )
	return cost, coupon_discount_value
end

-- прогресс очков
PROGRESS_POINTS = {
	[ "default" ] = {
		{
			points = 1,
			games = 6,
		},
		{
			points = 1,
			games = 28,
		},
		{
			points = 1,
			games = 55,
		},
		{	
			points = 2,
			games = 75,
		},
	},
	[ "gold" ] = {
		{
			points = 1,
			games = 6,
		},
		{
			points = 1,
			games = 15,
		},
		{
			points = 1,
			games = 20,
		},
		{	
			points = 2,
			games = 40,
		},
	},
}

INVENTORY_CONFIG = 
{
	default = 
	{
		[ TYPE_BOOST_DEFAULT ] = {
			{ 
				type = TYPE_INVENTORY,
				chances = 20.8, 
				analytics = {
					name = "fuel",
					count = 3,
					cost = 15,
				},
				reward = {
					name = "fuelcan",
					params = {
						count = 3
					},
					type = "fuelcan"
				}
			},
			{ 
				type = TYPE_INVENTORY,
				chances = 20.8,
				analytics = {
					name = "aid",
					count = 3,
					cost = 15,
				}, 
				reward = {
					name = "firstaid",
					params = {
						count = 3
					},
					type = "firstaid"
				}
			},
			{ 
				type = TYPE_INVENTORY,
				chances = 31.1,
				analytics = {
					name = "aid_fuel",
					count = 1,
					cost = 10,
				}, 
				reward = {
					name = "box",
					params = {
						items = {
							firstaid = { count = 1 },
							fuelcan = { count = 1 },
						},
						number = 3,
						name = "Аптечка + канистра",
					},
					type = "box"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 18.3,
				analytics = {
					name = "license_1d",
					count = 1,
					cost = 17,
				},
				reward = {
					name = "license_gun",
					params = {
						count = 1
					},
					type = "license_gun"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 9.0,
				analytics = {
					name = "repair_aid_fuel",
					count = 1,
					cost = 35,
				},
				reward = {
					name = "box",
					params = {
						items = {
							repairbox = { count = 1 },
							firstaid = { count = 1 }, 
							fuelcan = { count = 1 },
						},
						number = 4,
						name = "Рем. комплект + канистра + аптечка",
					},
					type = "box"
				}
			},
		},
		[ TYPE_BOOST_PLUS_50 ] = {
			{ 
				type = TYPE_INVENTORY, 
				chances = 23.1,
				analytics = {
					name = "repair",
					count = 1,
					cost = 25,
				},
				reward = {
					name = "repairbox",
					params = {
						count = 1
					},
					type = "repairbox"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 23.1,
				analytics = {
					name = "jailkeys",
					count = 1,
					cost = 25,
				},
				reward = {
					name = "jailkeys",
					params = {
						count = 1
					},
					type = "jailkeys"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 28.8,
				analytics = {
					name = "aid_fuel",
					count = 2,
					cost = 20,
				},
				reward = {
					name = "box",
					params = {
						items = {
							firstaid = { count = 2 },
							fuelcan = { count = 2 },
						},
						number = 3,
						name = "Аптечка + канистра",
					},
					type = "box"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 16.9,
				analytics = {
					name = "license_2d",
					count = 1,
					cost = 34,
				},
				reward = {
					name = "license_gun",
					params = {
						count = 2
					},
					type = "license_gun"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 8.1,
				analytics = {
					name = "repair_aid_fuel",
					count = 2,
					cost = 70,
				},
				reward = {
					name = "box",
					params = {
						items = {
							repairbox = { count = 2 },
							firstaid = { count = 2 }, 
							fuelcan = { count = 2 },
						},
						number = 4,
						name = "Рем. комплект + канистра + аптечка",
					},
					type = "box"
				}
			},
		},
		[ TYPE_BOOST_X2 ] = {
			{ 
				type = TYPE_INVENTORY, 
				chances = 20.4,
				analytics = {
					name = "repair",
					count = 2,
					cost = 50,
				},
				reward = {
					name = "repairbox",
					params = {
						count = 2
					},
					type = "repairbox"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 20.4,
				analytics = {
					name = "jailkeys",
					count = 2,
					cost = 50,
				},
				reward = {
					name = "jailkeys",
					params = {
						count = 2
					},
					type = "jailkeys"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 25.5,
				analytics = {
					name = "aid_fuel",
					count = 4,
					cost = 40,
				}, 
				reward = {
					name = "box",
					params = {
						items = {
							firstaid = { count = 4 },
							fuelcan = { count = 4 },
						},
						number = 3,
						name = "Аптечка + канистра",
					},
					type = "box"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 19.9,
				analytics = {
					name = "license_3d",
					count = 1,
					cost = 51,
				}, 
				reward = {
					name = "license_gun",
					params = {
						count = 3
					},
					type = "license_gun"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 13.8,
				analytics = {
					name = "wof_vip",
					count = 1,
					cost = 75,
				}, 
				reward = {
					name = "wof_coin",
					params = {
						count = 1,
						coin_type = "gold",
					},
					type = "wof_coin"
				}
			},
		},
	},

	gold = 
	{
		[ TYPE_BOOST_DEFAULT ] = {
			{
				type = TYPE_INVENTORY, 
				chances = 22.4,
				analytics = {
					name = "repair",
					count = 1,
					cost = 25,
				}, 
				reward = {
					name = "repairbox",
					params = {
						count = 1
					},
					type = "repairbox"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 22.4,
				analytics = {
					name = "jailkeys",
					count = 1,
					cost = 25,
				},  
				reward = {
					name = "jailkeys",
					params = {
						count = 1
					},
					type = "jailkeys"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 28.0,
				analytics = {
					name = "aid_fuel",
					count = 2,
					cost = 20,
				}, 
				reward = {
					name = "box",
					params = {
						items = {
							firstaid = { count = 2 },
							fuelcan = { count = 2 },
						},
						number = 3,
						name = "Аптечка + канистра",
					},
					type = "box"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 11.0,
				analytics = {
					name = "license_3d",
					count = 1,
					cost = 51,
				}, 
				reward = {
					name = "license_gun",
					params = {
						count = 3
					},
					type = "license_gun"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 16.1,
				analytics = {
					name = "repair_aid_fuel",
					count = 1,
					cost = 35,
				}, 
				reward = {
					name = "box",
					params = {
						items = {
							repairbox = { count = 1 },
							firstaid = { count = 1 }, 
							fuelcan = { count = 1 },
						},
						number = 4,
						name = "Рем. комплект + канистра + аптечка",
					},
					type = "box"
				}
			},
		},
		[ TYPE_BOOST_PLUS_50 ] = {
			{
				type = TYPE_INVENTORY, 
				chances = 21.3,
				analytics = {
					name = "repair",
					count = 2,
					cost = 50,
				}, 
				reward = {
					name = "repairbox",
					params = {
						count = 2
					},
					type = "repairbox"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 21.3,
				analytics = {
					name = "jailkeys",
					count = 2,
					cost = 50,
				}, 
				reward = {
					name = "jailkeys",
					params = {
						count = 2
					},
					type = "jailkeys"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 26.7,
				analytics = {
					name = "aid_fuel",
					count = 4,
					cost = 40,
				}, 
				reward = {
					name = "box",
					params = {
						items = {
							firstaid = { count = 4 },
							fuelcan = { count = 4 },
						},
						number = 3,
						name = "Аптечка + канистра",
					},
					type = "box"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 15.6,
				analytics = {
					name = "license_4d",
					count = 1,
					cost = 68,
				}, 
				reward = {
					name = "license_gun",
					params = {
						count = 4
					},
					type = "license_gun"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 15.1,
				analytics = {
					name = "repair_aid_fuel",
					count = 2,
					cost = 70,
				}, 
				reward = {
					name = "box",
					params = {
						items = {
							repairbox = { count = 2 },
							firstaid = { count = 2 }, 
							fuelcan = { count = 2 },
						},
						number = 4,
						name = "Рем. комплект + канистра + аптечка",
					},
					type = "box"
				}
			},
		},
		[ TYPE_BOOST_X2 ] = {
			{
				type = TYPE_INVENTORY, 
				chances = 19.3,
				analytics = {
					name = "repair",
					count = 4,
					cost = 100,
				}, 
				reward = {
					name = "repairbox",
					params = {
						count = 4
					},
					type = "repairbox"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 19.3,
				analytics = {
					name = "jailkeys",
					count = 4,
					cost = 100,
				},  
				reward = {
					name = "jailkeys",
					params = {
						count = 4
					},
					type = "jailkeys"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 24.1,
				analytics = {
					name = "aid_fuel",
					count = 8,
					cost = 80,
				},  
				reward = {
					name = "box",
					params = {
						items = {
							firstaid = { count = 8 },
							fuelcan = { count = 8 },
						},
						number = 3,
						name = "Аптечка + канистра",
					},
					type = "box"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 19.0,
				analytics = {
					name = "license_6d",
					count = 1,
					cost = 102,
				},  
				reward = {
					name = "license_gun",
					params = {
						count = 6
					},
					type = "license_gun"
				}
			},
			{ 
				type = TYPE_INVENTORY, 
				chances = 15.1,
				analytics = {
					name = "repair_aid_fuel",
					count = 3,
					cost = 105,
				},  
				reward = {
					name = "box",
					params = {
						items = {
							repairbox = { count = 3 },
							firstaid = { count = 3 }, 
							fuelcan = { count = 3 },
						},
						number = 4,
						name = "Рем. комплект + канистра + аптечка",
					},
					type = "box"
				}
			},
		},
	},
}

-- награды по уровням EXP - SOFT
WHEEL_REWARD_LEVELS = {
	[ "default" ] = {
		{ [ TYPE_EXP ] = 1000, [ TYPE_SOFT ] = 15000 },
		{ [ TYPE_EXP ] = 1000, [ TYPE_SOFT ] = 15000 },
		{ [ TYPE_EXP ] = 1000, [ TYPE_SOFT ] = 20000 },
		{ [ TYPE_EXP ] = 1000, [ TYPE_SOFT ] = 22500 },
		{ [ TYPE_EXP ] = 1500, [ TYPE_SOFT ] = 25000 },
		{ [ TYPE_EXP ] = 1500, [ TYPE_SOFT ] = 27500 },
		{ [ TYPE_EXP ] = 2000, [ TYPE_SOFT ] = 30000 },
		{ [ TYPE_EXP ] = 2000, [ TYPE_SOFT ] = 35000 },
		{ [ TYPE_EXP ] = 2300, [ TYPE_SOFT ] = 40000 },
		{ [ TYPE_EXP ] = 2300, [ TYPE_SOFT ] = 42500 },
		{ [ TYPE_EXP ] = 2300, [ TYPE_SOFT ] = 45000 },
		{ [ TYPE_EXP ] = 2300, [ TYPE_SOFT ] = 47500 },
		{ [ TYPE_EXP ] = 2500, [ TYPE_SOFT ] = 50000 },
		{ [ TYPE_EXP ] = 2500, [ TYPE_SOFT ] = 52500 },
		{ [ TYPE_EXP ] = 3000, [ TYPE_SOFT ] = 55000 },
		{ [ TYPE_EXP ] = 3000, [ TYPE_SOFT ] = 57500 },
		{ [ TYPE_EXP ] = 3000, [ TYPE_SOFT ] = 60000 },
		{ [ TYPE_EXP ] = 3000, [ TYPE_SOFT ] = 62500 },
		{ [ TYPE_EXP ] = 3000, [ TYPE_SOFT ] = 65000 },
		{ [ TYPE_EXP ] = 3000, [ TYPE_SOFT ] = 67500 },
		{ [ TYPE_EXP ] = 3200, [ TYPE_SOFT ] = 70000 },
		{ [ TYPE_EXP ] = 3600, [ TYPE_SOFT ] = 72500 },
		{ [ TYPE_EXP ] = 4200, [ TYPE_SOFT ] = 75000 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 77500 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 80000 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 82500 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 85000 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 87500 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 90000 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 92500 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 95000 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 97500 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 100000 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 102500 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 105000 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 107500 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 110000 },
	},
	[ "gold" ] = {
		{ [ TYPE_EXP ] = 1000, [ TYPE_SOFT ] = 15000 },
		{ [ TYPE_EXP ] = 1000, [ TYPE_SOFT ] = 15000 },
		{ [ TYPE_EXP ] = 1000, [ TYPE_SOFT ] = 20000 },
		{ [ TYPE_EXP ] = 1000, [ TYPE_SOFT ] = 22500 },
		{ [ TYPE_EXP ] = 1500, [ TYPE_SOFT ] = 25000 },
		{ [ TYPE_EXP ] = 1500, [ TYPE_SOFT ] = 27500 },
		{ [ TYPE_EXP ] = 2000, [ TYPE_SOFT ] = 30000 },
		{ [ TYPE_EXP ] = 2000, [ TYPE_SOFT ] = 35000 },
		{ [ TYPE_EXP ] = 2300, [ TYPE_SOFT ] = 40000 },
		{ [ TYPE_EXP ] = 2300, [ TYPE_SOFT ] = 42500 },
		{ [ TYPE_EXP ] = 2300, [ TYPE_SOFT ] = 45000 },
		{ [ TYPE_EXP ] = 2300, [ TYPE_SOFT ] = 47500 },
		{ [ TYPE_EXP ] = 2500, [ TYPE_SOFT ] = 50000 },
		{ [ TYPE_EXP ] = 2500, [ TYPE_SOFT ] = 52500 },
		{ [ TYPE_EXP ] = 3000, [ TYPE_SOFT ] = 55000 },
		{ [ TYPE_EXP ] = 3000, [ TYPE_SOFT ] = 57500 },
		{ [ TYPE_EXP ] = 3000, [ TYPE_SOFT ] = 60000 },
		{ [ TYPE_EXP ] = 3000, [ TYPE_SOFT ] = 62500 },
		{ [ TYPE_EXP ] = 3000, [ TYPE_SOFT ] = 65000 },
		{ [ TYPE_EXP ] = 3000, [ TYPE_SOFT ] = 67500 },
		{ [ TYPE_EXP ] = 3200, [ TYPE_SOFT ] = 70000 },
		{ [ TYPE_EXP ] = 3600, [ TYPE_SOFT ] = 72500 },
		{ [ TYPE_EXP ] = 4200, [ TYPE_SOFT ] = 75000 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 77500 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 80000 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 82500 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 85000 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 87500 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 90000 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 92500 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 95000 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 97500 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 100000 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 102500 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 105000 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 107500 },
		{ [ TYPE_EXP ] = 4500, [ TYPE_SOFT ] = 110000 },
	},	
}

-- процентное соотношение для наград
WHEEL_REWARD_PERCENTS = {
	[ "default" ] = {
		[ SECTION_SMALL ] = {
			{ type = TYPE_EXP, percent = 5, name_reward = "small_exp1", },
			{ type = TYPE_EXP, percent = 15, name_reward = "small_exp2", },
			{ type = TYPE_SOFT, percent = 1, name_reward = "small_soft1", },
			{ type = TYPE_SOFT, percent = 2, name_reward = "small_soft2", },
			{ type = TYPE_SOFT, percent = 3, name_reward = "small_soft3", },
		},
		[ SECTION_MEDIUM ] = {
			{ type = TYPE_EXP, percent = 40, name_reward = "mid_exp1", },
			{ type = TYPE_SOFT, percent = 4, name_reward = "mid_soft1", },
			{ type = TYPE_SOFT, percent = 6, name_reward = "mid_soft2", },
		},
		[ SECTION_INVENTORY ] = { },
		[ SECTION_BOOST_PLUS_50 ] = {
			{ type = TYPE_BOOST_PLUS_50, count = 1.5, name_reward = "bonus_1", },
		},
		[ SECTION_BOOST_X2 ] = {
			{ type = TYPE_BOOST_X2, count = 2, name_reward = "bonus_2", },
		},
		[ SECTION_JACKPOT ] = {
			{ type = TYPE_EXP, percent = 50, name_reward = "jp_exp", },
			{ type = TYPE_SOFT, percent = 50, name_reward = "jp_soft", },
		},
	},
	[ "gold" ] = {
		[ SECTION_SMALL ] = {
			{ type = TYPE_EXP, percent = 10, name_reward = "small_exp1", },
			{ type = TYPE_EXP, percent = 20, name_reward = "small_exp2", },
			{ type = TYPE_SOFT, percent = 3, name_reward = "small_soft1", },
			{ type = TYPE_SOFT, percent = 4, name_reward = "small_soft2", },
			{ type = TYPE_SOFT, percent = 5, name_reward = "small_soft3", },
		},
		[ SECTION_MEDIUM ] = {
			{ type = TYPE_EXP, percent = 50, name_reward = "mid_exp1", },
			{ type = TYPE_SOFT, percent = 6, name_reward = "mid_soft1", },
			{ type = TYPE_SOFT, percent = 7, name_reward = "mid_soft2", },
		},
		[ SECTION_INVENTORY ] = { },
		[ SECTION_BOOST_PLUS_50 ] = {
			{ type = TYPE_BOOST_PLUS_50, count = 1.5, name_reward = "bonus_1" },
		},
		[ SECTION_BOOST_X2 ] = {
			{ type = TYPE_BOOST_X2, count = 2, name_reward = "bonus_2" },
		},
		[ SECTION_JACKPOT ] = {
			{ type = TYPE_EXP, percent = 100, name_reward = "jp_exp", },
			{ type = TYPE_SOFT, percent = 100, name_reward = "jp_soft", },
		},
	},
}

-- необходимое колво очков для получения сезонных наград
PROGRESS_REWARDS_POINTS = {
	7,
	14,
	21,
	28,
}

-- прогресс наград по сезонам
PROGRESS_REWARDS = {
	-- 1 сезон
	{
		start_date = getTimestampFromString( "28 января 2021 00:00" ),
		finish_date = getTimestampFromString( "24 февраля 2021 23:59" ),
		rewards = {
			[ "default" ] = {
				{
					analytics = {
						name = "sochi",
						id = 207,
						cost_soft = 20000,
					},
					reward = {
						params = {
							model = 207
						},
						type = "skin"
					}
				},
				{
					analytics = {
						name = "lexus_lx",
						id = 551,
					},
					reward = {
						params = {
							model = 551,
							temp_days = 1,
						},
						type = "vehicle"
					}
				},
				{
					analytics = {
						name = "cowboy_hat",
						id = "m3_acse14",
						cost_soft = 20000,
					},
					reward = {
						params = {
							id = "m3_acse14"
						},
						rare = 3,
						type = "accessory"
					}
				},
				{
					analytics = {
						name = "madness",
						id = "s35",
					},
					reward = {
						cost = 69,
						params = {
							id = "s35",
						},
						type = "vinyl"
					}
				},
			},
			[ "gold" ] = {
				{
					analytics = {
						name = "porsche_panamera",
						id = 580,
					},
					reward_type = "vehicle",
					reward = {
						params = {
							model = 580,
							temp_days = 1,
						},
						type = "vehicle"
					}
				},
				{
					analytics = {
						name = "star_regiment",
						id = "neon_1",
					},
					reward = {
						cost = 999,
						params = {
							id = 1
						},
						type = "neon"
					}
				},
				{
					analytics = {
						name = "courier",
						id = 165,
						cost_soft = 40000,
					},
					reward = {
						params = {
							model = 165
						},
						type = "skin"
					}
				},
				{
					analytics = {
						name = "deadpool",
						id = 37,
					},
					reward = {
						cost = 139,
						
						params = {
							id = "s37",
						},
						type = "vinyl"
					}
				},
			},
		}
	},
	-- 2 сезон
	{
		start_date = getTimestampFromString( "25 февраля 2021 00:00" ),
		finish_date = getTimestampFromString( "24 марта 2021 23:59" ),
		rewards = {
			[ "default" ] = {
				{
					analytics = {
						name = "golf_gt",
						id = 529,
					},
					reward = {
						params = {
							model = 529,
							temp_days = 1,
						},
						type = "vehicle"
					}
				},
				{
					analytics = {
						name = "secret_tommy_pocket",
						id = "banana",
						cost_soft = 20000,
					},
					reward = {
						params = {
							id = "banana"
						},
						rare = 3,
						type = "accessory"
					}
				},
				{
					analytics = {
						name = "phoenix",
						id = "s23",
					},
					reward = {
						cost = 99,
						params = {
							id = "s23",
						},
						type = "vinyl"
					}
				},
				{
					analytics = {
						name = "monster",
						id = "neon_68",
					},
					reward = {
						cost = 979,
						params = {
							id = 68
						},
						type = "neon"
					}
				},
			},
			[ "gold" ] = {
				{
					analytics = {
						name = "buggy",
						id = 424,
					},
					reward = {
						params = {
							model = 424,
							temp_days = 1,
						},
						type = "vehicle"
					}
				},
				{
					analytics = {
						name = "guy_mask",
						id = "mask_v",
						cost_soft = 40000,
					},
					reward = {
						params = {
							id = "mask_v"
						},
						rare = 3,
						type = "accessory"
					}
				},
				{
					analytics = {
						name = "king_yerzhan",
						id = "s43",
					},
					reward = {
						cost = 89,
						params = {
							id = "s43",
						},
						type = "vinyl"
					}
				},
				{
					analytics = {
						name = "maniac",
						id = 94,
						cost_soft = 40000,
					},
					reward = {
						params = {
							model = 94
						},
						type = "skin"
					}
				},
			},
		}
	},
	-- 3 сезон
	{
		start_date = getTimestampFromString( "25 марта 2021 00:00" ),
		finish_date = getTimestampFromString( "22 апреля 2021" ),
		rewards = {
			[ "default" ] = {
				{
					analytics = {
						name = "volga",
						id = 467,
					},
					reward = {
						params = {
							model = 467,
							temp_days = 1,
						},
						type = "vehicle"
					}
				},
				{
					analytics = {
						name = "medallion",
						id = "chain2",
						cost_soft = 20000,
					},
					reward = {
						params = {
							id = "chain2"
						},
						rare = 3,
						type = "accessory"
					}
				},
				{
					analytics = {
						name = "dragon mother",
						id = "s24",
					},
					reward = {
						cost = 149,
						params = {
							id = "s24",
						},
						type = "vinyl"
					}
				},
				{
					analytics = {
						name = "holiday_balls",
						id = "neon_58",
					},
					reward = {
						cost = 819,
						params = {
							id = 58
						},
						type = "neon"
					}
				},
			},
			[ "gold" ] = {
				{
					analytics = {
						name = "black_lightning",
						id = 438,
					},
					reward = {
						params = {
							model = 438,
							temp_days = 1,
						},
						type = "vehicle"
					}
				},
				{
					analytics = {
						name = "katana",
						id = "katana",
						cost_soft = 40000,
					},
					reward = {
						params = {
							id = "katana"
						},
						rare = 3,
						type = "accessory"
					}
				},
				{
					analytics = {
						name = "rick",
						id = "s40",
					},
					reward = {
						cost = 149,
						params = {
							id = "s40",
						},
						type = "vinyl"
					}
				},
				{
					analytics = {
						name = "wall_street",
						id = 199,
						cost_soft = 40000,
					},
					reward = {
						params = {
							model = 199
						},
						type = "skin"
					}
				},
			},
		}
	},
	-- 4 сезон
	{
		start_date = getTimestampFromString( "22.04.2021" ),
		finish_date = getTimestampFromString( "20.05.2021" ),
		rewards = {
			[ "default" ] = {
				{
					analytics = {
						name = "chevrolet_camaro",
						id = 518,
					},
					reward = {
						params = {
							model = 518,
							temp_days = 1,
						},
						type = "vehicle"
					}
				},
				{
					analytics = {
						name = "net",
						id = "neon_33",
					},
					reward = {
						params = {
							id = 33
						},
						cost = 719,
						rare = 3,
						type = "neon"
					}
				},
				{
					analytics = {
						name = "leather_cap",
						id = "m3_acse06",
						cost_soft = 20000,
					},
					reward = {
						params = {
							id = "m3_acse06"
						},
						rare = 3,
						type = "accessory"
					}
				},
				{
					analytics = {
						name = "lecturer",
						id = 97,
						cost_soft = 20000,
					},
					reward = {
						params = {
							id = 97
						},
						type = "skin"
					}
				},
			},
			[ "gold" ] = {
				{
					analytics = {
						name = "mitsubishi_lancer_9",
						id = 6534,
					},
					reward = {
						params = {
							model = 6534,
							temp_days = 1,
						},
						type = "vehicle"
					}
				},
				{
					analytics = {
						name = "music_in_blood",
						id = "neon_60",
					},
					reward = {
						params = {
							id = 60
						},
						cost = 729,
						rare = 3,
						type = "neon"
					}
				},
				{
					analytics = {
						name = "cocked_hat",
						id = "m2_asce012",
						cost_soft = 40000,
					},
					reward = {
						params = {
							id = "m2_asce012"
						},
						rare = 3,
						type = "accessory"
					}
				},
				{
					analytics = {
						name = "eligant",
						id = 57,
						cost_soft = 40000,
					},
					reward = {
						params = {
							id = 57
						},
						type = "skin"
					}
				},
			},
		}
	},
	-- 5 сезон
	{
		start_date = getTimestampFromString( "20.05.2021" ),
		finish_date = getTimestampFromString( "17.06.2021" ),
		rewards = {
			[ "default" ] = {
				{
					analytics = {
						name = "nissan_skyline_gt-r",
						id = 587,
					},
					reward = {
						params = {
							model = 587,
							temp_days = 1,
						},
						type = "vehicle"
					}
				},
				{
					analytics = {
						name = "spiked_collar",
						id = "m3_acse16",
						cost_soft = 20000,
					},
					reward = {
						params = {
							id = "m3_acse16"
						},
						rare = 3,
						type = "accessory"
					}
				},
				{
					analytics = {
						name = "dance_of_sin",
						id = "s42",
					},
					reward = {
						cost = 69,
						params = {
							id = "s42",
						},
						type = "vinyl"
					}
				},
				{
					analytics = {
						name = "biker",
						id = 103,
						cost_soft = 20000,
					},
					reward = {
						params = {
							id = 103
						},
						type = "skin"
					}
				},
			},
			[ "gold" ] = {
				{
					analytics = {
						name = "bmw_m6",
						id = 505,
					},
					reward = {
						params = {
							model = 505,
							temp_days = 1,
						},
						type = "vehicle"
					}
				},
				{
					analytics = {
						name = "living_fire",
						id = "neon_42",
					},
					reward = {
						cost = 869,
						params = {
							id = 42
						},
						type = "neon"
					}
				},
				{
					analytics = {
						name = "helmet_german",
						id = "m2_asce06",
						cost_soft = 40000,
					},
					reward = {
						params = {
							id = "m2_asce06"
						},
						rare = 3,
						type = "accessory"
					}
				},
				{
					analytics = {
						name = "baldur",
						id = 6738,
						cost_soft = 40000,
					},
					reward = {
						params = {
							id = 6738
						},
						type = "skin"
					}
				},
			},
		}
	},
	-- 6 сезон
	{
		start_date = getTimestampFromString( "17.06.2021" ),
		finish_date = getTimestampFromString( "15.07.2021" ),
		rewards = {
			[ "default" ] = {
				{
					analytics = {
						name = "lincoln_town_car_1989",
						id = 6593,
					},
					reward = {
						params = {
							model = 6593,
							temp_days = 1,
						},
						type = "vehicle"
					}
				},
				{
					analytics = {
						name = "diesel",
						id = 176,
						cost_soft = 10000,
					},
					reward = {
						params = {
							id = 176
						},
						type = "skin"
					}
				},
				{
					analytics = {
						name = "mask",
						id = "mask2",
						cost_soft = 20000,
					},
					reward = {
						params = {
							id = "mask2"
						},
						rare = 3,
						type = "accessory"
					}
				},
				{
					analytics = {
						name = "rick",
						id = "s40",
					},
					reward = {
						cost = 149,
						params = {
							id = "s40",
						},
						type = "vinyl"
					}
				},
			},
			[ "gold" ] = {
				{
					analytics = {
						name = "dodge_charger",
						id = 419,
					},
					reward = {
						params = {
							model = 419,
							temp_days = 1,
						},
						type = "vehicle"
					}
				},
				{
					analytics = {
						name = "town",
						id = "neon_34",
					},
					reward = {
						cost = 829,
						params = {
							id = 34
						},
						type = "neon"
					}
				},
				{
					analytics = {
						name = "mask_of_bane",
						id = "m3_acse09",
						cost_soft = 40000,
					},
					reward = {
						params = {
							id = "m3_acse09"
						},
						rare = 3,
						type = "accessory"
					}
				},
				{
					analytics = {
						name = "rick",
						id = 6740,
						cost_soft = 40000,
					},
					reward = {
						params = {
							id = 6740
						},
						type = "skin"
					}
				},
			},
		}
	},
}