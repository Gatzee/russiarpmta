local id = "race5"
local function GetSelf( ) return TASKS_CONFIG[ id ] end

TASKS_CONFIG[ id ] = {
    id = id,
    name = "Гонки на NextRP",
    reward = 21000,

    desc = "Участвуй в 5 гонках",

    required_races = 5,

    fns = {
        add_race_finish = function( )
            local self = GetSelf( )
            local data = source:GetPermanentData( "retention_tasks" )
            if not data[ id ] then return end

            data[ id ].races = ( data[ id ].races or 0 ) + 1
            
            if data[ id ].races >= self.required_races then
                CompleteRetentionTask( source, id )
            else
                source:SetPermanentData( "retention_tasks", data )
            end
        end,
    },

    fn_complete = {
        server = function( self, player, data )
            player:GiveMoney( self.reward, "retention_task", "race5" )
        end,
        client = function( self, data )
            localPlayer:PhoneNotification( {
                title = "Поздравляем",
                msg = 'Ты выполнил акцию "' .. self.name .. '". Награда: ' .. format_price( self.reward ) .. ' рублей.'
            } )
        end,
    },

    fn_create_slider = function( self, data, parent )
        local races = ( data.races or 0 )
        data.progress = races / self.required_races
        data.readable_progress = races .. " / " .. self.required_races .. " гонок"
        data.amount = self.reward

        local bg = CreateDataSlider( self, data, parent )
        CreateMoneyReward( self, data, bg )
        return bg
    end,
}

addEvent( "onRaceAnyFinish", true )
addEventHandler( "onRaceAnyFinish", root, GetSelf( ).fns.add_race_finish )