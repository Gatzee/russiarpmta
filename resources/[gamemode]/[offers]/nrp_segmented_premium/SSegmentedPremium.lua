loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SDB" )
Extend( "SPlayerCommon" )
Extend( "ShTimelib" )

INSTALL_DATE_CONSIDERATION_PREMIUM = 1565298000

function onPlayerSessionStart_handler( session_count, install_date )
    local player = source

    player:GetCommonData( { "segmentedpremium_group", "install_date" }, { player }, function( result, player )
        if not isElement( player ) then return end
        if ( tonumber( result.install_date ) or 0 ) < INSTALL_DATE_CONSIDERATION_PREMIUM then return end

        if not result.segmentedpremium_group then
            CommonDB:queryAsync( function( result, player )
                if not isElement( player ) then return end

                local values = result:poll( -1 )

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

                    if next_group.group_name == "group_A" then
                        local timestamp = getRealTime( ).timestamp + 48 * 60 * 60
                        player:SetCommonData( { segmentedpremium_group = timestamp } ) 
                        triggerEvent( "onSegmentedPremiumGroupLoad", player, timestamp, true )
                    else
                        player:SetCommonData( { segmentedpremium_group = next_group.group_name } )
                        triggerEvent( "onSegmentedPremiumGroupLoad", player, next_group.group_name, true )
                    end

                    CommonDB:exec( "UPDATE offers_segmentedpremium SET count=`count`+1, today_count=`today_count`+1 WHERE id=? ", next_group.id )
                end
            end, { player },
            "SELECT * FROM offers_segmentedpremium" )
        
        elseif result.segmentedpremium_group then
            triggerEvent( "onSegmentedPremiumGroupLoad", player, result.segmentedpremium_group )

        end
    end )
end
addEvent( "onPlayerSessionStart", true )
addEventHandler( "onPlayerSessionStart", root, onPlayerSessionStart_handler )

function CleanDatabase( )
    CommonDB:exec( "UPDATE offers_segmentedpremium SET today_count=0" )
    DATABASE_CLEAN_TIMER = setTimer( CleanDatabase, 24 * 60 * 60 * 1000, 1 )
end
ExecAtTime( "00:00", CleanDatabase )

function onSegmentedPremiumGroupLoad_handler( group_name, is_first_time )
    iprint( "Player load premium group", group_name, is_first_time )
    if tonumber( group_name ) then
        source:setData( "segmented_premium", tonumber( group_name ), false )
        triggerEvent( "onPremiumDiscountsRefreshRequest", source )
    end
end
addEvent( "onSegmentedPremiumGroupLoad", true )
addEventHandler( "onSegmentedPremiumGroupLoad", root, onSegmentedPremiumGroupLoad_handler )