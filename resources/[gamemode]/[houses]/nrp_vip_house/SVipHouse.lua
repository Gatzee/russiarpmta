loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )
Extend( "SInterior" )
Extend( "SPlayerOffline" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "ShApartments" )
Extend( "ShVipHouses" )

SDB_SEND_CONNECTIONS_STATS = true
Extend( "SDB" )

Extend( "ShTimelib" )
Extend( "ShHouseSale" )

VIP_HOUSES = {}
VIP_HOUSE_OWNERS = {}

DOOR_ELEMENTS = {}
LAST_DOOR_ID = 1

BLOCK_SALE_TIMESTAMP = 72 * 60 * 60

-- текущие коэффициенты на счетчики, можно будет менять через окно мэрии
REAL_METERING_DEVICE_FACTOR = {
    [ CONST_METERING_DEVICE_TYPE.NOT_METER ] = DEFAULT_METERING_DEVICE_FACTOR[ CONST_METERING_DEVICE_TYPE.NOT_METER ],
    [ CONST_METERING_DEVICE_TYPE.LOW       ] = DEFAULT_METERING_DEVICE_FACTOR[ CONST_METERING_DEVICE_TYPE.LOW ],
    [ CONST_METERING_DEVICE_TYPE.MEDIUM    ] = DEFAULT_METERING_DEVICE_FACTOR[ CONST_METERING_DEVICE_TYPE.MEDIUM ],
    [ CONST_METERING_DEVICE_TYPE.HIGH      ] = DEFAULT_METERING_DEVICE_FACTOR[ CONST_METERING_DEVICE_TYPE.HIGH ],
}

addEventHandler("onResourceStart", resourceRoot, function()
	DB:createTable( "nrp_viphouses", {
		{ Field = "id",						Type = "int(11) unsigned",		Null = "NO",	Key = "PRI", Extra = "auto_increment"  },
		{ Field = "hid",					Type = "text",					Null = "YES",	Key = "",  },
		{ Field = "owner",					Type = "int(11) unsigned",		Null = "NO",	Key = "",		Default = 0 },
		{ Field = "sale_state",				Type = "smallint(3)",			Null = "NO",	Key = "",		Default = 0	},
		{ Field = "meter_type",				Type = "smallint(3)",			Null = "NO",	Key = "",		Default = 0	},
		{ Field = "settings",				Type = "text",					Null = "NO",	Key = "" },
		{ Field = "inventory_data",			Type = "text",					Null = "YES",	Key = "" },
		{ Field = "inventory_expand",		Type = "smallint(11) unsigned",	Null = "YES",	Key = "",		Default = 0 },
	} )
	for k,v in pairs( VIP_HOUSES_LIST ) do
		CreateVipHouse( v, k )
	end
end)

