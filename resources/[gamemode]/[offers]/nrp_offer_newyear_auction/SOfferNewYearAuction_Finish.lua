-- Завершение аукциона
function FinishAuction()
    local func_finish = function()
        DB:queryAsync( function( qh )
            local result = qh:poll( -1 )
            if not result or #result == 0 then return end
    
            local leader_data = result[ 1 ]
            GiveRewardNewYearAuction( leader_data )
    
            for k, v in pairs( result ) do
                if v.id ~= leader_data.id then
                    local player = GetPlayer( v.id )
                    if isElement( player ) then ReturnPlayerBet( player, v.new_year_auction_rate ) end
                end
            end
    
            CURREN_LEADER_DATA = { player_id = -1, nickname = "Отсутствует", value = 0, skin_id = 0 }
        end, {}, "SELECT id, client_id, new_year_auction_rate FROM nrp_players WHERE new_year_auction_rate > 0 ORDER BY new_year_auction_rate DESC" )
    end
    setTimer( func_finish, 120000, 1 )
    
    for k, v in pairs( GetPlayersInGame() ) do
        if v:GetPlayerRate() > 0 then
            v:SendMsg( "Аукцион закончен, победитель\nбудет объявлен через 2 минуты!", true )
        end
    end

    triggerClientEvent( "onClientEndNewYearAuctionUI", resourceRoot )
end

-- Выдача награды игроку/запись флага на выдачу при входе => new_year_auction_rate = -1
function GiveRewardNewYearAuction( leader_data )
    local player = GetPlayer( leader_data.id )
    if isElement( player ) then
        ResetPlayerOfferData( player )
        GivePlayerAuctionVehicle( player )
    else
        DB:exec( "UPDATE nrp_players SET new_year_auction_rate = -1 WHERE id = ?", leader_data.id )
    end

    -- Аналитика :-
    onChristmasAuctionFinish( leader_data.client_id, leader_data.new_year_auction_rate, true )
end

-- Выдача байка
function GivePlayerAuctionVehicle( player )
    local owner_pid	= "p:" .. player:GetUserID( )
    local vehicle_conf	= {
        model 		= 522,
        variant		= 1,
        x			= 0,
        y			= 0,
        z			= 0,
        rx			= 0,
        ry			= 0,
        rz			= 0,
        owner_pid	= owner_pid,
        color		= { 151, 7, 5 },
    }

    exports.nrp_vehicle:AddVehicle( vehicle_conf, true, "onNewYearAuctionGiveVehicleCallback", { player = player, cost = CONST_MIN_RATE * 1000 } )
end

-- Применение настроек к тачке
function onNewYearAuctionGiveVehicleCallback_handler( vehicle, data )
	local sOwnerPID = "p:" .. data.player:GetUserID()
    
    vehicle:SetFuel( "full" )
    
	vehicle:SetPermanentData( "showroom_cost", data.cost )
	vehicle:SetPermanentData( "showroom_date", getRealTimestamp() )
	vehicle:SetPermanentData( "first_owner", sOwnerPID )
    
    vehicle:SetColor( 151, 7, 5 )
    vehicle:SetWindowsColor( 0, 0, 0, 120 )

    local internal_tuning = { { id = 5 }, { id = 20 }, { id = 35 }, { id = 50 }, { id = 65 }, { id = 80 }, { id = 95 } }
    for k, v in pairs( internal_tuning ) do
        vehicle:ApplyPermanentPart( v.id )
    end

    local vinyls = 
    {
        [ 8 ]  = { [3] = 6, [7] = 112,       [10] = 221000, [14] = "soft", [15] = 112,       [16] = 8,  [17] = { color = -62199, mirror = false, rotation = 0,         size = 3,   x = 512, y = 512 }, },
        [ 10 ] = { [3] = 6, [7] = "mirage7", [10] = 201600, [14] = "soft", [15] = "mirage7", [16] = 10, [17] = { color = -9983,                  rotation = 200.89999, size = 1.5, x = 567, y = 220 }, },
        [ 12 ] = { [3] = 6, [7] = "mirage7", [10] = 201600, [14] = "soft", [15] = "mirage7", [16] = 12, [17] = { color = -8382,                  rotation = 338.46155, size = 1.5, x = 563, y = 809 }, },
    }
    vehicle:SetVinyls( vinyls )
	setElementData( vehicle, "vehicle_vinyl_data", { vinyls = vinyls, color = { vehicle:getColor( true ) } } )

    data.player:AddVehicleToList( vehicle )
    vehicle:SetParked( true )

    data.player:SendMsg( "Вы выиграли в аукционе,\nбайк отправлен на парковку!", true )
end
addEvent( "onNewYearAuctionGiveVehicleCallback", true)
addEventHandler( "onNewYearAuctionGiveVehicleCallback", resourceRoot, onNewYearAuctionGiveVehicleCallback_handler )