
--Количество попыток
ATTEMPTS_NUMBER = nil

--Начальный, конечный порт
PORTS = {}
PORTS.START_PORT = nil
PORTS.END_PORT = nil

--Текущий блок
CURRENT_BLOCK = {}

--Предыдущий блок
PREV_BLOCK = {}

--Состояния всех блоков на доске
BLOCK_STATES = {}

--Использованные блоки
USE_BLOCKS = {}

--Заблокированные линии
BLOCKED_LINES = {}

--Время анимаций "заполнений"
ANIM_PORT_DURATION = 1000
ANIM_HOR_DURATION = 1500
ANIM_VER_DURATION = 2000
ANIM_ROT_DURATION = 150

--Блокировка кликов
prev_click = 0

--Позиции портов по вертикали
PORT_POSITION =
{
    [ 1 ] = 54,
    [ 2 ] = 193,
    [ 3 ] = 332,
}

--Возможные ротации блока
ROTATIONS =
{
    [ 1 ] = 0,
    [ 2 ] = 90,
    [ 3 ] = 180,
    [ 4 ] = 270,
    [ 5 ] = 360,
}

--Значения ротация
ROTATIONS_VALUE =
{
    [ 0   ] = { x =  0, y = -1 };
    [ 90  ] = { x =  1, y =  0 };
    [ 180 ] = { x =  0, y =  1 };
    [ 270 ] = { x = -1, y =  0 };
    [ 360 ] = { x =  0, y = -1 };
}

--Количество собранных деталей
CONST_ASSEMBLY_DETAILS = 0

--Сброс игры
RESET_MINIGAME = true

SHADERS = {}
SHADER_IMG = {}

POPUP_MESSAGES =
{
    [ "OK" ]            = "assets/img/popup_ok.png";
    [ "FAIL" ]          = "assets/img/popup_fail.png";
    [ "FAIL_ATTEMPTS" ] = "assets/img/popup_fail_attempts.png";
}

IS_GAME_ACTIVE = false

function generateMinigameData( reset )
    if not PORTS.START_PORT or not PORTS.END_PORT or reset then
        USE_BLOCKS = {}
        PORTS.START_PORT = math.random(1, 3)
        PORTS.END_PORT = math.random(1, 3)
    end
end