function CreateSectionalDoor( config )
	if not config.objects then
		config.objects = { config }
	end

	local self = config
	self.key = self.key or "lalt"
	self.doors = {}
	self.id = LAST_DOOR_ID
	self.duration = self.duration or 1000

	for k,v in pairs(config.objects) do
		local door = v
		door.object = createObject( v.model, v.x, v.y, v.z, v.rx or 0, v.ry or 0, v.rz or 0 )
		door.rx = door.rx or 0
		door.ry = door.ry or 0
		door.rz = door.rz or 0
		door.move = door.move or { rz = 90 }
		table.insert(self.doors, door)
	end

	self.colshape = createColSphere( self.x, self.y, self.z, self.radius or 2 )

	if self.radial_enabled then
		setElementData( self.colshape, "radial_door", { self.id, self.name or "дверь" } )
	end

	self.unbindAtDeathPlayer = function()
		removeEventHandler( "onPlayerWasted", source, self.unbindAtDeathPlayer )
		unbindKey( source, self.key, "down", self.Switch)
	end

	addEventHandler("onColShapeHit", self.colshape, function( pElement, dim )
		if not dim then return end
		if getElementType(pElement) == "player" then
			if not self.vehicle_allowed and pElement.vehicle then return end
			bindKey( pElement, self.key, "down", self.Switch)
			pElement:ShowInfo( "ALT Взаимодействие" )
			addEventHandler( "onPlayerWasted", pElement, self.unbindAtDeathPlayer )
		end
	end)

	addEventHandler("onColShapeLeave", self.colshape, function( pElement, dim )
		if getElementType(pElement) == "player" then
			unbindKey( pElement, self.key, "down", self.Switch)
			removeEventHandler( "onPlayerWasted", pElement, self.unbindAtDeathPlayer )
		end
	end)

	self.Open = function( self )
		if self:IsMoving() then return end
		if self.opened then return end
		for k,v in pairs(self.doors) do
			if not v.visual then
				moveObject( v.object, self.duration, v.x + (v.move.x or 0), v.y + (v.move.y or 0), v.z + (v.move.z or 0), v.move.rx or v.rx, v.move.ry or v.ry, v.move.rz or v.rz)
				setTimer( setElementCollisionsEnabled, self.duration/2, 1, v.object, false )
				setTimer( setElementCollisionsEnabled, self.duration, 1, v.object, true )
			end
		end
		self.next_action = getTickCount() + self.duration
		self.opened = true
	end

	self.Close = function( self )
		if self:IsMoving() then return end
		if not self.opened then return end
		for k,v in pairs(self.doors) do
			if not v.visual then
				moveObject( v.object, self.duration, v.x, v.y, v.z, -(v.move.rx or 0), -(v.move.ry or 0), -(v.move.rz or 0) )
				setElementCollisionsEnabled( v.object, false )
				setTimer( setElementCollisionsEnabled, self.duration/2, 1, v.object, true )
			end
		end
		self.next_action = getTickCount() + self.duration
		self.opened = false
	end

	self.Switch = function( player )
		if self.OnSwitch and not self:OnSwitch( player ) then return end
		return self.opened and self:Close() or self:Open()
	end

	self.IsMoving = function( self )
		return (self.next_action or 0) >= getTickCount()
	end

	DOOR_ELEMENTS[LAST_DOOR_ID] = self
	LAST_DOOR_ID = LAST_DOOR_ID + 1
	return self
end

function OnDoorRadialInteraction( pPlayer, id )
	local pDoor = DOOR_ELEMENTS[id]
	if pDoor then
		pDoor.Switch( pPlayer )
	end
end
addEvent("OnDoorRadialInteraction", true)
addEventHandler("OnDoorRadialInteraction", root, OnDoorRadialInteraction)

