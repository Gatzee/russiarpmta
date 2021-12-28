local id = "gas45"
local function GetSelf( ) return TASKS_CONFIG[ id ] end

TASKS_CONFIG[ id ] = {
    id = id,
    name = "Заправка на NextRP",
    reward = 3500,

    desc = "Подзаправься в сумме на 45 литров",

    required_liter = 45,

    fns = {
        add_gas_liter = function( liter )

            local self = GetSelf( )
            local data = source:GetPermanentData( "retention_tasks" )
            if not data[ id ] then return end

            data[ id ].liter = ( data[ id ].liter or 0 ) + liter
            
            if data[ id ].liter >= self.required_liter then
                CompleteRetentionTask( source, id )
            else
                source:SetPermanentData( "retention_tasks", data )
            end
        end,
    },

    fn_complete = {
        server = function( self, player, data )
            player:GiveMoney( self.reward, "retention_task", "gas45" )
        end,
        client = function( self, data )
            localPlayer:PhoneNotification( {
                title = "Поздравляем",
                msg = 'Ты выполнил акцию "' .. self.name .. '". Награда: ' .. format_price( self.reward ) .. ' рублей.'
            } )
        end,
    },

    fn_create_slider = function( self, data, parent )
        local liter = ( data.liter or 0 )
        data.progress = liter / self.required_liter
        data.readable_progress = string.format( "%.0f", liter ) .. " / " .. self.required_liter .. " л"
        data.amount = self.reward

        local bg = CreateDataSlider( self, data, parent )
        CreateMoneyReward( self, data, bg )
        return bg
    end,
}
addEvent( "onGasBuy", true )
addEventHandler( "onGasBuy", root, GetSelf( ).fns.add_gas_liter )