local id = "pharmacy5"
local function GetSelf( ) return TASKS_CONFIG[ id ] end

TASKS_CONFIG[ id ] = {
    id = id,
    name = "Аптека на NextRP",
    reward = 3500,

    desc = "Вылечись лекарствами из аптеки 5 раз",

    required_firstaid = 5,

    fns = {
        add_firstaid_use = function( )

            local self = GetSelf( )
            local data = source:GetPermanentData( "retention_tasks" )
            if not data[ id ] then return end

            data[ id ].firstaid = ( data[ id ].firstaid or 0 ) + 1
            
            if data[ id ].firstaid >= self.required_firstaid then
                CompleteRetentionTask( source, id )
            else
                source:SetPermanentData( "retention_tasks", data )
            end
        end,
    },

    fn_complete = {
        server = function( self, player, data )
            player:GiveMoney( self.reward, "retention_task", "pharmacy5" )
        end,
        client = function( self, data )
            localPlayer:PhoneNotification( {
                title = "Поздравляем",
                msg = 'Ты выполнил акцию "' .. self.name .. '". Награда: ' .. format_price( self.reward ) .. ' рублей.'
            } )
        end,
    },

    fn_create_slider = function( self, data, parent )
        local firstaid = ( data.firstaid or 0 )
        data.progress = firstaid / self.required_firstaid
        data.readable_progress = string.format( "%.0f", firstaid ) .. " / " .. self.required_firstaid
        data.amount = self.reward

        local bg = CreateDataSlider( self, data, parent )
        CreateMoneyReward( self, data, bg )
        return bg
    end,
}
addEvent( "onFirstaidUse", true )
addEventHandler( "onFirstaidUse", root, GetSelf( ).fns.add_firstaid_use )