loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SDB" )
Extend( "SPlayerCommon" )
Extend( "ShTimelib" )

GLOBAL_START = 0 -- 1568840400 -- TODO: Вернуть для релиза (хотя не похуй ли?)
GLOBAL_FINISH = 1568970000

function onPlayerSessionStart_handler( session_count )
    local player = source

    local ts = getRealTime( ).timestamp
    if ts <= GLOBAL_START then return end
    if ts >= GLOBAL_FINISH then return end

    player:GetCommonData( { "rtasks4_group" }, { player }, function( result, player )
        if not isElement( player ) then return end

        if not result.rtasks4_group then
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

                    player:SetCommonData( { rtasks4_group = next_group.group_name } )
                    triggerEvent( "onSegmentedRetentionTasksGroupLoad", player, next_group.group_name, true )

                    CommonDB:exec( "UPDATE offers_segmentedretentiontasks SET count=`count`+1, today_count=`today_count`+1 WHERE id=? ", next_group.id )
                end
            end, { player },
            "SELECT * FROM offers_segmentedretentiontasks" )
        
        elseif result.rtasks4_group then
            triggerEvent( "onSegmentedRetentionTasksGroupLoad", player, result.rtasks4_group )

        end
    end )
end
addEvent( "onPlayerSessionStart", true )
addEventHandler( "onPlayerSessionStart", root, onPlayerSessionStart_handler )

function CleanDatabase( )
    CommonDB:exec( "UPDATE offers_segmentedretentiontasks SET today_count=0" )
    DATABASE_CLEAN_TIMER = setTimer( CleanDatabase, 24 * 60 * 60 * 1000, 1 )
end
ExecAtTime( "00:00", CleanDatabase )

function onSegmentedRetentionTasksGroupLoad_handler( group_name, is_first_time )
    iprint( "Player load retention group", group_name, is_first_time )
    if group_name == "group_A" then
        source:SetCommonData( { rtasks4_group = "group_A_finished" } )

        source:StartRetentionTask( "drive5" )
        source:StartRetentionTask( "run5" )

        triggerEvent( "ShowRetentionInterfaceRequest", source )
    end
end
addEvent( "onSegmentedRetentionTasksGroupLoad", true )
addEventHandler( "onSegmentedRetentionTasksGroupLoad", root, onSegmentedRetentionTasksGroupLoad_handler )