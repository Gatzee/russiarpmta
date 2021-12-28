local getElementData = getElementData
local getBlipIcon = getBlipIcon

CONST_6K = 6520
CONST_3K = CONST_6K / 2

CONST_RADAR_SCALE_FACTOR = CONST_6K / 6000
--CONST_RADAR_CENTER_OFFSET_X = -68
--CONST_RADAR_CENTER_OFFSET_Y = 385
CONST_RADAR_CENTER_OFFSET_Y = 860
CONST_RADAR_CENTER_OFFSET_X = -68

CONST_RADAR_RENDERABLE_SIZE = 3000
CONST_RADAR_RENDERABLE_SIZE_SCALE = CONST_RADAR_RENDERABLE_SIZE / CONST_6K

CONST_MINIMAP_SIZE = 4096
CONST_MINIMAP_SIZE_SCALE = CONST_MINIMAP_SIZE / CONST_6K

CONST_RADAR_ZOOM = 12
CONST_RADAR_ZOOM_HALF = CONST_RADAR_ZOOM / 2
CONST_RADAR_ZOOM_INV = 1 / CONST_RADAR_ZOOM

CONST_ARROW_SIZE = 32
CONST_ARROW_SIZE_MAX = CONST_ARROW_SIZE * 2

CONST_RADAR_BOX_SIZE = 248
CONST_RADAR_BOX_SIZE_HALF = CONST_RADAR_BOX_SIZE / 2

CONST_GAME_COORDS_TO_RADAR_RATIO = CONST_RADAR_ZOOM * CONST_RADAR_BOX_SIZE / CONST_6K

CONST_RADAR_BLIPS_REFRESH_RATE = 100

CONST_RADAR_BLIP_SIZE = 64
CONST_RADAR_BLIP_SIZE_HALF = CONST_RADAR_BLIP_SIZE / 2

CONST_RENDERABLE_BLIPS = {
    [ 0 ] = true,
}

CONST_BLIPS_SIZE_MUL = {
    [ 0 ] = 0.5,
}

addEvent( "RefreshRadarBlips", true )

local math_min = math.min

