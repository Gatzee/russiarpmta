loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

CONST_DIFF_COMPENSATION = 10 * 60

function onPlayerReadyToPlay_handler( player )
    local player = isElement( player ) and player or source
    local ts = getRealTimestamp()

    if player:GetLevel( ) < 3 then return end

	local seq = player:GetPermanentData( "retention_tasks_seq" ) or { }
    local seq_changed = false
	for i, v in pairs( RETENTION_TASKS_LIST ) do
		if ts >= v.start_date and ts <= v.finish_date then
            local diff = v.finish_date - ts
			if diff > CONST_DIFF_COMPENSATION then
                local task_key = v.id .. "_" .. v.finish_date
				if not seq[ task_key ] then
                    seq[ task_key ] = true
                    seq_changed = true

                    player:StartRetentionTask( v.id, diff )
                end
            end
        end
    end

    if seq_changed then
        player:SetPermanentData( "retention_tasks_seq", seq )
    end
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler, true, "low" )

function onResourceStart_handler( )
	triggerEvent( "onSpecialDataRequest", getResourceRootElement( ), "retention_tasks" )
    setTimer( function( )
        for i, v in pairs( GetPlayersInGame( ) ) do
            onPlayerReadyToPlay_handler( v )
        end
	end, 2000, 1 )
	--После запуска ресурса обновляем все даты
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
	if key ~= "retention_tasks" then return end

	if not value or next( value ) == nil then 
		RETENTION_TASKS_LIST = { }
	else
		for i,v in pairs( value ) do
			v.start_date = getTimestampFromString( v.start_date )
			v.finish_date = getTimestampFromString( v.finish_date )
		end
		RETENTION_TASKS_LIST = value
	end
end )

--После теста можно убрать
if SERVER_NUMBER > 100 then 
addCommandHandler( "resetsequence", function( player )
	player:SetPermanentData( "retention_tasks_seq", { } )
    player:SetPermanentData( "retention_tasks_today", nil )
    player:SetPermanentData( "retention_tasks",nil )
	onPlayerReadyToPlay_handler( player )
	player:ShowInfo("Sequence reset")
end)
end