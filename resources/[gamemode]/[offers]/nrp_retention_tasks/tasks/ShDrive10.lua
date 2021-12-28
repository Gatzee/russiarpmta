local id = "drive10"
local function GetSelf( ) return TASKS_CONFIG[ id ] end

TASKS_CONFIG[ id ] = {
    id = id,
    name = "Езда на NextRP",
    reward = 50000,

    desc = "Проедь 10 километров на своём автомобиле",

    required_distance = 10000,
    normal_duration = function( ) return 24 * 60 * 60 end,

    fns = {
        ping_drive_rcv = function( distance )
            local self = GetSelf( )
            local data = client:GetPermanentData( "retention_tasks" )

            data[ id ].meters = ( data[ id ].meters or 0 ) + distance
            
            if data[ id ].meters >= self.required_distance then
                CompleteRetentionTask( client, id )
            else
                client:SetPermanentData( "retention_tasks", data )
            end
        end,

        ping_drive = function( )
            local self = GetSelf( )
            if not localPlayer.vehicle or not isElement( localPlayer.vehicle ) or getElementData( localPlayer, "in_race" ) then
                --Vehicle destroyed
                self.fns.stop_drive()
                return
            end
            --iprint( getTickCount( ), "Pinging drive" )
            if self.last_position then
                local added_distance = ( localPlayer.vehicle.position - self.last_position ).length
                if added_distance >= 50 then
                    triggerServerEvent( "onDrive10AddMeters", resourceRoot, added_distance )
                    self.last_position = localPlayer.vehicle.position
                end
            else
                self.last_position = localPlayer.vehicle.position
            end
        end,

        start_drive = function( vehicle, seat )
            local self = GetSelf( )

            self.fns.stop_drive( )

            local vehicle = vehicle or localPlayer.vehicle

            if seat and seat > 0 then return end
            if vehicle:GetID( ) <= 0 then return end
            if IsSpecialVehicle( vehicle.model ) then return end
            if not vehicle:IsOwnedBy( localPlayer ) then return end

            --iprint( getTickCount( ), "Start drive" )
            self.fns.stop_waiting_for_vehicle( )
            self.fns.start_waiting_for_exit( )

            self.fns.ping_drive( )
            self.timer = setTimer( self.fns.ping_drive, 5000, 0 )

            return true
        end,

        stop_drive = function( vehicle, seat )
            local self = GetSelf( )
            --iprint( getTickCount( ), "Stop drive" )
            if isTimer( self.timer ) then killTimer( self.timer ) end
            self.timer = nil
            self.last_position = nil

            self.fns.stop_waiting_for_exit( )
            self.fns.start_waiting_for_vehicle( )
        end,
        
        start_waiting_for_vehicle = function( )
            local self = GetSelf( )
            self.fns.stop_waiting_for_vehicle( )
            --iprint( getTickCount( ), "Start waiting for vehicle" )
            addEventHandler( "onClientPlayerVehicleEnter", localPlayer, self.fns.start_drive )
        end,

        stop_waiting_for_vehicle = function( )
            local self = GetSelf( )
            --iprint( getTickCount( ), "Stop waiting for vehicle" )
            removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, self.fns.start_drive )
        end,

        start_waiting_for_exit = function( )
            local self = GetSelf( )
            --iprint( getTickCount( ), "Start waiting for exit" )
            addEventHandler( "onClientPlayerVehicleExit", localPlayer, self.fns.stop_drive )
        end,

        stop_waiting_for_exit = function( )
            local self = GetSelf( )
            --iprint( getTickCount( ), "Stop waiting for exit" )
            removeEventHandler( "onClientPlayerVehicleExit", localPlayer, self.fns.stop_drive )
        end,
    },

    fn_start = {
        client = function( self, data )
            if not ( localPlayer.vehicle and self.fns.start_drive( ) ) then
                self.fns.start_waiting_for_vehicle( )
            end
        end,
    },

    fn_stop = {
        client = function( self, data )
            if isTimer( self.timer ) then killTimer( self.timer ) end
            self.timer = nil
            self.last_position = nil
            removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, self.fns.start_drive )
            removeEventHandler( "onClientPlayerVehicleExit", localPlayer, self.fns.stop_drive )
        end,
    },

    fn_complete = {
        server = function( self, player, data )
            player:GiveMoney( self.reward, "retention_task", "drive5" )
        end,
        client = function( self, data )
            localPlayer:PhoneNotification( {
                title = "Поздравляем",
                msg = 'Ты выполнил акцию "' .. self.name .. '". Награда: ' .. format_price( self.reward ) .. ' рублей.'
            } )
        end,
    },

    fn_create_slider = function( self, data, parent )
        local meters = ( data.meters or 0 )
        data.progress = meters / self.required_distance
        data.readable_progress = math.floor( meters / 1000 ) .. " / " .. math.floor( self.required_distance / 1000 ) .. " км"
        data.amount = self.reward

        local bg = CreateDataSlider( self, data, parent )
        CreateMoneyReward( self, data, bg )
        return bg
    end,
}

addEvent( "onDrive10AddMeters", true )
addEventHandler( "onDrive10AddMeters", root, GetSelf( ).fns.ping_drive_rcv )