function GetRelativeConfig( conf )
	local pParent = table.copy( RELATIVE_CONFIGS[ conf.relative ] )

	local vecCenter = Vector3( pParent.relative_center.x, pParent.relative_center.y, pParent.relative_center.z )
	local vecRotation = Vector3( pParent.relative_center.rx, pParent.relative_center.ry, pParent.relative_center.rz )

	local vecNewCenter = Vector3( conf.relative_center.x, conf.relative_center.y, conf.relative_center.z )
	local vecNewRotation = Vector3( conf.relative_center.rx, conf.relative_center.ry, conf.relative_center.rz )

	for k,v in pairs(pParent.doors) do
		local vecPosition = Vector3( v.x, v.y, v.z )
		local vecRelativePosition = vecPosition - vecCenter
		local nX, nY = RotateVector( vecRelativePosition.x, vecRelativePosition.y, vecNewRotation.z )

		v.x = vecNewCenter.x + nX
		v.y = vecNewCenter.y + nY

		v.rz = ( v.rz or 0 ) + vecNewRotation.z

		if v.move then
			local rad = math.rad( vecNewRotation.z )
			local nx = (v.move.x or 0) * math.cos( rad ) - ( v.move.y or 0) * math.sin( rad )
			local ny = (v.move.x or 0) * math.sin( rad ) + ( v.move.y or 0) * math.cos( rad )

			v.move.x = nx
			v.move.y = ny
		end

		if v.objects then
			for i, obj in pairs( v.objects ) do
				local vecPosition = Vector3( obj.x, obj.y, obj.z )
				local vecRelativePosition = vecPosition - vecCenter
				local nX, nY = RotateVector( vecRelativePosition.x, vecRelativePosition.y, vecNewRotation.z )

				obj.x = vecNewCenter.x + nX
				obj.y = vecNewCenter.y + nY

				obj.rz = (obj.rz or 0) + vecNewRotation.z

				if obj.move then
					local rad = math.rad( vecNewRotation.z )
					local nx = (obj.move.x or 0) * math.cos( rad ) - ( obj.move.y or 0) * math.sin( rad )
					local ny = (obj.move.x or 0) * math.sin( rad ) + ( obj.move.y or 0) * math.cos( rad )

					obj.move.x = nx
					obj.move.y = ny
				end
			end
		end
	end

	local pRelativeKeysList = 
	{
		"reset_position",
		"spawn_position",
		"enter_marker_position",
		"sell_marker_position",
		"parking_marker_position",
		"control_marker_position",
		"bed_position",
		"wardrobe_position",
		"wardrobe_camera_position",
		"wardrobe_camera_target",
		"wardrobe_ped_position",
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

	if pParent.parking_marker_position and pParent.parking_marker_position.rot then
		conf.parking_marker_position.rot = (pParent.parking_marker_position.rot or 0) + vecNewRotation.z
	end
	
	conf.bed_rotation = (pParent.bed_rotation or 0) + vecNewRotation.z
	conf.wardrobe_ped_rotation = (pParent.wardrobe_ped_rotation or 0) + vecNewRotation.z

	for k,v in pairs( pParent.doors ) do
		table.insert( conf.doors, v )
	end

	conf.services_prefix = conf.services_prefix or pParent.services_prefix
	conf.services        = conf.services or pParent.services
	conf.cost            = conf.cost or pParent.cost
	conf.daily_cost      = conf.daily_cost or pParent.daily_cost
	conf.parking_slots   = conf.parking_slots or pParent.parking_slots
	conf.clothing_slots  = conf.clothing_slots or pParent.clothing_slots
	conf.img 			 = conf.img or pParent.img

	return conf
end

function RotateVector( x, y, angle )
	local rad = math.rad( angle )
	local nx = (x or 0) * math.cos( rad ) - (y or 0) * math.sin( rad )
	local ny = (x or 0) * math.sin( rad ) + (y or 0) * math.cos( rad )

	return nx, ny
end

function CreateVipHouse( config, index )
	local self = { }
	self.config = config
	self.hid = config.hid

	self.id = index
	self.dimension = 5000 + self.id

	self.doors = { }
	self.purchased_services = { }

	if config.relative then
		config = GetRelativeConfig( config )
	end

	for k,v in pairs( config.doors ) do
		local door = CreateSectionalDoor( v )
		door.house_id = self.hid
		door.OnSwitch = function( self, pPlayer )
			if PlayerHasAccesToVipHouse( pPlayer, self.house_id ) then
				return true
			else
				pPlayer:ShowError( "Ты не владелец" )
				return false
			end
		end
		table.insert(self.doors, door)
	end

	self.ShowControl = function( self, player, window )
		local config = self.config
		local services = table.copy( config.services )
		for i, v in pairs( services ) do
			if self.purchased_services[ i ] then 
				services[ i ].purchased = true 
			end
		end
		triggerClientEvent( player, "ShowViphouseControlUI", resourceRoot, 
			{ 
				hid             = self.hid,
				id              = self.id,
				name            = config.name,
				services        = services,
				metering_factor = REAL_METERING_DEVICE_FACTOR[ self.meter_type or 0 ],
				paid_days       = self.paid_days,
				window          = window,
			}
		)
	end

	self.IsPurchased = function( self )
		return self.owner and self.owner ~= 0
	end

	self.OnOwnerChange = function( self )
		if self:IsPurchased( ) then
			for i, v in pairs( self.doors ) do
				v:Close()
			end
			if isTimer( self.check_timer ) then killTimer( self.check_timer ) end
			self.check_timer = setTimer( self.CheckPaymentTime, 30 * 60 * 1000, 0, self.hid )
		else
			for i, v in pairs( self.doors ) do
				v:Open()
			end
			if isTimer( self.check_timer ) then killTimer( self.check_timer ) end
		end
	end

	self.Save = function( self )
		local owner = self.owner or 0
		local sale_state = self.sale_state or CONST_SALE_STATE.NOT_SALE
		local purchased_services = self.purchased_services
		local paid_days = self.paid_days or 1

		local settings = {
			purchased_services = purchased_services,
			paid_days = paid_days,
			paytime = self.paytime,
			owner_change_time = self.owner_change_time or 0,
		}

		if self.db_id then
			DB:exec(
				"UPDATE nrp_viphouses SET `owner` = ?, `sale_state` = ?, `settings` = ?, `inventory_data` = ?, `inventory_expand` = ? WHERE id = ?", 
				owner, sale_state, toJSON( settings, true ), toJSON( self.inventory_data, true ), self.inventory_expand, self.db_id
			)
		else
			DB:queryAsync( 
				function( query )
					local _, _, insert_id = query:poll( -1 )
					self.db_id = insert_id
				end, { },
				"REPLACE INTO nrp_viphouses ( `id`, `hid`, `owner`, `sale_state`, `settings`, `inventory_data`, inventory_expand ) VALUES ( ?, ?, ?, ?, ?, ?, ? )", 
				self.id, self.hid, owner, sale_state, toJSON( settings, true ), toJSON( self.inventory_data, true ), self.inventory_expand
			)
		end
	end

	self.Reset = function( self, without_saving )
		self.owner = 0
		self.purchased_services = { }
		self.paid_days = 1
		self.paytime = self.paytime or getRealTime( ).timestamp
		self.sale_state = CONST_SALE_STATE.NOT_SALE
		self.owner_change_time = getRealTime( ).timestamp
		self.inventory_data = {}
		self.inventory_expand = 0
		triggerEvent( "onHouseUpdate", resourceRoot, 0, self.id, self, self.config.inventory_max_weight )
		VIP_HOUSE_OWNERS[ self.hid ] = nil
		if not without_saving then
			self:Save( )
			self:OnOwnerChange( )
		end
	end

	self.Load = function( self )
		DB:queryAsync( 
			function( query, hid )
				local self = VIP_HOUSES[ hid ]

				local result = query:poll( -1 )
				if #result <= 0 then
					--iprint( "Nothing found, resetting" )
					self:Reset( )
					return 
				end
				local result = result[ 1 ]

				-- iprint( "Loading", result )

				self.db_id = result.id
				self.owner = tonumber( result.owner )

				local house_type = GetHouseTypeFromHID( self.hid )
				if ( house_type == CONST_HOUSE_TYPE.VILLA or house_type == CONST_HOUSE_TYPE.COTTAGE ) and self.owner and self.owner > 0 then
					VIP_HOUSE_OWNERS[ self.hid ] = exports.nrp_player_offline:GetOfflineDataFromUserID( self.owner, "nickname" )
				end

				local settings = result.settings and fromJSON( result.settings )

				self.purchased_services = { } 
				for i, v in pairs( settings.purchased_services or { } ) do
					self.purchased_services[ tonumber( i ) or i ] = v
				end

				self.inventory_data = result.inventory_data and fromJSON( result.inventory_data ) or {}
				self.inventory_expand = result.inventory_expand or 0

				self.paid_days = settings.paid_days or 1
				self.paytime = settings.paytime or getRealTime( ).timestamp
				self.owner_change_time = settings.owner_change_time or 0
				self.sale_state = result.sale_state or CONST_SALE_STATE.NOT_SALE

				self:OnOwnerChange( )
				self:Save( )

				triggerEvent( "onHouseUpdate", resourceRoot, 0, self.id, self, self.config.inventory_max_weight )
			end, { self.hid },
		"SELECT * FROM nrp_viphouses WHERE `hid`=?", self.hid )
	end

	self.CheckPaymentTime = function( hid )
		local self = VIP_HOUSES[ hid ]
		if not self:IsPurchased( ) then
			killTimer( sourceTimer )
			return
		end
		if self.paytime and self.paytime <= getRealTime().timestamp then
			self.paytime = self.paytime + 24 * 60 * 60
			self.paid_days = self.paid_days - 1

			local config = self.config
			
			-- Слёт випдома
			if self.paid_days <= ( config.dropoff_days or -15 ) then
				local is_first_owner = self.owner_change_time == 0
				local owned_time = is_first_owner and 0 or ( getRealTime().timestamp - self.owner_change_time )

				local metering_factor = REAL_METERING_DEVICE_FACTOR[ self.meter_type or 0 ] or 1
				local daily_cost = config.daily_cost * metering_factor
				local services = config.services
				for i, v in pairs( services ) do
					if self.purchased_services[ i ] then 
						daily_cost = daily_cost - services[ i ].reduction
					end
				end

				local debt = -self.paid_days * daily_cost
				local owner_id = self.owner
				
				local player = GetPlayer( owner_id, true )
				self.sale_state = CONST_SALE_STATE.NOT_SALE
				self:Reset( )

                -- обнуляем продажу на бирже недвижимости
                local resource = getResourceFromName( "nrp_house_sale" )
                if resource and getResourceState( resource ) == "running" then
                    local house_type = GetHouseTypeFromHID( self.hid )
                    local pData = {
                        hid                      = self.hid,
                        house_type               = house_type,
                        possible_buyer_id        = 0,
                        seller_id                = 0,
                        sale_state               = CONST_SALE_STATE.NOT_SALE,
                        total_rental_fee         = 0,
                        sale_publish_date        = 0,
                        sale_cost                = 0,
                        location_id              = GetLocationIDFromHID( self.hid, house_type ),
                    }
                    triggerEvent( "onChangeHouseSaleData", resourceRoot, self.hid, pData )
                end

				local price = config.cost * 0.4

				if player then
					player:ShowInfo( "Твой дом был забран коллекторами за долги и выставлен на повторную продажу" )
					onPlayerCompleteLogin_handler( player )
					triggerEvent( "CheckPlayerVehiclesSlots", player )
					player:GiveMoney( price, "viphouse_debt_sell", "flat" )
				else
					local query = DB:exec( "UPDATE nrp_players SET money=`money`+? WHERE id=?", price, owner_id)
					if not query then
						outputDebugString( "Error pay player", 1 )
					end
				end

				local str_type = config.village_class and "village" or (config.cottage_class and "cottage" or "country")
				local str_group = config.village_class and config.village_class or (config.cottage_class and config.cottage_class or config.country_class)
	
				triggerEvent( "onPlayerHouseLoss", player or resourceRoot, 
					{
						mortage_type = str_type,
						mortage_group = str_group,
						mortage_id = self.id,
						loss_reason = "service_debt",
						sum = debt,
						owned_days = math.floor( owned_time / ( 24 * 60 * 60 ) )  
					},
					not player and owner_id
				)
			else
				self:Save( )

				-- обновляем инфу на бирже об арендной плате
				if self.sale_state > CONST_SALE_STATE.NOT_SALE then
					local total_rental_fee = CalculateTotalRentalFee( self.hid )
					triggerEvent( "onUpdateTotalRentalFee", resourceRoot, hid, total_rental_fee )
				end
			end
		end
	end

	VIP_HOUSES[ self.hid ] = self
	VIP_HOUSES[ self.id ] = self

	self:Load( )

	return self
end

function onPlayerCompleteLogin_handler( player )
	local player = isElement( player ) and player or source

	local viphouse_ids = {}

	for i, v in pairs( VIP_HOUSES ) do
		if type( i ) == "number" and v.owner == player:GetUserID() then
			table.insert( viphouse_ids, v.id )
		end
	end

	player:SetPrivateData( "viphouse", viphouse_ids )

    triggerClientEvent( player, "onReceiveViphouseMarkersData", resourceRoot, VIP_HOUSE_OWNERS )
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )


