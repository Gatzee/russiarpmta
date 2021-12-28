--[[
	Permanent data
		engaged_at_id  ID игрока на котором помолвлен
		wedding_at_id  ID игрока на котором женат/замужем
		engaged_timestamp время помолвки

	Private data
		engaged_at_player
		engaged_at_id
		wedded_at_player
		wedded_at_id
]]

Player.PreparePlayerInfo = function( self )
	self:ClearTempData( MARRY_STAGE_WEDDING )
	self:ClearTempData( MARRY_STAGE_ENGAGE )

	local wedding_at_id = self:GetPermanentData( "wedding_at_id" )

	if wedding_at_id then
		local wedded_at_player = GetPlayer( wedding_at_id )
		self:SetPrivateData( "wedding_at_id", wedding_at_id )
		self:CheckWeddedSkinDurable( )

		----TODO: проверить наличие даты
		--self:setData( "wedding_at_player", wedded_at_player )

		if isElement( wedded_at_player ) then
			self:SetPrivateData( "wedding_at_player", wedded_at_player )
			wedded_at_player:SetPrivateData( "wedding_at_player", self )
			wedded_at_player:SetPrivateData( "wedding_at_id", self:GetID() )
			----TODO: проверить наличие даты
			--wedded_at_player:setData( "wedding_at_player", self )
			MARRY_WEDDED_LIST[self] = wedded_at_player
			MARRY_WEDDED_LIST_NOTIFIED[self] = {}
			MARRY_WEDDED_LIST_NOTIFIED[self].state = false
			MARRY_WEDDED_LIST_NOTIFIED[wedded_at_player] = {}
			MARRY_WEDDED_LIST_NOTIFIED[wedded_at_player].state = false
			weddingCheckDistToExp( self, wedded_at_player )

			--Для GPS и carslots
			--Обычный дом
			onWeddingUpdateApartList_handler( wedded_at_player )

			--Вип дом
			onWeddingUpdateVipHouseData_handler( wedded_at_player )

		else
			--Для GPS и carslots
			-- Квартиры
			local wedded_apartments = exports.nrp_apartment:GetApartmentListByUserId( wedding_at_id )
			if wedded_apartments and #wedded_apartments > 0 then
				local data = {}
				for i, apart in ipairs( wedded_apartments ) do
					table.insert( data, { id = apart.id, number = apart.number } )
				end
				self:SetPrivateData( "wedding_at_apartments_data", data )
			end

			--Вип дома
			local wedded_viphouses = exports.nrp_vip_house:GetVipHouseListByUserId( wedding_at_id )
			if wedded_viphouses then
				local data = {}
				for i, viphouse in ipairs( wedded_viphouses ) do
					table.insert( data, { id = viphouse.id } )
				end
				self:SetPrivateData( "wedding_at_viphouse_data", data )
			end
		end
	end
end

--Может ли игрок начать свадьбу
Player.IsPlayerCanStartWedding = function( self, pid )
	local pid_owner = GetPlayer( pid )
	if pid_owner and isElement( pid_owner ) then
		if not self:IsOnSkin() then
			self:ShowInfo( "Вы должны быть в свадебном костюме" )
			pid_owner:ShowInfo( "Ваш партнёр не надел свадебный костюм" )
			return pid_owner, false
		end
		if not pid_owner:IsOnSkin() then
			self:ShowInfo( "Ваш партнёр не надел свадебный костюм" )
			pid_owner:ShowInfo( "Вы должны быть в свадебном костюме" )
			return pid_owner, false
		end
		if getDistanceBetweenPoints3D( self:getPosition(), pid_owner:getPosition() ) < 5 then
			return pid_owner, true
		else
			self:ShowInfo( "Партнёр слишком далеко" )
			return pid_owner, false
		end
	else
		self:ShowInfo( "Партнёр не найден" )
	end
end

Player.GetPossiblePartner = function( self )
	return self:getData( "engage_possible_partner" )
end

--Закончил ли игрок начальный диалог ( до окна подтверждения )
Player.IsPlayerPartnerFinishStartScene = function( self )
	local partner = self:GetPossiblePartner()
	iprint('possible partner for',self,partner)
	if not partner then return false; end
	if not partner:getData( "wedding_finish_start_scene" ) then return false; end
	return partner
