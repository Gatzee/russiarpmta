local X, Y = guiGetScreenSize()

local LOCALPLAYER = getLocalPlayer()
local ROOTELEMENT = getRootElement()
local RESROOTELEMENT = getResourceRootElement(getThisResource())

effects = {}
effects.list = { "contrast", "blur", "carpaint", "water", "detail", "skybox" }

function effects.toggle()
    --enableRadialBlur()
    --startCarPaintReflectLite()
end

function effects.toggle()
    effects.enabled = not effects.enabled
    if effects.enabled then
        enableRadialBlur()
        startCarPaintReflectLite()
        enableWaterShine()
        enableDetail()
        enableContrast()
        triggerEvent( "ToggleSkybox", root, true )
        for i, v in ipairs(effects.list) do
            setElementData(LOCALPLAYER, "shaders." .. v, true, false)
        end
    else
        disableRadialBlur()
        stopCarPaintReflectLite()
        disableWaterShine()
        disableDetail()
        disableContrast()
        triggerEvent( "ToggleSkybox", root, false )
        for i, v in ipairs(effects.list) do
            setElementData(LOCALPLAYER, "shaders." .. v, false, false)
        end
    end
end
addCommandHandler("shaders", effects.toggle)
--bindKey("k","down","shaders")

function effects.toggle(_, name)
    local tostate = false
    if name == "blur" then
        if getBlurState() then
            disableRadialBlur()
        else
            enableRadialBlur()
            tostate = true
        end
    elseif name == "carpaint" then
        if getCarpaintState() then
            stopCarPaintReflectLite()
        else
            startCarPaintReflectLite()
            tostate = true
        end
    elseif name == "water" then
        if getWaterState() then
            disableWaterShine()
        else
            enableWaterShine()
            tostate = true
        end
    elseif name == "detail" then
        if getDetailState() then
            disableDetail()
        else
            enableDetail()
            tostate = true
        end
    elseif name == "lut" then
        if LUT.enabled then
            disableLUT()
        else
            enableLUT()
            tostate = true
        end
    elseif name == "ssao" then
        if SSAO.enabled then
            disableAO()
        else
            enableAO()
            tostate = true
        end
    elseif name == "sun" then
        if SunShader.enabled then
            SunShader:disable( )
        else
            SunShader:enable( )
            tostate = true
        end
    end
    setElementData(LOCALPLAYER, "shaders." .. name, tostate, false)
end
addCommandHandler("sh", effects.toggle)

function onSettingsChange_handler( changed, values )

    if changed.reflection then
        if getCarpaintState() then stopCarPaintReflectLite() end
        if values.reflection then
            startCarPaintReflectLite()
        end
    end

    if changed.water then
        if getWaterState() then disableWaterShine() end
        if values.water then
            enableWaterShine()
        end
    end

    if changed.blur then
        if getBlurState() then disableRadialBlur() end
        if values.blur then
            enableRadialBlur()
        end
    end

    if changed.ssao then
        if SSAO.enabled then disableAO() end
        if values.ssao then
            enableAO()
        end
    end

    if changed.lut then
        if LUT.enabled then disableLUT() end
        if values.lut then
            enableLUT()
        end
    end

    if changed.sun then
        if SunShader.enabled then SunShader:disable( ) end
        if values.sun then
            SunShader:enable( )
        end
    end
end
addEvent( "onSettingsChange" )
addEventHandler( "onSettingsChange", root, onSettingsChange_handler )

addEventHandler( "onClientResourceStart", resourceRoot, 
    function()
        triggerEvent( "onSettingsUpdateRequest", localPlayer, "reflection" )
    end
)
