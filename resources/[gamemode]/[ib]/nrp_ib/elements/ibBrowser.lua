local E_CLASS = "ibBrowser"

local DEFAULT_VALUES = {
    visible         = true,
    priority        = 0,

    px              = 0,
    py              = 0,
    sx              = 0,
    sy              = 0,
    is_local        = true,
    is_transparent  = true,
    postgui         = false,
    alpha           = 255,
    color           = 0xFFFFFFFF,

    focusable       = true,
}

function ibBrowser( self, resource )
    if type( self ) ~= "table" then
        outputDebugString( "Bad argument @ibBrowser[1], expect table got ".. type( self ), 1 )
        return
    end
    local sourceResource = sourceResource or resource or _THIS_RESOURCE
    local element = ibCreateNewElementOfClass( self, E_CLASS, sourceResource )
    ibSetDefaultValues( self, DEFAULT_VALUES )
    triggerEvent( "ibOnElementCreate", element, self, E_CLASS, sourceResource )

    local browser_gui = guiCreateBrowser( self.px, self.py, self.sx, self.sy, self.is_local, self.is_transparent, false )
    local browser = guiGetBrowser( browser_gui )

    ibSetData( element, "browser_gui", browser_gui )
    ibSetData( element, "browser", browser )

    guiSetAlpha( browser_gui, 0 )

    local function onClientBrowserCreated_handler( )
        triggerEvent( "ibOnBrowserCreated", element, browser )
		if _IB_ELEMENT_DATA[ element ].devtools then toggleBrowserDevTools( browser, true ) end
	end
    addEventHandler( "onClientBrowserCreated", browser, onClientBrowserCreated_handler )
    
    local function onClientBrowserLoadingStart_handler( url, is_main_frame )
        triggerEvent( "ibOnBrowserLoadingStart", element, browser, url, is_main_frame )
	end
    addEventHandler( "onClientBrowserLoadingStart", browser, onClientBrowserLoadingStart_handler )
    
    local function onClientBrowserDocumentReady_handler( url )
        triggerEvent( "ibOnBrowserDocumentReady", element, browser, url )
	end
    addEventHandler( "onClientBrowserDocumentReady", browser, onClientBrowserDocumentReady_handler )
    
    local function onClientBrowserNavigate_handler( url, is_blocked, is_main_frame )
        triggerEvent( "ibOnBrowserNavigate", element, browser, url )
	end
    addEventHandler( "onClientBrowserNavigate", browser, onClientBrowserNavigate_handler )

    local function injectCSS( css )
        local str = [[
            var style = document.getElementById( 'ibStyle' );
            if ( style == null ) {
                style = document.createElement( 'style' );
                style.id = "ibStyle";
                document.head.appendChild( style );
                console.log( "Created new style element" );
            }
            style.innerHTML += `]] .. css:gsub( "`", "\\`" ) .. [[`;
        ]]
        executeBrowserJavascript( browser, str )
    end
    addEventHandler( "ibBrowserInjectCSS", element, injectCSS )

    local function setElementParameter( id, parameter, value )
        local value = tostring( value )
        local str = [[
            var element = document.getElementById( ']] .. id .. [[' );
            element.]] .. parameter .. [[ = `]] .. value:gsub( "`", "\\`" ) .. [[`;
        ]]
        executeBrowserJavascript( browser, str )
    end
    addEventHandler( "ibBrowserSetElementParameter", element, setElementParameter )

    local function CallElementFunction( id, func )
        local str = [[
            var element = document.getElementById( ']] .. id .. [[' );
            element.]] .. func .. [[
        ]]
         executeBrowserJavascript( browser, str )
    end
    addEventHandler( "ibBrowserCallElementFunction", element, CallElementFunction )

    local function setElementHTML( id, html )
        setElementParameter( id, "innerHTML", html )
    end
    addEventHandler( "ibBrowserSetElementHTML", element, setElementHTML )

    local function setElementValue( id, value )
        setElementParameter( id, "value", value )
    end
    addEventHandler( "ibBrowserSetElementValue", element, setElementValue )
    
    local function ibOnElementDataChange_handler( key, value )
        local edata = _IB_ELEMENT_DATA[ element ]
        -- Отключение рендеринга
        if key == "disabled_rendering" then
            setBrowserRenderingPaused( browser, value and true )
        
        -- Смена громкости браузера
        elseif key == "volume" then
            setBrowserVolume( browser, value )

        -- Размеры
        elseif key == "sx" or key == "sy" then
            resizeBrowser( browser, edata.sx, edata.sy )

        -- Дебаг консоль
        elseif key == "devtools" then
            toggleBrowserDevTools( browser, value )

        -- Фокусировка браузера
        elseif key == "focused" then
            if ibGetData( element, "focusable" ) then
                if value then
                    guiSetEnabled( browser_gui, true )
                    focusBrowser( browser )
                else
                    guiSetEnabled( browser_gui, false )
                end
            end
        end
    end
    addEventHandler( "ibOnElementDataChange", element, ibOnElementDataChange_handler, false )

    -- Обработка фокусировки браузера
    local function ibOnElementMouseClick_handler( )
        if ibGetData( element, "focusable" ) then 
            ibSetData( element, "focused", source == element )
        end
    end
    addEventHandler( "ibOnElementMouseClick", _IB_ROOT, ibOnElementMouseClick_handler, true )
    ibSetData( element, "focused", self.focused )

    local function onClientElementDestroy_handler( )
        if isElement( browser_gui ) then destroyElement( browser_gui ) end
        if isElement( browser ) then destroyElement( browser ) end
        removeEventHandler( "ibOnElementMouseClick", _IB_ROOT, ibOnElementMouseClick_handler )
    end
    addEventHandler( "onClientElementDestroy", element, onClientElementDestroy_handler, false )

    return element
end

addEvent( "ibOnBrowserCreated", true )
addEvent( "ibOnBrowserLoadingStart", true )
addEvent( "ibOnBrowserDocumentReady", true )
addEvent( "ibOnBrowserNavigate", true )
addEvent( "ibBrowserInjectCSS", true )
addEvent( "ibBrowserSetElementHTML", true )
addEvent( "ibBrowserSetElementValue", true )
addEvent( "ibBrowserSetElementParameter", true )
addEvent( "ibBrowserCallElementFunction", true )


local dxDrawImage    = dxDrawImage
local guiSetPosition = guiSetPosition

_RENDER_FUNCTIONS[ E_CLASS ] = function( element, data, parent_px, parent_py, mouse_px, mouse_py, alpha )
    local px, py = parent_px + data.px, parent_py + data.py

    local alpha  = alpha * data.alpha

    local browser_gui       = data.browser_gui
    local browser           = data.browser
    local real_px, real_py  = data.real_px, data.real_py

    if real_px and real_py then
        guiSetPosition( browser_gui, real_px, real_py, false )
    end

    if alpha > 0 then
        dxDrawImage(
            px, py, data.sx, data.sy,
            browser,
            0, 0, 0,
            ColorMulAlpha( data.color, alpha ), data.postgui
        )
    end

    return px, py, data.sx, data.sy, mouse_px + data.px, mouse_py + data.py, alpha
end