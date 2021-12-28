loadstring(exports.interfacer:extend("Interfacer"))()
Extend("ShUtils")
Extend("CVehicle")
Extend("CSound")
Extend("ib")

local RADION_ENABLED = true
local RADIO_BLOCKED = false
local sounds = {}

local function destroyLabelOnPlayerWastedOrExitVehicle( vehicle, seat )
	if isElement( pInsideSound ) then
		SoundDestroySource( pInsideSound )
	end

	DestroyRadioLabel()

	removeEventHandler("onClientKey",root,keyHandler)
	setElementData( localPlayer, "radio.channel", nil, false )
	if seat == 0 then 
		triggerServerEvent( "radio:setChannel", localPlayer, 1, vehicle )
		return 
	end
end

addEventHandler( "onClientPlayerVehicleExit", localPlayer, destroyLabelOnPlayerWastedOrExitVehicle )

addEventHandler( "onClientPlayerWasted", localPlayer, function()
	local vehicle = getPedOccupiedVehicle( localPlayer )
	if not vehicle then return end

	local seat = getPedOccupiedVehicleSeat( localPlayer )
	destroyLabelOnPlayerWastedOrExitVehicle( vehicle, seat )
end )

local scX, scY = guiGetScreenSize()
local sx, sy = scX / 2, scY / 4
local radio_label = nil

iLastChannel = 1
pInsideSound = nil
SETTING_VALUE = 0.8
GLOBAL_RADIO_MUL = 0.5

function changeChannel( value )
	iLastChannel = iLastChannel + value

	if iLastChannel < 1 then 
		iLastChannel = #CHANNELS
	elseif iLastChannel > #CHANNELS then
		iLastChannel = 1
	end

	visibleAction = "Выбрана волна: " .. CHANNELS[ iLastChannel ].FriendlyName

	if isElement( pInsideSound ) then
		SoundDestroySource( pInsideSound )
	end 

	if iLastChannel ~= 1 then
		setElementData( localPlayer, "radio.channel", { channel = iLastChannel, state = true }, false )
		pInsideSound = SoundCreateSource( SOUND_TYPE_2D, VEHICLE_RADIO[ iLastChannel ].Value )
		SoundSetVolume( pInsideSound, GLOBAL_RADIO_MUL )
	else
		setElementData( localPlayer, "radio.channel", { channel = iLastChannel, state = false }, false )
	end

	if isTimer( pChannelTimer ) then killTimer( pChannelTimer ) end
	pChannelTimer = setTimer( function()
		if getPedOccupiedVehicle( localPlayer ) then
			triggerServerEvent( "radio:setChannel", localPlayer, iLastChannel, localPlayer.vehicle )
		end
	end, 1200, 1 )

	if IsCanShowLabel() then
		CreateRadioLabel()
	end
end

function IsCanShowLabel()
	if not localPlayer:getData( "in_race" ) and not localPlayer:getData( "give_assembly_vehicle" ) then
		return true
	end
	return false
end

function CreateRadioLabel()
	DestroyRadioLabel()
	local veh = getPedOccupiedVehicle( localPlayer )
	if veh then
		radio_label = ibCreateLabel( 0, sy, scX, 0, visibleAction, _, 0xFFFFFFFF, _, _, "center", "top", ibFonts.bold_13 )
		:ibData( "outline", 1 )
		:ibTimer( function( self )
			self:destroy()
		end, 4000, 1 )
	end
end

function DestroyRadioLabel()
	if isElement( radio_label ) then
		radio_label:ibAlphaTo( 0, 150 )
	end
end

function keyHandler( key, state )
	if RADIO_BLOCKED then return end
	if localPlayer:getData( "is_smartwatch_active" ) then return end

	if state then
		local count_open_back = localPlayer:getData( "open_back" ) or 0
		if not isCursorShowing( ) or ( localPlayer:getData( "bFirstPerson" ) and not count_open_back or count_open_back == 0 ) then
			if isPedDoingGangDriveby( localPlayer ) then return end
			if key == "mouse_wheel_up" then
				changeChannel(1)
			elseif key == "mouse_wheel_down" then
				changeChannel(-1)
			end
		end
		-- if key == "num_7" then
		-- 	changeChannel(-1)
		-- elseif key == "num_9" then
		-- 	changeChannel(1)
		-- end
	end
end

addEventHandler( "onClientPlayerVehicleEnter", localPlayer, function( veh, seat )
	--iprint( "onClientPlayerVehicleEnter", RADION_ENABLED )
	if not RADION_ENABLED then return end

	local mdl = getElementModel( veh )
	if VEHICLE_TYPE_BIKE[ mdl ] then
		return false
	end
	if seat ~= 0 then return end

	GLOBAL_RADIO_MUL = SETTING_VALUE
	CreateRadioInterface()	
	SoundSetVolume( pInsideSound, GLOBAL_RADIO_MUL )
end )

