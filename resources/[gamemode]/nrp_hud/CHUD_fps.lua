local fps = 0
local fps_i = 0
local fps_t = getTickCount()
local fps_height = dxGetFontHeight()

function RenderFPS()
	if getTickCount() - fps_t >= 1000 then
		fps_t = getTickCount()
		fps = fps_i
		fps_i = 0
	end
    fps_i = fps_i + 1
    dxDrawText( fps, x - dxGetTextWidth( fps ), y - fps_height )
end
addEventHandler( "onClientRender", root, RenderFPS )


function onClientShowFps_handler( state )
	removeEventHandler( "onClientRender", root, RenderFPS )
	if state then
		addEventHandler( "onClientRender", root, RenderFPS )
	end
end
addEvent( "onClientShowFps", true )
addEventHandler( "onClientShowFps", root, onClientShowFps_handler )