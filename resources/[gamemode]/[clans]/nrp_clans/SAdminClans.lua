local latent_handles = { }

function OnPlayerRequestClansData( player )
	local player = client or player
	local pToSend = {}

	local clans_to_inspect = { }
	for k,v in pairs( CLANS_LIST ) do
		if not v:GetPermanentData( "deleted" ) then
			clans_to_inspect[ k ] = v
		end
	end

	for k, v in pairs( clans_to_inspect ) do
		v:GetMembers( function( members )
			local tab = 
			{
				id = v.id,
				name = v.name,
				members = members,
				exp = v.score,
			}

			table.insert( pToSend, tab )

			clans_to_inspect[ k ] = nil

			if isElement( player ) and not next( clans_to_inspect ) then
				if latent_handles[ player ] then
					cancelLatentEvent( player, latent_handles[ player ] )
				elseif latent_handles[ player ] == nil then
					addEventHandler( "onPlayerQuit", player, function( )
						latent_handles[ player ] = nil
					end )
				end
				triggerLatentClientEvent( player, "AP:ReceiveClansData", 100000, resourceRoot, pToSend )
				local handles = getLatentEventHandles ( player )
				latent_handles[ player ] = handles[ #handles ] or false
			end
		end  )
	end
end
addEvent( "AP:OnPlayerRequestClansData", true )
addEventHandler( "AP:OnPlayerRequestClansData", root, OnPlayerRequestClansData )

function OnPlayerApplyClanAction( action, clan_id, data )
	if clan_id == "purple" or clan_id == "green" then
		client:outputChat( "Взаимодействовать можно только с кланами!", 200, 50, 50 )
		return false
	end

	if action == "delete" then
		if client:GetAccessLevel( ) <= ACCESS_LEVEL_HEAD_ADMIN then
			client:outputChat( "Нет доступа!", 200, 50, 50 )
			return false
		end

		local pClan = _CLANS_REVERSE[clan_id]
		if pClan then
			pClan:SetPermanentData( "deleted", 0 )
			client:outputChat( "Клан "..pClan.name.." успешно удалён", 50, 200, 50 )

			LogSlackCommand( "%s удалил клан %s", client, pClan.name )

			OnPlayerRequestClansData( client )
		end
	elseif action == "block" then
		if client:GetAccessLevel( ) <= ACCESS_LEVEL_MODERATOR then
			client:outputChat( "Нет доступа!", 200, 50, 50 )
			return false
		end

		local pClan = _CLANS_REVERSE[clan_id]
		if pClan then
			local is_blocked = pClan:GetPermanentData( "blocked" )
			pClan:SetPermanentData( "blocked", not is_blocked and getRealTime( ).timestamp + data.time*60 or false )
			pClan:SetPermanentData( "blocked_reason", not is_blocked and data.reason or false )
			client:outputChat( "Клан "..pClan.name.." успешно "..( is_blocked and "разблокирован" or "заблокирован" ), 50, 200, 50 )

			LogSlackCommand( "%s "..( is_blocked and "разблокировал" or "заблокировал" ).." клан %s по причине %s", client, pClan.name, data.reason )

			OnPlayerRequestClansData( client )
		end
	elseif action == "setexp" then
		if client:GetAccessLevel( ) <= ACCESS_LEVEL_HEAD_ADMIN then
			client:outputChat( "Нет доступа!", 200, 50, 50 )
			return false
		end

		local pClan = _CLANS_REVERSE[clan_id]
		if pClan then
			pClan:SetClanEXP( data.value )
			client:outputChat( "Рейтинг клана "..pClan.name.." успешно изменён", 50, 200, 50 )
			
			LogSlackCommand( "%s изменил рейтинг клана %s на %s", client, pClan.name, data.value )

			OnPlayerRequestClansData( client )
		end
	end
end
addEvent( "AP:OnPlayerApplyClanAction", true )
addEventHandler( "AP:OnPlayerApplyClanAction", root, OnPlayerApplyClanAction )