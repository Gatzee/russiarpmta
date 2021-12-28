local TIME_LEFT = 0
local SCORES = {}
local POINT = {}
local CP_OBJECTS = {}

local ui = {}

local is_low_res = _SCREEN_X <= 1024
local py = 40

function ShowUI_ControlPoints( state, data )
	if state then
		--DisableHUD(true)

		TIME_LEFT = data.time_left or TIME_LEFT
		SCORES = data.scores or { 0, 0 }

		POINT = 
		{ 
			state = POINT_STATE_NEUTRAL, 
			team = false, 
			update_tick = 0,
			position = data.position,
		}

		local rpx = _SCREEN_X/2 + 40
		local lpx = _SCREEN_X/2 - 220

		local fLeft = data.scores[1] / CAPTURE_TOTAL_DURATION
		local fRight = data.scores[2] / CAPTURE_TOTAL_DURATION

		--ui.icon_green = ibCreateImage( lpx-20+35, py, 23, 27, "files/img/icon_green.png" )
		ui.left_bg = ibCreateImage( lpx+85, py+8, 102, 10, nil, false, 0xFF33583a )
		ui.left_body = ibCreateImage( lpx+86, py+9, 100*fLeft, 8, nil, false, 0xFF87ea9a )
		ui.label_left = ibCreateLabel( lpx+60, py, 0, 27, GetTimerString( CAPTURE_TOTAL_DURATION-data.scores[1] ), false, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_16 ):ibData("outline", 1)

		if is_low_res then
			--ui.icon_purple = ibCreateImage(lpx-20+35, py+40, 27, 27, "files/img/icon_purple.png")
			ui.right_bg = ibCreateImage( lpx+85, py+8+40, 102, 10, nil, false, 0xFF492a2a )
			ui.right_body = ibCreateImage( lpx+86, py+9+40, 100*fRight, 8, nil, false, 0xFFe73f5e )
			ui.label_right = ibCreateLabel( lpx+60, py+40, 0, 27, GetTimerString( CAPTURE_TOTAL_DURATION-data.scores[2] ), false, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_16 ):ibData("outline", 1)
			
			ui.time_left = ibCreateLabel( _SCREEN_X/2, py+20, 0, 27, "10:00", false, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.regular_12 ):ibData("outline", 1)
		else
			--ui.icon_purple = ibCreateImage( rpx+130+20, py, 27, 27, "files/img/icon_purple.png" )
			ui.right_bg = ibCreateImage( rpx, py+8, 102, 10, nil, false, 0xFF492a2a )
			ui.right_body = ibCreateImage( rpx+1, py+9, 100*fRight, 8, nil, false, 0xFFe73f5e )
			ui.label_right = ibCreateLabel( rpx+130, py, 0, 27, GetTimerString( CAPTURE_TOTAL_DURATION-data.scores[2] ), false, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_16 ):ibData("outline", 1)
		
			ui.time_left = ibCreateLabel( _SCREEN_X/2, py, 0, 27, "10:00", false, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.regular_12 ):ibData("outline", 1)
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

			if POINT.state == POINT_STATE_CAPTURED then
        if POINT.team == GetCoopQuestTeamID( ) then
				  SCORES[ 1 ] = SCORES[ 1 ] + 1
        else
          SCORES[ 2 ] = SCORES[ 2 ] + 1
        end

				ui.label_left:ibData( "text", GetTimerString( CAPTURE_TOTAL_DURATION-math.floor(SCORES[1]) ) )
				ui.label_right:ibData( "text", GetTimerString( CAPTURE_TOTAL_DURATION-math.floor(SCORES[2]) ) )

				local fLeft = SCORES[1] / CAPTURE_TOTAL_DURATION
				local fRight = SCORES[2] / CAPTURE_TOTAL_DURATION

				ui.left_body:ibData("sx", 100*fLeft)
				ui.right_body:ibData("sx", 100*fRight)
			end
		end, 1000, 0)

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
	POINT.team = data.team or POINT.team
	POINT.state = data.state or POINT.state

	if data.scores then
    local my_team_id = GetCoopQuestTeamID( )
    local opp_team_id = GetCoopQuestTeamID( ) == 1 and 2 or 1

    local temp_scores = table.copy( data.scores )

    data.scores[ 1 ] = temp_scores[ my_team_id ]
    data.scores[ 2 ] = temp_scores[ opp_team_id ] 

		local fLeft = data.scores[1] / CAPTURE_TOTAL_DURATION
		local fRight = data.scores[2] / CAPTURE_TOTAL_DURATION

		SCORES = data.scores

		ui.label_left:ibData( "text", GetTimerString( CAPTURE_TOTAL_DURATION-math.floor(data.scores[1]) ) )
		ui.label_right:ibData( "text", GetTimerString( CAPTURE_TOTAL_DURATION-math.floor(data.scores[2]) ) )

		ui.left_body:ibData("sx", 100*fLeft)
		ui.right_body:ibData("sx", 100*fRight)
	end
