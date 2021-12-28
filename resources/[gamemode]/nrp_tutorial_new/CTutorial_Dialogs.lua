function CreateTip( id )
    local area = ibCreateArea( 0, 0, _SCREEN_X, _SCREEN_Y ):ibData( "alpha", 0 )

    ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, _, area, 0x99000000 ):ibData( "alpha", 0 )

    local hint = ibCreateImage( 0, 0, 0, 0, "img/tips/" .. id .. ".png", area )
    hint:ibSetRealSize( ):center_x( ):ibData( "py", _SCREEN_Y - 30 - hint:ibData( "sy" ) )
    
    area:ibAlphaTo( 255, 500 )

    return area
end

function SetTipImportant( area )
    if isElement( area ) then
        local children = getElementChildren( area )
        local background, hint = children[ 1 ], children[ 2 ]

        background:ibAlphaTo( 255, 500 )
        hint:ibMoveTo( _, _SCREEN_Y_HALF - hint:ibData( "sy" ) / 2, 500 )
    end
end

function DestroyTip( area )
    if isElement( area ) then
        area:ibAlphaTo( 0, 300 ):ibTimer( function( self ) destroyElement( self ) end, 300, 1 )
    end
end