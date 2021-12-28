local id = "fc5"
local function GetSelf( ) return TASKS_CONFIG[ id ] end

TASKS_CONFIG[ id ] = {
    id = id,
    name = "Бойцовский клуб на NextRP",
    reward = 21000,

    desc = "Участвуй в 5 раундах Бойцовского Клуба",

    required_rounds = 5,

    fns = {
        add_fc_rounds = function( )
            local self = GetSelf( )
            local data = source:GetPermanentData( "retention_tasks" )
            if not data[ id ] then return end

            data[ id ].rounds = ( data[ id ].rounds or 0 ) + 1
            
            if data[ id ].rounds >= self.required_rounds then
                CompleteRetentionTask( source, id )
            else
                source:SetPermanentData( "retention_tasks", data )
            end
        end,
    },

    fn_complete = {
        server = function( self, player, data )
            player:GiveMoney( self.reward, "retention_task", "fc5" )
        end,
        client = function( self, data )
            localPlayer:PhoneNotification( {
                title = "Поздравляем",
                msg = 'Ты выполнил акцию "' .. self.name .. '". Награда: ' .. format_price( self.reward ) .. ' рублей.'
            } )
        end,
    },

    fn_create_slider = function( self, data, parent )
        local rounds = ( data.rounds or 0 )
        data.progress = rounds / self.required_rounds
        data.readable_progress = rounds .. " / " .. self.required_rounds .. " раундов"
        data.amount = self.reward

        local bg = CreateDataSlider( self, data, parent )
        CreateMoneyReward( self, data, bg )
        return bg
    end,
}

addEvent( "FC:OnServerFightFinished", true )
addEventHandler( "FC:OnServerFightFinished", root, GetSelf( ).fns.add_fc_rounds )