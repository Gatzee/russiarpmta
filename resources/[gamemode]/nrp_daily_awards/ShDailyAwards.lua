loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShVehicle" )
Extend( "ShVehicleConfig" )
Extend( "ShSkin" )
Extend( "ShAccessories" )

REQUIRED_DAILY_PLAYTIME = 15 -- min

INVENTORY_ITEM_IMAGES = {
	[ IN_FIRSTAID ] = "files/img/items/firstaid.png",
	[ IN_REPAIRBOX ] = "files/img/items/repairbox.png",
	[ IN_CANISTER ] = "files/img/items/fuel.png",
	[ IN_FOOD_LUNCHBOX ] = "files/img/items/food.png",
}

BOOSTER_IMAGES = {
	[ BOOSTER_DOUBLE_EXP ] = "files/img/items/x2.png",
	[ BOOSTER_DOUBLE_MONEY ] = "files/img/items/x2.png",
	[ BOOSTER_EXTENDED_SHIFT ] = "files/img/items/plus_one.png",
}

POSSIBLE_ITEMS = {
	exp = {
		block_size = { 2, 2 },
		block_priority = 1,

		func_receive = function( self, pPlayer, params )
			return pPlayer:GiveExp( params.count, "daily_reward" )
		end,

		func_draw = function( self, params, r_type )
			local area, size_x, size_y = GenerateItemArea(params.size or table.copy(self.block_size), r_type )
			local label = ibCreateLabel( 0, 0, size_x, size_y, format_price(params.count), area, 0xffffd735, _, _, "center", "center" )
			:ibData( "font", ibFonts.bold_28 ):ibData( "disabled", true )
			local icon = ibCreateImage( 0, 0, 63, 50, "files/img/items/exp.png", area )

			label:center( 0, -17 )
			icon:center( 0, 17 )

			return { area = area, size = table.copy(self.block_size), priority = self.priority, position = { 1, 1 } }
		end,
	},

	money = {
		block_size = { 2, 2 },
		block_priority = 1,

		func_receive = function( self, pPlayer, params )
			return pPlayer:GiveMoney( params.count, "daily_reward" )
		end,

		func_draw = function( self, params, r_type )
			local area, size_x, size_y = GenerateItemArea(params.size or table.copy(self.block_size), r_type )
			local label = ibCreateLabel( 0, 0, size_x, size_y, format_price(params.count), area, 0xff23f965, _, _, "center", "center" )
			:ibData( "font", ibFonts.bold_28 ):ibData( "disabled", true )
			local icon = ibCreateImage( 0, 0, 48, 43, "files/img/items/money.png", area )

			label:center( 0, -17 )
			icon:center( 0, 17 )

			return { area = area, size = table.copy(self.block_size), priority = self.priority, position = { 1, 1 } }
		end,
	},

	premium = {
		block_size = { 3, 3 },

		func_receive = function( self, pPlayer, params )
			return pPlayer:GivePremiumExpirationTime( params.days )
		end,

		func_draw = function( self, params, r_type )
			local area, size_x, size_y = GenerateItemArea(params.size or table.copy(self.block_size), r_type )

			local img = ibCreateImage( 0, 0, 0, 0, "files/img/items/premium.png", area ):ibSetRealSize():ibData("disabled", true):center()
			img:ibData("py", img:ibData("py")-25)

			local label = ibCreateLabel( 0, size_y-size_y/3+10, size_x, 0, "Премиум на "..params.days.."д.", area, 0xFFFFFFFF, _, _, "center", "center",  ibFonts.regular_16):ibData("disabled", true)

			return { area = area, size = table.copy(self.block_size), priority = self.priority, position = { 1, 1 } }
		end,
	},

	item = {
		block_size = { 1, 2 },
		block_priority = 1,

		func_receive = function( self, pPlayer, params )
			return pPlayer:InventoryAddItem( params.id, params.attributes, params.count or 1 )
		end,

		func_draw = function( self, params, r_type )
			local area, size_x, size_y = GenerateItemArea(params.size or table.copy(self.block_size), r_type )
			local img = ibCreateImage( 0, 0, 0, 0, INVENTORY_ITEM_IMAGES[ params.id ], area ):ibSetRealSize():center():ibData("disabled", true)
			img:ibData("py", img:ibData("py")+10)

			if params.count and params.count > 1 then
				ibCreateLabel( img:ibData( "sx" ) - 16, 0, 0, 0, "x"..params.count, img, 0xffffffff, _, _, "left", "top" ):ibData("font", ibFonts.bold_14):ibData("disabled", true)
			end

			return { area = area, size = table.copy(self.block_size), priority = self.priority, position = { 1, 1 } }
		end,
	},

	skin = {
		block_size = { 1, 2 },
		block_priority = 1,

		func_receive = function( self, pPlayer, params )
			return pPlayer:GiveSkin( params.id )
		end,

		func_draw = function( self, params, r_type )
			local area, size_x, size_y = GenerateItemArea(params.size or table.copy(self.block_size), r_type )
			local img = ibCreateImage( 0, 0, 0, 0, "files/img/items/skins/" .. params.id .. ".png", area )
			:ibSetRealSize( ):center( ):ibAttachTooltip( "Скин \"" .. SKINS_NAMES[ params.id ] .. "\"" )

			img:ibData("py", img:ibData("py")+10)

			return { area = area, size = table.copy(self.block_size), priority = self.priority, position = { 1, 1 } }
		end,
	},

	vinyl = {
		block_size = { 1, 2 },
		block_priority = 1,

		requested_params = { P_CLASS },

		func_receive = function( self, pPlayer, params )
			return client:GiveVinyl( {
				[ P_PRICE_TYPE ] = "race",
				[ P_IMAGE ]      = "s" .. params.id,
				[ P_CLASS ]      = params[ 3 ],
				[ P_NAME ]       = "s" .. params.id,
				[ P_PRICE ]      = 0,
			} )
		end,

		func_request_params  = function(self, pPlayer, item )
			local vehicles = pPlayer:GetVehicles( true, true )
			local unparked_vehicles = { }
			local player_classes = { }
			for i, v in pairs( vehicles ) do
				if not v:GetParked( ) then
					table.insert( unparked_vehicles, v )
					player_classes[ v:GetTier() ] = true
				end
			end
			table.sort( unparked_vehicles, function( a, b ) return a:GetTier( ) > b:GetTier( ) end )

			local selected_vehicle = unparked_vehicles[ 1 ]

			local iClass = 3

			if not selected_vehicle or selected_vehicle.model == 468 then
				iClass = item.available_classes[ math.random(#item.available_classes) ]
			else
				iClass = selected_vehicle:GetTier( )
			end

			local pDataToSend =
			{
				list = item.available_classes,
				selected_value = iClass,
				player_classes = player_classes,
			}

			triggerClientEvent(pPlayer, "DA:ShowUI_Selector", resourceRoot, true, pDataToSend )
		end,

		func_draw = function( self, params, r_type )
			local area, size_x, size_y = GenerateItemArea(params.size or table.copy(self.block_size), r_type )
			local img = ibCreateImage( 0, 0, 0, 0, "files/img/items/vinyls/"..params.id..".png", area )
			:ibSetRealSize( ):center( ):ibAttachTooltip( "Винил" )
			img:ibData( "py", img:ibData( "py" ) + 10 )

			return { area = area, size = table.copy(self.block_size), priority = self.priority, position = { 1, 1 } }
		end,
	},

	accessory = {
		block_size = { 1, 2 },
		block_priority = 1,

		func_receive = function( self, pPlayer, params )
			return pPlayer:AddOwnedAccessory( params.id )
		end,

		func_draw = function( self, params, r_type )
			local area, size_x, size_y = GenerateItemArea(params.size or table.copy(self.block_size), r_type )
			local img = ibCreateImage( 0, 0, 0, 0, "files/img/items/accessories/"..params.id..".png", area )
			:ibSetRealSize( ):center( ):ibAttachTooltip( CONST_ACCESSORIES_INFO[ params.id ] and CONST_ACCESSORIES_INFO[ params.id ].name or "Аксессуар" )
			img:ibData( "py", img:ibData( "py" ) + 10 )

			return { area = area, size = table.copy(self.block_size), priority = self.priority, position = { 1, 1 } }
		end,
	},

	roulette_coin = {
		block_size = { 2, 2 },

		func_receive = function( self, pPlayer, params )
			return pPlayer:GiveCoins(params[1], params[2] and "gold" or "default", "DAILY_AWARD", "NRPDszx5x")
		end,

		func_draw = function( self, params, r_type )
			local area, size_x, size_y = GenerateItemArea(params.size or table.copy(self.block_size), r_type )

			local label = ibCreateLabel( 0, 10, size_x-52, size_y, format_price(params[1]), area, 0xffffffff, _, _, "center", "center" ):ibData("font", ibFonts.bold_32):ibData("disabled", true)
			ibCreateImage( size_x/2+label:width()/2-25, size_y/2-25+10, 51, 51, params[2] and "files/img/items/coin_gold.png" or "files/img/items/coin.png", area )
			:ibAttachTooltip( params[2] and "Жетон для премиум\n колеса фортуны" or "Жетон для\n колеса фортуны" )

			return { area = area, size = table.copy(self.block_size), priority = self.priority, position = { 1, 1 } }
		end,
	},

	booster = {
		block_size = { 2, 2 },

		block_priority = 2,

		func_receive = function( self, pPlayer, params )
			return pPlayer:ActivateBooster( params.id, params.duration )
		end,

		func_draw = function( self, params, r_type )
			local area, size_x, size_y = GenerateItemArea(params.size or table.copy(self.block_size), r_type )
			local img = ibCreateImage( 0, 0, 0, 0, BOOSTER_IMAGES[ params.id ], area )
			:ibSetRealSize( ):ibData( "disabled", true ):center( )
			img:ibData( "py", img:ibData( "py" ) - 5 )

			local duration = params.duration or BOOSTERS_LIST[ params.id ].iDuration
			local hour = math.floor( duration / 3600 )
			local min = math.floor( ( duration - hour * 3600 ) / 60 )
			local format = min > 0 and "%2d ч. %02d мин." or "%2d ч."
			local converted_desc = string.format( BOOSTERS_LIST[ params.id ].sDesc, string.format( format, hour, min ) )

			ibCreateLabel( 0, size_y-size_y / 3.5, size_x, 0, converted_desc, area, 0xFFFFFFFF, _, _, "center", "center",  ibFonts.regular_13):ibData("disabled", true)

			return { area = area, size = table.copy(self.block_size), priority = self.priority, position = { 1, 1 } }
		end,
	},
	
	booster_double_exp_money = {
		block_size = { 2, 2 },

		func_receive = function( self, pPlayer, params )
			return
				pPlayer:ActivateBooster( BOOSTER_DOUBLE_EXP, params.duration )
					and
				pPlayer:ActivateBooster( BOOSTER_DOUBLE_MONEY, params.duration )
		end,

		func_draw = function( self, params, r_type )
			local area, size_x, size_y = GenerateItemArea(params.size or table.copy(self.block_size), r_type )
			local img = ibCreateImage( 0, 0, 0, 0, BOOSTER_IMAGES[ BOOSTER_DOUBLE_EXP ], area ):ibSetRealSize():ibData("disabled", true):center()
			img:ibData("py", img:ibData("py") - 5)

			local duration = params.duration
			local hour = math.floor( duration / 3600 )
			local min = math.floor( ( duration - hour * 3600 ) / 60 )
			local format = min > 0 and "%2d ч. %02d мин." or "%2d ч."
			local converted_desc = string.format( "Денег и опыта\nна работе на %s", string.format( format, hour, min ) )

			ibCreateLabel( 0, size_y-size_y / 3.5, size_x, 0, converted_desc, area, 0xFFFFFFFF, _, _, "center", "center",  ibFonts.regular_13):ibData("disabled", true)

			return { area = area, size = table.copy(self.block_size), priority = self.priority, position = { 1, 1 } }
		end,
	},

	tuning_part = {
		block_size = { 1, 2 },

		requested_params = { P_CLASS },

		func_request_params  = function(self, pPlayer, item )
			local vehicles = pPlayer:GetVehicles( true, true )
			local unparked_vehicles = { }
			local player_classes = { }
			for i, v in pairs( vehicles ) do
				table.insert( unparked_vehicles, v )
				player_classes[ v:GetTier() ] = true
			end
			table.sort( unparked_vehicles, function( a, b ) return a:GetTier( ) > b:GetTier( ) end )

			local selected_vehicle = unparked_vehicles[ 1 ]

			local iClass = 3

			if not selected_vehicle or selected_vehicle.model == 468 then
				iClass = item.available_classes[ math.random(#item.available_classes) ]
			else
				iClass = selected_vehicle:GetTier( )
			end

			local pDataToSend = 
			{
				list = item.available_classes,
				selected_value = iClass,
				player_classes = player_classes,
			}

			triggerClientEvent(pPlayer, "DA:ShowUI_Selector", resourceRoot, true, pDataToSend )
		end,

		func_receive = function( self, pPlayer, params )
			local parts = exports.nrp_tuning_internal_parts:getTuningPartsIDByParams( { type = params.type, category = params.category } )

			if #parts > 0 then
				local id = parts[ math.random( 1, #parts ) ]
				local tier = params[ 3 ]
				local part = getTuningPartByID( id, tier )

				pPlayer:GiveTuningPart( tier, id )
				pPlayer:ShowRewards( { type = "tuning_internal", value = part } )
			end
		end,

		func_draw = function( self, params, r_type )
			local area = GenerateItemArea( params.size or table.copy( self.block_size ), r_type )

			local img = ibCreateImage( 0, 0, 0, 0, ":nrp_tuning_internal_parts/img/" .. PARTS_IMAGE_NAMES[ params.type ] .. ".png", area )
			:ibSetRealSize( ):center( ):ibAttachTooltip( PARTS_NAMES[ params.type ] )

			img:ibData( "py", img:ibData( "py" ) + 10 )

			return { area = area, size = table.copy(self.block_size), priority = self.priority, position = { 1, 1 } }
		end,
	},

	vehicle = {
		block_size = { 2, 2 },

		block_priority = 0,

		func_receive = function( self, player, params )
			local vehicles = player:GetVehicles()
			if params.temp_days then
				for _, vehicle in pairs( vehicles ) do
					if params.model == vehicle.model then
						local temp_timeout = vehicle:GetPermanentData( "temp_timeout" )
						if temp_timeout and temp_timeout >= getRealTimestamp( ) then
							vehicle:SetPermanentData( "temp_timeout", temp_timeout + params.temp_days * 24 * 60 * 60 )
							triggerEvent( "CheckTemporaryVehicle", vehicle )
							return
						end
					end
				end
			else
				for _, vehicle in pairs( vehicles ) do
					local temp_timeout = vehicle:GetPermanentData( "temp_timeout" )
					if params.model == vehicle.model and temp_timeout and temp_timeout > 0 then
						exports.nrp_vehicle:DestroyForever( vehicle:GetID( ) )
					end
				end
			end

			local sOwnerPID = "p:" .. player:GetUserID()
			local variant = params.variant or 1
			local pRow = {
				model 		= params.model,
				variant		= variant,
				x			= 0,
				y			= 0,
				z			= 0,
				rx			= 0,
				ry			= 0,
				rz			= 0,
				owner_pid	= sOwnerPID,
				color		= { 255, 255, 255 },
				temp_timeout = ( params.temp_days and ( getRealTimestamp( ) + params.temp_days * 24 * 60 * 60 ) )
			}
		
			exports.nrp_vehicle:AddVehicle( pRow, true, "OnDailyAwardsVehicleAdded", {
				player = player,
				cost = VEHICLE_CONFIG[ params.model ].variants[ variant ].cost,
				temp_days = params.temp_days,
				temp_timeout = pRow.temp_timeout,
				discount_params = params.discount_params or false
			} )
		end,

		func_draw = function( self, params, r_type )
			local area, size_x, size_y = GenerateItemArea(params.size or table.copy(self.block_size), r_type )
			local tooltip = VEHICLE_CONFIG[ params.model ].model
			local duration_seconds = params.temp_days and ( params.temp_days * 24 * 60 * 60 )

			if duration_seconds then
				tooltip = tooltip .. " на " .. getHumanTimeString( duration_seconds / 60, false, true )
			end

			local img = ibCreateImage( 0, 0, 100, 50, ":nrp_vehicle_passport/img/vehicles/" .. params.model .. ".png", area )
			:center( ):ibSetRealSize( ):ibAttachTooltip( tooltip )


			local sx, sy = img:ibData( "sx" ), img:ibData( "sy" )
			local prop = ( sx / 100 )

			img:ibBatchData( { sx = sx / prop, sy = sy / prop } )
			img:ibData( "py", img:ibData( "py" ) + 13 + ( params.y_offset and params.y_offset or 0 ) )

			return { area = area, size = table.copy(self.block_size), priority = self.priority, position = { 1, 1 } }
		end,
	},
}