function PlayerHasAccesToVipHouse( player, hid )
	local house = VIP_HOUSES[ hid ]
	return house.owner == player:GetUserID( ) or house.owner == player:GetPermanentData( "wedding_at_id" )
end


function GetVipHouseListByUserId( user_id )
	if not tonumber( user_id ) then return end

	local viphouse_list = {}
	for i, house in pairs( VIP_HOUSES ) do
		if type( i ) == "string" and house.owner == user_id then

			local config = house.config

			local metering_factor = REAL_METERING_DEVICE_FACTOR[ house.meter_type or 0 ] or 1
			local daily_cost = config.daily_cost * metering_factor
			local services = config.services
			for j, v in pairs( services ) do
				if house.purchased_services[ j ] then
					daily_cost = daily_cost - services[ j ].reduction
				end
			end

			table.insert( viphouse_list, {
				id                 		= house.id,
				hid                		= house.hid,
				name               		= config.name,
				paid_days          		= house.paid_days,
				sale_state         		= house.sale_state,
				daily_cost         		= daily_cost,
				purchased_services 		= house.purchased_services,
				owner	           		= house.owner,
				inventory_max_weight	= house.config.inventory_max_weight + house.inventory_expand,
			})
		end
	end

	return viphouse_list
end

function GetPlayerVipHouseList( player )
	if not isElement( player ) then return end
	local user_id = player:GetUserID( )

	return GetVipHouseListByUserId( user_id )
