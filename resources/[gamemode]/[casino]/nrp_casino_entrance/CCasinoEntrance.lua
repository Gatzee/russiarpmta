loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "CPlayer" )
Extend( "CInterior" )

local conf = {
    -- Рублевка
    {
        -- Вход
        ex = 706.790, ey = -208.723, ez = 21.050 ,
		edimension = 0, 
		einterior = 0,
        emarker_text = "Казино\n`Три Топора`",

        -- Выход
		x = -92.0656, y = -500.775, z = 913.972,
		interior = 1,
        dimension = 1,
        marker_text = "Выход",

        radius = 1.5,

        casino_id = CASINO_THREE_AXE,
    },

    -- Москва
    {
        -- Вход
        ex = 2535.5012, ey = 2579.9140, ez = 8.0754,
		edimension = 0, 
		einterior = 0,
        emarker_text = "Казино\n`Москва`",

        -- Выход
		x = 2399.14, y = -1332.97, z = 2800.07,
		interior = 4,
        dimension = 1,
        marker_text = "Выход",

        radius = 1.5,

        casino_id = CASINO_MOSCOW,
    },
}

for i, v in pairs( conf ) do

    local entrance_conf = {
        x           = v.ex, 
        y           = v.ey + 860, 
        z           = v.ez,
        dimension   = v.edimension,
        interior    = v.einterior,
        radius      = v.radius,
        marker_text = v.emarker_text,
        text        = "ALT Взаимодействие",
        color       = { 0, 150, 255, 50 },
    }

    local exit_conf = {
        x           = v.x, 
        y           = v.y, 
        z           = v.z,
        dimension   = v.dimension,
        interior    = v.interior,
        radius      = v.radius,
        marker_text = v.marker_text,
        text        = "ALT Взаимодействие",
        color       = { 255, 0, 0, 50 },
    }

    local entrance = TeleportPoint( entrance_conf )
    entrance.elements = {}
    entrance.elements.blip = createBlipAttachedTo( entrance.marker, 44, 2, 255, 255, 255, 255, 0, 150 )

    entrance:SetImage( "files/img/marker_" .. v.casino_id .. ".png" )
	entrance.element:setData( "material", true, false )
    entrance:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 150, 255, 255, entrance_conf.radius * 0.78 } )

    local exit = TeleportPoint( exit_conf )
    exit.element:setData( "material", true, false )
    exit:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 0, 0, 255, exit_conf.radius * 0.78 } )

    entrance.PreJoin = function( self , player )
        if player:GetBlockInteriorInteraction() then
            player:ShowInfo( "Вы не можете войти во время задания" )
            return false
        end
		return true
    end

    entrance.PostJoin = function( )
        triggerServerEvent( "onClientPlayerEnterLeaveCasino", resourceRoot, v.casino_id )

        localPlayer:Teleport( exit.colshape.position, exit.dimension, exit.interior, 1000 )

        triggerServerEvent( "SwitchPosition", resourceRoot )
        triggerEvent( "onClientPlayerCasinoEnter", localPlayer,  v.casino_id )
    end

    exit.PostJoin = function( )
        triggerServerEvent( "onClientPlayerEnterLeaveCasino", resourceRoot )

        localPlayer:Teleport( entrance.colshape.position, entrance.dimension, entrance.interior, 50 )
        triggerEvent( "onClientPlayerCasinoExit", localPlayer,  v.casino_id )
    end
end