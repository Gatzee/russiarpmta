loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CPlayer" )

local _SCREEN_X, _SCREEN_Y = guiGetScreenSize( )

engineSetAsynchronousLoading( false, false )

--[[for i, v in pairs( getElementsByType( "object" ) ) do
    engineSetModelLODDistance( v.model, 280 )
end]]

setBlurLevel( 15 ) -- уменьшение блюр-левела. Дефолт 36
setBirdsEnabled( false ) -- Нахуя нам ПТЫЦЫ? Bekky, lemme smash.
setCloudsEnabled( false ) -- Облака тоже в минус
setOcclusionsEnabled( true ) -- Отрисовка объектов за предметами в минус


-- Расстояние отрисовки
setFarClipDistance( 350 )
setFogDistance( 250 )

local min_distance = 150
local max_distance = 1500

local min_vehdistance = 30
local max_vehdistance = 250

function onSettingsChange_handler( changed, values )
	if changed.drawdistance then
		if values.drawdistance then
            local new_distance = math.floor( min_distance + ( max_distance - min_distance ) * values.drawdistance )
            setFarClipDistance( new_distance )
            setFogDistance( math.floor( new_distance * 0.6 ) )
		end
    end
    if changed.vehdrawdistance then
		if values.vehdrawdistance then
            local new_distance = math.floor( min_vehdistance + ( max_vehdistance - min_vehdistance ) * values.vehdrawdistance )
            setVehiclesLODDistance( new_distance, new_distance * 2.14 )
		end
    end
end
addEvent( "onSettingsChange" )
addEventHandler( "onSettingsChange", root, onSettingsChange_handler )

triggerEvent( "onSettingsUpdateRequest", localPlayer, "drawdistance" )
triggerEvent( "onSettingsUpdateRequest", localPlayer, "vehdrawdistance" )


local FADE_DIST = 10
local FADE_START = 5
local WATER_RENDERING

function FuckWater( )
      if not localPlayer:IsInGame( ) then return end

      if not WATER_RENDERING and localPlayer.inWater then
            WATER_RENDERING = true
            addEventHandler( "onClientRender", root, FuckWaterRender, false, "low-999999999999" )
      elseif WATER_RENDERING and not localPlayer.inWater then
            WATER_RENDERING = nil
            removeEventHandler( "onClientRender", root, FuckWaterRender )
      end
end
setTimer( FuckWater, 1000, 0 )

function FuckWaterRender( )
      local px, py, pz = getElementPosition( localPlayer )
      local water_level = getWaterLevel( px, py, pz, true )

      if water_level then
            local dist = water_level - pz - FADE_START

            if dist > 0 then
                  local alpha = math.min( 255, dist / FADE_DIST * 255 )
                  dxDrawRectangle( 0, 0, _SCREEN_X, _SCREEN_Y, tocolor( 0, 0, 0, alpha ) )
            end
      end
end

-- Вода в мире
WATER_CONF = {
      -- Озеро
      {
            center = Vector2( 300, -287 ),
            width = 90,
            height = 19,
      },

      -- Я в порядке, заливаем водичку в час ночи, в аккурат перед релизом МСК
      -- Пруды МСК
      {
            center = Vector2( -1252.08, 2350.73 ),
            width = 39,
            height = 9.5,
      },
      {
            center = Vector2( -1027.0629882813, 2008.5462646484 ),
            width = 80,
            height = 7.15,
      },
      {
            center = Vector2( 2327.9877929688, 2642.2453613281 ),
            width = 40,
            height = 6.5,
      },
      {
            center = Vector2( 991.06213378906, 2167.0043945313 ),
            width = 100,
            height = 6.5,
      },

	  -- Ебаные коттеджи
	  -- Понимаю
      {
            center = Vector2( 762.568, -490.435 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 805.096, -554.017 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 776.563, -628.773 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 718.833, -689.283 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 704.283, -661.509 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 630.359, -688.253 ),
            width = 9,
            height = 19.6,
      },
      {
            center = Vector2( 600.135, -688.66 ),
            width = 9,
            height = 19.6,
      },
      {
            center = Vector2( 525.546, -661.157 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 511.372, -689.395 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 511.103, -597.965 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 525.464, -625.685 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 600.054, -597.525 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 630.159, -597.976 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 704.506, -626.072 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 538.157, -551.602 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 545.731, -535.757 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 719.151, -597.089 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 692.775, -550.064 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 684.241, -535.474 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 776.932, -540.052 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 613.189, -468.992 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 628.373, -440.38 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 628.228, -405.24 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 612.841, -377.022 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 702.219, -377.825 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 640.048, -330.868 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 648.062, -314.73 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 597.19, -261.619 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 589.392, -201.457 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 585.168, -145.417 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 593.035, -127.62 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 576.526, -56.119 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 558.89, -47.362 ),
            width = 8,
            height = 19.6,
      },
      {
            center = Vector2( 702.508, -468.836 ),
            width = 8,
            height = 19.6,
      },
      -- Виллы
      {
            center = Vector2( 203.111, -191.025 ),
            width = 10,
            height = 19.6,
      },
      {
            center = Vector2( 160.69, -221.498 ),
            width = 10,
            height = 19.6,
      },
      {
            center = Vector2( 121.064, -259.221 ),
            width = 10,
            height = 19.6,
      },
      {
            center = Vector2( 87.881, -307.104 ),
            width = 10,
            height = 19.6,
      },
      {
            center = Vector2( 58.176, -400.791 ),
            width = 10,
            height = 19.6,
      },
      {
            center = Vector2( 43.273, -454.317 ),
            width = 10,
            height = 19.6,
      },
      {
            center = Vector2( 40.838, -512.322 ),
            width = 10,
            height = 19.6,
      },
      {
            center = Vector2( 52.704, -567.801 ),
            width = 10,
            height = 19.6,
      },
      {
            center = Vector2( 58.84, -625.808 ),
            width = 10,
            height = 19.6,
      },
      {
            center = Vector2( 120.32, -646.065 ),
            width = 10,
            height = 19.6,
      },
      {
            center = Vector2( 181.305, -649.125 ),
            width = 10,
            height = 19.6,
      },
      {
            center = Vector2( 235.582, -648.364 ),
            width = 10,
            height = 19.6,
      },
      {
            center = Vector2( 293.525, -642.644 ),
            width = 10,
            height = 19.6,
      },
      {
            center = Vector2( 350.661, -636.92 ),
            width = 10,
            height = 19.6,
      },
      {
            center = Vector2( -1230.315, 2181.304 ),
            width = 25,
            height = 9.85,
      },
      {
            center = Vector2( -948.222, 2141.407 ),
            width = 85,
            height = 7.1,
      }
}

for i, v in pairs( WATER_CONF ) do
      v.center.y = v.center.y+860
      local water = createWater (
            v.center.x - v.width, v.center.y - v.width, v.height,
            v.center.x + v.width, v.center.y - v.width, v.height,
            v.center.x - v.width, v.center.y + v.width, v.height,
            v.center.x + v.width, v.center.y + v.width, v.height
      )
      setWaterLevel( water, v.height )
end