function arrangeItems( parent )

    SHADERS = {}
    SHADER_IMG = {}
    USE_BLOCKS = {}
    UI_elements.rt_popup = ibCreateRenderTarget( 0, 0, 438, 411, parent ):ibData( "priority", 2 )

    if #BLOCK_STATES == 0 or RESET_MINIGAME then
        BLOCK_STATES = nil
        BLOCKED_LINES = nil
        BLOCK_STATES = {}
        BLOCKED_LINES = {}
        for i = 1, 3 do
            BLOCK_STATES[ i ] = {}
            BLOCKED_LINES[ i ] = {}
            for j = 1 , 3 do
                BLOCK_STATES[ i ][ j ] = {}
                BLOCKED_LINES[ i ][ j ] = {}
                BLOCKED_LINES[ i ][ j ] = false
                if RESET_MINIGAME then
                    BLOCK_STATES[ i ][ j ].rotation = ROTATIONS[ math.random( 1, #ROTATIONS ) ]
                end
            end
        end

        --Убираем 1 линию возле конечного порта
        BLOCKED_LINES[ math.random(2, 3) ][ PORTS.START_PORT ] = true


        RESET_MINIGAME = false
    end

    UI_elements.start_port = ibCreateImage( 0, PORT_POSITION[ PORTS.START_PORT ], 24, 25, "assets/img/port.png", parent )
    UI_elements.end_port   = ibCreateImage( 414, PORT_POSITION[ PORTS.END_PORT   ], 24, 25, "assets/img/port.png", parent )
    :ibData( "rotation", 180 )

    UI_elements.start_line = ibCreateImage( 24,  PORT_POSITION[ PORTS.START_PORT ] + 8, 47, 9, "assets/img/port_line.png", parent )
    UI_elements.end_line   = ibCreateImage( 367, PORT_POSITION[ PORTS.END_PORT   ] + 8, 47, 9, "assets/img/port_line.png", parent )

    local px, py = 71, 37
    for i = 1, 3  do
        for j = 1, 3 do
            UI_elements[ "block" .. i .. j ] = ibCreateImage( px, py, 59, 59, "assets/img/block.png", parent )
            :ibData( "rotation", BLOCK_STATES[ i ][ j ].rotation )
            :ibData( "priority", 1 )
            :ibData( "alpha", 200 )
            :ibOnHover( function( )
                UI_elements[ "block" .. i .. j ]:ibAlphaTo( 255 )
            end )
            :ibOnLeave( function( )
                UI_elements[ "block" .. i .. j ]:ibAlphaTo( 200 )
            end )
            :ibOnClick( function( key, state )

                if key ~= "left" or state ~= "up" or getTickCount() < prev_click then return end

                prev_click = getTickCount() + ANIM_ROT_DURATION
                local rotation = UI_elements[ "block" .. i .. j ]:ibData( "rotation" )
                BLOCK_STATES[ i ][ j ].rotation = (rotation + 90) > 360 and 0 or (rotation + 90)

                local cRotation = UI_elements[ "block" .. i .. j ]:ibData("rotation")
                if cRotation == 360 and BLOCK_STATES[ i ][ j ].rotation == 0 then
                    UI_elements[ "block" .. i .. j ]:ibData("rotation", 0)
                    BLOCK_STATES[ i ][ j ].rotation = 90
                end
                UI_elements[ "block" .. i .. j ]
                :ibRotateTo( BLOCK_STATES[ i ][ j ].rotation, ANIM_ROT_DURATION, "Linear" )
                :ibTimer( function( self, rotation )
                    self:ibData( "rotation", rotation )
                end, ANIM_ROT_DURATION, 1, BLOCK_STATES[ i ][ j ].rotation )
                ibClick( )

            end )
            if not BLOCKED_LINES[ i ][ j ] then
                if i < 3 then
                    UI_elements[ "v_line_" .. i .. j ] = ibCreateImage( px + 25, py + 59, 9, 80, "assets/img/v_line.png", parent )
                end
                if j < 3 then
                    UI_elements[ "h_line_" .. i .. j ] = ibCreateImage( px + 59, py + 25, 60, 9, "assets/img/h_line.png", parent )
                end
            else
                UI_elements[ "v_line_" .. i .. j ] = nil
                UI_elements[ "h_line_" .. i .. j ] = nil
            end
            px = px + 119
        end
        py = py + 139
        px = 71
    end

    if ATTEMPTS_NUMBER <= 0 then
        createPoUpMessage( "FAIL_ATTEMPTS" )
    end

end

function playMinigame()

    for i = 1, 3  do
        for j = 1, 3 do
            if UI_elements[ "block" .. i .. j ] then
                UI_elements[ "block" .. i .. j ]:ibData( "disabled", true )
            end
        end
    end

    CURRENT_BLOCK = {}
    CURRENT_BLOCK.x, CURRENT_BLOCK.y = 1, PORTS.START_PORT

    fillTube( UI_elements.start_line )
    UI_elements.start_port:ibTimer( function()
        UI_elements.start_port:ibData( "texture", "assets/img/port_active.png" )

        UI_elements[ "block" .. CURRENT_BLOCK.y .. CURRENT_BLOCK.x ]
        :ibAlphaTo( 255 )
        fillBlock( UI_elements[ "block" .. CURRENT_BLOCK.y .. CURRENT_BLOCK.x ], true )

        UI_elements.end_port:ibTimer( function()
            checkNextPosition( 1, PORTS.START_PORT )
        end, 2200, 1 )
    end, ANIM_PORT_DURATION, 1 )

end

function checkNextPosition( i, j )

    local prevx, prevy = PREV_BLOCK.x, PREV_BLOCK.y
    PREV_BLOCK.x, PREV_BLOCK.y = CURRENT_BLOCK.x, CURRENT_BLOCK.y

    if i == 4 and j == PORTS.END_PORT then
        fillTube( UI_elements.end_line )
        UI_elements.end_line:ibTimer( function()
            UI_elements.end_port:ibData( "texture", "assets/img/port_active.png" )
            createPoUpMessage( "OK" )
        end, ANIM_PORT_DURATION, 1 )
        --iprint("OK")
        return
    elseif not BLOCK_STATES[ j ][ i ] then
        if UI_elements[ "block" .. PREV_BLOCK.y .. PREV_BLOCK.x ] then
            fillBlock( UI_elements[ "block" .. PREV_BLOCK.y .. PREV_BLOCK.x ], false )
        elseif UI_elements[ "block" .. CURRENT_BLOCK.y .. CURRENT_BLOCK.x ]  then
            fillBlock( UI_elements[ "block" .. CURRENT_BLOCK.y .. CURRENT_BLOCK.x ], false )
        end
        createPoUpMessage( "FAIL" )
        --iprint("FAIL_1")
        return
    elseif USE_BLOCKS[ j .. i ] then
        if UI_elements[ "block" .. PREV_BLOCK.y .. PREV_BLOCK.x ] then
            fillBlock( UI_elements[ "block" .. PREV_BLOCK.y .. PREV_BLOCK.x ], false )
        end
        createPoUpMessage( "FAIL" )
        --iprint("FAIL_2")
        return
    end

    USE_BLOCKS[ j .. i ] = true
    --iprint( "JI: ", j, i, BLOCK_STATES[ j ][ i ].rotation )
    local new_position = ROTATIONS_VALUE[ BLOCK_STATES[ j ][ i ].rotation ]
    CURRENT_BLOCK.x, CURRENT_BLOCK.y = CURRENT_BLOCK.x + new_position.x, CURRENT_BLOCK.y + new_position.y

    if CURRENT_BLOCK.x == 0 then
        CURRENT_BLOCK.x = 1
        fillBlock( UI_elements[ "block" .. CURRENT_BLOCK.y .. CURRENT_BLOCK.x ], false )
        createPoUpMessage( "FAIL" )
        --iprint("FAIL_3")
        return
    elseif (prevy == CURRENT_BLOCK.y and prevx == CURRENT_BLOCK.x) 
            or ( (CURRENT_BLOCK.x > 3 or CURRENT_BLOCK.x <= 0 or CURRENT_BLOCK.y > 3 or CURRENT_BLOCK.y <= 0) 
                    and CURRENT_BLOCK.y ~= PORTS.END_PORT and CURRENT_BLOCK.x ~= 4) then
        fillBlock( UI_elements[ "block" .. PREV_BLOCK.y .. PREV_BLOCK.x ], false )
    createPoUpMessage( "FAIL" )
        --iprint("FAIL_4")
        return
    end

    local isAnimation
    --Анимка проводника
    --Горизонтальная
    if CURRENT_BLOCK.x - PREV_BLOCK.x < 0 then
        --Проверка линий на блокировку
        if not UI_elements[ "h_line_" .. CURRENT_BLOCK.y .. CURRENT_BLOCK.x ] then
            fillBlock( UI_elements[ "block" .. PREV_BLOCK.y .. PREV_BLOCK.x ], false )
            createPoUpMessage( "FAIL" )
            return
        end
        fillTube(  UI_elements[ "h_line_" .. CURRENT_BLOCK.y .. CURRENT_BLOCK.x ], "HOR", true )
        isAnimation = "HOR"
    elseif CURRENT_BLOCK.x - PREV_BLOCK.x > 0 and CURRENT_BLOCK.x <= 3 then
        --Проверка линий на блокировку
        if not UI_elements[ "h_line_" .. PREV_BLOCK.y .. PREV_BLOCK.x ] then
            fillBlock( UI_elements[ "block" .. PREV_BLOCK.y .. PREV_BLOCK.x ], false )
            createPoUpMessage( "FAIL" )
            return
        end
        fillTube(  UI_elements[ "h_line_" .. PREV_BLOCK.y .. PREV_BLOCK.x ], "HOR" )
        isAnimation = "HOR"
    end

    --Вертикальная
    if CURRENT_BLOCK.y - PREV_BLOCK.y > 0 then
        --Проверка линий на блокировку
        if not UI_elements[ "v_line_" .. PREV_BLOCK.y .. PREV_BLOCK.x ] then
            fillBlock( UI_elements[ "block" .. PREV_BLOCK.y .. PREV_BLOCK.x ], false )
            createPoUpMessage( "FAIL" )
            --("FAIL_5")
            return
        end
        fillTube(  UI_elements[ "v_line_" .. PREV_BLOCK.y .. PREV_BLOCK.x ], "VER" )
        isAnimation = "VER"
    elseif CURRENT_BLOCK.y - PREV_BLOCK.y < 0 and CURRENT_BLOCK.y < 3 then
        --Проверка линий на блокировку
        if not UI_elements[ "v_line_" .. CURRENT_BLOCK.y .. CURRENT_BLOCK.x ] then
            fillBlock( UI_elements[ "block" .. PREV_BLOCK.y .. PREV_BLOCK.x ], false )
            createPoUpMessage( "FAIL" )
            --iprint("FAIL_6")
            return
        end
        fillTube(  UI_elements[ "v_line_" .. CURRENT_BLOCK.y .. CURRENT_BLOCK.x ], "VER", true )
        isAnimation = "VER"
    end

    UI_elements.end_port:ibTimer( function()
        fillBlock( UI_elements[ "block" .. CURRENT_BLOCK.y .. CURRENT_BLOCK.x ], true )
    end, isAnimation == "HOR" and ANIM_HOR_DURATION or ANIM_VER_DURATION, 1 )

    UI_elements.start_port:ibTimer( function()
        if UI_elements[ "block" .. CURRENT_BLOCK.y .. CURRENT_BLOCK.x ] then
            UI_elements[ "block" .. CURRENT_BLOCK.y .. CURRENT_BLOCK.x ]:ibAlphaTo( 255 )
        end
        checkNextPosition( CURRENT_BLOCK.x, CURRENT_BLOCK.y )
    end, isAnimation == "HOR" and ANIM_HOR_DURATION + 2200 or isAnimation == "VER" and  ANIM_VER_DURATION + 2200 or 50, 1 )
end


function fillTube( tube, type, direction )

    if type == "HOR" then
        if not direction then
            ibCreateImage( 4, 2, 0, 5, _, tube, 0xFF47AFFF )
            :ibResizeTo( tube:ibData("sx") - 8, _,   ANIM_HOR_DURATION, "Linear" )
        else
            tube:ibData( "texture", "assets/img/h_line_hovered.png" )
            ibCreateImage( 4, 2, tube:ibData("sx") - 8, 5, _, tube, 0xFF6C8095 )
            :ibResizeTo( 0, _, ANIM_HOR_DURATION, "Linear" )
        end
    elseif type == "VER" then
        if not direction then
            ibCreateImage( 2, 4, 5, 0, _, tube, 0xFF47AFFF )
            :ibResizeTo( _, tube:ibData( "sy" ) - 8,   ANIM_VER_DURATION, "Linear" )
        else
            tube:ibData( "texture", "assets/img/v_line_hovered.png" )
            ibCreateImage( 2, 4, 5, tube:ibData( "sy" ) - 8, _, tube, 0xFF6C8095 )
            :ibResizeTo( _, 0, ANIM_VER_DURATION, "Linear" )
        end
    else
        ibCreateImage( 4, 2, 0, 5, _, tube, 0xFF47AFFF )
        :ibResizeTo( tube:ibData("sx") - 8, _,   ANIM_PORT_DURATION, "Linear" )
    end

end

function fillBlock( block, success )

    if success and block then
        local texture_path = success and "assets/img/block_active.png" or "assets/img/block_fail.png"
        SHADERS[ block ] = dxCreateShader( "assets/fx/circle.fx" )
        local texture = dxCreateTexture( texture_path )
        dxSetShaderValue( SHADERS[ block ], "tex", texture )
        dxSetShaderValue( SHADERS[ block ], "angle", 270 )
        dxSetShaderValue( SHADERS[ block ], "dg", 0 )
        dxSetShaderValue( SHADERS[ block ], "rgba", 255, 255, 255, 255 )

        local angle = 0
        local rotation = block:ibData( "rotation" )
        SHADER_IMG[ block ] = ibCreateImage( 0, 0, 59, 59, SHADERS[ block ], block ):ibData( "disabled", true )
        :ibData( "rotation", rotation )
        :ibOnRender( function()
            if angle < 2 then
                angle = angle + 0.01
                dxSetShaderValue( SHADERS[ block ], "dg", angle )
            end
        end )
    else
        if SHADERS[ block ] then
            SHADERS[ block ]:destroy()
            SHADER_IMG[ block ]:destroy()
        end
        if block then
            block:ibData( "texture", "assets/img/block_fail.png" )
        end
    end

end

function toggleButtons( state )
    for k in pairs( TABS_CONTAINERS ) do
        UI_elements[ "tab_" .. k ]:ibData( "disabled", state )
    end
    UI_elements.play_button:ibData( "disabled", state )
end

function resetMinigame( parent )

    BLOCK_STATES = nil
    BLOCK_STATES = {}
    RESET_MINIGAME = true

    if ATTEMPTS_NUMBER > 0 then
        if isElement( UI_elements.game_area ) then
            UI_elements.game_area:destroy()
        end

        USE_BLOCKS = nil

        generateMinigameData( true )

        UI_elements.game_area = ibCreateArea( 47, 21, 438, 411, parent )
        local taskInfoText = string.format( "Выстроить электронную цепь, \nвращая компоненты вокруг своей\nоси. Чтобы ток из порта %d достиг\nпорт %d", PORTS.START_PORT, PORTS.END_PORT )
        UI_elements.taskInfo:ibData( "text", taskInfoText )

        arrangeItems( UI_elements.game_area )
        toggleButtons( false )
    else
        createPoUpMessage( "FAIL_ATTEMPTS" )
    end

end

function createPoUpMessage( message )

    local popup = ibCreateImage( 0, 411, 438, 411, POPUP_MESSAGES[ message ], UI_elements.rt_popup )
    :ibData( "priority", 11 )
    if message ~= "OK" then
        onMinigameFailed()
    end

    if ATTEMPTS_NUMBER > 0 then
        if message == "OK" then
            UI_elements.assemblyDetails:ibData( "text", CONST_ASSEMBLY_DETAILS )
            setTimer( function()
                GAME_DATA.success_callback()
                IS_GAME_ACTIVE = false
            end, 800, 1 )
            RESET_MINIGAME = true
        else
            RESET_MINIGAME = true
            IS_GAME_ACTIVE = false
        end
    else
        setTimer( function()
            GAME_DATA.fail_callback()
            IS_GAME_ACTIVE = false
        end, 1000, 1 )
    end

    popup:ibTimer( function( self )
        self:ibMoveTo( _, 0, 300 )
    end, 200, 1 )

end

function onMinigameFailed()
    if isElement( UI_elements[ "attempt_" .. ATTEMPTS_NUMBER ] ) then
        UI_elements[ "attempt_" .. ATTEMPTS_NUMBER ]:destroy()
        ATTEMPTS_NUMBER = ATTEMPTS_NUMBER - 1
    end
end