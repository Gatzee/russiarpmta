DRAG_TYPE_FROM_SHOP        = 1
DRAG_TYPE_FROM_SHOP_BOUGHT = 2
DRAG_TYPE_FROM_RADIAL      = 3


function CreateFloatingItem( index, item, drag_type )
    DestroyFloatingItem( )
    if not item then return end

    local cx, cy = getCursorPosition( )
    cx, cy = cx * scx, cy * scy

    local bg = CreateItemElement( cx, cy, index, item, drag_type )
    bg:ibAlphaTo( 255, 150, "OutQuad" )

    ui.item_floating = bg
    ui.item_floating_item = item
    ui.item_floating_type = drag_type

    removeEventHandler( "onClientClick", root, onMouseReleased )
    addEventHandler( "onClientClick", root, onMouseReleased )

    removeEventHandler( "onClientCursorMove", root, RenderMoveFloatingItem )
    addEventHandler( "onClientCursorMove", root, RenderMoveFloatingItem )
end

function CreateItemElement( px, py, index, item, drag_type )
    local bg
    if drag_type == DRAG_TYPE_FROM_SHOP or drag_type == DRAG_TYPE_FROM_SHOP_BOUGHT then
        bg = ibCreateImage( px, py, 80, 110, "files/img/rectangle.png" )
        ibCreateContentImage( 0, 0, 90, 90, "animation", index, bg ):center():ibData("disabled", true)
    else
        bg = ibCreateContentImage( px, py, 90, 90, "animation", index, bg )
    end
    return bg
end

function IsFloatingItemVisible( )
    return isElement( ui.item_floating )
end

function GetFloatingItem( )
    return ui.item_floating_item
end

function ResetFloatingItem( )
    ui.item_floating_item = nil
    ui.item_floating_type = nil
end

function GetFloatingItemDragType( )
    return ui.item_floating_type
end

function DestroyFloatingItem( )
    removeEventHandler( "onClientCursorMove", root, RenderMoveFloatingItem )
    if isElement( ui.item_floating ) then 
        destroyElement( ui.item_floating )
    end
end

function onMouseReleased( button, state )
    if button == "left" and state == "up" then
        removeEventHandler( "onClientClick", root, onMouseReleased )
        DestroyFloatingItem( )
    end
end

function RenderMoveFloatingItem( _, _, ax, ay )
    if not IsFloatingItemVisible( ) then
        return DestroyFloatingItem( )
    end
    ui.item_floating:ibBatchData( { px = ax + 10, py = ay + 10 } )
end