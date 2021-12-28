Extend( "CInterior" )
Extend( "CVehicle" )
Extend( "ShUtils" )


local NPC_SHOP_DATA = {
	{
		position = Vector3( 742.594, -159.5, 20.903 );
		rotation = 90;
		veh = {
			{
				model = 6637;
				position = Vector3( 743.971, -163.251, 20.768 );
				rotation = Vector3( 0, 0, 56 );
			},
			{
				model = 413;
				position = Vector3( 744.538, -155.929, 21.193 );
				rotation = Vector3( 0, 0, 115 );
			},
		}
	},
	{
		position = Vector3( 2048.51, -742.11, 60.65 );
		rotation = 45;
		veh = {
			{
				model = 6637;
				position = Vector3( 2054.22, -741.77, 60.5 );
				rotation = Vector3( 0, 0, 19 );
			},
			{
				model = 413;
				position = Vector3( 2046.9, -748.27, 60.965 );
				rotation = Vector3( 0, 0, 64 );
			},
		}
	},
	{
		position = Vector3( -100.885, -1985.183, 20.802 );
		rotation = 0;
		veh = {
			{
				model = 6637;
				position = Vector3( -106.279, -1991.002, 20.666 );
				rotation = Vector3( 0, 0, 317 );
			},
			{
				model = 413;
				position = Vector3( -95.835, -1990.793, 21.091 );
				rotation = Vector3( 0, 0, 40 );
			},
		}
	},
	{
		position = Vector3( -54.55, 2253.6, 21.61 );
		rotation = 0;
		veh = {
			{
				model = 6637;
				position = Vector3( -59.866, 2247.850, 21.461 );
				rotation = Vector3( 0, 0, 317 );
			},
			{
				model = 413;
				position = Vector3( -49.854, 2247.895, 21.917 );
				rotation = Vector3( 0, 0, 40 );
			},
		}
	},
}

local notification_player_timer = nil

function onPlayerVerifyReadyToSpawn( )
	local timestamp = getRealTimestamp( )
	if timestamp >= EVENTS_TIMES[ CURRENT_EVENT ].from and timestamp < EVENTS_TIMES[ CURRENT_EVENT ].to then
		local elements = { }

		for i, v in pairs( NPC_SHOP_DATA ) do
			local ped = createPed( 6752, v.position, v.rotation )
			ped.frozen = true
			addEventHandler("onClientPedDamage", ped, cancelEvent)
			table.insert( elements, ped )


			for _, info in pairs( v.veh ) do
				local veh = createVehicle( info.model, info.position, info.rotation )
				veh.frozen = true
				veh.overrideLights = 2
				veh:setColor( 9, 17, 9 )
				veh:SetWindowsColor( 0, 0, 0, 220 )
				addEventHandler("onClientVehicleDamage", veh, cancelEvent)
				addEventHandler("onClientVehicleStartEnter", veh, cancelEvent)
				table.insert( elements, veh )
			end

			local npc_shop = TeleportPoint( {
				x = v.position.x, y = v.position.y, z = v.position.z;
				radius = 4;
				keypress = "lalt";
				text = "ALT Взаимодействие";
			} )
			table.insert( elements, npc_shop )

			npc_shop.marker:setColor( 0, 0, 0, 0 )

			npc_shop.PreJoin = function( )
				return true
			end

			npc_shop.PostJoin = function( self, player )
				triggerEvent( "ShowUIEventShop", resourceRoot )
			end

			npc_shop.elements = {}
			npc_shop.elements.blip = Blip( npc_shop.x, npc_shop.y, npc_shop.z, 23, 2, 255, 0, 0, 255, 0, 300 )
		end

		Timer( function( )
			local timestamp = getRealTimestamp( )
			if not ( timestamp >= EVENTS_TIMES[ CURRENT_EVENT ].from and timestamp < EVENTS_TIMES[ CURRENT_EVENT ].to ) then
				killTimer( sourceTimer )
				for _, element in pairs( elements ) do
					element:destroy( )
				end

				if isTimer( notification_player_timer ) then
					killTimer( notification_player_timer )
				end
			end
		end, 60000, 0 )


		local function notifyLocalPlayer( )
			if localPlayer.dimension ~= 0 then return end
			localPlayer:PhoneNotification( {
				title = "Майские праздники";
				msg_short = "Майский ивент в разгаре!!! Тебя ждут увлекательные состязания и уникальные товары в Майском магазине! ";
				msg = "Майский ивент в разгаре!!! Тебя ждут увлекательные состязания и уникальные товары в Майском магазине! ";
			} )
		end

		notification_player_timer = Timer( function( )
			notifyLocalPlayer( )
			notification_player_timer = Timer( notifyLocalPlayer, 3 * 60 * 60 * 1000, 0 )
		end, 1 * 60 * 1000, 1 )
	end
end
addEventHandler( "onPlayerVerifyReadyToSpawn", root, onPlayerVerifyReadyToSpawn )

-- Тестирование
function OnClientCreateEventShop_handler( )
	onPlayerVerifyReadyToSpawn( )
end
addEvent( "OnClientCreateEventShop", true )
addEventHandler( "OnClientCreateEventShop", resourceRoot, OnClientCreateEventShop_handler )