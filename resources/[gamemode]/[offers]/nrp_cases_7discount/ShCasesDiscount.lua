loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShVehicleConfig" )
Extend( "ShPhone" )
Extend( "ShPlayer" )
Extend( "ShVehicle" )
Extend( "rewards/_ShItems" )

CONST_CASES_LIST = 
{ 
	["bronze"] = true,
	["silver"] = true,
}

REGISTERED_CASE_ITEMS = { }

CONST_REWARDS_BY_WEEK = 
{
	[1] = 
	{
		{
	      	type = "vinyl_case",
	      	name = "Королевский",
	      	cost = 353,
	      	id = 3,
	      	points = 75,
	      	bg_color = 1,
	      	count = 2
	    },
	    {
	      	bg_color = 1,
	      	type = "premium",
	      	name = "Премиум 3 дня",
	      	cost = 299,
	      	id = "3d_prem",
	      	points = 250,
	      	days = 3,
	      	count = 1
	    },
	    {
	      	type = "case",
	      	name = "Кейс Сатан-клаус",
	      	cost = 2998,
	      	id = "sanatclaus",
	      	points = 500,
	      	bg_color = 2,
	      	count = 2
	    },
	    {
	      	type = "skin",
	      	name = "Скин \"Англичанин\"",
	      	cost = 1250,
	      	id = 6743,
	      	points = 1000,
	      	bg_color = 3,
	      	count = 1
	    },
	    {
	      	type = "vehicle",
	      	name = "BMW 750i",
	      	cost = 3300,
	      	id = 6532,
	      	points = 2000,
	      	bg_color = 3,
	      	count = 1
	    },
	},

	[2] = 
	{
		{
          	type = "wof_coin",
          	name = "VIP Жетон колеса фортуны",
          	cost = 150,
          	points = 75,
          	coin_type = "gold",
          	bg_color = 1,
          	count = 2
        },
        {
          	type = "tuning_case",
          	name = "Максимальный тюнинг кейс",
          	cost = 698,
          	id = 5,
          	points = 250,
          	bg_color = 1,
          	count = 2
        },
        {
          	type = "case",
          	name = "Кейс Авиационный",
          	cost = 2998,
          	id = "air",
          	points = 500,
          	bg_color = 2,
          	count = 2
        },
        {
          	type = "skin",
          	name = "Скин \"Дарт-Вейдер\"",
          	cost = 2399,
          	id = 48,
          	points = 1000,
          	bg_color = 3,
          	count = 1
        },
        {
          	type = "skin",
          	name = "Скин \"Боец Спарты\"",
          	cost = 190,
          	id = 182,
          	points = 2000,
          	bg_color = 3,
          	count = 1
        },
	},

	[3] = 
	{
		{
          	type = "vinyl_case",
          	name = "Королевский",
          	cost = 353,
          	id = 3,
          	points = 75,
          	bg_color = 1,
          	count = 2
        },
        {
          	bg_color = 1,
          	type = "premium",
          	name = "Премиум 3 дня",
          	cost = 299,
          	id = "3d_prem",
          	points = 250,
          	days = 3,
          	count = 1
        },
        {
          	type = "case",
          	name = "Кейс Люкс",
          	cost = 2998,
          	id = "lux",
          	points = 500,
          	bg_color = 2,
          	count = 2
        },
        {
          	type = "skin",
          	name = "Скин \"Геральд\"",
          	cost = 5500,
          	id = 161,
          	points = 1000,
          	bg_color = 3,
          	count = 1
        },
        {
          	type = "pack",
          	name = "Пак \"Ниндзя\"",
          	cost = 1999,
          	id = "ninja",
          	points = 2000,
          	bg_color = 3,
          	count = 1
        },
	},

	[4] = 
	{
		{
          	type = "wof_coin",
          	name = "VIP Жетон колеса фортуны",
          	cost = 150,
          	points = 75,
          	coin_type = "gold",
          	bg_color = 1,
          	count = 2
        },
        {
          	type = "tuning_case",
          	name = "Максимальный тюнинг кейс",
          	cost = 698,
          	id = 5,
          	points = 250,
          	bg_color = 1,
          	count = 2
        },
        {
          	type = "case",
          	name = "Кейс Бриллиантовый",
          	cost = 2998,
          	id = "diamond",
          	points = 500,
          	bg_color = 2,
          	count = 2
        },
        {
          	type = "skin",
          	name = "Скин \"Спидерман\"",
          	cost = 6000,
          	id = 48,
          	points = 1000,
          	bg_color = 3,
          	count = 1
        },
        {
        	type = "pack",
        	name = "Пак \"Безумный Макс\"",
        	cost = 2470,
        	id = "mad_max",
        	points = 2000,
        	bg_color = 3,
        	count = 1
        }
	},

	[5] = 
	{
		{
          	type = "vinyl_case",
          	name = "Королевский",
          	cost = 353,
          	id = 3,
          	points = 75,
          	bg_color = 1,
          	count = 2
        },
        {
          	bg_color = 1,
          	type = "premium",
          	name = "Премиум 3 дня",
          	cost = 299,
          	id = "3d_prem",
          	points = 250,
          	days = 3,
          	count = 1
        },
        {
          	type = "case",
          	name = "Кейс Имераторский",
          	cost = 2998,
          	id = "imperial",
          	points = 500,
          	bg_color = 2,
          	count = 2
        },
        {
          	type = "skin",
          	name = "Скин \"Пришелец\"",
          	cost = 7000,
          	id = 100,
          	points = 1000,
          	bg_color = 3,
          	count = 1
        },
        {
          	type = "pack",
          	name = "Пак \"Буран\"",
          	cost = 2000,
          	id = "buran",
          	points = 2000,
          	bg_color = 3,
          	count = 1
        },
	},

	[6] = 
	{
		{
          	type = "wof_coin",
          	name = "VIP Жетон колеса фортуны",
          	cost = 150,
          	points = 75,
          	coin_type = "gold",
          	bg_color = 1,
          	count = 2
        },
        {
          	type = "tuning_case",
          	name = "Максимальный тюнинг кейс",
          	cost = 698,
          	id = 5,
          	points = 250,
          	bg_color = 1,
          	count = 2
        },
        {
          	type = "case",
          	name = "Кейс Париж",
          	cost = 2998,
          	id = "paris",
          	points = 500,
          	bg_color = 2,
          	count = 2
        },
        {
          	type = "skin",
          	name = "Скин \"Волк\"",
          	cost = 3000,
          	id = 33,
          	points = 1000,
          	bg_color = 3,
          	count = 1
        },
        {
          	type = "pack",
          	name = "Пак \"Форсаж 2\"",
          	cost = 3499,
          	id = "forsage",
          	points = 2000,
          	bg_color = 3,
          	count = 1
        }
	},
}