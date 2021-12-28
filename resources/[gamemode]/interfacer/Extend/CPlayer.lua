-- CPlayer.lua

Import( "ShPlayer" )

Player.GetMoney = function(self)
	return getElementData( self, "money" )
end

Player.GetLevel = function(self)
	return getElementData(self,"level") or 1
end

Player.GetExp = function(self)
	return getElementData(self,"exp") or 150
end

Player.GetAllVehiclesDiscount = function( self )
	local data = getElementData( self, "all_vehicles_discount" )
	if data and data.timestamp then
		if data.timestamp >= getRealTimestamp( ) then
			return data
		end
	end
end

Player.GetHobbyItems = function( self )
	return self:getData( "hobby_items" ) or {}
end

Player.GetHobbyEquipment = function( self )
	return self:getData( "hobby_equipment" ) or {}
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

Player.GetHobbiesData = function( self )
	return getElementData( self, "hobby_data" ) or {}
end

Player.GetJobID = function( self )
	local shift_info = getElementData( self, "job_shift" )
	return shift_info and shift_info.job_id
end

Player.GetJobClass = function( self )
	local shift_info = getElementData( self, "job_shift" )
	return shift_info and shift_info.job_class
end

Player.GetCoopJobClass = function( self )
	return getElementData( self, "coop_job_class" )
end

Player.PhoneNotification = function( self, data )
	triggerEvent( "OnClientReceivePhoneNotification", self, data )
end

Player.GetPhoneNumber = function( self )
    return self:getData( "phone_number" )
end

Player.ShowRewards = function( self, ... )
    triggerEvent( "ShowRewards", self, { ... } )
end

Player.HasFCMembership = function( self )
	return ( getElementData( self, "fc_membership" ) or 0 ) > getRealTime().timestamp
end

Player.HasDance = function( self, iDance )
	local iDance = tostring(iDance)
	local pDances = getElementData( self, "unlocked_animations" ) or {}
	if pDances[iDance] then
		return true
	end

	return false
end

Player.GetBoostersData = function( self )
	return self:getData("temp_boosters") or {}
end

Player.IsBoosterActive = function( self, booster )
	local boosters = self:GetBoostersData()

	for k,v in pairs(boosters) do
		if v.id == booster and v.expires >= getRealTime().timestamp then
			return v
		end
	end

	return false
end

Player.IsUnlocked = function( self, key )
	local key = tostring(key)
	local pUnlocks = getElementData( self, "unlocks" ) or {}
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

Player.ErrorWindow = function( self, text, title )
	triggerEvent( "onErrorWindow", root, text, title )
end

Player.InfoWindow = function( self, text, title )
	triggerEvent( "onInformationWindow", root, text, title )
end


Player.MissionFailed = function( self, text )
	triggerEvent( "ShowPlayerUIQuestFailed", root, text )
end

Player.MissionCompleted = function( self, text )
	triggerEvent( "ShowPlayerUIQuestSuccess", root, nil, text )
end

Player.GetFaction = function( self )
	return getElementData( self, "faction_id" ) or 0
end

Player.GetFactionLevel = function( self )
	return getElementData( self, "faction_level" ) or 0
end

Player.GetFactionExp = function( self )
	return getElementData( self, "faction_exp" ) or 0
end

Player.IsOnFactionDayOff = function ( self )
	return ( self:getData( "factions_day_off" ) or 0 ) > getRealTimestamp( )
end

Player.AddWanted = function( self, sArticle, iAmount, bCheck )
	if self.dimension >= 2 then return end

	if bCheck and self:IsWantedFor( sArticle ) then
		return false
	end

	triggerServerEvent( "OnClientPlayerAddWanted", self, sArticle, iAmount, bCheck )
	
	return true
end

Player.GetClanID = function( self )
	local team = self:GetClanTeam( )
	return team and team:GetID( )
end

Player.GetClanRole = function( self )
	return self:getData( "clan_role" ) or 0
end

Player.GetClanRank = function( self )
	return getElementData( self, "clan_rank" )
end

Player.GetClanEXP = function( self )
	return getElementData( self, "clan_exp" ) or 0
end

Player.NotEnoughtMoney = function( self )
	triggerEvent( "ShowNotEnoughtWindow", self, true )
end
Player.NotEnoughMoney = Player.NotEnoughtMoney

Player.GetCalories = function( self )
	return getElementData( self, "calories" ) or 100
end

Player.GetStamina = function( self )
	return getElementData( self, "stamina" ) or 100
end

Player.HasDisease = function( self )
	return getElementData( self, "has_disease" )
end

Player.GetDiseaseStage = function( self )
	return getElementData( self, "disease_stage" )
end

