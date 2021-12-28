local COLLECT_POINTS = { }
local TEAM_SCORES = { 0, 0 }
local minigame_id, shovel

function CreateDataCollectionPoint( conf, is_minigame )
	local target_point = TeleportPoint( {
		x = conf.x, y = conf.y, z = conf.z,
		radius = 4,
		dimension = localPlayer.dimension,
		gps = false,
		ignore_gps_route = true,
	} )

	target_point.gps = false
	target_point.ignore_gps_route = true
	target_point.qid = conf.id
	target_point.keypress = "lalt"
    target_point.text = "ALT Взаимодействие"
	target_point.accepted_elements = { player = true }
	target_point.marker.markerType = "cylinder"
	target_point.elements = {}
	target_point.elements.blip = createBlipAttachedTo(target_point.marker, 41, 5, 250, 100, 100)
	target_point.elements.blip.position = target_point.marker.position
	target_point.minigame = is_minigame

	target_point.PostJoin = function( self, player )
		if player ~= localPlayer then return end
		if isPedDead( player ) then return end
		if isPedInVehicle( player ) then return end

		if self.minigame then
			StartDiggingMinigame( self.qid )
		else
			triggerServerEvent( "OnPlayerDataCollected", resourceRoot, self.qid )
		end
	end

	COLLECT_POINTS[ conf.id ] = target_point

	return target_point
end

function OnClientPlayerDataCollected( id )
	if COLLECT_POINTS[ id ] then
		COLLECT_POINTS[ id ]:destroy( )
		COLLECT_POINTS[ id ] = nil

		if minigame_id == id then
			StopDiggingMinigame( )
		end
	end
end
addEvent( "OnClientPlayerDataCollected", true )
addEventHandler( "OnClientPlayerDataCollected", resourceRoot, OnClientPlayerDataCollected )

function CleanUpQuestDataPoints( )
	for k, v in pairs( COLLECT_POINTS ) do
		if v and v.destroy then
			v:destroy( )
		end
	end

	COLLECT_POINTS = { }
end

-- Minigame
local minigame = {}

local disabled_controls = 
{
	"forwards",
	"backwards",
	"left",
	"right",
}

local iMinigameStarted = 0
local iLastDig = 0
local fZonePosition = 0
local iDigsMade, iGoodDigsMade = 0, 0

function StartDiggingMinigame( qid )
	StopDiggingMinigame( )

	shovel = createObject( 1219, localPlayer.position )
	setElementCollisionsEnabled( shovel, false )
	exports.bone_attach:attachElementToBone(shovel, localPlayer, 12, -0.3, 0.12, 0.1, 0, 90, -20)

	iLastDig = getTickCount()+1000
	iMinigameStarted = getTickCount()
	iDigsMade = 0
	iGoodDigsMade = 0
	minigame_id = qid

	minigame.sfx = playSound( ":nrp_hobby_digging/files/sounds/digging.mp3", true )
	setSoundPosition( minigame.sfx, math.random(0, 40) )
	setPedAnimation(localPlayer, "DIGGING", "Dig", -1, true, false)

	fZonePosition = math.random(0, 80)/100

	local scx, scy = guiGetScreenSize()

	minigame.bar_bg = ibCreateImage( scx/2+80, scy/2-120, 14, 220, nil, false, 0x80212b36)
	minigame.bar_zone = ibCreateImage( 1, 220*fZonePosition, 12, 40, nil, minigame.bar_bg, 0xFFe3ca41 )
	minigame.bar_line = ibCreateImage( -4, 0, 22, 2, nil, minigame.bar_bg, 0xFFFFFFFF )

	minigame.good = ibCreateImage( scx/2+94, scy/2-110, 106, 52, ":nrp_hobby_digging/files/img/good.png" ):ibData("alpha", 0)
	minigame.bad = ibCreateImage( scx/2+94, scy/2-110, 88, 50, ":nrp_hobby_digging/files/img/bad.png" ):ibData("alpha", 0)

	addEventHandler( "onClientPreRender", root, PreRenderMinigame )
	addEventHandler( "onClientPlayerWasted", localPlayer, StopDiggingMinigame )
	addEventHandler( "onClientKey", root, DiggingKeyHandler )

	for k,v in pairs(disabled_controls) do
		toggleControl( v, false )
	end
end

