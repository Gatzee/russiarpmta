-- SPlayer.lua
Import( "SElement" )
Import( "ShUtils" )
Import( "Globals" )
Import( "ShPlayer" )
Import( "ShWedding" )

Player.HasFinishedTutorial = function( self )
	return self:HasFinishedBasicTutorial( ) and self:GetLevel( ) >= 2
end

Player.HasFinishedBasicTutorial = function( self )
	return not self:getData( "tutorial" ) and self:GetPermanentData( "intro" ) ~= "Yes"
end

Player.GetFines = function( self )
	return exports.nrp_fines:GetPlayerFines( self ) or {}
end

Player.GetFinesSum = function( self )
	local pFines = self:GetFines()

	local iTotalCash = 0

	for k,v in pairs(pFines) do
		iTotalCash = iTotalCash + (v.cost or 0)
	end

	return iTotalCash
end

Player.HasFines = function( self )
	local pFines = self:GetFines()
	return pFines and #pFines > 0
end

Player.RemoveFine = function( self, finedbid )
	triggerEvent( "OnRemoveFineRequest", self, finedbid )
end

Player.HasConfiscatedVehicle = function( self )
	local pVehicles = self:GetVehicles( _, true )

	for k,v in pairs(pVehicles) do
		if v:IsConfiscated() then
			return true
		end
	end

	return false
end


Player.GetCinemaBalance = function( self )
	return self:GetPermanentData( "cinema_balance" ) or 0
end

Player.SetCinemaBalance = function( self, amount, method )
	if amount < 0 then return end
	local amount = math.floor( amount )
	local method = method or "Unknown"
	local old = self:GetCinemaBalance( )
	local diff = amount - old
	self:SetPermanentData( "cinema_balance", amount )
	WriteLog( "money/set_cinema", "%s: %s, было %s, стало %s, разница %s", self, method, old, amount, diff )
end

Player.GiveCinemaBalance = function( self, amount, method )
	if amount < 0 then return end
	local method = "GiveCinemaBalance:" .. ( method or "Unknown:" .. THIS_RESOURCE_NAME )
	return self:SetCinemaBalance( self:GetCinemaBalance( ) + amount, method )
end

Player.TakeCinemaBalance = function( self, amount, method )
	if amount < 0 then return end
	local method = "TakeCinemaBalance:" .. ( method or "Unknown:" .. THIS_RESOURCE_NAME )
	return self:SetCinemaBalance( self:GetCinemaBalance( ) - amount, method )
end


Player.GetLevel = function(self)
	return self:GetPermanentData( "level" ) or 1
end

Player.GetExp = function(self)
	return self:GetPermanentData( "exp" ) or 150
end

Player.GetHobbyItems = function( self )
	return self:GetPermanentData( "hobby_items" ) or {}
end

Player.GetHobbyEquipment = function( self )
	return self:GetPermanentData( "hobby_equipment" ) or {}
end

Player.SetHobbyLevel = function( self, hobby, level )
	local pHobbiesData = self:GetHobbiesData()
	if not pHobbiesData[hobby] then pHobbiesData[hobby] = {} end
	pHobbiesData[hobby].level = level

	self:SetPrivateData( "hobby_data", pHobbiesData )
	return self:SetPermanentData( "hobby_data", pHobbiesData )
end

Player.GetHobbyExp = function( self, hobby )
	local pHobbiesData = self:GetHobbiesData()
	return pHobbiesData[hobby] and pHobbiesData[hobby].exp or 0
end

Player.GetHobbyLevel = function( self, hobby )
	local pHobbiesData = self:GetHobbiesData()
	return pHobbiesData[hobby] and pHobbiesData[hobby].level or 1
end

Player.GetHobbyUnlocks = function( self, hobby )
	local pHobbiesData = self:GetHobbiesData()
	return pHobbiesData[hobby] and pHobbiesData[hobby].unlocks or {}
end

Player.SetHobbyUnlock = function( self, hobby, class, level )
	local pHobbiesData = self:GetHobbiesData()
	if not pHobbiesData[hobby] then pHobbiesData[hobby] = {} end
	if not pHobbiesData[hobby].unlocks then pHobbiesData[hobby].unlocks = {} end

	pHobbiesData[hobby].unlocks[class] = level

	self:SetPrivateData( "hobby_data", pHobbiesData )
	return self:SetPermanentData( "hobby_data", pHobbiesData )
end

Player.GetHobbiesData = function( self )
	return self:GetPermanentData( "hobby_data" ) or {}
end

Player.SetJobID = function( self, id )
	self:SetPermanentData( "job_id", id )
end

Player.SetJobClass = function( self, class )
	self:SetPermanentData( "job_class", class )
end

Player.SetShiftID = function( self, shift_id )
	self:setData( "shift_id", shift_id, false )
end

Player.GetShiftID = function( self )
	return self:getData( "shift_id" )
end


Player.PhoneNotification = function( self, data )
	triggerClientEvent( self, "OnClientReceivePhoneNotification", self, data )
end

Player.SituationalPhoneNotification = function( player, data, config )
	local self = {
		ts     = getRealTime( ).timestamp,
		player = player,
	}

	function self.send( )
		triggerClientEvent( player, "OnClientReceivePhoneNotification", player, data )
	end
	
	function self.cancel( )
		if isTimer( self.timer ) then killTimer( self.timer ) end
		removeEventHandler( "onPlayerPreLogout", player, self.on_quit )
	end

	function self.on_quit( )
		if config.save_offline then
			local notifications = player:GetPermanentData( "offline_notifications" ) or { }
			table.insert( notifications, data )
			player:SetPermanentData( "offline_notifications", notifications )
		end
		self.cancel( )
	end

	local function is_sendable( )
		if config.condition then
			return config.condition( self, player, data, config )
		end
		return true
	end

	local function check( )
		local result = is_sendable( )
		if result == true then
			self:send( )
			self:cancel( )
		elseif result == "cancel" then
			self:cancel( )
		end
	end

	addEventHandler( "onPlayerPreLogout", player, self.on_quit )
	self.timer = setTimer( check, 5000, 0 )

	return self
end

Player.ShowRewards = function( self, ... )
    triggerClientEvent( self, "ShowRewards", self, { ... } )
end

Player.GiveFCMembership = function( self, iDays )
	local iExpirationDate

	if self:HasFCMembership() then
		iExpirationDate = self:GetPermanentData("fc_membership") + iDays*24*60*60
	else
		iExpirationDate = getRealTime().timestamp + iDays*24*60*60
	end
	
	self:SetPermanentData("fc_membership", iExpirationDate)
	self:SetPrivateData("fc_membership", iExpirationDate)
end

Player.HasFCMembership = function( self )
	return ( self:GetPermanentData("fc_membership") or 0 ) > getRealTime().timestamp
end

Player.HasDance = function( self, iDance )
	local iDance = tostring(iDance)
	local pDances = self:GetPermanentData("unlocked_animations") or {}
	if pDances[iDance] then
		return true
	end

	return false
end

Player.AddDance = function( self, iDance )
	local iDance = tostring( iDance )
	local pDances = self:GetPermanentData( "unlocked_animations" ) or { }
	pDances[ iDance ] = true

	self:SetPermanentData( "unlocked_animations", pDances )
	self:SetPrivateData( "unlocked_animations", pDances )

	return true
end

Player.RemoveDance = function( self, iDance )
	local iDance = tostring(iDance)
	local pDances = self:GetPermanentData("unlocked_animations") or {}
	pDances[iDance] = nil

	self:SetPermanentData("unlocked_animations", pDances)
	self:SetPrivateData("unlocked_animations", pDances)

	return false
end

-- Инвентарь внутреннего тюнинга
Player.GetTuningParts = function( self, tier )
	local parts = self:GetPermanentData( "tuning_internal" ) or { }
	return type( tier ) == "number" and ( parts[ tier ] or { } ) or parts
end

Player.GiveTuningPart = function( self, tier, id )
	local list = self:GetPermanentData( "tuning_internal" ) or { }

	if not list[ tier ] then
		list[ tier ] = { }
	end
	table.insert( list[ tier ], id )

	self:SetPermanentData( "tuning_internal", list )
end

Player.TakeTuningPartByPosition = function( self, tier, position )
	local list = self:GetPermanentData( "tuning_internal" ) or { }

	if not list[ tier ] or not list[ tier ][ position ] then return end

	table.remove( list[ tier ], position )
	self:SetPermanentData( "tuning_internal", list )
	return true
end

Player.TakeTuningPart = function( self, tier, id )
	local list = self:GetPermanentData( "tuning_internal" ) or { }

	for idx, partID in pairs( list[ tier ] or { } ) do
		if id == partID then
			table.remove( list[ tier ], idx )
			self:SetPermanentData( "tuning_internal", list )
			return true
		end
	end
end

----------------------------------------------------------------
-- 					Инвентарь винилов 						  --
----------------------------------------------------------------

-- Получение текущих винилов в инвентаре
Player.GetVinyls = function( self, vehicle_class )
	local vinyls = {}
	local vinyls_data = self:GetPermanentData( "vinyl_list" ) or { }
	
	for _, vinyl in pairs( vinyls_data ) do
		local new_vinyl_data = { }
		for i, v in pairs( vinyl ) do
			new_vinyl_data[ tonumber( i ) or i ] = tonumber( v ) or v
		end
		if not vehicle_class or new_vinyl_data[ P_CLASS ] == vehicle_class then
			table.insert( vinyls, new_vinyl_data )
		end
	end
	return vinyls
end

-- Установка текущих винилов в инвентаре
Player.SetVinyls = function( self, vinyl_list )
	self:SetPermanentData( "vinyl_list", vinyl_list )
end

-- Выдача винила в инвентарь
Player.GiveVinyl = function( self, vinyl )
	local vinyl_list = self:GetVinyls()
	table.insert( vinyl_list, vinyl )
	self:SetVinyls( vinyl_list )
end

-- Удаление винила из инвентаря
Player.TakeVinyl = function( self, vinyl_position )
	local vinyl_list = self:GetVinyls()
	table.remove( vinyl_list, vinyl_position )
	self:SetVinyls( vinyl_list )
end

----------------------------------------------------------------

-- Сегментированные офферы
Player.GetOfferConf = function( self, offer_num, key )
    local conf_table = self:GetPermanentData( "segoffers" ) or { }
    if not conf_table[ offer_num ] then return end

    local offer_table = conf_table[ offer_num ] or { }
    return offer_table[ key ]
end

Player.GetOfferAllConf = function( self, offer_num )
	local conf_table = self:GetPermanentData( "segoffers" ) or { }
	return conf_table[ offer_num ] or { }
end

Player.SetOfferConf = function( self, offer_num, key, value )
    local conf_table = self:GetPermanentData( "segoffers" ) or { }
    if not conf_table[ offer_num ] then conf_table[ offer_num ] = { } end
    conf_table[ offer_num ][ key ] = value
    self:SetPermanentData( "segoffers", conf_table )
end

Player.AddSpecialCouponDiscount = function( self, discount_data )
	local special_coupons_discount = self:GetSpecialCouponsDiscount()
	
	table.insert( special_coupons_discount, discount_data )

	self:SetSpecialCouponsDiscount( special_coupons_discount )
