-- ShPlayer
Import( "ShElement" )

Player.InventoryGetItem = function( self, item_id )
	return exports.nrp_inventory:Inventory_GetById( self, item_id )
end

Player.InventoryGetItemCount = function( self, item_id, attributes )
	return exports.nrp_inventory:Inventory_GetItemCount( self, item_id, attributes )
end

Player.SetHP = function( self, hp, ignore_limit )
	self.health = math.min( hp, not ignore_limit and self:getData( "max_health" ) or 100 )
end

Player.SetBuff = function( self, buff_id, value, buff_source )
    return exports.nrp_player_buffs:SetBuff( self, buff_id, value, buff_source )
end

Player.GetClanUpgradeLevel = function( self, upgrade_id )
	local clan_id = self:GetClanID( )
	if not clan_id then
		return 0
	end
    --return exports.nrp_clans_buffs:GetClanUpgradeLevel( clan_id, upgrade_id )
	return 0
end

Player.GetClanBuffValue = function( self, buff_upgrade_id )
	--return exports.nrp_clans_buffs:GetClanBuffValue( self, buff_upgrade_id )
	return 0
end

Player.Teleport = function( self, position, dimension, interior, transitionTime )
	local x, y, z = nil, nil, nil

	if type( position ) == "userdata" or type( position ) == "table" then
		x, y, z = tonumber( position.x ), tonumber( position.y ), tonumber( position.z )
	end

	if localPlayer then
		if dimension then self.dimension = dimension end
		if interior then self.interior = interior end
		if x and y and z then self.position = Vector3( x, y, z ) end
		triggerServerEvent( "RequestTeleport", root, x, y, z, dimension, interior )
	else
		triggerEvent( "RequestTeleportPlayer", root, self, x, y, z, dimension, interior )
	end


	if interior then
		if localPlayer then -- client side
			triggerEvent( "requestNoCollisionTimePlayer", self )
		else -- server side
			triggerClientEvent( self, "requestNoCollisionTimePlayer", self )
		end
	end

	if type( transitionTime ) == "number" and transitionTime >= 50 then
		local function fade( state, seconds )
			return localPlayer and Camera.fade( state, seconds ) or self:fadeCamera( state, seconds )
		end

		fade( false, 0 )
		self.frozen = true

		Timer( function ( )
			if not isElement( self ) then return end
			
			fade( true, 1 )
			self.frozen = false
		end, transitionTime, 1 )
	end
end

Player.GetAFKTime = function( self )
	local afk_start_tick = self:getData( "afk_start_tick" )
	return afk_start_tick and getTickCount( ) - afk_start_tick or 0
end

Player.GetUniqueIdentificator = function( self )
    return 10000000 * self:getData( "_srv" )[ 1 ] + self:GetID( )
end

Player.IsInStoryQuest = function( self )
	local current_quest = self:getData( "current_quest" ) or { }
	for i, v in pairs( REGISTERED_QUESTS or { } ) do
		if v == current_quest.id then return true end
	end
end

Player.CanCreateParty = function( self )
	return self:getData( "allow_create_party" ) and true or false
end

Player.IsYoutuber = function( self )
	return self:getData( "is_youtuber" ) and true or false
end

Player.GetUniqueDimension = function( self, increment )
	local increment = tonumber(increment) or 1000
	local diff = 65535 - increment

	local element_id = self:GetID()
	if not element_id then
		return false
	end

	return increment + element_id % diff
end

Player.HasAnyApartment = function( self, wedded_include )
	local wedded_bonus = false
	if wedded_include then
		local wedding_at_apartments_data = self:getData( "wedding_at_apartments_data" ) or {}
		local wedding_at_viphouse_data = self:getData( "wedding_at_viphouse_data" ) or {}
		if next( wedding_at_apartments_data ) or next( wedding_at_viphouse_data ) then
			wedded_bonus = true
		end
	end

	local apartments = self:getData( "apartments" ) or {}
	local viphouse = self:getData( "viphouse" ) or {}

	return wedded_include and wedded_bonus or #apartments > 0 or #viphouse > 0
end

