local id = "run3"
local function GetSelf( ) return TASKS_CONFIG[ id ] end

TASKS_CONFIG[ id ] = {
    id = id,
    name = "Бег на NextRP",
    reward = 4375,

    desc = "Пробеги 3 километров",

    required_distance = 3000,
    normal_duration = function( ) return 24 * 60 * 60 end,

    fns = {
        ping_run_rcv = function( distance )
            local self = GetSelf( )
            local data = client:GetPermanentData( "retention_tasks" )
            if not data then
                data = {}
            end
            if not data[ id ] then
                data[ id ] = {
                    meters = distance,
                };
            else
                data[ id ].meters = ( data[ id ].meters or 0 ) + distance
            end
            
            if data[ id ].meters >= self.required_distance then
                CompleteRetentionTask( client, id )
            else
                client:SetPermanentData( "retention_tasks", data )
            end
        end,

        ping_run = function( )
            if localPlayer.vehicle then return end
            if localPlayer:IsInOrAroundWater( ) then return end
            if not isPedOnGround( localPlayer ) then return end

            local self = GetSelf( )
            if self.last_position then
                local added_distance = ( localPlayer.position - self.last_position ).length
                if added_distance >= 5 then
                    if added_distance >= 20 then
                        self.last_position = localPlayer.position
                    else
                        triggerServerEvent( "onRun5AddMeters", resourceRoot, added_distance )
                        self.last_position = localPlayer.position
                    end
                end
            else
                self.last_position = localPlayer.position
            end
        end,

        start_run = function( vehicle, seat )
            local self = GetSelf( )

            self.fns.ping_run( )
            self.timer = setTimer( self.fns.ping_run, 2500, 0 )

            return true
        end,

        stop_run = function( vehicle, seat )
            local self = GetSelf( )
            if isTimer( self.timer ) then killTimer( self.timer ) end
            self.timer = nil
            self.last_position = nil
        end,
    },

    fn_start = {
        client = function( self, data )
            self.fns.start_run( )
        end,
    },

    fn_stop = {
        client = function( self, data )
            if isTimer( self.timer ) then killTimer( self.timer ) end
            self.timer = nil
            self.last_position = nil
        end,
    },

    fn_complete = {
        server = function( self, player, data )
            player:GiveMoney( self.reward, "retention_task", "run5" )
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

addEvent( "onRun5AddMeters", true )
addEventHandler( "onRun5AddMeters", root, GetSelf( ).fns.ping_run_rcv )