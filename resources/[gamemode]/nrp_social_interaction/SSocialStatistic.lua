Extend( "ShApartments" )
Extend( "ShVipHouses" )
Extend( "ShVehicleConfig" ) -- for work GetVehicles & GetCars functions
Extend( "SVehicle" )
Extend( "ShSkin" )
Extend( "ShAccessories" )

SKINS_COSTS = { }

for _, v in pairs( BOUTIQUE_LIST ) do
	SKINS_COSTS[ v.id ] = v.cost
end

local availableStats = { }

function setAvailableStat( forPlayer, player, value )
    if type( value ) ~= "boolean" then return end

    if not availableStats[forPlayer] then
        availableStats[forPlayer] = { }
    end

    availableStats[forPlayer][player] = value == false and nil or value
end

function isAvailableStat( forPlayer, player )
    if not availableStats[forPlayer] then return false
    elseif not availableStats[forPlayer][player] then return false
    else return true
    end
end

function getPlayerStats( player )
    local function counterCompletedMissions( )
        local quests = player:GetPermanentData( "quests" )
        local counter = 0

        if not quests or not quests.completed then return counter end

        for _, _ in pairs( quests.completed ) do
            counter = counter + 1
        end

        return counter
    end

    return {
        mission         = counterCompletedMissions( ),
        task            = player:GetPermanentData( "dq_count" ) or 0,
        accumulation    = player:GetPermanentData( "jobs_cash_rewards" ) or 0,
        casino          = player:GetPermanentData( "casino_games_count" ) or 0,
        hobby           = player:GetPermanentData( "hobby_cash_rewards" ) or 0,
        event           = player:GetPermanentData( "join_events_counter" ) or 0,
        arrest          = player:GetPermanentData( "wanted_counter" ) or 0,
        kill            = player:GetPermanentData( "kill_counter" ) or 0,
        death           = player:GetPermanentData( "death_counter" ) or 0,
    }
end

function getPlayerPropertyStats( player )
    local function counterVeh( checkType )
        local vehicles = player:GetVehicles( false, true )
        local specVehicles = player:GetSpecialVehicles( )
        local counter = 0

        for _, vehicle in pairs( vehicles ) do
            if ( checkType and VEHICLE_CONFIG[vehicle.model][checkType] ) or not checkType then
                counter = counter + 1
            end
        end

        for _, vehicle in pairs( specVehicles ) do
            local model = vehicle[2]
            if ( checkType and VEHICLE_CONFIG[model][checkType] ) or not checkType then
                counter = counter + 1
            end
        end

        return counter
    end

    local motoC = counterVeh( "is_moto" )
    local airplaneC = counterVeh( "is_airplane" )
    local vesselC = counterVeh( "is_boat" )
    local carC = counterVeh( ) - motoC - airplaneC - vesselC

    local function counterProperty( )
        local cash = player:GetMoney( )
        local apartments = player:getData( "apartments" ) or {}
        local viphouse_ids = player:getData( "viphouse" ) or {}
        local vehicles = player:GetVehicles( false, true )
        local specVehicles = player:GetSpecialVehicles( )

        local businessesCost = 0
        local houseCost = 0
        local vehicleCost = 0
        local skinsCost = 0
        local accessoriesCost = 0

        for i, v in pairs( apartments ) do 
            houseCost = houseCost + APARTMENTS_CLASSES[ APARTMENTS_LIST[ v.id ].class ].cost
        end

        for i, v in pairs( viphouse_ids ) do 
            houseCost = houseCost + VIP_HOUSES_LIST[ v ].cost
        end

        for _, vehicle in pairs( vehicles ) do
            local model = vehicle.model
            local variant = vehicle:GetVariant( ) or 1
            vehicleCost = vehicleCost + VEHICLE_CONFIG[ model ].variants[ variant ].cost
        end

        for _, vehicle in pairs( specVehicles ) do
            local model = vehicle[2]
            vehicleCost = vehicleCost + VEHICLE_CONFIG[ model ].variants[ 1 ].cost
        end

        local businesses = exports.nrp_businesses:GetOwnedBusinesses( player )
        for _, business_id in pairs( businesses ) do
            businessesCost = businessesCost + exports.nrp_businesses:GetBusinessConfig( business_id, "cost" )
        end

        for _, skin_id in pairs( player:GetSkins( ) ) do
            if SKINS_COSTS[ skin_id ] then
                skinsCost = skinsCost + SKINS_COSTS[ skin_id ]
            end
        end

        for accessory_id in pairs( player:GetOwnedAccessories( ) ) do
            local info = CONST_ACCESSORIES_INFO[ accessory_id ]
            if info then
                local cost = info.soft_cost or ( info.hard_cost and info.hard_cost * 1000 ) or 0
                accessoriesCost = accessoriesCost + cost
            end
        end

        return cash + houseCost + vehicleCost + businessesCost + skinsCost + accessoriesCost
    end

    local function getHouseCount( )

        local apartments = player:getData( "apartments" ) or {}
        local viphouse_ids = player:getData( "viphouse" ) or {}

        local count = #apartments + #viphouse_ids

        return count
    end

    local function counterSkins( )
        local skins = player:GetSkins( )
        local counter = 0

        for _, _ in pairs( skins ) do
            counter = counter + 1
        end

        return counter
    end

    local function counterAccessories( )
        local accessories = player:GetOwnedAccessories( )
        local counter = 0

        for _, _ in pairs( accessories ) do
            counter = counter + 1
        end

        return counter
    end

    local function counterBusinesses( )
        local businesses = exports.nrp_businesses:GetOwnedBusinesses( player )
        local counter = 0

        for _, _ in pairs( businesses ) do
            counter = counter + 1
        end

        return counter
    end

    return {
        property    = counterProperty( ),
        car         = carC,
        house       = getHouseCount( ),
        skin        = counterSkins( ),
        accessory   = counterAccessories( ),
        business    = counterBusinesses( ),
        moto        = motoC,
        airplane    = airplaneC,
        vessel      = vesselC,
    }
end

addEventHandler( "onPlayerQuit", root, function ( )
    availableStats[source] = nil
end )

addEvent( "socialInteractionDontShowStats", true )
addEventHandler( "socialInteractionDontShowStats", root, function ( player )
    if client ~= source or not isElement( source ) then return end

    setAvailableStat( source, player, false )
end )