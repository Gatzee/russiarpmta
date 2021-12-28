loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "ShUtils" )
Extend( "CPlayer" )
Extend( "Globals" )
Extend( "CInterior" )

ibUseRealFonts( true )

local FLOWERS_POSITIONS = { }
local FLOWERS_TEXTURE = nil
local FLOWERS_MARKERS = { }

local FLOWERS_SIZE = 1.5

function OnEventFlowersLoad_handler( list )
	FLOWERS_POSITIONS = list
    if #FLOWERS_POSITIONS > 0 then
        for i, v in pairs( FLOWERS_POSITIONS ) do
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
                if localPlayer.dimension ~= 0 then return end
                return true
            end
            package.PostJoin = function( self, player )
                triggerServerEvent( "OnEventFlowerCollected", player, current_position )

                local current_position = self.listpos
                table.remove( FLOWERS_POSITIONS, current_position )
                table.remove( FLOWERS_MARKERS, current_position )
                self:destroy()

                for i, v in pairs( FLOWERS_MARKERS ) do
                    v.listpos = i
				end
				
				if not next( FLOWERS_MARKERS ) then
					removeEventHandler( "onClientPreRender", root, RenderFlowers )
					destroyElement( FLOWERS_TEXTURE )
				end
            end
            local tpoint = TeleportPoint( package )
            tpoint.marker:setColor( unpack( package.color ) )

            FLOWERS_MARKERS[ i ] = tpoint
        end
		FLOWERS_TEXTURE = dxCreateTexture( "files/img/rose.png" )
        addEventHandler( "onClientPreRender", root, RenderFlowers )
    end
end
addEvent( "OnEventFlowersLoad", true )
addEventHandler( "OnEventFlowersLoad", root, OnEventFlowersLoad_handler )

--UKNOWDAWAE = true

function RenderFlowers()
    if localPlayer.dimension ~= 0 then return end

    local rotation_angle = math.rad( ( getTickCount() / 10 ) % 360 )

    for i, v in pairs( FLOWERS_POSITIONS ) do
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
            x, y, z + FLOWERS_SIZE / 2, 
            x, y, z - FLOWERS_SIZE / 2, 
            FLOWERS_TEXTURE, FLOWERS_SIZE, 0xffffffff, false,
            x + math.sin( rotation_angle ), y + math.cos( rotation_angle ), z
        )
    end
end

function CreateQuestMarker( position )
	triggerEvent( "ToggleGPS", localPlayer, Vector3( position.x, position.y, position.z ) )
end
addEvent("CreateQuestMarker", true)
addEventHandler("CreateQuestMarker", resourceRoot, CreateQuestMarker)