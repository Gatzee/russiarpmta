-------------------------------
------- Таймер действий -------
-------------------------------

PROGRESSBAR_CONF    = { px = 28, py = 55, sx = 152, sy = 16, color = 0xffe02929, bg_color = 0x55e02929 }
ICON_CONF           = { image = "img/icon_timer.png", px = 0, py = 55, sx = 24, sy = 24 }

function DestroyTimer( )
    if isElement( UI_elements.img_icon ) then destroyElement( UI_elements.img_icon ) end
    if isElement( UI_elements.progressbar_bg ) then destroyElement( UI_elements.progressbar_bg ) end
    if isElement( UI_elements.progressbar_img ) then destroyElement( UI_elements.progressbar_img ) end
end

function CreateTimer( px, py, duration )
    DestroyTimer( )

    if not isElement( UI_elements.bg ) then return end

    if px and py and duration then
        
        local img_icon  = ibCreateImage( px + ICON_CONF.px, py + ICON_CONF.py, ICON_CONF.sx, ICON_CONF.sy, ICON_CONF.image, UI_elements.bg )

        local progressbar_bg    = ibCreateImage( px + PROGRESSBAR_CONF.px, py + PROGRESSBAR_CONF.py, PROGRESSBAR_CONF.sx, ICON_CONF.sy, nil, UI_elements.bg, PROGRESSBAR_CONF.bg_color )
        local progressbar_img   = ibCreateImage( px + PROGRESSBAR_CONF.px, py + PROGRESSBAR_CONF.py, PROGRESSBAR_CONF.sx, ICON_CONF.sy, nil, UI_elements.bg, PROGRESSBAR_CONF.color )
        progressbar_img:ibResizeTo( 0, ICON_CONF.sy, duration * 1000, "Linear" )
        
        UI_elements.img_icon        = img_icon
        UI_elements.progressbar_bg  = progressbar_bg 
        UI_elements.progressbar_img = progressbar_img
    end
end

function onCasinoGameFoolTimerStart_handler( duration )
    onCasinoGameFoolTimerStop_handler( )

    --iprint( "timer start", duration )
    for i, v in pairs( PLAYERS_DATA ) do
        if v.task == CASINO_TASK_PLAYING or v.task == CASINO_TASK_ADDING then
            
            if isElement( v.img_box ) and v.img_box:isib() then
                local px, py = v.img_box:ibData( "px" ), v.img_box:ibData( "py" )
                --iprint( v.player, "creating", px, py )
                CreateTimer( px, py, duration )
            end

        end
    end
end
addEvent( "onCasinoGameFoolTimerStart", true )
addEventHandler( "onCasinoGameFoolTimerStart", root, onCasinoGameFoolTimerStart_handler )

function onCasinoGameFoolTimerStop_handler( )
    --iprint( "timer stop" )
    DestroyTimer( )
end
addEvent( "onCasinoGameFoolTimerStop", true )
addEventHandler( "onCasinoGameFoolTimerStop", root, onCasinoGameFoolTimerStop_handler )

function onCasinoGameFoolTimerReset_handler( duration )
    onCasinoGameFoolTimerStart_handler( duration )
end
addEvent( "onCasinoGameFoolTimerReset", true )
addEventHandler( "onCasinoGameFoolTimerReset", root, onCasinoGameFoolTimerReset_handler )