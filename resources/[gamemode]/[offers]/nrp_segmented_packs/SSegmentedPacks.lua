loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SDB" )
Extend( "SPlayerCommon" )
Extend( "ShTimelib" )

INSTALL_DATE_CONSIDERATION_PACKS = 1565820809

function onPlayerSessionStart_handler( session_count, install_date )
    local player = source

    player:GetCommonData( { "segmentedpacks_group", "segmentedpacks_ready" }, { player }, function( result, player )
        if not isElement( player ) then return end
        if ( install_date or 0 ) < INSTALL_DATE_CONSIDERATION_PACKS then return end

        if not result.segmentedpacks_group then
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

                    player:SetCommonData( { segmentedpacks_group = next_group.group_name } )
                    triggerEvent( "onSegmentedPacksGroupLoad", player, next_group.group_name, true )

                    CommonDB:exec( "UPDATE offers_segmentedpacks SET count=`count`+1, today_count=`today_count`+1 WHERE id=? ", next_group.id )
                end
            end, { player },
            "SELECT * FROM offers_segmentedpacks" )
        
        elseif result.segmentedpacks_group then
            triggerEvent( "onSegmentedPacksGroupLoad", player, result.segmentedpacks_group )

        end
    end )
end
addEvent( "onPlayerSessionStart", true )
addEventHandler( "onPlayerSessionStart", root, onPlayerSessionStart_handler )

function CleanDatabase( )
    CommonDB:exec( "UPDATE offers_segmentedpacks SET today_count=0" )
    DATABASE_CLEAN_TIMER = setTimer( CleanDatabase, 24 * 60 * 60 * 1000, 1 )
end
ExecAtTime( "00:00", CleanDatabase )

function onSegmentedPacksGroupLoad_handler( group_name, is_first_time )
    iprint( "Player load packs group", group_name, is_first_time )
    if group_name == "group_A" then
        source:SetPrivateData( "segmented_packs", true )
    end
end
addEvent( "onSegmentedPacksGroupLoad", true )
addEventHandler( "onSegmentedPacksGroupLoad", root, onSegmentedPacksGroupLoad_handler )