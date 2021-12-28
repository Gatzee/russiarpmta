function generateTriangleTexture( x, y, ibParent, controllability, clutch, slip, controllabilityNew, clutchNew, slipNew )
    local triangle = ibCreateImage( x, y, 130, 114, "img/triangle.png", ibParent )

    local function correctPoint( parameter )
        parameter = parameter < 0 and 0 or parameter
        parameter = parameter > 100 and 100 or parameter
        return parameter
    end

    local controllabilityValue = correctPoint( controllability ) / 100 * 66
    local controllabilityX = 59
    local controllabilityY = 64 - controllabilityValue
    local clutchValue = correctPoint( clutch ) / 100 * 44
    local clutchX = 63 + clutchValue * 1.35
    local clutchY = 77 + clutchValue * 0.8 - 6
    local slipValue = correctPoint( slip ) / 100 * 44
    local slipX = 56 - slipValue * 1.35
    local slipY = 77 + slipValue * 0.8 - 6

    local renderTarget = dxCreateRenderTarget( 130, 114, true )

    dxSetRenderTarget( renderTarget )
    dxDrawPrimitive( "trianglefan", false, controllabilityX + 7, controllabilityY + 6, 0xaa48617b, clutchX + 6, clutchY + 6, 0xaa48617b, 66, 76, 0xaa48617b )
    dxDrawPrimitive( "trianglefan", false, clutchX + 6, clutchY + 6, 0xaa3e5c7c, slipX + 5, slipY + 6, 0xaa3e5c7c, 65, 76, 0xaa3e5c7c )
    dxDrawPrimitive( "trianglefan", false, slipX + 6, slipY + 6, 0xaa435f7c, controllabilityX + 6, controllabilityY + 6, 0xaa435f7c, 65, 75, 0xaa435f7c )

    dxDrawPrimitive( "linestrip", false, controllabilityX + 6, controllabilityY + 5, 0x55000000, clutchX + 5, clutchY + 5, 0x55000000 )
    dxDrawPrimitive( "linestrip", false, clutchX + 6, clutchY + 7, 0x55000000, slipX + 5, slipY + 7, 0x55000000 )
    dxDrawPrimitive( "linestrip", false, slipX + 6, slipY + 5, 0x55000000, controllabilityX + 5, controllabilityY + 5, 0x55000000 )
    dxSetRenderTarget( )

    local texture = dxCreateTexture( dxGetTexturePixels( renderTarget, 0, 0, 130, 114 ) )
    renderTarget:destroy( )

    ibCreateImage( 0, 0, 130, 114, texture, triangle )

    triangle:ibOnDestroy( function ( ) texture:destroy( ) end )

    ibCreateImage( 53, - 34, 26, 26, "img/icon_controllability.png", triangle )
    :ibAttachTooltip( "Управляемость " .. correctPoint( controllability ) .. "%" )
    ibCreateImage( 140, 106, 28, 28, "img/icon_clutch.png", triangle )
    :ibAttachTooltip( "Сцепление " .. correctPoint( clutch ) .. "%" )
    ibCreateImage( - 36, 106, 28, 28, "img/icon_slip.png", triangle )
    :ibAttachTooltip( "Скольжение " .. correctPoint( slip ) .. "%" )

    ibCreateButton( controllabilityX, controllabilityY, 12, 12, triangle, "img/point.png", "img/point_hover.png", "img/point_hover.png", 0xff486682, 0xff486682, 0xff486682 )
    :ibAttachTooltip( correctPoint( controllability ) .. "%" )

    ibCreateButton( clutchX, clutchY, 12, 12, triangle, "img/point.png", "img/point_hover.png", "img/point_hover.png", 0xff486682, 0xff486682, 0xff486682 )
    :ibAttachTooltip( correctPoint( clutch ) .. "%" )

    ibCreateButton( slipX, slipY, 12, 12, triangle, "img/point.png", "img/point_hover.png", "img/point_hover.png", 0xff486682, 0xff486682, 0xff486682 )
    :ibAttachTooltip( correctPoint( slip ) .. "%" )

    if controllabilityNew and controllabilityNew ~= controllability then
        local controllabilityValue = correctPoint( controllabilityNew ) / 100 * 66
        local controllabilityX = 59
        local controllabilityY = 64 - controllabilityValue

        ibCreateButton( controllabilityX, controllabilityY, 12, 12, triangle,
        "img/point.png", "img/point_hover.png", "img/point_hover.png",
        0xffff965d, 0xffff965d, 0xffff965d )
        :ibAttachTooltip( correctPoint( controllabilityNew ) .. "%" )
    end

    if clutchNew and clutchNew ~= clutch then
        local clutchValue = correctPoint( clutchNew ) / 100 * 44
        local clutchX = 63 + clutchValue * 1.35
        local clutchY = 77 + clutchValue * 0.8 - 6

        ibCreateButton( clutchX, clutchY, 12, 12, triangle,
        "img/point.png", "img/point_hover.png", "img/point_hover.png",
        0xffff965d, 0xffff965d, 0xffff965d )
        :ibAttachTooltip( correctPoint( clutchNew ) .. "%" )
    end

    if slipNew and slipNew ~= slip then
        local slipValue = correctPoint( slipNew ) / 100 * 44
        local slipX = 56 - slipValue * 1.35
        local slipY = 77 + slipValue * 0.8 - 6

        ibCreateButton( slipX, slipY, 12, 12, triangle,
        "img/point.png", "img/point_hover.png", "img/point_hover.png",
        0xffff965d, 0xffff965d, 0xffff965d )
        :ibAttachTooltip( correctPoint( slipNew ) .. "%" )
    end

    return triangle
end