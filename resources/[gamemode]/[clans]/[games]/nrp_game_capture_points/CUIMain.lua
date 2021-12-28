local TIME_LEFT = 0
local SCORES = {}
local POINTS = {}

local ui = {}

local is_low_res = scx <= 1024
local py = 40

function ShowUI_Main( state, data )
	if state then
		--DisableHUD(true)

		TIME_LEFT = data.time_left or TIME_LEFT
		SCORES = data.scores

		POINTS = {}
		for i = 1, #POINT_POSITIONS do
			POINTS[i] = 
			{ 
				state = POINT_STATE_NEUTRAL, 
				band = false, 
				progress = 0, 
				progress_delta = 0, 
				update_tick = 0,
			}
		end

		local rpx = scx/2 + 40
		local lpx = scx/2 - 220

		local fLeft = data.scores.green / 800
		local fRight = data.scores.purple / 800

		ui.icon_green = ibCreateImage( lpx-20+35, py, 23, 27, "files/img/icon_green.png" )
		ui.left_bg = ibCreateImage( lpx+85, py+8, 102, 10, nil, false, 0xFF33583a )
		ui.left_body = ibCreateImage( lpx+86, py+9, 100*fLeft, 8, nil, false, 0xFF87ea9a )
		ui.label_left = ibCreateLabel( lpx+60, py, 0, 27, data.scores.green, false, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_16 ):ibData("outline", 1)

		if is_low_res then
			ui.icon_purple = ibCreateImage(lpx-20+35, py+40, 27, 27, "files/img/icon_purple.png")
			ui.right_bg = ibCreateImage( lpx+85, py+8+40, 102, 10, nil, false, 0xFF492a2a )
			ui.right_body = ibCreateImage( lpx+86, py+9+40, 100*fRight, 8, nil, false, 0xFFe73f5e )
			ui.label_right = ibCreateLabel( lpx+60, py+40, 0, 27, data.scores.purple, false, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_16 ):ibData("outline", 1)
			
			ui.time_left = ibCreateLabel( scx/2, py+20, 0, 27, "10:00", false, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.regular_12 ):ibData("outline", 1)
		else
			ui.icon_purple = ibCreateImage( rpx+130+20, py, 27, 27, "files/img/icon_purple.png" )
			ui.right_bg = ibCreateImage( rpx, py+8, 102, 10, nil, false, 0xFF492a2a )
			ui.right_body = ibCreateImage( rpx+1, py+9, 100*fRight, 8, nil, false, 0xFFe73f5e )
			ui.label_right = ibCreateLabel( rpx+130, py, 0, 27, data.scores.purple, false, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_16 ):ibData("outline", 1)
		
			ui.time_left = ibCreateLabel( scx/2, py, 0, 27, "10:00", false, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.regular_12 ):ibData("outline", 1)
		end

		ui.time_left:ibTimer(function()
			TIME_LEFT = TIME_LEFT - 1

			if TIME_LEFT >= 1 then
				local minutes = tostring( math.floor( TIME_LEFT/60 ) ) 
				local seconds = tostring( TIME_LEFT - 60*minutes )

				minutes = (#minutes <= 1 and "0"..minutes) or minutes
				seconds = (#seconds <= 1 and "0"..seconds) or seconds

				ui.time_left:ibData("text", minutes..":"..seconds)
			else
				ui.time_left:ibData("text", "-")
			end
		end, 1000, 0)

		-- Points
		local px, py = 40, scy/2

		local point_names = { "A", "B", "C", "D", "E", "F" }

		for i = 1, #POINT_POSITIONS do
			ui["point_name"..i] = ibCreateLabel( px, py, 0, 0, point_names[i], false, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_16 ):ibData("outline", 1)
			ui["point_bg"..i] = ibCreateImage( px+20, py-5, 120, 10, nil, false, 0xFF111111)
			ui["point_body"..i] = ibCreateImage( 1, 1, 118, 8, nil, ui["point_bg"..i], 0xFF858585)
			ui["point_status"..i] = ibCreateLabel( px+22, py-25, 0, 0, "свободна", false, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_10 )

			py = py + 40
		end

		addEventHandler("onClientRender", root, RenderPoints)
	else
		removeEventHandler("onClientRender", root, RenderPoints)
		--DisableHUD( false )
		for k,v in pairs(ui) do
			if isElement(v) then
				destroyElement( v )
			end
		end
	end
end

function UpdateGameUI( data )

	if data.scores then
		local fLeft = data.scores.green / 800
		local fRight = data.scores.purple / 800

		local iDeltaLeft = math.floor( data.scores.green - SCORES.green )
		local iDeltaRight = math.floor( data.scores.purple - SCORES.purple )

		if iDeltaLeft >= 1 then
			local px, py = ui.label_left:ibData("px"), ui.label_left:ibData("py")
			local label = ibCreateLabel( px, py, 0, 27, "+ "..iDeltaLeft, false, 0xFF22FF22, 1, 1, "center", "center", ibFonts.bold_16 )
			:ibAlphaTo(0, 4000):ibMoveTo( px, py+60, 4000 )
			:ibTimer(function( element )
				if isElement(element) then destroyElement( element ) end
			end, 4000, 1, label)
		end

		if iDeltaRight >= 1 then
			local px, py = ui.label_right:ibData("px"), ui.label_right:ibData("py")
			local label = ibCreateLabel( px, py, 0, 27, "+ "..iDeltaRight, false, 0xFF22FF22, 1, 1, "center", "center", ibFonts.bold_16 )
			:ibAlphaTo(0, 4000):ibMoveTo( px, py+60, 4000 )
			:ibTimer(function( element )
				if isElement(element) then destroyElement( element ) end
			end, 4000, 1, label) 
		end

		SCORES = data.scores

		ui.label_left:ibData( "text", math.floor(data.scores.green) )
		ui.label_right:ibData( "text", math.floor(data.scores.purple) )

		ui.left_body:ibData("sx", 100*fLeft)
		ui.right_body:ibData("sx", 100*fRight)
	end

	local point_state_strings = 
	{
		[POINT_STATE_NEUTRAL] = "свободна",
		[POINT_STATE_CAPTURING] = "захватывается",
		[POINT_STATE_CAPTURED] = "захвачена",
		[POINT_STATE_CONFLICT] = "оспаривается",
	}

	if data.points then
		local iTick = getTickCount()
		for point_id, new_point_data in pairs(data.points) do
			local point_data = POINTS[point_id]
			local fOldProgress = point_data.progress or 0
			for key, value in pairs(new_point_data) do
				point_data[key] = value
			end
			if point_data.progress > 0 then
				point_data.progress_delta = point_data.progress - fOldProgress
			else
				point_data.progress_delta = 0
			end
			point_data.update_tick = iTick
		end

		for k,v in pairs(POINTS) do
			ui["point_status"..k]:ibData("text", point_state_strings[ v.state ])

			if v.band and ( v.state == POINT_STATE_CAPTURING or v.state == POINT_STATE_CAPTURED or v.state == POINT_STATE_CONFLICT ) then
				ui["point_body"..k]:ibData("color", tocolor( unpack( BANDS_COLORS[v.band] ) ) )
			else
				ui["point_body"..k]:ibData("color", 0xFF858585)
			end
			if v.state ~= POINT_STATE_CONFLICT then
				ui["point_body"..k]:ibData( "alpha", 255 )
			end
		end
	end
end
addEvent("CEV:UpdateGameUI", true)
addEventHandler("CEV:UpdateGameUI", resourceRoot, UpdateGameUI)

local iLastUpdate = 0

function RenderPoints()
	local iTick = getTickCount()

	for k, v in pairs(POINTS) do
		if v.state then
			local fProgress = v.progress_delta * (iTick - v.update_tick) / (ZONE_STATUS_UPDATE_INTERVAL * 1000)
			fProgress = fProgress - v.progress_delta
			fProgress = math.max( 0, math.min( v.progress + fProgress, 1 ) )

			ui["point_body"..k]:ibData( "sx", 118 * fProgress )

			if v.state == POINT_STATE_CONFLICT then
				ui["point_body"..k]:ibData( "alpha", 255 * math.sin( math.pi * ( iTick % 1337 ) / 1337 ) )
			end
		end

        local pointPos = POINT_POSITIONS[k]
        local x, y, z = pointPos.x, pointPos.y, pointPos.z
		if getDistanceBetweenPoints3D ( x, y, z, localPlayer.position ) <= 80 then
			local color = 0xFF858585
			if v.state == POINT_STATE_CAPTURING or v.state == POINT_STATE_CAPTURED then
				color = v.band and tocolor( unpack( BANDS_COLORS[v.band] ) ) or color
			end
			for i = 1, 3 do
				dxDrawCircle3D( x, y, z + (i - 2) * 0.2, CAPTURE_ZONE_RADIUS, 32, color, 3 )
			end
        end
	end

	iLastUpdate = iTick
end

function dxDrawCircle3D( x, y, z, radius, segments, color, width )
	local segAngle = 360 / segments
	local fX, fY, tX, tY
	for i = 1, segments do 
		fX = x + math.cos( math.rad( segAngle * i ) ) * radius; 
		fY = y + math.sin( math.rad( segAngle * i ) ) * radius; 
		tX = x + math.cos( math.rad( segAngle * ( i + 1 ) ) ) * radius; 
		tY = y + math.sin( math.rad( segAngle * ( i + 1 ) ) ) * radius;
		dxDrawLine3D( fX, fY, z, tX, tY, z, color, width )
	end 
end