local id = "crash_cutscene"
local function GetSelf( ) return TUTORIAL_STEPS[ id ] end

TUTORIAL_STEPS[ id ] = {
    entrypoint = function( self )
        local self = GetSelf( )

        setTimer( function( )
            local from = to
            local to = { 1297.0762939453, -1117.40921020508+860, 49.307529449463, 1223.5941162109, -1184.36413574219+860, 38.47241973877, 0, 70 }
            CameraFromTo( from, to, 15000 )

            setTimer( function( )
                local logo_area = ShowLogo( )

                setTimer( function( )
                    HideLogo( logo_area )
                    fadeCamera( false, 2.0 )

                    setTimer( function( )
                        DestroyTableElements( { self.my_vehicle, self.enemy_vehicle, self.enemy_ped_1, self.enemy_ped_2, self.bot_falling } )
                        
                        localPlayer.frozen = false

                        setFPSLimit( 0 )
                        DisableHUD( false )

                        -- Шаг 18 - Завершение катсцены
                        triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 17, getRealTimestamp( ) - TUTORIAL_START_TICK )

                        StartTutorialStep( "hospital_scene", false )
                    end, 3000, 1 )

                end, 12000, 1 )

            end, 3000, 1 )

        end, 5000, 1 )
    end
}

function ShowLogo( )
    local text = "Добро пожаловать на"
    local scale = _SCREEN_X / 1920

    local sx, sy = math.floor( 1148 * scale ), math.floor( 580 * scale )
    local font_size = math.floor( 48 * scale )

    local label_y_diff = 120 * scale

    local logo_area = ibCreateArea( _SCREEN_X - sx, 0, sx, sy ):center_y( )
    local gradient = ibCreateImage( _SCREEN_X - sx, 0, sx, _SCREEN_Y, "img/gradient.png", logo_area ):center( ):ibData( "alpha", 0 ):ibAlphaTo( 255, 2000 )
    
    local logo = ibCreateImage( 0, 0, sx, sy, "img/logo_bg.png", logo_area ):center( 0, label_y_diff / 2 )
    local logo_overlay = ibCreateImage( logo:ibData( "px" ), logo:ibData( "py" ), sx, sy, "img/logo.png", logo_area ):ibData( "section", { px = 0, py = 0, sx = 0, sy = sy } )

    local lbl = ibCreateLabel( 0, 0, 0, 0, text, logo_area, COLOR_WHITE, _, _, "center", "top", ibFonts[ "regular_" .. font_size ] ):center( )--:ibData( "outline", 1 )

    logo:ibData( "alpha", 0 )
    lbl:ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )
    :ibTimer( function( self )
        self:ibMoveTo( _, label_y_diff, 500 )
            :ibTimer( function( )
                logo:ibAlphaTo( 255, 1000 )
                :ibTimer( function( )
                    logo_overlay:ibInterpolate( function( self )
                        local start_part = math.floor( sx * 0.6 )
                        local size = math.ceil( self.progress * ( sx - start_part ) )
                        logo_overlay:ibBatchData( { px = start_part, section = { px = start_part, py = 0, sx = size, sy = sy } } )
                    end, 1000, "OutQuad" )
                end, 1000, 1 )
            end, 600, 1 )
    end, 1000, 1 )

    return logo_area
end

function HideLogo( logo_area )
    local duration = 2000
    logo_area:ibAlphaTo( 0, duration ):ibTimer( function( self ) self:destroy( ) end, duration, 1 )
end