end

--Принял ли игрок предложение ( окно подтверждения, диалог )
Player.IsPlayerPartnerAcceptEndWeddingOffer = function( self )
	local partner = self:GetPossiblePartner()
	if not partner or not isElement( partner ) then return false; end
	if not partner:getData( "wedding_accept_finish" ) then return partner, false; end
	return partner, true
end

--Может ли игрок начать помолвку
Player.IsPlayerCanStartEngage = function( self )
	local wedding_at_id = self:GetPermanentData( "wedding_at_id" )
	local engaged_at_id = self:GetPermanentData( "engaged_at_id" )
	iprint(wedding_at_id,engaged_at_id)
	if wedding_at_id or engaged_at_id then
		self:ShowInfo( "Вы не можете начать помолвку т.к. уже\n " .. ( self:GetGender() == 0 and "женаты" or "замужем" ) ..  " или начали помолвку." )
		return false
	end

	if self:getData( "jailed" ) then
		self:ShowInfo( "Вы не можете начать помолвку, т.к. в тюрьме." )
		return false
	end

	if self:isDead() then
		self:ShowInfo( "Вы не можете начать помолвку, т.к. на том свете." )
		return false
	end

	if self:IsOnFactionDuty() then
		self:ShowInfo( "Вы не можете начать помолвку, т.к. на смене фракции." )
		return false
	end

	if not self:HasAnyApartment() then
		self:ShowInfo( "Вы не можете начать помолвку, т.к. не имеете недвижимости" )
		return false
	end

	return true
end

Player.ClearTempData = function( self, stage )
	if stage == MARRY_STAGE_WEDDING then
		for i, v in pairs( { "wedding_finish_start_scene", "wedding_accept_finish" } ) do
			self:setData( v, nil, false )
		end
	elseif stage == MARRY_STAGE_ENGAGE then
		for i, v in pairs( { "engage_item_applyed" } ) do
			self:setData( v, nil, false )
		end
	end
end

Player.OnApplyStartEngage = function( self )
	self:triggerEvent( "onWeddingContextSetState", self, true )
	self:SetPrivateData( "engage_item_applyed", true )
	self:SetPermanentData( "engage_item_applyed", true )
	self:ApplySkins( true )
end

--Развод успешен
Player.OnDivorceSuccess = function( self )
	local wedding_at_id = self:GetPermanentData( "wedding_at_id" )
	if wedding_at_id then
		local partner = GetPlayer( wedding_at_id )

		local function clear_for( player )
			player:SetPrivateData( "wedding_at_apartments_data", nil )
			player:SetPrivateData( "wedding_at_viphouse_data", nil )

			triggerEvent( "UpdateParkingMarkerWeddingPartner", player )
			triggerEvent( "UpdateGarageMarkerWeddingPartner", player )

			player:SetPrivateData( "wedding_at_player", nil )
			player:SetPrivateData( "wedding_at_id", nil )
			player:SetPermanentData( "wedding_at_id", nil )
			
			MARRY_WEDDED_LIST[player] = nil
			MARRY_WEDDED_LIST_NOTIFIED[player] = nil

			--Очистка спавна в доме
			local last_visited_apart = player:GetPermanentData( "last_visited_apart" )
			if last_visited_apart and last_visited_apart.friendly then
				last_visited_apart.friendly = false
				player:SetPermanentData( "last_visited_apart", last_visited_apart )
			end
		end

		self:ShowInfo( "Вы подали на развод" )
		clear_for( self )

		if isElement( partner ) then --Игрок онлайн
			partner:ShowInfo( "Ваш напарник подал на развод" )
			clear_for( partner )
		else --Игрок оффлайн
			DB:exec( "UPDATE nrp_players SET wedding_at_id = NULL WHERE id = ? LIMIT 1", wedding_at_id )
		end
	end
end

