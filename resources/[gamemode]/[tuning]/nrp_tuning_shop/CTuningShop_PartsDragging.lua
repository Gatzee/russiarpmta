DRAG_TYPE_FROM_SHOP      = 1
DRAG_TYPE_FROM_INVENTORY = 2
DRAG_TYPE_FROM_VEHICLE   = 3

function CreateFloatingPart( part, drag_type )
    DestroyFloatingPart( )

    if not part then return end

    local cx, cy = getCursorPosition( )
    cx, cy = cx * x, cy * y
    setCursorAlpha( 0 )

    local bg = CreatePartElement( cx, cy, part, false )
    bg:ibAlphaTo( 255, 150, "OutQuad" )

    UI_elements.part_floating = bg
    UI_elements.part_floating_part = part
    UI_elements.part_floating_type = drag_type

    addEventHandler( "onClientCursorMove", root, RenderMoveFloatingPart )
    addEventHandler( "ibOnMouseRelease", bg, function( )
        DestroyFloatingPart( )
    end, true, "low" )
end

function IsFloatingPartVisible( )
    return isElement( UI_elements.part_floating )
end

function GetFloatingPart( )
    return UI_elements.part_floating_part
end

function ResetFloatingPart( )
    UI_elements.part_floating_part = nil
end

function GetFloatingPartDragType( )
    return UI_elements.part_floating_type
end

function DestroyFloatingPart( )
    setCursorAlpha( 255 )
    removeEventHandler( "onClientCursorMove", root, RenderMoveFloatingPart )

    if isElement( UI_elements.part_floating ) then destroyElement( UI_elements.part_floating ) end
end

function RenderMoveFloatingPart( _, _, ax, ay )
    if not IsFloatingPartVisible( ) then
        return DestroyFloatingPart( )
    end

    UI_elements.part_floating:ibBatchData( { px = ax - 43, py = ay - 43 } )
end