REGISTERED_ITEMS.pack = {
	Give = function( player, params )
		local pPackConfig = REWARD_PACKS[ params.id ]
		if not pPackConfig then return end

		for k,v in pairs( pPackConfig.items ) do
			local pItemConf = REGISTERED_ITEMS[ v.type ]
			if pItemConf then
				pItemConf.Give( player, v )
			end
		end
	end;

	uiCreateItem = function( id, params, bg, fonts )
		local pPackConfig = REWARD_PACKS[ params.id ]

		local img = ibCreateContentImage( 0, 0, 360, 280, "pack", pPackConfig.id, bg ):center( 0, 0 )
		:ibSetInBoundSize( 90, 90 )
		:center()
		
		return img
	end;

	uiCreateRewardItem = function( id, params, bg, fonts )
		local pPackConfig = REWARD_PACKS[ params.id ]
		local img = ibCreateContentImage( 0, 0, 800, 270, "pack", pPackConfig.id, bg ):center( )

		-- Items
		local px = 0
		for k,v in pairs( pPackConfig.items ) do
			local desc_data = REGISTERED_ITEMS[ v.type ] and REGISTERED_ITEMS[ v.type ].uiGetDescriptionData( v.type, v )
			local l_name = ibCreateLabel( px, 0, (k == 2 and 300 or 244), 40, desc_data and desc_data.title or "???", img, _, _, _, "center", "center", ibFonts.bold_16 )
			px = px + (k == 2 and 300 or 244)
		end
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = params.name or "Пак";
		}
	end;
}

