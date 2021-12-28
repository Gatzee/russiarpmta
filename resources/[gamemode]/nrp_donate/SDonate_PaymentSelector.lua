loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
MARIADB_INCLUDE = { APIDB = true }
Extend( "SDB" )
Extend( "SPlayerCommon" )
Extend( "ShTimelib" )

PAYMENTS_SELECTOR_ENABLED = true

function onPlayerSessionStart_handler( session_count, install_date )
    local player = source

    if not PAYMENTS_SELECTOR_ENABLED then
        --triggerEvent( "onSegmentedPaymentsLoadFinished", player )
        return
    end

    player:GetCommonData( { "payments_system_group", "install_date" }, { player }, function( result, player )
        if not isElement( player ) then return end
        local country = exports.admin:getPlayerCountry( player ) or "RU"

        if ( tonumber( result.install_date ) or 0 ) >= PAYMENTS_RELEASE_DATE then
            if not result.payments_system_group then
                CommonDB:queryAsync( function( query, player )
                    if not isElement( player ) then dbFree( query ) return end

                    local values = query:poll( -1 )

                    local sum = 0
                    local available_groups = { }
                    for i, v in pairs( values ) do
                        sum = sum + v.count
                        if ( v.count < v.max_count or v.max_count == -1 ) and ( v.today_count < v.today_max_count or v.today_max_count == -1 ) then
                            if DoesCountryMatch( country, v.countries_allowed ) then
                                table.insert( available_groups, v )
                            end
                        end
                    end

                    if #available_groups > 0 then
                        local next_group_num = 1 + ( sum + 1 ) % #available_groups
                        local next_group = available_groups[ next_group_num ]

                        player:SetCommonData( { payments_system_group = next_group.group_name } )
                        triggerEvent( "onSegmentedPaymentsLoad", player, next_group.group_name, true )

                        CommonDB:exec( "UPDATE segmented_payments SET count=`count`+1, today_count=`today_count`+1 WHERE id=? ", next_group.id )
                    end
                end, { player },
                "SELECT * FROM segmented_payments" )
            
            elseif result.payments_system_group then
                triggerEvent( "onSegmentedPaymentsLoad", player, result.payments_system_group )
                ForceCountrySwitch( player, country )
            end
        else
            ForceCountrySwitch( player, country )
        end
    end )
end
addEvent( "onPlayerSessionStart" )
addEventHandler( "onPlayerSessionStart", root, onPlayerSessionStart_handler, true, "low" )

function DoesCountryMatch( country, list_json )
    if list_json == "any" then
        return true
    else
        local list = list_json and fromJSON( list_json )
        if list then
            for i, v in pairs( list ) do
                if v == country then
                    return true
                end
            end
        end
    end
end

function ForceCountrySwitch( player, country )
    if not PAYMENTS_SELECTOR_ENABLED then return end
    if country ~= "RU" then
        if player:getData( "pmethod" ) ~= "gamemoney" then
            player:SetPaymentMethod( "gamemoney" )
            player:SetCommonData( { payments_system_group = "gamemoney" } )
        end
    end
end

function CleanDatabase( )
    CommonDB:exec( "UPDATE segmented_payments SET today_count=0" )
    DATABASE_CLEAN_TIMER = setTimer( CleanDatabase, 24 * 60 * 60 * 1000, 1 )
end
ExecAtTime( "00:00", CleanDatabase )

function onSegmentedPaymentsLoad_handler( group_name, is_first_time )
    if is_first_time then
        SendElasticGameEvent( source:GetClientID( ), "payment_system_group", { payment_system = group_name == "unitpay" and 1 or 2 } )
    end

    -- Если юнитпей, то он и так дефолтно юзается
    if group_name ~= "unitpay" then
        local methods = fromJSON( MariaGet( "payment_methods" ) )
        for i, v in pairs( methods or { } ) do
            if v == group_name then
                source:SetPaymentMethod( group_name )
                break
            end
        end
    end

    --triggerEvent( "onSegmentedPaymentsLoadFinished", player )
end
addEvent( "onSegmentedPaymentsLoad", true )
addEventHandler( "onSegmentedPaymentsLoad", root, onSegmentedPaymentsLoad_handler )

-- На всякий случай если потребуется быстро всем вырубить гейммани
function KillSwitch( )
    for i, v in pairs( GetPlayersInGame( ) ) do
        if v:getData( "pmethod" ) == "gamemoney" then
            v:SetPrivateData( "pmethod", nil )
        end
    end
end

function Player:SetPaymentMethod( method )
    self:SetPrivateData( "pmethod", method )
end