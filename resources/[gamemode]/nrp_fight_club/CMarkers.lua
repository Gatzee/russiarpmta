TOURNAMENT_DATA = {}
FIGHT_CLUB_BUY_TICKER_MARKERS =
{
	{
		-- В ЗАЛЕ
		x = -2117.4242, 
		y = 243.8531, 
		z = 665.0920,
		dimension = 1,
		interior = 1,
		func = function( pPlayer )
			ShowUI_Tickets( true )
		end
	},
}

function UpdateTournamentData( data )
	TOURNAMENT_DATA = data
end
addEvent( "FC:UpdateTournamentData", true )
addEventHandler( "FC:UpdateTournamentData", resourceRoot, UpdateTournamentData )

function SetCollidableWithPlayers( state )
	for k, v in pairs( getElementsByType( "player" ) ) do
		setElementCollidableWith( localPlayer, v, state )
	end
end

addEventHandler( "onClientResourceStart", resourceRoot, function()

	CreatePedMarkers()

	for i, config in pairs( FIGHT_CLUB_ENTRANCES ) do
		local pDoor = createObject( 17289, -2068.5, 1101.588 - 860, 666.504 )
		pDoor.interior = 1
		pDoor.dimension = i
		setElementRotation( pDoor, 0, 0, 90 )
		setElementAlpha( pDoor, 0 )

		config.accepted_elements = { player = true }
		config.keypress = "lalt"
		config.radius = 2
		config.marker_text = "Бойцовский клуб"
		config.text = "ALT Взаимодействие"

		local entrance = TeleportPoint( config )
		entrance.element:setData( "material", true, false )
    	entrance:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 255, 0, 255, 1.55 } )
		entrance.element:setData( "ignore_dist", true )
		entrance.marker:setColor( 0, 255, 0, 50 )
		entrance.PreJoin = function( self , player )
			if player:GetBlockInteriorInteraction() then
				player:ShowInfo( "Вы не можете войти во время задания" )
				return false
			end
			return true
		end
		entrance.PostJoin = function( self, pPlayer )
			SetCollidableWithPlayers( false )
			triggerServerEvent( "onPlayerWannaEnterFightClub", resourceRoot, i )
		end
		entrance.PostLeave = function( self, pPlayer )
			SetCollidableWithPlayers( true )
		end
		entrance.elements = {}
		entrance.elements.blip = Blip( config.x, config.y, config.z, 54, 2, 255, 255, 255, 255, 0, 200 )
		
		local exit_config = 
		{
			marker_text = "Выход",
			text = "ALT Взаимодействие",
			x = -2121.2058,
			y = 1104.7938 - 860,
			z = 665.1,
			dimension = i,
			interior = 1,
			radius = 1.5,
		}

		local exit = TeleportPoint( exit_config )
		exit.element:setData( "material", true, false )
    	exit:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 255, 0, 255, 1.15 } )
		exit.element:setData( "ignore_dist", true )
		exit.marker:setColor( 0, 255, 0, 50 )
		exit.PostJoin = function( self, pPlayer )
			SetCollidableWithPlayers( false )
			triggerServerEvent( "onPlayerWannaExitFightClub", resourceRoot, i )
		end
		exit.PostLeave = function( self, pPlayer )
			SetCollidableWithPlayers( true )
		end

		local pNoColZone = createColSphere( -2106.510, 1108.572 - 860,  665.155, 20 )
		setElementParent( pNoColZone, exit.element )

		local lobby_config =
		{
			marker_text = "Список боёв",
			text = "ALT Взаимодействие",
			x = -2102.3659, 
			y = 1115.1652 - 860,
			z = 665.092,
			dimension = i,
			interior = 1,
			radius = 1.5,
		}
		local lobby_marker = TeleportPoint( lobby_config )
		lobby_marker.element:setData( "material", true, false )
    	lobby_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 30, 30, 180, 255, 1.15 } )
		lobby_marker.element:setData( "ignore_dist", true )
		lobby_marker.marker:setColor( 30, 30,180, 50 )
		lobby_marker.PreJoin = function( self , player )
			if player:GetBlockInteriorInteraction() then
				player:ShowInfo( "Вы не можете войти во время задания" )
				return false
			end
			return true
		end
		lobby_marker.PostJoin = function( self, pPlayer )
			SetCollidableWithPlayers( false )
			ShowLobbyListUI( true )
		end

		lobby_marker.PostLeave = function( self, pPlayer )
			SetCollidableWithPlayers( true )
			ShowLobbyListUI( false )
			ShowLobbyCreateUI( false )
		end

		--[[
		local tournament_config =
		{
			marker_text = "Турнир",
			text = "ALT Взаимодействие",
			x = -2108.303, 
			y = 1115.606 - 860,
			z = 665.09,
			dimension = i,
			interior = 1,
			radius = 1.5,
		}
		local tournament_marker = TeleportPoint( tournament_config )
		tournament_marker.element:setData( "material", true, false )
    	tournament_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 30, 30, 180, 255, 1.15 } )
		tournament_marker.element:setData( "ignore_dist", true)
		tournament_marker.marker:setColor( 30, 30, 180, 50 )
		tournament_marker.PreJoin = function( self , player )
			if player:GetBlockInteriorInteraction() then
				player:ShowInfo( "Вы не можете войти во время задания" )
				return false
			end
			return true
		end
		tournament_marker.PostJoin = function( self, pPlayer )
			local pToSend = {}
			pToSend.slots_left = (TOURNAMENT_DATA.max_participants or TOURNAMENT_MAX_PARTICIPANTS) - ( TOURNAMENT_DATA.participants and #TOURNAMENT_DATA.participants or 0 )
			pToSend.fights = {}
			pToSend.participants = TOURNAMENT_DATA.participants
			for k,v in pairs(TOURNAMENT_DATA.fights) do
				if not v.result then
					table.insert( pToSend.fights, { participants = v.participants } )
				end
			end
			triggerEvent( "FC:ShowUI_Tournament", resourceRoot, true, pToSend )
		end

		tournament_marker.PostLeave = function( self, pPlayer )
			triggerEvent( "FC:ShowUI_Tournament", resourceRoot, false )
		end
		]]
	end

	local ped = createPed( 39, -2117.4453, 1102.3576 - 860, 665.0920)
	ped.dimension = 1
	ped.interior = 1
	addEventHandler( "onClientPedDamage", ped, cancelEvent )
end)

function CreatePedMarkers()
	for k,v in pairs( FIGHT_CLUB_BUY_TICKER_MARKERS ) do
		local config = {}
		config.x = v.x
		config.y = v.y
		config.z = v.z
		config.dimension = v.dimension or 0
		config.interior = v.interior or 0
		config.accepted_elements = { player = true }
		config.keypress = "lalt"
		config.radius = 1.5

		config.marker_text = "Покупка билетов"
		config.text = "ALT Взаимодействие"
		v.teleport = TeleportPoint(config)
		v.teleport.element:setData( "material", true, false )
    	v.teleport:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 255, 0, 255, 1.2 } )
		v.teleport.element:setData("ignore_dist", true)
		v.teleport.marker:setColor(0,255,0,20)
		v.teleport.PreJoin = function( self , player )
			if player:GetBlockInteriorInteraction() then
				player:ShowInfo( "Вы не можете войти во время задания" )
				return false
			end
			return true
		end
		v.teleport.PostJoin = function( self, pPlayer )
			SetCollidableWithPlayers( true )
			v.func( localPlayer )
		end
		v.teleport.PostLeave = function()
			SetCollidableWithPlayers( false )
			ShowUI_Tickets( false )
		end
	end
end