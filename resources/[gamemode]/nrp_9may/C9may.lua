loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "CInterior" )
Extend( "ShUtils" )

local RIBBONS_POSITIONS = { }
local RIBBONS_TEXTURE = nil
local RIBBONS_MARKERS = { }

local RIBBONS_SIZE = 1.5

function On9mayRibbonsLoad_handler( list )
	RIBBONS_POSITIONS = list
    if #RIBBONS_POSITIONS > 0 then
        for i, v in pairs( RIBBONS_POSITIONS ) do
            local package = table.copy( v )
            package.elements = { }
            package.elements.marker = Marker( package.x, package.y, package.z + 0.9, "corona", 1.5, 255, 0, 0, 120 )
            package.color = { 0, 0, 0, 0 }
            package.z = package.z + 1
            package.keypress = false
            package.radius = 2.5
            package.listpos = i
            package.PreJoin = function( self, player )
                if localPlayer ~= player then return end
                return true
            end
            package.PostJoin = function( self, player )
                player:InfoWindow( "Собери все ленточки для Соколова и получишь доступ к уникальному квесту с большой наградой" )
                local current_position = self.listpos
                table.remove( RIBBONS_POSITIONS, current_position )
                table.remove( RIBBONS_MARKERS, current_position )
                self:destroy()
                triggerServerEvent( "On9mayLetterFind", player, current_position )
                for i, v in pairs( RIBBONS_MARKERS ) do
                    v.listpos = i
				end
				
				if not next( RIBBONS_MARKERS ) then
					removeEventHandler( "onClientPreRender", root, RenderRibbons )
					destroyElement( RIBBONS_TEXTURE )
				end
            end
            local tpoint = TeleportPoint( package )
            tpoint.marker:setColor( unpack( package.color ) )

            RIBBONS_MARKERS[ i ] = tpoint
        end
		RIBBONS_TEXTURE = dxCreateTexture( "images/world_icon.png" )
        addEventHandler( "onClientPreRender", root, RenderRibbons )
    end
end
addEvent( "On9mayRibbonsLoad", true )
addEventHandler( "On9mayRibbonsLoad", root, On9mayRibbonsLoad_handler )

function RenderRibbons()
    local rotation_angle = math.rad( ( getTickCount() / 10 ) % 360 )

    for i, v in pairs( RIBBONS_POSITIONS ) do
        local letter_number = v.letter
        local x, y, z = v.x, v.y, v.z + 1


        if UKNOWDAWAE then
            local screenx, screeny = getScreenFromWorldPosition( x, y, z )
            if screenx and screeny then
                local cx, cy, cz = getCameraMatrix()
                local distance = getDistanceBetweenPoints3D( x, y, z, cx, cy, cz )
                dxDrawText( "(" .. distance .. ")", screenx, screeny, screenx, screeny, 0xffffffff, 1, "default-bold", "center", "center" )
            end
        end

		dxDrawMaterialLine3D( 
            x, y, z + RIBBONS_SIZE / 2, 
            x, y, z - RIBBONS_SIZE / 2, 
            RIBBONS_TEXTURE, RIBBONS_SIZE, 0xffffffff, false,
            x + math.sin( rotation_angle ), y + math.cos( rotation_angle ), z
        )
    end
end


local txd = engineLoadTXD( "models/rhino.txd" )
engineImportTXD( txd, 432 )
local dff = engineLoadDFF( "models/rhino.dff" )
engineReplaceModel( dff, 432 )

local txd = engineLoadTXD( "models/swatvan.txd" )
engineImportTXD( txd, 601 )
local dff = engineLoadDFF( "models/swatvan.dff" )
engineReplaceModel( dff, 601 )