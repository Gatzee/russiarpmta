loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SVehicle" )

local iMaxDistance = 10
local pCurrentlyTasedPlayers = { }

function OnPlayerTaserFire( target )
	if target and isElement( target ) then
		if target.health < 1 then return end 
		local distance = ( client.position - target.position ).length
		if distance <= iMaxDistance then
			if target:IsInFaction( ) then
				local target_faction = target:GetFaction( )
				if FACTIONS_BY_CITYHALL[ target_faction ] == target_faction and target:IsFactionOwner( ) then
					if client:IsInFaction( ) and client:GetFactionLevel( ) < 3 then
						return
					end
				end
			end

			if exports.nrp_fsin_jail:IsPlayerInCamera( target ) then return end

			local players = { }
			for i, v in pairs( getElementsByType( "player" ) ) do
				if ( v.position - client.position ).length <= 100 then
					table.insert( players, v )
				end
			end

			triggerClientEvent( players, "OnClientPlayerTaserFired", client, target )
			triggerEvent( "onPlayerTaserDamage", target, client )
			pCurrentlyTasedPlayers[ target ] = true

			if isElementAttached( target ) then
				detachElements( target )
				return
			end

			setTimer( function( pPlayer )
				pCurrentlyTasedPlayers[ pPlayer ] = nil
			end, 10000, 1, target )
		end
	end
end
addEvent( "OnPlayerTaserFire", true )
addEventHandler( "OnPlayerTaserFire", root, OnPlayerTaserFire )

function OnPlayerQuit( )
	if pCurrentlyTasedPlayers[ source ] then
		source:Jail( )
	end
end
addEvent( "onPlayerPreLogout", true )
addEventHandler( "onPlayerPreLogout", root, OnPlayerQuit )