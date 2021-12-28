loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ib" )
Extend( "CUI" )
Extend( "CActionTasksUtils" )

local scX, scY = guiGetScreenSize()
local UI_elements = nil
local TIMEOUT = 1050
local HIDE_HUD_COMPONENTS = { "main", "notifications", "daily_quest", "factionradio", "cases_discounts", "quest", "ksusha", "wanted", "radar", "vehicle",
                              "hints", "nodamage", "hunting", "treating_timer", "weapons", "incasator", "trashman", "coop_quest", "offers", "offer_ingame_draw", "7cases", "split_offer", "businesses", }

local cancel_keys = { [ "q" ] = true, [ "e" ] = true, [ "w" ] = true, [ "a" ] = true, [ "s" ] = true, [ "d" ] = true, [ "f" ] = true }

local all_controls = { "fire", "aim_weapon", "next_weapon", "previous_weapon", "forwards", "backwards", "left", "right", "zoom_in", "zoom_out",
    "change_camera", "jump", "sprint", "look_behind", "crouch", "action", "walk", "conversation_yes", "conversation_no",
    "group_control_forwards", "group_control_back", "enter_exit", "vehicle_fire", "vehicle_secondary_fire", "vehicle_left", "vehicle_right",
    "steer_forward", "steer_back", "accelerate", "brake_reverse", "radio_next", "radio_previous", "radio_user_track_skip", "horn",
    "handbrake", "vehicle_look_left", "vehicle_look_right", "vehicle_look_behind", "vehicle_mouse_look", "special_control_left", "special_control_right",
    "special_control_down", "special_control_up", "enter_passenger", "screenshot", "chatbox", }

function onClientShowMenuPhotoMode_handler()
    ShowPhotoModeMenu( true )
    triggerServerEvent( "OnServerPlayerOpenPhotoMode", localPlayer )
end
addEvent( "onClientShowMenuPhotoMode", true )
addEventHandler( "onClientShowMenuPhotoMode", root, onClientShowMenuPhotoMode_handler )

function onClientHideMenuPhotoMode_handler()
    if UI_elements then
        ShowPhotoModeMenu( false )
    end
end
addEvent( "onClientHideMenuPhotoMode", true )
addEventHandler( "onClientHideMenuPhotoMode", root, onClientHideMenuPhotoMode_handler )

function IsCanOpenPhotoMode()
    return true
end

