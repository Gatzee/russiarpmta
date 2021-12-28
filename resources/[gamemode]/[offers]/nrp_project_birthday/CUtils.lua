
----------------------------------------------------------------------------------------------
-- Перемещение камеры в заданную позицию
----------------------------------------------------------------------------------------------

iStarted = nil
sx, sy, sz = nil, nil, nil
CAMERA_DATA = nil

function PreRenderCamera()
    local fProgress = ( getTickCount() - iStarted ) / 1000

    local cx, cy, cz = interpolateBetween( sx, sy, sz, CAMERA_DATA.x, CAMERA_DATA.y, CAMERA_DATA.z, fProgress, "Linear" )
    setCameraMatrix( cx, cy, cz, CAMERA_DATA.tx, CAMERA_DATA.ty, CAMERA_DATA.tz )

    if fProgress >= 1 then
        removeEventHandler( "onClientRender", root, PreRenderCamera )
        iStarted = nil
        sx, sy, sz = nil, nil, nil
        CAMERA_DATA = nil
    end
end

function MoveCameraTo( camera_data )
    CAMERA_DATA = camera_data
    iStarted = getTickCount()
    sx, sy, sz = getElementPosition( getCamera() )
    removeEventHandler( "onClientRender", root, PreRenderCamera )
	addEventHandler( "onClientRender", root, PreRenderCamera )
end

----------------------------------------------------------------------------------------------
-- Система диалогов 
----------------------------------------------------------------------------------------------

CURRENT_DIALOG = nil
NEXT_DIALOG_TIMER = nil

function CreatetDialog( event_data, callback )
    if CURRENT_DIALOG then return end

    localPlayer.position = localPlayer.position
    toggleAllControls( false )
    setTimer( toggleAllControls, 10000, 1, true )

    local dialog_data = EVENT[ "stage_" .. event_data.stage ]
    if not dialog_data or not dialog_data.dialog or #dialog_data.dialog.messages == 0 then return end
    
    dialog_data = table.copy( dialog_data.dialog )
    event_data = table.copy( event_data )
    CURRENT_DIALOG = 
    {
        id = "stage_" .. event_data.stage,
        messages = dialog_data.messages,
        font = ibFonts[ dialog_data.font ],
        on_finished = dialog_data.on_finished,
        camera_matrix = dialog_data.camera_matrix,
        elements = {},
        callback = callback,
        data = event_data,
    }

    if CURRENT_DIALOG.camera_matrix then
        MoveCameraTo( CURRENT_DIALOG.camera_matrix )
    end

    if isTimer( NEXT_DIALOG_TIMER ) then
        NEXT_DIALOG_TIMER:destroy()
    end
    NEXT_DIALOG_TIMER = setTimer( NextDialogMessage, 1000, 1 )
    showCursor( true )
end

function NextDialogMessage()
    local _, sMsg = next( CURRENT_DIALOG.messages )
    if sMsg then
        local str, sx, sy = CustomWordBreak(sMsg, CURRENT_DIALOG.font, 600)
        sx = sx + 20
        sy = sy + 20

        local px, py = scX/2-sx/2, scY - scY/3

        for k,v in pairs( CURRENT_DIALOG.elements ) do
            local msg_px, msg_py = v:ibData("px"), v:ibData("py")
            local msg_sy = v:ibData("sy")
            local new_py = msg_py-sy-10

            local f_alpha_progress = (new_py+msg_sy/2) / (scY/3)
            local alpha = interpolateBetween( 0, 0, 0, 255, 0, 0, f_alpha_progress, "Linear" )

            v:ibMoveTo( msg_px, new_py, 600 )
            v:ibAlphaTo(alpha, 600)
        end

        local msg_bg = ibCreateImage( px, py+sy, sx, sy, "files/img/msg_bg.png", false ):ibData("alpha", 0)
        :ibAlphaTo( 255, 600 ):ibMoveTo( px, py, 600 )
        ibCreateLabel( 0, 0, sx, sy-20, str, msg_bg, 0xffffffff, _, _, "center", "center", CURRENT_DIALOG.font )

        table.insert( CURRENT_DIALOG.elements, msg_bg )
        table.remove( CURRENT_DIALOG.messages, 1 )

        if isTimer( NEXT_DIALOG_TIMER ) then
            NEXT_DIALOG_TIMER:destroy()
        end
        NEXT_DIALOG_TIMER = setTimer( NextDialogMessage, 1200, 1 )
    else
        local msg_py = CURRENT_DIALOG.elements[ #CURRENT_DIALOG.elements ]:ibData("py")
        local msg_sy = CURRENT_DIALOG.elements[ #CURRENT_DIALOG.elements ]:ibData("sy")

        CURRENT_DIALOG.elements.btn_finish = ibCreateButton( scX/2-56, msg_py+msg_sy+10, 110, 44, false, 
            "files/img/btn_finish_dialog.png", "files/img/btn_finish_dialog.png", "files/img/btn_finish_dialog.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnClick( function(key, state) 
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            if CURRENT_DIALOG.callback then
                CURRENT_DIALOG.callback( CURRENT_DIALOG.data )
            elseif CURRENT_DIALOG.on_finished then
                CURRENT_DIALOG.on_finished( CURRENT_DIALOG.data )
            end
            DestroyDialog()
        end)
    end
end

function DestroyDialog()
    for k, v in pairs( CURRENT_DIALOG.elements ) do
        if isElement( v ) then
            destroyElement( v )
        end
    end

    toggleAllControls( true )
    setCameraTarget( localPlayer )
    showCursor( false )
    CURRENT_DIALOG = nil
end


function CustomWordBreak( text, font, width )
	local text = string.gsub( text, "\n", "" )
	local pWords = split( text, " " )
	local pLines = {}
	local iWidthMax = 0

	local iLine = 1

	for k,v in pairs( pWords ) do
		local line_width = dxGetTextWidth( (pLines[iLine] or "").." "..v, 1, font )

		if line_width > iWidthMax then
			iWidthMax = line_width
		end

		if line_width >= width then
			iLine = iLine + 1
			pLines[iLine] = (pLines[iLine] or "").." "..v
		else
			pLines[iLine] = (pLines[iLine] or "").." "..v
		end
	end

	local sOutput = ""

	for k,v in pairs(pLines) do
		sOutput = sOutput.."\n"..v
	end

	local iHeight = dxGetFontHeight( 1, font ) * ( #pLines+2 )

	return sOutput, math.floor(iWidthMax), math.floor(iHeight)
end

----------------------------------------------------------------------------------------------
-- Сохранение временных данных 
----------------------------------------------------------------------------------------------

function SaveEventContent( content )
    ResetEventContent( EVENT_NAME )
    local file = fileCreate( EVENT_NAME )
    local content_json = toJSON( content, true )
    fileWrite( file, content_json )
    fileClose( file )
    return true
end

function LoadEventContent( )
    if fileExists( EVENT_NAME ) then
        local file = fileOpen( EVENT_NAME )
        local content_json = fileRead( file, fileGetSize( file ) )
        local content = content_json and fromJSON( content_json ) or { }
        fileClose( file )
        return content
    end
    return false
end

function ResetEventContent()
    if fileExists( EVENT_NAME ) then fileDelete( EVENT_NAME ) end
end