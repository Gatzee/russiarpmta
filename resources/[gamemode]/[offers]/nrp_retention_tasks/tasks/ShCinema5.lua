local id = "cinema5"
local function GetSelf( ) return TASKS_CONFIG[ id ] end

TASKS_CONFIG[ id ] = {
    id = id,
    name = "Кино на NextRP",
    reward = 8750,

    desc = "Запусти ролик более, чем на 5 минут",

    required_duration = 5 * 60,

    fns = {
        add_cinema_seconds = function( cost, duration, is_vip )
            local self = GetSelf( )
            local data = source:GetPermanentData( "retention_tasks" )
            if not data[ id ] then return end

            data[ id ].seconds = ( data[ id ].seconds or 0 ) + duration
            
            if data[ id ].seconds >= self.required_duration then
                CompleteRetentionTask( source, id )
            else
                source:SetPermanentData( "retention_tasks", data )
            end
        end,
    },

    fn_complete = {
        server = function( self, player, data )
            player:GiveMoney( self.reward, "retention_task", "cinema5" )
        end,
        client = function( self, data )
            localPlayer:PhoneNotification( {
                title = "Поздравляем",
                msg = 'Ты выполнил акцию "' .. self.name .. '". Награда: ' .. format_price( self.reward ) .. ' рублей.'
            } )
        end,
    },

    fn_create_slider = function( self, data, parent )
        local seconds = ( data.seconds or 0 )
        data.progress = seconds / self.required_duration
        data.readable_progress = math.floor( seconds / 60 ) .. " / " .. self.required_duration / 60 .. " минут"
        data.amount = self.reward

        local bg = CreateDataSlider( self, data, parent )
        CreateMoneyReward( self, data, bg )
        return bg
    end,
}

addEvent( "onCinemaVideoStart", true )
addEventHandler( "onCinemaVideoStart", root, GetSelf( ).fns.add_cinema_seconds )