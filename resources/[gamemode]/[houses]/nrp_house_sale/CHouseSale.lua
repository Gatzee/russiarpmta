Extend( "ib" )
Extend( "Globals" )
Extend( "CPlayer" )
Extend( "CInterior" )

CONST_HOUSE_TYPE_INFO = {
    [ CONST_HOUSE_TYPE.VILLA     ] = { name = "Вилла",             value = CONST_HOUSE_TYPE.VILLA,      image = "villa.png",     },
    [ CONST_HOUSE_TYPE.COTTAGE   ] = { name = "Коттедж",           value = CONST_HOUSE_TYPE.COTTAGE,    image = "cottage.png",   },
    [ CONST_HOUSE_TYPE.COUNTRY   ] = { name = "Деревенский домик", value = CONST_HOUSE_TYPE.COUNTRY,    image = "village.png",   },
    [ CONST_HOUSE_TYPE.APARTMENT ] = { name = "Квартира",          value = CONST_HOUSE_TYPE.APARTMENT,  image = "apartment.png", },
}

SALE_MARKERS =
{
    -- Новороссийск
    [1] = {
        ["marker"] = {
            x           = -28.22,
            y           = -866,
            z           = 1047.528,
            radius      = 2,
            interior    = 1,
            dimension   = 1,
            keypress    = "lalt",
            marker_text = "Продажа недвижимости",
            text        = "ALT Взаимодействие",
            color       = { 0, 150, 255, 50 }
        },
        ["npc"] =  {
            name        = "Сотрудник мэрии",
            position    = Vector3( { x = -29.538, y = -863.595, z = 1047.537 } ),
            rotation    = 180,
            interior    = 1,
            dimension   = 1,
        },
    },

    -- Горки
    [2] = {
        ["marker"] = {
            x           = 2278.746,
            y           = -86.208,
            z           = 670.997,
            radius      = 2.5,
            interior    = 1,
            dimension   = 1,
            keypress    = "lalt",
            marker_text = "Продажа недвижимости",
            text        = "ALT Взаимодействие",
            color       = { 0, 150, 255, 0 }
        },

        ["npc"] =  {
            name        = "Сотрудник мэрии",
            position    = Vector3( { x = 2278.836, y = -88.034, z = 670.997 } ),
            rotation    = 0,
            interior    = 1,
            dimension   = 1,
        },
    },

    [3] = {
        ["marker"] = {
            x           = 1335.5450,
            y           = 2435.6635,
            z           = 2285.5500,
            radius      = 2.5,
            interior    = 3,
            dimension   = 1,
            keypress    = "lalt",
            marker_text = "Продажа недвижимости",
            text        = "ALT Взаимодействие",
            color       = { 0, 150, 255, 0 }
        },

        ["npc"] =  {
            name        = "Сотрудник мэрии",
            position    = Vector3( { x = 1335.6727, y = 2437.0410, z = 2285.5571 } ),
            rotation    = 180,
            interior    = 3,
            dimension   = 1,
        },
    }
}


function CreateHouseSaleMarker( config )
    local sale_marker = TeleportPoint( config.marker )

    sale_marker:SetImage( "images/marker.png" )
    sale_marker.element:setData( "material", true, false )
    sale_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.5 } )

    sale_marker.PreJoin = function( self, player )
        return true
    end
    sale_marker.PostJoin = function( self )
        ShowChooseActionView( true )
    end
    sale_marker.PostLeave = function( self )
        ShowChooseActionView( false )
    end

    local npc = Ped( 1, config.npc.position )
    npc.interior = config.npc.interior
    npc.dimension = config.npc.dimension
    npc.rotation = Vector3( 0, 0, config.npc.rotation )
    npc.frozen = true

    local function RenderNpcName( )
        local x, y, z = getCameraMatrix()
        local cam_vector = Vector3( x, y, z )
        local distance = ( config.npc.position - cam_vector ).length

        if distance > 15 then return end

        local scale = math.min( 5 / distance, 2.5 )
        local scx, scy = getScreenFromWorldPosition( config.npc.position + Vector3( 0, 0, 0.9 ) )
        if scx and scy then
            dxDrawText( config.npc.name, scx+0.4, scy+0.4, scx+0.4, scy+0.4, 0xff000000, scale, "default-bold", "center", "center" )
            dxDrawText( config.npc.name, scx, scy, scx, scy, 0xffffe2a7, scale, "default-bold", "center", "center" )
        end
    end

    addEventHandler( "onClientElementStreamIn", npc, function ( )
        addEventHandler("onClientHUDRender", root, RenderNpcName )
    end )

    addEventHandler( "onClientElementStreamOut", npc, function ( )
        removeEventHandler("onClientHUDRender", root, RenderNpcName )
    end )

    addEventHandler( "onClientPedDamage", npc, cancelEvent )
end

for k, conf in pairs( SALE_MARKERS ) do
    CreateHouseSaleMarker( conf )
end
