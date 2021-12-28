loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShUtils" )
Extend( "CPlayer" )
Extend( "ib" )

SHADER_CODE = [[
    texture ScreenTexture;
    sampler implicitInputTexture = sampler_state
    {
        Texture = <ScreenTexture>;
    };
    
    texture MaskTexture;
    sampler implicitMaskTexture = sampler_state
    {
        Texture = <MaskTexture>;
    };
    
    
    float4 MaskTextureMain( float2 uv : TEXCOORD0 ) : COLOR0
    {
        
        float4 sampledTexture = tex2D( implicitInputTexture, uv );
        float4 maskSampled = tex2D( implicitMaskTexture, uv );
        sampledTexture.a *= (maskSampled.r + maskSampled.g + maskSampled.b) / 3.0f;
        return sampledTexture;
    }
    
    technique Technique1
    {
        pass Pass1
        {
            AlphaBlendEnable = true;
            SrcBlend = SrcAlpha;
            DestBlend = InvSrcAlpha;
            PixelShader = compile ps_2_0 MaskTextureMain();
        }
    }
]]

UI_elements = { }

EDITING = false

ACTIONS = {
    "Достал оружие",
    "Запросил документы",
    "Поприветствовал",
    "Передаёт поздравление с Новым Годом!",
    "Достал бумажник",
    "Обернулся по сторонам",
    "Дал взятку",
    "Поблагодарил",
    "Почавкал",
    "Улыбнулся",
    "Посмеялся",
    "Порофлил",
    "Обрадовался",
    "Огорчился",
}

local file_path = "actions.nrp"
if fileExists( file_path ) then
    local file = fileOpen( file_path )
    if file then
        local file_contents = fileRead( file, fileGetSize( file ) )
        ACTIONS = file_contents and fromJSON( file_contents ) or ACTIONS
        fileClose( file )
    end
end

local NUMBER_OF_SECTIONS = 3
local CURRENT_OFFSET = 0


function ShowUISmartwatch( state )

    if state then
        ShowUISmartwatch( false )

        x, y = guiGetScreenSize()

        coeff = 0.75

        sx, sy = math.floor( 267 * coeff ),    math.floor( 480 * coeff )
        px, py = math.floor( ( x - sx ) / 2 ), math.floor( ( y - sy ) / 2 )

        ax , ay  = math.floor( 11 / 0.6 * coeff ),  math.floor( 90 / 0.6 * coeff )
        asx, asy = math.floor( 132 / 0.6 * coeff ), math.floor( 130 / 0.6 * coeff )

        UI_elements.middle_texture = dxCreateTexture( "img/middle.png" )
        UI_elements.delete_texture = dxCreateTexture( "img/delete.png" )

        UI_elements.RT_INNER     = dxCreateRenderTarget( asx, asy, true )
        UI_elements.mask_texture = dxCreateTexture( "img/mask.png", "argb", true, "clamp" )
        UI_elements.SH_MASK      = dxCreateShader( SHADER_CODE )
        dxSetShaderValue( UI_elements.SH_MASK, "ScreenTexture", UI_elements.RT_INNER )
        dxSetShaderValue( UI_elements.SH_MASK, "MaskTexture", UI_elements.mask_texture )

        UI_elements.bg = ibCreateImage( px, py, sx, sy, "img/bg.png" ):ibData( "priority", 10 )
        
        local size = 32 * coeff
        UI_elements.add = ibCreateButton( ax + 130, ay - 25, size, size, UI_elements.bg,
  "img/btn_add.png", "img/btn_add_active.png", "img/btn_add_active.png",
  0xFFFFFFFF, 0xFFffffff, 0xFFeeeeee )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "down" then return end
            ShowEditUI( not EDITING, "add" )
        end )

        local sizex, sizey = 140 * coeff, 32 * coeff
        UI_elements.edit = ibCreateButton( ax + 15, ay - 25, sizex, sizey, UI_elements.bg,
   "img/btn_edit.png", "img/btn_edit_active.png", "img/btn_edit_active.png",
   0xFFFFFFFF, 0xFFffffff, 0xFFeeeeee )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "down" then return end
            ShowEditUI( not EDITING, "edit" )
        end )

        UI_elements.main = ibCreateImage( 0, 0, asx, asy, UI_elements.SH_MASK, UI_elements.bg ):center( -5, 13 )

        EDITING = nil
        addEventHandler( "onClientRender", root, RenderCarousel )

        bindKey( "mouse_wheel_up", "down", onMouseDown )
        bindKey( "mouse_wheel_down", "down", onMouseUp )
        bindKey( "mouse1", "down", onMouseAction )

        showCursor( true )

        localPlayer:setData( "is_smartwatch_active", true, false )
    else
        removeEventHandler( "onClientRender", root, RenderCarousel )
        unbindKey( "mouse_wheel_up", "down", onMouseDown )
        unbindKey( "mouse_wheel_down", "down", onMouseUp )
        unbindKey( "mouse1", "down", onMouseAction )
        DestroyCarousel( )
        for i, v in pairs( UI_elements ) do
            if isElement( v ) then destroyElement( v ) end
        end
        UI_elements = { }
        showCursor( false )

        localPlayer:setData( "is_smartwatch_active", false, false )
    end
