ibUseRealFonts( true )

local data_exam_air = { }
local exam_air = { }

function OnResourceStop_handler( )
	OnFinishExamAir_handler( )
end
addEventHandler( "onClientResourceStop", resourceRoot, OnResourceStop_handler )

function OnStartlExamAir_handler( data )
	data_exam_air = data
	toggleControl( "enter_exit", false )
	data_exam_air.vehicle:setData( "exam_vehicle", true, false )
	setElementData( localPlayer, "driving_exam", true, false )

	StartRouteAir( )

	exam_air.hint_bg = ibCreateImage( 0, _SCREEN_Y - 150, _SCREEN_X, 150, nil, false, 0x80000000 )
	ibCreateLabel( 0, 0, _SCREEN_X, 150, "Двигайся по маршруту, стараясь не повредить транспортное средство", exam_air.hint_bg, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_18 )
end
addEvent( "OnStartlExamAir", true )
addEventHandler( "OnStartlExamAir", resourceRoot, OnStartlExamAir_handler )

function OnFinishExamAir_handler( )
	DestroyTableElements( data_exam_air )
	DestroyExamAirStuff( )

	toggleControl( "enter_exit", true )

	removeEventHandler( "onClientKey", root, onClickExamAir_handler )
	removeEventHandler( "onClientRender", root, OnRenderExamAir_handler )

	setElementData( localPlayer, "driving_exam", false, false )
end
addEvent( "OnFinishExamAir", true )
addEventHandler( "OnFinishExamAir", resourceRoot, OnFinishExamAir_handler )

function ExamAirFail( reason )
	removeEventHandler( "onClientRender", root, OnRenderExamAir_handler )

	triggerServerEvent( "OnPassedExamAir", resourceRoot, localPlayer )

	if reason then localPlayer:ShowError( reason ) end
end

function StartRouteAir( )
	exam_air.route = AIR_SCHOOL_ROUTES[ data_exam_air.school_id ][ data_exam_air.license_type ].route
	exam_air.marker_id = 0

	NextRouteAirMarker( )

	addEventHandler( "onClientKey", root, onClickExamAir_handler )
	addEventHandler( "onClientRender", root, OnRenderExamAir_handler )
end

function NextRouteAirMarker( )
	if isElement( exam_air.marker ) then destroyElement( exam_air.marker ) end
	if isElement( exam_air.blip ) then destroyElement( exam_air.blip ) end

	exam_air.marker_id = exam_air.marker_id + 1

	local next_marker_data = exam_air.route[ exam_air.marker_id ]

	if not next_marker_data then
		triggerServerEvent( "OnPassedExamAir", resourceRoot, localPlayer, true )
		return
	end

	exam_air.marker = createMarker( next_marker_data, "ring", 20, 200, 50, 50, 150 )

	if exam_air.route[ exam_air.marker_id + 1 ] then
		setMarkerTarget( exam_air.marker, exam_air.route[ exam_air.marker_id + 1 ] )
	end

	exam_air.blip = createBlipAttachedTo( exam_air.marker, 0, 2, 200, 50, 50 )
	
	exam_air.blip.dimension = localPlayer.dimension
	exam_air.marker.dimension = localPlayer.dimension

	addEventHandler( "onClientMarkerHit", exam_air.marker, OnHitRouteAirMarker_handler )
end

function OnHitRouteAirMarker_handler( player, dim )
	if player == localPlayer and dim then
		NextRouteAirMarker( )
		if isElement( exam_air.hint_bg ) then destroyElement( exam_air.hint_bg ) end
	end
end

function DestroyExamAirStuff( )
	DestroyTableElements( exam_air )
	exam_air = { }
end

function onClickExamAir_handler( key, state )
	if key == "p" or key == "1" then
		cancelEvent( )
	end
end

function OnRenderExamAir_handler( )
	if isElement( exam_air.marker ) then

		if isPedDead( localPlayer ) then
			ExamAirFail( )
			return
		end

		if not isElement( data_exam_air.vehicle ) then
			ExamAirFail( )
			return
		end

		if data_exam_air.vehicle.health <= 850 then
			ExamAirFail( "Ты повредил транспорт" )
			return
		end

		if isElementInWater( data_exam_air.vehicle ) and data_exam_air.license_type ~= LICENSE_TYPE_BOAT then
			ExamAirFail( "Ты утопил транспорт" )
			return
		end

		if not localPlayer.vehicle then
			ExamAirFail( "Ты покинул транспортное средство" )
			return
		end

		dxDrawLine3D( data_exam_air.vehicle.position, exam_air.marker.position, 0xFF22DD22, 20 )
	end
end