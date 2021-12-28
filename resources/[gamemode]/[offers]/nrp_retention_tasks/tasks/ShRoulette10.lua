local id = "roulette10"
local function GetSelf( ) return TASKS_CONFIG[ id ] end

TASKS_CONFIG[ id ] = {
    id = id,
    name = "Классическая рулетка на NextRP",
    reward = 10500,

    desc = "Сделай 10 ставок в классической рулетке",

    required_game = 10,

    fns = {
        add_game = function( )
            local self = GetSelf( )
            local data = source:GetPermanentData( "retention_tasks" )
            if not data[ id ] then return end

            data[ id ].game = ( data[ id ].game or 0 ) + 1
            
            if data[ id ].game >= self.required_game then
                CompleteRetentionTask( source, id )
            else
                source:SetPermanentData( "retention_tasks", data )
            end
        end,
    },

    fn_complete = {
        server = function( self, player, data )
            player:GiveMoney( self.reward, "retention_task", "roulette10" )
        end,
        client = function( self, data )
            localPlayer:PhoneNotification( {
                title = "Поздравляем",
                msg = 'Ты выполнил акцию "' .. self.name .. '". Награда: ' .. format_price( self.reward ) .. ' рублей.'
            } )
        end,
    },

    fn_create_slider = function( self, data, parent )
        local game = ( data.game or 0 )
        data.progress = game / self.required_game
        data.readable_progress = string.format( "%.0f", game ) .. " / " .. self.required_game .. " ставок"
        data.amount = self.reward

        local bg = CreateDataSlider( self, data, parent )
        CreateMoneyReward( self, data, bg )
        return bg
    end,
}
addEvent( "onRoulettePlay", true )
addEventHandler( "onRoulettePlay", root, GetSelf( ).fns.add_game )