end

function ShowEditUI( state, edit_type )
    if state then
        ShowEditUI( false )
        EDITING = edit_type

        local action_num = ( CURRENT_OFFSET ) % #ACTIONS
        if action_num == 0 then action_num = #ACTIONS end
        local action = edit_type == "add" and "" or ACTIONS[ action_num ]

        UI_elements.main:ibData( "visible", false )

        UI_elements[ edit_type == "add" and "edit" or "add" ]:ibData( "visible", false )

        UI_elements.desc = ibCreateLabel( ax + 5, ay + 20, 0, 0, edit_type == "add" and "Новое действие" or "Изменить действие", 
            UI_elements.bg, 0xFFFFFFFF, 1, 1, _, _, ibFonts.regular_11 )
        
        UI_elements.input_bg = ibCreateImage( ax + 5, ay + 45, asx - 10, 30, _, UI_elements.bg, 0xff1e2832 )
        UI_elements.input = ibCreateWebEdit( 0, -3, asx - 10, 36, action, UI_elements.input_bg, 0xffffffff, 0 )
        :ibData( "font", "regular_11" )
        :ibData( "max_length", 255 )

        UI_elements.save = ibCreateButton( ax + 5, ay + 80, asx - 10, 30, UI_elements.bg, _, _, _, 0xff1e2832, 0xff303a45, 0xff3e4853 )
        ibCreateLabel( 0, 0, 0, 0, edit_type == "add" and "Добавить" or "Сохранить", UI_elements.save, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.regular_11 ):center( )

        UI_elements.save:ibOnClick( function( key, state )
            if key ~= "left" or state ~= "down" then return end
            local text = UI_elements.input:ibData( "text" )
            if utf8.len( text ) > 255 then
                localPlayer:ShowError( "Слишком длинный текст!" )
                return
            elseif utf8.len( text ) <= 0 then
                localPlayer:ShowError( "Слишком короткий текст!" )
                return
            end
            if edit_type == "add" then
                table.insert( ACTIONS, text )
            else
                ACTIONS[ action_num ] = text
            end
            ACTIONS_CHANGED = true
            ShowEditUI( false, edit_type )
        end )
    else
        EDITING = nil
        UI_elements.add:ibData( "visible", true )
        UI_elements.edit:ibData( "visible", true )
        UI_elements.main:ibData( "visible", true )

        if isElement( UI_elements.desc ) then
            destroyElement( UI_elements.desc )
            destroyElement( UI_elements.input_bg )    
            destroyElement( UI_elements.save )
        end
    end
end

