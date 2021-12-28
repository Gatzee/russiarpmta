local Settings = {}
Settings.var = {}

local scx, scy = guiGetScreenSize()
local mssource

local texturegrun = {
    "predator92body128", "monsterb92body256a", "monstera92body256a", "andromeda92wing","fcr90092body128",
    "hotknifebody128b", "hotknifebody128a", "rcbaron92texpage64", "rcgoblin92texpage128", "rcraider92texpage128", 
    "rctiger92body128","rhino92texpage256", "petrotr92interior128","artict1logos","rumpo92adverts256","dash92interior128",
    "coach92interior128","combinetexpage128","hotdog92body256",
    "raindance92body128", "cargobob92body256", "andromeda92body", "at400_92_256", "nevada92body256",
    "polmavbody128a" , "sparrow92body128" , "hunterbody8bit256a" , "seasparrow92floats64" , 
    "dodo92body8bit256" , "cropdustbody256", "beagle256", "hydrabody256", "rustler92body256", 
    "shamalbody256", "skimmer92body128", "stunt256", "maverick92body128", "leviathnbody8bit256", "@hite", "map",
    "vehiclegrunge256", "?emap*", "vehiclegeneric256", "vehicleshatter128", "hotdog92glass128", "vinil",
}

local texturegene = {
    "vehiclegeneric256",
    "*_glass_*",
}

function setEffectv()
    local v = Settings.var
    v.renderDistance = 50 -- shader will be applied to textures nearer than this
    v.sparkleSize = 0.5	-- scale the carpaint sparkles
    v.brightnessFactorPaint = 0.022
    v.brightnessFactorWShield = 0.099
    v.bumpSize = 0.5 -- for car paint
    v.bumpSizeWnd = 0 -- for windshields
    v.normalXY = 1.5 * 0.5 -- deformation strength (0-2.0) 2.0 = the highest (X and Y of vector)
    v.normalZ = 1.5 -- deformation strength (0-2.0) 2.0 = the highest (Z of vector)
    v.minZviewAngleFade = -0.20 -- the camera z direction where the fading starts
    v.brightnessAdd =0.5 -- before bright pass
    v.brightnessMul = 1.5 -- multiply after brightpass
    v.brightpassCutoff = 0.16 -- 0-1
    v.brightpassPower = 2 -- 1-5
    v.uvMul = {1.00,0.85} -- uv multiply
    v.uvMov = {0.00,-0.16} -- uv move
    --Sky gradient color coating
    v.skyLightIntensity = 0.5
    --Pearlescent
    v.filmDepth = 0.03
    v.filmIntensity = 0.051
end

