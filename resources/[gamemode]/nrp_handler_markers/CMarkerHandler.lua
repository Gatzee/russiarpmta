MARKERS = { }

TEXTURES = { }

MAX_DISTANCE = 40
SCREEN_SCALE_FACTOR = 0.62236922828322

ICON_SX = 13
ICON_SY = 22
ICON_SX_HALF = ICON_SX / 2
ICON_SY_HALF = ICON_SY / 2

POINT_ICON_SX = 20
POINT_ICON_SY = 25
POINT_ICON_SX_HALF = POINT_ICON_SX / 2
POINT_ICON_SY_HALF = POINT_ICON_SY / 2

DIRECTION_TYPE_LEFT = 1
DIRECTION_TYPE_RIGHT = 2

loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
ibUseRealFonts( true )

-- Состояния, в которых запрещено рисовать маркеры
function CheckRenderable( )
	if getElementData( localPlayer, "IsWithinTuning" ) then return end
	return true
end

local function DrawOutlinedText( str, x, y, x2, y2, color, scale, font, float_left, float_top )
	dxDrawText( str, x-1, y, x2-1, y2, 0xFF000000, scale, font, float_left, float_top )
	dxDrawText( str, x+1, y, x2+1, y2, 0xFF000000, scale, font, float_left, float_top )
	dxDrawText( str, x, y-1, x2, y2-1, 0xFF000000, scale, font, float_left, float_top )
	dxDrawText( str, x, y+1, x2, y2+1, 0xFF000000, scale, font, float_left, float_top )
	dxDrawText( str, x, y, x2, y2, color, scale, font, float_left, float_top )
end

local math_ceil = math.ceil

