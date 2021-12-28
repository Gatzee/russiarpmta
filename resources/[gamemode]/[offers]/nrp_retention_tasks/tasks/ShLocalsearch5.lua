local id = "localsearch5"
local function GetSelf( ) return TASKS_CONFIG[ id ] end

TASKS_CONFIG[ id ] = {
    id = id,
    name = "Местный поиск на NextRP",
    reward_name = "Топливная система",
    reward_img = {
        name = "localsearch5_reward",
        sx = 235,
        sy = 50,
    },


    desc = "Отвези мусор на свалку 5 раз в работе мусорщика",

    required_trash = 5,

    fns = {
        add_trash = function( )
            local self = GetSelf( )
            local data = source:GetPermanentData( "retention_tasks" )
            if not data[ id ] then return end

            data[ id ].trash = ( data[ id ].trash or 0 ) + 1
            
            if data[ id ].trash >= self.required_trash then
                CompleteRetentionTask( source, id )
            else
                source:SetPermanentData( "retention_tasks", data )
            end
        end,
    },

    fn_complete = {
        server = function( self, player, data )
            exports.nrp_assembly_vehicle:GiveAssemblyVehicleDetail( "task", player )
        end,
        client = function( self, data )
            localPlayer:PhoneNotification( {
                title = "Поздравляем",
                msg = 'Ты выполнил акцию "' .. self.name .. '". Награда: ' .. format_price( self.reward ) .. ' рублей.'
            } )
        end,
    },

    fn_create_slider = function( self, data, parent )
        local trash = ( data.trash or 0 )

        data.progress = trash / self.required_trash
        data.readable_progress = string.format( "%.0f", trash ) .. " / " .. self.required_trash
        data.reward_name = self.reward_name

        local bg = CreateDataSlider( self, data, parent )
        return bg
    end,
}
addEvent( "onTrashManEndLoop", true )
addEventHandler( "onTrashManEndLoop", root, GetSelf( ).fns.add_trash )