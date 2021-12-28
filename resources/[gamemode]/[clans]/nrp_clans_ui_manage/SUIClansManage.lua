loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SClans" )
Extend( "SDB" )

function ChangeClanTextData( clan_id, key, value )
    local prev_pos = 0
    for pos, codepoint in utf8.next, value .. " " do
        if pos - prev_pos > 3 then
            return
        end
        prev_pos = pos
    end
    SetClanData( clan_id, key, value )
end

function onClanMotdChangeRequest_handler( motd )
    local clan_id = client:GetClanID( )
    if not clan_id then return end
    ChangeClanTextData( clan_id, "motd", motd )
end
addEvent( "onClanMotdChangeRequest", true )
addEventHandler( "onClanMotdChangeRequest", root, onClanMotdChangeRequest_handler )

function onClanDescChangeRequest_handler( desc )
    local clan_id = client:GetClanID( )
    if not clan_id then return end
    ChangeClanTextData( clan_id, "desc", desc )
end
addEvent( "onClanDescChangeRequest", true )
addEventHandler( "onClanDescChangeRequest", root, onClanDescChangeRequest_handler )

function onPlayerWantSetClanClosed_handler( state )
    local player = client or source
    local clan_id = player:GetClanID( )
    if not clan_id then return end
   
    if player:GetClanRole( ) ~= CLAN_ROLE_LEADER then return end

    CallClanFunction( clan_id, "SetClosed", state )
end
addEvent( "onPlayerWantSetClanClosed", true )
addEventHandler( "onPlayerWantSetClanClosed", root, onPlayerWantSetClanClosed_handler )

-- function onPlayerDeleteClanRequest_handler( )
--     if not client then return end
--     -- Трое суток на восстановление
--     local clan_id = client:GetClanID()
--     SetClanData( clan_id, "delete_date", getRealTime().timestamp + 2 * 24 * 60 * 60 )
--     client:ShowNotification( "Клан будет распущен через 3 суток" )
--     triggerClientEvent( client, "ShowBandUI", client )
-- end
-- addEvent( "onPlayerDeleteClanRequest", true )
-- addEventHandler( "onPlayerDeleteClanRequest", root, onPlayerDeleteClanRequest_handler )

-- function onPlayerCancelDeleteClanRequest_handler( )
--     if not client then return end
--     -- Трое суток на восстановление
--     local clan_id = client:GetClanID()
--     SetClanData( clan_id, "delete_date", false )
--     client:ShowNotification( "Удаление клана отменено" )
--     triggerClientEvent( client, "ShowBandUI", client )
-- end
-- addEvent( "onPlayerCancelDeleteClanRequest", true )
-- addEventHandler( "onPlayerCancelDeleteClanRequest", root, onPlayerCancelDeleteClanRequest_handler )

function onPlayerWantChangeClanRole_handler( user_id, new_role )
    local player = client or source
    local clan_id = player:GetClanID( )

    if not clan_id then
        return
    end
   
    local player_role = player:GetClanRole( )
    if player_role < CLAN_ROLE_MODERATOR then return end

    if player_role <= new_role and player_role ~= CLAN_ROLE_LEADER then
        triggerClientEvent( player, "onClientUpdateClanUIMembersData", player, false, "Недостаточно прав!" )
        return
    end

    local other_player = GetPlayer( user_id )
    if other_player then
        if other_player:GetClanID( ) ~= clan_id then
            triggerClientEvent( player, "onClientUpdateClanUIMembersData", player, false, "Данный игрок не состоит в вашем клане!" )
            return
        end

        if other_player:GetClanRole( ) >= player_role then
            triggerClientEvent( player, "onClientUpdateClanUIMembersData", player, false, "Роль этого игрока выше вашего!" )
            return
        end

        local result, error = CallClanFunction( clan_id, "RequestChangePlayerRole", user_id, new_role )
        if not result then
            triggerClientEvent( player, "onClientUpdateClanUIMembersData", player, false, error or "Неизвестная ошибка" )
            return
        end

        other_player:SetClanRole( new_role )
        other_player:PhoneNotification( {
            title = "Клан",
            msg = "Ваша роль в клане была изменена",
        } )
        triggerClientEvent( other_player, "HideAllClanUI", other_player )

        if new_role == CLAN_ROLE_LEADER then
            CallClanFunction( clan_id, "RequestChangePlayerRole", player:GetUserID( ), CLAN_ROLE_MODERATOR )
            player:SetClanRole( CLAN_ROLE_MODERATOR )
            player:ShowSuccess( "Вы успешно передали права лидера игроку " .. other_player:GetNickName( ) )
            triggerClientEvent( player, "onClientUpdateClanUIMembersData", player, true )
            triggerClientEvent( player, "onClientUpdateClanUI", player, {
                clan_role = CLAN_ROLE_MODERATOR,
            } )
        else
            player:ShowSuccess( "Вы успешно изменили роль игрока " .. other_player:GetNickName( ) )
            triggerClientEvent( player, "onClientUpdateClanUIMembersData", player, true )
        end
		-- triggerClientEvent( player, "onClientUpdateClanUI", player, {
		-- 	members = memebers,
		-- } )
    else
		DB:queryAsync(
			function( query )
				local data = query:poll( -1 )
                if not data or not data[ 1 ] then return end
                if not isElement( player ) then return end

                data = data[ 1 ]

                if tonumber( data.clan_id ) ~= clan_id then
                    triggerClientEvent( player, "onClientUpdateClanUIMembersData", player, false, "Данный игрок не состоит в вашем клане!" )
                    return
                end

                if data.clan_role >= player_role then
                    triggerClientEvent( player, "onClientUpdateClanUIMembersData", player, false, "Роль этого игрока выше вашего!" )
                    return
                end

                local result, error = CallClanFunction( clan_id, "RequestChangePlayerRole", user_id, new_role )
                if not result then
                    triggerClientEvent( player, "onClientUpdateClanUIMembersData", player, false, error or "Неизвестная ошибка" )
                    return
                end

                local other_player = GetPlayer( user_id )
                if other_player then
                    other_player:SetClanRole( new_role )
                    other_player:PhoneNotification( {
                        title = "Клан",
                        msg = "Ваша роль в клане была изменена",
                    } )
                    triggerClientEvent( other_player, "HideAllClanUI", other_player )
                else
                    DB:exec( "UPDATE nrp_players SET clan_role = ? WHERE id = ?", new_role, user_id )
                end
                if new_role == CLAN_ROLE_LEADER then
                    CallClanFunction( clan_id, "RequestChangePlayerRole", player:GetUserID( ), CLAN_ROLE_MODERATOR )
                    player:SetClanRole( CLAN_ROLE_MODERATOR )
                    player:ShowSuccess( "Вы успешно передали права лидера игроку " .. data.nickname )
                    triggerClientEvent( player, "onClientUpdateClanUIMembersData", player, true )
                    triggerClientEvent( player, "onClientUpdateClanUI", player, {
                        clan_role = CLAN_ROLE_MODERATOR,
                    } )
                else
                    player:ShowSuccess( "Вы успешно изменили роль игрока " .. data.nickname )
                    triggerClientEvent( player, "onClientUpdateClanUIMembersData", player, true )
                end
			end, { },
			"SELECT nickname, clan_id, clan_role FROM nrp_players WHERE id = ? LIMIT 1", user_id
        )
    end