Player.IsHouseOwner = function( self, id, number )
    if id == 0 then
		local viphouse_ids = self:getData( "viphouse" ) or {}
		for i, viphouse_id in ipairs( viphouse_ids ) do
			if viphouse_id == number then
				return true
			end
		end
        return false
    else
        local apartments = self:getData( "apartments" ) or {}
		for i, apart in ipairs( apartments ) do
			if apart.id == id and apart.number == number then
				return true
			end
		end
        return false
	end
end

Player.CanAccessWeddingAtHouse = function( self, id, number )
	local wedding_at_apartments_data = self:getData( "wedding_at_apartments_data" ) or {}
	local wedding_at_viphouse_data = self:getData( "wedding_at_viphouse_data" ) or {}

	if id == 0 then
		for i, data in ipairs( wedding_at_viphouse_data ) do
			if data.id == number then
				return true
			end
		end
	else
		for i, data in ipairs( wedding_at_apartments_data ) do
			if data.id == id and data.number == number then
				return true
			end
		end
	end

	return false
end

Player.HasAccessToHouse = function( self, id, number )
	if not number then
		id, number = id:match( "^(%d+)_(%d+)$" )
		id = tonumber( id )
		number = tonumber( number )
	end
	return self:IsHouseOwner( id, number ) or self:CanAccessWeddingAtHouse( id, number )
end

Player.GetAllHousesList = function( self, wedded_include )
	local list = self:getData( "apartments" ) or {}
	for i, viphouse_id in ipairs( self:getData( "viphouse" ) or {} ) do
		table.insert( list, { id = 0, number = viphouse_id } )
	end
    if wedded_include then
		for i, data in ipairs( self:getData( "wedding_at_apartments_data" ) or {} ) do
			table.insert( list, data )
		end
		for i, data in ipairs( self:getData( "wedding_at_viphouse_data" ) or {} ) do
			table.insert( list, { id = 0, number = data.id } )
		end
	end
	return list
end

Player.GetAllHousePosition = function( self, wedded_include, flatten )
	local positions = {}

	if wedded_include then
		local wedding_at_apartments_data = self:getData( "wedding_at_apartments_data" ) or {}
		for i, data in ipairs( wedding_at_apartments_data ) do
			local vec3 = APARTMENTS_LIST[ data.id ].enter_position
			if flatten then
				table.insert( positions, vec3 )
			else
				local distance = math.abs( ( self.position - vec3 ):getLength( ) )
				table.insert( positions, { vec3, distance } )
			end
		end

		local wedding_at_viphouse_data = self:getData( "wedding_at_viphouse_data" ) or {}
		for i, data in ipairs( wedding_at_viphouse_data ) do
			local pos_data = VIP_HOUSES_LIST[ data.id ].enter_marker_position or VIP_HOUSES_LIST[ data.id ].control_marker_position or VIP_HOUSES_LIST[ data.id ].relative_center
			local vec3 = Vector3( pos_data.x, pos_data.y, pos_data.z )
			if flatten then
				table.insert( positions, vec3 )
			else
				local distance = math.abs( ( self.position - Vector3( pos_data.x, pos_data.y, pos_data.z ) ):getLength( ) )
				table.insert( positions, { vec3, distance } )
			end
		end
	end

	local apartments = self:getData( "apartments" ) or {}
	for i, data in ipairs( apartments ) do
		local vec3 = APARTMENTS_LIST[ data.id ].enter_position
		if flatten then
			table.insert( positions, vec3 )
		else
			local distance = math.abs( ( self.position - vec3 ):getLength( ) )
			table.insert( positions, { vec3, distance } )
		end
	end

	local viphouse_ids = self:getData( "viphouse" ) or {}
	for i, id in ipairs( viphouse_ids ) do
		local pos_data = VIP_HOUSES_LIST[ id ].enter_marker_position or VIP_HOUSES_LIST[ id ].control_marker_position or VIP_HOUSES_LIST[ id ].relative_center
		local vec3 = Vector3( pos_data.x, pos_data.y, pos_data.z )
		if flatten then
			table.insert( positions, vec3 )
		else
			local distance = math.abs( ( self.position - vec3 ):getLength( ) )
			table.insert( positions, { vec3, distance } )
		end
	end

	return positions
