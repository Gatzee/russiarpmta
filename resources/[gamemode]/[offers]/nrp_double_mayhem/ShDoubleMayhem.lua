loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )
Extend( "ShAccessories" )

enum "ePackState" {
	"PACK_STATE_PURCHASED",
    "PACK_STATE_TAKE",
}

OFFER_NAME = "double_mayhem_universal"
OFFER_PACK_ID = 907

OFFER_NAME_RU = "Нео-нуарный разнос"

-- Для аналитики
PACKS_STRING_ID = {
    --"gang_pack",
    --"thief_pack",
	"noir_pack",
	"neon_pack",
}

OFFER_CONFIG = {
	packs = {
		--[[
		[ PACKS_STRING_ID[ 1 ] ] = {
			name = "пак Банд",
			cost = 1534,
			cost_original = 2788,
			items = {
				{
					type = "case",
					cost = 0,
					cost_original = 795,
					params = {
						id = "zabiving",
						name = "Кейс \"Забивочный\"",
						count = 5,
					},
				},
				{
					type = "case",
					cost = 0,
					cost_original = 1495,
					params = {
						id = "jailed",
						name = "Кейс \"Преступники\"",
						count = 3,
					},
				},
				{
					type = "repairbox",
					cost = 0,
					cost_original = 25,
					params = {
						count = 10
					}
				},
				{
					type = "box",
					cost = 0,
					cost_original = 149,
					params = {
                        number = 1,
						items = {
							premium = { days = 1 },
							firstaid = { count = 1 },
							repairbox = { count = 12 },
							jailkeys = { count = 3 },
						},
					},
				},
                {
					type = "vinyl",
					cost = 169000,
					cost_original = 169,
					name = "outlaw",
					params = {
						id = "s116"
					}
				},
			},
		},
		[ PACKS_STRING_ID[ 2 ] ] = {
			name = "пак Мафии",
			cost = 490,
			cost_original = 790,
			items = {
                {
					type = "box",
					cost = 0,
					cost_original = 149,
					params = {
                        number = 1,
						items = {
							premium = { days = 1 },
							firstaid = { count = 1 },
							repairbox = { count = 7 },
							jailkeys = { count = 3 },
						}
					},
				},
				{
					type = "case",
					cost = 0,
					cost_original = 149,
					params = {
						id = "brigada",
						name = "Кейс \"Бригада\"",
						count = 3,
					},
				},
                {
					type = "repairbox",
					cost = 0,
					cost_original = 25,
					params = {
						count = 5,
					}
				},
				{
					cost = 69000,
					cost_original = 69,
					name = "cap6",
					type = "accessory",
					params = {
                        id = "cap6",
						model = 2220,
					}
				},
			},
		},
		]]
		[ PACKS_STRING_ID[ 1 ] ] = {
			name = "пак Нуара",
			cost = 1390,
			cost_original = 2673,
			items = {
				{
					type = "case",
					cost = 0,
					cost_original = 349,
					params = {
						id = "drive",
						name = "Кейс \"Драйвовый\"",
						count = 2,
					},
				},
				{
					type = "case",
					cost = 0,
					cost_original = 499,
					params = {
						id = "noir",
						name = "Кейс \"Нуар\"",
						count = 3,
					},
				},
				{
					type = "repairbox",
					cost = 0,
					cost_original = 25,
					params = {
						count = 10
					}
				},
				{
					type = "box",
					cost = 0,
					cost_original = 149,
					params = {
						number = 1,
						items = {
							premium = { days = 1 },
							firstaid = { count = 1 },
							repairbox = { count = 7 },
							jailkeys = { count = 3 },
						},
					},
				},
				{
					type = "vinyl",
					cost = 79000,
					cost_original = 79,
					name = "outlaw",
					params = {
						id = "s26"
					}
				},
			},
		},
		[ PACKS_STRING_ID[ 2 ] ] = {
			name = "пак Неона",
			cost = 546,
			cost_original = 880,
			items = {
				{
					type = "box",
					cost = 0,
					cost_original = 149,
					params = {
						number = 1,
						items = {
							premium = { days = 1 },
							firstaid = { count = 1 },
							repairbox = { count = 7 },
							jailkeys = { count = 3 },
						}
					},
				},
				{
					type = "case",
					cost = 0,
					cost_original = 179,
					params = {
						id = "cyberpunk",
						name = "Кейс \"Киберпанк\"",
						count = 3,
					},
				},
				{
					type = "repairbox",
					cost = 0,
					cost_original = 25,
					params = {
						count = 5,
					}
				},
				{
					type = "vinyl",
					cost = 69000,
					cost_original = 69,
					name = "outlaw",
					params = {
						id = "s69"
					}
				},
			},
		},
	},
	
	--gift = {
	--	cost = 2990,
    --    type = "vehicle",
	--	name = "Mercedes-Benz W124(E500)",
	--	params = {
	--		model = 6598
	--	},
	--},

	gift = {
		cost = 1490,
		type = "vehicle",
		name = "Dodge Charger",
		params = {
			model = 419
		},
	},
}