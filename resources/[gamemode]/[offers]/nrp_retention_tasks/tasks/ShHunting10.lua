local id = "hunting10"
local function GetSelf( ) return TASKS_CONFIG[ id ] end

TASKS_CONFIG[ id ] = {
    id = id,
    name = "Охота на NextRP",
    reward = 7000,

    desc = "Продай 10 кг шкур и мяса",

    required_weight = 10,

    fns = {
        add_treasure_weight = function( hobby, weight )
            if hobby ~= 2 then return end

            local self = GetSelf( )
            local data = source:GetPermanentData( "retention_tasks" )
            if not data[ id ] then return end

            data[ id ].weight = ( data[ id ].weight or 0 ) + weight
            
            if data[ id ].weight >= self.required_weight then
                CompleteRetentionTask( source, id )
            else
                source:SetPermanentData( "retention_tasks", data )
            end
        end,
    },

    fn_complete = {
        server = function( self, player, data )
            player:GiveMoney( self.reward, "retention_task", "hunting10" )
        end,
        client = function( self, data )
            localPlayer:PhoneNotification( {
                title = "Поздравляем",
                msg = 'Ты выполнил акцию "' .. self.name .. '". Награда: ' .. format_price( self.reward ) .. ' рублей.'
            } )
        end,
    },

    fn_create_slider = function( self, data, parent )
        local weight = ( data.weight or 0 )
        data.progress = weight / self.required_weight
        data.readable_progress = math.floor( weight * 10 ) / 10 .. " / " .. self.required_weight .. " кг"
        data.amount = self.reward

        local bg = CreateDataSlider( self, data, parent )
        CreateMoneyReward( self, data, bg )
        return bg
    end,
}
addEvent( "HB:OnPlayerSellItems", true )
addEventHandler( "HB:OnPlayerSellItems", root, GetSelf( ).fns.add_treasure_weight )