end

Player.GetNearestHousePosition = function( self, wedded_include )

	local positions = self:GetAllHousePosition( wedded_include )
	table.sort( positions, function( a, b )
		return a[ 2 ] < b[ 2 ]
	end )

	return next( positions ) and positions[ 1 ][ 1 ] or false
end

Player.GetHouseIsInside = function( self )
	local id, number = exports.nrp_apartment:GetApartmentPlayerIsInside( self )
	if not id then
		number = exports.nrp_vip_house:GetVipHousePlayerIsInside( self )
		id = number and 0
	end
	return id, number
end
Player.IsInHouse = Player.GetHouseIsInside

Player.GetOnShift = function( self )
	return self:getData( "onshift" )
end

Player.GetShiftCity = function( self )
	local shift_info = getElementData( self, "job_shift" )
	return shift_info and shift_info.city
end

Player.tostring = function( self )
    return table.concat( { getElementData( self, "_nickname" ) or self:getName(), " (UID:", tostring( self:GetID( ) ), ")" }, '' )
end

Player.GetFactionVoiceChannel = function( self )
	return getElementData( self, "_voicech" )
end

Player.SetFactionVoiceChannel = function( self, ch )
	self:setData( "_voicech", ch, false )
	triggerEvent( "onFactionVoiceChannelChange", self, ch )
end

Player.GetClanTeam = function( self )
	local team = self:getTeam( )
	if team then
		local id = team:getID( )
		if id and id:find( "^c[0-9]+$" ) then
			return team
		end
	end
end

Player.IsInClan = function( self )
	return ( self:GetClanTeam( ) or ( self:GetClanID( ) or 0 ) > 0 ) and true or false
end

Player.GetClanCartelID = function( self )
	local team = self:GetClanTeam()
	return team and team:getData( "cartel" )
end

Player.IsInCartelClan = Player.GetClanCartelID

Player.IsWantedFor = function( self, sArticle )
	local pWantedData
	if localPlayer then
		pWantedData = getElementData( self, "wanted_data" ) or { }
	else
		pWantedData = self:GetPermanentData( "wanted_data" ) or { }
	end

	for k,v in pairs( pWantedData ) do
		if v[1] == sArticle then
			return true
		end
	end
end

Player.AddFine = function( self, source, fineid, ... )
	local source = tonumber( source ) and nil or source
	local fineid = fineid or tonumber( source )
	if not fineid then return end

	if localPlayer then
		triggerServerEvent( "OnAddFineRequest", self, source, self, fineid, ... )
	else
		triggerEvent( "OnAddFineRequest", self, source, self, fineid, ... )
	end
end

Player.IsImmortal = function( self )
	return getElementData( self, "bImmortal" )
end	

Player.IsVoiceMuted = function(self)
	return getElementData( self, "_muted" )
end

Player.IsChatMuted = function(self)
	return getElementData(self,"CPlayer::m_iChatMuted")
end

Player.IsPremiumActive = function (self)
	if localPlayer then
		return ( self:getData( "premium_time_left" ) or 0 ) >= getRealTimestamp( )
	else
		return ( self:GetPermanentData( "premium_time_left" ) or 0 ) >= getRealTimestamp( )
	end
end;

Player.IsSubscriptionActive = function (self)
	return ( ( getElementData( self, "subscription_time_left" ) or 0 ) - getRealTimestamp( ) ) > 0
end;

Player.IsCanChgSubscriptionUnlockVehicle = function( self )
	return true
end;

Player.GetNicknameColor = function( self )
	return getElementData( self, "nickname_color" ) or 1
end;

Player.GetRegDate = function( self )
	return getElementData( self, "reg_date" )
end

Player.IsInGame = function( self )
	return getElementParent( self ) == getElementByID( "inGamePlayers" ) --getElementData( self, "_ig" )
end


Player.GetNickName = Player.getNametagText