Player.ApplySkins = function( self, state, force )
	local gender = self:GetGender()
	local current_target_model = gender == 0 and WEDDING_SKINS.male or WEDDING_SKINS.female
	if state then
		self:GiveSkin( current_target_model )
		self.model = current_target_model
	else
		local default_skin
		local skins = self:GetSkins( )
		for _, model in pairs( skins ) do
			if model == WEDDING_SKINS.male or model == WEDDING_SKINS.female then
				default_skin = model
				break
			end
		end

		if default_skin and self:HasSkin( default_skin ) then
			--Ещё доступен для игрока
			if not force then
				setTimer( function( player, skin )
					if not isElement( player ) then return end
					player:setModel( skin )
				end, 16*1000, 1, self, default_skin )
			else
				self:setModel( default_skin )
			end

		else
			--Мог продать или что то ещё
			local skins = self:GetSkins( )
			if next( skins ) then
				for _, model in pairs( skins ) do

					if not force then
						setTimer( function( player, skin )
							if not isElement( player ) then return end
							player:setModel( skin )
						end, 16*1000, 1, self, default_skin )
					else
						self:setModel( default_skin )
					end

					break
				end
			else
				if not force then
					setTimer( function( player )
						if not isElement( player ) then return end
						player:setModel( 0 )
					end, 16*1000, 1, self )
				else
					self:setModel( 0 )
				end
			end
		end

		self:RemoveSkin( current_target_model )
	end
end

Player.IsOnSkin = function( self )
	local gender = self:GetGender()
	local current_target_model = gender == 0 and WEDDING_SKINS.male or WEDDING_SKINS.female
	if self:getModel() == current_target_model then
		return true
	end
end

Player.CheckWeddedSkinDurable = function( self )
	local wedded_stamp = self:GetPermanentData( "wedding_last_tick" )
	if not wedded_stamp then
		wedded_stamp = getRealTime().timestamp
		self:SetPermanentData( "wedding_last_tick", wedded_stamp )
	end
	if WEDDING_SKINS_DURABLE + wedded_stamp < getRealTime().timestamp then
		local gender = self:GetGender()
		local current_target_model = gender == 0 and WEDDING_SKINS.male or WEDDING_SKINS.female
		if self:HasSkin( current_target_model ) then
			self:ShowInfo( "Истекло время использования костюма молодожён" )
			self:RemoveSkin( current_target_model )
			if self:getModel() == current_target_model then
				local skins = self:GetSkins( )
				if next( skins ) then
					for _, model in pairs( skins ) do
						self:setModel( model )
						break
					end
				end
			end
		end
	end
end

-----------------
--Запись данных--
-----------------

Player.WriteDataOnEngageSuccess = function( self, partner )
	local self_id, possible_partner_id = self:GetID(),partner:GetID()

	self:SetPrivateData( "engaged_at_player", partner )
	self:SetPrivateData( "engaged_at_id", possible_partner_id )
	self:SetPermanentData( "engaged_at_id", possible_partner_id )
	self:SetPrivateData( "engage_item_applyed", false )
end

Player.WriteDataOnWeddingSuccess = function( self, partner )
	local partner_id = partner:GetID()

	self:SetPrivateData( "engaged_at_player", nil )
	self:SetPrivateData( "engaged_at_id", nil )
	self:SetPermanentData( "engaged_at_id", nil )
	self:SetPrivateData( "wedding_at_player", partner )
	self:SetPrivateData( "wedding_at_id", partner_id )
	self:SetPermanentData( "wedding_at_id", partner_id )
	
	self:SetPermanentData( "wedding_count", ( self:GetPermanentData( "wedding_count" ) or 0 ) + 1 )

	self:SetPrivateData( "engage_item_applyed", nil )

	onWeddingUpdateApartList_handler( partner )

	onWeddingUpdateVipHouseData_handler( partner )

	triggerEvent( "onPlayerSomeDo", self, "wedding" ) -- achievements
end

Player.RestoreDataOnWeddingFault = function( self, partner )
	self:SetPrivateData( "engaged_at_player", nil )
	self:SetPrivateData( "engaged_at_id", nil )
	self:SetPermanentData( "engaged_at_id", nil )
	self:SetPermanentData( "engaged_timestamp", nil )
	self:SetPrivateData( "wedding_at_player", nil )
	self:SetPrivateData( "wedding_at_id", nil )
	self:SetPermanentData( "wedding_at_id", nil )
end