end

Player.TakeSpecialCouponDiscount = function( self, target_coupon_discount_value, target_item_type )
	local special_coupons_discount = self:GetSpecialCouponsDiscount()

	local target_discount_index = 0
	for discount_index, discount_data in ipairs( special_coupons_discount ) do
		if target_coupon_discount_value == discount_data.value then
			for item_index, item_type in pairs( discount_data.items ) do
				if target_item_type == item_type then
					target_discount_index = discount_index
					break
				end
			end
		end
	end

	if not special_coupons_discount[ target_discount_index ] then return end
	table.remove( special_coupons_discount, target_discount_index )
	
	self:SetSpecialCouponsDiscount( special_coupons_discount )

	
	local info_text = {
        special_services    = "Услуга была оказана по скидке " .. target_coupon_discount_value .. "%",
        special_case        = "Кейс был приобретен по скидке " .. target_coupon_discount_value .. "%", 
        special_vehicle     = "Транспорт был приобретен по скидке " .. target_coupon_discount_value .. "%", 
        special_skin        = "Скин был приобретен по скидке " .. target_coupon_discount_value .. "%",
        special_numberplate = "Номерной знак был приобретен по скидке " .. target_coupon_discount_value .. "%",
        special_neon        = "Неон был приобретен по скидке " .. target_coupon_discount_value .. "%", 
        special_vinyl       = "Винил был приобретен по скидке " .. target_coupon_discount_value .. "%", 
        special_vip_wof     = "Жетон был приобретен по скидке " .. target_coupon_discount_value .. "%",
        special_pack        = "Набор был приобретен по скидке " .. target_coupon_discount_value .. "%",
    }

	self:ShowInfo( info_text[ target_item_type ] )
end

Player.SetSpecialCouponsDiscount = function( self, special_coupons_discount )
    self:SetPrivateData( "special_discount", special_coupons_discount )
	self:SetPermanentData( "special_discount", special_coupons_discount )
end

Player.GetSpecialCouponsDiscount = function( self )
	if (self:getData( "offer_discount_gift_time_left" ) or 0) < getRealTimestamp() then return {} end
    return self:GetPermanentData( "special_discount" ) or {}
end

function Player.AddFactionRecord( self, ... )
	triggerEvent("AddFactionRecord", self, self, ... )
end

Player.GetReputationLogs = function( self )
	return exports.nrp_rp_rating:GetReputationLogs( self )
end

Player.GetReputationLogs = function( self )
	return exports.nrp_rp_rating:GetReputationLogs( self )
end

Player.SetRating = function( self, fValue, sAction, bNotify )
	local fOldValue = self:GetRating()

	local fValue = math.min( 100, math.max(fValue, 0))

	self:SetPermanentData( "rp_rating", fValue )
	self:SetPrivateData( "rp_rating", fValue )

	triggerEvent("AddReputationLog", self, self, fValue-fOldValue, sAction, bNotify)
end

Player.GiveRating = function( self, fValue, sAction, bNotify )
	local fRating = self:GetRating()
	if fRating == RPR_DEFAULT_VALUE then
		return false
	end
	return self:SetRating( fRating+fValue, sAction, bNotify )
end

Player.TakeRating = function( self, fValue, sAction, bNotify )
	local fRating = self:GetRating()
	if fRating == RPR_DEFAULT_VALUE then
		return false
	end
	return self:SetRating( fRating-fValue, sAction, bNotify )
end

Player.GetRating = function( self )
	local fRating = self:GetPermanentData("rp_rating") or RPR_DEFAULT_VALUE
	fRating = math.floor( fRating*10 ) / 10
	return fRating
end

Player.ErrorWindow = function( self, text, title )
	triggerClientEvent( self, "onErrorWindow", self, text, title )
end

Player.InfoWindow = function( self, text, title )
	triggerClientEvent( self, "onInformationWindow", self, text, title )
end

Player.MissionFailed = function( self, text )
	triggerClientEvent( self, "ShowPlayerUIQuestFailed", self, text )
end

Player.MissionCompleted = function( self, text )
	triggerClientEvent( self, "ShowPlayerUIQuestSuccess", self, nil, text )
end

Player.Jail = function( self, pSource, ... )
	exports.nrp_jail:JailPlayer( pSource, self, ... )
end

Player.IsJailed = function( self )
	return self:getData( "jailed" )
end

Player.Release = function( self, pSource, ... )
	local data = self:getData( "jailed" )
	if data == "is_prison" then
		exports.nrp_fsin_jail:ReleasePlayer( pSource, self, ... )
	else
		exports.nrp_jail:ReleasePlayer( pSource, self, ... )
	end
end

Player.GiveWeapon = function( self, ...)
	return exports.nrp_handler_weapons:GiveWeapon( self, ... )
end

Player.TakeWeapon = function( self, ... )
	return exports.nrp_handler_weapons:TakeWeapon( self, ... )
end

Player.TakeAllWeapons = function( self, bOnlyTemporary )
	return exports.nrp_handler_weapons:TakeAllWeapons( self, bOnlyTemporary )
end

Player.GetPermanentWeapons = function( self )
	return exports.nrp_handler_weapons:GetPermanentWeapons( self )
end

Player.GetDeathCounter = function( self )
	return self:IsJailed() and 30 or (not self:IsInClan( ) and self:GetPermanentData( "has_medbook" ) and 30 or 90)
end

Player.AddWanted = function( self, sArticle, iAmount, bCheck )
	if self:IsOnUrgentMilitary( ) and not self:IsUrgentMilitaryVacation( ) then return end
	if self.dimension >= 2 then return end
	local data = getElementData( self, "jailed" )
	if data and data == true then return end

	-- Военка
	if self:GetFaction( ) == F_ARMY then
		local px, py = getElementPosition(self)
		if getDistanceBetweenPoints2D( px, py, -2440.309, 744.183  ) <= 280 then
			return false
		end
	end

	local iAmount = iAmount or 1
	local pList = self:GetWantedData( true )

	if bCheck and self:IsWantedFor( sArticle ) then
		return false
	end

	for i = 1, iAmount do
		table.insert( pList, { sArticle, 0 } )
	end

	self:SetWantedData( pList )

	local px, py, pz = getElementPosition( self )
	local players = getElementsByType("player")
	for i, player in pairs( players ) do
		local vx, vy, vz = getElementPosition( player )
		if player:IsInGame() and player ~= localPlayer and getDistanceBetweenPoints3D( px, py, pz, vx, vy, vz ) <= WANTED_KNOW_DISTANCE and FACTION_RIGHTS.WANTED_KNOW[ player:GetFaction() ] and player:IsOnFactionDuty() then
			triggerClientEvent( player, "OnPlayerReceiveWantedData", self, pList )
		end
	end

	-- ANALYTICS
	triggerEvent( "OnPlayerPunishmentReceived", self, "prison", sArticle, WANTED_REASONS_LIST[sArticle].duration )

	triggerEvent( "onPlayerAddWanted", self, sArticle )

	return true
end

Player.RemoveWanted = function( self, sArticle, iAmount, ignore_sync )
	local iAmount = iAmount or 1
	local pList = self:GetWantedData( true )

	for i = 1, iAmount do
		for k,v in pairs( pList ) do
			if v[ 1 ] == sArticle then
				table.remove( pList, k )
				break
			end
		end
	end

	self:SetWantedData( pList )
	return true
end

Player.ClearWanted = function( self )
	
	local target_players = {}
	for k, v in pairs( getElementsWithinRange( self.position, 150, "player" ) ) do
		if v:IsInGame() and FACTION_RIGHTS.WANTED_KNOW[ v:GetFaction() ] and v:IsOnFactionDuty() then
			table.insert( target_players, v )
		end
	end
	triggerClientEvent( target_players, "OnPlayerReceiveWantedData", self, nil )

	self:SetWantedData( { } )
	return true
end

Player.GetWantedData = function( self, bFull )
	local pFullWantedData = self:GetPermanentData( "wanted_data" ) or {}
	if bFull then
		return pFullWantedData
	else
		local pShortList = {}
		for k,v in pairs(pFullWantedData) do
			table.insert(pShortList, v[1])
		end
		return pShortList
	end
end

Player.SetWantedData = function( self, data )
	self:SetPrivateData( "wanted_data", data )
	self:SetPermanentData( "wanted_data", data )
end

Player.GetClanID = function( self )
	return self:GetPermanentData( "clan_id" )
end

Player.SetClanID = function( self, value )
	if not value then value = nil end
	self:SetPermanentData( "clan_id", value )
	local team = value and getElementByID( "c" .. value )
	if team then
		self:SetPrivateData( "offer_clan", nil )
		self:setTeam( team )
		triggerEvent( "onPlayerSomeDo", self, "join_clan" ) -- achievements
	else
		self:setTeam( )
	end

	self:RefreshDailyQuests( )
end

Player.GetClanRole = function( self )
	return self:GetPermanentData( "clan_role" ) or 0
end

Player.SetClanRole = function( self, value )
	self:SetPrivateData( "clan_role", value )
	return self:SetPermanentData( "clan_role", value )
end

Player.GetClanRank = function( self )
	return self:GetPermanentData( "clan_rank" ) or 0
end

Player.SetClanRank = function( self, value )
	local old = getElementData( self, "clan_rank" )
	self:SetPermanentData( "clan_rank", value )
	self:SetPrivateData( "clan_rank", value )
	triggerEvent( "onPlayerClanRankChange", self, value, old )
end

Player.GetClanEXP = function( self )
	return self:GetPermanentData( "clan_exp" ) or 0
end

Player.SetClanEXP = function( self, value )
	triggerEvent( "onPlayerClanEXPChange", self, value )
end

Player.GiveClanEXP = function( self, value, ignore_premium_mul )
    if not ignore_premium_mul and self:IsPremiumActive( ) then
		value = value * PREMIUM_SETTINGS.fClanEXPMul
    end
	self:SetClanEXP( self:GetClanEXP() + value )
end

Player.TakeClanEXP = function( self, value )
	self:SetClanEXP( self:GetClanEXP() - value )
end

Player.AddClanStats = function( self, key, value )
	if not self:GetClanID( ) then return end
	local stats = self:GetPermanentData( "clan_stats" ) or {}
	stats[ key ] = ( stats[ key ] or 0 ) + value
	self:SetPermanentData( "clan_stats", stats )
end

Player.SetClanStats = function( self, key, value )
	if not self:GetClanID( ) then return end
	local stats = self:GetPermanentData( "clan_stats" ) or {}
	if key then
		stats[ key ] = value
	elseif type( value ) == "table" then
		stats = value
	end
	self:SetPermanentData( "clan_stats", stats )
end

Player.ResetClanStats = function( self )
	self:SetPermanentData( "clan_stats", { } )
end

Player.GetClanStats = function( self, key )
	local stats = self:GetPermanentData("clan_stats") or {}
	if key then
		return stats[key]
	else
		return stats
	end
end

function AlertAllClans( text, type )
    local fn = type == "success" and 'ShowSuccess' or type == "error" and 'ShowError' or 'ShowInfo'
    Async:foreach( getElementsByType( "player" ), function( v )
        if isElement( v ) and v:GetClanID() then
            v[ fn ]( v, text )
        end
    end )