local SCROLL_DURATION = 150
local NOW_SCROLL, FROM_SCROLL, TO_SCROLL, CURRENT_TICK = 0, 0, 0, 0
function ScrollCarousel( state )
    if EDITING then return end

    UI_elements.Carousel = UI_elements.Carousel or { }

    if NOW_SCROLL == TO_SCROLL and not SCROLLING then
        onScrollStart()
    end

    playSoundFrontEnd( 37 )
    local is_up = state == "up"
    CURRENT_OFFSET = CURRENT_OFFSET + ( is_up and 1 or -1 )

    FROM_SCROLL = NOW_SCROLL
    CURRENT_TICK = getTickCount()
    TO_SCROLL = CURRENT_OFFSET * asy / NUMBER_OF_SECTIONS

    SCROLLING = true
end

function onMouseUp()
    ScrollCarousel( "up" )
end

function onMouseDown()
    ScrollCarousel( "down" )
end

function DestroyCarousel()
    if UI_elements.Carousel then
        for i, v in pairs( UI_elements.Carousel ) do
            if isElement( v ) then destroyElement( v ) end
        end
    end
    UI_elements.Carousel = nil
end

function RenderCarousel( )
    local progress = ( getTickCount() - CURRENT_TICK ) / SCROLL_DURATION
    if progress > 1 then 
        progress = 1 
        if SCROLLING then
            onScrollStop() 
            SCROLLING = false
        end
    elseif progress < 0 then 
        progress = 0 
    end
    NOW_SCROLL = interpolateBetween( FROM_SCROLL, 0, 0, TO_SCROLL, 0, 0, progress, "InOutQuad" )

    local ipx, ipy = 5, 2

    local section_height = asy / NUMBER_OF_SECTIONS

    local selection_changed = false 

    local active_range = {
        [ 0 ] = true,
        [ 1 ] = true,
        [ 2 ] = true,
        [ 3 ] = true,
    }

    if not EDITING then
        dxSetRenderTarget( UI_elements.RT_INNER, true )
        dxSetBlendMode( "add" )
            for i = 0, 2 do
                local current_position = math.floor( NOW_SCROLL / section_height - 1 + i ) % #ACTIONS
                if current_position == 0 then current_position = #ACTIONS end

                local real_offset = CURRENT_OFFSET % #ACTIONS
                if real_offset == 0 then real_offset = #ACTIONS end

                
                local action = ACTIONS[ current_position ]
                if action then
                    local npy = ( i ) * section_height - NOW_SCROLL % section_height
                    local npy_target = npy + section_height

                    local padding = 10
                    local text_width = asx - padding * 2
                    local text, height = GetWrappedText( action, text_width, ibFonts.regular_10 )

                    local n = -1
                    
                    while height > section_height * 0.75 do
                        n = n - 1
                        text, height = GetWrappedText( utf8.sub( action, 1, n ) .. "...", text_width, ibFonts.regular_10 )
                    end

                    local bgx, bgy = ipx, npy + ipy
                    local bgsx, bgsy = asx - ipx * 2, section_height - ipy * 2

                    if active_range[ i ] and isMouseWithinRangeOf( px + ax + bgx, py + ay + bgy, bgsx, bgsy ) then
                        SELECTION = current_position
                        SELECTION_TYPE = "send"
                        selection_changed = true
                        dxDrawImage( bgx, bgy, bgsx, bgsy, UI_elements.middle_texture, 0, 0, 0, tocolor( 255, 255, 255, 255 ) )
                    else
                        dxDrawImage( bgx, bgy, bgsx, bgsy, UI_elements.middle_texture, 0, 0, 0, tocolor( 255, 255, 255, real_offset == current_position and 150 or 70 ) )
                    end
                    
                    dxDrawText( text, padding, npy, padding + text_width, npy_target, tocolor( 255, 255, 255, 255 ), 1, ibFonts.regular_10, "center", "center", false, true, false, false )
                    
                    local ix, iy = bgx + bgsx - 11, bgy + 3
                    local isx = 8

                    local is_within_range = active_range[ i ] and isMouseWithinRangeOf( px + ax + ix, py + ay + iy, isx, isx ) 
                    if is_within_range then
                        SELECTION_TYPE = "delete"
                        dxDrawImage( ix, iy, isx, isx, UI_elements.delete_texture, 0, 0, 0, tocolor( 255, 255, 255, 255 ) )
                    else
                        dxDrawImage( ix, iy, isx, isx, UI_elements.delete_texture, 0, 0, 0, tocolor( 255, 255, 255, 200 ) )
                    end

                end
            end
        dxSetRenderTarget( )

        dxSetBlendMode( "modulate_add" )

        dxSetShaderValue( UI_elements.SH_MASK, "ScreenTexture", UI_elements.RT_INNER )

        dxSetBlendMode( "blend" )

    end

    if not selection_changed then
        SELECTION = nil
        SELECTION_TYPE = nil
    end
