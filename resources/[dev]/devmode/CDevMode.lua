loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )

local x = guiGetScreenSize( )

local sx, sy = 500, 61
local header = ibCreateImage( math.min( x / 2 - sx / 2, x - 380 - sx ), 20, sx, sy, "img/1.png" )

local toggle = ibCreateImage( header:ibData( "px" ), header:ibGetAfterY( 10 ), 0, 0, "img/2.png" ):ibSetRealSize( ):ibData( "alpha", 0 )

bindKey( "r", "both", function( _, state )
    toggle:ibAlphaTo( state == "down" and 255 or 0, 500 )
end )