Player.GetAccessLevel = function( self )
	return getElementData( self, "_alevel" ) or 0
end

Player.IsAdmin = function( self )
	return self:GetAccessLevel() > 0
end



	Player.GetClientID = function( )
		return getPlayerSerial(self)
	end


Player.ShowInfo = function(self, text)
	triggerEvent("ShowInfo", self, text)
end

Player.CloseInfo = function( self )
	triggerEvent( "CloseInfo", self )
end

Player.ShowError = function(self, text)
	triggerEvent("ShowError", self, text)
end

Player.ShowWarning = function(self, text)
	triggerEvent("ShowWarning", self, text)
end

Player.ShowSuccess = function( self, text )
	triggerEvent( "ShowSuccess", self, text )
end

Player.ShowNotification = function( self, text )
	return triggerEvent( "ShowInfo", self, text )
end

Player.GetHunger = function(self)
	return getElementData( self, "player_hunger" ) or 0
end

Player.GetGender = function( self )
	return getElementData( self, "gender" ) or 0
end

Player.TeleportToColshape = function( self, colshape )
	fadeCamera( false, 0 )

	self.frozen = true
	self:Teleport( colshape.position, colshape.dimension, colshape.interior )

	Timer( function ( )
		fadeCamera( true, 0.5 )
		self.frozen = false
	end, 2000, 1 )
end

Player.CompleteDailyQuest = function( self, id )
	triggerServerEvent( "onServerCompleteQuest", self, self, id )
end

Player.IsInOrAroundWater = function( self )
	if localPlayer.inWater then return true end
	
	local px, py, pz = getElementPosition( self )
	local water_level = getWaterLevel( px, py, pz )

	if water_level then
		local difference = math.abs( pz - water_level )
		if difference <= 10 and not isPedOnGround( self ) then
			return true
		end
	end
end

Player.GetCoopJobLobbyId = function( self )
	return self:getData( "work_lobby_id" )
end

Player.GetBlockInteriorInteraction = function( self, state )
	return self:getData( "block_interior" )
end

Player.GetBlockCleanupMemory = function( self, state )
	return self:getData( "block_cleanup_memory" )
end

_CARRYING = nil
function StartCarrying( conf )
	if _CARRYING then return end

	toggleControl( "fire", false )
	toggleControl( "jump", false )
	toggleControl( "sprint", false )
	toggleControl( "crouch", false )
	toggleControl( "enter_exit", false )
	toggleControl( "next_weapon", false )
	toggleControl( "previous_weapon", false )
	toggleControl( "aim_weapon", false )

	setPedWeaponSlot( localPlayer, 0 )

	local object = Object( conf.model or 3052, localPlayer.position )
	exports.bone_attach:attachElementToBone( object, localPlayer, conf.bone or 8, conf.offset_x or 0.1, conf.offset_y or 0.3, conf.offset_z or 0.3, conf.rx or 25, conf.ry or 180, conf.rz or 25 )

	object.dimension = localPlayer.dimension

	setPedAnimation( localPlayer, "CARRY", "crry_prtial", 0, true, true, false, true )
	toggleControl( "fire", false )

	local timer = setTimer( function( )
		local class, id = getPedAnimation( localPlayer )
		if class ~= "CARRY" or id ~= "crry_prtial" then
			setPedAnimation( localPlayer, "CARRY", "crry_prtial", 0, true, true, false, true )
		end
	end, 100, 0 )

	_CARRYING = { timer = timer, object = object }

	return object
end

function StopCarrying( conf )
	if not _CARRYING then return end

	if isTimer( _CARRYING.timer ) then killTimer( _CARRYING.timer ) end
	if isElement( _CARRYING.object ) then destroyElement( _CARRYING.object ) end

	_CARRYING = nil

	toggleControl( "fire", true )
	toggleControl( "jump", true )
	toggleControl( "sprint", true )
	toggleControl( "crouch", true )
	toggleControl( "enter_exit", true )
	toggleControl( "next_weapon", true )
	toggleControl( "previous_weapon", true )
	toggleControl( "aim_weapon", true )

	setPedAnimation( localPlayer, "CARRY", "liftup", 0, false, false, false, false )
end

Player.SetStateShowDocuments = function( self, state, source )
	if state and self:IsInEventLobby( ) then return false end
	
	if self:getData( "is_show_document" ) and state then
        if self ~= source then
            triggerServerEvent( "ShowNotificationShowDocuments", source )
        end
        return false
    end

    self:setData( "is_show_document", state, false )
    return true
end

Player.GetCoopJobRole = function( self )
    return self:getData( "coop_job_role_id" )
end

Player.GetSocialRating = function ( self )
	return self:getData( "social_rating" ) or 0
end