

VSController =
{
    station_data = {},
    -- Получить свободное id для общения
    GetFreeStationId = function( self )
        local station_id = nil

	    for i = os.time( ), math.huge do
	    	if not STATION_DATA[ i ] then
	    		station_id = i
	    		break
	    	end
	    end

	    return station_id
    end,

    -- Создать голосовой канал
    CreateStation = function( self, station_id, owner, channel_name, subscribers  )
        local station_id = station_id or self:GetFreeStationId()
        if self.station_data[ station_id ] then return end

        self.station_data[ station_id ] = 
        {
            owner = owner,
            channel_name = channel_name,
            subscribers = subscribers,
        }

        for k, v in pairs( self.station_data[ station_id ].subscribers ) do
            v:AddVoiceStation( station_id )
        end

        triggerClientEvent( subscribers, "onClientAddStationChannel", root, { station_id = station_id, channel_name = channel_name } )

        return self.station_data[ station_id ]
    end,

    -- Уничтожить голосовой канал
    DestroyStation = function( self, station_id )
        if not self.station_data[ station_id ] then return end
        for k, v in pairs( self.station_data[ station_id ].subscribers ) do
            v:RemoveVoiceStation( station_id )
        end

        triggerClientEvent( self.station_data[ station_id ].subscribers, "onClientRemoveStationChannel", root, { station_id = station_id } )
        self.station_data[ station_id ] = nil
    end,

    
    -- Если слушатель уже существует
    IsSubscriberExists = function( self, station_id, subscriber )
        for k, v in pairs( self.station_data[ station_id ].subscribers ) do
            if v == subscriber then
                return true
            end
        end
        return false
    end,

    -- Добавить слушателя
    AddSubscriber = function( self, station_id, subscriber )
        if not self.station_data[ station_id ] or self:IsSubscriberExists( station_id, subscriber ) then return end
        v:AddVoiceStation( station_id )

        table.insert( self.station_data[ station_id ].subscribers, subscriber )
        triggerClientEvent( subscriber, "onClientAddStationChannel", root, { station_id = station_id, channel_name = self.station_data[ station_id ].channel_name } )
        
        return true
    end,
    
    -- Удалить слушателя
    RemoveSubscriber = function( self, station_id, subscriber )
        if not self.station_data[ station_id ] or not self:IsSubscriberExists( station_id, subscriber ) then return end
        
        for k, v in pairs( self.station_data[ station_id ].subscribers ) do
            if v == subscriber then
                v:RemoveVoiceStation( station_id )
                table.remove( self.station_data[ station_id ].subscribers, k )
            end
        end

        if #self.station_data[ station_id ].subscribers == 0 then
            self:DestroyStation( station_id )
        else
            triggerClientEvent( subscriber, "onClientRemoveStationChannel", root, { station_id = station_id } )
        end

        return true
    end,
}