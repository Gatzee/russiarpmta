local task_cid = BP_TASK_GOVERNMENTS_VISIT

local check_locations = {
    [ "government_msk" ] = true,
    [ "government_nsk" ] = true,
    [ "government_gorki" ] = true,
    [ "red_square" ] = true,
}

local self
self = {
    CheckVisited = function( gov_id )
        local player = source

        if not check_locations[ gov_id ] then return end

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end

        local visited = player:GetTaskData( task_id, "visited_markets" ) or { }
        
        if gov_id and not visited[ gov_id ] then
            player:AddTaskProgress( task_id, 1 )

            visited[ gov_id ] = true
            player:SetTaskData( task_id, "visited_markets", visited )
        end
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

if not localPlayer then
    addEvent( "onPlayerLocationEnter", true )
    addEventHandler( "onPlayerLocationEnter", root, self.CheckVisited )
end

if localPlayer then
    -- Красная площадь
    local col = createColPolygon(
        Vector2{ x = 24.344, y = 2623.805 },
        Vector2{ x = 109.768, y = 2687.413 },
        Vector2{ x = 375.482, y = 2364.553 },
        Vector2{ x = 406.368, y = 2285.808 },
        Vector2{ x = 274.934, y = 2247.477 },
        Vector2{ x = 245.021, y = 2357.828 },
        Vector2{ x = 24.344, y = 2623.805 }
    )

    addEventHandler( "onClientColShapeHit", col, function( element )
        if element == localPlayer then
            triggerServerEvent( "onPlayerLocationEnter", localPlayer, "red_square" )
        end
    end )
end