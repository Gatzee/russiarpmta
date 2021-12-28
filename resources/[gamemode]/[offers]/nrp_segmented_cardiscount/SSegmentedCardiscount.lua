loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SDB" )
Extend( "SPlayerCommon" )
Extend( "ShTimelib" )

INSTALL_DATE_CONSIDERATION_CARDISCOUNT = 1565125200

function onPlayerSessionStart_handler( session_count, install_date )
    local player = source

    player:GetCommonData( { "segmentedcardiscount_group", "install_date" }, { player }, function( result, player )
        if not isElement( player ) then return end
        if ( tonumber( result.install_date ) or 0 ) < INSTALL_DATE_CONSIDERATION_CARDISCOUNT then return end

        if not result.segmentedcardiscount_group then
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

                    player:SetCommonData( { segmentedcardiscount_group = next_group.group_name } )
                    triggerEvent( "onSegmentedCardiscountGroupLoad", player, next_group.group_name, true )

                    CommonDB:exec( "UPDATE offers_segmentedcardiscount SET count=`count`+1, today_count=`today_count`+1 WHERE id=? ", next_group.id )
                end
            end, { player },
            "SELECT * FROM offers_segmentedcardiscount" )
        
        elseif result.segmentedcardiscount_group then
            triggerEvent( "onSegmentedCardiscountGroupLoad", player, result.segmentedcardiscount_group )

        end
    end )
end
addEvent( "onPlayerSessionStart", true )
addEventHandler( "onPlayerSessionStart", root, onPlayerSessionStart_handler )

function CleanDatabase( )
    CommonDB:exec( "UPDATE offers_segmentedcardiscount SET today_count=0" )
    DATABASE_CLEAN_TIMER = setTimer( CleanDatabase, 24 * 60 * 60 * 1000, 1 )
end
ExecAtTime( "00:00", CleanDatabase )

function onSegmentedCardiscountGroupLoad_handler( group_name, is_first_time )
    iprint( "Player load cardiscount group", group_name, is_first_time )
    if group_name == "group_A" then
        source:setData( "cardiscount_test", true, false )
    end
end
addEvent( "onSegmentedCardiscountGroupLoad", true )
addEventHandler( "onSegmentedCardiscountGroupLoad", root, onSegmentedCardiscountGroupLoad_handler )