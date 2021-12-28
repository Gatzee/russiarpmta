-- CActionTasksUtils.lua

local DIALOG_SHADER_CODE = [[
    texture tRenderTarget;
    sampler tRenderTargetSampler = sampler_state
    {
        Texture = <tRenderTarget>;
    };
    
    float ease_out_quad(float x) {
        float t = x; float b = 0; float c = 1; float d = 1;
        return -c *(t/=d)*(t-2) + b;
    }

    float ease_out_cubic(float x) {
        float t = x; float b = 0; float c = 1; float d = 1;
        return c*((t=t/d-1)*t*t + 1) + b;
    }
    
    float4 MaskTextureMain( float2 uv : TEXCOORD0 ) : COLOR0
    {
        
        float4 color = tex2D( tRenderTargetSampler, uv );
        color.a *= ease_out_cubic( uv.y );
        return color;
    }
    
    technique tech
    {
        pass p1
        {
            AlphaBlendEnable = true;
            SrcBlend = SrcAlpha;
            DestBlend = InvSrcAlpha;
            PixelShader = compile ps_2_0 MaskTextureMain();
        }
    }
]]

CONST_DIALOG_OFFSET = 20

local function_skip_dialog = nil

function CreateDialog( data, stripes, ignore_skip )
    local self = { }

    local is_quest_failed = false
    if QUEST_DATA and QUEST_DATA.id then
        is_quest_failed = exports.nrp_quests:IsLastStartedQuestFailure( QUEST_DATA.id )
    end

    self.elements = { }
    self.current_id = 0
    self.animation_duration = 500

    local sx, sy = 800, math.floor( 256 * 3 / 5 )

    local shader = dxCreateShader( DIALOG_SHADER_CODE )

    local main_py = _SCREEN_Y - (is_quest_failed and sy + 30 or sy)

    local bg_list_fake = ibCreateImage( _SCREEN_X_HALF - sx / 2, main_py, sx, sy )
    local bg_list = ibCreateRenderTarget( bg_list_fake:ibData( "px" ), bg_list_fake:ibData( "py" ), bg_list_fake:width( ), bg_list_fake:height( ) ):ibData( "no_render_to_screen", true )

    if is_quest_failed and not ignore_skip then
        ibCreateImage( (sx - 327) / 2, sy - 7, 327, 27, ":nrp_shared/img/action_tasks/btn_skip_dialog.png", bg_list_fake )

        function_skip_dialog = function()
            if CEs.dialog_callback and self.dialog_parts[ self.current_id ]:ibData( "is_author" ) then
                if isTimer( CEs.timer ) then killTimer( CEs.timer ) end
                local temp = CEs.dialog_callback
                CEs.dialog_callback = nil
                temp()
            end
        end
    end

    bg_list_fake:ibData( "texture", shader )
    dxSetShaderValue( shader, "tRenderTarget", bg_list:ibData( "render_target" ) )

    local function CreateDialogPart( dialog_part )
        local old_real_fonts = ibIsUsingRealFonts( )
        ibUseRealFonts( true )

        local bg

        if dialog_part.custom then
            bg = dialog_part.custom( bg_list )
        else
            local name, text = dialog_part.name, dialog_part.text

            local _, lines = utf8.gsub( text, "\n", "" )

            bg = ibCreateArea( 0, 0, 800, 0, bg_list )
            local bg_image = ibCreateImage( 0, 0, 800, 0, ":nrp_shared/img/action_tasks/bg_dialog_contents.png", bg )

            local npy = 9
            if name then
                ibCreateLabel( 0, npy, 0, 0, name, bg, 0xffffdf93, 1, 1, "center", "top", ibFonts.bold_16 ):center_x( )
                npy = npy + 22
            end

            for i, v in pairs( split( text, "\n" ) ) do
                ibCreateLabel( 0, npy, 0, 0, v, bg, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_16 ):center_x( )
                npy = npy + 21
            end

            npy = npy + 12

            bg:ibData( "sy", npy )
            bg_image:ibData( "sy", npy )

            ibCreateImage( 0, 1, 800, 2, ":nrp_shared/img/action_tasks/bg_dialog_edges.png", bg_image )
            ibCreateImage( 0, npy - 3, 800, 2, ":nrp_shared/img/action_tasks/bg_dialog_edges.png", bg_image ):ibData( "rotation", 180 )
        end

        ibUseRealFonts( old_real_fonts )

        return bg
    end

    self.dialog_parts = { }

    local npy = sy
    for i, v in pairs( data ) do
        local bg = CreateDialogPart( v )
        bg:ibData( "is_author", v.name )

        table.insert( self.dialog_parts, bg )

        bg:ibData( "py", npy )
        npy = npy + bg:ibData( "sy" ) + CONST_DIALOG_OFFSET
    end

    local function SetDialogState( bg, state )
        local bg_image = getElementChild( bg, 0 )
        bg_image:ibAlphaTo( state and 255 or 0, self.animation_duration )
    end

    self.destroy = function( self )
        DestroyTableElements( { bg_list, bg_list_fake, shader, self.destroy_timer } )
        DestroyTableElements( self.elements )
        function_skip_dialog = nil
        self.elements = nil
        setmetatable( self, nil )
    end

    self.destroy_with_animation = function( self, duration )
        local duration = duration or 200
        bg_list:ibAlphaTo( 0, duration )
        function_skip_dialog = nil
        self.destroy_timer = setTimer( function( ) self:destroy( ) end, duration, 1 )
    end

    self.relocate = function( self )
        local npy = sy - self.dialog_parts[ self.current_id ]:ibData( "sy" ) - CONST_DIALOG_OFFSET
        self.dialog_parts[ self.current_id ]:ibMoveTo( _, npy, self.animation_duration )
        SetDialogState( self.dialog_parts[ self.current_id ], true )

        if self.current_id > 1 then
            for i = self.current_id - 1, 1, -1 do
                npy = npy - self.dialog_parts[ i ]:ibData( "sy" )
                self.dialog_parts[ i ]:ibMoveTo( _, npy, self.animation_duration )
                SetDialogState( self.dialog_parts[ i ], false )
            end
        end

        if self.current_id < #self.dialog_parts then
            local npy = 256
            for i = self.current_id + 1, #self.dialog_parts do
                self.dialog_parts[ i ]:ibMoveTo( _, npy, self.animation_duration )
                npy = npy + self.dialog_parts[ i ]:ibData( "sy" ) + CONST_DIALOG_OFFSET
                SetDialogState( self.dialog_parts[ i ], true )
            end
        end
    end

    self.next = function( self )
        iprint( "Called next", self.current_id, #self.dialog_parts )
        if self.dialog_parts[ self.current_id + 1 ] then
            self.current_id = self.current_id + 1
            self:relocate( )
            local sound = self:play_voice_line( data[ self.current_id ] )
            if self.auto then
                local duration = data[ self.current_id ].duration or ( sound.length + 0.25 )
                if isTimer( self.next_timer ) then self.next_timer:destroy( ) end
                self.next_timer = setTimerDialog( function( )
                    self:next( )
                end, duration * 1000, 1 )
            end
            if self.next_callback then
                self:next_callback( data[ self.current_id - 1 ], data[ self.current_id ] )
            end
        else
            self:destroy()
            if self.end_callback then
                self:end_callback( )
            end
        end
    end

    self.previous = function( self )
        if self.dialog_parts[ self.current_id - 1 ] then
            self.current_id = self.current_id - 1
            self:relocate( )
            self:play_voice_line( data[ self.current_id ] )
        end
    end

    self.play_voice_line = function( self, dialog )
        iprint( dialog.voice_line )
        if dialog and dialog.voice_line then
            if isElement( self.elements.sound ) then
                stopSound( self.elements.sound )
                self.elements.sound = nil
            end

            self.elements.sound = playSound( ":nrp_shared/sfx/voice/" .. dialog.voice_line .. ".wav" )
            setSoundVolume( self.elements.sound, 1 )
            return self.elements.sound
        end
    end

    self.start = function( self, time )
        self.timer = setTimer( function( )
            self:next( )
        end, time or 2000, 1 )
    end

    self.reposition_to_stripes = function( self, stripes )
        if stripes and stripes:is_shown( ) then
            bg_list_fake:ibData( "py", main_py - stripes:get_height( ) )
            bg_list:ibData( "py", main_py - stripes:get_height( ) )
        else
            bg_list_fake:ibData( "py", main_py )
            bg_list:ibData( "py", main_py )
        end
    end

    return self
end

local EYELID_SHADER_CODE = [[
    float2 resolution = float2( 1.0f, 1.0f );
    float progress = 1;

    float4 drawCircle( float2 uv, float4 main_color, float radius, float2 center, float4 color, float2 scale, float squeeze, float soften ) {
        float2 vTexCoord = uv.xy / resolution.xy;
        float squeezeDirection = ( vTexCoord.y < center.y ) ? squeeze : -squeeze;
        
        squeezeDirection *= radius;
        
        float dist = distance( vTexCoord, center + float2( 0.0f, squeezeDirection ) * scale );
        float lerped_value = clamp( ( radius - dist ) / soften, 0.0f, 1.0f );
        
        if ( dist <= radius ) {
            return lerp( color, main_color, 1.0f - lerped_value );
        }

        return main_color;
    }

    float4 inv_color( float4 color ) {
        return float4( 1, 1, 1, 1 ) - color;
    }

    float4 ps( float2 uv: TEXCOORD0 ) : COLOR0 {
        float4 fragColor = float4( 0.0f, 0.0f, 0.0f, 0.0f );
        
        float circleRadius = 1.7f;
        
        float2 circleScale = float2( 1.5f, 1.5f );
        float2 circleCenter = float2( 0.5f, 0.5f );
        float4 circleColor = float4( 1.0f, 1.0f, 1.0f, 1.0f );
        
        fragColor += float4( 0, 0, 0, 1 ) * inv_color( drawCircle( uv, fragColor, circleRadius, circleCenter, circleColor, circleScale, progress, 0.74f ) );

        return fragColor;
    }

    technique nextrp {
        pass P0 {
            PixelShader = compile ps_2_0 ps();
        }
    }
]]

function CreateEyeLid( )
    local self = { }
    
    self.destroy = function( )
        removeEventHandler( "onClientHUDRender", root, self.draw )
        DestroyTableElements( self )
        setmetatable( self, nil )
    end

    self.goto = function( self, value, time, callback )
        self.start_value = self.current_value
        self.end_value   = value

        self.tick = getTickCount( )
        self.time = time
        self.callback = callback
    end

    self.open = function( self, time, callback )
        local time = time or 400
        self:goto( 0, time, callback )
    end

    self.close = function( self, time, callback )
        local time = time or 100
        self:goto( 1, time, callback )
    end

    self.blink = function( self, count, time_close, time_open, callback )
        local count = count or 1
        local time_close = time_close or 100
        local time_open = time_open or 400

        local sequence = { }
        for i = 1, count do
            table.insert( sequence, { 1, time_close } )
            table.insert( sequence, { 0, time_open } )
        end

        local t = { }
        local step = 0
        t.next_step = function( )
            step = step + 1
            if sequence[ step ] then
                local value, time = unpack( sequence[ step ] )
                self:goto( value, time, sequence[ step + 1 ] and t.next_step or callback )
            end
        end

        t.next_step( )
    end

    self.set_value = function( value )
        self.current_value = value
        dxSetShaderValue( self.shader, "progress", value )
    end

    self.draw = function( )
        dxDrawImage( 0, 0, _SCREEN_X, _SCREEN_Y, self.shader )

        if self.start_value then
            local progress = math.min( 1, math.max( 0, ( getTickCount( ) - self.tick ) / self.time ) )
            local value = interpolateBetween( self.start_value, 0, 0, self.end_value, 0, 0, progress, "Linear" )
            self.set_value( value )

            if progress >= 1 and self.callback then
                local fn = self.callback
                self.callback = nil
                fn( )
            end
        end
    end
    addEventHandler( "onClientHUDRender", root, self.draw )

    self.shader = dxCreateShader( EYELID_SHADER_CODE )
    self.set_value( 0 )

    return self
end

function CreateBlackStripes( )
    local self = { }

    local required_screen_y = _SCREEN_X / 21 * 9
    local height = math.floor( ( _SCREEN_Y - required_screen_y ) / 2 )

    self.area = ibCreateDummy( )
    self.black_top = ibCreateImage( 0, -height, _SCREEN_X, height, _, self.area, COLOR_BLACK )
    self.black_bottom = ibCreateImage( 0, _SCREEN_Y, _SCREEN_X, height, _, self.area, COLOR_BLACK )

    self.area:ibDeepSet( "disabled", true ):ibData( "priority", -100 )

    self.destroy = function( self )
        DestroyTableElements( self )
        setmetatable( self, nil )
    end

    self.destroy_with_animation = function( self, duration )
        local duration = duration or 500
        self:hide( duration )
        self.area:ibTimer( function( ) self:destroy( ) end, duration, 1 )
    end

    self.show = function( self, duration )
        local duration = duration or 500
        self.black_top:ibMoveTo( 0, 0, duration )
        self.black_bottom:ibMoveTo( 0, _SCREEN_Y - height, duration )
        self.shown = true
    end

    self.hide = function( self, duration )
        local duration = duration or 500
        self.black_top:ibMoveTo( 0, -height, duration )
        self.black_bottom:ibMoveTo( 0, _SCREEN_Y, duration )
        self.shown = nil
    end

    self.is_shown = function( self )
        return self.shown
    end

    self.get_height = function( self )
        return height
    end

    return self
end

function SteeringWheelController( vehicle )
    local self = { }

    self.destroy = function( )
        removeEventHandler( "onClientRender", root, self.draw )
        removeEventHandler( "onClientElementDestroy", vehicle, self.destroy )
        DestroyTableElements( self )
        setmetatable( self, nil )
    end

    self.set_value = function( value )
        setVehicleComponentRotation( vehicle, "rpb_sw", 0, value or 0, 0 )
        self.current_value = value
    end

    self.draw = function( )
        if self.start_value then
            local progress = math.min( 1, math.max( 0, ( getTickCount( ) - self.tick ) / self.time ) )
            local value = interpolateBetween( self.start_value, 0, 0, self.end_value, 0, 0, progress, "InOutQuad" )
            self.set_value( value )

            if progress >= 1 and self.callback then
                local fn = self.callback
                self.callback = nil
                fn( )
            end
        end
    end

    self.goto = function( self, value, time, callback )
        self.start_value = self.current_value

        if not self.start_value then
            local rx, ry, rz = getVehicleComponentRotation( vehicle, "rpb_sw" )
            self.start_value = ry
        end
        self.end_value = value

        self.tick = getTickCount( )
        self.time = time
        self.callback = callback
    end

    addEventHandler( "onClientRender", root, self.draw )
    addEventHandler( "onClientElementDestroy", vehicle, self.destroy )

    return self
end

do
    local timer
    local controlTable = { "fire", "aim_weapon", "next_weapon", "previous_weapon", "forwards", "backwards", "left", "right", "zoom_in", "zoom_out",
        "change_camera", "jump", "sprint", "look_behind", "crouch", "action", "walk", "conversation_yes", "conversation_no",
        "group_control_forwards", "group_control_back", "enter_exit", "vehicle_fire", "vehicle_secondary_fire", "vehicle_left", "vehicle_right",
        "steer_forward", "steer_back", "accelerate", "brake_reverse", "radio_next", "radio_previous", "radio_user_track_skip", "horn",
        "handbrake", "vehicle_look_left", "vehicle_look_right", "vehicle_look_behind", "vehicle_mouse_look", "special_control_left", "special_control_right",
        "special_control_down", "special_control_up" }

    local function ResetStates( )
        for i, v in pairs( controlTable ) do
            setPedControlState( localPlayer, v, false )
        end
    end

    local WHITELIST = { }
    function HandleKeys( key, pressed )
        if pressed then
            local key = string.lower( key )
            if not WHITELIST[ key ] then 
                if function_skip_dialog and key == "enter" then
                    function_skip_dialog()
                end
                cancelEvent( ) 
            end
        end
    end

    function BlockAllKeys( whitelist )
        UnblockAllKeys( )

        ResetStates( )

        for i, v in pairs( whitelist or { } ) do
            WHITELIST[ v ] = true
        end
        addEventHandler( "onClientKey", root, HandleKeys )

        timer = setTimer( ResetStates, 0, 1 )
    end

    function UnblockAllKeys( )
        ResetStates( )
        if isTimer( timer ) then killTimer( timer ) end
        timer = nil 
        WHITELIST = { }
        removeEventHandler( "onClientKey", root, HandleKeys )
    end
end

function FadeBlink( duration, delay )
    fadeCamera( false, 0.0 )
    setTimer( fadeCamera, delay and delay * 1000 or 50, 1, true, duration or 1.0 )
end

function StartCutsceneAtNPC( id )
    local quest_npc = FindQuestNPC( id )
    if not quest_npc then return end

    setCameraMatrix( unpack( quest_npc.camera_to ) )
    localPlayer.position = quest_npc.player_position or localPlayer.position
    localPlayer.rotation = Vector3( 0, 0, quest_npc.player_rotation or localPlayer.rotation.z )
    --removePedTask( localPlayer )
end

function CreateMarkerToNPC( conf )
    local quest_npc = FindQuestNPC( conf.id )
    if not quest_npc then return end

    CreateQuestPoint( quest_npc.player_position or quest_npc.position, conf.callback, nil, conf.radius, nil, conf.local_dimension and localPlayer:GetUniqueDimension( ) or localPlayer.dimension,
        function( )
            if localPlayer.vehicle then
                return false, "Выйди из транспорта чтобы продолжить"
            end

            if conf.check_func then
                local result, err = conf.check_func( )
                return result, err
            else
                return true
            end
        end 
    )
end

function CreateMarkerToCutscene( conf )
    local callback_real = conf.callback

    conf.callback = function( self, player )
        StartQuestCutscene( conf )
        if callback_real then callback_real( self, player ) end
    end
    CreateQuestPoint( conf.position, conf.callback, conf.name, conf.radius, conf.interior, conf.local_dimension and localPlayer:GetUniqueDimension( ) or conf.dimension, conf.check_fn, conf.keypress, conf.keytext, conf.marker_type, conf.r, conf.g, conf.b, conf.a )
end

function CreateMarkerToCutsceneNPC( conf )
    local callback_real = conf.callback

    conf.callback = function( self, player )
        StartQuestCutscene( conf )
        if callback_real then callback_real( self, player ) end
    end
    CreateMarkerToNPC( conf )
end

function setTimerDialog( callback, time_ms )
    if isTimer( CEs.timer_dialog ) then killTimer( CEs.timer_dialog ) end

    CEs.dialog_callback = callback
    CEs.timer_dialog = setTimer( CEs.dialog_callback, time_ms or ((CEs.dialog.elements.sound.length + 0.05) * 1000), 1 )

    return CEs.timer_dialog
end

function StartQuestCutscene( conf )
    local conf = conf or { }
    
    triggerEvent( "ToggleDisableFirstPerson", localPlayer )
    
    if not conf.ignore_fade_blink then
        FadeBlink( 1.0, 0.2 )
    end
    
    BlockAllKeys( conf.allowed_keys )
    DisableHUD( true )

    if not conf.no_stripes and not CEs.stripes then
        CEs.stripes = CreateBlackStripes( )
        CEs.stripes:show( )
    end

    if conf.dialog then
        if CEs.dialog then CEs.dialog:destroy() end
        CEs.dialog = CreateDialog( conf.dialog )
        CEs.dialog:reposition_to_stripes( CEs.stripes )
    end

    if conf.id then
        StartCutsceneAtNPC( conf.id )
    end

    localPlayer.frozen = true
end

function FinishQuestCutscene( conf )
    local conf = conf or { }

    if CEs.dialog then
        CEs.dialog:destroy_with_animation( )
        CEs.dialog = nil
    end

    if CEs.stripes then
        CEs.stripes:destroy_with_animation( )
        CEs.stripes = nil
    end

    localPlayer.frozen = false
    UnblockAllKeys( )
    DisableHUD( false )
    
    if not conf.ignore_fade_blink then
        FadeBlink( 1.0 )
    end
    
    setCameraTarget( localPlayer )
end


function GetTargetCameraMatrix( target )
    local mx_old = { getCameraMatrix( ) }

    setCameraTarget( target or localPlayer )

    local mx = { getCameraMatrix( ) }

    setCameraMatrix( unpack( mx_old ) )

    return unpack( mx )
end

function CameraFromToSequence( sequence, callback, ... )
    local step = 0

    local args = { ... }
    local self = { }

    self.NextStep = function( )
        if sequence[ step ] then
            local args_prev = sequence[ step ]
            local callback_prev = args_prev[ 5 ]
            if callback_prev then
                for i = 1, 5 do
                    table.remove( args_prev, 1 )
                end
                callback_prev( unpack( args_prev ) )
            end
            
        end
        step = step + 1
        if sequence[ step ] then
            local from, to, duration, easing = unpack( sequence[ step ] )
            CameraFromTo( from, to, duration, easing, self.NextStep )
        else
            if callback then callback( unpack( args ) ) end
        end
    end

    self.NextStep( )
end

function CameraFromTo( from, to, duration, easing, callback, ... )
    local self = { }

    local from = from or { getCameraMatrix( ) }

    local args = { ... }
    local easing = easing or "InOutQuad"
    local start = getTickCount( )

    self.draw = function( )
        local progress = math.min( 1, ( getTickCount( ) - start ) / duration )

        local cx, cy, cz = interpolateBetween( from[ 1 ], from[ 2 ], from[ 3 ], to[ 1 ], to[ 2 ], to[ 3 ], progress, easing )
        local ctx, cty, ctz = interpolateBetween( from[ 4 ], from[ 5 ], from[ 6 ], to[ 4 ], to[ 5 ], to[ 6 ], progress, easing )

        local rotation, fov = interpolateBetween( from[ 7 ] or 0, from[ 8 ] or 70, 0, to[ 7 ] or from[ 7 ] or 0, to[ 8 ] or from[ 8 ] or 70, 0, progress, easing )

        setCameraMatrix( cx, cy, cz, ctx, cty, ctz, rotation, fov )

        if progress >= 1 then
            self.destroy( )
        end
    end
    
    self.destroy = function( )
        removeEventHandler( "onClientRender", root, self.draw )
        setmetatable( self, nil )

        if callback then callback( unpack( args ) ) end
    end

    addEventHandler( "onClientRender", root, self.draw )

    return self
end

function MoveCameraToLocalPlayer( duration, callback, ... )
    local from = { getCameraMatrix( ) }
    local to = { GetTargetCameraMatrix( localPlayer ) }

    CameraFromTo( from, to, duration, easing, callback, ... )
end

function HideNPCs( )
    triggerEvent( "onPlayerMoveQuestElements", localPlayer, localPlayer:GetUniqueDimension( ) + 1 )
end

function ShowNPCs( )
    triggerEvent( "onPlayerMoveQuestElements", localPlayer, localPlayer.dimension )
end

function LocalizeQuestElement( element, conf )
    local conf = conf or { }
    element.dimension = localPlayer.dimension or conf.dimension
    element.interior = localPlayer.interior or conf.interior
end

local undamagable_peds = { }
addEventHandler( "onClientPlayerStealthKill", localPlayer, function( target )
    if undamagable_peds[ target ] then
        cancelEvent( )
    end
end )

function SetUndamagable( element, state )
    undamagable_peds[ element ] = state or nil
    removeEventHandler( "onClientPedDamage", element, cancelEvent )
    if state then
        addEventHandler( "onClientPedDamage", element, cancelEvent )
    end
end

function ConvertKeystringToValues( str )
    local pattern = "key=[^ ]+"
    local pattern_extractor = "key=(.+)"
    local temp_separator = "<SEPARATOR>"

    local function trim(s)
        return ( s:gsub( "^%s*(.-)%s*$", "%1" ) )
    end

    local keys = { }
    local separable_string = str
    for key in utf8.gmatch( str, pattern ) do
        table.insert( keys, utf8.match( key, pattern_extractor ) )
    end
    local separable_string = utf8.gsub( separable_string, pattern, temp_separator )
    local split_string = split( separable_string, temp_separator )

    local elements = { }
    for i, v in pairs( split_string ) do
        table.insert( elements, { type = "text", value = trim( v ) } )
    end
    for i, v in pairs( keys ) do
        table.insert( elements, i * 2, { type = "key", value = trim( v ) } )
    end

    return elements
end

function CreateSutiationalHint( self )
    local self = self or { }
    if not self.text then return false end
    
    self.rate = self.rate or 100
    self.condition = self.condition or function( ) return true end

    self.construct_visual = function( )
        if isElement( self.area ) then destroyElement( self.area ) end
        self.area = ibCreateArea( self.px or 0, self.py or (_SCREEN_Y - 100), 0, 0 ):ibData( "alpha", 0 )

        self.elements_order = ConvertKeystringToValues( self.text )
        self.elements = { }
        
        local real_fonts = ibIsUsingRealFonts( )
        ibUseRealFonts( true )

        for i, v in ipairs( self.elements_order ) do
            local element

            if v.type == "text" then
                element = ibCreateLabel( 0, 0, 0, 0, v.value, self.area, _, _, _, _, _, ibFonts.regular_18 ):ibData( "outline", 1 )

            elseif v.type == "key" then
                element = ibCreateImage( 0, -4, 34, 34, _, self.area, ibApplyAlpha( 0xff212b36, 85 ) )
                local label = ibCreateLabel( 0, 0, 0, 0, v.value, element, _, _, _, "center", "center", ibFonts.bold_18 )

                if utf8.len( v.value ) > 2 then
                    label:ibData( "font", ibFonts.bold_16 )
                    local width = label:width( ) + 8 * 2
                    element:ibData( "sx", width )
                end

                label:center( )
            end
            
            if element then
                table.insert( self.elements, element )
            end
        end

        local prev_element
        for i, v in pairs( self.elements ) do
            v:ibData( "px", prev_element and prev_element:ibGetAfterX( 5 ) or 0 )
            prev_element = v
        end
        self.area:ibData( "sx", prev_element:ibGetAfterX( ) ):center_x( )

        ibUseRealFonts( real_fonts )
    end

    self.is_showing = function( )
        return self.showing
    end

    self.show = function( self, duration )
        self.area:ibAlphaTo( 255, duration or 250 )
        self.showing = true
    end

    self.hide = function( self, duration )
        self.area:ibAlphaTo( 0, duration or 250 )
        self.showing = nil
    end

    self.destroy = function( )
        DestroyTableElements( self )
        setmetatable( self, nil )
    end

    self.destroy_with_animation = function( self, duration )
        if isTimer( self.timer ) then killTimer( self.timer ) end

        local duration = duration or 500
        self:hide( duration )
        self.area:ibTimer( function( ) self:destroy( ) end, duration, 1 )
    end

    self.check_condition = function( )
        local condition_result = self:condition( )
        if self:is_showing( ) and not condition_result then
            self:hide( )
        elseif not self:is_showing( ) and condition_result then
            self:show( )
        end
    end

    self.timer = setTimer( self.check_condition, self.rate, 0 )

    self:construct_visual( )
    self:check_condition( )

    return self
end

function StartPedTalk( ped, duration, loop )
    setPedAnimation( ped, "Razgovor", "razgovor", duration or -1, loop or false, true, true, true, 500 )
end

function StopPedTalk( ped )
    setPedAnimation( ped, nil, nil )
end