function ShowPhotoModeMenu( state )
    if state and IsCanOpenPhotoMode() then
        UI_elements = 
        {
            controls_state = {},
        }

        ibAutoclose( )

        UI_elements.black_bg = ibCreateBackground( 0x00000000, OnTryLeave, true, true )
        UI_elements.bg = ibCreateImage( 0, scY - 93, 1125, 93, "files/img/bg.png", UI_elements.black_bg ):center_x()

        UI_elements.lid = CreateEyeLid( )
        UI_elements.camera_frozen = false
        UI_elements.timeout = getTickCount()

        bindKey( "f", "down", FrozenCamera )
        UI_elements.can_create_screenshot = true

        UI_elements.frozen_state = isElementFrozen( localPlayer.vehicle and localPlayer.vehicle or localPlayer )
        setElementFrozen( localPlayer.vehicle and localPlayer.vehicle or localPlayer, true )
        setFreecamEnabled( localPlayer.position )
        
        for k, v in pairs( all_controls ) do
            UI_elements.controls_state[ v ] = isControlEnabled( v )
        end
        toggleAllControls( false )
        toggleControl( "enter_passenger", true )
        toggleControl( "screenshot", true )
        toggleControl( "chatbox", true )

        addEventHandler( "onClientKey", root, onClientKey_handler )
        addEventHandler( "onClientPlayerWasted", localPlayer, onClientPlayerWasted_handler )
        
        triggerEvent( "onClientHideHudComponents", resourceRoot, HIDE_HUD_COMPONENTS, true )
        triggerEvent( "onClientSetChatState", resourceRoot, false )
        triggerEvent( "DisableGPS", resourceRoot )
        triggerEvent( "onClientShowForbiddenParkingIcon", resourceRoot, false )
        triggerEvent( "onClientShowFps", resourceRoot, false )
        triggerEvent( "onClientHideMemoryBox", resourceRoot )
        triggerEvent( "ShowInventoryHotbar", localPlayer, false )

        triggerEvent( "onClientChangeInterfaceState", root, true, { photo_mode = true } )

        localPlayer:setData( "photo_mode", true, false )
        setFreecamFrozen( false)
    else
        toggleAllControls( true, false, true )
        for k, v in pairs( UI_elements.controls_state ) do
            if v then toggleControl( k, v) end
        end

        if not localPlayer:getData( "is_frozen_by_admin" ) then
            setElementFrozen( localPlayer.vehicle and localPlayer.vehicle or localPlayer, UI_elements.frozen_state )
        end

        setFreecamDisabled( )

        DestroyTableElements( UI_elements )
        UI_elements = nil
        
        unbindKey( "f", "down", FrozenCamera )

        removeEventHandler( "onClientKey", root, onClientKey_handler )
        removeEventHandler( "onClientPlayerWasted", localPlayer, onClientPlayerWasted_handler )
        
        triggerEvent( "onClientHideHudComponents", resourceRoot, HIDE_HUD_COMPONENTS, false )
        triggerEvent( "onClientSetChatState", resourceRoot, true )
        triggerEvent( "onClientShowForbiddenParkingIcon", resourceRoot, true )
        triggerEvent( "onClientShowFps", resourceRoot, true )
        triggerEvent( "ShowInventoryHotbar", localPlayer, true )
        
        triggerEvent( "onClientChangeInterfaceState", root, false, { photo_mode = true } )

        localPlayer:setData( "photo_mode", false, false )
    end
end

function onClientPlayerWasted_handler()
    ShowPhotoModeMenu( false )
end

function CreateScreenshot()
    local ticks = getTickCount() 
    if ticks < UI_elements.timeout then return end
    UI_elements.timeout = ticks + TIMEOUT
    
    UI_elements.bg:ibData( "alpha", 0 )
    setTimer( function()
        takeScreenShot()

        UI_elements.lid:close( 250, function( ) fadeCamera( false, 0.0 ) end )
        setTimer( function()
            UI_elements.bg:ibData( "alpha", 255 )
            fadeCamera( true, 0.0 )
            UI_elements.lid:open( 250 )
        end, 250, 1 )

        local sound = playSound( "files/fx/took_photo.mp3" )
        setSoundVolume( sound, 0.25 )

        triggerServerEvent( "OnServerPlayerTookPhoto", localPlayer )
    end, 50, 1 )
end

function FrozenCamera()
    UI_elements.camera_frozen = not UI_elements.camera_frozen
    setFreecamFrozen( UI_elements.camera_frozen )
end

function OnTryLeave()
    showCursor( true )
    setCursorAlpha( 255 )
    if UI_elements.confirmation then UI_elements.confirmation:destroy() end
    UI_elements.can_create_screenshot = false
    UI_elements.confirmation = ibConfirm( {
        title = "ВЫХОД ИЗ ФОТОРЕЖИМА", 
        text = "Все сделанные снимки находятся\nв корневой папке c игрой screenshots.\nВы желаете выйти из фоторежима?",
        fn = function( self ) 
            self:destroy()
            showCursor( false )
            if localPlayer:getData( "bFirstPerson" ) then setCursorAlpha( 0 ) end
            ShowPhotoModeMenu()
        end,
        fn_cancel = function( )
            UI_elements.can_create_screenshot = true
            if localPlayer:getData( "bFirstPerson" ) then setCursorAlpha( 0 ) end
            showCursor( false )
        end,
        priority = 100,
    } )
end

function onClientKey_handler( key, press )
    if not press then return end 
    if not cancel_keys[ key ] then
        cancelEvent()
    end
    if key == "escape" then
        OnTryLeave()
    elseif key == "mouse1" and UI_elements and UI_elements.can_create_screenshot then
        CreateScreenshot()
    end
end