end

function GetPlayerAllVipHouseCarSlotInfo( pPlayer )
	local total_slot_count = 0

	local viphouse_list = GetPlayerVipHouseList( pPlayer ) or {}
	for k, house in pairs( viphouse_list ) do
		local conf = VIP_HOUSES_REVERSE[ house.hid ]
		total_slot_count = total_slot_count + ( house.paid_days > 0 and conf.parking_slots or 0 )
	end

	return total_slot_count
end

function GetVipHouseKeyByID( hid, index )
	if VIP_HOUSES[ hid ] then
		return index and VIP_HOUSES[ hid ][ index ] or VIP_HOUSES[ hid ]
	end
end

function GetVipHouseByOwnerId( owner_id )
	for k, v in pairs( VIP_HOUSES ) do
		if v.owner == owner_id then
			return v
		end
	end
	return false
end

function SetViphouseData( id, key, value )
	VIP_HOUSES[ id ][ key ] = value
	VIP_HOUSES[ id ]:Save()
end

function ResetViphouse( hid )
  VIP_HOUSES[ hid ]:Reset( )
end

function GetVipHouseCarslots( hid )
	return VIP_HOUSES[ hid ] and VIP_HOUSES[ hid ].parking_slots or false
end

function CreateApartmentMarkersOnPlayerSpawn( _, _, _, _, _, _, interior, dimension )
	if interior == 0 or dimension == 0 then return end

	local dimension = dimension - 5000
	local id = math.floor( dimension / 110 )
	local number = dimension % 110

	if id ~= 0 or not VIP_HOUSES_LIST[ number ] or not VIP_HOUSES_LIST[ number ].apartments_class then return end
	if APARTMENTS_CLASSES[ VIP_HOUSES_LIST[ number ].apartments_class ].interior ~= interior then return end

	local house = VIP_HOUSES[ number ]
	if not house then return end

	source:SetInVipHouse( house )
