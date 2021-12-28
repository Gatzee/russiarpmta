loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShVehicle" )
Extend( "CAI" )
Extend( "ShVehicleConfig" )
Extend( "ShInventoryConfig" )
Extend( "ShWedding" )

INTERACT_DISTANCE = 8
LAST_ACTION_DONE = 0

RADIAL_ACTIONS = 
{

	{
		sTargetType = "player",
		sIcon = "PlayerHandcuffs",
		sText = "КПЗ",
		iNextHeal = 0,

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget

			local sName = pTarget:GetNickName() or ""
			local iJail = exports.nrp_jail:GetClosestJail( localPlayer )
			local bIsJailed = pTarget:getData("jailed")
			self.args = { not bIsJailed, iJail }
			self.sText = bIsJailed and "Освободить" or ("Заключить\n" .. sName)
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end
			if not FACTION_RIGHTS.JAILID[ localPlayer:GetFaction() ] then return end

			local faction_level = localPlayer:GetFactionLevel()
			if pTarget:getData("jailed") and faction_level <= 2 then return end -- прапорщик и выше
			if isPedDead(pTarget) or isPedDead(localPlayer) then return end
			if localPlayer:getData("jailed") then return end

			local bIsJailed = pTarget:getData("jailed")
			if bIsJailed and faction_level < FACTION_OWNER_LEVEL - 1 then
				return
			end

			local iJail = exports.nrp_jail:GetClosestJail( localPlayer )
			if not iJail then
				return
			end

			triggerEvent ( "onResetTaser", root ) 
			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end

			if pArgs[1] then
				pTarget:Jail(pPlayer, pArgs[2])

				WriteLog( "factions/jail", "%s посадил игрока %s в КПЗ", pPlayer, pTarget )
			else
				triggerClientEvent(pPlayer, "jail:ShowReleaseUI", pPlayer, true)
			end

			return true
		end,
	},

	{
		sTargetType = "ped",
		sIcon = "PlayerHandcuffs",
		sText = "КПЗ",

		client_only = true,

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget
			self.args = { true, iJail }
			self.sText = "Заключить человека"
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			return localPlayer:getData( "fake_jail_enabled" )
		end,

		fClientApply = function( self, pTarget, pArgs )
			triggerEvent( "onClientPlayerFakeJail", localPlayer, pTarget, pArgs )

			return true
		end,
	},

	{
		sTargetType = "player",
		sIcon = "PlayerHandcuffs",
		sText = "Тюрьма",
		iNextHeal = 0,

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget

			local sName = pTarget:GetNickName() or ""
			local iJail, iRoomID = exports.nrp_fsin_jail:GetClosestRoom( localPlayer )
			local bIsJailed = pTarget:getData("jailed") == "is_prison"
			self.args = { bIsJailed, iJail, iRoomID }
			self.sText = "Заключить\n" .. sName
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end
			if not FACTION_RIGHTS.PRISONID[ localPlayer:GetFaction() ] then return end
			if localPlayer:GetFactionLevel() <= 2 then return end -- прапорщик и выше
			if isPedDead(pTarget) or isPedDead(localPlayer) then return end
			if pTarget:getData("jailed") ~= "is_prison" then return end
			
			local iJail, iRoomID = exports.nrp_fsin_jail:GetClosestRoom( localPlayer )
			if not iJail or not iRoomID then
				return
			end
			
			triggerEvent ( "onResetTaser", root )
			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end

			if exports.nrp_fsin_jail:IsPlayerInCamera( pTarget ) then 
				pPlayer:ShowError( "Игрок уже находится в заключении" )
				return 
			end

			if pArgs[1] then
				triggerEvent( "prison:OnServerJailPlayerByFsin", pPlayer, pTarget, pArgs[2], pArgs[3] )

				WriteLog( "factions/jail", "%s посадил игрока %s в тюрьму", pPlayer, pTarget )
			else
				--triggerClientEvent(pPlayer, "jail:ShowReleaseUI", pPlayer, true)
			end

			return true
		end,
	},

	{
		sTargetType = "player",
		sIcon = "PlayerMedic",
		sText = "Вылечить",
		iNextHeal = 0,

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget

			local name = pTarget:GetNickName() or ""
			self.sText = "Вылечить\n"..name
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end
			if not FACTION_RIGHTS.HEALTH[ localPlayer:GetFaction() ] then return end
			if isPedDead(pTarget) or isPedDead(localPlayer) then return end
			local max_health = 100 + ( 100 / 431 * ( pTarget:getStat( 24 ) - 569 ) )
			if pTarget.health >= max_health then return end
			if localPlayer.dimension ~= pTarget.dimension then return end
			if not localPlayer:IsOnFactionDuty( ) then return end

			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end

			triggerEvent("OnPlayerTryHeal", pPlayer, pTarget)

			pTarget:CompleteDailyQuest( "band_heal_in_hospital" )

			return true
		end,
	},

	{
		sTargetType = "player",
		sIcon = "PlayerMedic",
		sText = "Реанимировать",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget

			local name = pTarget:GetNickName() or ""
			self.sText = "Реанимировать\n"..name
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end
			if not FACTION_RIGHTS.REANIMATION[ localPlayer:GetFaction() ] then return end
			if not isPedDead(pTarget) or isPedDead(localPlayer) then return end

			local iWeapon = getPedWeapon( localPlayer )
			if iWeapon ~= 10 then return end

			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end

			triggerEvent("OnPlayerTryRevive", pPlayer, pTarget)

			return true
		end,
	},

	{
		sTargetType = "player",
		sIcon = "PlayerTreat",
		sText = "Начать лечение",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget

			local name = pTarget:GetNickName() or ""
			self.sText = "Начать лечение\n" .. name
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end
			if not FACTION_RIGHTS.HEALTH[ localPlayer:GetFaction() ] then return end
			if not localPlayer:IsOnFactionDuty() then return end
			if pTarget.dead then return end
			if localPlayer.dimension ~= pTarget.dimension then return end

			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end

			triggerEvent( "onPlayerTryStartTreat", pPlayer, pTarget )

			return true
		end,
	},

	{
		sTargetType = "player",
		sIcon = "Documents",
		sText = "Запросить паспорт",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget

			local name = pTarget:GetNickName() or ""
			self.sText = "Запросить паспорт у\n"..name
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end
			if not FACTION_RIGHTS.DOC_CHECK[ localPlayer:GetFaction() ] then return end
			if not localPlayer:IsOnFactionDuty() then return end
			if isPedDead(pTarget) or isPedDead(localPlayer) then return end
			if localPlayer:getData("jailed") then return end
			if pTarget:getData("jailed") then return end
			if localPlayer.dimension ~= pTarget.dimension then return end

			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end

			triggerEvent( "OnPlayerTryRequestDocuments", pPlayer, pTarget )

			return true
		end,
	},

	{
		sTargetType = "player",
		sIcon = "AddFine",
		sText = "Штрафы",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget

			local name = pTarget:GetNickName() or ""
			self.sText = "Выписать штраф\n"..name
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end
			if not FACTION_RIGHTS.FINES_GIVE[ localPlayer:GetFaction() ] then return end
			if isPedDead(pTarget) or isPedDead(localPlayer) then return end
			if localPlayer:getData("jailed") then return end
			if pTarget:getData("jailed") then return end
			if not localPlayer:IsOnFactionDuty() then return end
			if pTarget:GetLevel() <= 3 then return end
			if localPlayer.dimension ~= pTarget.dimension then return end

			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end
			triggerEvent( "OnPlayerRequestAddFineOrWantedUI", pPlayer, pTarget, 1 )

			return true
		end,
	},

	{
		sTargetType = "player",
		sIcon = "food",
		sText = "Накормить",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget

			local name = pTarget:GetNickName() or ""
			self.sText = "Накормить\n"..name
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end
			if isPedDead(pTarget) or isPedDead(localPlayer) then return end
			local current_quest = localPlayer:getData( "current_quest" )
			if not current_quest or current_quest.id ~= "task_mayor_1" then return end
			if localPlayer.dimension ~= pTarget.dimension then return end

			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end
			local target_faction = pTarget:GetFaction( )
			if target_faction > 0 and FACTIONS_BY_CITYHALL[ target_faction ] == target_faction then
				pPlayer:ShowError( "Нельзя накормить сотрудника мэрии" )
				return
			end
			local maxCalories = pTarget:getData( "max_calories" ) or 100
			if pTarget:GetCalories() > maxCalories - 10 then
				pPlayer:ShowError( "Человек не голоден" )
				return
			end

			triggerEvent( "OnPlayerTryGiveFreeFood", pPlayer, pTarget )

			return true
		end,
	},

	{
		sTargetType = "player",
		sIcon = "Documents",
		sText = "Выдать розыск",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget

			local name = pTarget:GetNickName() or ""
			self.sText = "Выдать розыск\n"..name
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end
			if not FACTION_RIGHTS.WANTED_GIVE[ localPlayer:GetFaction() ] then return end
			if not localPlayer:IsOnFactionDuty() then return end
			if isPedDead(pTarget) or isPedDead(localPlayer) then return end
			if FACTION_RIGHTS.WANTED_GIVE[ pTarget:GetFaction() ] then return end
			if localPlayer:getData("jailed") then return end
			if pTarget:getData("jailed") then return end
			if localPlayer.dimension ~= pTarget.dimension then return end

			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end

			triggerEvent( "OnPlayerRequestAddFineOrWantedUI", pPlayer, pTarget, 2 )
			return true
		end,
	},

	{
		sTargetType = "player",
		sIcon = "AddMute",
		sText = "Заглушить игрока",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget

			local name = pTarget:GetNickName() or ""
			self.sText = "Заглушить игрока\n"..name
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end
			if not FACTION_RIGHTS.MUTE_GIVE[ localPlayer:GetFaction() ] then return end
			if isPedDead(pTarget) or isPedDead(localPlayer) then return end
			if FACTION_RIGHTS.MUTE_GIVE[ pTarget:GetFaction() ] then return end
			if localPlayer:getData("jailed") then return end
			if pTarget:getData("jailed") then return end
			if localPlayer.dimension ~= pTarget.dimension then return end
			if not localPlayer:IsOnFactionDuty() then return end

			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end

			local timestamp = getRealTimestamp( )
			local minutes = 3
			local duration = 60 * minutes
			local voice_mute_timeout = pPlayer:getData( "voice_mute_timeout" )

			if voice_mute_timeout and timestamp < voice_mute_timeout then
				pPlayer:ShowInfo( "Не так часто!" )
				return false
			end

			pPlayer:setData( "voice_mute_timeout", timestamp + duration, false )
			pTarget:SetMuteVoice( duration )

			pPlayer:ShowInfo( "Игрок заглушен" )
			pTarget:ShowInfo( "Голосовой чат заблокирован на " .. minutes .. plural( minutes, " минуту", " минуты", " минут" ) ) 
			return true
		end,
	},

	{
		sTargetType = "player",
		sIcon = "PlayerHandcuffs",
		sText = "Наручники",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget
			local state = pTarget:getData("is_handcuffed")
			if state then
				self.sText = "Снять наручники"
				self.args = { false }
			else
				self.sText = "Заковать в наручники"
				self.args = { true }
			end
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			local factionID = localPlayer:GetFaction( )

			if not PreCheckClient( pTarget ) then return end
			if isPedInVehicle(pTarget) then return end
			if isPedDead(pTarget) or isPedDead(localPlayer) then return end
			if not FACTION_RIGHTS.HANDCUFFS[ factionID ] then return end
			if not pTarget:getData("is_tased") and not pTarget:getData("is_handcuffed") then return end
			--if pTarget:getData("jailed") and factionID ~= F_FSIN then return end
			
			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end

			triggerEvent( "OnPlayerTryPutHandcuffs", pPlayer, pTarget, pArgs[1] )

			return true
		end,
	},

	{
		sTargetType = "ped",
		sIcon = "PlayerHandcuffs",
		sText = "Наручники",

		client_only = true,


		fPrepareClientData = function( self, pTarget )
			self.target = pTarget
			local state = pTarget:getData( "is_handcuffed" )
			if state then
				self.sText = "Снять наручники"
				self.args = { false }
			else
				self.sText = "Заковать в наручники"
				self.args = { true }
			end
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			return localPlayer:getData( "fake_handcuffs_enabled" )
		end,

		fClientApply = function( self, pTarget, pArgs )
			triggerEvent( "onClientPlayerFakeHandcuff", localPlayer, pTarget, pArgs )

			return true
		end,
	},

	--[[{
		sTargetType = "vehicle",
		sIcon = "VehicleSignal",
		sText = "сигнализация",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget
			local state = pTarget:GetSignal()
			if state then
				self.sText = "Выключить\nсигнализацию"
				self.args = { false }
			else
				self.sText = "Включить\nсигнализацию"
				self.args = { true }
			end
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end

			if pTarget:IsOwnedBy(localPlayer, true) then
				return true
			end
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end

			if pTarget:IsOwnedBy(pPlayer, true) then
				pTarget:SetSignalMode( pArgs[1] )
				return true
			end
		end,
	},]]

	{
		sTargetType = "vehicle",
		sIcon = "VehicleHood",
		sText = "капот",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget

			local conf = VEHICLE_CONFIG[pTarget.model]

			local state = getElementData( pTarget, "cd_state_0" ) == 1 or (not conf or not conf.ignoreDefaultDoors) and getVehicleDoorOpenRatio( pTarget, 0 ) >= 0.9
			if state then
				self.sText = "Закрыть"
				self.args = { 0 }
			else
				self.sText = "Открыть"
				self.args = { 1 }
			end
			self.sText = self.sText .. ( FRONT_TRUNK_VEHICLES[ pTarget.model ] and " багажник" or " капот" )
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end

			if pTarget:getData( "block_interaction" ) then
				return false
			end

			if IsSpecialVehicle( pTarget.model ) then
				return false
			end

			local config = VEHICLE_CONFIG[ pTarget.model ]
			if not pTarget.components.bonnet_dummy and ( not config.customDoors or not config.customDoors[ 0 ] ) or config.no_bonnet then
				return false
			end
			
			if VEHICLE_TYPE_BIKE[ pTarget.model ] or config.is_moto then
				return false
			end

			if pTarget:isLocal( ) then
				return false
			end

			if pTarget:GetOwnerID() ~= localPlayer:GetID() then
				return false
			end

			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end
			local conf = VEHICLE_CONFIG[ pTarget.model ]

			if pTarget:GetOwnerID() ~= pPlayer:GetID() then
				return false
			end

			if not conf or not conf.ignoreDefaultDoors then
				setVehicleDoorOpenRatio( pTarget, 0, pArgs[1], 1000 )
			end

			if conf and conf.customDoors then
				setElementData( pTarget, "cd_state_0", pArgs[1] )
			end

			if FRONT_TRUNK_VEHICLES[ pTarget.model ] then
				triggerClientEvent( pPlayer, "onVehicleTrunkStateChange", pTarget, pArgs[1] == 1 )
			end

			return true
		end,
	},

	{
		sTargetType = "vehicle",
		sIcon = "VehicleTrunk",
		sText = "багажник",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget

			local conf = VEHICLE_CONFIG[pTarget.model]

			local state = getElementData( pTarget, "cd_state_1" ) == 1 or (not conf or not conf.ignoreDefaultDoors) and getVehicleDoorOpenRatio( pTarget, 1 ) >= 0.9
			if state then
				self.sText = "Закрыть"
				self.args = { 0 }
			else
				self.sText = "Открыть"
				self.args = { 1 }
			end
			self.sText = self.sText .. ( FRONT_TRUNK_VEHICLES[ pTarget.model ] and " капот" or " багажник" )
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end

			if pTarget:getData( "block_interaction" ) then
				return false
			end

			if IsSpecialVehicle( pTarget.model ) then
				return false
			end

			local config = VEHICLE_CONFIG[ pTarget.model ]
			if not pTarget.components.boot_dummy and ( not config.customDoors or not config.customDoors[ 1 ] ) or config.no_boot then
				return false
			end
			
			if VEHICLE_TYPE_BIKE[ pTarget.model ] or config.is_moto then
				return false
			end

			if pTarget:isLocal( ) then
				return false
			end

			if pTarget:GetOwnerID() ~= localPlayer:GetID() then
				return false
			end

			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end
			local conf = VEHICLE_CONFIG[pTarget.model]

			if pTarget:GetOwnerID() ~= pPlayer:GetID() then
				return false
			end

			if not conf or not conf.ignoreDefaultDoors then
				setVehicleDoorOpenRatio( pTarget, 1, pArgs[1], 1000 )
			end

			if conf and conf.customDoors then
				setElementData( pTarget, "cd_state_1", pArgs[1] )
			end

			triggerClientEvent( pPlayer, "onVehicleTrunkStateChange", pTarget, pArgs[1] == 1 )
			
			return true
		end,
	},

	{
		sTargetType = "vehicle",
		sIcon = "VehicleLock",
		sText = "замки",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget
			local state = isVehicleLocked( pTarget )
			if state then
				self.sText = "Открыть двери"
				self.args = { false }
			else
				self.sText = "Закрыть двери"
				self.args = { true }
			end
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end

			if VEHICLE_TYPE_BIKE[ pTarget.model ] or VEHICLE_CONFIG[ pTarget.model ].is_moto then
				return false
			end

			if pTarget:getData( "block_interaction" ) then
				return false
			end

			if pTarget:isLocal( ) then
				return false
			end

			if pTarget:IsOwnedBy(localPlayer, true) then
				return true
			end
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end

			if pTarget:IsOwnedBy( pPlayer, true ) then
				if not pArgs[1] then
					if pTarget:getData( 'tow_evacuating' ) then
						return
					end
				end
				setVehicleLocked( pTarget, pArgs[1] )
				return true
			end

			return false
		end,
	},

	{
		sTargetType = "controlled_vehicle",
		sIcon = "VehicleLights",
		sText = "фары",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget
			local state = getVehicleOverrideLights( pTarget ) == 2
			if state then
				self.sText = "Выключить фары"
				self.args = { 1 }
			else
				self.sText = "Включить фары"
				self.args = { 2 }
			end
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end

			if IsSpecialVehicle( pTarget.model ) == "boat" then
				return false
			end

			if localPlayer:getData( "tutorial" ) then
				return false
			end

			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end
			setVehicleOverrideLights( pTarget, pArgs[1] )
			return true
		end,
	},

	{
		sTargetType = "controlled_vehicle",
		sIcon = "VehicleEngine",
		sText = "двигатель",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget
			local state = getVehicleEngineState( pTarget )
			if state then
				self.sText = "Заглушить двигатель"
				self.args = { false }
			else
				self.sText = "Завести двигатель"
				self.args = { pTarget:GetFuel() > 0 }
			end
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end
			if not VEHICLE_CONFIG[ pTarget.model ].is_boat and isElementInWater( pTarget ) then return end

			if localPlayer:getData( "block_engine_incasator" ) or pTarget:getData( "block_engine" ) then
				return false
			end

			if pTarget:IsOwnedBy(localPlayer) or pTarget:getData("exam_vehicle") then
				return true
			end
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end
			if pTarget:IsEngineEnabled( pPlayer ) then
				if getVehicleController(pTarget) == pPlayer then
					setVehicleEngineState( pTarget, pArgs[1] )
					triggerEvent( "PlayerAction_VehicleToggleEngine", pPlayer, pTarget )
					return true
				end
			end
		end,
	},

	{
		sTargetType = "controlled_vehicle",
		sIcon = "Cruise",
		sText = "Включить ограничитель скорости",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget
			local state = getElementData( localPlayer, "cruise_state" )
			if state then
				self.sText = "Выключить круиз"
				self.args = { false }
			else
				self.sText = "Включить круиз"
				self.args = { true }
			end
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end
			if not VEHICLE_CONFIG[ pTarget.model ].is_boat and isElementInWater( pTarget ) or localPlayer:getData( "blocked_cruise" ) then return end

			local restricted_models = 
			{
				[530] = true
			}

			if restricted_models[ model ] then
				return false
			end
			
			if localPlayer:getData("in_race") then
				return false
			end

			if localPlayer:getData("in_clan_event_lobby") then
				return false
			end

			if localPlayer:getData( "tutorial" ) then
				return false
			end

			local model = pTarget.model

			if IsSpecialVehicle( model ) then 
				return false 
			end

			if VEHICLE_TYPE_BIKE[ model ] or VEHICLE_TYPE_QUAD[ model ] or model == 468 or model == 530 then
				return false
			end

			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end
			if getVehicleController(pTarget) == pPlayer then
				triggerEvent( "SwitchSpeedLimiter", pPlayer, pTarget, pArgs[1] )
				return true
			end
		end,
	},

	{
		sTargetType = "near_vehicles",
		sIcon = "Drag",
		sText = "Драг-рейсинг",

		client_only = true,

		fClientCheck = function( self, pTarget )
			if not isElement( localPlayer.vehicle ) or getPedOccupiedVehicleSeat( localPlayer ) ~= 0 then
				return false
			end

			local restricted_models = {
				[ 468 ] = true,
				[ 530 ] = true,
				[ 471 ] = true,
			}
			if localPlayer.vehicle:GetID() < 0 or not localPlayer.vehicle:IsNormalVehicle() or restricted_models[ localPlayer.vehicle.model ] then
				return false
			end

			return true
		end,

		fPrepareClientData = function( self, pTargets )
			if not isElement( localPlayer.vehicle ) then return end

			local function IsCanJoinDrag( pTarget )
				if not pTarget then return end
				local targed_id = pTarget:GetID()
				if not targed_id or targed_id < 0 then return end
				local controller = pTarget.controller 
				if not controller or controller == localPlayer then return end
				if getElementDimension( pTarget ) ~= 0 then return end
				local faction_vehicle = pTarget:GetFaction()
				if faction_vehicle ~= 0 then return end
				if pTarget:GetSpecialType() or not pTarget:IsNormalVehicle() then return end
				
				local restricted_models = {
					[ 468 ] = true,
					[ 530 ] = true,
					[ 471 ] = true,
				}
				if restricted_models[ pTarget.model ] then
					return false
				end
				return true
			end

			self.target = getElementsWithinRange( localPlayer.position, 50, "vehicle")
			pTargets = self.target

			for i, veh in pairs( pTargets ) do 
				if not IsCanJoinDrag( veh ) then pTargets[ i ] = nil end
			end
			
			local pos = localPlayer.position
			table.sort( pTargets,
				function( a, b )
					if a and b then 
						return ( pos - a.position ).length < ( pos - b.position ).length
					elseif a then
						return true
					end
					return false
				end 
			)

			self.child_items = { }
			local player_vehicle_position = localPlayer.vehicle.position
			for _, vehicle in pairs( pTargets ) do
				local player = vehicle.controller
				if player and player ~= localPlayer then
					table.insert( self.child_items,{
						sTargetType = "vehicle",
						target = vehicle,
						sIcon = "Drag",
						client_only = true,
						sText = player:GetNickName(),
						fClientCheck = self.fClientCheck,
						fClientApply = self.fClientApply,
						id = self.id,
					})
					if #self.child_items == 4 then
						break
					end
				end
			end


			return true
		end,

		fClientApply = function( self, pTarget, pArgs )
			pTarget = self.target
			triggerServerEvent( "RC:onServerPlayerWantOpenDragRace", root, 
			{
				nickname  = pTarget.controller:GetNickName(),
				race_type = "drag",
			})

			return true
		end,
	},

	{
		sTargetType = "controlled_vehicle",
		sIcon = "VehicleLock",
		sText = "замки",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget
			local state = isVehicleLocked( pTarget )
			if state then
				self.sText = "Открыть двери"
				self.args = { false }
			else
				self.sText = "Закрыть двери"
				self.args = { true }
			end
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end

			if localPlayer:getData( "tutorial" ) then
				return false
			end

			if VEHICLE_TYPE_BIKE[ pTarget.model ] or ( VEHICLE_CONFIG[ pTarget.model ] or { } ).is_moto then
				return false
			end
			

			if pTarget:IsOwnedBy(localPlayer, true) then
				return true
			end
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end

			if pTarget:IsOwnedBy(pPlayer, true) then
				setVehicleLocked( pTarget, pArgs[1] )
				return true
			end

			return true
		end,
	},

	{
		sTargetType = "controlled_vehicle",
		sIcon = "VehicleEngine",
		sText = "Передать ключи",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget
			local sTargetPlayer = getVehicleOccupant( pTarget, 1 ):GetNickName() or ""
			self.sText = "Передать ключи\n"..sTargetPlayer
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end

			if not getVehicleOccupant( pTarget, 1 ) then
				return false
			end

			if getElementType( getVehicleOccupant( pTarget, 1 ) ) ~= "player" then
				return false
			end

			local iOwnerID = pTarget:GetOwnerID( )
			if iOwnerID and iOwnerID == localPlayer:GetUserID( ) then
				return true
			end

			return false
		end,

		fClientApply = function ( )
			toggleControl( "enter_exit", false )
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			toggleControl( pPlayer, "enter_exit", true )

			if not PreCheckServer( pPlayer, pTarget ) then return end
			
			if pPlayer:GetJobClass( ) == JOB_CLASS_TAXI_PRIVATE and pPlayer:GetOnShift( ) then
				pPlayer:ShowError( "Заверши смену чтобы передавать ключи" )
				return
			end

			local iOwnerID = pTarget:GetOwnerID( )
			if iOwnerID and iOwnerID == pPlayer:GetUserID( ) then
				local pTargetPlayer = getVehicleOccupant( pTarget, 1 )
				if not isElement(pTargetPlayer) then 
					pPlayer:ShowError("Игрок должен быть на пассажирском месте")
					return 
				end
				pTarget:SetTempOwnerPID( pTargetPlayer:GetUserID(), true )

				removePedFromVehicle( pPlayer )
				removePedFromVehicle( pTargetPlayer )
				warpPedIntoVehicle( pPlayer, pTarget, 1 )
				warpPedIntoVehicle( pTargetPlayer, pTarget, 0 )

				return true
			end

			return false
		end,
	},

	{
		sTargetType = "controlled_vehicle",
		sIcon = "VehicleLights",
		sText = "Сирена",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget
			local state = getElementData( self.target, "sirens" )
			if state then
				self.sText = "Отключить сирену"
				self.args = { false }
			else
				self.sText = "Включить сирену"
				self.args = { true }
			end
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end

			local pSirens = getVehicleSirens( pTarget )

			if pSirens and #pSirens >= 1 then
				return true
			end

			return false
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end

			setVehicleSirensOn( pTarget, pArgs[1] )
			setElementData( pTarget, "sirens", pArgs[1] )

			return false
		end,
	},



	{
		sTargetType = "vehicle",
		sIcon = "Documents",
		sText = "вытащить игрока",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget

			table.sort( self.t,
				function( a, b ) 
					return ( localPlayer.position - a[ 2 ] ):getLength() < ( localPlayer.position - b[ 2 ] ):getLength() 
				end 
			)

			self.sText = "Вытащить\n" .. self.t[ 1 ][ 1 ]:GetNickName()
			self.args = { self.t[ 1 ] }
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end

			local t = { }
			for i,v in pairs( getVehicleOccupants( pTarget ) ) do
				if not isElementLocal( v ) and getElementType( v ) == "player" then
					table.insert( t, { v, v.position } )
				end
			end

			if #t <= 0 then 
				return
			end

			self.t = t

			if pTarget:IsOwnedBy( localPlayer, true ) then
				return true
			elseif FACTION_RIGHTS.VEH_EJECT[ localPlayer:GetFaction( ) ] and localPlayer:IsOnFactionDuty( ) then
				return true
			end

			return false
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end
			local player = pArgs[ 1 ][ 1 ]
			if pTarget and player and getPedOccupiedVehicle( player ) == pTarget then
				if player:getData( "block_engine_incasator" ) then
					pPlayer:ShowError( "Инкассатор ожидает погрузки" )
					return
				end

				if player:getData( "jailed" ) == "move_prison" then 
					pPlayer:ShowError("Ты с ума сошел? Это же зек")
					return 
				end
				
				toggleControl( player, "accelerate", false )
				toggleControl( player, "brake_reverse", false )
				setControlState( player, "enter_exit", true )
				setTimer(
					function()
						if not isElement( player ) then return end
						setControlState( player, "enter_exit", false )
					end
				, 400, 1 )
				setTimer(
					function()
						if not isElement( player ) then return end
						toggleControl( player, "accelerate", true )
						toggleControl( player, "brake_reverse", true )
					end
				, 2000, 1 )
			end
			return true
		end,
	},

	{
		sTargetType = "vehicle",
		sIcon = "Documents",
		sText = "Вытащить человека",

		client_only = true,


		fPrepareClientData = function( self, pTarget )
			self.target = pTarget
			self.sText = "Вытащить человека"
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target

			if not isElement( pTarget ) then return end
			
			local current_quest = localPlayer:getData( "current_quest" ) or { }
			if not ( current_quest.id == "jeka_capture" and localPlayer.dimension == localPlayer:GetUniqueDimension( ) ) then return end
			
			local occupants = getVehicleOccupants( pTarget )
			if type( occupants ) ~= "table" then return end

			local t = { }
			for i,v in pairs( occupants ) do
				table.insert( t, { v, v.position } )
			end
			
			if #t <= 0 then 
				return
			end
			return true
		end,

		fClientApply = function( self, pTarget )
			
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end

			local t = { }
			for i,v in pairs( getVehicleOccupants( pTarget ) ) do
				table.insert( t, { v, v.position } )
			end

			if #t <= 0 then 
				return
			end

			self.t = t

			table.sort( t,
				function( a, b ) 
					return ( localPlayer.position - a[ 2 ] ):getLength() < ( localPlayer.position - b[ 2 ] ):getLength() 
				end 
			)

			local ped = t[ 1 ][ 1 ]
			setPedVehicleExit( ped )
			setTimer( removePedFromVehicle, 2000, 1, ped )
			triggerEvent( "onClientPlayerExtractVehicle", localPlayer, ped )

			return true
		end,
	},

	{
		sTargetType = "colshape",
		sIcon = "GarageGate",
		sText = "Открыть",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget
			local pData = pTarget:getData("radial_door")
			self.sText = pData[2]
			self.args = { pData[1] }
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end

			local pData = pTarget:getData("radial_door")

			if pData then
				return true
			end

			return false
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end

			triggerEvent("OnDoorRadialInteraction", pPlayer, pPlayer, pArgs[1])

			return false
		end,
	},

	{
		sTargetType = "vehicle",
		sIcon = "TowtruckCall",
		sText = "Вызов эвакуатора",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget
			self.sText = "Вызвать эвакуатор"
			self.args = { 0 }
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target

			if not FACTION_RIGHTS.EVACUATION[ localPlayer:GetFaction( ) ] then return end
			if isPedDead(localPlayer) then return end
			if localPlayer:getData("jailed") then return end
			if not pTarget or not isElement( pTarget ) then return end
			if pTarget:GetID() and pTarget:GetID() < 0 then return end
			if not localPlayer:IsOnFactionDuty() then return end
			if getPedOccupiedVehicle( localPlayer ) then return end
			if IsSpecialVehicle( pTarget.model ) then
				return false
			end

			return true
		end,
		fServerApply = function( pPlayer, pTarget )
			if not PreCheckServer( pPlayer, pTarget ) then return end
			if pTarget:IsInFaction() then return end
			if pTarget:isInWater() then return end
			if pTarget:getData( "tow_evacuated_real" ) or pTarget:getData( "tow_evac_added" ) or pTarget:getData( "work_lobby_id" ) then return end
			if pTarget:GetID() and pTarget:GetID() <= 0 then return end
			triggerEvent( "onServerDpsQueryEvacuateVehicle", root, pPlayer, pTarget )
			return true
		end,
	},

	{
		sTargetType = "near_players",
		sIcon = "PlayerInteract",
		sText = "Фиксация",

		fPrepareClientData = function( self, pTargets )
			self.target = pTarget

			local pos = localPlayer.position
			table.sort( pTargets,
				function( a, b ) 
					return ( pos - a.position ).length < ( pos - b.position ).length
				end 
			)

			self.child_items = { }
			for i, player in pairs( pTargets ) do
				if player ~= localPlayer and not player.vehicle and PreCheckClient( player ) then
					table.insert( self.child_items, 
						{
							target = player,
							sIcon = "PlayerInteract",
							sText = "Зафиксировать\n" .. player:GetNickName(),
							fClientCheck = self.fClientCheck,
							id = self.id,
						}
					)
				end
			end
		end,

		fClientCheck = function( self, pTarget )
			if not FACTION_RIGHTS.WANTED_KNOW[ localPlayer:GetFaction( ) ] then return end
			if not localPlayer:IsOnFactionDuty( ) then return end

			if type( pTarget ) == "table" then
				if #pTarget <= 0 then return end
			else
				if not PreCheckClient( pTarget ) then return end
			end

			if localPlayer.dimension ~= pTarget.dimension then return end

			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end

			triggerEvent( "onPlayerFixatePreWanted", pPlayer, pTarget, true )
			return true
		end,
	},

	{
		sTargetType = "near_vehicles",
		sIcon = "VehicleInteract",
		sText = "Фиксация",

		fPrepareClientData = function( self, pTargets )
			self.target = pTarget

			local pos = localPlayer.position
			table.sort( pTargets,
				function( a, b ) 
					return ( pos - a.position ).length < ( pos - b.position ).length
				end 
			)

			self.child_items = { }
			for i, vehicle in pairs( pTargets ) do
				local player = vehicle.controller
				if player and player ~= localPlayer and PreCheckClient( player ) then
					table.insert( self.child_items, 
						{
							target = player,
							sIcon = "VehicleInteract",
							sText = "Зафиксировать\n" .. player:GetNickName() .. "\n" .. ( vehicle:GetNumberPlateHR( true ) or "НЕОПОЗНАН" ),
							fClientCheck = self.fClientCheck,
							id = self.id,
						}
					)
				end
			end
		end,

		fClientCheck = function( self, pTarget )
			if not FACTION_RIGHTS.WANTED_KNOW[ localPlayer:GetFaction( ) ] then return end
			if not localPlayer:IsOnFactionDuty( ) then return end

			pTarget = pTarget or self.target
			if type( pTarget ) == "table" then
				if #pTarget <= 0 then return end
			else
				if not PreCheckClient( pTarget ) then return end
			end

			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not PreCheckServer( pPlayer, pTarget ) then return end
			
			triggerEvent( "onPlayerFixatePreWanted", pPlayer, pTarget, true )
			return true
		end,
	},

	{
		sTargetType = "player",
		sIcon = "wedding",
		sText = "Сделать\nпредложение",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget
			self.sText = "Сделать\nпредложение"
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end
			if isPedDead( pTarget ) or isPedDead( localPlayer ) then return end
			if localPlayer:getData( "jailed" ) then return end
			if pTarget:getData( "jailed" ) then return end
			if localPlayer:IsOnFactionDuty() then return end
			if not localPlayer:getData( "engage_item_applyed" ) or localPlayer:getData( "engaged_at_id" ) then return end
			if localPlayer.dimension ~= pTarget.dimension then return end
			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			if not WEDDING_SINGLE_GENDER then
				if pPlayer:GetGender() == pTarget:GetGender() then
					pPlayer:ShowInfo( "Нельзя сделать предложение персонажу того же пола" )
					return false
				end
			end
			if pPlayer:GetLevel() < 6 or pTarget:GetLevel() < 6 then
				pPlayer:ShowInfo( "Вы и ваш партнёр должны быть выше/или 6 уровня" )
				return false
			end
			triggerEvent( "OnWeddingIsPlayerReadyToStartEngage", pPlayer, pTarget )
			return true
		end,
	},

	{
		sTargetType = "player",
		sIcon = "kiss",
		sText = "Поцеловать",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget
			self.sText = "Поцеловать"
		end,

		fClientCheck = function( self, pTarget )
			local pTarget = pTarget or self.target
			if not PreCheckClient( pTarget ) then return end
			if isPedDead( pTarget ) or isPedDead( localPlayer ) then return end
			if not localPlayer:getData( "wedding_at_player" ) or localPlayer:getData( "wedding_at_player" ) ~= pTarget then return end
			if localPlayer.dimension ~= pTarget.dimension then return end
			return true
		end,

		fServerApply = function( pPlayer, pTarget, pArgs )
			triggerEvent( "OnWeddingPlayerWantToKiss", pPlayer, pTarget )
			return true
		end,
	},

	{
		sTargetType = "player",
		sIcon = "Invite",
		sText = "Пригласить\nна тусовку",

		fPrepareClientData = function( self, pTarget )
			self.target = pTarget

			local nickname = pTarget:GetNickName( ) or ""
			self.sText = "Пригласить\nна тусовку\n" .. nickname
		end,

		fClientCheck = function( self, pTarget )
			if not localPlayer:IsYoutuber( ) then return end
			if localPlayer.dimension ~= pTarget.dimension then return end
			return true
		end,

		fServerApply = function( pPlayer, pTarget )
			triggerEvent( "onPartyInvite", pPlayer, pTarget )

			return true
		end,
	},
}