end
addEvent( "onPlayerWantChangeClanRole", true )
addEventHandler( "onPlayerWantChangeClanRole", root, onPlayerWantChangeClanRole_handler )

function onClanKickRequest_handler( target_user_id )
    local player = client or source
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    local player_role = player:GetClanRole( )
    if player_role < CLAN_ROLE_MODERATOR then
        player:ShowError( "Недостаточно прав" )
        return
    end

    local target = GetPlayer( target_user_id )
    if target then
        if target:GetClanRole( ) >= player_role then
            player:ShowError( "Роль этого игрока выше вашего" )
            return
        end
        CallClanFunction( clan_id, "LeavePlayer", target, true )

        target:PhoneNotification( {
            title = "Клан",
            msg = "Ты был изгнан из клана!",
        } )
        player:ShowSuccess( "Вы успешно выгнали игрока " .. target:GetNickName( ) )
		triggerClientEvent( player, "onClientUpdateClanUI", player, {
			members = CallClanFunction( clan_id, "GetMembers" ),
		} )
    else
        CallClanFunction( clan_id, "LeavePlayerOffline", target_user_id, player )
    end
end
addEvent( "onClanKickRequest", true )
addEventHandler( "onClanKickRequest", root, onClanKickRequest_handler )

local INVITATION_COOLDOWN = { }
function SendClanInvitation( target )
    local player = client or source

    if ( INVITATION_COOLDOWN[ target ] or 0 ) >= getRealTimestamp( ) then
        player:ShowError( "Нельзя отправлять приглашения так часто!" )
        return
    end
    
    if not isElement( target ) then
        player:ShowError( "Игрок должен быть онлайн" )
        return
    end

    if target == player then
        player:ShowError( "Нельзя пригласить самого себя!" )
        return
    end

    if target:IsInFaction( ) then
        player:ShowError( "Игрок состоит во фракции" )
        return
    end

    if target:GetClanID( ) then
        player:ShowError( "Игрок уже состоит в клане" )
        return
    end

    if target:GetLevel( ) < 6 then
        player:ShowError( "Игрок должен быть 6 уровня или выше" )
        return
    end

    local clan_id = player:GetClanID( )
    if not clan_id then return end

    local data = {
        name = GetClanData( clan_id, "name" ),
        clan_id = clan_id,
    }
    triggerClientEvent( target, "ShowInviteWindow", player, data )

    INVITATION_COOLDOWN[ target ] = getRealTimestamp( ) + 60 * 3

    player:ShowSuccess( "Приглашение выслано!" )
end
addEvent( "onClanInvitationRequest", true )
addEventHandler( "onClanInvitationRequest", root, SendClanInvitation )

function onPlayerQuit_handler( )
    INVITATION_COOLDOWN[ source ] = nil
end
addEventHandler( "onPlayerQuit", root, onPlayerQuit_handler )