Player.GetLicenses = function( self )
	return getElementData( self, "licenses" ) or { }
end

Player.GetLicenseState = function( self, value )
	local licenses = self:GetLicenses()
	return licenses[value] or 1
end

Player.HasLicense = function( self, value )
	local licenses = self:GetLicenses()
	return licenses[value] and licenses[value] == LICENSE_STATE_TYPE_PASSED
end

Player.AddVehicleToList = function( self, vehicle )
	if vehicle:GetSpecialType( ) then
		self:AddSpecialVehicleToList( vehicle:GetID( ), vehicle.model )
		return
	end

	local list = self:GetVehicles( _, true )
	for k, v in pairs( list ) do
		if v == vehicle then
			return
		end
	end

	table.insert( list, vehicle )
	self:SetPrivateData( "pVehiclesList", list )
end

Player.RemoveVehicleFromList = function( self, vehicle )
	if vehicle:GetSpecialType() then
		self:RemoveSpecialVehicleFromList( vehicle:GetID() )
		return
	end

	local list = self:GetVehicles( _, true )
	local removed = false
	for k,v in pairs( list ) do
		if v == vehicle then
			table.remove( list, k )
			removed = true
			break
		end
	end

	if removed then
		self:SetPrivateData( "pVehiclesList", list )
	end
end

Player.GetMotorbikes = function ( self, exclude_id_468 )
	local list = getElementData( self, "pVehiclesList" ) or { }

	local real_list = { }
	for _, vehicle in ipairs( list ) do
		local config = VEHICLE_CONFIG[ vehicle.model ]
		if config.is_moto and ( not exclude_id_468 or vehicle.model ~= 468 ) then
			table.insert( real_list, vehicle )
		end
	end

	return real_list
end

Player.GetVehicles = function( self, sorted_by_block, with_moto, exclude_id_468 )
	local list = getElementData( self, "pVehiclesList" ) or { }

	if not with_moto or exclude_id_468 then
		local real_list = { }
		for _, vehicle in ipairs( list ) do
			local config = VEHICLE_CONFIG[ vehicle.model ]
			if with_moto or ( config and not config.is_moto ) then
				if ( not exclude_id_468 or vehicle.model ~= 468 ) then
					table.insert( real_list, vehicle )
				end
			end
		end
		list = real_list
	end

	if sorted_by_block then
		local len = #list
		
		local i = 1
		while i <= len do
			local veh = list[i]
			if isElement(veh) and veh:GetBlocked( ) then
				table.remove( list, i )
				table.insert( list, veh )

				i = i - 1
				len = len - 1
			end

			i = i + 1
		end
	end

	--Общий гараж
	--[[if not with_wedded_owned then
		local decr = 0 --nu i govno suka
		for i = 1, #list do
			if list[i-decr]:GetOwnerID() ~= self:GetID() then
				table.remove( list, i-decr )
				decr = decr + 1
			end
		end
	end]]

	return list
end
Player.GetVehiclesList = Player.GetVehicles

Player.AddSpecialVehicleToList = function( self, vehicle_id, model_id )
	local list = self:GetSpecialVehicles()
	for k, v in pairs( list ) do
		if v[1] == vehicle_id then
			return
		end
	end
	
	table.insert( list, { vehicle_id, model_id } )
	self:SetPrivateData( "pSpecialVehiclesList", list )
end

Player.RemoveSpecialVehicleFromList = function( self, vehicle_id )
	local list = self:GetSpecialVehicles()
	local removed = false
	for k,v in pairs( list ) do
		if v[1] == vehicle_id then
			table.remove( list, k )
			removed = true
			break
		end
	end

	if removed then
		self:SetPrivateData( "pSpecialVehiclesList", list )
	end
end

Player.GetSpecialVehicles = function( self, sorted_by_block )
	local list = getElementData( self, "pSpecialVehiclesList" ) or {}

	return list
end

