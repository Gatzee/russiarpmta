function Player_Setmayor( player, command, faction, target_id )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end
    local faction = tonumber( faction )
	if not faction then return ERRCODE_WRONG_SYNTAX end
	if FACTIONS_BY_CITYHALL[ faction ] ~= faction then return ERRCODE_WRONG_SYNTAX end

    if target_player:IsInClan() then 
        player:outputChat( "Игрок находится в клане", 255, 0, 0 )
        return 
    end

    local faction_name = FACTIONS_NAMES[ faction ] or "Нет фракции"

    if faction > 0 and FACTIONS_NAMES[ faction ] then
        target_player:EndUrgentMilitary()
	end
	
	exports.nrp_factions_gov_voting:SetNewCityMayor( faction, tonumber( target_id ), "Администратор назначил нового мэра" )

    outputChatBox( target_player:GetNickName() .. " был назначен мэром " .. faction_name, player, 0, 255, 0 )
    LogSlackCommand( "%s был назначен %s мэром %s", target_player, player, faction_name )
end
addCommandHandler( "setmayor", Player_Setmayor )

function Player_Removemayor( player, command, faction, ... )
    local faction = tonumber( faction )
	if not faction then return ERRCODE_WRONG_SYNTAX end
	if FACTIONS_BY_CITYHALL[ faction ] ~= faction then return ERRCODE_WRONG_SYNTAX end

	local reason_str = table.concat( { ... }, ' ' ) or "без указания причины"
    local faction_name = FACTIONS_NAMES[ faction ] or "Нет фракции"

	exports.nrp_factions_gov_voting:RemoveCurrentCityMayor( faction, "Администратором (".. reason_str ..")" )

    outputChatBox( "Мэр ".. faction_name .." особожден от должности по причине: ".. reason_str, player, 0, 255, 0 )
    LogSlackCommand( "%s осободил от должности мэра %s", player, faction_name )
end
addCommandHandler( "removemayor", Player_Removemayor )

function Player_Startvoting( player, command, faction )
    local faction = tonumber( faction )
	if not faction then return ERRCODE_WRONG_SYNTAX end
	if FACTIONS_BY_CITYHALL[ faction ] ~= faction then return ERRCODE_WRONG_SYNTAX end

    local faction_name = FACTIONS_NAMES[ faction ] or "Нет фракции"

	triggerEvent( "StartGovernmentVoting", root, faction )

    outputChatBox( "Назначены выборы мэра ".. faction_name, player, 0, 255, 0 )
    LogSlackCommand( "%s начал выборы мэра %s", player, faction_name )
end
addCommandHandler( "startvoting", Player_Startvoting )

function Player_Reseteconomy( player, command, faction )
    local faction = tonumber( faction )
	if not faction then return ERRCODE_WRONG_SYNTAX end
	if FACTIONS_BY_CITYHALL[ faction ] ~= faction then return ERRCODE_WRONG_SYNTAX end

    local faction_name = FACTIONS_NAMES[ faction ] or "Нет фракции"

	exports.nrp_factions_gov_ui_control:ResetGovStateToDefault( faction )

    outputChatBox( "Экономика ".. faction_name .." сброшена на дефолтные значения", player, 0, 255, 0 )
    LogSlackCommand( "%s сбросил экономику %s на дефолтные значения", player, faction_name )
end
addCommandHandler( "reseteconomy", Player_Reseteconomy )