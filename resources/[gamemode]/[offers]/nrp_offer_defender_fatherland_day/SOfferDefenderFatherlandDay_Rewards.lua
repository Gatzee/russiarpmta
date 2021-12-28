
REWARDS =
{
    soft = function( player, reward_data )
        player:GiveMoney( reward_data.cost * 1000, "sale", "defender_pack_reward" )
    end,

    case = function( player, reward_data )
        player:GiveCase( reward_data.item_id, reward_data.quantity )
    end,

    vehicle = function( player, reward_data )
		local pRow	= {
			model 		= reward_data.item_id;
			variant		= reward_data.variant or 1;
			x			= 0;
			y			= 0;
			z			= 0;
			rx			= 0;
			ry			= 0;
			rz			= 0;
			owner_pid	= "p:" .. player:GetUserID();
			color		= reward_data.color or { 58, 82, 58 };
		}
	
		exports.nrp_vehicle:AddVehicle( pRow, true, "OfferDefenderFatherlandDayCallback", { player = player, cost = VEHICLE_CONFIG[ pRow.model ].variants[ pRow.variant ].cost } )
    end,

    skin = function( player, reward_data )
        if not player:HasSkin( reward_data.item_id ) and SKINS_GENDERS[ reward_data.item_id ] == player:GetGender( ) then
            player:GiveSkin( reward_data.item_id )
        else
            player:GiveMoney( reward_data.convert_cost, "sale", "defend_item_return" )
            player:ShowInfo( "Вам возвращен денежный эквивалент за \"" ..reward_data.item_name .. "\" в размере " .. format_price( reward_data.convert_cost ) .. "р." )
        end
    end,

    vinyl = function( player, reward_data )
        reward_data.params = 
        {
            id = reward_data.item_id,
        }
        player:SetPermanentData( "last_defender_fatherland_day_vinyl", reward_data )
        triggerClientEvent( player, "onClientSelectVinyl", resourceRoot, reward_data )
    end,

    iventory_item = function( player, reward_data )
        player:InventoryAddItem( reward_data.item_id, nil, reward_data.quantity )
    end,
}

function onServerPlayerSelectedVinyl_handler( data )
    local player = client
    if not isElement( player ) then return end

    local reward_data = player:GetPermanentData( "last_defender_fatherland_day_vinyl" )
    if not reward_data then return end

    player:GiveVinyl( {
        [ P_PRICE_TYPE ] = "hard",
        [ P_IMAGE      ] = reward_data.item_id,
        [ P_CLASS      ] = (data and data.vehicle and data.vehicle:GetTier()) or 1,
        [ P_NAME       ] = VINYL_NAMES[ reward_data.item_id ],
        [ P_PRICE      ] = reward_data.cost,
    } )

    player:SetPermanentData( "last_defender_fatherland_day_vinyl", nil )
end
addEvent( "onServerPlayerSelectedVinyl", true )
addEventHandler( "onServerPlayerSelectedVinyl", resourceRoot, onServerPlayerSelectedVinyl_handler )

function OfferDefenderFatherlandDayCallback_handler( vehicle, data )
    if isElement( vehicle ) and isElement( data.player ) then
		
        
        if data.player.dimension == 0 and data.player.interior == 0 then
            vehicle.locked = true
		    vehicle.engineState = true
            vehicle.position = data.player.position

		    removePedFromVehicle( data.player )
            warpPedIntoVehicle( data.player, vehicle )
        else
            vehicle:SetParked( true )
            data.player:ShowInfo( "Транспорт " .. VEHICLE_CONFIG[ vehicle.model ].model .. " припаркован в гараж" )
        end
	end
end
addEvent( "OfferDefenderFatherlandDayCallback", true )
addEventHandler( "OfferDefenderFatherlandDayCallback", resourceRoot, OfferDefenderFatherlandDayCallback_handler )