function startCarPaintReflectLite()
    if cprlEffectEnabled then return end
    local v = Settings.var
    setEffectv()
    grunShader = dxCreateShader("fx/car_refgrun.fx",2,v.renderDistance,true,"vehicle")
    glassShader = dxCreateShader("fx/car_refgene.fx",2,v.renderDistance,true,"vehicle")
    mssource = dxCreateScreenSource( scx, scy)
    if grunShader and glassShader and mssource then
        dxUpdateScreenSource( mssource)
        addEventHandler("onClientHUDRender",getRootElement (),updateScreen)
        addEventHandler( "onClientFirstPersonStateChange", root, onClientFirstPersonStateChange_carpaint )
        dxSetShaderValue ( grunShader, "minZviewAngleFade",v.minZviewAngleFade)
        dxSetShaderValue ( grunShader, "sCutoff",v.brightpassCutoff)
        dxSetShaderValue ( grunShader, "sPower", v.brightpassPower)			
        dxSetShaderValue ( grunShader, "sAdd", v.brightnessAdd)
        dxSetShaderValue ( grunShader, "sMul", v.brightnessMul)
        dxSetShaderValue ( grunShader, "sNorFacXY", v.normalXY)
        dxSetShaderValue ( grunShader, "sNorFacZ", v.normalZ)
        dxSetShaderValue ( grunShader, "brightnessFactor", v.brightnessFactorPaint)  
        dxSetShaderValue ( grunShader, "uvMul", v.uvMul[1],v.uvMul[2])
        dxSetShaderValue ( grunShader, "uvMov", v.uvMov[1],v.uvMov[2])
        dxSetShaderValue ( grunShader, "skyLightIntensity", v.skyLightIntensity)
        dxSetShaderValue ( grunShader, "sparkleSize", v.sparkleSize)
        dxSetShaderValue ( grunShader, "filmDepth", v.filmDepth)
        dxSetShaderValue ( grunShader, "gFilmIntensity", v.filmIntensity)
        dxSetShaderValue ( glassShader, "minZviewAngleFade",v.minZviewAngleFade)			
        dxSetShaderValue ( glassShader, "sCutoff",v.brightpassCutoff)
        dxSetShaderValue ( glassShader, "sPower", v.brightpassPower)	
        dxSetShaderValue ( glassShader, "sAdd", v.brightnessAdd)
        dxSetShaderValue ( glassShader, "sMul", v.brightnessMul)
        dxSetShaderValue ( glassShader, "sNorFacXY", v.normalXY)
        dxSetShaderValue ( glassShader, "sNorFacZ", v.normalZ)
        dxSetShaderValue ( glassShader, "brightnessFactor", v.brightnessFactorWShield) 
        dxSetShaderValue ( glassShader, "uvMul", v.uvMul[1],v.uvMul[2])
        dxSetShaderValue ( glassShader, "uvMov", v.uvMov[1],v.uvMov[2])
        dxSetShaderValue ( glassShader, "skyLightIntensity", v.skyLightIntensity)
        dxSetShaderValue ( grunShader, "bumpSize",v.bumpSize)
        dxSetShaderValue ( glassShader, "bumpSize",v.bumpSizeWnd)
        textureVol = dxCreateTexture ( "images/smallnoise3d.dds" )
        textureFringe = dxCreateTexture ( "images/ColorRamp01.png" )
        textureCube = dxCreateTexture ( "images/cube_env256.dds" )
        dxSetShaderValue ( grunShader, "sRandomTexture", textureVol )
        dxSetShaderValue ( grunShader, "sFringeTexture", textureFringe )
        dxSetShaderValue ( grunShader, "sReflectionTexture", mssource )
        dxSetShaderValue ( glassShader, "sRandomTexture", textureVol )
        dxSetShaderValue ( glassShader, "sReflectionTexture", mssource )
        dxSetShaderValue ( glassShader, "sCubeReflectionTexture", textureCube )	
        
        engineApplyShaderToWorldTexture ( grunShader, "vehiclegrunge256" )
        engineApplyShaderToWorldTexture ( grunShader, "?emap*" )
        engineApplyShaderToWorldTexture ( grunShader, "vinil" )
        for _,addList in ipairs(texturegrun) do
            engineApplyShaderToWorldTexture (grunShader, addList )
        end

        SetCarGlassShaderEnabled( true )

        cprlEffectEnabled = true
        if v.skyLightIntensity==0 then return end
        local pntBright=v.skyLightIntensity
        vehTimer = setTimer(function()
            if cprlEffectEnabled then
                local rSkyTop,gSkyTop,bSkyTop,rSkyBott,gSkyBott,bSkyBott= getSkyGradient ()
                local cx,cy,cz = getCameraMatrix()
                if (isLineOfSightClear(cx,cy,cz,cx,cy,cz+30,true,false,false,true,false,true,false,localPlayer)) then 
                    pntBright=pntBright+0.015
                else
                    pntBright=pntBright-0.015
                end
                if pntBright>v.skyLightIntensity then pntBright=v.skyLightIntensity end
                if pntBright<0 then pntBright=0 end 
                dxSetShaderValue ( grunShader, "sSkyColorTop", rSkyTop/255, gSkyTop/255, bSkyTop/255)
                dxSetShaderValue ( grunShader, "sSkyColorBott", rSkyBott/255, gSkyBott/255, bSkyBott/255)
                dxSetShaderValue ( grunShader, "sSkyLightIntensity", pntBright)
                dxSetShaderValue ( glassShader, "sSkyColorTop", rSkyTop/255, gSkyTop/255, bSkyTop/255)
                dxSetShaderValue ( glassShader, "sSkyColorBott", rSkyBott/255, gSkyBott/255, bSkyBott/255)
                dxSetShaderValue ( glassShader, "sSkyLightIntensity", pntBright)
            end
        end,50,0 )				
    else
        outputDebugString("Could not create carpaint shader")
    end
end

function stopCarPaintReflectLite()
    if not cprlEffectEnabled then return end
    removeEventHandler ( "onClientHUDRender", getRootElement (), updateScreen )
    removeEventHandler( "onClientFirstPersonStateChange", root, onClientFirstPersonStateChange_carpaint )
    engineRemoveShaderFromWorldTexture(grunShader,"*")
    engineRemoveShaderFromWorldTexture(glassShader,"*")
    destroyElement(grunShader)
    destroyElement(glassShader)
    grunShader = nil
    glassShader = nil
    destroyElement(mssource)
    destroyElement(textureVol)
    destroyElement(textureFringe)
    mssource = nil
    textureVol = nil
    textureFringe = nil
    if isTimer( vehTimer) then killTimer(vehTimer) end
    vehTimer = nil
    cprlEffectEnabled = false
end

function getCarpaintState()
    if cprlEffectEnabled then return true end
end

function updateScreen()
    if mssource then
        dxUpdateScreenSource( mssource)
    end
end

function SetCarGlassShaderEnabled( state )
    if not isElement( glassShader ) then return end
    if state then
        if IS_FIRST_PERSON_ENABLED then return end
        for _,addList in ipairs(texturegene) do
            engineApplyShaderToWorldTexture (glassShader, addList )
        end
    else
        engineRemoveShaderFromWorldTexture ( glassShader, "*" )
    end
end

function onClientFirstPersonStateChange_carpaint( state )
    IS_FIRST_PERSON_ENABLED = state
    SetCarGlassShaderEnabled( not state )
end