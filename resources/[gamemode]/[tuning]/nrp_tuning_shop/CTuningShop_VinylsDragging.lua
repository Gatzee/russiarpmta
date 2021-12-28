DRAG_TYPE_FROM_STYLE     = 1
DRAG_TYPE_FROM_INVENTORY = 2
DRAG_TYPE_FROM_VEHICLE   = 3

function CreateFloatingVinyl( vinyl, drag_type )
    DestroyFloatingVinyl( )

    if not vinyl then return end

    local cx, cy = getCursorPosition( )
    cx, cy = cx * x, cy * y
    setCursorAlpha( 0 )

    local bg = CreateVinylItem( cx, cy, 86, 86, vinyl, false )
    bg:ibAlphaTo( 255, 150, "OutQuad" )

    UI_elements.vinyl_floating = bg
    UI_elements.vinyl_floating_vinyl = vinyl
    UI_elements.vinyl_floating_type = drag_type

    addEventHandler( "onClientCursorMove", root, RenderMoveFloatingVinyl )

    addEventHandler( "ibOnMouseRelease", bg, function( )
        DestroyFloatingVinyl( )
    end, true, "low" )
end

function IsFloatingVinylVisible( )
    return isElement( UI_elements.vinyl_floating )
end

function GetFloatingVinyl( )
    return UI_elements.vinyl_floating_vinyl
end

function ResetFloatingVinyl( )
    UI_elements.vinyl_floating_vinyl = nil
end

function GetFloatingVinylDragType( )
    return UI_elements.vinyl_floating_type
end

function DestroyFloatingVinyl( )
    setCursorAlpha( 255 )
    removeEventHandler( "onClientCursorMove", root, RenderMoveFloatingVinyl )
    if isElement( UI_elements.vinyl_floating ) then
        destroyElement( UI_elements.vinyl_floating ) 
    end
end

function RenderMoveFloatingVinyl( _, _, ax, ay )
    if not IsFloatingVinylVisible( ) then
        return DestroyFloatingVinyl( )
    end
    UI_elements.vinyl_floating:ibBatchData( { px = ax - 43, py = ay - 43 } )
end