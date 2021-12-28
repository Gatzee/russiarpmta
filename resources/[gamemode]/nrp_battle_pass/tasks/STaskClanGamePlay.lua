local task_cid_by_clan_game = {
    [ "box_drop"   ] = BP_TASK_CLAN_CARGODROP ,
    [ "graffiti"   ] = BP_TASK_CLAN_GRAFFITI  ,
    [ "treasure"   ] = BP_TASK_CLAN_PACKAGES  ,
    [ "deathmatch" ] = BP_TASK_CLAN_TDM       ,
    [ "clan_raid"  ] = BP_TASK_CLAN_HOLDAREA  ,
}

local self
self = {
    onPlayerChangeClanHonor_handler = function( event_name )
        local player = source
        
        local task_cid = task_cid_by_clan_game[ event_name ]
        if not task_cid then return end
        
        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        player:AddTaskProgress( task_id, 1 )
    end,
}
for i, task_cid in pairs( task_cid_by_clan_game ) do
    BP_TASKS_CONTROLLERS[ task_cid ] = self
end

addEvent( "onPlayerChangeClanHonor" )
addEventHandler( "onPlayerChangeClanHonor", root, self.onPlayerChangeClanHonor_handler )