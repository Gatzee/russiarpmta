loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "CInterior" )

PACKAGES = {}
PACKAGE_MARKER_DIFFERENCE = -0.21
PACKAGE_MARKER_COLOR = { 10, 98, 87 }

function CreatePackage( package_number, x, y, z )
    local package = { x = x, y = y, z = z }

    local object = Object( 3052, package.x, package.y, package.z, 0, 0, math.random( 0, 360 ) )
    local corona = Marker( package.x, package.y, package.z + PACKAGE_MARKER_DIFFERENCE, "corona", 1, unpack( PACKAGE_MARKER_COLOR ) )

    package.elements = { }
    package.elements.object = object
    package.elements.corona = corona
    
    package.color = { 0, 0, 0, 0 }
    package.z = package.z + 1
    package.keypress = false
    package.radius = 2.5
    package.package_number = package_number
    package.PreJoin = function( self, player )
        if not player:IsInClan() then 
            player:ShowNotification( "Только бандиты могут забирать закладки!" ) 
            return false
        end
        return true
    end
    package.PostJoin = function( self, player )
        if not player:IsInClan() then
            player:ShowError( "Порядочные граждане не трогают закладки" )
            return
        end
        triggerServerEvent( "onServerPlayerTakeClanPackage", localPlayer, package_number )
        self:destroy()
    end

    local tpoint = TeleportPoint( package )
    table.insert( PACKAGES, { package_number, tpoint } )

end

addEvent( "onClientCreateClanPackages", true )
addEventHandler( "onClientCreateClanPackages", resourceRoot, function( package_data )
    for k, v in pairs( PACKAGES ) do
        if v[ 2 ] then
            v[ 2 ]:destroy()
        end
    end
    PACKAGES = {}
    for k, v in pairs( package_data ) do
        CreatePackage( unpack( v ) )
    end
end )


addEvent( "onClientDeleteClanPackage", true )
addEventHandler( "onClientDeleteClanPackage", resourceRoot, function( package_number )
    for k, v in pairs( PACKAGES ) do
        if v[ 1 ] == package_number then
            v[ 2 ]:destroy()
            PACKAGES[ k ] = nil
            break
        end
    end
end )