Player.GetCostWithCouponDiscount = function( self, target_item_type, original_cost )
	if (self:getData( "offer_discount_gift_time_left" ) or 0) < getRealTimestamp() then
		return original_cost, false
	end

	local cost_with_discount, discount_value = original_cost, nil

	local special_coupons_discount = self:getData( "special_discount" ) or {}
	for discount_index, discount_data in ipairs( special_coupons_discount ) do
		for item_index, item_type in pairs( discount_data.items ) do
			if target_item_type == item_type then
				discount_value = discount_data.value
				cost_with_discount = cost_with_discount - math.floor( (discount_value / 100) * cost_with_discount )
				break
			end
		end
	end

	return cost_with_discount, discount_value
end

Player.GetCouponDiscountListByItemType = function( self, target_item_type, ignore_item_type )
	local result = {}
	if (self:getData( "offer_discount_gift_time_left" ) or 0) < getRealTimestamp() then
		return result
	end

	local special_coupons_discount = self:getData( "special_discount" ) or {}

	if target_item_type then
		for discount_index, discount_data in ipairs( special_coupons_discount ) do
			for item_index, item_type in pairs( discount_data.items ) do
				if item_type == target_item_type then
					table.insert( result, discount_data )
					break
				end
			end
		end
	else
		for discount_index, discount_data in ipairs( special_coupons_discount ) do
			local insert_item = true
			for item_index, item_type in pairs( discount_data.items ) do
				if item_type == ignore_item_type then
					insert_item = false
					break
				end
			end

			if insert_item then
				table.insert( result, discount_data )
			end
		end	
	end

	return result
end

Player.GetCostService = function( self, service_id )
	local cost, coupon_discount_value = self:GetCostWithCouponDiscount( "special_services", SHOP_SERVICES[ service_id ].iPrice )
    return cost, coupon_discount_value
end

Player.GetVehiclesByTier = function( self, tier )
	local vehicles = self:GetVehicles( )
	local i = 1
	while i <= #vehicles do
		local vehicle = vehicles[ i ]
		if not isElement( vehicle ) or vehicle:GetTier( ) ~= tier then
			table.remove( vehicles, i )
			i = i - 1
		end
		i = i + 1
	end
	return vehicles
end

Player.GetDefaultSkin = function(self)
	return getElementData(self,"skin")
end

Player.GetAccessories = function( self, by_model )
	local accessories = self:getData( "accessories" ) or { }
	return by_model and ( accessories[ by_model ] or { } ) or accessories
end

Player.GetCoins = function(self, sType)
	if sType == "gold" then
		return getElementData( self, "_coins_gold" ) or 0
	else
		return getElementData( self, "_coins_default" ) or 0
	end
end

Player.GetBusinessCoins = function( self )
	return getElementData( self, "business_coins" ) or 0
end

Player.GetDonate = function(self)
	return getElementData( self, "donate" ) or 0
end

Player.HasDonate = function(self, donate)
	return self:GetDonate() - donate >= 0
end

Player.HasMoney = function(self, money)
	return self:GetMoney() - money >= 0
end

Player.IsInGreenZone = function(self)
	return getElementData( self, "_greenzone" )
end

Player.GetUserID = Element.GetID

Player.GetAdminDuty = function(self)
	return getElementData( self, "_aduty" )
end

Player.IsAdminMode = function(self)
	return getElementData( self, "_amode" );
end;

SubCheck = function(first, last)
	local iRuNameCharacters = GetRussianCharaters(first)
	local iEnNameCharacters = GetLatinCharacters(first)
	-- Если в каком-то языке есть присутствие символа в имени.
	if not ( iRuNameCharacters == 0 or iEnNameCharacters == 0 ) then
		if iRuNameCharacters > iEnNameCharacters then
			return false, "Вы не можете использовать англ символы в имени"
		else
			return false, "Вы не можете использовать рус символы в англ имени"
		end
	end
	local iRuLastNameCharacters = GetRussianCharaters(last)
	local iEnLastNameCharacters = GetLatinCharacters(last)
	-- Если в фамилии есть рус символ среди других.
	if not iRuLastNameCharacters == 0 and not iEnLastNameCharacters == 0 then
		if iRuLastNameCharacters > iEnLastNameCharacters then
			return false, "Вы не можете использовать англ символы в фамилии"
		else
			return false, "Вы не можете использовать рус символы в англ фамилии"
		end
	end
	if not (iRuNameCharacters == 0 and iRuLastNameCharacters == 0 or iEnNameCharacters == 0 and iEnLastNameCharacters == 0) then
		if iRuNameCharacters == 0 and iEnLastNameCharacters == 0 then
			return false, "Вы не можете использовать англ имя и рус фамилию.\nПравильно: Maxim Smirnov."
		else
			return false, "Вы не можете использовать рус имя и англ фамилию.\nПравильно: Максим Смирнов."
		end
	end
	return true
