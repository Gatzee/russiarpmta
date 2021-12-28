local BROWSER, SHADER, TIMER

local SHADER_CODE = [[
	texture gTexture;

	technique TexReplace
	{
		pass P0
		{
			Texture[0] = gTexture;
		}
	}
]]

function ApplyBrowserToScreens( browser )
    local shader = dxCreateShader( SHADER_CODE, 1, 40 )
    dxSetShaderValue( shader, "gTexture", browser )
    engineApplyShaderToWorldTexture( shader, "k_teatr20" )

    return shader
end

function RemoveBrowserFromScreens( )
    DestroyTableElements( { BROWSER, SHADER, TIMER } )
    BROWSER, SHADER, TIMER = nil, nil, nil
end

function onCinemaVideoSync_handler( url, time_passed )
    --iprint( getTickCount( ), "cinema video sync", url, time_passed )
    -- Если есть видео
    if url then
        local time_passed = time_passed or 0

        local url = URLAppendParameters( PROXY_URL, 
            {
                url = url,
                start = time_passed,
            }
        )

        -- Браузер не существует
        if not isElement( BROWSER ) then
            BROWSER = createBrowser( 1920, 1080, false )
            addEventHandler( "onClientBrowserCreated", BROWSER, function( )
                loadBrowserURL( BROWSER, url )
                SHADER = ApplyBrowserToScreens( BROWSER )
                TIMER = setTimer( function( ) setBrowserVolume( BROWSER, CINEMA_VOLUME_MUL or 1 ) end, 500, 0 )
            end )

        -- Уже есть браузер
        else
            loadBrowserURL( BROWSER, url )

        end

        triggerEvent( "CreateCinemaDimmer", localPlayer )
        ALPHA_CONTROLS_ALLOWED = true

    -- Если просмотр окончен
    else
        RemoveBrowserFromScreens( )
        triggerEvent( "DestroyCinemaDimmer", localPlayer )
        ALPHA_CONTROLS_ALLOWED = nil
    end
end
addEvent( "onCinemaVideoSync", true )
addEventHandler( "onCinemaVideoSync", resourceRoot, onCinemaVideoSync_handler )

-- Прозрачность персонажей
MIN_ALPHA = 1
function UpdatePlayersAlpha( )
    local target_alpha = IS_INSIDE_CINEMA and ALPHA_CONTROLS_ALLOWED and CINEMA_ALPHA_PLAYERS and MIN_ALPHA or 255
    for i, v in pairs( getElementsByType( "player", root, true ) ) do
        if v.alpha > 0 then
            v.alpha = target_alpha
        end
    end
end

function onPlayerCinemaEnter_alphaHandler( )
    onPlayerCinemaLeave_alphaHandler( )
    ALPHA_TIMER = setTimer( UpdatePlayersAlpha, 1000, 0 )
end
addEvent( "onPlayerCinemaEnter", true )
addEventHandler( "onPlayerCinemaEnter", root, onPlayerCinemaEnter_alphaHandler )

function onPlayerCinemaLeave_alphaHandler( )
    if isTimer( ALPHA_TIMER ) then killTimer( ALPHA_TIMER ) end
    UpdatePlayersAlpha( )
end
addEvent( "onPlayerCinemaLeave", true )
addEventHandler( "onPlayerCinemaLeave", root, onPlayerCinemaLeave_alphaHandler )

function onSettingsChange_handler( changed, values )
	if changed.cinemavolume then
		if values.cinemavolume then
            CINEMA_VOLUME_MUL = values.cinemavolume
            if isElement( BROWSER ) then
                setBrowserVolume( BROWSER, CINEMA_VOLUME_MUL )
            end
        end
    end
    
    if changed.cinemaalpha then
        CINEMA_ALPHA_PLAYERS = values.cinemaalpha
        UpdatePlayersAlpha( )
	end
end
addEvent( "onSettingsChange" )
addEventHandler( "onSettingsChange", root, onSettingsChange_handler )

triggerEvent( "onSettingsUpdateRequest", localPlayer, "cinemavolume" )
triggerEvent( "onSettingsUpdateRequest", localPlayer, "cinemaalpha" )