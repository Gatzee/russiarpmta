local TEXTURE, SHADER

INSIDE_POS = Vector3( -288.6, -357.5, 1353.6 )

INTERIORS = {
    -- Вход в Горки городе
    {
        outside = Vector3( 2245.6301269531, 360.6657409668, 62.415336608887 ),
        inside_interior = 1,
        inside_dimension = 1,

        outside_check = function( self, player )
			if player:GetBlockInteriorInteraction() then
				player:ShowInfo( "Вы не можете войти во время задания" )
				return false
			end
			return true
		end,
    },

    -- Вход в НСК
    {
        outside = Vector3( 258.43933105469, -1345.2214355469, 21.795612335205 ),
        inside_interior = 1,
        inside_dimension = 3,

        outside_check = function( self, player )
			if player:GetBlockInteriorInteraction() then
				player:ShowInfo( "Вы не можете войти во время задания" )
				return false
			end
			return true
		end,
    },

    {
        outside = Vector3( 258.4792175293, -1354.6083984375, 21.795612335205 ),
        inside_interior = 1,
        inside_dimension = 3,

        outside_check = function( self, player )
			if player:GetBlockInteriorInteraction() then
				player:ShowInfo( "Вы не можете войти во время задания" )
				return false
			end
			return true
		end,
    },
    
    {
        outside = Vector3( 258.36120605469, -1363.3458251953, 21.795612335205 ),
        inside_interior = 1,
        inside_dimension = 3,

        outside_check = function( self, player )
			if player:GetBlockInteriorInteraction() then
				player:ShowInfo( "Вы не можете войти во время задания" )
				return false
			end
			return true
		end,
    },

    -- Вход в МСК
    {
        outside = Vector3( 1320.4224853516, 2173.8833007813, 9.1135320663452 ),
        inside_interior = 1,
        inside_dimension = 5,

        outside_check = function( self, player )
            if player:GetBlockInteriorInteraction() then
                player:ShowInfo( "Вы не можете войти во время задания" )
                return false
            end
            return true
        end,
    },

    {
        outside = Vector3( 1315.1708984375, 2173.92578125, 9.1393013000488 ),
        inside_interior = 1,
        inside_dimension = 5,

        outside_check = function( self, player )
            if player:GetBlockInteriorInteraction() then
                player:ShowInfo( "Вы не можете войти во время задания" )
                return false
            end
            return true
        end,
    },
}

TPOINTS = { }
INSIDE_TPOINTS = { }


-- Проверка на вход в кинотеатр косыми способами
INSIDE_SHAPE = createColPolygon( 
    -270.700, -343.867,
    -261.963, -461.466,
    -320.158, -468.577,
    -325.958, -347.100,
    -270.700, -343.867
)
function CheckInsideCinema( )
    if localPlayer.interior > 0 and isElementWithinColShape( localPlayer, INSIDE_SHAPE ) and not IsWithinCinemaQuest( ) then
        if not IS_INSIDE_CINEMA then
            IS_INSIDE_CINEMA = true

            LoadTextures( )
            setElementData( localPlayer, "in_cinema", true, false )
            triggerEvent( "onPlayerCinemaEnter", localPlayer )

            --iprint( "Loaded cinema...", getTickCount( ) )

            local dimension = getElementDimension( localPlayer )
            for i, v in pairs( INSIDE_TPOINTS ) do
                v.dimesion           = dimension
                v.element.dimension  = dimension
                v.marker.dimension   = dimension
                v.colshape.dimension = dimension
            end
        end
    else
        if IS_INSIDE_CINEMA then
            IS_INSIDE_CINEMA = nil

            DestroyTextures( )
            setElementData( localPlayer, "in_cinema", false, false )
            triggerEvent( "onPlayerCinemaLeave", localPlayer )

            --( "Destroyed cinema...", getTickCount( ) )
        end
    end
