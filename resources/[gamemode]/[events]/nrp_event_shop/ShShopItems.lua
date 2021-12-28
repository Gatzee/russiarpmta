loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )

enum "eEventTimeType" 
{
	"HOURS",
	"DAYS",
}

TIME_FORMATS = {
	[ HOURS ] = { "час", "часа", "часов" },
	[ DAYS ] = { "день", "дня", "дней" },
}

SHOP_NAMES = {
	--[ "halloween" ] = "ХЭЛЛОУИНСКИЙ",
	--[ "new_year" ] = "НОВОГОДНИЙ",
	[ "may_events" ] = "МАЙСКИЙ",
}

SHOP_BOOSTERS = {
	--[[
	[ "new_year" ] =
	{
		{
			id = "lollipop";
			type = "booster";
			name = "Новогодний леденец";
			time = 2;
			time_type = HOURS;
			cost = 99;
			cost_single = 49.5;
			discount = 0;
		},
		{
			id = "gingerbread";
			type = "booster";
			name = "Новогодние печенье";
			time = 6;
			time_type = HOURS;
			cost = 249;
			cost_single = 41.5;
			discount = 10;
		},
		{
			id = "house";
			type = "booster";
			name = "Сладкий дом";
			time = 10;
			time_type = HOURS;
			cost = 349;
			cost_single = 35;
			discount = 50;
		},
	},
	--]]

	[ "may_events" ] =
	{
		{
			id = "clove";
			type = "booster";
			name = "Гвоздики";
			time = 2;
			time_type = HOURS;
			cost = 99;
			cost_single = 49;
			discount = 0;
		},
		{
			id = "medal";
			type = "booster";
			name = "Медаль";
			time = 4;
			time_type = HOURS;
			cost = 179;
			cost_single = 45;
			discount = 10;
		},
		{
			id = "coat_of_arms";
			type = "booster";
			name = "Герб";
			time = 12;
			time_type = HOURS;
			cost = 299;
			cost_single = 25;
			discount = 50;
		},
	},
}

SHOP_ITEMS = {
	--[[
	[ "new_year" ] =
	{
		{
			id = "lollipop";
			type = "booster";

			name = "Новогодний леденец";

			cost = 99;
			time = 2;
			time_type = HOURS;
		},
		{
			id = "gingerbread";
			type = "booster";

			name = "Новогодние печенье";

			cost = 249;
			time = 6;
			time_type = HOURS;
		},
		{
			id = "house";
			type = "booster";

			name = "Сладкий дом";

			cost = 349;
			time = 10;
			time_type = HOURS;
		},


		{
			id = "new_year_scarf";
			type = "accessory";

			name = "Новогодний Шарф";

			cost = 600;
		},
		{
			id = "new_year_hat";
			type = "accessory";

			name = "Новогодняя Шапка";

			cost = 900;
		},
		{
			id = "beard_santa";
			type = "accessory";

			name = "Борода Мороза";

			cost = 1400;
		},
		{
			id = "deer_mask";
			type = "accessory";

			name = "Маска “Под Оленя”";

			cost = 2500;
		},


		{
			id = 303;
			type = "skin";

			name = "Новогодний Эльф";

			cost = 4900;
		},
		{
			id = 301;
			type = "skin";

			name = "Снегурочка";

			cost = 4900;
		},
		{
			id = 300;
			type = "skin";

			name = "Гринч";

			cost = 5900;
		},
		{
			id = 184;
			type = "skin";

			name = "Дед мороз";

			cost = 6900;
		},


		{
			id = 480;
			type = "vehicle";

			name = "Zaz 968 Roadster";

			cost = 12000;

			color = { 255, 0, 0 };
		},
	},
	--]]

	[ "may_events" ] =
	{
		{
			id = "clove";
			type = "booster";
			name = "Гвоздики";
			time = 2;
			time_type = HOURS;
			cost = 99;
		},
		{
			id = "medal";
			type = "booster";
			name = "Медаль";
			time = 4;
			time_type = HOURS;
			cost = 179;
		},
		{
			id = "coat_of_arms";
			type = "booster";
			name = "Герб";
			time = 12;
			time_type = HOURS;
			cost = 299;
		},

		
		{
			id = "m3_acse32";
			type = "accessory";

			name = "Военная каска";

			cost = 600;
		},
		{
			id = "m3_acse33";
			type = "accessory";

			name = "Шлем пилота";

			cost = 900;
		},
		{
			id = "m3_acse34";
			type = "accessory";

			name = "Пулемётная лента";

			cost = 1400;
		},
		{
			id = "m3_acse23";
			type = "accessory";

			name = "Армейский подсумок";

			cost = 2500;
		},

		{
			id = 6752;
			type = "skin";

			name = "Ветеран";

			cost = 4900;
		},
		{
			id = 6754;
			type = "skin";

			name = "Медсестра";

			cost = 4900;
		},
		{
			id = 6750;
			type = "skin";

			name = "Командос";

			cost = 5900;
		},
		{
			id = 6753;
			type = "skin";

			name = "Снайперша";

			cost = 6900;
		},

		{
			id = 6584;
			type = "vehicle";

			name = "Газ-Т34";

			cost = 12000;
			soft_cost = 300000;

			color = { { 245, 245, 220 }, { 9, 17, 9 } };
		},
	},
}