end
addEventHandler("onPlayerSpawn", root, CreateApartmentMarkersOnPlayerSpawn)

function PlayerWantEnterVipHouse_handler( id, allowed_by_owner )
	local player = client or source

	local house = VIP_HOUSES[ id ]
	if not allowed_by_owner and house.owner and house.owner ~= 0 and house.owner ~= player:GetUserID() and house.owner ~= player:GetPermanentData( "wedding_at_id" ) then 
		player:triggerEvent( "onClientPlayerNeedCallHouse", resourceRoot, 0, id )
		return
	end

	local apartments_class = house.config.apartments_class
	local pos = player.position

	player:Teleport( APARTMENTS_CLASSES[ apartments_class ].exit_position, house.dimension, APARTMENTS_CLASSES[ apartments_class ].interior, 1000 )
	player:SetInVipHouse( house )
end
addEvent( "PlayerWantEnterVipHouse", true )
addEventHandler( "PlayerWantEnterVipHouse", root, PlayerWantEnterVipHouse_handler )

function PlayerWantCallVipHouse( house_id )
	local player = client or source

	local house = VIP_HOUSES[ house_id ]	

	local owner = GetPlayer( house.owner, true )
	if not owner then return end

	local dimension = owner.dimension - 5000
	if dimension < 0 then return end
	local owner_id = math.floor( dimension / 110 )
	local owner_number = dimension % 110

	local is_owner_in_house = owner_id == 0 and owner_number == house_id
	if not is_owner_in_house then return end

	owner:triggerEvent( "onClientPlayerCallHouse", resourceRoot, player, 0, house_id )