HUD_CONFIGS.radar = {
    elements = { },
    fns = { },
    independent = true, -- Не управлять позицией худа
    create = function( self )
        local x, y = guiGetScreenSize( )

        local bg = ibCreateArea( 20, y - 268, 248, 248 )

        if getTargetOnMap( ) then bg:ibData( "visible", false ) end

        local outline_color = ibApplyAlpha( 0xff212b36, 75 )
        ibCreateImage( 0, 0, 248, 2, _, bg, outline_color )
        ibCreateImage( 0, 246, 248, 2, _, bg, outline_color )

        ibCreateImage( 0, 2, 2, 244, _, bg, outline_color )
        ibCreateImage( 246, 2, 2, 244, _, bg, outline_color )

        local bg_img = ibCreateImage( 2, 2, 244, 244, _, bg, ibApplyAlpha( 0xffffffff, 50 ) )

        local icon_player = ibCreateImage( 0, 0, 24, 24, "img/radar/icon_player.png", bg_img ):center( )

        local icon_inventory_full = ibCreateImage( 206, 206, 32, 32, "img/radar/icon_inventory_full.png", bg_img ):ibData( "alpha", 0 )

        local prewanted_img = ibCreateImage( 0, 0, 244, 244, _, bg_img ):ibData( "alpha", 0 )
        prewanted_img:ibTimer( function( )
            if localPlayer:getData( "prewanted" ) then
                prewanted_img:ibData( "alpha", 255 )
                local is_red = prewanted_img:ibData( "texture" ) == "img/radar/wanted_red.png"
                prewanted_img:ibData( "texture", is_red and "img/radar/wanted_blue.png" or "img/radar/wanted_red.png" )
            else
                prewanted_img:ibData( "alpha", 0 )
            end

            icon_inventory_full:ibData( "alpha", localPlayer:getData( "is_inventory_full" ) and 255 or 0 )
        end, 500, 0 )

        local bg_hint = ibCreateImage( 10, 239, 18, 18, _, bg, outline_color )
        ibCreateLabel( 0, 0, 0, 0, "M", bg_hint, COLOR_WHITE, _, _, "center", "center", ibFonts.bold_10 ):ibData( "subpixel", true ):center( )
            
        self.elements.shader                 = dxCreateShader( "fx/hud_mask.fx" )
        self.elements.overlay_texture        = dxCreateRenderTarget( CONST_MINIMAP_SIZE, CONST_MINIMAP_SIZE, true )
        self.elements.overlay_render_texture = dxCreateRenderTarget( CONST_RADAR_RENDERABLE_SIZE, CONST_RADAR_RENDERABLE_SIZE, true )

        dxSetShaderValue( self.elements.shader, "TexOverlay", self.elements.overlay_texture )
        dxSetShaderValue( self.elements.shader, "TexOverlayRender", self.elements.overlay_render_texture )
        dxSetShaderValue( self.elements.shader, "gUVScale", CONST_RADAR_ZOOM_INV, CONST_RADAR_ZOOM_INV )
        dxSetShaderValue( self.elements.shader, "fMapAlphaMul", 0.95 )
        dxSetShaderValue( self.elements.shader, "fAlphaMul", 1 )
            
        bg_img:ibData( "texture", self.elements.shader )

        local function GetBlips( )
            local blips = getElementsByType( "blip" )
            local radarareas = getElementsByType( "radararea" )
            local interior = getElementInterior( localPlayer )
            local dimension = getElementDimension( localPlayer )

            local suitable_blips = { }
            for i, v in pairs( blips ) do
                if v.dimension == dimension and v.interior == interior and not v:getData( "is_hide" ) then
                    table.insert( suitable_blips, v )
                end
            end
        for i, v in pairs( radarareas ) do
            if v.dimension == dimension and v.interior == interior then
                table.insert( suitable_blips, v )
            end
        end

        return suitable_blips
        end

        self.icons_arrows = { }
        self.cache = { textures = {} }

        self.fns.UpdateBlips = function( is_gps )
            if not is_gps then
                for k, v in pairs( self.cache ) do
                    if type( k ) ~= "string" and not isElement( k ) then self.cache[ k ] = nil end
                end

                for i, v in pairs( self.icons_arrows ) do if isElement( v[ 1 ] ) then destroyElement( v[ 1 ] ) end end
                self.icons_arrows = { }
            end

            dxSetRenderTarget( self.elements.overlay_texture, true )
                if GPS.draw_path then
                    for i = #GPS.draw_path - 1, 1, -1 do
                        local start_node = GPS.draw_path[ i ] 
                        local finish_node = GPS.draw_path[ i - 1 ]
                        if start_node and finish_node then
                            local dpx, dpy = ( start_node.x + CONST_3K - CONST_RADAR_CENTER_OFFSET_X ) / CONST_6K * CONST_MINIMAP_SIZE, ( 1 - ( start_node.y + CONST_3K - CONST_RADAR_CENTER_OFFSET_Y ) / CONST_6K ) * CONST_MINIMAP_SIZE
                            local tpx, tpy = ( finish_node.x + CONST_3K - CONST_RADAR_CENTER_OFFSET_X ) / CONST_6K * CONST_MINIMAP_SIZE, ( 1 - ( finish_node.y + CONST_3K - CONST_RADAR_CENTER_OFFSET_Y ) / CONST_6K ) * CONST_MINIMAP_SIZE
                            dxDrawLine( dpx, dpy, tpx, tpy, 0xFFFF8800, 6 )
                        end
                    end
                end
                
                for i, v in pairs( getElementsByType( "blip" ) ) do
                    local icon = getElementData( v, 'extra_blip' ) or getBlipIcon( v )
                    if icon > 0 and v.dimension == localPlayer.dimension and not capture and not v:getData( "is_hide" ) then
                        local points = { [ 41 ] = true, [ 80 ] = true, [ 81 ] = true, [ 84 ] = true, }
                        if points[ icon ] then
                            if not is_gps then
                                if not self.cache[ v ] then
                                    self.cache[ v ] = {}
                                    self.cache[ v ].icon = icon
                                    self.cache.textures[ icon ] = dxCreateTexture( "img/radar/blips/" .. icon .. ".png" )
                                end
                                
                                local color = getElementData( v, "extra_blip_color" ) or 0xFFFFFFFF
                                local img = ibCreateImage( 0, 0, 0, 0, self.cache.textures[ icon ], bg_img, color ):ibData( "alpha", 0 ):ibAlphaTo( 255, 500 )
                                self.icons_arrows[ v ] = { img }
                            end
                        else
                            local px, py = getElementPosition( v )
                            if not self.cache[ v ] then
                                self.cache[ v ] = {}
                                self.cache[ v ].icon = icon
                                self.cache[ v ].scale = math_min( getBlipSize( v ) / 2, 2 )
                                self.cache[ v ].px, self.cache[ v ].py = px, py

                                self.cache[ v ].dpx, self.cache[ v ].dpy = ( self.cache[ v ].px + CONST_3K - CONST_RADAR_CENTER_OFFSET_X ) / CONST_6K * CONST_MINIMAP_SIZE, ( 1 - ( self.cache[ v ].py + CONST_3K - CONST_RADAR_CENTER_OFFSET_Y ) / CONST_6K ) * CONST_MINIMAP_SIZE

                                self.cache[ v ].icon_size = self.cache[ v ].scale * CONST_RADAR_BLIP_SIZE * CONST_MINIMAP_SIZE_SCALE
                                self.cache[ v ].icon_size_half = self.cache[ v ].icon_size / 2

                                self.cache[ v ].dpx, self.cache[ v ].dpy = self.cache[ v ].dpx - self.cache[ v ].icon_size_half, self.cache[ v ].dpy - self.cache[ v ].icon_size_half

                                if not self.cache.textures[ icon ] then self.cache.textures[ icon ] = dxCreateTexture( "img/radar/blips/" .. icon .. ".png" ) end
                            elseif px ~= self.cache[ v ].px or py ~= self.cache[ v ].py then
                                self.cache[ v ].px, self.cache[ v ].py = px, py
                                self.cache[ v ].dpx, self.cache[ v ].dpy = ( self.cache[ v ].px + CONST_3K - CONST_RADAR_CENTER_OFFSET_X ) / CONST_6K * CONST_MINIMAP_SIZE, ( 1 - ( self.cache[ v ].py + CONST_3K - CONST_RADAR_CENTER_OFFSET_Y ) / CONST_6K ) * CONST_MINIMAP_SIZE
                                self.cache[ v ].dpx, self.cache[ v ].dpy = self.cache[ v ].dpx - self.cache[ v ].icon_size_half, self.cache[ v ].dpy - self.cache[ v ].icon_size_half
                            end
                            
                            dxDrawImage( self.cache[ v ].dpx, self.cache[ v ].dpy, self.cache[ v ].icon_size, self.cache[ v ].icon_size, self.cache.textures[ icon ] )
                        end
                    end
                end

                for i, v in pairs( getElementsByType( "radararea" ) ) do
                    if not self.cache[ v ] then
                        self.cache[ v ] = {}
                        self.cache[ v ].px, self.cache[ v ].py = getElementPosition( v )
                        self.cache[ v ].sx, self.cache[ v ].sy = getRadarAreaSize( v )
                        self.cache[ v ].r, self.cache[ v ].g, self.cache[ v ].b, self.cache[ v ].a = getRadarAreaColor( v )
                        self.cache[ v ].dpx, self.cache[ v ].dpy = ( self.cache[ v ].px + CONST_3K - CONST_RADAR_CENTER_OFFSET_X ) / CONST_6K * CONST_MINIMAP_SIZE, ( 1 - ( self.cache[ v ].py + CONST_3K - CONST_RADAR_CENTER_OFFSET_Y ) / CONST_6K ) * CONST_MINIMAP_SIZE
                        self.cache[ v ].dsx, self.cache[ v ].dsy = self.cache[ v ].sx * CONST_MINIMAP_SIZE_SCALE, self.cache[ v ].sy * CONST_MINIMAP_SIZE_SCALE
                        self.cache[ v ].color = tocolor( self.cache[ v ].r, self.cache[ v ].g, self.cache[ v ].b, self.cache[ v ].a )
                    end

                    dxDrawRectangle( self.cache[ v ].dpx, self.cache[ v ].dpy, self.cache[ v ].dsx, self.cache[ v ].dsy, self.cache[ v ].color )
                end
            dxSetRenderTarget( )
        end
        addEventHandler( "RefreshRadarBlips", localPlayer, self.fns.UpdateBlips )
        addEventHandler( "onClientRestore", root, self.fns.UpdateBlips )

        local function GetInBoundPosition( x, y, px, py )
            local delta_px, delta_py = px - x, py - y
            delta_px, delta_py = delta_px * CONST_GAME_COORDS_TO_RADAR_RATIO, delta_py * CONST_GAME_COORDS_TO_RADAR_RATIO

            local scale = math.max( math.abs( delta_px / CONST_RADAR_BOX_SIZE_HALF ), math.abs( delta_py / CONST_RADAR_BOX_SIZE_HALF ), 1 )
            delta_px, delta_py = delta_px / scale, delta_py / scale

            return delta_px, delta_py, scale
        end

        local pic_texture_current
        bg_img:ibOnRender( function( )
            local texture = GetRadarMapTexture( )
            if pic_texture_current ~= texture then
                dxSetShaderValue( self.elements.shader, "sPicTexture", texture )
                pic_texture_current = texture
            end

            local source_physics = getCameraTarget( localPlayer ) or getCamera( )

            local x, y = getElementPosition( source_physics )
            dxSetShaderValue( self.elements.shader, "gUVPosition", ( x - CONST_RADAR_CENTER_OFFSET_X ) / CONST_6K, ( y - CONST_RADAR_CENTER_OFFSET_Y ) / -CONST_6K )

            local _, _, rz = getElementRotation( source_physics )
            icon_player:ibData( "rotation", -rz )

            for i, v in pairs( self.icons_arrows ) do
                local element, image = i, v[ 1 ]

                if isElement( element ) and isElement( image ) then
                    local px, py, pz = getElementPosition( element )
                    local delta_px, delta_py, scale = GetInBoundPosition( x, y, px, py )

                    local target_size

                    if scale > 1 then
                        target_size = CONST_ARROW_SIZE
                    else
                        target_size = CONST_ARROW_SIZE_MAX
                    end

                    if v[ 2 ] ~= target_size then
                        image:ibResizeTo( target_size, target_size, 1500 )
                        v[ 2 ] = target_size
                    end

                    local sx, sy = image:ibData( "sx" ) / 2, image:ibData( "sy" ) / 2

                    image:ibBatchData( {
                        px = CONST_RADAR_BOX_SIZE_HALF + delta_px - sx,
                        py = CONST_RADAR_BOX_SIZE_HALF - delta_py - sy
                    } )
                else
                    self.fns.UpdateBlips( )
                end

            end

            dxSetRenderTarget( self.elements.overlay_render_texture, true )
                -- Движующиеся элементы, вызовы фракций, др.
                for i, v in pairs( getElementsByType( "blip" ) ) do
                    local icon = getElementData( v, 'extra_blip' ) or getBlipIcon( v )
                    if CONST_RENDERABLE_BLIPS[ icon ] and (v:getData( "ignore_dimension" ) or v.dimension == localPlayer.dimension) and not v:getData( "is_hide" ) then
                        local px, py = getElementPosition( v )

                        local dpx, dpy = ( px + CONST_3K - CONST_RADAR_CENTER_OFFSET_X ) / CONST_6K * CONST_RADAR_RENDERABLE_SIZE, ( 1 - ( py + CONST_3K - CONST_RADAR_CENTER_OFFSET_Y ) / CONST_6K ) * CONST_RADAR_RENDERABLE_SIZE

                        local r, g, b = getBlipColor( v )

                        local scale = math.min( getBlipSize( v ) / 2, 2 ) * CONST_RADAR_RENDERABLE_SIZE_SCALE

                        local icon_size = scale * CONST_RADAR_BLIP_SIZE * ( CONST_BLIPS_SIZE_MUL[ icon ] or 1 )
                        local icon_size_half = icon_size / 2
                        
                        dxDrawRectangle( dpx - icon_size_half, dpy - icon_size_half, icon_size, icon_size, tocolor( r, g, b, 255 ) )
                    end
                end
            dxSetRenderTarget( )
        end )

        local last_blips = { }
        bg_img:ibTimer( function( )
            local function reverse( tbl )
                local n = { }
                for i, v in pairs( tbl ) do
                    n[ v ] = true
                end
                return n
            end

            local function blips_identical( tbl1, tbl2 )
                for i, v in pairs( tbl1 ) do
                    if not tbl2[ i ] then
                        return false
                    end 
                end

                for i, v in pairs( tbl2 ) do
                    if not tbl1[ i ] then
                        return false
                    end 
                end

                return true
            end

            local blips = GetBlips( )
            local blips_updated = not blips_identical( reverse( blips ), reverse( last_blips ) )
            
            if blips_updated then
                self.fns.UpdateBlips( )
                last_blips = blips
            end
        end, CONST_RADAR_BLIPS_REFRESH_RATE, 0 )

        table.insert( self.elements, bg )
        return bg
    end,

    destroy = function( self )
        if self.fns.UpdateBlips then
            removeEventHandler( "onClientRestore", root, self.fns.UpdateBlips )
            removeEventHandler( "RefreshRadarBlips", localPlayer, self.fns.UpdateBlips )
        end

        for i, v in pairs( self.icons_arrows or { } ) do if isElement( v[ 1 ] ) then destroyElement( v[ 1 ] ) end end
        self.icons_arrows = nil

        DestroyTableElements( self.elements )
        self.elements = { }
    end,
}

function CanRadarBeShown( )
    return localPlayer.interior == 0 
           and not localPlayer:getData( "is_in_wardrobe" )
           and not localPlayer:getData( "drag_race" )
end

function Radar_onStart( )
    AddHUDBlock( "radar" )

    setPlayerHudComponentVisible( "radar", false )

    setTimer( function( )
        setPlayerHudComponentVisible( "radar", false )
        toggleControl( "radar", false )

        if not CanRadarBeShown( ) and not getTargetOnMap( ) then
            RemoveHUDBlock( "radar" )
            HideRadarMap( )
        else
            AddHUDBlock( "radar" )
        end
    end, 100, 0 )
end
addEventHandler( "onClientResourceStart", resourceRoot, Radar_onStart )

if getMapTexture then
    GetRadarMapTexture = getMapTexture
else
    local MAP_TEXTURE
    function GetRadarMapTexture( )
        if not isElement( MAP_TEXTURE ) then
            MAP_TEXTURE = dxCreateTexture( "img/radar/map.dds", "dxt1" )
        end
        return MAP_TEXTURE
    end
end