end

GetRussianCharaters = function(str)
	local iCount = 0
	local iLen = utfLen(str)
	for i = 1, iLen do
		local iCode = utfCode(utfSub(str, i, i))
		if iCode >= 1040 and iCode <= 1103 or iCode == 1105 or iCode == 1025 then
			iCount = iCount + 1
		end
	end
	return iCount
end

GetLatinCharacters = function(str)
	local iCount = 0
	local iLen = utfLen(str)
	for i = 1, iLen do
		local iCode = utfCode(utfSub( str, i, i))
		if iCode >= 65 and iCode <= 90 or iCode >= 97 and iCode <= 122 then
			iCount = iCount + 1
		end
	end
	return iCount
end

VerifyValidLogin = function( first, last )
	if tonumber( first ) then
		return false, "Имя не может состоять из цифр"
	end
	if utf8.upper( utf8.sub( first, 1, 1) ) ~= utf8.sub( first, 1, 1 ) then
		return false, "Имя должно начинаться с большой буквы"
	end
	if utf8.len( first ) > 16 then
		return false, "Имя не может быть длинее 16 символов"
	end
	if utf8.len( first ) < 2 then
		return false, "Имя не может быть короче 2 символов"
	end
	if not utf8.find( first, "[a-вzA-Zа-яА-Я]+$" ) then
		return false, "Имя может содержать только буквы (без пробелов, цифр и других символов)."
	end
	if tonumber(last) then
		return false, "Фамилия не может состоять из цифр"
	end
	if utf8.upper( utf8.sub( last, 1, 1) ) ~= utf8.sub( last, 1, 1 ) then
		return false, "Фамилия должна начинаться с большой буквы"
	end
	if utf8.len( last ) > 16 then
		return false, "Фамилия не может быть длинее 16 символов"
	end
	if utf8.len( last ) < 4 then
		return false, "Фамилия не может быть короче 4 символов"
	end
	if not utf8.find( last, "[a-zA-Zа-яА-Я]+$" ) then
		return false, "Фамилия может содержать только буквы (без пробелов, цифр и других символов)."
	end
	if first == last then
		return false, "Имя и фамилия не могут быть равны"
	end
	if first == "Шаха" and last == "Вазович" then
		return false, "Нельзя использовать фамилию и имя из примера"
	end
	local bResult, strError = SubCheck(first, last)
	if not bResult then
		return false, strError
	end
	return true
end

VerifyPlayerName = function(nickname)
	if type(nickname) ~= "string" then
		return false, "Введите Имя и Фамилию"
	end
	if utf8.len( nickname ) > 32 then
		return false, "Имя и Фамилия не могут быть длинее 32 символов"
	end
	if utf8.len( nickname ) < 5 then
		return false, "Имя и Фамилия не могут быть короче 5 символов"
	end
	local _, iSpaces = utf8.gsub( nickname, " ", "" )
	if iSpaces > 1 then
		return false, "Вы не можете поставить больше одного пробела."
	end
	if pregFind( nickname, "^([A-Za-z]){1,15} ([A-Za-z]){1,16}+$", "u" ) then
		return false, "Имя и фамилия должны быть на русском!"
	end
	-- Парсим нинейм.
	local pSplit	= split(nickname, " ")
	local name 	= pSplit[ 1 ] or ""
	local last = pSplit[ 2 ] or ""
	-- Проверяем на валидность.
	local bResult, strError = VerifyValidLogin(name, last)
	if not bResult then
		return false, strError
	end
	if not pregFind( nickname, "^([A-ZА-Я0-9a-zа-я]){1,15} ([A-ZА-Я0-9a-zа-я]){1,16}+$", "u" ) then
		return false, "Между именем и фамилией должен быть пробел. Правильно: Максим Смирнов."
	end
	if not pregFind( nickname, "^([A-ZА-Я]{1,1})[a-zа-я]{1,15} ([A-ZА-Я]{1,1})[a-zа-я]{2,16}+$", "u" ) then
		return false, "Неверные имя и фамилия. Правильно: Максим Смирнов"
	end
	return true