REWARD_PACKS = 
{
	mad_max = {
		name = "Безумный Макс",
		id = 18,

		items = 
		{
			{
				type = "skin",
				id = 269,
			},

			{ 
				type = "vehicle",
				id = 6560,

				tuning = 
				{
				    color = { 27, 24, 27 },
				    headlights_color = { 46, 46, 46 },
				    height_level = 0,
				    tuning_external = {
				        [7] = 2
				    },
				    installed_vinyls = { {
				            [3] = 3,
				            [7] = "peek8",
				            [10] = 60000,
				            [14] = "soft",
				            [15] = "peek8",
				            [16] = 1,
				            [17] = {
				                color = -13757684,
				                rotation = 0,
				                size = 1.1410257,
				                x = 738,
				                y = 512
				            }
				        }, {
				            [3] = 3,
				            [7] = "peek8",
				            [10] = 60000,
				            [14] = "soft",
				            [15] = "peek8",
				            [16] = 2,
				            [17] = {
				                color = -13361129,
				                mirror = false,
				                rotation = 0,
				                size = 1.2179487,
				                x = 362,
				                y = 545
				            }
				        }, {
				            [3] = 3,
				            [7] = "peek8",
				            [10] = 60000,
				            [14] = "soft",
				            [15] = "peek8",
				            [16] = 3,
				            [17] = {
				                color = -12114415,
				                mirror = false,
				                rotation = 295.38461,
				                size = 1.1410257,
				                x = 994,
				                y = 490
				            }
				        }, {
				            [3] = 3,
				            [7] = 12,
				            [10] = 130000,
				            [14] = "soft",
				            [15] = 12,
				            [16] = 4,
				            [17] = {
				                color = -14347255,
				                mirror = true,
				                rotation = 0,
				                size = 1.5,
				                x = 707,
				                y = 481
				            }
				        }, {
				            [3] = 3,
				            [7] = 12,
				            [10] = 130000,
				            [14] = "soft",
				            [15] = 12,
				            [16] = 5,
				            [17] = {
				                color = -14478575,
				                rotation = 0,
				                size = 1.5,
				                x = 109,
				                y = 536
				            }
				        }, {
				            [3] = 3,
				            [7] = "mirage2",
				            [10] = 76500,
				            [14] = "soft",
				            [15] = "mirage2",
				            [16] = 6,
				            [17] = {
				                color = -12509162,
				                mirror = true,
				                rotation = 184.61539,
				                size = 1.8846154,
				                x = 641,
				                y = 862
				            }
				        }, {
				            [3] = 3,
				            [7] = "dlf5",
				            [10] = 95000,
				            [14] = "soft",
				            [15] = "dlf5",
				            [16] = 7,
				            [17] = {
				                color = -13359850,
				                mirror = true,
				                rotation = 0,
				                size = 0.52564102,
				                x = 170,
				                y = 765
				            }
				        }, {
				            [3] = 3,
				            [7] = "mirage2",
				            [10] = 76500,
				            [14] = "soft",
				            [15] = "mirage2",
				            [16] = 8,
				            [17] = {
				                color = -11721190,
				                mirror = false,
				                rotation = 156.92308,
				                size = 1.4743589,
				                x = 582,
				                y = 222
				            }
				        }, {
				            [3] = 3,
				            [7] = "mirage2",
				            [10] = 76500,
				            [14] = "soft",
				            [15] = "mirage2",
				            [16] = 9,
				            [17] = {
				                color = -12115176,
				                rotation = 246.15384,
				                size = 1.0128205,
				                x = 918,
				                y = 535
				            }
				        } },
				    wheels = 1076,
				    wheels_camber = { 23, 38 },
				    wheels_offset = { 0, 0 },
				    wheels_width = { 0, 0 },
				    windows_color = { 0, 0, 0, 120 }
				}
			},

			{
				type = "tuning_case",
				id = 3,
				count = 1,
				class = "C",
				subtype = 1,
			},
		}
	},

	buran = {
		name = "Буран",
		id = 21,

		items = 
		{
			{
				type = "skin",
				id = 122,
			},

			{ 
				type = "vehicle",
				id = 560,

				tuning = 
				{
					color = { 0, 70, 147 },
					headlights_color = { 1, 122, 255 },
					height_level = 0,
					tuning_external = {
					    [2] = 3,
					    [4] = 2,
					    [5] = 4,
					    [6] = 5,
					    [7] = 8,
					    [8] = 2,
					    [10] = 4,
					    [13] = 3
					},
					installed_vinyls = { {
					        [3] = 2,
					        [7] = "peek8",
					        [10] = 45000,
					        [14] = "soft",
					        [15] = "peek8",
					        [16] = 1,
					        [17] = {
					            color = -16751664,
					            mirror = true,
					            rotation = 227.69231,
					            size = 0.85897434,
					            x = 486,
					            y = 354
					        }
					    }, {
					        [3] = 2,
					        [7] = "peek8",
					        [10] = 45000,
					        [14] = "soft",
					        [15] = "peek8",
					        [16] = 2,
					        [17] = {
					            color = -16752743,
					            mirror = false,
					            rotation = 58.46154,
					            size = 0.88461536,
					            x = 400,
					            y = 746
					        }
					    }, {
					        [3] = 2,
					        [7] = "peek8",
					        [10] = 45000,
					        [14] = "soft",
					        [15] = "peek8",
					        [16] = 3,
					        [17] = {
					            color = -16753471,
					            rotation = 0,
					            size = 0.93589741,
					            x = 806,
					            y = 529
					        }
					    }, {
					        [3] = 2,
					        [7] = 32,
					        [10] = 82500,
					        [14] = "soft",
					        [15] = 32,
					        [16] = 4,
					        [17] = {
					            color = -16777216,
					            rotation = 0,
					            size = 1.8333334,
					            x = 335,
					            y = 512
					        }
					    }, {
					        [3] = 2,
					        [7] = 12,
					        [10] = 97500,
					        [14] = "soft",
					        [15] = 12,
					        [16] = 5,
					        [17] = {
					            color = -15131615,
					            rotation = 196.92308,
					            size = 0.83910251,
					            x = 615,
					            y = 518
					        }
					    } },
					wheels_camber = { 0, 0 },
					wheels_offset = { 0, 0 },
					wheels_width = { 0, 0 },
					windows_color = { 0, 0, 0, 250 }
				}
			},

			{
				type = "tuning_case",
				id = 3,
				count = 1,
				class = "B",
				subtype = 1,
			},
		}
	},

	forsage = {
		name = "Форсаж 2",
		id = 3,

		items = 
		{
			{
				type = "skin",
				id = 205,
			},

			{ 
				type = "vehicle",
				id = 587,
				variant = 2,

				tuning = 
				{
					color = { 133, 131, 131 },
					headlights_color = { 53, 131, 255 },
					height_level = 0,
					tuning_external = {
					    [5] = 2,
					    [6] = 2,
					    [10] = 2
					},
					installed_vinyls = {
					    [10] = {
					        [3] = 3,
					        [7] = "skyline1",
					        [10] = 68000,
					        [14] = "soft",
					        [15] = "skyline1",
					        [16] = 10,
					        [17] = {
					            color = -16684289,
					            mirror = true,
					            rotation = 352.79999,
					            size = 1.53,
					            x = 529,
					            y = 767
					        }
					    },
					    [11] = {
					        [3] = 3,
					        [7] = "skyline1",
					        [10] = 68000,
					        [14] = "soft",
					        [15] = "skyline1",
					        [16] = 11,
					        [17] = {
					            color = -16684289,
					            rotation = 187.39999,
					            size = 1.545,
					            x = 528,
					            y = 256
					        }
					    },
					    [12] = {
					        [3] = 3,
					        [7] = "CAMARO_CS_CAMARO",
					        [10] = 170000,
					        [14] = "soft",
					        [15] = "CAMARO_CS_CAMARO",
					        [16] = 12,
					        [17] = {
					            rotation = 90.361542,
					            size = 1.5375,
					            x = 512,
					            y = 512
					        }
					    }
					},
					wheels_camber = { 0, 0 },
					wheels_offset = { 0, 0 },
					wheels_width = { 0, 0 },
					windows_color = { 0, 0, 0, 180 }
				}
			},

			{
				type = "tuning_case",
				id = 3,
				count = 1,
				class = "D",
				subtype = 1,
				tier = 1,
			},
		}
	},

	ninja = {
		name = "Ниндзя",
		id = 4,

		items = 
		{
			{
				type = "skin",
				id = 121,
			},

			{ 
				type = "vehicle",
				id = 521,

				tuning = 
				{ 
					color = { 255, 180, 1 },
					headlights_color = {},
					height_level = 0,
					tuning_external = {},
					installed_vinyls = {},
					wheels_camber = { 0, 0 },
					wheels_offset = { 0, 0 },
					wheels_width = { 0, 0 },
					windows_color = { 0, 0, 0, 120 }
				}
			},

			{
				type = "tuning_case",
				id = 3,
				count = 2,
				class = "M",
				subtype = 1,
			},
		}
	},
}