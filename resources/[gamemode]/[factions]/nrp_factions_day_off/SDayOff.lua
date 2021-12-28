loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

local PLAYERS_POOL = { }

Player.SyncData = function ( self )
	local counter = self:GetPermanentData( "duty_counter_for_day_off" ) or 0
	local days_available = self:GetPermanentData( "factions_day_off_available" ) or 0
	local factions_day_off = self:GetPermanentData( "factions_day_off" ) or 0

	self:SetPrivateData( "duty_counter_for_day_off", counter )
	self:SetPrivateData( "factions_day_off_available", days_available )
	self:SetPrivateData( "factions_day_off", factions_day_off )
end

Player.ClearData = function ( self )
	self:SetPermanentData( "duty_counter_for_day_off", nil )
	self:SetPermanentData( "factions_day_off_available", nil )
	self:SetPermanentData( "factions_day_off", nil )

	self:SyncData( )
end

Player.HasSomeData = function ( self )
	local counter = self:GetPermanentData( "duty_counter_for_day_off" ) or 0
	local days_available = self:GetPermanentData( "factions_day_off_available" ) or 0

	return counter > 0 or days_available > 0
end

Player.StopDayOff = function ( self )
	local start_time = self:GetPermanentData( "factions_day_off_start_time" ) or 0
	local time_to = self:GetPermanentData( "factions_day_off" ) or 0
	local current_time = getRealTimestamp( )
	local passed_days = math.floor( ( current_time - start_time ) / 3600 / 24 )
	local got_days = math.floor( ( time_to - start_time ) / 3600 / 24 )

	-- analytics
	SendElasticGameEvent( self:GetClientID( ), "faction_day_off_deny", {
		faction_id = self:GetFaction( ),
		days_off_passed_count = passed_days,
		days_off_count = got_days,
	} )

	self:SetPermanentData( "factions_day_off", nil )

	triggerClientEvent( self, "onClientShowDayOffWindow", self, nil, true )
end

function onPlayerFactionDutyEnd_handler( )
	removeEventHandler( "onPlayerPreLogout", source, onPlayerFactionDutyEnd_handler )
	removeEventHandler( "OnPlayerFactionDutyEnd", source, onPlayerFactionDutyEnd_handler )

	local last_start = PLAYERS_POOL[ source ] or 0

	if getRealTimestamp( ) - last_start >= 1800 then
		local counter = ( source:GetPermanentData( "duty_counter_for_day_off" ) or 0 ) + 1

		if counter >= FACTION_DUTY_VALUE_FOR_DAY_OFF then
			counter = 0
			source:SetPermanentData( "factions_day_off_available", FACTION_DAY_OFF_VALUE )
		end

		source:SetPermanentData( "duty_counter_for_day_off", counter )
		source:SyncData( )
	end

	PLAYERS_POOL[ source ] = nil
end

addEventHandler( "OnPlayerFactionDutyStart", root, function ( )
	addEventHandler( "onPlayerPreLogout", source, onPlayerFactionDutyEnd_handler )
	addEventHandler( "OnPlayerFactionDutyEnd", source, onPlayerFactionDutyEnd_handler )

	PLAYERS_POOL[ source ] = getRealTimestamp( )
end )

addEventHandler( "onPlayerReadyToPlay", root, function ( )
	local faction_id = source:GetFaction( )

	if faction_id > 0 then
		local time_to = source:GetPermanentData( "factions_day_off" ) or 0
		local is_day_off = time_to > getRealTimestamp( )
		if is_day_off then
			triggerClientEvent( source, "onClientShowDayOffWindow", source, time_to )
		elseif not is_day_off and source:GetPermanentData( "factions_day_off" ) then
			source:StopDayOff( )
		end

		source:SyncData( )

	elseif faction_id == 0 and source:HasSomeData( ) then
		source:ClearData( )
	end
end )

addEventHandler( "onPlayerFactionChange", root, function ( _, faction_id )
	if faction_id == 0 then
		source:ClearData( )
	end
end )

addEvent( "PlayerWantGetDayOffFaction", true )
addEventHandler( "PlayerWantGetDayOffFaction", root, function ( days )
	if not client then
		return
	end

	if client:IsOnFactionDayOff( ) then
		client:ShowError( "Ты уже находишься в отгуле" )
		return
	end

	days = tonumber( days )
	if not days or days ~= days or math.ceil( days ) ~= days then
		return
	end

	if not client:IsInFaction( ) then
		return
	end

	local days_available = client:GetPermanentData( "factions_day_off_available" ) or 0
	if days <= 0 or days > days_available then
		return
	end

	if client:IsOnFactionDuty( ) then
		client:EndFactionDuty( )
	end

	local current_time = getRealTimestamp( )
	local time_to = current_time + days * 24 * 3600

	client:SetPermanentData( "factions_day_off_start_time", current_time )
	client:SetPermanentData( "factions_day_off", time_to )
	client:SetPermanentData( "factions_day_off_available", days_available - days )
	client:SyncData( )

	triggerClientEvent( client, "onClientShowDayOffWindow", client, time_to )

	-- analytics
	SendElasticGameEvent( client:GetClientID( ), "faction_day_off", {
		faction_id = client:GetFaction( ),
		days_off_count = days,
	} )
end )

addEvent( "PlayerWantStopDayOffFaction", true )
addEventHandler( "PlayerWantStopDayOffFaction", resourceRoot, function ( )
	if not client or not client:GetPermanentData( "factions_day_off" ) then
		return
	end

	client:StopDayOff( )
	client:SyncData( )
end )