loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "SDB" )

function onVehiclePassportShowRequest_handler( target )
    local player = source

    if target:getData("is_fishing") then return end
    if target:getData("in_clan_event_lobby") then return end

    local last_entered_vehicle_id = player:GetPermanentData( "last_entered_vehicle_id" )
    if not last_entered_vehicle_id then return end
    local vehicle = GetVehicle( last_entered_vehicle_id )
    if not isElement( vehicle ) then return end

    if vehicle:GetOwnerID( ) == player:GetUserID( ) then
        local parts = vehicle:GetParts( )
        local stats = { vehicle:GetStats( parts ) }

        local purchase_date = vehicle:GetPermanentData( "purchase_date" )
        if not purchase_date then
            local timestamp = getRealTime().timestamp
            vehicle:SetPermanentData( "purchase_date", timestamp )
            purchase_date = timestamp
        end

        local tuningDetails = exports.nrp_vehicle_conditions:GetVehicleTuningLevels( vehicle )
        local mileanceCoeff  = ( TUNING_EFFECT_WEAR.status[tuningDetails] - 1 ) * 100
        local damageCoeff = ( 1 - TUNING_EFFECT_WEAR.damage[tuningDetails] ) * 100

        local conf = {
            vehicle             = vehicle,
            variant             = vehicle:GetVariant( ),
            class               = vehicle:GetTier( ),
            parts               = parts,
            stats               = stats,
            purchase_date       = get_date_from_unix( purchase_date ),
            price   		    = vehicle:GetPrice(),
            untradable          = vehicle:GetPermanentData( "untradable" ) or ( vehicle:GetPermanentData( "temp_timeout" ) or 0 ) > 0 or nil,
            color               = tocolor( unpack( vehicle:GetColor( ) ) ),
            repairs             = vehicle:GetPermanentData( "engine_repairs" ) or 0,
            mileanceCoeff       = mileanceCoeff,
            damageCoeff         = damageCoeff,
            statusNumber        = vehicle:GetProperty( "statusNumber" ) or 1,
            inventory_expand    = vehicle:GetPermanentData( "inventory_expand" ),
        }

        triggerClientEvent( target, "ShowVehiclePassportUI", player, true, conf )
    else
        player:ShowError( "Ты не являешься владельцем машины по техпаспорту" )
    end
end
addEvent( "onVehiclePassportShowRequest" )
addEventHandler( "onVehiclePassportShowRequest", root, onVehiclePassportShowRequest_handler )

function onPlayerVehicleEnter_handler( vehicle, seat )
    if seat == 0 then
        local player = source
        if vehicle:GetOwnerID() == player:GetUserID() then
            player:SetPermanentData( "last_entered_vehicle_id", vehicle:GetID( ) )

            if eventName == "RefreshVehiclePassport" then
                triggerClientEvent( player, "RefreshVehiclePassport", player )
            end
        end
    end
end
addEventHandler( "onPlayerVehicleEnter", root, onPlayerVehicleEnter_handler )
addEvent( "RefreshVehiclePassport" )
addEventHandler( "RefreshVehiclePassport", root, onPlayerVehicleEnter_handler )

function onPlayerBuyCar_handler( vehicle )
    vehicle:SetPermanentData( "purchase_date", getRealTime().timestamp )
end
addEvent( "onPlayerBuyCar", true )
addEventHandler( "onPlayerBuyCar", root, onPlayerBuyCar_handler )

function get_date_from_unix(unix_time)
    local day_count, year, days = function(yr) return (yr % 4 == 0 and (yr % 100 ~= 0 or yr % 400 == 0)) and 366 or 365 end, 1970, math.ceil(unix_time/86400)

    while days >= day_count(year) do
        days = days - day_count(year) year = year + 1
    end
    local tab_overflow = function(seed, table) for i = 1, #table do if seed - table[i] <= 0 then return i, seed end seed = seed - table[i] end end
    local month, days = tab_overflow(days, {31,(day_count(year) == 366 and 29 or 28),31,30,31,30,31,31,30,31,30,31})
    local hours, minutes, seconds = math.floor(unix_time / 3600 % 24), math.floor(unix_time / 60 % 60), math.floor(unix_time % 60)
    local period = hours > 12 and "pm" or "am"
    hours = hours > 12 and hours - 12 or hours == 0 and 12 or hours
    return string.format("%02d.%02d.%04d", days, month, year, hours, minutes, seconds, period)
end