function StopDiggingMinigame()
	if isElement( shovel ) then destroyElement( shovel ) end

	for k,v in pairs(minigame) do
		if isElement(v) then
			destroyElement( v )
		end
	end
	removeEventHandler( "onClientPreRender", root, PreRenderMinigame )
	removeEventHandler( "onClientPlayerWasted", localPlayer, StopDiggingMinigame )
	removeEventHandler( "onClientKey", root, DiggingKeyHandler )

	setPedAnimation(localPlayer, nil)

	for k,v in pairs(disabled_controls) do
		toggleControl( v, true )
	end

	minigame = {}
	minigame_id = nil
end

function PreRenderMinigame()
	local fProgress = ( getTickCount() - iMinigameStarted ) / 2000

	local py = interpolateBetween( 10, 0, 0, 215, 0, 0, fProgress%1, "SineCurve" )
	minigame.bar_line:ibData("py", py)

	if iLastDig and getTickCount() - iLastDig > 15000 then
		localPlayer:ShowError("Не спи!")
		StopDiggingMinigame()
		return
	end

	if getKeyState("mouse1") then
		local is_good = py >= 220*fZonePosition and py <= 220*fZonePosition+40

		if OnPlayerDig( is_good ) then
			local mark_line = ibCreateImage( 0, py, 14, 2, nil, minigame.bar_bg, is_good and 0xff22dd22 or 0xffdd2222  )
			:ibTimer(function( element )
				destroyElement( element )
			end, 6000, 1, mark_line)
			:ibAlphaTo(0, 6000)

			table.insert(minigame, mark_line)

			minigame.bar_line:ibData("alpha", 50)
			:ibTimer( function() 
				minigame.bar_line:ibData("alpha", 255)
			end, 1800, 1)
		end
	end
end

function OnPlayerDig( is_good )
	if iLastDig and getTickCount() - iLastDig < 1800 then return end
	iLastDig = getTickCount()

	iDigsMade = iDigsMade + 1

	if is_good then
		iGoodDigsMade = iGoodDigsMade + 1
		minigame.hit_sfx = playSound(":nrp_hobby_digging/files/sounds/hit.mp3")
		minigame.good:ibAlphaTo(255, 500)
		:ibTimer(function()
			minigame.good:ibAlphaTo( 0, 500 )
		end, 1000, 1)
	else
		minigame.bad:ibAlphaTo(255, 500)
		:ibTimer(function()
			minigame.bad:ibAlphaTo( 0, 500 )
		end, 1000, 1)
	end

	if iGoodDigsMade >= 5 then
		triggerServerEvent( "OnPlayerDataCollected", resourceRoot, minigame_id )
		StopDiggingMinigame()
		return
	end

	if iDigsMade >= 12 then
		triggerServerEvent( "OnPlayerDataCollected", resourceRoot, minigame_id )
		StopDiggingMinigame()
		return
	end

	return true
end

local ui = {}
function ShowUI_DataCollection( state )
	if state then
		TEAM_SCORES = { 0, 0 }
		ShowUI_DataCollection( false )

		ui.title = ibCreateLabel( _SCREEN_X/2, 20, 0, 27, "Собрано данных", false, 0xFFffffff, 1, 1, "center", "center", ibFonts.regular_14 ):ibData("outline", 1)

		ui.team1_score = ibCreateLabel( _SCREEN_X/2-50, 60, 0, 27, TEAM_SCORES[1], false, 0xFF87ea9a, 1, 1, "center", "center", ibFonts.regular_24 ):ibData("outline", 1)
		ui.team2_score = ibCreateLabel( _SCREEN_X/2+50, 60, 0, 27, TEAM_SCORES[1], false, 0xFFe73f5e, 1, 1, "center", "center", ibFonts.regular_24 ):ibData("outline", 1)
	else
		DestroyTableElements( ui )
		ui = { }
	end
end

function OnClientTeamScoresSynced( new_scores )
	for k,v in pairs( new_scores ) do
		local delta = v - TEAM_SCORES[ k ]

		if delta ~= 0 then
			ui["team"..( k == GetCoopQuestTeamID() and 1 or 2 ).."_score"]:ibAlphaTo( 0, 300 )
			:ibTimer( function( ) 
				ui["team"..( k == GetCoopQuestTeamID() and 1 or 2 ).."_score"]:ibData( "text", v ):ibAlphaTo( 255, 200 )
			end, 500, 1 )
		end
	end

	TEAM_SCORES = new_scores
end
addEvent( "OnClientTeamScoresSynced", true )
addEventHandler( "OnClientTeamScoresSynced", resourceRoot, OnClientTeamScoresSynced )

function DiggingKeyHandler( key, state )
	if state and key == "mouse1" then
		cancelEvent()
	end
end