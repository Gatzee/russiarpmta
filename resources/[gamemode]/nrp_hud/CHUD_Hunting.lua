HUD_CONFIGS.hunting = {
    order = 990,
    elements = { },
    use_real_fonts = true,

    create = function( self )
        local hunting = localPlayer:getData( "hunting" )
        local bg = ibCreateImage( 0, 0, 340, 50, nil, nil, 0xd72a323c )
        self.elements.bg = bg

        ibCreateImage( 8, 6, 40, 40, "img/current_task_icon_small.png", bg )
        ibCreateLabel( 52, 15, 0, 0, "Вы в розыске!", bg, 0xffff965d, nil, nil, "left", "top", ibFonts.semibold_16 )
        ibCreateImage( 233, 16, 16, 18, "img/icon_timer.png", bg )

        local timer = ibCreateLabel( 259, 15, 0, 0, "", bg, 0xffffffff, nil, nil, "left", "top", ibFonts.bold_16 )

        local function updateTimer( )
            local timeLeft = hunting.timeTo - getRealTimestamp( )

            if timeLeft < 0 then
                RemoveHUDBlock( "hunting" )
                return
            end

            local hour = math.floor( timeLeft / 3600 )
            local min = math.floor( ( timeLeft - hour * 3600 ) / 60 )
            local sec = math.floor( timeLeft - hour * 3600 - min * 60 )

            timer:ibData( "text", string.format( "%02d:%02d:%02d", hour, min, sec ) )
        end

        timer:ibTimer( updateTimer, 1000, 0 )
        updateTimer( )

        return bg
    end,

    destroy = function( self )
        DestroyTableElements( { self.elements.bg } )
        self.elements = { }
    end,
}

function updateStateHuntingHUD( value )
    RemoveHUDBlock( "hunting" )

    if not localPlayer:getData( "in_race" ) and type( value ) == "table" and tonumber( value.timeTo ) then
        AddHUDBlock( "hunting" )
    end
end

addEventHandler( "onClientResourceStart", resourceRoot, function ( )
    updateStateHuntingHUD( localPlayer:getData( "hunting" ) )
end )

addEventHandler( "onClientElementDataChange", localPlayer, function ( key, _, value )
    if key ~= "in_race" and key ~= "hunting" then return end
    updateStateHuntingHUD( key == "hunting" and value or localPlayer:getData( "hunting" ) )
end )