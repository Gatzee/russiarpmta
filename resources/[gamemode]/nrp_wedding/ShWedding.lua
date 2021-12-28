loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShWedding" )

WEDDING_SHOP_PARTS = {
	wedding					= { hard_cost = 499,    name = "Свадебная набор",     	 node = IN_WEDDING_START,                buy_count = 1,	level = 6, max = 1 },
	divorce     			= { hard_cost = 499,    name = "Бумаги на развод",       node = IN_WEDDING_DIS,                  buy_count = 1,	level = 6, max = 1 },
	choco       			= { hard_cost = 10,     name = "Шоколадка",              node = IN_WEDDING_CHOCO,                buy_count = 1, id = 1 },
	panam_hat   			= { hard_cost = 99,     name = "Шляпа Panam Hat",        node = IN_WEDDING_PANAMHAT,             buy_count = 1, id = 2 },--1365
	diamond_bag 			= { hard_cost = 49,     name = "Сумка с бриллиантом",    node = IN_WEDDING_HANDBAG,              buy_count = 1, id = 3 },--1337
	diamond_hope			= { hard_cost = 99,     name = "Алмаз хоуп",             node = IN_WEDDING_NECKLACEHOPE,         buy_count = 1, id = 4 },--1338
	wood_black_glasses		= { hard_cost = 49,     name = "Очки Wood Black",        node = IN_WEDDING_GLASSES_WOODBLACK,    buy_count = 1, id = 5 },--1339
};

WEDDING_SHOP_ITEM_NAMES_BY_NODES = { }
for i, v in pairs( WEDDING_SHOP_PARTS ) do
	WEDDING_SHOP_ITEM_NAMES_BY_NODES[ v.node ] = { name = v.name, id = i }
end