end

function onMouseAction()
    if SELECTION and ACTIONS[ SELECTION ] then
        if SELECTION_TYPE == "delete" then
            if #ACTIONS <= 3 then
                localPlayer:ShowError( "Должно быть как минимум 3 действия" )
                return
            end
            table.remove( ACTIONS, SELECTION )
            SELECTION = nil
            ACTIONS_CHANGED = true
        elseif SELECTION_TYPE == "send" then
            SendAction( ACTIONS[ SELECTION ] )
            ShowUISmartwatch( false )
        end
    end
end


function onScrollStop()
    --UI_elements.delete
end

function onScrollStart()
    if isElement( UI_elements.delete ) then
        destroyElement( UI_elements.delete )
    end
end

function HandleKeys()
    if not localPlayer:IsInGame( ) or localPlayer:getData( "tutorial" ) then return end
    --Если идёт переключение чата
    if getKeyState( "lctrl" ) then return end
    ShowUISmartwatch( not next( UI_elements ) )
end
bindKey( "1", "down", HandleKeys )

function SendAction( action )
    triggerServerEvent( "SWAction", localPlayer, action )
end

function SetAction( key, value )
    ACTIONS[ key ] = value
    ACTIONS_CHANGED = true
end

function FlushActions( force )
    if ACTIONS_CHANGED or force then
        if fileExists( file_path ) then fileDelete( file_path ) end
        local file = fileCreate( file_path )
        fileWrite( file, toJSON( ACTIONS, true ) )
        fileClose( file )
        ACTIONS_CHANGED = nil
        --iprint( "Действия сохранены" )
    end
end
Timer( FlushActions, 6000, 0 )


function isMouseWithinRangeOf(px,py,sx,sy)
  if not isCursorShowing() then
    return false
  end
  local cx,cy = getCursorPosition()
  local x,y = guiGetScreenSize()
  cx,cy = cx*x,cy*y
  if cx >= px and cx <= px+sx and cy >= py and cy <= py+sy then
    return true,cx,cy
  else
    return false
  end
end

function GetWrappedText( text, width, font )
	local fontHeight = dxGetFontHeight( 1, font or "default" );

	text = string.gsub(text, "\n", " #")
	local splitted = {};
	for i in string.gmatch( text, "%S+" ) do
		table.insert( splitted, i );
	end
    
    local text_lines = {}
    local text_line = 1
    local text_max_sx = 120
    local text_height = 0

    for i, word in pairs( splitted ) do
        if not text_lines[text_line] then
            text_lines[text_line] = ""
        end
        if dxGetTextWidth( text_lines[text_line] .. word, 1, font ) > text_max_sx then
            text_lines[text_line] = text_lines[text_line] .. "\n"
            text_lines[text_line + 1] = word
            text_line = text_line + 1
            text_height = text_height + 10
            if text_line >= 3 then
                text_lines[text_line]  = "..."
                break
            end
        else
            text_lines[text_line] = text_lines[text_line] .. " " .. word
        end
    end
    return table.concat( text_lines, "" ), text_height
end;