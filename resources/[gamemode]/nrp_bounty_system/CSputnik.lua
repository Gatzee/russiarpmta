local ui = { }
local time = 0
local timerFont = exports.nrp_fonts:DXFont( "Oxanium/Oxanium-Bold.ttf", 20, false, "default" )

function closeMap( )
    if ui.timer then
        ui.timer:destroy( )
        ui = { }

        triggerServerEvent( "updateTargetPositionBySputnik", localPlayer )
    end
end

addEvent( "updateTargetPositionBySputnik", true )
addEventHandler( "updateTargetPositionBySputnik", localPlayer, function ( targetID, x, y, updateTime )
    if not targetID then
        closeMap( )
        return
    end

    time = updateTime
    triggerEvent( "showTargetOnMap", localPlayer, { x = x, y = y } )

    local function updateTick( up )
        if up then time = time - 1 end

        local text = time < 0 and 0 or time
        if text < 10 then text = "00:0" .. text
        else text = "00:" .. text end

        ui.tick:ibData( "text", text )
        ui.tick_shadow:ibData( "text", text )

        if time < 0 then
            triggerServerEvent( "updateTargetPositionBySputnik", localPlayer, targetID )
        end
    end

    if not ui.timer then
        ibUseRealFonts( true )

        ui.timer = ibCreateLabel( 18, _SCREEN_Y /  2 - 30, 0, 0, "Обновление зоны:", nil, 0x88000000, nil, nil, "left", "top", ibFonts.bold_21 )
        :ibData( "priority", 1 )
        ibCreateLabel( - 1, - 1, 0, 0, "Обновление зоны:", ui.timer, 0xffffe2a7, nil, nil, "left", "top", ibFonts.bold_21 )
        ibCreateImage( 0, 31, 30, 32, ":nrp_shared/img/icon_timer.png", ui.timer )
        ui.tick_shadow = ibCreateLabel( 35, 30, 0, 0, time, ui.timer, 0x88000000, nil, nil, "left", "top", timerFont )
        :ibTimer( function ( )
            updateTick( true )
        end, 1000, 0 )
        ui.tick = ibCreateLabel( - 1, - 1, 0, 0, time, ui.tick_shadow, 0xffffffff, nil, nil, "left", "top", timerFont )

        ibUseRealFonts( false )
    end

    updateTick( )
end )

addEvent( "onPlayerUseSputnikChangeState", true )
addEventHandler( "onPlayerUseSputnikChangeState", root, function ( state )
    source:setData( "use_sputnik", state, false )
end )