local number_to_factions = {
    [ "02" ] = {
		[ F_POLICE_PPS_NSK ] = true;
		[ F_POLICE_PPS_GORKI] = true;
		[ F_POLICE_PPS_MSK] = true;
	};
    [ "03" ] = {
		[ F_MEDIC ] = true;
		[ F_MEDIC_MSK ] = true;
	};
    [ "112" ] = {
		[ F_POLICE_DPS_NSK ] = true;
		[ F_POLICE_DPS_GORKI ] = true;
        [ F_POLICE_DPS_MSK ] = true;
	};
}

local number_color = {
    [ "02" ] = { 0, 0, 255 },
    [ "03" ] = { 255, 255, 255 },
    [ "112" ] = { 0, 0, 255 },
}

LAST_REQUEST = { }
PLAYER_COL = {}

function onPhoneSendStuffRequest_handler( number, reason )
    local factions = number_to_factions[ number ]

    if not factions then
        client:ShowError( "Ошибка набора номера!" )
        return
    end
    local client_faction = client:GetFaction()
    if factions[ client_faction ] then
        client:ShowError( "Ты не можешь вызвать свою же службу!" )
        return
    end
    if LAST_REQUEST[ client ] and getTickCount() - LAST_REQUEST[ client ] <= 5 * 60 * 1000 then
        client:ShowError( "Нельзя вызывать службы так часто!" )
        return
    end

    triggerEvent( "onPlayerSomeDo", client, "call_112" ) -- achievements
    client:ShowSuccess( "Служба получила ваше сообщение! Ожидайте на месте" )
    
    local nickname = client:GetNickName( )
    
    Async:foreach( getElementsByType( "player" ), function( player )
        if factions[ player:GetFaction() ] then
            player:outputChat( "[Фракция] Новый вызов от " .. nickname ..", гражданин отмечен на карте", 255, 255, 0 )
            player:outputChat( "Указанная причина вызова: " .. reason, 255, 255, 0 )
            triggerClientEvent( player, "onFactionShowLocation", client, number_color[ number ] )
        end
    end )
    

    LAST_REQUEST[ client ] = getTickCount()
    PLAYER_COL[ client ] = createColSphere( client.position, 15 )
    addEventHandler( "onColShapeHit", PLAYER_COL[ client ], function( hitElement, matchingDimension )
        if getElementType( hitElement ) == "player" and  hitElement ~= client and factions[ hitElement:GetFaction() ] and hitElement:IsOnFactionDuty( ) then
            Async:foreach( getElementsByType( "player" ), function( player )
                if factions[ hitElement:GetFaction() ] then
                    triggerClientEvent( player, "hideFactionBlips", hitElement )
                end
            end )
            source:destroy()
            triggerEvent( "onServerCompleteShiftPlan", hitElement, hitElement, "shift_call", _, 0 )
        end
    end )

    addEventHandler( "onColShapeLeave", PLAYER_COL[ client ], function( hitElement, matchingDimension )
        if getElementType( hitElement ) == "player" and  hitElement == client then
            Async:foreach( getElementsByType( "player" ), function( player )
                if factions[ hitElement:GetFaction() ] then
                    triggerClientEvent( player, "hideFactionBlips", hitElement )
                end
            end )
            client:ShowSuccess( "Вы покинули область ожидания! Вызов отменен" )
            source:destroy()
        end
    end )

end
addEvent( "onPhoneSendStuffRequest", true )
addEventHandler( "onPhoneSendStuffRequest", root, onPhoneSendStuffRequest_handler )

function onPlayerQuit_handler()
    LAST_REQUEST[ source ] = nil
end
addEventHandler( "onPlayerQuit", root, onPlayerQuit_handler )

function onPlayerFactionChange_handler( player, ignore_team_reset )
    local player = isElement( player ) and player or source
    triggerClientEvent( player, "hideFactionBlips", player )
end
addEventHandler( "onPlayerFactionChange", root, onPlayerFactionChange_handler )