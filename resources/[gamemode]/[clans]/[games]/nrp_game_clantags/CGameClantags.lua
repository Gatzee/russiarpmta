loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShClans" )

TAG_TEXTURES = { }
TAG_TEXTURES_PATHS = { }

for i, v in pairs( TAG_IMAGES ) do
    --TAG_TEXTURES[ v ] = dxCreateTexture( ":nrp_clans/" .. v )
    TAG_TEXTURES_PATHS[ i ] = ":nrp_clans/" .. v
end

CLANTAGS = false
CLANTAGS_VISIBLE = { }

Timer( function() 
    CLANTAGS = getElementsByType( "clantags", root, true )
    
    CLANTAGS_VISIBLE = { }

    TAG_TEXTURES[ "circle" ] = TAG_TEXTURES[ "circle" ] or dxCreateTexture( ":nrp_clans/img/dropimage.dds" )
    TAG_TEXTURES[ "neutral" ] = TAG_TEXTURES[ "neutral" ] or dxCreateTexture( ":nrp_clans/img/tags/neutral.png" )

    local cx, cy, cz = getCameraMatrix()
    for i, v in pairs( CLANTAGS ) do
        local number = getElementData( v, "number" )
        local global_conf = TAG_POSITIONS[ number ]
        if getDistanceBetweenPoints3D( cx, cy, cz, global_conf.vector_pos ) < 70 then
            global_conf.tag_id = getElementData( v, "spray" )
            table.insert( CLANTAGS_VISIBLE, global_conf )
        end
    end
    for i, v in pairs( CARTELS_TAGS ) do
        local global_conf = v
        if getDistanceBetweenPoints3D( cx, cy, cz, global_conf.vector_pos ) < 70 then
            table.insert( CLANTAGS_VISIBLE, global_conf )
        end
    end
end, 1000, 0 )

function ClanTags_Render()
    if localPlayer.dimension ~= 0 then return end
    
    for i, v in pairs( CLANTAGS_VISIBLE or { } ) do
        local tag_id = v.tag_id

        local x, y = v.x, v.y

        -- local owner = getElementData( element, "owner" ) or 1
        local color = { 255, 255, 255, 255 }
        -- Кольцо
        if tag_id then 
            dxDrawMaterialLine3D(
                v.vector_from_pos,
                v.vector_to_pos,
                TAG_TEXTURES[ "circle" ], v.size,
                tocolor( unpack( color ) ), false,
                v.vector_img_direction
            )
        end
        -- Изображение
        if tag_id and TAG_TEXTURES_PATHS[ tag_id ] then 
            TAG_TEXTURES[ tag_id ] = TAG_TEXTURES[ tag_id ] or DxTexture( TAG_TEXTURES_PATHS[ tag_id ] ) 
        end
        dxDrawMaterialLine3D(
            v.vector_from_pos,
            v.vector_to_pos,
            TAG_TEXTURES[ tag_id ] or TAG_TEXTURES[ "neutral" ], v.size,
            0xffffffff, false,
            v.vector_img_direction
        )
    end

end
addEventHandler( "onClientPreRender", root, ClanTags_Render, true, "low-1000" )  --, true, "high+99999999999" )

START_SPRAY_TICK = nil
LAST_SPRAY_TICK = nil
INITIAL_AMMO_COUNT = nil
function onClientPlayerWeaponFire( weapon )
    if weapon ~= 41 then return end
    if localPlayer.dimension ~= 0 then return end
    if LAST_FINISHED_SPRAY and getTickCount() - LAST_FINISHED_SPRAY <= 2000 then return end
    for i, v in pairs( TAG_POSITIONS ) do
        if getDistanceBetweenPoints3D( v.x, v.y, v.z, localPlayer.position ) <= 3 then

            -- Определение угла нацеливания на тег
            local mx1, mx2, mx3, mx4, mx5, mx6 = getCameraMatrix()
            local direction_vector = Vector3( mx1 - mx4, mx2 - mx5, mx3 - mx6 )
            local required_view_vector = Vector3( mx1 - v.x, mx2 - v.y, mx3 - v.z )

            local dot_product = direction_vector:dot( required_view_vector )

            local acos = dot_product / direction_vector:getLength() / required_view_vector:getLength()
            local deg = math.deg( math.acos( acos ) )

            if deg <= 20 then
                if not LAST_SPRAY_TICK or getTickCount( ) - LAST_SPRAY_TICK >= 250 then
                    START_SPRAY_TICK = nil
                end
                LAST_SPRAY_TICK = getTickCount( )
                if not START_SPRAY_TICK then
                    START_SPRAY_TICK = getTickCount( )
                    INITIAL_AMMO_COUNT = localPlayer:getTotalAmmo( )
                    triggerServerEvent( "checkSpray", localPlayer, i )
                end

                if getTickCount( ) - START_SPRAY_TICK >= 750 then
                    local current_ammo_count = localPlayer:getTotalAmmo( )
                    local diff = INITIAL_AMMO_COUNT - current_ammo_count
                    if diff >= 75 then
                        triggerServerEvent( "onClanTagSprayRequest", localPlayer, i )
                        --TAG_POSITIONS[ i ].texture = TAG_IMAGES[ 2 ]
                        LAST_SPRAY_TICK = nil
                        LAST_FINISHED_SPRAY = getTickCount( )
                    end
                end
            else
                START_SPRAY_TICK = nil
                LAST_SPRAY_TICK = nil
                INITIAL_AMMO_COUNT = nil
            end
        end
    end
end
addEventHandler( "onClientPlayerWeaponFire", localPlayer, onClientPlayerWeaponFire )

-- Запрет дамага от баллончика
function onClientPlayerDamage_handler( _, weapon )
    if weapon == 41 then cancelEvent() end
end
addEventHandler( "onClientPlayerDamage", localPlayer, onClientPlayerDamage_handler )