end

Player.GetHunger = function(self)
	return getElementData(self,"hunger") or 0
end

----------------------[Срочка]------------------------

Player.IsInUrgentMilitaryBase = function( self )
	return getElementData( self, "in_urgent_military_base" )
end

Player.IsUrgentMilitaryVacation = function( self )
	return ( self:getData( "urgent_military_vacation" ) or 0 ) >= getRealTime().timestamp
end


Player.GetMilitaryLevel = function( self )
	return getElementData( self, "military_level" ) or 0
end

Player.GetMilitaryExp = function( self )
	return getElementData( self, "military_exp" ) or 0
end

Player.GetMilitaryExpMax = function( self, level )
	return MILITARY_EXPERIENCE[ level or self:GetMilitaryLevel() ]
end

Player.IsOnUrgentMilitary = function( self )
	local level = self:GetMilitaryLevel()

	return level > 0 and level < 4
end

Player.HasMilitaryTicket = function( self )
	return self:GetMilitaryLevel() >= 4
end

----------------------[Уровень]------------------------

Player.GetExpMax = function(self, level)
	return LEVELS_EXPERIENCE[level or self:GetLevel()]
end

----------------------[Фракции]------------------------

Player.IsInFaction = function( self )
	return self:GetFaction() > 0
end

Player.IsOnFactionDuty = function( self )
	return getElementData( self, "faction_duty" )
end

Player.GetFactionDutyCity = Player.IsOnFactionDuty

Player.IsFactionSkin = function( self )
	return self.model == FACTION_SKINS_BY_GENDER[ self:GetFaction() ][ self:GetFactionLevel() ][ self:GetGender() ]
end

Player.IsFactionOwner = function( self )
	return self:GetFactionLevel() == FACTION_OWNER_LEVEL
end

Player.IsHasFactionControlRights = function( self )
	return self:GetFactionLevel() >= FACTION_OWNER_LEVEL - 1
end

Player.GetFactionExpMax = function( self, level )
	return FACTION_EXPERIENCE[ level or self:GetFactionLevel() ]
end

--------------------------------------------------------

Player.GetQuestsData = function( self )
	local data = getElementData( self, "quests" ) or { }

	data.completed       = data.completed or { }
	data.failed          = data.failed or { }
	data.count_failed    = data.count_failed or { }
	data.count_completed = data.count_completed or { }

	return data
end

Player.GetStartCity = function(self)
	return self:getData( "start_city" ) or 1
end;

-- Hide nickname
Player.IsNickNameHidden = function ( self )
	return ( self:getData( "hide_nickname_time" ) or 0 ) > getRealTimestamp( )
end

-- Кейсы
Player.GetCases = function( self, case_type )
	iprint(getElementData( self, case_type and ( "cases_" .. case_type ) or "cases" ) or { })
	return getElementData( self, case_type and ( "cases_" .. case_type ) or "cases" ) or { }
	
end

Player.HasCase = function( self, case_type, case_id, tier, case_subtype )
	local player_cases = self:GetCases( case_type )

	if case_type == "tuning" then
		local available = ( ( ( player_cases[ case_id ] or { } )[ tier ] or { } )[ case_subtype ] ) or 0
		return available > 0
	else
		return player_cases[ case_id ] and player_cases[ case_id ] > 0
	end
end

Player.HasCasesExp = function( self, exp )
	local cases_exp = getElementData( self, "cases_exp" )
	return cases_exp and cases_exp >= exp
end

