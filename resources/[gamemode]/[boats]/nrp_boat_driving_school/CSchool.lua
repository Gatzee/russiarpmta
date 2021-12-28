Extend("CPlayer")
Extend("CInterior")
Extend("CUI")
Extend("ib")

ibUseRealFonts( true )

SPECIAL_LICENSES_LIST = 
{
	[LICENSE_TYPE_BOAT] = 
	{
		title = "Морской транспорт",
		cost = 35000,
	},
}

function OnClientResourceStart()
	for k,v in pairs( SCHOOL_MARKERS_LIST ) do
		CreateSpecialDrivingSchool( v, k )
	end
end
addEventHandler("onClientResourceStart", resourceRoot, OnClientResourceStart)

function CreateSpecialDrivingSchool( config, school_id )
	config.radius = config.radius or 2
	config.marker_text = "Морская школа"
	config.keypress = "lalt"
	config.text = "ALT Взаимодействие"

	local store = TeleportPoint(config)
	store.marker:setColor(0,100,255,40)
	store:SetImage( "files/img/icon_marker.png" )
	store.element:setData( "material", true, false )
    store:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.45 } )

	store.PreJoin = function( store, player )
		return true
	end
	store.PostJoin = function(store) 
		if localPlayer:GetBlockInteriorInteraction() then
            localPlayer:ShowInfo( "Вы не можете войти во время задания" )
            return false
        end
		ShowUI_School( true, school_id ) 
	end
	store.PostLeave = function(store) 
		ShowUI_School( false ) 
	end
end

local pData = {}
local pExam = {}

function OnClientSpecialExamStarted( data )
	pData = data

	-- TODO Exam Sequence (?)
	pData.vehicle:setData("exam_vehicle", true, false)

	setElementData( localPlayer, "driving_exam", true, false )

	StartRoute()

	pExam.hint_bg = ibCreateImage( 0, scy-150, scx, 150, nil, false, 0x80000000 )
	ibCreateLabel( 0, 0, scx, 150, "Двигайся по маршруту, стараясь не повредить транспортное средство", pExam.hint_bg, 0xFFFFFFFF, 1, 1, "center", "center" )
		:ibData("font", ibFonts.regular_18)
end
addEvent("OnClientSpecialExamStarted", true)
addEventHandler("OnClientSpecialExamStarted", resourceRoot, OnClientSpecialExamStarted)

function OnClientSpecialExamFinished()
	DestroyTableElements( pData )
	DestroyClientExamStuff()

	removeEventHandler("onClientKey", root, ExamKeyHandler)
	removeEventHandler("onClientRender", root, RenderExam)

	setElementData( localPlayer, "driving_exam", false, false )
end
addEvent("OnClientSpecialExamFinished", true)
addEventHandler("OnClientSpecialExamFinished", resourceRoot, OnClientSpecialExamFinished)

function OnClientExamFail( reason )
	removeEventHandler("onClientRender", root, RenderExam)

	triggerServerEvent("OnPlayerSpecialExamFinished", resourceRoot)

	if reason then
		localPlayer:ShowError(reason)
	end
end

function StartRoute()
	pExam.route = ROUTES_LIST[ pData.school_id ][ pData.license_type ].pRoute
	pExam.marker_id = 0

	NextRouteMarker()

	addEventHandler("onClientKey", root, ExamKeyHandler)
	addEventHandler("onClientRender", root, RenderExam)
end

function NextRouteMarker()
	if isElement(pExam.marker) then destroyElement( pExam.marker ) end
	if isElement(pExam.blip) then destroyElement( pExam.blip ) end

	pExam.marker_id = pExam.marker_id + 1

	local pNextMarkerData = pExam.route[ pExam.marker_id ]

	if not pNextMarkerData then
		triggerServerEvent("OnPlayerSpecialExamFinished", resourceRoot, true)
		return
	end

	pExam.marker = createMarker( pNextMarkerData, "checkpoint", 30, 200, 50, 50, 150 )

	if pExam.route[ pExam.marker_id + 1 ] then
		setMarkerTarget(pExam.marker, pExam.route[ pExam.marker_id + 1 ])
	end

	pExam.blip = createBlipAttachedTo( pExam.marker, 0, 2, 200, 50, 50 )
	
	pExam.blip.dimension = localPlayer.dimension
	pExam.marker.dimension = localPlayer.dimension

	addEventHandler("onClientMarkerHit", pExam.marker, OnRouteMarkerHit)
end

function OnRouteMarkerHit( pPlayer, dim )
	if pPlayer == localPlayer and dim then
		NextRouteMarker()
		if isElement(pExam.hint_bg) then destroyElement( pExam.hint_bg ) end
	end
end

function DestroyClientExamStuff()
	DestroyTableElements(pExam)
	pExam = {}
end

local disabled_keys = 
{
	["p"] = true,
	[1] = true,
}

function ExamKeyHandler(key, state)
	if disabled_keys[key] then
		cancelEvent()
	end
end

function RenderExam()
	if isElement(pExam.marker) then

		if isPedDead( localPlayer ) then
			OnClientExamFail()
			return
		end

		if not isElement(pData.vehicle) then
			OnClientExamFail()
			return
		end

		if pData.vehicle.health <= 900 then
			OnClientExamFail( "Ты повредил транспорт" )
			return
		end

		if not localPlayer.vehicle then
			OnClientExamFail( "Ты покинул транспортное средство" )
			return
		end

		dxDrawLine3D( pData.vehicle.position, pExam.marker.position, 0xFF22DD22, 20 )
	end
end

-- Constructor
--[[
local points = {}

function RenderRoute()
	for k,v in pairs(points) do
		local pNextPoint = points[k + 1]
		if pNextPoint then
			dxDrawLine3D( v, pNextPoint, 0xFF22DD22, 20 )
		end
	end
end
addEventHandler("onClientRender", root, RenderRoute)

bindKey("num_1", "down", function()
	table.insert(points, localPlayer.vehicle.position)
end)

bindKey("num_2", "down", function()
	table.remove(points, #points)
end)

bindKey("num_3", "down", function()
	for k,v in pairs(points) do
		outputConsole( "Vector3( "..math.floor(v.x*100)/100 ..", "..math.floor(v.y*100)/100 ..", "..math.floor(v.z*100)/100 .." ),")
	end
end)
]]