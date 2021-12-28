local DATA = {}

local SHADER_CODE = [[
    float4 rgba = float4(1,0,0,0.25);
  
    technique simple
    {
        pass P0
        {
            MaterialAmbient = rgba;
            MaterialDiffuse = rgba;
            MaterialEmissive = rgba;
            MaterialSpecular = rgba;

            AmbientMaterialSource = Material;
            DiffuseMaterialSource = Material;
            EmissiveMaterialSource = Material;
            SpecularMaterialSource = Material;

            ColorOp[0] = SELECTARG1;
            ColorArg1[0] = Diffuse;

            Lighting = true;
            AlphaRef = 0;
        }
    }
]]

TEXTURES = {
    "rpb_glass_rear", "rp_glass_rear",
    "rpb_glass_front", "rp_glass_front",
}


local pDefaultShader = dxCreateShader( SHADER_CODE, 0, 50, false, "vehicle" )
dxSetShaderValue(pDefaultShader, "rgba", 0, 0, 0, 120 / 255)

local STREAMED_VEHICLES = { }

function onClientElementStreamIn( vehicle )
    local vehicle = vehicle or source
    if getElementType( vehicle ) ~= "vehicle" then return end
    if STREAMED_VEHICLES[ vehicle ] then return end
    createWindowsForVehicle(vehicle)
    addEventHandler( "onClientElementStreamOut", vehicle, onClientElementStreamOut )
    addEventHandler( "onClientElementDestroy", vehicle, onClientElementStreamOut )
    addEventHandler( "onClientElementDataChange", vehicle, onClientElementDataChange )
    STREAMED_VEHICLES[ vehicle ] = true
end
addEventHandler("onClientElementStreamIn", root, onClientElementStreamIn)

function onClientElementStreamOut( )
    destroyWindowsForVehicle( source )
    removeEventHandler( "onClientElementStreamOut", source, onClientElementStreamOut )
    removeEventHandler( "onClientElementDestroy", source, onClientElementStreamOut )
    removeEventHandler( "onClientElementDataChange", source, onClientElementDataChange )
    STREAMED_VEHICLES[ source ] = nil
end
function onStart()
    for i, v in pairs( getElementsByType( "vehicle", root, true ) ) do
        onClientElementStreamIn( v )
    end
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function createWindowsForVehicle(vehicle)
    destroyWindowsForVehicle(vehicle)
    local veh_type = getVehicleType(vehicle)
    if veh_type ~= "Automobile" and veh_type ~= "Monster Truck" then
        return
    end
    local color = getElementData(vehicle, "_wincolor")
    local r, g, b, a = unpack( color or {} )
    if not r or not g or not b then
        r, g, b, a = 0, 0, 0, 120
    end
    DATA[vehicle] = {}
    a = a == 0 and 0 or math.max(120, a or 255)
    if r == 0 and g == 0 and b == 0 and a == 120 then
        DATA[vehicle].shader = pDefaultShader
        for i, v in pairs( TEXTURES ) do
            engineApplyShaderToWorldTexture(pDefaultShader, v, vehicle)
        end
    else
        DATA[vehicle].shader = createWindowsShader(vehicle)
        dxSetShaderValue(DATA[vehicle].shader, "rgba", r / 255, g / 255, b / 255, (a or 255) / 255)
    end
    if not isElement(DATA[vehicle].shader) then
        destroyWindowsForVehicle(vehicle)
        return
    end
end

function createWindowsShader(vehicle)
    local shader = dxCreateShader( SHADER_CODE, 0, 50, false, "vehicle" )
    if not isElement(shader) then
        return
    end
    for i, v in pairs( TEXTURES ) do
        engineApplyShaderToWorldTexture(shader, v, vehicle)
    end
    return shader
end

function destroyWindowsForVehicle(vehicle)
    if DATA[vehicle] then
        if isElement(DATA[vehicle].shader) and DATA[vehicle].shader ~= pDefaultShader then
            destroyElement(DATA[vehicle].shader)
        end
        DATA[vehicle] = nil
    end
end

function onClientElementDataChange(key)
    local vehicle = source
    if key ~= "_wincolor" then return end
    if not DATA[vehicle] or not DATA[vehicle].shader then
        createWindowsForVehicle(vehicle)
    else
        if DATA[vehicle].shader == pDefaultShader then
            createWindowsForVehicle(vehicle)
        end
        local color = getElementData(vehicle, "_wincolor")
        local r, g, b, a = unpack(color or {})
        if not r or not g or not b then
            r, g, b, a = 0, 0, 0, 120
        end
        a = a == 0 and 0 or math.max(120, a or 255)
        dxSetShaderValue(DATA[vehicle].shader, "rgba", r / 255, g / 255, b / 255, (a or 255) / 255)
    end
end

function CheckBrokenShaders()
    for k, v in pairs(DATA) do
        if not isElement(k) or not isElementStreamedIn(k) then
            if isElement(v.shader) then
                if v.shader ~= pDefaultShader then
                    destroyElement(v.shader)
                end
            end
            DATA[k] = nil
        end
    end
end
setTimer(CheckBrokenShaders, 30000, 0)