for k,v in pairs(RADIAL_ACTIONS) do
	v.id = k
end

function PreCheckClient( pTarget )
	if not isElement(pTarget) then return end

	local distance = (localPlayer.position - pTarget.position).length
	if distance >= INTERACT_DISTANCE and pTarget ~= localPlayer.vehicle then return end

	return true
end

function PreCheckServer( pPlayer, pTarget )
	if not isElement(pPlayer) or not isElement(pTarget) then return end

	local distance = (pPlayer.position - pTarget.position).length
	if distance >= INTERACT_DISTANCE and pTarget ~= pPlayer.vehicle then return end

	return true
end

function GetNearestInteractiveElements( pPlayer )
	local plyPosition = pPlayer.position
	local pElements = {}
	local pVehicles = getElementsWithinRange( plyPosition, 10, "vehicle" )
	local pPlayers = getElementsWithinRange( plyPosition, 10, "player" )
	local pColShapes = getElementsWithinRange( plyPosition, 10, "colshape" )
	local pPeds = getElementsWithinRange( plyPosition, 10, "ped" )

	if isPedInVehicle(pPlayer) then
		local veh = getPedOccupiedVehicle( pPlayer )
		if getVehicleController(veh) == pPlayer then
			pElements.controlled_vehicle = veh
		else
			pElements.occupied_vehicle = veh
		end
	end

	local vehicle_element = math.huge
	local lowerDistance, player_element, ped_element = math.huge, nil, nil
	if not isPedInVehicle(pPlayer) then
		for k,v in pairs(pVehicles) do
			local distance = (plyPosition-v.position).length
			if distance < lowerDistance then
				lowerDistance = distance
				if distance <= INTERACT_DISTANCE then
					vehicle_element = v
				end
			end
		end

		for k,v in pairs(pPlayers) do
			local distance = (plyPosition-v.position).length
			if distance < lowerDistance then
				if distance <= INTERACT_DISTANCE and v ~= pPlayer then
					lowerDistance = distance
					player_element = v
				end
			end
		end

		for k,v in pairs(pPeds) do
			local distance = (plyPosition-v.position).length
			if distance < lowerDistance then
				if distance <= INTERACT_DISTANCE and v ~= pPlayer then
					lowerDistance = distance
					ped_element = v
				end
			end
		end
	end

	local lowerDistance, colshape_element = math.huge, nil
	for k,v in pairs(pColShapes) do
		if isElement( v ) then
			local distance = (plyPosition-v.position).length
			if distance < lowerDistance then
				if distance <= INTERACT_DISTANCE then
					lowerDistance = distance
					colshape_element = v
				end
			end
		end
	end

	pElements.vehicle = vehicle_element
	pElements.player = player_element
	pElements.colshape = colshape_element
	pElements.ped = ped_element

	pElements.near_vehicles = pVehicles
	pElements.near_players = pPlayers

	return pElements
end