local task_cid = BP_TASK_VEHICLE_MARKETS_VISIT

local self
self = {
    CheckMarketVisited = function( market_id )
        local player = client or source

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end

        local visited = player:GetTaskData( task_id, "visited_markets" ) or { }
        market_id = tonumber( market_id )
        
        if market_id and not visited[ market_id ] then
            player:AddTaskProgress( task_id, 1 )

            visited[ market_id ] = true
            player:SetTaskData( task_id, "visited_markets", visited )
        end
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onPlayerCarsellOpen" )
addEventHandler( "onPlayerCarsellOpen", root, self.CheckMarketVisited )

addEvent( "onPlayerAirplaneMarketOpen", true )
addEventHandler( "onPlayerAirplaneMarketOpen", root, self.CheckMarketVisited )

addEvent( "onPlayerBoatMarketOpen", true )
addEventHandler( "onPlayerBoatMarketOpen", root, self.CheckMarketVisited )