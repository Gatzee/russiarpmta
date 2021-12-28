
STAGE_4_WAIT = 4 * 60 * 60

EVENT_COUNT = 0
EVENT =
{
	[ "stage_1" ] =
	{
		id = "stage_1",
		start = "client",
		server = function( player, data )
            local pData = player:GetPermanentData( EVENT_NAME )
            SetNextStage( player, pData )
            
            -- Аналитика
            triggerEvent( "onPlayerHbEvent", player, 1, 0, "soft" )
		end,
    },
    [ "stage_2" ] =
	{
		id = "stage_2",
		start = "client",
        server = function( player, data )
            data.type_operation = data.type_operation or 1
            data.type_operation = math.min( 2, math.max( 1, data.type_operation ) )
            
			local pData = player:GetPermanentData( EVENT_NAME )
			pData.type_operation = data.type_operation
			pData.progresses.hdd_1.current = pData.progresses.hdd_1.current + 1
			SetNextStage( player, pData )

			player:InventoryRemoveItem( IN_HDD )
            player:InventoryAddItem( IN_HDD, nil, 1 )
            
            -- Аналитика
            triggerEvent( "onPlayerHbEvent", player, 2, 0, "soft" )
		end,
	},
	[ "stage_3" ] =
	{
		id = "stage_3",
		start = "client",
		server = function( player, data )
			local pData = player:GetPermanentData( EVENT_NAME )
			pData.time_wait = STAGE_4_WAIT
			pData.need_wait = pData.time_wait 
			pData.stage_wait = getRealTime().timestamp + pData.time_wait
			SetNextStage( player, pData )

            player:InventoryRemoveItem( IN_HDD )
            
            -- Аналитика
            triggerEvent( "onPlayerHbEvent", player, 3, 0, "soft" )
		end,
	},
	[ "stage_4" ] =
	{
		id = "stage_4",
		start = "client",
		server = function( player, data )
			local pData = player:GetPermanentData( EVENT_NAME )
			if pData.stage_wait - getRealTime().timestamp <= 0 then
				pData.need_wait, pData.time_wait, pData.stage_wait = nil, nil, nil
				pData.progresses.wait_1.current = 4
				SetNextStage( player, pData )
			else
				player:ShowError( "Коля ещё не расшифровал данные" )
				return
            end
            
            -- Аналитика
            triggerEvent( "onPlayerHbEvent", player, 4, 0, "soft" )
		end,
    },
    [ "stage_5" ] =
	{
		id = "stage_5",
		start = "client",
		server = function( player, data )
			local pData = player:GetPermanentData( EVENT_NAME )
            SetNextStage( player, pData )
            
            -- Аналитика
            triggerEvent( "onPlayerHbEvent", player, 5, 0, "soft" )
		end,
	},
	[ "stage_6" ] =
	{
		id = "stage_6",
		start = "client",
		server = function( player, data )
            local pData = player:GetPermanentData( EVENT_NAME )
            pData.progresses.hdd_2.current = pData.progresses.hdd_2.current + 1
			SetNextStage( player, pData )

			player:InventoryRemoveItem( IN_HDD )
			player:InventoryAddItem( IN_HDD, nil, 1 )
			
            -- Аналитика
            triggerEvent( "onPlayerHbEvent", player, 6, 0, "soft" )
		end,
	},
	[ "stage_7" ] =
	{
		id = "stage_7",
		start = "client",
		server = function( player, data )
			player:InventoryRemoveItem( IN_HDD )

            local pData = player:GetPermanentData( EVENT_NAME )
			SetNextStage( player, pData )

            -- Аналитика
            triggerEvent( "onPlayerHbEvent", player, 7, 0, "soft" )            
		end,
    },
    [ "stage_8" ] =
	{
		id = "stage_8",
		start = "client",
		server = function( player, data )end,
	},
}

for k, v in pairs( EVENT ) do
    EVENT_COUNT = EVENT_COUNT + 1
end