end

function AlertClan( clan_id, text, type )
    local fn = type == "success" and 'ShowSuccess' or type == "error" and 'ShowError' or 'ShowInfo'
    Async:foreach( getElementsByType( "player" ), function( v )
        if isElement( v ) and v:GetClanID() == clan_id then
            v[ fn ]( v, text )
        end
    end )
end

Player.IsUnlocked = function( self, key )
	local key = tostring(key)
	local pUnlocks = self:GetPermanentData( "unlocks" ) or {}
	local pTempUnlocks = getElementData( self, "temp_unlocks" ) or {}

	for k,v in pairs(pTempUnlocks) do
		pUnlocks[k] = v
	end

	local bState = pUnlocks[key]
	if bState then
		if tonumber(bState) then
			bState = getRealTime().timestamp <= bState
		end
	end

	return bState
end

Player.SetUnlock = function( self, key, state )
	local key = tostring(key)
	local pUnlocks = self:GetPermanentData( "unlocks" ) or {}
	pUnlocks[key] = state

	self:SetPermanentData( "unlocks", pUnlocks )
	self:SetPrivateData( "unlocks", pUnlocks )
end

Player.SetTempUnlock = function( self, key, state )
	local key = tostring(key)
	local pUnlocks = self:GetPermanentData( "temp_unlocks" ) or {}
	pUnlocks[key] = state

	self:SetPermanentData( "temp_unlocks", pUnlocks )
	self:SetPrivateData( "temp_unlocks", pUnlocks )
end

Player.NotEnoughtMoney = function( self )
	triggerClientEvent( self, "ShowNotEnoughtWindow", self, true )
end
Player.NotEnoughMoney = Player.NotEnoughtMoney

Player.SetImmortal = function( self, state )
	self:SetPrivateData( "bImmortal", state )
	return true
end

Player.SetGender = function( self, value )
	self:SetPrivateData( "gender", value )
	self:SetPermanentData( "gender", value )
	return true
end

Player.GetGender = function(self)
	return self:GetPermanentData( "gender" ) or 0
end

Player.SetCalories = function( self, value, ignore_limit )
	value = math.min( math.max( 0, value or 0 ), not ignore_limit and self:getData( "max_calories" ) or 100 )
	self:SetPermanentData( "calories", value )
	self:SetPrivateData( "calories", value )
	return true
end

Player.GetCalories = function( self )
	return self:GetPermanentData( "calories" ) or 100
end

Player.GetAccessLevel = function( self )
	return self:GetPermanentData( "accesslevel" ) or 0
end

Player.SetAccessLevel = function( self, value )
	local old_value = self:GetAccessLevel( )
	self:SetPermanentData( "accesslevel", value )
	self:SetPermanentData( "check_serial", 1 )
	self:SetPrivateData( "_alevel", value )
	triggerEvent( "onPlayerAccessLevelChange", self, old_value, value or 0 )
end

Player.IsAdmin = function( self )
	return self:GetAccessLevel() >= 1
end

Player.SetInGame = function( self, state )
	setElementParent( self, state and getElementByID( "inGamePlayers" ) or root )
	self:SetPrivateData( "_ig", state )
end

Player.InventoryCheckWeight = function( self, item_id, ... )
	local attributes, count = arg[ 1 ], arg[ 2 ]
	if type( arg[ 1 ] ) == "number" then
		attributes, count = nil, arg[ 1 ] -- player:InventoryRemoveItem( item_type, count )
	end
	return exports.nrp_inventory:Inventory_CheckWeight( self, item_id, attributes, count or 1 )
end

Player.InventoryAddItem = function( self, item_id, ... )
	local attributes, count = arg[ 1 ], arg[ 2 ]
	if type( arg[ 1 ] ) == "number" then
		attributes, count = nil, arg[ 1 ] -- player:InventoryRemoveItem( item_type, count )
	end
	triggerEvent( "InventoryAddItem", self, self, item_id, attributes, count )
end

Player.InventoryRemoveItem = function( self, item_id, ... )
	local attributes, count = arg[ 1 ], arg[ 2 ]
	if type( arg[ 1 ] ) == "number" then
		attributes, count = nil, arg[ 1 ] -- player:InventoryRemoveItem( item_type, count )
	end
	triggerEvent( "InventoryRemoveItem", self, self, item_id, attributes, count )
end

Player.InventoryAddTempItem = function( self, item_id, ... )
	local attributes, count = arg[ 1 ], arg[ 2 ]
	if type( arg[ 1 ] ) == "number" then
		attributes, count = nil, arg[ 1 ] -- player:InventoryRemoveItem( item_type, count )
	end
	triggerEvent( "InventoryAddItem", self, self, item_id, attributes, count, true )
end

Player.InventoryRemoveTempItem = function( self, item_id, ... )
	local attributes, count = arg[ 1 ], arg[ 2 ]
	if type( arg[ 1 ] ) == "number" then
		attributes, count = nil, arg[ 1 ] -- player:InventoryRemoveItem( item_type, count )
	end
	triggerEvent( "InventoryRemoveItem", self, self, item_id, attributes, count, true )
end

Player.GiveJobFineByVehicleHealth = function( self, veh_health )
	local fines = {
		{ 25, 0.08 };
		{ 50, 0.2 };
		{ 99, 0.4 };	--При 100% разрушении выдает 99%
	}

	local last_coef = 0
	if veh_health then
		local health_proc = math.ceil( ( 1 - math.min( ( veh_health - VEHICLE_HEALTH_BROKEN ) / ( 1000 - VEHICLE_HEALTH_BROKEN ), 1 ) ) * 100 )
		--iprint( health_proc, veh_health )

		for _, info in ipairs( fines ) do
			if health_proc < info[1] then break end
			last_coef = info[2]
		end
	else
		last_coef = 0.20
	end

	local fine_sum = 0
	if last_coef > 0 then
		local task_earned = getElementData( self, "task_earned" ) or 0
		local daily_tasks_reward = getElementData( self, "daily_tasks_reward" ) or 0
		task_earned = task_earned - daily_tasks_reward
		local money = math.floor( math.min( task_earned * last_coef, 25000 ) )
		if money > 0 then
			fine_sum = money
			local job_class = self:GetJobClass()
			self:TakeMoney( money, "job_fine_vehicle", JOB_ID[ job_class ] )
			self:ShowError( "Вы были оштрафованы на ".. math.floor( last_coef * 100 ) .."% за поломку транспорта" )
		end
		--iprint( last_coef, math.floor( last_coef * 100 ), task_earned * last_coef )

		setElementData( self, "task_earned", false, false )
	end
	setElementData( self, "daily_tasks_reward", false, false )

	return fine_sum
end

Player.AddMoneyTaskEarned = function( self, money )
	local task_earned = getElementData( self, "task_earned" ) or 0
	setElementData( self, "task_earned", task_earned + money, false )
end

Player.ResetMoneyTaskEarned = function( self )
	setElementData( self, "task_earned", false, false )
	setElementData( self, "daily_tasks_reward", false, false )
end

Player.AddMoneyDailyTasks = function( self, money )
	local task_earned = getElementData( self, "daily_tasks_reward" ) or 0
	setElementData( self, "daily_tasks_reward", task_earned + money, false )
end

Player.ResetMoneyDailyTasks = function( self, money )
	setElementData( self, "daily_tasks_reward", false, false )
end

Player.ToggleAllControls = function(self, bEnabled, bGtaControls, bMtaControls)
	local bState = toggleAllControls( self, bEnabled, bGtaControls == nil and true or bGtaControls, bMtaControls == nil and true or bMtaControls )

	toggleControl(self, "radar", false)

	return bState
end

Player.GiveAllVehiclesDiscount = function( self, duration, percentage )
	if duration then
		local data = { timestamp = getRealTimestamp( ) + duration, percentage = percentage }
		self:SetPermanentData( "all_vehicles_discount", data )
		self:SetPrivateData( "all_vehicles_discount", data )
	else
		self:ResetAllVehiclesDiscount( )
	end
end

Player.ResetAllVehiclesDiscount = function( self )
	self:SetPermanentData( "all_vehicles_discount", false )
	self:SetPrivateData( "all_vehicles_discount", false )
end

Player.GetAllVehiclesDiscount = function( self )
	local data = self:GetPermanentData( "all_vehicles_discount" )
	if data and data.timestamp then
		if data.timestamp >= getRealTimestamp( ) then
			return data
		end
	end
end

Player.SetExp = function( self, exp )
	setElementData( self, "CPlayer::iExp", exp )
	return self:SetPermanentData( "game_exp", exp )
end

Player.GiveLicense = function( self, license )
	local licenses = self:GetPermanentData("licenses") or {}
	licenses[license] = LICENSE_STATE_TYPE_PASSED
	self:SetPermanentData( "licenses", licenses )
	self:SetPrivateData( "licenses", licenses )

	triggerEvent( "onPlayerSomeDo", self, "got_license" ) -- achievements
end

Player.TakeLicense = function( self, license )
	local licenses = self:GetPermanentData("licenses") or {}
	licenses[license] = nil
	self:SetPermanentData( "licenses", licenses )
	self:SetPrivateData( "licenses", licenses )
end

Player.SetLicenseState = function( self, license, state )
	local licenses = self:GetPermanentData("licenses") or {}
	licenses[license] = state
	self:SetPermanentData( "licenses", licenses )
	self:SetPrivateData( "licenses", licenses )
end

Player.HasVehicle = function(self,model)
	for i,vehicle in pairs(self:GetVehicles(_, true)) do
		if isElement(vehicle) and vehicle.model == model then
			return vehicle
		end
	end
	return false
end

Player.ParkedVehicles = function( self, count_parked )
	local count = 0
	local list = self:GetVehicles(_, true)

	count_parked = count_parked or #list

	for i, vehicle in pairs( list ) do
		if isElement( vehicle ) and not vehicle:GetParked() then
			count = count + 1

			vehicle:SetParked( true )

			if count >= count_parked then
				return
			end
		end
	end
end

Player.GetCountVehiclesNotParked = function( self, vehicles )
	vehicles = vehicles or self:GetVehicles(_, true)

	local count = 0

	for i, vehicle in pairs( vehicles ) do
		if isElement( vehicle ) and not vehicle:GetBlocked() and not vehicle:GetParked() then
			count = count + 1
		end
	end

	return count
end

