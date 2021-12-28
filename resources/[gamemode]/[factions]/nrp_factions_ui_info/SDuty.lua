loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SPlayer")

function PlayerWantStartDuty( city )
	if not client then
		return
	end

	if not client:IsInFaction( ) then
		return
	end

	if client:IsOnFactionDuty( ) then
		return
	end

	if client:IsOnFactionDayOff( ) then
		client:ShowInfo( "Ты находишься в отгуле" )
		return
	end
	
	if client:getData( "current_quest" ) then
		client:ShowInfo( "Заверши текущую задачу!" )
		return false
	end

	city = city or 1
	client:StartFactionDuty( city )

	client:ShowSuccess( "Вы успешно начали смену\nв г. “".. HOMETOWNS[ city ] .."“" )
	triggerClientEvent( client, "ShowUIInfo", resourceRoot, city, true )
end
addEvent( "PlayerWantStartDuty", true )
addEventHandler( "PlayerWantStartDuty", resourceRoot, PlayerWantStartDuty )

function PlayerWantEndDuty( )
	if not client then
		return
	end

	if not client:IsInFaction( ) then
		return
	end

	if not client:IsOnFactionDuty( ) then
		return
	end

	client:EndFactionDuty( )
	client:ShowSuccess( "Вы успешно завершили смену" )

	triggerEvent( "onPlayerFactionEndDuty", client )
end
addEvent( "PlayerWantEndDuty", true )
addEventHandler( "PlayerWantEndDuty", root, PlayerWantEndDuty )

function PlayerWantLeaveFaction( )
	if not client then
		return
	end

	if not client:IsInFaction( ) then
		return
	end

	local player_faction = client:GetFaction( )
	local iRank = client:GetFactionLevel( )
	local counter = exports.nrp_factions_ui_control_menu:GetCountFactionMemberList( client )
	local rank = FACTIONS_LEVEL_NAMES[ player_faction ][ iRank ] or "?"

	if FACTION_RIGHTS.ECONOMY[ player_faction ] and iRank == #FACTIONS_LEVEL_NAMES[ player_faction ] then
		exports.nrp_factions_gov_voting:RemoveCurrentCityMayor( player_faction, "По собственному желанию" )
		triggerEvent( "StartGovernmentVoting", root, player_faction, true )
	end

	client:SetFaction( 0 )
	client:SetPermanentData( "faction_timeout", getRealTimestamp( ) + FACTION_JOIN_TIMEOUT.himself )
	client:AddFactionRecord( player_faction, "Уволен", "по собственному желанию", rank )

	WriteLog( "factions/fire", "%s вышел из фракции по собственному желанию", client )

	client:ShowSuccess( "Ты успешно покинул фракцию" )

	-- analytics
	triggerEvent( "onPlayerFactionChangeAnalytics", client, false, player_faction, counter, iRank, true )
end
addEvent( "PlayerWantLeaveFaction", true )
addEventHandler( "PlayerWantLeaveFaction", resourceRoot, PlayerWantLeaveFaction )