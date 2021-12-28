IB_TEXTURES = { }
IB_TEXTURES_ASSIGNMENT = { }

--[[function renderDebugTextures( )
    dxDrawText( inspect( IB_TEXTURES ), 20, 300, 0, 0 )

    local npy  = 0
    for i, v in pairs( IB_TEXTURES_ASSIGNMENT ) do
        dxDrawText( tostring( i ) .. "(" .. tostring( isElement( i ) ) .. ")", 400, npy, 0, 0 )
        npy = npy + 15
        for n, t in pairs( v ) do
            dxDrawText( tostring( n ) .. "(" .. ( isElement( t ) and getElementData( t, "path" ) or "" ) .. " )", 450, npy, 0, 0 )
            npy = npy + 15
        end
    end

    for n, t in pairs( getElementsByType( "texture", resourceRoot ) ) do
        dxDrawText( "Global: " .. tostring( t ) .. "(" .. tostring( isElement( t ) ) .. "/ " .. tostring( isElement( t ) and getElementData( t, "path" ) ) .. ")", 450, npy, 0, 0 )
        npy = npy + 15
    end
end

function debug_textures( )
    _TEX_DEBUG = not _TEX_DEBUG
    if _TEX_DEBUG then
        addEventHandler( "onClientRender", root, renderDebugTextures )
    else
        removeEventHandler( "onClientRender", root, renderDebugTextures )
    end
end
addCommandHandler( "dtex", debug_textures )]]

local dxCreateTexture = dxCreateTexture
local isElement       = isElement

function GetTextureFor( element, texture_name, texture_surface )
    local texture_info = IB_TEXTURES[ texture_name ]

    local assignment = IB_TEXTURES_ASSIGNMENT[ element ]
    -- Если у элемента уже есть список текстур
    if assignment == nil then
        IB_TEXTURES_ASSIGNMENT[ element ] = { [ texture_name ] = true }
    
    -- Если нету
    else
        assignment[ texture_name ] = true
    end


    -- Подгружаем уже имеющуюся текстуру
    if texture_info then
        texture_info.elements[ element ] = true
        return texture_info.texture

    -- Создаем новую первичную текстуру
    else
        local texture = dxCreateTexture( texture_name, texture_surface or "argb" )
        IB_TEXTURES[ texture_name ] = { 
            texture = texture,
            elements = { [ element ] = true }
        }
        return texture
    end
end

function CheckTextureForRemoval( texture_name )
    local texture_info = IB_TEXTURES[ texture_name ]
    if texture_info == nil then return end

    -- Ищем активные элементы на текстуре
    if isElement( next( texture_info.elements ) ) then return end

    -- Удаляем текстуру если не найдено
    if isElement( texture_info.texture ) then
        destroyElement( texture_info.texture )
    end
    IB_TEXTURES[ texture_name ] = nil
end

-- Обработка изменения текстуры у элемента
function ibOnElementDataChange_textureHandler( key, value, old )
    local list = IB_TEXTURES[ old ]
    if list and old ~= value then
        list.elements[ source ] = nil
        CheckTextureForRemoval( old )
    end
end
addEvent( "ibOnElementDataChange", true )
addEventHandler( "ibOnElementDataChange", root, ibOnElementDataChange_textureHandler )