end
addEvent("PlayerWantCallVipHouse", true)
addEventHandler("PlayerWantCallVipHouse", root, PlayerWantCallVipHouse)

function PlayerExitFromVipHouse( house_id )
	local player = client or source

	player:Teleport( VIP_HOUSES_LIST[ house_id ].enter_marker_position, 0, 0, 50 )
	player:SetInVipHouse( false )
end
addEvent( "PlayerExitFromVipHouse", true )
addEventHandler("PlayerExitFromVipHouse", root, PlayerExitFromVipHouse)

function PlayerWantShowControlVipHouse_handler( id )
	local house = VIP_HOUSES[ id ]
	if house:IsPurchased( ) then
		if house.owner ~= client:GetUserID() then 
			client:ErrorWindow( "Ты не владелец!" )
			return
		end

		house:ShowControl( client )
	else
		local config = house.config
		triggerClientEvent( client, "ShowPurchaseUI", resourceRoot, true, 
			{ 
				hid = house.hid, 
				id = house.id, 
				cost = config.cost, 
				name = config.name,
				class = config.class,
				img = config.img,
			} 
		)
	end
end
addEvent( "PlayerWantShowControlVipHouse", true )
addEventHandler( "PlayerWantShowControlVipHouse", root, PlayerWantShowControlVipHouse_handler )


addEventHandler( "onResourceStop", resourceRoot, function()
	for _, player in ipairs( getElementsByType( "player" ) ) do
		if player:IsInGame() then
			if player.interior ~= 0 and player.dimension ~= 0 then
				local dimension = player.dimension - 5000
				local id = math.floor( dimension / 110 )
				local number = dimension % 110

				if id == 0 and VIP_HOUSES_LIST[ number ] and VIP_HOUSES_LIST[ number ].apartments_class 
				and APARTMENTS_CLASSES[ VIP_HOUSES_LIST[ number ].apartments_class ].interior == player.interior then
					player:Teleport( Vector3( VIP_HOUSES_LIST[ number ].enter_marker_position ), 0, 0, 50 )
				end
			end
		end
	end
end )

function onGovChangeMeteringFactor_handler( meter_type, new_factor )
	if not isnumber( meter_type ) then return end
	if not isnumber( new_factor ) then return end
	if not DEFAULT_METERING_DEVICE_FACTOR[ meter_type ] then return end

	REAL_METERING_DEVICE_FACTOR[ meter_type ] = new_factor
end
addEvent( "onGovChangeMeteringFactor", true )
addEventHandler("onGovChangeMeteringFactor", root, onGovChangeMeteringFactor_handler)

function onPlayerEnterVilla_handler( id )
	local player = client
	player:SetInVipHouse( VIP_HOUSES[ id ] )
