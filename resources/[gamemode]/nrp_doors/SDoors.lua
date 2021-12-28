loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend("SPlayer")
Extend("SInterior")

function CheckAccess( self, player )
    if self.faction then
        local forbidden = false
        if type( self.faction ) == "table" then
            if not self.faction[ player:GetFaction() ] then
                forbidden = true
            end
        else
            if player:GetFaction() ~= self.faction then
                forbidden = true
            elseif player:getData( "jailed" ) then
                forbidden = true
            end
        end
        if forbidden then
            local text = self.resource_config and self.resource_config.no_keys_message or "У тебя нет ключей"
            return false, text
        end
    end
    return true
end

DOOR_RESOURCES = {
    [ "Army" ] = {
        faction = F_ARMY,
    },
    [ 'Int_Medic' ] = {
        faction = F_MEDIC,
    },
    [ 'Int_Police_Nsk' ] = {
        faction = F_POLICE_PPS_NSK,
    },
    [ 'Int_Police_Gorki' ] = {
        faction = F_POLICE_PPS_GORKI,
    },
    [ 'Int_DPS_Nsk' ] = {
        faction = F_POLICE_DPS_NSK,
    },
    [ 'Int_DPS_Gorki' ] = {
        faction = F_POLICE_DPS_GORKI,
    },
    [ 'Int_Mayor_Nsk' ] = {
        faction = F_GOVERNMENT_NSK,
    },
    [ 'Int_Mayor_Gorki' ] = {
        faction = F_GOVERNMENT_GORKI,
    },
    [ 'Int_Fsin_Nsk' ] = {
        faction = F_FSIN,
    },
}

DOORS = { }

function onResourceStart_handler( resource )
    local resource = resource or source

    if resource == getThisResource() then
        for i, v in pairs( DOOR_RESOURCES ) do
            local res = getResourceFromName( i )
            if res then
                local state = getResourceState( res )

                if state == "running" then
                    restartResource( res, true )

                elseif state == "loaded" then
                    startResource( res, true )

                end
            end
        end
        return
    end

    local resource_name = getResourceName( resource )
    local resource_config = DOOR_RESOURCES[ resource_name ]
    if not resource_config then return end
    local objects = getElementsByType( "object", getResourceRootElement( resource ) )

    local interconnected = { }
    local int = tonumber

    for i, v in pairs( objects ) do
        local properties = getElementData( v, "property" )
        local properties_tbl = properties
        if properties_tbl then
            local config = {
                id = tostring( getElementData( v, "id" ) ),
                open_text = "ALT Взаимодействие",
                close_text = "ALT Взаимодействие",
                model = int( getElementData( v, "model" ) ),
                x = int( getElementData( v, "posX" ) ), y = int( getElementData( v, "posY" ) ), z = int( getElementData( v, "posZ" ) ),
                rx = int( getElementData( v, "rotX" ) ) or 0, ry = int( getElementData( v, "rotY" ) ) or 0, rz = int( getElementData( v, "rotZ" ) ) or 0,
                move = {
                    rx = properties_tbl.rotate_obj_x,
                    ry = properties_tbl.rotate_obj_y,
                    rz = properties_tbl.rotate_obj_z,
                    x = properties_tbl.move_obj_x,
                    y = properties_tbl.move_obj_y,
                    z = properties_tbl.move_obj_z,
                },
                faction = resource_config.faction,
                CheckAccess = CheckAccess,
                duration = properties_tbl.duration,
                dimension = int( getElementData( v, "dimension" ) ) or 0,
                interior = int( getElementData( v, "interior" ) ) or 0,
                radius = int( getElementData( v, "radius" ) ) or resource_config.radius or 2,
                resource_config = resource_config,
            }
            destroyElement( v )

            local door = DoorInteractive( config )
            local connected_door_id = properties_tbl.interconnected

            if connected_door_id then
                interconnected[ config.id ] = {
                    door = door,
                    connected_door_id = connected_door_id,
                }
            end
        end
    end

    for i, v in pairs( interconnected ) do
        v.door.interconnected = interconnected[ v.connected_door_id ].door
    end

    stopResource( resource )
end
addEventHandler( "onResourceStart", root, onResourceStart_handler )

--Временный массив, т.к. в модельке тюрьмы нет дверей -> моделлеры пидоры
STATIC_DOORS =
{   
    --2 этаж административное здание, половина двери
    { id = 17289, dimension = 1, interior = 1, position = Vector3(-2666.0441, 2836.6100, 1544.5418), rotation = Vector3( 0, 0, 180 )},
    --2 этаж раздевалка
    { id = 17288, dimension = 1, interior = 1, position = Vector3(-2652.3530, 2838.6787, 1544.5418), rotation = Vector3( 0, 0, 0 ) },
   --1 этаж комната начальника
    { id = 17286, dimension = 1, interior = 1, position = Vector3(-2668.71, 2839.9450, 1540.6893), rotation = Vector3( 0, 0, 180 ) },

    --Двери реанизмацц, щель
    { id = 17289, dimension = 1, interior = 1, position = Vector3(468.265, -1607.12, 1021.21), rotation = Vector3( 0, 0, 180 ) },
    --Двери реанимации, щель
    { id = 17289, dimension = 1, interior = 1, position = Vector3(1962.444, 305.099, 661.2), rotation = Vector3( 0, 0, 0 ) },

    --2 этаж ДПС г.Новороссийск
    { id = 17289, dimension = 1, interior = 1, position = Vector3(320.64, -1166.688, 1026.25), rotation = Vector3( 0, 0, 90 ) },
}

for _, v in pairs( STATIC_DOORS ) do
    local door = Object( v.id, v.position, v.rotation )
    door:setDimension( v.dimension )
    door:setInterior( v.interior )
end
