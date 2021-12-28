loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "ib" )
ibUseRealFonts( true )


GAME_DATA = nil
UI_elements = {}

CURRENT_TAB_ID = nil
TABS_CONTAINERS =
{
    [ 1 ] =
    {
        text = "Играть",
        content = function()
            return createMainTabView()
        end,
    },
    [ 2 ] =
    {
        text = "Информация",
        content = function()
            return createInfoTabView()
        end,
    }
}

function createAssemblyMinigame( data )

    GAME_DATA = data

    UI_elements.blackBg = ibCreateBackground( 0xBF1D252E, function()
        if GAME_DATA.fail_callback then
            GAME_DATA.fail_callback()
        end 
    end, true, true )
    
    UI_elements.rt  = ibCreateRenderTarget( 0, 0, 800, 580, UI_elements.blackBg ):ibData( "priority", -1 ):center()
    UI_elements.bg_area = ibCreateImage( 0, 0, 800, 580, "assets/img/bg_minigame.png", UI_elements.rt )
    :ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )

    ibCreateButton(	748, 25, 24, 24, UI_elements.bg_area, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        if GAME_DATA.fail_callback then
            GAME_DATA.fail_callback()
        end
        ibClick( )
    end, false )

    UI_elements.assemblyDetails = ibCreateLabel( 754, 86, 0, 0, tostring( CONST_ASSEMBLY_DETAILS ), UI_elements.bg_area, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.regular_14 )

    local px = 31
    for k, v in pairs( TABS_CONTAINERS ) do
        local tabName, tabSizeX = v.text, dxGetTextWidth( v.text, 1, ibFonts.bold_14 )
        UI_elements[ "tab_" .. k ] = ibCreateArea( px, 91, tabSizeX, 25, UI_elements.bg_area )
        UI_elements[ "text_" .. k ] = ibCreateLabel( 0, 0, tabSizeX, 14, v.text, UI_elements[ "tab_" .. k ], 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_14 )
        :ibBatchData({ disabled = true, alpha = 200 })

        UI_elements[ "tab_" .. k ]
        :ibOnHover( function( )
            UI_elements[ "text_" .. k ]:ibAlphaTo( 255 )
        end )
        :ibOnLeave( function( )
            if k ~= CURRENT_TAB_ID then
                UI_elements[ "text_" .. k ]:ibAlphaTo( 200 )
            end
        end )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" or k == CURRENT_TAB_ID then return end
            switchTab( k )
            ibClick( )
        end )

        if not UI_elements.active_line then
            UI_elements.active_line = ibCreateImage( px, 114, tabSizeX, 3, _,  UI_elements.bg_area, 0xFFFF9759 )
        end

        px = px + tabSizeX + 30
    end

    switchTab( 1 )

    showCursor( true )

end

function createNextDetailAssembly()

    UI_elements.assemblyDetails:ibData( "text", CONST_ASSEMBLY_DETAILS )

    local parent = UI_elements.game_area:ibData( "parent" )

    if isElement( UI_elements.game_area ) then
        UI_elements.game_area:destroy()
    end

    BLOCK_STATES = nil
    BLOCK_STATES = {}
    RESET_MINIGAME = true

    USE_BLOCKS = nil

    generateMinigameData( true )

    UI_elements.game_area = ibCreateArea( 47, 21, 438, 411, parent )
    local taskInfoText = string.format( "Выстроить электронную цепь, \nвращая компоненты вокруг своей\nоси. Чтобы ток из порта %d достиг\nпорт %d", PORTS.START_PORT, PORTS.END_PORT )
    UI_elements.taskInfo:ibData( "text", taskInfoText )

    arrangeItems( UI_elements.game_area )
    toggleButtons( false )

end

function destroyMinigame()

    UI_elements.blackBg:destroy()
    showCursor( false )

    CONST_ASSEMBLY_DETAILS = 0
    ATTEMPTS_NUMBER = nil
    START_PORT = nil
    END_PORT = nil

    GAME_DATA = nil

end

function switchTab( f_new_tab_id )

    if TABS_CONTAINERS[ f_new_tab_id ] then

        local animation_duration = 200
        local new_content_area = TABS_CONTAINERS[ f_new_tab_id ].content()

        if isElement( UI_elements.content_area ) then

            new_content_area
            :ibBatchData({ priority = 0, alpha = 0, px = f_new_tab_id > CURRENT_TAB_ID and 100 or -100 })
            :ibAlphaTo( 255, animation_duration )

            -- Анимация появления с правой стороны
            if f_new_tab_id > CURRENT_TAB_ID then
                UI_elements.content_area:ibMoveTo( -100, _, animation_duration ):ibAlphaTo( 0, animation_duration )
                new_content_area:ibMoveTo( 0, _, animation_duration )
            -- Анимация появления с левой стороны
            elseif f_new_tab_id < CURRENT_TAB_ID then
                UI_elements.content_area:ibMoveTo( 100, _, animation_duration ):ibAlphaTo( 0, animation_duration )
                new_content_area:ibMoveTo( 0, _, animation_duration )
            end

            UI_elements.content_area:ibTimer( function( self, old_area )
                if isElement( old_area ) then
                    old_area:destroy()
                end
            end, animation_duration, 1, UI_elements.content_area )

            UI_elements.content_area = new_content_area
        else
            UI_elements.content_area = new_content_area
        end

        CURRENT_TAB_ID = f_new_tab_id

        for key in pairs( TABS_CONTAINERS ) do
            if key ~= CURRENT_TAB_ID then
                UI_elements[ "text_" .. key ]:ibAlphaTo( 200 )
            else
                UI_elements[ "text_" .. key ]:ibAlphaTo( 255 )
            end
        end

        local px = UI_elements[ "tab_" .. CURRENT_TAB_ID ]:ibData( "px" )
        local sx = UI_elements[ "tab_" .. CURRENT_TAB_ID ]:ibData( "sx" )
        UI_elements.active_line:ibMoveTo(   px, _, animation_duration, "Linear" )
        UI_elements.active_line:ibResizeTo( sx, _,   animation_duration, "Linear" )

    end

end