end
INSIDE_SHAPE_TIMER = setTimer( CheckInsideCinema, 1000, 0 )

-- Подгрузка текстур и шейдера замены экрана
function LoadTextures( )
    DestroyTextures( )

    TEXTURE = dxCreateTexture( "img/replace.jpg" )
    SHADER  = dxCreateShader( "fx/replace.fx" )

    dxSetShaderValue( SHADER, "gTexture", TEXTURE )
    engineApplyShaderToWorldTexture( SHADER, "k_teatr20" )
end
addEvent( "onPlayerRequestLoadCinemaTextures" )
addEventHandler( "onPlayerRequestLoadCinemaTextures", root, LoadTextures )

function DestroyTextures( )
    DestroyTableElements( { TEXTURE, SHADER } )
end
addEvent( "onPlayerRequestUnloadCinemaTextures" )
addEventHandler( "onPlayerRequestUnloadCinemaTextures", root, DestroyTextures )

-- Входы в кино
function onResourceStart_handler()
    for i, conf in pairs( INTERIORS ) do
        local outside_conf = {
            marker_text = conf.marker_text or "Кинотеатр",
            keypress = "lalt",
	        text = "ALT Взаимодействие",
            --text        = "Нажмите Alt чтобы выбрать этаж",
            x           = conf.outside.x,
            y           = conf.outside.y,
            z           = conf.outside.z,
            dimension   = 0,
            interior    = 0,
            radius      = 2,
            color       = { 0, 120, 255, 10 },
        }
        local outside_tpoint = TeleportPoint( outside_conf )
        outside_tpoint.PreJoin = conf.outside_check

        outside_tpoint:SetImage( "img/marker.png" )
        outside_tpoint.element:setData( "material", true, false )
        outside_tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.5 } )

        createBlip( conf.outside.x, conf.outside.y, conf.outside.z, 16, 2, 255, 255, 255 )

        local inside_conf = {
            marker_text = conf.inside_marker_text or "Выход",
            text        = "ALT Взаимодействие",
            x           = INSIDE_POS.x,
            y           = INSIDE_POS.y,
            z           = INSIDE_POS.z + 0.15,
            dimension   = conf.inside_dimension,
            interior    = conf.inside_interior,
            radius      = 2,
            color       = { 0, 120, 255, 40 },
        }
        local inside_tpoint = TeleportPoint( inside_conf )
        inside_tpoint.PreJoin = conf.inside_check

        inside_tpoint.element:setData( "material", true, false )
    	inside_tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 120, 255, 255, 1.55 } )

        outside_tpoint.PostJoin = function( self )
            ShowEntranceUI_handler( true, { inside_tpoint = inside_tpoint, base_dimension = conf.inside_dimension } )
        end

        outside_tpoint.PostLeave = function( self )
            ShowEntranceUI_handler( false )
        end

        inside_tpoint.PostJoin = function( self )
            local current_quest = localPlayer:getData( "current_quest" )
            if current_quest and current_quest.id == "angela_cinema" then
                localPlayer:ShowError( "Отведи девушку в зал! ")
                return false
            end

            local position = outside_tpoint.colshape.position

            -- Поиск выхода относительно текущего измерения игрока
            local current_dimension = getElementDimension( localPlayer )
            for _, v in pairs( INTERIORS ) do
                local considered_dimensions = {
                    [ v.inside_dimension ] = true,
                    [ v.inside_dimension + 1 ] = true,
                }
                if considered_dimensions[ current_dimension ] then
                    position = v.outside
                    break
                end
            end

            triggerServerEvent( "SwitchPosition", resourceRoot )
            localPlayer:Teleport( position, outside_tpoint.dimension, outside_tpoint.interior, 50 )

            CheckInsideCinema( )
        end

        table.insert( INSIDE_TPOINTS, inside_tpoint )
    end
end
addEventHandler( "onClientResourceStart", resourceRoot, onResourceStart_handler )