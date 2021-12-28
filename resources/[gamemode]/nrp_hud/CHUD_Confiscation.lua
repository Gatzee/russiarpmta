HUD_CONFIGS.vehicle_confiscation = {
    elements = { },
    order = 997,
    create = function( self, data )
        local bg = ibCreateImage( 0, 0, 340, 80, "img/bg_vehicle_discount.png", bg )
        self.elements.bg = bg

        local positions = {
            { 33, 40 },
            { 62, 40 },
            { 84, 38 },
            { 108, 40 },
            { 136, 40 },
        }

        for i, v in pairs( positions ) do
            local lbl = ibCreateLabel( v[ 1 ], v[ 2 ], 0, 0, "", bg, 0xffffffff, _, _, "center", "center", ibFonts.regular_26 )
            self.elements[ "lbl_symbol_" .. i ] = lbl
        end

        local label_discount = ibCreateLabel( 170, 30, 0, 0, "Конфискация", bg, 0xFFff2f2f, _, _, "left", "center", ibFonts.bold_16 )
        local label_vehicle_name = ibCreateLabel( 170, 55, 0, 0, VEHICLE_CONFIG[ data.vehicle.model ].model , bg, 0xFFffffff, _, _, "left", "center", ibFonts.regular_12 )

        local time_left = data.time

        function UpdateTimer( )
            time_left = time_left - 1

            if time_left <= 0 then
                RemoveHUDBlock( "vehicle_confiscation" )
                return
            end

            local minutes = math.floor( time_left / 60 )
            local seconds = time_left - 60*minutes
            minutes = string.format( "%02d", minutes )
            seconds = string.format( "%02d", seconds )

            local str = minutes .. ":" .. seconds
            for i = 1, #positions do
                local symbol = utf8.sub( str, i, i )
                self.elements[ "lbl_symbol_" .. i ]:ibData( "text", symbol )
            end
        end

        self.elements.timer = setTimer( UpdateTimer, 1000, 0 )
        UpdateTimer( )

        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}

function ShowConfiscationUI( data )
    AddHUDBlock( "vehicle_confiscation", data )
end
addEvent("ShowConfiscationUI", true)
addEventHandler("ShowConfiscationUI", root, ShowConfiscationUI)

function HideConfiscationUI()
    RemoveHUDBlock( "vehicle_confiscation" )
end
addEvent("HideConfiscationUI", true)
addEventHandler("HideConfiscationUI", root, HideConfiscationUI)