Player.HasFreeVehicleSlot = function( self, count )
	local have_slots = exports.nrp_apartment:GetPlayerHaveVehiclesSlots( self )
	local vehicle_list = self:GetVehicles( )
	return have_slots >= ( #vehicle_list + ( count or 1 ) )
end

Player.GetTotalPlayingTime = function(self)
	return self:GetPermanentData( "playing_time" ) or 0
end

Player.SetDefaultSkin = function(self, skin)
	return self:SetPermanentData( "skin", skin )
end

Player.GetSkins = function( self )
	return self:GetPermanentData( "skins" ) or { }
end

Player.GiveSkin = function( self, skin_model )
	local skins = self:GetSkins( )

	for _, model in pairs( skins ) do
		if model == skin_model then
			return false
		end
	end

	for i = 1, math.huge do
		if not skins[ "s"..i ] then
			skins[ "s"..i ] = skin_model
			break
		end
	end

	self:SetPermanentData( "skins", skins )
	return true
end

Player.RemoveSkin = function( self, skin_model )
	local skins = self:GetSkins( )
	
	for _, model in pairs( skins ) do
		if model == skin_model then
			skins[_] = nil
			break
		end
	end

	self:SetPermanentData( "skins", skins )
	return true
end

Player.HasSkin = function( self, skin_model )
	local skins = self:GetSkins( )

	for _, model in pairs( skins ) do
		if model == skin_model then
			return true
		end
	end
	
	return false
end

Player.GetJobID = function(self)
	local id = self:GetPermanentData( "job_id" )
	return id ~= "0" and id
end

Player.GetJobClass = function(self)
	local class = self:GetPermanentData( "job_class" )
	return class ~= "0" and tonumber( class )
end

Player.SetPermanentData = function( self, key, value )
	triggerEvent( "SetPermanentData", self, key, value )
end

Player.SetBatchPermanentData = function( self, list )
	triggerEvent( "SetBatchPermanentData", self, list )
end

Player.GetPermanentData = function( self, key )
	return exports.nrp_player:GetPermanentData( self, key )
end

Player.GetBatchPermanentData = function( self, ... )
	return exports.nrp_player:GetBatchPermanentData( self, ... )
end

Player.GetFastPermanentData = function( self, key, callback_event )
	triggerEvent( "GetAsyncPermanentData", self, key, callback_event )
end

Player.GetGlobalData = function( self, ... )
	return exports.nrp_player:GetGlobalData( self, ... )
end

Player.SetGlobalData = function( self, ... )
	return exports.nrp_player:SetGlobalData( self, ... )
end

Player.SetPrivateData = function( self, key, value )
	triggerEvent( "SetPrivateData", self, key, value )
end

Player.SetBatchPrivateData = function( self, list )
	triggerEvent( "SetBatchPrivateData", self, list )
end

Player.ShowInfo = function(self, text)
	triggerClientEvent( self, "ShowInfo", self, text )
end

Player.CloseInfo = function( self )
	triggerClientEvent( self, "CloseInfo", self )
end

Player.ShowError = function(self, text)
	triggerClientEvent( self, "ShowError", self, text )
end

Player.ShowWarning = function(self, text)
	triggerClientEvent( self, "ShowWarning", self, text )
end

Player.ShowSuccess = function(self, text)
	triggerClientEvent( self, "ShowSuccess", self, text )
end

Player.ShowNotification = function( self, text )
	triggerClientEvent( self, "ShowInfo", self, text )
end

Player.OwnsVehicle = function(self, vehicle)
	local vehicle_owner = vehicle:GetOwnerID()
	return vehicle_owner and tonumber(vehicle_owner) == tonumber(self:GetUserID()) or false
end

Player.OwnsVehicleWedded = function( self, vehicle )
	local wedding_at_id = self:GetPermanentData( "wedding_at_id" )
	if wedding_at_id == vehicle:GetOwnerID() then
		return true
	end
end

Player.GetMoney = function( self )
	return self:GetPermanentData( "money" )
end

Player.GiveMoney = function( self, amount, source, source_type )
	if amount <= 0 then return end
	local method = "GiveMoney:" .. tostring( source ) .. ":" .. tostring( source_type )
	local final = self:GetMoney() + amount
	local result = self:SetMoney( self:GetMoney() + amount, method )
	if result then
		SendElasticGameEvent( self:GetClientID( ), "in_game_income", { source_class = source, source_class_type = source_type, currency = "soft", sum = amount, balance = final, current_lvl = self:GetLevel( ) } )
	end
	return result
end

Player.TakeMoney = function( self, amount, source, source_type )
	if amount < 0 then return end
	local method = "TakeMoney:" .. tostring( source ) .. ":" .. tostring( source_type )
	local final = self:GetMoney() - amount
	local result = self:SetMoney( final, method )
	if result then
		SendElasticGameEvent( self:GetClientID( ), "in_game_outcome", { source_class = source, source_class_type = source_type, currency = "soft", sum = amount, balance = final, current_lvl = self:GetLevel( ) } )
	end
	return result
end

Player.SetMoney = function( self, amount, method )
	if amount < 0 then return end
	local old = self:GetMoney() or 0
	local diff = old - amount
	if diff == 0 then return end

	local amount = math.floor( amount )
	local method = method or "Unknown:" .. THIS_RESOURCE_NAME
	self:SetPermanentData( "money", amount )
	self:SetPrivateData( "money", amount )
	WriteLog( "money/set", "%s: %s, было %s, стало %s, разница %s", self, method, old, amount, diff )
	return true
end

Player.EnoughMoneyOffer = function ( self, place, price, fn_callback, ... )
	return exports.nrp_hard_refill:EnoughMoneyOffer( self, place, price, fn_callback, ... )
end

Player.TeleportToColshape = function( self, colshape )
	self:fadeCamera( false, 0 )

	self.frozen = true
	self:Teleport( colshape.position, colshape.dimension, colshape.interior )

	Timer( function ( )
		self:fadeCamera( true, 0.5 )
		self.frozen = false
	end, 2000, 1 )
end

Player.SetClientID = function( self, cid )
	setElementData( self, "_clientid", cid, false )
	return true
end

Player.SetNickName = function( self, nickname )
	self:setName( string.gsub( Translit( nickname ), " ", "_" ):sub( 1, 22 )  )
	self:setNametagText( nickname )
	triggerEvent( "onPlayerNickNameChange", self, nickname )
end

------------------------------------
-- Premium


Player.SetPremiumExpirationTime = function( self, timestamp )
	setElementData( self, "premium_time_left", timestamp )
	self:SetPermanentData( "premium_time_left", timestamp )
	return true
end

-- Добавление дней к премиуму. Если нет премиума или истёк, также работает корректно
Player.GivePremiumExpirationTime = function(self, days)
	local days = tonumber(days)
	if not days or days <= 0 then return false end
	local current_expiration_time = self:GetPermanentData( "premium_time_left" ) or 0
	local current_timestamp = getRealTimestamp( )
	current_expiration_time = math.max(current_timestamp, current_expiration_time)
	local new_expiration_time = current_expiration_time + 86400 * days -- количество дней
	return self:SetPremiumExpirationTime(new_expiration_time)
end

Player.IsPremiumRenewalEnabled = function( self )
	if self:GetPermanentData( "premium_renewal_enabled" ) == false then
		return false
	else
		return true
	end
end


------------------------------------
-- Подписка

Player.SetSubscriptionExpirationTime = function( self, timestamp )
	self:SetPrivateData( "subscription_time_left", timestamp )
	self:SetPermanentData( "subscription_time_left", timestamp )
end

Player.GiveSubscription = function( self, days )
	local days = tonumber( days )
	if not days or days <= 0 then return false end

	local current_expiration_time = self:GetPermanentData( "subscription_time_left" ) or 0
	local current_timestamp = getRealTime().timestamp
	current_expiration_time = math.max(current_timestamp, current_expiration_time)
	local new_expiration_time = current_expiration_time + 86400 * days

	self:SetSubscriptionExpirationTime(new_expiration_time)
end

Player.GiveSubscriptionRewards = function( self, need_check )
	local subscription_reward_time = self:GetPermanentData( "subscription_reward_time" ) or 0
	local time = getRealTime()
	local timestamp = time.timestamp - time.hour * 60 * 60 - time.minute * 60 - time.second

	if need_check and subscription_reward_time > timestamp then
		return false
	end

	self:InventoryAddItem( IN_REPAIRBOX, nil, 3 )
	self:InventoryAddItem( IN_CANISTER, nil, 3 )
	self:InventoryAddItem( IN_FIRSTAID, nil, 3 )

	timestamp = timestamp + 24 * 60 * 60

	self:SetPrivateData( "subscription_reward_time", timestamp )
	self:SetPermanentData( "subscription_reward_time", timestamp )

	return true
end

Player.SetNicknameColor = function( self, color_index, need_check, not_setup_time )
	local nickname_color_timeout = self:GetPermanentData( "nickname_color_timeout" ) or 0
	local timestamp = getRealTime().timestamp

	if need_check and timestamp < nickname_color_timeout then
		return false
	end

	setElementData( self, "nickname_color", color_index )
	self:SetPermanentData( "nickname_color", color_index )

	if not not_setup_time then
		timestamp = timestamp + 86400 * 7
		self:SetPrivateData( "nickname_color_timeout", timestamp )
		self:SetPermanentData( "nickname_color_timeout", timestamp )
	end

	return true
end

Player.SetSubscriptionUnlockVehicle = function( self, vehicle_id, not_setup_time )
	self:SetPrivateData( "vehicle_access_sub_id", vehicle_id )
	self:SetPermanentData( "vehicle_access_sub_id", vehicle_id )

	-- Сбрасываем с других машин
	local vehicles = self:GetVehicles( )
	for _, v in pairs( vehicles ) do
		if isElement( v ) and v:HasBlackTuning( ) then
			local _, _, _, a = unpack( v:GetWindowsColor( ) )
			v:ResetBlackTuning( a )
		end
	end

	if not not_setup_time then
		local timestamp = getRealTime().timestamp + 86400 * 30
		self:SetPrivateData( "vehicle_access_sub_time", timestamp )
		self:SetPermanentData( "vehicle_access_sub_time", timestamp )
	end
end

Player.CleanPremiumStuff = function( self )
	local vehicles = self:GetVehicles( )

	for _, v in pairs( vehicles ) do
		if isElement( v ) and v:HasBlackTuning( ) then
			local _, _, _, a = unpack( v:GetWindowsColor( ) )
			v:ResetBlackTuning( a )
		end
	end

	if self:GetNicknameColor( ) ~= 1 then
		self:SetNicknameColor( 1, false, true )
	end

	exports.nrp_handler_accessories:removeSubscriptionAccessories( self )
end

------------------------------------
-- Аксессуары

Player.IsOwnedAccessory = function( self, id )
	local items = self:GetPermanentData( "own_accessories" ) or { }
	if items[id] then return true; end
end

Player.GetOwnedAccessories = function( self )
	return self:GetPermanentData( "own_accessories" ) or { }
end

Player.AddOwnedAccessory = function( self, id )
	local own_accessories = self:GetPermanentData( "own_accessories" ) or { }
	own_accessories[ id ] = true
	self:SetPermanentData( "own_accessories", own_accessories )
end

Player.SetAccessories = function( self, new_accessories, by_model )
	if by_model then
		local accessories = self:GetPermanentData( "accessories" ) or { }
		accessories[ by_model ] = new_accessories
		self:SetPermanentData( "accessories", accessories )
		self:setData( "accessories", accessories )

		triggerEvent( "onPlayerSomeDo", self, "use_accessory" ) -- achievements
	else
		self:SetPermanentData( "accessories", new_accessories )
		self:setData( "accessories", new_accessories )
	end
end

--------------------------------
-- Roulette Coins
Player.SetCoins = function( self, value, sType, method, key )
	if key ~= "NRPDszx5x" then
		--iprint( "ATTEMPT TO CALL SET COINS", self, tostring( value ), tostring( method ), tostring( key ) )
		return
	end
	local method = method and tostring( method ) or "UNKNOWN"
	WriteLog("money/coins", "[Server.SPlayer.SetCoins] %s. Было: %s, Стало: %s (разница: %s). Вызов: %s", self, self:GetCoins(sType), value, self:GetCoins(sType) - value, method)
	if sType == "gold" then
		self:SetPermanentData( "coins_gold", value )
		self:SetPrivateData( "_coins_gold", value )
	else
		self:SetPermanentData( "coins_default", value )
		self:SetPrivateData( "_coins_default", value )
	end
	return true
end

Player.GiveCoins = function( self, value, sType, method, key )
	local method = "GiveCoins:" .. tostring( method )
	self:SetCoins( self:GetCoins(sType) + value, sType, method, key )
	return true
end

Player.TakeCoins = function( self, value, sType, method, key )
	if self:GetCoins(sType) < value then return false end
	local method = "TakeCoins:" .. tostring( method )
	self:SetCoins( self:GetCoins(sType) - value, sType, method, key )
	return true
end

--------------------------------
-- Business Coins
Player.SetBusinessCoins = function( self, value, method )
	local method = method and tostring( method ) or "UNKNOWN"
	local current_coins = self:GetBusinessCoins( )
	WriteLog( "money/business_coins", "%s. Было: %s, Стало: %s (разница: %s). Вызов: %s", self, current_coins, value, current_coins - value, method )
	self:SetPermanentData( "business_coins", value )
	self:SetPrivateData( "business_coins", value )
	return true
end

Player.GiveBusinessCoins = function( self, value, method )
	local method = "GiveBusinessCoins:" .. ( method or "Unknown:" .. THIS_RESOURCE_NAME )
	self:SetBusinessCoins( self:GetBusinessCoins( ) + value, method )
	return true
end

Player.TakeBusinessCoins = function( self, value, method )
	if self:GetBusinessCoins( ) < value then return false end
	local method = "TakeBusinessCoins:" .. ( method or "Unknown:" .. THIS_RESOURCE_NAME )
	self:SetBusinessCoins( self:GetBusinessCoins( ) - value, method )
	return true
end

--------------------------------
-- Donate

Player.SetDonate = function( self, amount, method )
	if amount < 0 then return end
	local donate = self:GetDonate( )
	local diff = donate - amount
	if diff == 0 then return end

	local method = method and tostring( method ) or "Unknown:" .. THIS_RESOURCE_NAME
	WriteLog( "money/donate", "[Server.SPlayer.SetDonate] %s. Было: %s, Стало: %s (разница: %s). Вызов: %s", self, donate, amount, diff, method )
	self:SetPermanentData( "donate", amount )
	self:SetPrivateData( "donate", amount )
	return true
end

Player.GiveDonate = function( self, amount, source, source_type )
	local method = "GiveDonate:" .. tostring( source ) .. ":" .. tostring( source_type )
	local final = self:GetDonate() + amount
	local result = self:SetDonate( final, method )
	if result then
		SendElasticGameEvent( self:GetClientID( ), "in_game_income", { source_class = source, source_class_type = source_type, currency = "hard", sum = amount, balance = final, current_lvl = self:GetLevel( ) } )
	end
	return result
end

Player.TakeDonate = function( self, amount, source, source_type )
	if amount <= 0 then return false end
	if self:GetDonate() < amount then return false end

	local method = "TakeDonate:" .. tostring( method ) .. ":" .. tostring( source_type )
	local final = self:GetDonate() - amount
	local result = self:SetDonate( final, method )
	if result then
		if source == "f4_service" or source == "wedding_shop" or source == "service" then
			triggerEvent( "onPlayerSomeDo", self, "f4_service" ) -- achievements
		end

		SendElasticGameEvent( self:GetClientID( ), "in_game_outcome", { source_class = source, source_class_type = source_type, currency = "hard", sum = amount, balance = final, current_lvl = self:GetLevel( ) } )
	end

	return result
end

Player.GetDonate = function( self )
	return self:GetPermanentData( "donate" )
end


--------------------------------------------------------------------
-- Кэйсы рулетки
--------------------------------------------------------------------

Player.GiveCase = function( self, case_id, count )
	local player_cases = self:GetPermanentData( "cases" ) or { }
	player_cases[ case_id ] = ( player_cases[ case_id ] or 0 ) + count

	self:SetPrivateData( "cases", player_cases )
	self:SetPermanentData( "cases", player_cases )
end

Player.TakeCase = function( self, case_id, count )
	count = count or 1

	local player_cases = self:GetPermanentData( "cases" ) or { }

	if not player_cases[ case_id ] or player_cases[ case_id ] < count then
		return false
	end

	player_cases[ case_id ] = player_cases[ case_id ] - count

	self:SetPrivateData( "cases", player_cases )
	self:SetPermanentData( "cases", player_cases )

	return true
end

Player.GiveCasesExp = function( self, exp )
	local player_cases_exp = self:GetPermanentData( "cases_exp" ) or 0

	new_player_cases_exp = math.min( player_cases_exp + exp, CONST_MAX_CASES_EXP )

	if new_player_cases_exp >= CONST_MAX_CASES_EXP and player_cases_exp < CONST_MAX_CASES_EXP then
		triggerClientEvent( self, "ShowCasesReward", resourceRoot, _, 2 )
	elseif new_player_cases_exp >= CONST_FIRST_CASES_EXP and player_cases_exp < CONST_FIRST_CASES_EXP then
		triggerClientEvent( self, "ShowCasesReward", resourceRoot, _, 1 )
	end

	self:SetPrivateData( "cases_exp", new_player_cases_exp )
	self:SetPermanentData( "cases_exp", new_player_cases_exp )
end

Player.TakeCasesExp = function( self, exp )
	local player_cases_exp = self:GetPermanentData( "cases_exp" ) or 0

	if not player_cases_exp or player_cases_exp < exp then
		return false
	end

	player_cases_exp = player_cases_exp - exp

	self:SetPrivateData( "cases_exp", player_cases_exp )
	self:SetPermanentData( "cases_exp", player_cases_exp )

	return true
end

------------------
-- Тюнинг кейсы --
------------------
Player.GiveTuningCase = function( self, case_id, tier, case_subtype, count )
	local player_cases = self:GetPermanentData( "cases_tuning" ) or { }

	if not player_cases[ case_id ] then
		player_cases[ case_id ] = { }
	end

	if not player_cases[ case_id ][ tier ] then
		player_cases[ case_id ][ tier ] = { }
	end

	player_cases[ case_id ][ tier ][ case_subtype ] = ( player_cases[ case_id ][ tier ][ case_subtype ] or 0 ) + count

	self:SetPrivateData( "cases_tuning", player_cases )
	self:SetPermanentData( "cases_tuning", player_cases )
end

Player.TakeTuningCase = function( self, case_id, tier, subtype, count )
	count = count or 1

	local tuning_cases = self:GetPermanentData( "cases_tuning" ) or { }
	local available = ( ( tuning_cases[ case_id ] or { })[ tier ] or { } )[ subtype ] or 0

	if available < count then return false end

	tuning_cases[ case_id ][ tier ][ subtype ] = available - 1

	self:SetPrivateData( "cases_tuning", tuning_cases )
	self:SetPermanentData( "cases_tuning", tuning_cases )

	return true
end

-----------------
-- Винил кейсы --
-----------------
Player.GiveVinylCase = function( self, case_id, count )
	local player_cases = self:GetPermanentData( "cases_vinyl" ) or { }
	player_cases[ case_id ] = ( player_cases[ case_id ] or 0 ) + count

	self:SetPrivateData( "cases_vinyl", player_cases )
	self:SetPermanentData( "cases_vinyl", player_cases )
end

Player.TakeVinylCase = function( self, case_id, count )
	count = count or 1

	local player_cases = self:GetPermanentData( "cases_vinyl" ) or { }

	if not player_cases[ case_id ] or player_cases[ case_id ] < count then
		return false
	end

	player_cases[ case_id ] = player_cases[ case_id ] - count

	self:SetPrivateData( "cases_vinyl", player_cases )
	self:SetPermanentData( "cases_vinyl", player_cases )

	return true
end

-- Остальная дичь
Player.SetHometown = function( self, value )
	return self:SetPermanentData( "hometown", value )
end

Player.GetHometown = function(self)
	return self:GetPermanentData( "hometown" )
end

Player.GetBusinessInventoryData = function(self)
	return getElementData(self, "business_items") or {}
end

Player.SetBusinessInventoryData = function(self, tItems)
	return self:SetPrivateData("business_items", tItems)
end

Player.HasBusinessItem = function(self,iItem)
	local iItem = tonumber(iItem)
	local tItems = self:GetBusinessInventoryData()
	if ( tItems[iItem] or 0 ) >= 1 then
		return true
	end

	return false
end

Player.GiveBusinessItem = function(self,iItem,iAmount)
	local iAmount = tonumber(iAmount) or 1
	local tItems = self:GetBusinessInventoryData()
	local iCurrent = tItems[iItem] or 0
	tItems[iItem] = iCurrent + iAmount

	self:SetBusinessInventoryData(tItems)

	return true
end

Player.TakeBusinessItem = function(self,iItem,iAmount)
	local iAmount = tonumber(iAmount) or 1
	local tItems = self:GetBusinessInventoryData()
	local iCurrent = tItems[iItem] or 0
	if iCurrent - iAmount >= 0 then
		tItems[iItem] = iCurrent - iAmount
		self:SetBusinessInventoryData(tItems)
		return true
	else
		return false, "У игрока нет этого предмета!"
	end
end

Player.GetWeaponData = function(self)
	local data = {}

	for slot = 0, 12 do
		local weapon = getPedWeapon(self, slot)
		local amount = getPedTotalAmmo(self, slot)

		if weapon > 0 and amount > 0 then
			table.insert(data, { [weapon] = amount })
		end
	end

	return data
end

----------------------[Срочка]------------------------

Player.StartUrgentMilitary = function( self )
	self:SetMilitaryLevel( 1 )
	self:SetMilitaryExp( 0 )

	self:EnterOnUrgentMilitaryBase()
end

Player.EndUrgentMilitary = function( self )
	self:SetMilitaryLevel( 4 )
	self:SetMilitaryExp( 0 )

	if self:IsInUrgentMilitaryBase() then
		self:ExitFromUrgentMilitaryBase()
	else
		self:TakeUrgentMilitaryVacation()
	end
	
	self:ShowSuccess( "Поздравляем с получением военного билета!" )
end

Player.EnterOnUrgentMilitaryBase = function( self )
	self.position = Vector3( -2372.944, -113.476 +860, 21 ) + Vector3( math.random( -3, 3 ), math.random( -3, 3 ), 0 )

	self.interior = 0
	self.dimension = URGENT_MILITARY_DIMENSION

	self.model = URGENT_MILITARY_SKINS_BY_GENDER[ self:GetGender() ]

	self:SetPrivateData( "in_urgent_military_base", true )
	self:SetPrivateData( "last_enter_urgent_military_base", getRealTime().timestamp )

	self:TakeUrgentMilitaryVacation()

	if #self:GetWantedData() > 0 then
		self:ClearWanted()
		self:TakeMilitaryExp( 100 )

		self:ShowInfo( "Снято -100 очков ранга за розыск" )
	end
end

Player.ExitFromUrgentMilitaryBase = function( self )
	triggerEvent( "PlayerFailStopQuest", self, { type = "quest_fail", fail_text = "Вы покинули часть" } )

	self.interior = 0
	self.dimension = 0
	self.position = Vector3( -1217.257, -1285.566 +860, 21.428 ) + Vector3( math.random( -2, 2 ), math.random( -2, 2 ), 0 )

	self:SetPrivateData( "in_urgent_military_base", nil )

	local skins_list = self:GetSkins( )
	if skins_list and skins_list.s1 then
		self.model = skins_list.s1
	end
end

Player.GiveUrgentMilitaryVacation = function( self )
	local timestamp_end = getRealTime().timestamp + URGENT_MILITARY_VACATION_LEN

	self:SetPrivateData( "urgent_military_vacation", timestamp_end )
	self:SetPermanentData( "urgent_military_vacation", timestamp_end )
end

Player.TakeUrgentMilitaryVacation = function( self )
	self:SetPrivateData( "urgent_military_vacation", nil )
	self:SetPermanentData( "urgent_military_vacation", nil )
end

Player.SetMilitaryState = function( self, state )
	local pMilitaryData = self:GetMilitaryData()
	pMilitaryData.m_bState = state
	return self:SetPrivateData( "CPlayer::m_pMilitaryData", pMilitaryData )
end

Player.GiveMilitaryExp = function( self, exp, reason )
	local current_exp = self:GetMilitaryExp()
	local current_level = self:GetMilitaryLevel()

	exp = math.ceil( exp )

	if reason then
		WriteLog( "urgent_military", "[Server.SPlayer.GiveMilitaryExp] %s. Было: %s, Стало: %s (разница: %s). Вызов: %s", self, current_exp, current_exp + exp, exp, reason )
	end

	if MILITARY_EXPERIENCE[ current_level ] then
		current_exp = current_exp + exp

		if current_exp >= MILITARY_EXPERIENCE[ current_level ] then
			current_exp = current_exp - MILITARY_EXPERIENCE[ current_level ]
			current_level = current_level + 1

			if current_level == 4 then
				triggerEvent( "onPlayerUrgentMilitaryLeave", self, false )
				self:EndUrgentMilitary()
				return
			end

			self:SetMilitaryLevel( current_level )

			if MILITARY_EXPERIENCE[ current_level ] and current_exp >= MILITARY_EXPERIENCE[ current_level ] then
				self:SetMilitaryExp( current_exp )
				self:GiveMilitaryExp( 0 )
				return
			end

			triggerEvent( "OnPlayerMilitaryLevelUp", self, current_level )
		end

		self:SetMilitaryExp( current_exp )
	end
end

Player.TakeMilitaryExp = function( self, exp, reason )
	local current_exp = self:GetMilitaryExp()

	exp = math.ceil( exp )

	if current_exp - exp < 0 then
		exp = current_exp
		self:SetMilitaryExp( 0 )
	else
		self:SetMilitaryExp( current_exp - exp )
	end

	if reason then
		WriteLog( "urgent_military", "[Server.SPlayer.TakeMilitaryExp] %s. Было: %s, Стало: %s (разница: %s). Вызов: %s", self, current_exp, current_exp - exp, exp, reason )
	end
end

Player.SetMilitaryExp = function( self, exp, reason )
	exp = math.ceil( exp )

	if reason then
		WriteLog( "urgent_military", "[Server.SPlayer.SetMilitaryExp] %s. Было: %s, Стало: %s. Вызов: %s", self, self:GetExp(), exp, reason )
	end

	self:SetPrivateData( "military_exp", exp )
	return self:SetPermanentData( "military_exp", exp )
end

Player.SetMilitaryLevel = function( self, new_level, reset_exp )
	if reset_exp then
		self:SetMilitaryExp( 0, "Reset by SetLevel" )
	end

	if reason then
		WriteLog( "urgent_military", "[Server.SPlayer.SetMilitaryLevel] %s. Был: %s, Стал: %s. Вызов: %s", self, self:GetLevel(), new_level, reason )
	end

	self:SetPrivateData( "military_level", new_level )
	return self:SetPermanentData( "military_level", new_level )
end

----------------------[Уровень]------------------------

Player.GiveExp = function(self, exp, reason)
	local current_exp = self:GetExp()
	local current_level = self:GetLevel()

	exp = math.ceil( exp * self:GetPermanentExpBonusMultiplier( ) )

	if WEDDING_EXP_BOOST_ENABLED then
		local player_partner_id = self:GetPermanentData( "wedding_at_id" )
		if player_partner_id then
			local player_partner_element = GetPlayer( player_partner_id )
			if player_partner_element and isElement( player_partner_element ) and getDistanceBetweenPoints3D( self:getPosition(), player_partner_element:getPosition() ) < WEDDING_EXP_BOOST_DISTANCE then
				exp = math.ceil ( exp + ( exp * ( WEDDING_EXP_BOOST / 100 ) ) )
			end
		end
	end

	if reason then
		WriteLog("level", "[Server.SPlayer.GiveExp] %s. Было: %s, Стало: %s (разница: %s). Вызов: %s", self, current_exp, current_exp + exp, exp, reason)
	end

	current_exp = current_exp + exp

	if LEVELS_EXPERIENCE[current_level] then
		if current_exp >= LEVELS_EXPERIENCE[current_level] then
			current_exp = current_exp - LEVELS_EXPERIENCE[current_level]
			current_level = current_level + 1

			self:SetLevel( current_level, _, "LEVELUP" )

			if LEVELS_EXPERIENCE[current_level] and current_exp >= LEVELS_EXPERIENCE[current_level] then
				self:SetExp(current_exp)
				self:GiveExp(0)
				return
			end

			triggerEvent("OnPlayerLevelUp", self, current_level)
			self:CompleteDailyQuest( "np_get_new_level" ) 
		end
	end

	self:SetExp(current_exp)
	return exp
end

Player.SetExp = function(self, exp, reason)
	exp = math.ceil( exp )

	if reason then
		WriteLog("level", "[Server.SPlayer.SetExp] %s. Было: %s, Стало: %s. Вызов: %s", self, self:GetExp(), exp, reason)
	end

	self:SetPrivateData("exp", exp)
	return self:SetPermanentData("exp", exp)
end

Player.SetLevel = function(self, new_level, reset_exp, reason)
	if reset_exp then
		self:SetExp(0, "Reset by SetLevel")
	end

	if reason then
		WriteLog("level", "[Server.SPlayer.SetLevel] %s. Был: %s, Стал: %s. Вызов: %s", self, self:GetLevel(), new_level, reason)
	end

	self:UpdateOfflineData( "level", new_level )

	setElementData( self, "level", new_level )
	return self:SetPermanentData("level", new_level)
end

Player.GetClientID = function( self )
	return getElementData( self, "_clientid" )
end

----------------------[Фракции]------------------------

Player.GetFaction = function( self )
	return self:GetPermanentData( "faction_id" ) or 0
end

Player.GetFactionLevel = function( self )
	return self:GetPermanentData( "faction_level" ) or 0
end

Player.GetFactionExp = function( self )
	return self:GetPermanentData( "faction_exp" ) or 0
end

Player.SetFaction = function( self, faction_id, reason )
	local old_faction_id = self:GetFaction( )

	if reason then
		WriteLog( "faction", "[Server.SPlayer.SetFaction] %s. Смена фракции: %s -> %s. Вызов: %s", self, old_faction_id, faction_id, reason )
	end

	if faction_id and faction_id > 0 then
		self:SetPrivateData( "offer_clan", nil )

		self:SetPrivateData( "faction_id", faction_id )
		self:SetPermanentData( "faction_id", faction_id )

		self:SetFactionLevel( 1 )

		triggerEvent( "onPlayerSomeDo", self, "join_faction" ) -- achievements
	else
		self:EndFactionDuty()

		self:SetPrivateData( "faction_id", 0 )
		self:SetPermanentData( "faction_id", 0 )

		self:SetFactionLevel( 0 )

		self:RefreshDailyQuests( )
	end

	self:SetFactionExp( 0 )
	self:SetPermanentData( "faction_warns", 0 )

	triggerEvent( "onPlayerFactionChange", self, old_faction_id, faction_id )
end

Player.SetFactionSkin = function( self )
	local faction_skin = FACTION_SKINS_BY_GENDER[ self:GetFaction() ]
	if not faction_skin then
		Debug( "no faction_skin, faction = " .. tostring( self:GetFaction() ), 1 )
		return
	end
	faction_skin = faction_skin[ self:GetFactionLevel() ]
	if not faction_skin then
		Debug( "no faction_skin, level = " .. tostring( self:GetFactionLevel() ), 1 )
		return
	end
	faction_skin = faction_skin[ self:GetGender() ]
	if not faction_skin then
		Debug( "no faction_skin, gender = " .. tostring( self:GetGender() ), 1 )
		return
	end
	self.model = faction_skin
end

Player.TakeFactionSkin = function( self )
	self.model = self:GetSkins( ).s1
end

Player.StartFactionDuty = function( self, city )
	triggerEvent( "PlayerFailStopQuest", self, { type = "quest_fail", fail_text = "Вы начали смену" } )

	self:SetFactionSkin( )
	self:SetPrivateData( "faction_duty", city or 1 )

	triggerEvent( "OnPlayerFactionDutyStart", self )
end

Player.EndFactionDuty = function( self )
	triggerEvent( "PlayerFailStopQuest", self, { type = "quest_stop", fail_text = "Вы закончили смену" } )

	self:TakeFactionSkin( )
	self:SetPrivateData( "faction_duty", nil )

	triggerEvent( "OnPlayerFactionDutyEnd", self )
end

Player.GiveFactionOwner = function( self, reason )
	self:SetFactionLevel( FACTION_OWNER_LEVEL )
	self:SetFactionExp( 0 )

	if reason then
		WriteLog( "faction", "[Server.SPlayer.TakeFactionOwner] %s. Выдача прав лидера фракции: %s. Вызов: %s", self, self:GetFaction(), reason )
	end
end

Player.TakeFactionOwner = function( self, reason )
	self:SetFactionLevel( FACTION_OWNER_LEVEL - 1 )
	self:SetFactionExp( 0 )

	if reason then
		WriteLog( "faction", "[Server.SPlayer.TakeFactionOwner] %s. Удаление прав лидера фракции: %s. Вызов: %s", self, self:GetFaction(), reason )
	end
end

Player.IsHasFactionControlRightsToPlayer = function( self, to_player )
	if isElement( to_player ) then
		return self:IsHasFactionControlRights() and to_player:GetFactionLevel() < self:GetFactionLevel()
	elseif type( to_player ) == "number" then
		return self:IsHasFactionControlRights() and to_player < self:GetFactionLevel()
	end
end


Player.GiveFactionExp = function( self, exp, reason )
	local current_exp = self:GetFactionExp()
	local current_level = self:GetFactionLevel()

	exp = math.ceil( exp )

	if reason then
		WriteLog( "faction", "[Server.SPlayer.GiveFactionExp] %s. Было: %s, Стало: %s (разница: %s). Вызов: %s", self, current_exp, current_exp + exp, exp, reason )
	end

	self:SetFactionExp( current_exp + exp )
end

Player.GiveFactionLevelUp = function( self, reason )
	local current_exp = self:GetFactionExp()
	local current_level = self:GetFactionLevel()

	if FACTION_EXPERIENCE[ current_level ] and current_exp >= FACTION_EXPERIENCE[ current_level ] then
		current_exp = current_exp - FACTION_EXPERIENCE[ current_level ]
		self:SetFactionExp( current_exp )

		current_level = current_level + 1
		self:SetFactionLevel( current_level )
		triggerEvent( "onPlayerFactionRankUpgrade", self, current_level )

		if reason then
			WriteLog( "faction", "[Server.SPlayer.GiveFactionLevelUp] %s. Повышение: %s -> %s. Вызов: %s", self, current_level, current_level + 1, reason )
		end

		-- Даём новый скин
		if self:IsOnFactionDuty() then
			self:SetFactionSkin()
		end

		triggerEvent( "OnPlayerFactionLevelUp", self, current_level )

		return true
	end

	return false
end

Player.SetFactionLevel = function( self, new_level, reason, reset_exp )
	if reset_exp then
		self:SetFactionExp( 0, "Reset by SetLevel" )
	end

	if reason then
		WriteLog( "faction", "[Server.SPlayer.SetFactionLevel] %s. Был: %s, Стал: %s. Вызов: %s", self, self:GetLevel(), new_level, reason )
	end

	self:SetPrivateData( "faction_level", new_level )
	self:SetPermanentData( "faction_level", new_level )

	if self:IsOnFactionDuty() then
		self:SetFactionSkin()
	end

	return true
end

Player.SetFactionExp = function( self, exp, reason )
	exp = math.ceil( exp )

	if reason then
		WriteLog( "faction", "[Server.SPlayer.SetFactionExp] %s. Было: %s, Стало: %s. Вызов: %s", self, self:GetExp(), exp, reason )
	end

	triggerEvent( "onFactionEXPChange", self, exp, self:GetPermanentData( "faction_exp" ) or 0 )

	self:SetPrivateData( "faction_exp", exp )
	return self:SetPermanentData( "faction_exp", exp )
end

Player.TakeFactionExp = function( self, exp, reason )
	self:SetFactionExp( math.max( 0, self:GetFactionExp() - exp ), reason )
end

Player.GiveFactionWarning = function( self, exp_fine_amount )
	local exp_fine_amount = exp_fine_amount or 100

	self:TakeFactionExp( exp_fine_amount, "FactionWarning" )

	local warnings = self:GetPermanentData( "faction_warns" ) or 0
	warnings = warnings + 1
	if warnings > 3 then
		self:ShowInfo( "Вы были уволены за получение 4-го выговора" )
		self:SetFaction( 0 )
		self:SetPermanentData( "faction_timeout", getRealTimestamp( ) + FACTION_JOIN_TIMEOUT.leader )
	else
		self:ShowInfo( "Вы получили выговор от лидера и потеряли -" .. exp_fine_amount .. " очков" )
		self:SetPermanentData( "faction_warns", warnings )
	end
end

Player.GiveFactionThanks = function( self, exp_bonus_amount )
	local exp_bonus_amount = exp_bonus_amount or 300

	local faction_thanks_last = self:GetPermanentData( "faction_thanks_last" ) or 0
	local timestamp = getRealTime().timestamp
	if faction_thanks_last > timestamp then
		return false
	end

	self:GiveFactionExp( exp_bonus_amount, "FactionThanks" )

	local warnings = self:GetPermanentData( "faction_warns" ) or 0
	self:SetPermanentData( "faction_warns", math.max( 0, warnings - 1 ) )

	self:SetPermanentData( "faction_thanks_last", timestamp + 24 * 60 * 60 )

	self:ShowInfo( "Вы получили благодарность от лидера и +".. exp_bonus_amount .." очков" )

	return true
end

Player.IsOnFactionDayOff = function ( self )
	return ( self:GetPermanentData( "factions_day_off" ) or 0 ) > getRealTimestamp( )
end

--------------------------------------------------------------------

Player.SetQuestsData = function(self, quests_data)
	self:SetPrivateData("quests", quests_data)
	return self:SetPermanentData("quests", quests_data)
end

Player.SetStartCity = function( self, start_city )
	self:SetPrivateData( "start_city", tonumber( start_city ) )
	self:SetPermanentData( "start_city", tonumber( start_city ) );
end;

Player.SetQuestEnabled = function( self, quest_id, state )
	local quests_enabled = self:GetPermanentData( "quests_enabled" ) or { }
	quests_enabled[ quest_id ] = state
	self:SetPermanentData( "quests_enabled", quests_enabled )
	self:SetPrivateData( "quests_enabled", quests_enabled )
end

--------------------------------------------------------------------

Player.ActivateBooster = function( self, booster, time )
	local time = time or BOOSTERS_LIST[booster].iDuration

	local bFound = false

	local boosters = self:GetBoostersData()
	for k,v in pairs(boosters) do
		if v.id == booster and v.expires >= getRealTimestamp() then
			v.expires = v.expires + time
			bFound = true
		end
	end

	if not bFound then
		table.insert(boosters, { id = booster, expires = getRealTimestamp() + time })
	end

	self:SetBoostersData( boosters )

	return true
end

Player.GetBoostersData = function( self )
	return self:GetPermanentData("temp_boosters") or {}
end

Player.SetBoostersData = function( self, new_data )
	if not new_data then return end

	self:SetPermanentData("temp_boosters", new_data)
	self:SetPrivateData("temp_boosters", new_data)

	return true
end

Player.IsBoosterActive = function( self, booster )
	local boosters = self:GetBoostersData()

	for k,v in pairs(boosters) do
		if v.id == booster and v.expires >= getRealTimestamp() then
			return v
		end
	end

	return false
end

--------------------------------------------------------------------

Player.HasAnyTaxiLicense = function( self )
    for i, v in pairs( TAXI_LICENSES ) do
        local result = self:HasTaxiLicense( i )
        if result == TAXI_LICENSE_ENDLESS or ( result ~= TAXI_LICENSE_EXPIRED and result ~= TAXI_LICENSE_NOT_PURCHASED ) then
            return true
        end
    end
end

Player.GetTaxiLicensesInfo = function( self )
    local licenses = { }
    for i, v in pairs( TAXI_LICENSES ) do
        licenses[ i ] = self:HasTaxiLicense( i )
    end
    return licenses
end

Player.HasTaxiLicense = function( self, tier )
    local duration = self:GetTaxiLicenses( )[ tier ]

    -- Вечная лицензия
    if duration == TAXI_LICENSE_ENDLESS then
        return TAXI_LICENSE_ENDLESS

    -- Временная лицензия
    elseif tonumber( duration ) then
        local time_left = math.max( 0, duration - getRealTimestamp() )

        if time_left <= 0 then
            return TAXI_LICENSE_EXPIRED
        else
            return duration
        end
    end

    return TAXI_LICENSE_NOT_PURCHASED
end

Player.HasFreeTaxiTicket = function( self )
	return self:InventoryGetItemCount( IN_FREE_TAXI ) > 0
end

Player.GiveFreeTaxiTicket = function( self, count )
	self:InventoryAddItem( IN_FREE_TAXI, nil, count )
end

Player.TakeFreeTaxiTicket = function( self, count )
	self:InventoryRemoveItem( IN_FREE_TAXI, count or 1 )
end

Player.SetTaxiLicense = function( self, tier, value )
    local licenses = self:GetTaxiLicenses( )
    licenses[ tier ] = value
    self:SetTaxiLicenses( licenses )
end

Player.GetTaxiLicenses = function( self )
    return self:GetPermanentData( "taxi_licenses" ) or { }
end

Player.SetTaxiLicenses = function( self, list )
    self:SetPermanentData( "taxi_licenses", list )
end

--------------------------------------------------------------------

Player.StartRetentionTask = function( self, ... )
	triggerEvent( "StartRetentionTask", self, self, ... )
end

Player.StopRetentionTask = function( self, ... )
	triggerEvent( "StopRetentionTask", self, self, ... )
end

Player.GetRetentionTasks = function( self )
	local retention_tasks = { }

	local ts = getRealTimestamp()

	for i, v in pairs( self:GetPermanentData( "retention_tasks" ) or { } ) do
		if (v.timestamp_start and ts >= v.timestamp_start) and (v.timestamp_end and ts <= v.timestamp_end) then
			retention_tasks[ i ] = v
		end
	end

	return retention_tasks
end

--------------------------------------------------------------------

Player.AddDailyQuest = function( self, quest_id, is_forced )
    triggerEvent( "onServerAddPlayerDailyQuest", self, quest_id, is_forced )
end

Player.RemoveDailyQuest = function( self, quest_id )
	triggerEvent( "onServerRemovePlayerDailyQuest", self, quest_id, is_forced )
end

Player.RefreshDailyQuests = function( self, quest_id )
	triggerEvent( "onServerRefreshPlayerDailyQuest", self, quest_id, is_forced )
end

Player.CompleteDailyQuest = function( self, id )
	triggerEvent( "onServerCompleteQuest", self, self, id )
end

-------------------------------------------------------------------

Player.AddPermanentExpBonus = function( self, multiplier, duration )
	self:SetPermanentData( "exp_bonus", { multiplier = multiplier, finish_date = getRealTime( ).timestamp + duration } )
end

Player.ClearPermanentExpBonus = function( self )
	self:SetPermanentData( "exp_bonus", nil )
end

Player.GetPermanentExpBonusMultiplier = function( self )
	local bonus = self:GetPermanentData( "exp_bonus" )
	return ( bonus and bonus.multiplier and getRealTime( ).timestamp <= bonus.finish_date and bonus.multiplier ) or 1
end

-------------------------------------------------------------------
Player.AddJobMoneyBonus = function( self, multiplier, duration )
	self:SetPermanentData( "job_money_bonus", { multiplier = multiplier, finish_date = getRealTime( ).timestamp + duration } )
end

Player.ClearJobMoneyBonus = function( self )
	self:SetPermanentData( "job_money_bonus", nil )
end

Player.GetJobMoneyBonusMultiplier = function( self )
	local bonus = self:GetPermanentData( "job_money_bonus" )
	return ( bonus and bonus.multiplier and getRealTime( ).timestamp <= bonus.finish_date and bonus.multiplier ) or 1
end

-------------------------------------------------------------------
--	ТЕЛЕФОННЫЕ НОМЕРА
-------------------------------------------------------------------

Player.GetPhoneNumber = function( self )
    return self:GetPermanentData( "phone_number" ) or false
end

Player.SetPhoneContacts = function( self, contacts )
	self:SetPermanentData( "phone_contacts", contacts )
end

Player.GetPhoneContacts = function( self )
	return self:GetPermanentData( "phone_contacts" ) or {}
end

Player.AddPhoneContact = function( self, phone_number, player_id, player_nick )
	local contacts = self:GetPermanentData( "phone_contacts" ) or {}
	for k, v in pairs( contacts ) do
		if v.phone_number == phone_number then
			return false, "dublicate"
		end
	end
	
	table.insert( contacts, { phone_number = phone_number, player_id = player_id, player_nick = player_nick, favorite = false } )
	self:SetPhoneContacts( contacts )

	if #contacts >= 3 then
		self:CompleteDailyQuest( "np_add_contact" )
	end

	return true
end

Player.RemovePhoneContact = function( self, phone_number )
	local contacts = self:GetPermanentData( "phone_contacts" ) or {}
	for k, v in pairs( contacts ) do
		if v.phone_number == phone_number then
			table.remove( contacts, k )
			break
		end
	end
	self:SetPhoneContacts( contacts )
end

Player.IsPhoneExistContact = function( self, phone_number )
	local contacts = self:GetPermanentData( "phone_contacts" ) or {}
	for k, v in pairs( contacts ) do
		if v.phone_number == phone_number then
			return true
		end
	end
	return false
end

Player.SetContactFavorite = function( self, phone_number, value )
	local contacts = self:GetPermanentData( "phone_contacts" ) or {}
	for k, v in pairs( contacts ) do
		if v.phone_number == phone_number then
			contacts[ k ].favorite =  value
			break
		end
	end
	self:SetPhoneContacts( contacts )
end


GetPlayerFromPhoneNumber = function( phone_number )
	local pTarget = exports.nrp_phone_sim_shop:GetPlayerByPhoneNumber( phone_number )
	if pTarget and isElement( pTarget ) then
		return pTarget
	end
	return false
end

-------------------------------------------------------------------
--	ОБОИ НА ТЕЛЕФОН
-------------------------------------------------------------------

Player.GivePhoneWallpaper = function( self, wallpaper_id )
	-- wallpaper_id == CONST_WALLPAPER[ i ].img
	return exports.nrp_phone:GiveWallpaper( self, wallpaper_id )
end

Player.HasPhoneWallpaper = function( self, wallpaper_id )
	-- wallpaper_id == CONST_WALLPAPER[ i ].img
	local wallpapers = exports.nrp_phone:GetPlayerWallpapers( self )
	return wallpapers and wallpapers[ wallpaper_id ]
end

-------------------------------------------------------------------


-- Функции, не относящиеся к классу, но имеющие отношение к игрокам
AdminMessage = function( sMessage, iRed, iGreen, iBlue, bColored )
	local pPlayers = GetPlayersInGame( )
	for _, pPlayer in pairs( pPlayers ) do
		if pPlayer:IsAdmin( ) then
			pPlayer:outputChat( sMessage, iRed or 255, iGreen or 255, iBlue or 255, bColored or false )
		end
	end
end

GetPlayerFromClientID = function(id)
	for i, player in pairs( GetPlayersInGame( ) ) do
		if player:GetClientID( ) == id then
			return player
		end
	end
end

GetPlayerFromUserID = function( id )
	return GetPlayer( id, true )
end

-- Оффлайн
Player.UpdateOfflineData = function( self, key, value )
	triggerEvent( "SetOfflineDataForClientID", root, self:GetClientID( ), key, value )
end

-- Бесплатная эвакуация тачек
Player.GiveFreeEvacuation = function( self, vehicle_id )
	-- ставим vehicle_id = 0, чтобы эвакуция была доступна для любой тачки
	local evacuations = self:GetPermanentData( "free_evacuations" ) or { }
	evacuations[ vehicle_id ] = ( evacuations[ vehicle_id ] or 0 ) + 1
	self:SetPermanentData( "free_evacuations", evacuations )
end

Player.TakeFreeEvacuation = function( self, vehicle_id )
	local evacuations = self:GetPermanentData( "free_evacuations" ) or { }
	if ( evacuations[ vehicle_id ] or 0 ) <= 0 then
		vehicle_id = 0
	end
	evacuations[ vehicle_id ] = ( evacuations[ vehicle_id ] or 0 ) - 1
	if evacuations[ vehicle_id ] <= 0 then
		evacuations[ vehicle_id ] = nil
	end
	self:SetPermanentData( "free_evacuations", evacuations )
end

Player.HasFreeEvacuation = function( self, vehicle_id )
	return ( self:GetPermanentData( "free_evacuations" ) or { } )[ vehicle_id ]
end

Player.GetAllFreeEvacuations = function( self )
	return self:GetPermanentData( "free_evacuations" ) or { }
end

-- Social rating
Player.SetSocialRating = function ( self, value, source_type )
	value = not tonumber( value ) and 0 or math.ceil( tonumber( value ) )

	if value > 1000 then value = 1000
	elseif value < - 1000 then value = - 1000 end

	if source_type == "sr_donation" then
		local diff = value - self:GetSocialRating(  )
		self:SetSocialRatingAnchor( self:GetSocialRatingAnchor( ) + diff )
	end

	self:SetPermanentData( "social_rating", value )
	self:setData( "social_rating", value )
	triggerEvent( "onPlayerSomeDo", self, "update_social_rating" ) -- achievements
end

Player.GetSocialRating = function ( self )
	return self:GetPermanentData( "social_rating" ) or 0
end

Player.ChangeSocialRating = function ( self, value, source_type )
	if source_type ~= "sr_donation" and not self:IsSocialRatingChangeAvailable( value ) then return end

	local sR = self:GetSocialRating( )
	local new_value = sR + value 

	if not self:IsPremiumActive( ) and source_type ~= "sr_donation" then
		local sr_anchor = self:GetSocialRatingAnchor( )
 		new_value = Clamp( sr_anchor - 200, sR+value, sr_anchor + 100 )
 	end

	self:SetSocialRating( new_value, source_type )
end

Player.SetSocialRatingAnchor = function( self, value )
	local value = value and tonumber( value ) or 0
	self:SetPermanentData( "social_rating_anchor", value )
	self:SetPrivateData( "social_rating_anchor", value )
end

Player.GetSocialRatingAnchor = function( self )
	return self:GetPermanentData( "social_rating_anchor" ) or 0
end

Player.IsSocialRatingChangeAvailable = function( self, value )
	local value = value or 1
	local lim = 100
	local old_rating = self:GetSocialRating( )
	local anchor = self:GetSocialRatingAnchor( )
	local new_rating = old_rating + value

	if new_rating < -1000 or new_rating > 1000 then return false end

	if self:IsPremiumActive( ) then
		return true 
	end

	local higher_limit = anchor + lim
	local lower_limit = anchor - lim * 2

	if value < 0 and new_rating < lower_limit then
		return false
	elseif value > 0 and new_rating > higher_limit then
		return false
	end

	return true
end

-- Hide nickname
Player.SetHideNickExpirationTime = function( self, timestamp )
	if timestamp >= getRealTime( ).timestamp then -- sync only actual
		self:setData( "hide_nickname_time", timestamp )
	end

	self:SetPermanentData( "hide_nickname_time", timestamp )

	return true
end

Player.GetHideNickExpirationTime = function( self )
	return self:GetPermanentData( "hide_nickname_time" ) or 0
end

Player.HasHouseRentalDebt = function( self, id, number )
	return id == 0 and exports.nrp_vip_house:HasVipHouseRentalDebt( number )
		or id > 0  and exports.nrp_apartment:HasApartmentRentalDebt( id, number )
end

Player.HasAnyHouseRentalDebt = function( self )
	if exports.nrp_apartment:HasPlayerAnyApartmentRentalDebt( self ) then
		return true
	elseif exports.nrp_vip_house:HasPlayerAnyVipHouseRentalDebt( self ) then
		return true
	end

	return false
end

Player.GetCoopJobLobbyId = function( self )
	return self:getData( "work_lobby_id" )
end

Player.GetCoopJobRole = function( self )
	return self:getData( "coop_job_role_id" )
end

Player.SetBlockInteriorInteraction = function( self, state )
	self:SetPrivateData( "block_interior", state )
	return true
end

Player.GetBlockInteriorInteraction = function( self, state )
	return self:getData( "block_interior" )
end

Player.SetBlockCleanupMemory = function( self, state )
	self:SetPrivateData( "block_cleanup_memory", state )
	return true
end

Player.GetBlockCleanupMemory = function( self, state )
	return self:getData( "block_cleanup_memory" )
end

Player.GetNeons = function( self )
	return self:GetPermanentData( "neons" ) or { }
end

Player.GiveNeon = function( self, neon_data )
	local neons = self:GetNeons( )
	table.insert( neons, neon_data )
	self:SetPermanentData( "neons", neons )
end

Player.TakeNeon = function( self, neon_data )
	local neons = self:GetNeons( )

	local to_remove = nil
	for i, v in ipairs( neons ) do
		if table.compare( v, neon_data ) then
			table.remove( neons, i )
			self:SetPermanentData( "neons", neons )
			return true
		end
	end
end

Player.HasVoiceStation = function( self, station_id )
	local player_voice_channels = self:getData( "voice_channels" ) or {}
	return player_voice_channels[ station_id ]
end

Player.AddVoiceStation = function( self, station_id )
	local player_voice_channels = self:getData( "voice_channels" ) or {}
	player_voice_channels[ station_id ] = true
	self:setData( "voice_channels", player_voice_channels, false )
end

Player.RemoveVoiceStation = function( self, station_id )
	local player_voice_channels = self:getData( "voice_channels" ) or {}
	player_voice_channels[ station_id ] = nil
	self:setData( "voice_channels", player_voice_channels, false )
end

Player.SetMuteVoice = function( self, duration )
	local end_time_mute = getRealTimestamp( ) + duration
	self:setData( "mute_voice", end_time_mute, false )
	triggerEvent( "onPlayerMute", self, end_time_mute )
end

Player.SetUnMuteVoice = function( self )
	self:setData( "mute_voice", false, false )
end

Player.AddCasinoGameWinAmount = function( self, casino_id, game_id, win_amount )
	if not type( win_amount ) ~= "number" or win_amount <= 0 then end
	triggerEvent( "onAddCasinoGameWinAmount", root, self, casino_id, game_id, win_amount )
end

Player.AddCasinoGameLoseAmount = function( self, lose_amount )
	if not type( lose_amount ) ~= "number" or lose_amount <= 0 then end
	triggerEvent( "onAddCasinoGameLoseAmount", self, lose_amount )
end

Player.StartShortOffer = function ( self, short_offer_name )
	local current_time = getRealTimestamp( )
	local last_offer_time = self:GetPermanentData( "last_short_offer_time" ) or 0

	if current_time - last_offer_time < 3600 * 24 then
		local time_from = last_offer_time + 3600 * 24
		local data = self:GetPermanentData( short_offer_name ) or { }

		data.time_from = time_from

		self:SetPermanentData( short_offer_name, data )
		self:SetPermanentData( "last_short_offer_time", time_from )

		return false
	else
		self:SetPermanentData( "last_short_offer_time", current_time )

		return true
	end
end

Player.LoadShortOffer = function ( self, short_offer_name )
	local data = self:GetPermanentData( short_offer_name )
	if not data or data.time_to == 0 then
		return
	end

	local current_time = getRealTimestamp( )
	if data.time_from and not data.time_to then
		if data.time_from <= current_time then
			return true
		end
	elseif ( data.time_to or 0 ) > current_time then
		self:SetPrivateData( short_offer_name, data )
	else
		self:SetPermanentData( short_offer_name, { time_to = 0 } )
	end
end