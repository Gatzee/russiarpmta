loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SDB" )
Extend( "SPlayerCommon" )
Extend( "ShTimelib" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )

INSTALL_DATE_CONSIDERATION = getTimestampFromString( "26 декабря 2019 00:00" )
TEST_START_POSTPONE = 7 * 24 * 60 * 60

function onPlayerSessionStart_handler( session_count, install_date )
    local player = source

    player:GetCommonData( { "vehdiscount_group", "install_date" }, { player }, function( result, player )
        if not isElement( player ) then return end

        local install_date = ( tonumber( result.install_date ) or 0 )

        -- Если инсталл после даты запуска теста
        if ( tonumber( result.install_date ) or 0 ) < INSTALL_DATE_CONSIDERATION then return end

        -- Если прошло 7 дней с момента инсталла
        if getRealTime( ).timestamp - install_date <= TEST_START_POSTPONE then return end

        -- Start group find
        if not result.vehdiscount_group then
            -- Start vehicles check
            local vehicles = player:GetVehicles( false, true )
            if #vehicles == 1 and isElement( vehicles[ 1 ] ) and vehicles[ 1 ].model == 468 then
                -- Start already has discount check
                if not player:GetAllVehiclesDiscount( ) then
                    -- Start payments check
                    CommonDB:queryAsync( function( query )
                        if not isElement( player ) then
                            dbFree( query )
                            return
                        end
                        local result = query:poll( -1 )
                        local paid_vefore = ( result[ 1 ].paid_before or 0 ) > 0

                        if not paid_before then
                            -- Start group distribution
                            CommonDB:queryAsync( function( query, player )
                                if not isElement( player ) then
                                    dbFree( query )
                                    return
                                end

                                local values = query:poll( -1 )

                                local sum = 0
                                local available_groups = { }
                                for i, v in pairs( values ) do
                                    sum = sum + v.count
                                    if ( v.count < v.max_count or v.max_count == -1 ) and ( v.today_count < v.today_max_count or v.today_max_count == -1 ) then
                                        table.insert( available_groups, v )
                                    end
                                end

                                if #available_groups > 0 then
                                    local next_group_num = 1 + ( sum + 1 ) % #available_groups
                                    local next_group = available_groups[ next_group_num ]

                                    player:SetCommonData( { vehdiscount_group = next_group.group_name } )
                                    triggerEvent( "onSegmentedVehdiscountGroupLoad", player, next_group.group_name, true )

                                    CommonDB:exec( "UPDATE offers_segmentedvehdiscount SET count=`count`+1, today_count=`today_count`+1 WHERE id=? ", next_group.id )
                                end
                            end, { player },
                            "SELECT * FROM offers_segmentedvehdiscount" )
                            -- End group distribution
                        end
                    end, { player }, "SELECT COUNT(*) AS paid_before FROM payments WHERE client_id=? LIMIT 1", player:GetClientID( ) )
                    -- End payments check
                end
                -- End already has discount check
            end
            -- End vehicles check
        elseif result.vehdiscount_group then
            triggerEvent( "onSegmentedVehdiscountGroupLoad", player, result.vehdiscount_group )
        end
        -- End group find
    end )
end
addEvent( "onPlayerSessionStart", true )
addEventHandler( "onPlayerSessionStart", root, onPlayerSessionStart_handler )

function CleanDatabase( )
    CommonDB:exec( "UPDATE offers_segmentedvehdiscount SET today_count=0" )
    DATABASE_CLEAN_TIMER = setTimer( CleanDatabase, 24 * 60 * 60 * 1000, 1 )
end
ExecAtTime( "00:00", CleanDatabase )

function onSegmentedVehdiscountGroupLoad_handler( group_name, is_first_time )
    iprint( "Player load vehicle group", group_name, is_first_time )
    if group_name == "group_A" then
        if is_first_time then source:GiveAllVehiclesDiscount( 24 * 60 * 60, 30 ) end
        source:setData( "vehdiscount_test", true, false )
    end
end
addEvent( "onSegmentedVehdiscountGroupLoad", true )
addEventHandler( "onSegmentedVehdiscountGroupLoad", root, onSegmentedVehdiscountGroupLoad_handler )

function onPlayerBuyCar_handler( vehicle, cost )
    local player = source

    if player:getData( "vehdiscount_test" ) then
        player:setData( "vehdiscount_test", false, false )
        player:SetCommonData( { vehdiscount_group = "finished" } )

        triggerEvent( "onSegmentedVehidscountVehiclePurchase", player, vehicle, cost )
    end
end
addEventHandler( "onPlayerBuyCar", root, onPlayerBuyCar_handler )