Player.GetCasesExp = function( self )
	return getElementData( self, "cases_exp" ) or 0
end

-- Винил кейсы
Player.GetVinylCases = function( self )
	return getElementData( self, "cases_vinyl" ) or { }
end

Player.HasVinylCase = function( self, case_id )
	local player_cases = getElementData( self, "cases_vinyl" ) or { }
	return player_cases[ case_id ] and player_cases[ case_id ] > 0
end

Player.IsHandcuffed = function( self )
	return getElementData( self, "is_handcuffed" )
end

Player.IsInEventLobby = function( self )
	return self:getData( "in_clan_event_lobby" )
		or self:getData( "in_race" )
		or self:getData( "current_event" )
		or self:getData( "is_on_event" )
		or self:getData( "in_party" )
		or self:getData( "in_coop_quest" )
end

Player.CanJoinToEvent = function( self, data )
	data = data or {}
	if data.event_type and data.event_type ~= "fight" then
		if data.event_type ~= "club" then
			if data.event_type ~= "race" and (self.health < 50 or self:getData( "_healing" )) then
				return false, "Для начала подлечись"
			end

			if not data.skip_check_job and self:IsOnFactionDuty( ) then
				return false, "Ты на смене во фракции!"
			end

			if not data.skip_check_job and self:GetOnShift( ) then
				return false, "Закончи смену на работе!"
			end

			if self:IsOnUrgentMilitary( ) and not self:IsUrgentMilitaryVacation( ) then
				return false, "Ты на срочной службе!"
			end
		end

		if not data.skip_check_job and self:getData( "current_quest" ) then
			return false, "Закончи текущую задачу!"
		end
	end

	if self:getData( "prewanted" ) then
		return false, "Ты в розыске!"
	end

	if self:getData( "in_party" ) then
		return false, "Нельзя принять участие отсюда!"
	end

	if self:getData( "in_casino" ) then
		return false, "Нельзя принять участие отсюда!"
	end

	if self:getData( "in_race" ) then
		return false, "Нельзя принять участие отсюда!"
	end

	if self:getData( "is_hunting" ) then
		return false, "Нельзя принять участие отсюда!"
	end

	if self:getData( "in_clan_event_lobby" ) then
		return false, "Нельзя принять участие отсюда!"
	end

	if self:getData( "registered_in_clan_event" ) then
		return false, "Отмени участие в войне кланов!"
	end

	if self:getData( "is_in_clothes_shop" ) then
		return false, "Нельзя принять участие отсюда!"
	end

	if self:getData( "is_in_wardrobe" ) then
		return false, "Нельзя принять участие отсюда!"
	end

	if self:getData( "is_handcuffed" ) then
		return false, "Ты в наручниках"
	end
	
	if self:getData( "is_sleeping" ) then
		return false, "Ты спишь"
	end

	if self:getData( "driving_exam" ) then
		return false, "Сначала заверши экзамен!"
	end

	if self:getData( "jailed" ) then
		return false, "Нельзя сделать это находясь в тюрьме"
	end

	if self:getData( "current_event" ) or self:getData( "is_on_event" ) then
		return false, "Ты на эвенте"
	end

	if data.event_type and data.event_type ~= "fight" then
		if self.dimension ~= 0 then
			return false, "Нельзя принять участие отсюда!"
		end

		if self.interior ~= 0 then
			return false, "Выйди на улицу!"
		end
	end

	if data.event_type ~= "race" and getCameraTarget( self ) ~= ( localPlayer and self.vehicle or self ) then
		return false, "Нельзя принять участие отсюда!"
	end

	if self.frozen then
		return false, "Нельзя принять участие сейчас!"
	end

	if self:getData("is_handcuffed") then
		return false, "Вы в наручниках!"
	end

	if self:getData( "in_strip_club" ) then
		return false, "Нельзя принять участие отсюда!"
	end

	return true
	
end

function Player:GetPMethod( )
	return self:getData( "pmethod" ) or "unitpay"
end

Player.HasCoopJobClass = function( self )
	local shift_data = self:getData( "job_shift" ) or {}
	return shift_data.is_coop_job
end