function RenderMarkers( )
	-- Блок рендера по любой причине
	if not CheckRenderable( ) then return end

	-- Базовая инфа
	local physics_source = getCameraTarget( ) or getCamera( )
	local mx, my, mz = getElementPosition( physics_source )

	local x, y, z, tx, ty, tz = getCameraMatrix( )
	local vec_cam = Vector3( x, y, z )
	local vec_cam_direction = ( Vector3( tx, ty, tz ) - vec_cam ):getNormalized( )

	local _, _, mrz	= getElementRotation( getCamera( ) )
	mrz = math.rad( -mrz )

	local dimension = getElementDimension( localPlayer )
	local interior  = getElementInterior( localPlayer )

	-- Отрисовываем маркеры
	for i, conf in pairs( MARKERS ) do
		local tpoint = conf.tpoint
		if isElement( tpoint ) and getElementDimension( tpoint ) == dimension and getElementInterior( tpoint ) == interior then

			local px, py, pz = conf.px, conf.py, conf.pz
			if conf.attached then
				px, py, pz = getElementPosition( conf.marker )
				pz = pz + 1
			end

			local distance = getDistanceBetweenPoints3D( x, y, z, px, py, pz )
			local isClear = isLineOfSightClear( px, py, pz, x, y, z, true, false, false, true, false, false, false, localPlayer )
			local text_offset_y = 0

			-- Навигация до точки
			local gps = conf.gps
			if gps then
				local gps_distance = tonumber( gps ) or math.huge
				if distance <= gps_distance then
					local scale = math.max( 20 / distance * SCREEN_SCALE_FACTOR, 1 )
					local screen_x, screen_y = getScreenFromWorldPosition( px, py, pz )
					local str = math.floor( distance ) .. " М"

					if screen_x then
						local sx, sy = 101, 101
						local coeff = math.max( sx, sy ) / 204 * scale

						local img_path = "point.png"
						if conf.quest_state ~= nil then
							img_path = conf.quest_state and "point_mq.png" or "point_sq.png"
						end

						sx, sy = sx * coeff, sy * coeff

						dxDrawImage( screen_x - sx / 2, screen_y - sy * 1.2, sx, sy, GetTexture( "img/" .. img_path ), 0, 0, 0, 0xffffffff )

						dxDrawText( str, screen_x + 1, screen_y + 1, screen_x + 1, screen_y + 1, 0x88000000, scale*1.5, "default-bold", "center", "center", false, false, false, true )
						dxDrawText( str, screen_x, screen_y, screen_x, screen_y, 0xffffffff, scale*1.5, "default-bold", "center", "center", false, false, false, true )

						text_offset_y = -sy
					else
						local dx = px - mx
						local dy = py - my

						local rad = math.atan2( dx, dy )
						local rrz = rad - mrz

						local sx = math.sin( rrz )
						local sy = math.cos( rrz )

						local X1 = _SCREEN_X_HALF
						local Y1 = _SCREEN_Y_HALF
						local X2 = sx * _SCREEN_X_HALF + _SCREEN_X_HALF
						local Y2 = -sy * _SCREEN_Y_HALF + _SCREEN_Y_HALF
						local X
						local Y

						local direction
						if math.abs( sx ) > math.abs( sy ) then
							if X2 < X1 then
								X = 20
								Y = Y1 + ( Y2 - Y1 ) * ( X - X1 ) / ( X2 - X1 )
								direction = DIRECTION_TYPE_LEFT
							else
								X = _SCREEN_X - 20
								Y = Y1 + ( Y2 - Y1 ) * ( X - X1 ) / ( X2 - X1 )
								direction = DIRECTION_TYPE_RIGHT
							end
						end

						local img_path = "point_small.png"
						if conf.quest_state ~= nil then
							img_path = conf.quest_state and "point_mq_small.png" or "point_sq_small.png"
						end

						if direction then
							local px, py = X, Y - ICON_SY_HALF
							if direction == DIRECTION_TYPE_LEFT then
								dxDrawImage( px, py, ICON_SX, ICON_SY, "img/arrow.png", 0 )

								px = px + ICON_SX + 10
								py = py + ICON_SY_HALF - POINT_ICON_SY_HALF
								dxDrawImage(
									px, py,
									POINT_ICON_SX, POINT_ICON_SY,
									"img/" .. img_path
								)

								px = px + POINT_ICON_SX + 6
								py = py + ICON_SY_HALF + 2
								DrawOutlinedText( str, px, py, px, py, 0xFFFFFFFF, 1, ibFonts.bold_12, "left", "center" )

							elseif direction == DIRECTION_TYPE_RIGHT then
								dxDrawImage( px, py, ICON_SX, ICON_SY, "img/arrow.png", 180 )

								px = px - POINT_ICON_SX - 10
								py = py + ICON_SY_HALF - POINT_ICON_SY_HALF
								dxDrawImage(
									px, py,
									POINT_ICON_SX, POINT_ICON_SY,
										"img/" .. img_path
								)

								px = px - 6
								py = py + ICON_SY_HALF + 2
								DrawOutlinedText( str, px, py, px, py, 0xFFFFFFFF, 1, ibFonts.bold_12, "right", "center" )
							end
						end
					end
				end
			end

			-- Подложка
			local dropimage = conf.dropimage
			if isElement( dropimage ) then
				local half_size = conf.dropimage_scale / 2
				dxDrawMaterialLine3D( px - half_size, py - half_size, pz - 0.95, px + half_size, py + half_size, pz - 0.95, dropimage, half_size * 3, conf.dropimage_color, px, py, pz + 2 )
			end

			-- Основное изображение
			local image = conf.image
			if not gps and isClear and isElement( image ) then
				local image_scale = conf.image_scale
				local screen_x, screen_y = getScreenFromWorldPosition( px, py, pz )
				if screen_x then
					if conf.image_material then
						local sx, sy = dxGetMaterialSize( image )
						local relation = sy / sx
						dxDrawMaterialLine3D( px, py, pz + image_scale / 2 * relation, px, py, pz - image_scale / 2 * relation, image, image_scale, conf.image_color )
					else
						local sx, sy = dxGetMaterialSize( image )
						local coeff = math.max( sx, sy ) / 128
						local scale = 10 / distance * SCREEN_SCALE_FACTOR * image_scale
						sx, sy = math_ceil( sx / coeff * scale ), math_ceil( sy / coeff * scale )
						dxDrawImage( screen_x - sx / 2, screen_y - sy / 2, sx, sy, image, 0, 0, 0, conf.image_color )

						-- Сдвиг текста вверх по экрану
						text_offset_y = -sy
					end
				end
			end

			-- Текст
			if not gps and isClear or gps then
				local text = conf.text
				if text then
					if conf.image_material then pz = pz + 1 end
					local screen_x, screen_y = getScreenFromWorldPosition( px, py, pz )
					if screen_x then
						local color = conf.dropimage_color or 0xFFFFFFFF
						local scale = math.max( 40 / distance * SCREEN_SCALE_FACTOR, 1 )
						dxDrawText( text, screen_x, screen_y + text_offset_y, screen_x, screen_y + text_offset_y, color, scale, "default-bold", "center", "center", false, false, false, true )
					end
				end
			end


		end
	end