end
addEvent("CPQ:UpdateGameUI", true)
addEventHandler("CPQ:UpdateGameUI", resourceRoot, UpdateGameUI)

local iLastUpdate = 0

function RenderPoints()
	local iTick = getTickCount()

    local pointPos = POINT.position
    local x, y, z = pointPos.x, pointPos.y, pointPos.z
	if getDistanceBetweenPoints3D ( x, y, z, localPlayer.position ) <= 80 then
		local color = 0xFF858585
		if POINT.state == POINT_STATE_CAPTURING or POINT.state == POINT_STATE_CAPTURED then
			color = POINT.team and tocolor( unpack( TEAM_COLORS[POINT.team] ) ) or color
		end
		for i = 1, 3 do
			dxDrawCircle3D( x, y, z + (i - 2) * 0.2, CAPTURE_ZONE_RADIUS, 32, color, 3 )
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

local OBJECTS_CONF = 
{
	{
      model = 2991,
      ry = 0,
      rz = 69,
      x = 596.67664,
      y = 2406.9004,
      z = 14.066775
    }, {
      model = 2991,
      ry = 0,
      rz = 69,
      x = 596.80658,
      y = 2406.9238,
      z = 15.296834
    }, {
      model = 2991,
      ry = 0,
      rz = 156,
      x = 593.04016,
      y = 2412.4092,
      z = 14.05843
    }, {
      model = 2991,
      ry = 0,
      rz = 156,
      x = 593.09119,
      y = 2412.3879,
      z = 15.288488
    }, {
      model = 2932,
      ry = 0,
      rz = 193,
      x = 576.24329,
      y = 2424.8796,
      z = 24.784163
    }, {
      model = 2935,
      ry = 0,
      rz = 193,
      x = 576.25867,
      y = 2424.8782,
      z = 27.637577
    }, {
      model = 2935,
      ry = 0,
      rz = 193,
      x = 579.68372,
      y = 2405.9019,
      z = 24.779955
    }, {
      model = 2935,
      ry = 0,
      rz = 372,
      x = 579.75684,
      y = 2405.8494,
      z = 27.633369
    }, {
      model = 2991,
      ry = 0,
      rz = 461,
      x = 577.29181,
      y = 2418.3425,
      z = 23.984163
    }, {
      model = 2991,
      ry = 0,
      rz = 461,
      x = 577.17194,
      y = 2418.3052,
      z = 25.214222
    }, {
      model = 2991,
      ry = 0,
      rz = 461,
      x = 578.44196,
      y = 2412.5806,
      z = 23.984163
    }, {
      model = 2935,
      ry = 0,
      rz = 514,
      x = 542.26801,
      y = 2406.4724,
      z = 24.784163
    }, {
      model = 2932,
      ry = 0,
      rz = 514,
      x = 542.30737,
      y = 2406.4805,
      z = 27.637577
    }, {
      model = 2932,
      ry = 0,
      rz = 553,
      x = 539.58374,
      y = 2395.5601,
      z = 24.784163
    }, {
      model = 2932,
      ry = 0,
      rz = 553,
      x = 539.67963,
      y = 2395.5403,
      z = 27.637577
    }, {
      model = 3066,
      ry = 0,
      rz = 567,
      x = 572.92596,
      y = 2408.0459,
      z = 14.466775
    }, {
      model = 3066,
      ry = 0,
      rz = 526,
      x = 548.11493,
      y = 2402.3921,
      z = 14.473246
    }, {
      model = 2932,
      ry = 0,
      rz = 732,
      x = 572.50214,
      y = 2424.116,
      z = 14.862009
    }, {
      model = 2935,
      ry = 0,
      rz = 680,
      x = 555.79395,
      y = 2420.2588,
      z = 14.866462
    }, {
      model = 2935,
      ry = 0,
      rz = 641,
      x = 569.16156,
      y = 2397.655,
      z = 24.784163
    }, {
      model = 2932,
      ry = 0,
      rz = 641,
      x = 552.70135,
      y = 2394.5542,
      z = 24.784163
    }, {
      model = 2974,
      ry = 0,
      rz = 641,
      x = 539.19116,
      y = 2394.0591,
      z = 13.579475
    }, {
      model = 2974,
      ry = 0,
      rz = 641,
      x = 584.25696,
      y = 2403.2937,
      z = 13.585989
    }, {
      model = 2973,
      ry = 0,
      rz = 672,
      x = 592.07495,
      y = 2407.8865,
      z = 13.579475
    }, {
      model = 2991,
      ry = 0,
      rz = 734,
      x = 528.72083,
      y = 2399.1687,
      z = 14.073244
    }, {
      model = 2991,
      ry = 0,
      rz = 734,
      x = 530.53235,
      y = 2390.0674,
      z = 14.073246
    }, {
      model = 2991,
      ry = 0,
      rz = 734,
      x = 530.55353,
      y = 2389.9851,
      z = 15.303305
    }, {
      model = 2973,
      ry = 0,
      rz = 734,
      x = 535.49268,
      y = 2398.2217,
      z = 13.579475
    }, {
      model = 2973,
      ry = 0,
      rz = 734,
      x = 535.59387,
      y = 2398.2473,
      z = 16.04038
    }, {
      model = 2973,
      ry = 0,
      rz = 734,
      x = 561.21808,
      y = 2398.9912,
      z = 13.466063
    }, {
      model = 2973,
      ry = 0,
      rz = 722,
      x = 563.83527,
      y = 2399.6401,
      z = 13.466775
    },
    {
      model = 2935,
      ry = 0,
      rz = 854,
      x = -1488.9877,
      y = 2230.6807,
      z = 11.325891
    }, {
      model = 2935,
      ry = 0,
      rz = 854,
      x = -1489.0109,
      y = 2230.7168,
      z = 14.179305
    }, {
      model = 2935,
      ry = 0,
      rz = 854,
      x = -1479.7356,
      y = 2239.3047,
      z = 11.320942
    }, {
      model = 2935,
      ry = 0,
      rz = 854,
      x = -1479.7396,
      y = 2239.3293,
      z = 14.174356
    }, {
      model = 2932,
      ry = 0,
      rz = 854,
      x = -1495.0283,
      y = 2255.4609,
      z = 11.320309
    }, {
      model = 2932,
      ry = 0,
      rz = 854,
      x = -1495.046,
      y = 2255.4944,
      z = 14.173723
    }, {
      model = 2932,
      ry = 0,
      rz = 854,
      x = -1504.1171,
      y = 2246.3306,
      z = 11.326272
    }, {
      model = 2932,
      ry = 0,
      rz = 854,
      x = -1504.1211,
      y = 2246.3525,
      z = 14.179687
    }, {
      model = 2932,
      ry = 0,
      rz = 854,
      x = -1502.7222,
      y = 2254.3784,
      z = 11.52531
    }, {
      model = 2935,
      ry = 0,
      rz = 854,
      x = -1481.4911,
      y = 2231.7527,
      z = 11.521417
    }, {
      model = 2991,
      ry = 0,
      rz = 947,
      x = -1486.4785,
      y = 2239.8599,
      z = 10.721417
    }, {
      model = 2991,
      ry = 0,
      rz = 940,
      x = -1489.4193,
      y = 2237.0664,
      z = 10.72531
    }, {
      model = 2991,
      ry = 0,
      rz = 942,
      x = -1488.012,
      y = 2238.48,
      z = 11.955369
    }, {
      model = 2991,
      ry = 0,
      rz = 942,
      x = -1497.7441,
      y = 2246.4929,
      z = 10.72531
    }, {
      model = 2991,
      ry = 0,
      rz = 942,
      x = -1494.7051,
      y = 2249.2617,
      z = 10.72531
    }, {
      model = 2991,
      ry = 0,
      rz = 942,
      x = -1496.217,
      y = 2248.0276,
      z = 11.955369
    }, {
      model = 2973,
      ry = 0,
      rz = 942,
      x = -1498.4933,
      y = 2237.4836,
      z = 9.9160967
    }, {
      model = 2973,
      ry = 0,
      rz = 942,
      x = -1493.147,
      y = 2232.3328,
      z = 9.9240551
    }, {
      model = 2973,
      ry = 0,
      rz = 942,
      x = -1502.6162,
      y = 2242.2864,
      z = 9.9165955
    },
    {
      model = 2935,
      ry = 0,
      rz = 48,
      x = 2395.2222,
      y = 2728.2798,
      z = 8.3521633
    }, {
      model = 2935,
      ry = 0,
      rz = 131,
      x = 2404.2532,
      y = 2727.9939,
      z = 8.3456726
    }, {
      model = 2935,
      ry = 0,
      rz = 131,
      x = 2397.281,
      y = 2762.4604,
      z = 8.3485365
    }, {
      model = 2935,
      ry = 0,
      rz = 53,
      x = 2406.6526,
      y = 2763.5811,
      z = 8.409317
    }, {
      model = 2932,
      ry = 0,
      rz = 81,
      x = 2388.6394,
      y = 2750.7041,
      z = 8.3426771
    }, {
      model = 2932,
      ry = 0,
      rz = 81,
      x = 2412.2322,
      y = 2741.0437,
      z = 8.3426771
    }, {
      model = 2991,
      ry = 0,
      rz = 81,
      x = 2411.7529,
      y = 2749.9141,
      z = 7.5354028
    }, {
      model = 2991,
      ry = 0,
      rz = 81,
      x = 2390.2461,
      y = 2743.2593,
      z = 7.5426774
    }, {
      model = 2991,
      ry = 0,
      rz = 127,
      x = 2401.3706,
      y = 2756.4299,
      z = 7.5354028
    }, {
      model = 2991,
      ry = 0,
      rz = 127,
      x = 2401.3552,
      y = 2756.2542,
      z = 8.765461
    }, {
      model = 2991,
      ry = 0,
      rz = 212,
      x = 2400.6975,
      y = 2736.0352,
      z = 7.5354028
    }, {
      model = 2991,
      ry = 0,
      rz = 212,
      x = 2400.7375,
      y = 2736.0991,
      z = 8.765461
    },
    {
      model = 2973,
      ry = 0,
      rz = 0,
      x = 2391.9419,
      y = 2737.2756,
      z = 6.9426775
    }, {
      model = 3066,
      ry = 0,
      rz = 85,
      x = 2400.8796,
      y = 2727.4641,
      z = 7.9582024
    }, {
      model = 2935,
      ry = 0,
      rz = 169,
      x = 2391.4983,
      y = 2755.6089,
      z = 8.3426771
    }, {
      model = 2935,
      ry = 0,
      rz = 192,
      x = 2411.6287,
      y = 2758.7739,
      z = 8.3354025
    }, {
      model = 2991,
      ry = 0,
      rz = 191,
      x = 2412.7781,
      y = 2753.6743,
      z = 7.5354028
    }, {
      model = 2991,
      ry = 0,
      rz = 265,
      x = 2411.3159,
      y = 2745.853,
      z = 7.5354028
    }, {
      model = 2991,
      ry = 0,
      rz = 265,
      x = 2412.2629,
      y = 2751.8638,
      z = 8.765461
    }, {
      model = 2974,
      ry = 0,
      rz = 354,
      x = 2407.9275,
      y = 2735.2725,
      z = 6.9426775
    }, {
      model = 2935,
      ry = 0,
      rz = 442,
      x = 2388.21,
      y = 2747.7686,
      z = 8.3426771
    }, {
      model = 2991,
      ry = 0,
      rz = 424,
      x = 2388.7075,
      y = 2739.3523,
      z = 7.5426774
    }, {
      model = 2991,
      ry = 0,
      rz = 441,
      x = 2390.2046,
      y = 2743.1006,
      z = 8.7727356
    }, {
      model = 2991,
      ry = 0,
      rz = 414,
      x = 2403.094,
      y = 2766.6201,
      z = 7.6962762
    }, {
      model = 2991,
      ry = 0,
      rz = 448,
      x = 2409.9331,
      y = 2736.6433,
      z = 7.5426774
    }
}

function CreateControlPointObjects( )
	DestroyControlPointObjects( )

	for k,v in pairs( OBJECTS_CONF ) do
		local object = createObject( v.model, v.x, v.y, v.z, v.rx or 0, v.ry or 0, v.rz or 0 )
		object.dimension = localPlayer.dimension
    setObjectBreakable( object, false )
		table.insert( CP_OBJECTS, object )
	end
end

function DestroyControlPointObjects( )
	DestroyTableElements( CP_OBJECTS )
	CP_OBJECTS = {}
end