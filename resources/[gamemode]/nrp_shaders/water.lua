local texWaterShader,textureVol,textureCube
local effectParts
local wsEffectEnabled

function enableWaterShine()
  if wsEffectEnabled then return end
  -- Create things
  texWaterShader = dxCreateShader( "fx/tex_water.fx" )
  textureVol = dxCreateTexture ( "images/wavemap.png" )
  textureCube = dxCreateTexture ( "images/cube_env256.dds" )
  -- Get list of all elements used
  effectParts = {
    texWaterShader,
    textureVol,
    textureCube
  }
  
  -- Check list of all elements used
  bAllValid = true
  for _,part in ipairs(effectParts) do
    bAllValid = part and bAllValid
  end
  if not bAllValid then return end
  dxSetShaderValue ( texWaterShader, "sRandomTexture", textureVol );
  dxSetShaderValue ( texWaterShader, "sReflectionTexture", textureCube );
  engineApplyShaderToWorldTexture( texWaterShader, "waterclear256" )
  wsEffectEnabled = true
  addEventHandler( "onClientPreRender", root, updateVisibility )
  
  watTimer = setTimer( function()
	      if texWaterShader and wsEffectEnabled then
		local r, g, b, a = getWaterColor()
		r, g, b, a = r/255, g/255, b/255, a/255
		dxSetShaderValue ( texWaterShader, "sWaterColor", r, g, b, a )
	      end
	    end
	    ,100,0)	
end

----------------------------------------------------------------
-- disableWaterShine
----------------------------------------------------------------
function disableWaterShine()
  if not wsEffectEnabled then return end
  if isElement(texWaterShader) then
    engineRemoveShaderFromWorldTexture(texWaterShader, "waterclear256" )
  end
  -- Destroy all shaders
  for _,part in ipairs(effectParts) do
    if part then
      destroyElement( part )
      part = nil
    end
  end
  effectParts = {}
  bAllValid = false
  if isTimer(watTimer) then killTimer(watTimer) end
  -- Flag effect as stopped
  wsEffectEnabled = false
  removeEventHandler( "onClientPreRender", root, updateVisibility )
end

function getWaterState()
  if wsEffectEnabled then return true end
end

-----------------------------------------------------------------------------------
-- updateVisibility
-----------------------------------------------------------------------------------
local lightDirection = {0,0,1}
local dectectorPos = 1
local dectectorScore = 0
local detectorList = {
  { x = -1, y = -1, status = 0 },
  { x =  0, y = -1, status = 0 },
  { x =  1, y = -1, status = 0 },
  
  { x = -1, y =  0, status = 0 },
  { x =  0, y =  0, status = 0 },
  { x =  1, y =  0, status = 0 },
  
  { x = -1, y =  1, status = 0 },
  { x =  0, y =  1, status = 0 },
  { x =  1, y =  1, status = 0 },
}

local fadeTarget = 0
local fadeCurrent = 0
function updateVisibility ( deltaTicks )
  if not wsEffectEnabled then return end
  
  detectNext ()
  
  if dectectorScore > 0 then
    fadeTarget = 1
  else
    fadeTarget = 0
  end
  
  local dif = fadeTarget - fadeCurrent
  local maxChange = deltaTicks / 1000
  dif = math.clamp(-maxChange,dif,maxChange)
  fadeCurrent = fadeCurrent + dif
  
  -- Update shaders
  if texWaterShader then
    dxSetShaderValue( texWaterShader, "sVisibility", fadeCurrent )
  end
end

-----------------------------------------------------------------------------------
-- Light source visiblility detector
-----------------------------------------------------------------------------------

function detectNext ()
  -- Step through detectorList - one item per call
  dectectorPos = ( dectectorPos + 1 ) % #detectorList
  dectector = detectorList[dectectorPos+1]
  
  local lightDirX, lightDirY, lightDirZ
  
  if isDynamicSkyEnabled then
    local vecX, vecY, vecZ = exports.shader_dynamic_sky:getDynamicSunVector()
    if vecZ < 0 then
      lightDirX, lightDirY, lightDirZ = vecX, vecY, vecZ
    else
      vecX, vecY, vecZ = exports.shader_dynamic_sky:getDynamicMoonVector()
      if vecZ < 0 then
	lightDirX, lightDirY, lightDirZ = vecX, vecY, vecZ
      else
	lightDirX, lightDirY, lightDirZ = 0, 0, 1
      end
    end
  else
    lightDirX, lightDirY, lightDirZ = unpack(lightDirection)
  end
  
  local x, y, z = getElementPosition(localPlayer)
  
  x = x + dectector.x
  y = y + dectector.y
  
  local endX = x - lightDirX * 200
  local endY = y - lightDirY * 200
  local endZ = z - lightDirZ * 200
  
  if dectector.status == 1 then
    dectectorScore = dectectorScore - 1
  end
  
  dectector.status = isLineOfSightClear ( x,y,z, endX, endY, endZ, true, false, false ) and 1 or 0
  
  if dectector.status == 1 then
    dectectorScore = dectectorScore + 1
  end
  
  if dectectorScore < 0 or dectectorScore > 9 then
    outputDebugString ( "dectectorScore: " .. tostring(dectectorScore) )
  end
  
  -- Enable this to see the 'line of sight' checks
  if false then
    local color = tocolor(255,255,0)
    if dectector.status == 1 then
      color = tocolor(255,0,255)
    end
    dxDrawLine3D ( x,y,z, endX, endY, endZ, color )
  end
end