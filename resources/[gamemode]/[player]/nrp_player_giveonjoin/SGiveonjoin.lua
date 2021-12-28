loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "SPlayer" )
Extend( "SVehicle" )

function onPlayerReadyToPlay_handler( player )
    local player = isElement( player ) and player or source

    local give_on_join = player:GetPermanentData( "give_on_join" ) or { }
    if next( give_on_join ) then
        player:SetPermanentData( "give_on_join", nil )

        for i, v in pairs( give_on_join ) do
            local result, err = pcall( GiveItem, player, v )
            if not result then
                --iprint( "ERR GIVE ON JOIN", player, v )
                WriteLog( "give_on_join/err", "Игрок %s ошибка выдачи %s", player, v )
            else
                --iprint( "SUCCESS", player, v )
                WriteLog( "give_on_join/success", "Игрок %s получил %s", player, v )
            end
        end
    end
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )

addEvent( "onPlayerTestGiveonjoin" )
addEventHandler( "onPlayerTestGiveonjoin", root, onPlayerReadyToPlay_handler )

function GiveItem( player, item )
    if item.type == "vehicle" then
        local owner_pid = "p:" .. player:GetUserID( )

		local row	= {
			model     = item.model;
			variant   = item.variant or 1;
			x         = 0;
			y         = 0;
			z         = 0;
			rx        = 0;
			ry        = 0;
			rz        = 0;
			owner_pid = owner_pid;
			color     = { 255, 255, 255 };
		}
	
		exports.nrp_vehicle:AddVehicle( row, true, "OnGivejoinVehicleAdded", { player = player, cost = VEHICLE_CONFIG[ id.model ].variants[ id.variant or 1 ].cost } )

    elseif item.type == "accessory" then
        player:AddOwnedAccessory( item.id )

    elseif item.type == "skin" then
        player:InventoryAddItem( IN_CLOTHES, { item.id }, 1 )

    elseif item.type == "license" then
        player:GiveLicense( item.id )

    end

    return true
end

function OnGivejoinVehicleAdded_handler( vehicle, data )
    if isElement( vehicle ) and isElement( data.player ) then
        local owner_pid = "p:" .. data.player:GetUserID( )

        vehicle:SetOwnerPID( owner_pid )
        vehicle:SetFuel( "full" )
        vehicle:SetColor( 255, 255, 255 )
        vehicle:SetParked( true )

        vehicle:SetPermanentData( "showroom_cost", data.cost )
        vehicle:SetPermanentData( "showroom_date", getRealTime( ).timestamp )
        
        vehicle:SetPermanentData( "first_owner", owner_pid )

        triggerEvent( "CheckPlayerVehiclesSlots", data.player )
    end
end
addEvent( "OnGivejoinVehicleAdded" )
addEventHandler( "OnGivejoinVehicleAdded", root, OnGivejoinVehicleAdded_handler )