end
addEvent( "onPlayerEnterVilla", true )
addEventHandler( "onPlayerEnterVilla", root, onPlayerEnterVilla_handler )

function onPlayerExitVilla_handler( id )
	local player = client
	player:SetInVipHouse( false )
end
addEvent( "onPlayerExitVilla", true )
addEventHandler( "onPlayerExitVilla", root, onPlayerExitVilla_handler )

Player.SetInVipHouse = function( self, house )
	if house then
		if house.config.class ~= "Вилла" then
			triggerClientEvent( self, "CreateVipHouseMarkers", resourceRoot, {
				id        = house.id,
				dimension = house.dimension,
				apartments_class = house.config.apartments_class,
			} )
		end

		triggerEvent( "onPlayerEnterViphouse", self, 0, house.id )

		local wedding_at_id = self:GetPermanentData( "wedding_at_id" )
        local friendly_apart = wedding_at_id and wedding_at_id == house.owner

        if self:GetUserID() == house.owner or friendly_apart then
			self:SetPermanentData( "last_visited_apart", false )
		end

		self:SetPermanentData( "last_visited_viphouse", { id = house.id, friendly = friendly_apart } )
	end

	self:SetPrivateData( "in_viphouse", not not house )
end

-- есть ли задолженность по арендной плате
function HasVipHouseRentalDebt( id )
	return VIP_HOUSES[ id ].paid_days < 0
end

function HasPlayerAnyVipHouseRentalDebt( player )
	local user_id = player:GetUserID( )
	local viphouse_ids = player:getData( "viphouse" ) or {}
	for i, id in ipairs( viphouse_ids ) do
		local pVipHouse = VIP_HOUSES[ id ]
		if pVipHouse and pVipHouse.owner == user_id and pVipHouse.paid_days < 0 then
			return true
		end
	end

	return false
end

-- имена владельцов на маркерах
function onRequestVipHouseOwners_handler( )
	if not isElement( client ) then return end
	triggerClientEvent( client, "onReceiveViphouseMarkersData", resourceRoot, VIP_HOUSE_OWNERS )
end
addEvent( "onRequestVipHouseOwners", true )
addEventHandler( "onRequestVipHouseOwners", resourceRoot, onRequestVipHouseOwners_handler )


------------------------------------------------------------------------------------------------------------------------
----- Для теста
if SERVER_NUMBER > 100 then
	addCommandHandler( "setviphousepaiddays", function( player, cmd, id, paid_days )
		id = tonumber(id)
		paid_days = tonumber(paid_days)
		if not id or not paid_days then
			outputConsole( "ОШИБКА! Неправильное кол-во дней. Введите 'setviphousepaiddays i n' , где i - номер випхауса, n-число дней", player )
			return
		end

		local house = VIP_HOUSES[ id ]
		if not house then
			outputConsole( "ОШИБКА! Дом не найден. Проверьте параметры", player )
			return
		end

		house.paid_days = paid_days
        house.paytime = getRealTime().timestamp - 24 * 60 *60
		house:Save()

		outputConsole( "Кол-во оплаченных дней " .. tostring(paid_days) .. " успешно установлено.", player )
	end )


	addCommandHandler( "viphousesaleblock", function( player, cmd, day )
		day = tonumber( day )
		if not day then
			outputConsole( "ОШИБКА! Неправильные аргументы. Введите 'viphousesaleblock i' , где i - кол-во дней", player )
			return
		end

		BLOCK_SALE_TIMESTAMP = day * 24 * 60 * 60

		outputConsole( "Установлен запрет на продажу квартиры в " .. day .. " д.", player )
	end )


	addCommandHandler( "isplayerinsidevilla", function( player, cmd, hid )
		if IsPlayerInsideVilla( player, hid ) then
			outputConsole( "Игрок на территории виллы " .. hid )
		else
			outputConsole( "Игрока нет на территории виллы " .. hid )
		end
	end )
end