function CreateRadioInterface()
	local phone_radio = getElementData( localPlayer, "radio.channel" )
	if phone_radio and phone_radio.channel then
		phone_radio = phone_radio.channel
		if phone_radio < 1 then 
			iLastChannel = #CHANNELS
		elseif phone_radio > #CHANNELS then
			iLastChannel = 1
		else
			iLastChannel = phone_radio
		end
		changeChannel( 0 )
	else
		changeChannel( 0 )
	end
	
	removeEventHandler( "onClientKey", root, keyHandler )
	addEventHandler( "onClientKey", root, keyHandler )
end

addEventHandler( "onClientResourceStart", resourceRoot, function()
	if getPedOccupiedVehicleSeat( localPlayer ) == 0 then
		CreateRadioInterface()
		GLOBAL_RADIO_MUL = SETTING_VALUE
		SoundSetVolume( pInsideSound, GLOBAL_RADIO_MUL )
	end
end )

addEvent( "radio:ToggleSound", true )
addEventHandler( "radio:ToggleSound", root, function( bState )
	if bState then
		if isElement( pInsideSound ) then
			setSoundVolume( pInsideSound, iTempStoredVolume )
		end
	else
		if isElement( pInsideSound ) then
			iTempStoredVolume = getSoundVolume( pInsideSound )
			setSoundVolume( pInsideSound, 0 )
		end
	end
end )

function HandleRadioBlock( )
	local keys = { "isWithinTuning", "block_radio" }
	local is_blocked = false
	for i, v in pairs( keys ) do
		if getElementData( localPlayer, v ) then
			is_blocked = true
			break
		end
	end

	BlockRadio( is_blocked )
	triggerEvent( "radio:ToggleSound", resourceRoot, not is_blocked )
end
addEventHandler( "onClientResourceStart", resourceRoot, HandleRadioBlock )

addEventHandler( "onClientElementDataChange", localPlayer, function( key )
	if key == "isWithinTuning" or key == "block_radio" then
		HandleRadioBlock( )
	end
end )

function BlockRadio( state )
	RADIO_BLOCKED = state
	triggerEvent( "SwitchRadioEnabled", localPlayer, not state )
end

function GetSoundFFT( pVehicle )
	if sounds[pVehicle] then
		return getSoundFFTData(sounds[pVehicle], 2048, 256)
	end
end

local ticks = 0
local timeout = 1000

function onSettingsChange_handler( changed, values )
	if changed.radio_coeff then
		if values.radio_coeff then
			SETTING_VALUE = values.radio_coeff
			if getPedOccupiedVehicleSeat( localPlayer ) ~= 0 then return end

			GLOBAL_RADIO_MUL = SETTING_VALUE
			SoundBandSetVolume( "radio", GLOBAL_RADIO_MUL )
			
			local cticks = getTickCount()
			if cticks - ticks > timeout then
				cticks = ticks
				triggerServerEvent( "radio:setVolume", localPlayer, GLOBAL_RADIO_MUL )
			end
			if isElement( pInsideSound ) then
				SoundSetVolume( pInsideSound, GLOBAL_RADIO_MUL )
			end
		end
	end
end
addEvent( "onSettingsChange" )
addEventHandler( "onSettingsChange", root, onSettingsChange_handler )

triggerEvent( "onSettingsUpdateRequest", localPlayer, "radio" )


function onClientPlayerReceiveRadioData_handler( data, reset )
	if isElement( pInsideSound ) then
		SoundDestroySource( pInsideSound )
	end
	iLastChannel = data.channel
	if iLastChannel ~= 1 then
		pInsideSound = SoundCreateSource( SOUND_TYPE_2D, VEHICLE_RADIO[ iLastChannel ].Value )
	end
	if isElement( pInsideSound ) then
		GLOBAL_RADIO_MUL = data.volume
		SoundSetVolume( pInsideSound, GLOBAL_RADIO_MUL )
	end
	removeEventHandler( "onClientKey", root, keyHandler )
end
addEvent( "onClientPlayerReceiveRadioData", true )
addEventHandler( "onClientPlayerReceiveRadioData", root, onClientPlayerReceiveRadioData_handler )


addEventHandler( "onClientElementDestroy", root, function ()
	if getElementType( source ) == "vehicle" and getPedOccupiedVehicle( localPlayer ) == source then
		local occupants = getVehicleOccupants( source )
		if #occupants > 1 then
			triggerServerEvent( "onServerVehicleDestroyed", localPlayer, occupants, source )
		end
		removeEventHandler( "onClientKey", root, keyHandler )
		if isElement( pInsideSound ) then
			SoundDestroySource( pInsideSound )
		end
		DestroyRadioLabel()
	end
end)

addEvent( "SwitchRadioEnabled" )
addEventHandler( "SwitchRadioEnabled", resourceRoot, function( state )
	RADION_ENABLED = state

	if not state then
		if isElement( pInsideSound ) then
			SoundDestroySource( pInsideSound )
		end

		DestroyRadioLabel()
		removeEventHandler( "onClientKey",root, keyHandler )
		setElementData( localPlayer, "radio.channel", nil, false )
	
		if localPlayer.vehicle and localPlayer.vehicleSeat == 0 then
			triggerServerEvent( "radio:setChannel", localPlayer, 1, localPlayer.vehicleSeat )
		end
	end
end )