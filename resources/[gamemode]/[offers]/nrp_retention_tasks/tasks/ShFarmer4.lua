local id = "farmer4"
local function GetSelf( ) return TASKS_CONFIG[ id ] end

TASKS_CONFIG[ id ] = {
    id = id,
    name = "Фермер на NextRP",
    reward = 8400,

    desc = "Отработай 4 часов фермером",

    pulse_frequency = 60,
    required_time = 4 * 60 * 60,
    normal_duration = function( ) return 24 * 60 * 60 end,

    required_job = JOB_CLASS_FARMER,

    timers = { },

    fns = {
        ping_pulse = function( player )
            local self = GetSelf( )

			if not isElement( player ) then
				self.fns.stop_pulse( player )
				return
			end

            if player:GetJobClass( ) ~= self.required_job then return end
            if not player:GetOnShift( ) then return end

            local data = player:GetPermanentData( "retention_tasks" )
            data[ id ].current_time = ( data[ id ].current_time or 0 ) + self.pulse_frequency
            if data[ id ].current_time >= self.required_time then
                CompleteRetentionTask( player, id )
            else
                player:SetPermanentData( "retention_tasks", data )
            end
        end,

        start_pulse = function( player )
            local self = GetSelf( )

            self.timers[ player ] = setTimer( self.fns.ping_pulse, self.pulse_frequency * 1000, 0, player )
            return true
        end,

        stop_pulse = function( player )
            local self = GetSelf( )
            if isTimer( self.timers[ player ] ) then killTimer( self.timers[ player ] ) end
            self.timers[ player ] = nil
        end,
    },

    fn_start = {
        server = function( self, player, data )
            self.fns.start_pulse( player )
        end,
    },

    fn_stop = {
        server = function( self, player, data )
             self.fns.stop_pulse( player )
        end,
    },

    fn_complete = {
        server = function( self, player, data )
            player:GiveMoney( self.reward, "retention_task", "farmer4" )
        end,
        client = function( self, data )
            localPlayer:PhoneNotification( {
                title = "Поздравляем",
                msg = 'Ты выполнил акцию "' .. self.name .. '". Награда: ' .. format_price( self.reward ) .. ' рублей.'
            } )
        end,
    },

    fn_create_slider = function( self, data, parent )
        local current_time = ( data.current_time or 0 )
        data.progress = current_time / self.required_time
        data.readable_progress = math.floor( current_time / 60 / 60 ) .. " / " .. self.required_time / 60 / 60 .. " ч."
        data.amount = self.reward

        local bg = CreateDataSlider( self, data, parent )
        CreateMoneyReward( self, data, bg )
        return bg
    end,
}