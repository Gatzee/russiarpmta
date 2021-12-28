BezierCurve = { }
local BezierCurve_mt = { __index = BezierCurve }

function BezierCurve:new( )
    local self = { }
    setmetatable( self, BezierCurve_mt )
    return self
end

function BezierCurve:compute( points, density )
    self.curve = { }
    self.points = points
    self:ComputeBezier( points, density )
end

function BezierCurve:debug_draw( color, width )
    local self = self 

    self:debug_draw_stop( )

    self.draw_fn = function( )
        for i = 1,( #self.curve ) - 1 do
            dxDrawLine3D( self.curve[i].x, self.curve[i].y, localPlayer.position.z, self.curve[i+1].x, self.curve[i+1].y, localPlayer.position.z, color or 0xFFFFFFFF, width or 1, false )
        end
        dxDrawLine3D( self.points[ 1 ].x, self.points[ 1 ].y, localPlayer.position.z, self.points[ 2 ].x, self.points[ 2 ].y, localPlayer.position.z, 0xFF00FF00, 3 )
        dxDrawLine3D( self.points[ 3 ].x, self.points[ 3 ].y, localPlayer.position.z, self.points[ 4 ].x, self.points[ 4 ].y, localPlayer.position.z, 0xFF0000FF, 3 )
    end
    addEventHandler( "onClientPreRender", root, self.draw_fn )
end

function BezierCurve:debug_draw_stop( )
    if self.draw_fn then
        removeEventHandler( "onClientPreRender", root, self.draw_fn )
        self.draw_fn = nil
    end
end

function BezierCurve:PointOnCubicBezier( cp, t )
    local ax, bx, cx
    local ay, by, cy
    local tSquared, tCubed
    local result = Vector2( 0,0 )
 
  --  /* calculation of the polinomial coeficients */
 
    cx = 3.0 * (cp[2].x - cp[1].x)
    bx = 3.0 * (cp[1].x - cp[2].x) - cx
    ax = cp[4].x - cp[1].x - cx - bx
 
    cy = 3.0 * (cp[2].y - cp[1].y)
    by = 3.0 * (cp[3].y - cp[2].y) - cy
    ay = cp[4].y - cp[1].y - cy - by
 
  --  /* calculate the curve point at parameter value t */
 
    tSquared = t * t
    tCubed = tSquared * t
 
    result.x = (ax * tCubed) + (bx * tSquared) + (cx * t) + cp[1].x
    result.y = (ay * tCubed) + (by * tSquared) + (cy * t) + cp[1].y
 
    return result
end

function BezierCurve:ComputeBezier( cp, numberOfPoints ) 
    local dt
    local i
 
    dt = 1.0 / ( numberOfPoints - 1 )
 
    for i = 1, numberOfPoints do
        self.curve[i] = self:PointOnCubicBezier( cp, i*dt )
        i = i + 1
    end
end