end
addEventHandler( "onClientPreRender", root, RenderMarkers )

function GetTexture( texture_path )
	if type( texture_path ) ~= "string" then return texture_path end

	-- Создаем новую текстуру если такой нет в памяти
	if not TEXTURES[ texture_path ] then
		local texture = dxCreateTexture( texture_path, "dxt5", true )
		TEXTURES[ texture_path ] = {
			tick = getTickCount( ),
			texture = texture,
		}
		return texture

	-- Просто ставим состояние активной текстуры
	else
		TEXTURES[ texture_path ].tick = getTickCount( )
		return TEXTURES[ texture_path ].texture
	end
end

function FindMarkers( )
	local markers = { }

	local px, py, pz = getCameraMatrix( )

	for i, v in pairs( getElementsByType( "marker", root ) ) do
		local tpoint = getElementParent( v )
		if tpoint and getElementType( tpoint ) == "teleport_points" then
			local tpx, tpy, tpz = getElementPosition( tpoint )
			local gps = getElementData( tpoint, "gps" )

			if isElementStreamedIn( v ) and getDistanceBetweenPoints3D( px, py, pz, tpx, tpy, tpz ) <= MAX_DISTANCE or gps then
				local conf = {
					marker		= v,
					tpoint 		= tpoint,
					gps    		= gps,
					px     		= tpx,
					py     		= tpy,
					pz     		= tpz,
					attached	= v.attached,
					quest_state	= getElementData( tpoint, "quest_state" ),
				}

				-- Текст
				local text = getElementData( tpoint, "text" )
				if text and utf8.len( text ) > 0 then
					conf.text = text
				end

				-- Обычное изображение
				local image          = GetTexture( getElementData( tpoint, "image" ) )
				local image_color    = 0xFFFFFFFF
				local image_scale    = 1
				local image_material = getElementData( tpoint, "material" )
				if type( image ) == "table" then
					image_color = tocolor( image[ 2 ], image[ 3 ], image[ 4 ], image[ 5 ] )
					image_scale = image[ 6 ] or image_scale
					image       = GetTexture( image[ 1 ] )
				end
				conf.image          = image
				conf.image_color    = image_color
				conf.image_scale    = image_scale
				conf.image_material = image_material

				-- Подложка для маркера если она есть
				local dropimage       = GetTexture( getElementData( tpoint, "dropimage" ) )
				local dropimage_color = 0xFFFFFFFF
				local dropimage_scale = 1
				if type( dropimage ) == "table" then
					dropimage_color = tocolor( dropimage[ 2 ], dropimage[ 3 ], dropimage[ 4 ], dropimage[ 5 ] )
					dropimage_scale = dropimage[ 6 ] or dropimage_scale
					dropimage       = GetTexture( dropimage[ 1 ] )
				end

				if dropimage then
					conf.dropimage       = dropimage
					conf.dropimage_color = dropimage_color
					conf.dropimage_scale = dropimage_scale
				end

				-- Добавляем в отрисовку
				table.insert( markers, conf )
			end
		end
	end

	MARKERS = markers

	-- Зачищаем давно неиспользованные текстуры
	local tick = getTickCount( )
	for i, v in pairs( TEXTURES ) do
		if tick - v.tick > 5000 then
			if isElement( v.texture ) then destroyElement( v.texture ) end
			TEXTURES[ i ] = nil
		end
	end
end
FindMarkers( )
setTimer( FindMarkers, 750, 0 )