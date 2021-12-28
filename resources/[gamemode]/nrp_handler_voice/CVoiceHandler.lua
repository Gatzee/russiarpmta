loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )
Extend( "ib" )
Extend( "CPlayer" )
Extend( "Globals" )
Extend( "CChat" )
Extend( "CUI" )

local CONST_ICON_SIZE = 24
local CONST_ICON_SIZE_HALF = CONST_ICON_SIZE / 2
local CONST_VOICE_RANGE = 15
local CONST_ICON_TEXT_OFFSET = 5

local CONST_LABEL_POSITION = CONST_ICON_SIZE + CONST_ICON_TEXT_OFFSET

local CONST_LINE_SPACING = CONST_ICON_SIZE + 5

local VOICE_TYPE_NORMAL = 1
local VOICE_TYPE_FACTION = 2
local VOICE_TYPE_PHONE 	 = 3

local PLAYERS_LABELS = { }

local SETTING_FACTION_VOICE_EFFECT_DELAY = 2500
local SETTING_FACTION_VOICE_VOLUME = 0.2

local SETTING_VOICE_MUL = 1

local SETTING_Y_BOTTOM_OFFSET_DEFAULT = _SCREEN_Y / 2
local SETTING_Y_BOTTOM_OFFSET_CASINO = SETTING_Y_BOTTOM_OFFSET_DEFAULT - 200

local SETTING_Y_BOTTOM_OFFSET = SETTING_Y_BOTTOM_OFFSET_DEFAULT

local VOICE_AREA = ibCreateDummy( ):ibData( "priority", 1 )

function Player.BuildTalkingLine( self, line_type )
	local area = ibCreateArea( 0, 0, 0, 24, VOICE_AREA ):ibData( "priority", 9999999999 )

	if line_type == VOICE_TYPE_NORMAL then
		ibCreateImage( 0, 0, CONST_ICON_SIZE, CONST_ICON_SIZE, "img/voice_small.png", area )
	elseif line_type == VOICE_TYPE_FACTION then
		ibCreateImage( 0, 0, CONST_ICON_SIZE, CONST_ICON_SIZE, "img/voice_small_faction.png", area )
	elseif line_type == VOICE_TYPE_PHONE then
		ibCreateImage( 0, 0, CONST_ICON_SIZE, CONST_ICON_SIZE, "img/voice_small_phone.png", area )
	end

	local lbl = ibCreateLabel( CONST_LABEL_POSITION, 0, 0, 0, self:GetNickName( ), area, _, _, _, "left", "center", ibFonts.bold_12 )
	:ibData( "outline", 1 ):center_y( )

	local width = lbl:ibGetAfterX( )
	area:ibBatchData( { sx = width, px = _SCREEN_X - 20 - width } )

	return area
end

function Player.DestroyFromTalkingList( self )
	if PLAYERS_LABELS[ self ] then
		if isElement( PLAYERS_LABELS[ self ].element ) then
			destroyElement( PLAYERS_LABELS[ self ].element )
		end
		PLAYERS_LABELS[ self ] = nil

		return true
	end
end

function SetVoiceChatVisible( state )
	VOICE_AREA:ibData( "alpha", state and 255 or 0 )
end

-- Обновление позиции элементов по Y
function SortVoiceChat( )
	local list = { }
	for i, v in pairs( PLAYERS_LABELS ) do
		table.insert( list, v )
	end
	table.sort( list, function( a, b ) return a.nickname < b.nickname end )

	local npy = SETTING_Y_BOTTOM_OFFSET
	for i = 1, #list do
		local element = list[ i ].element
		element:ibData( "py", npy - element:ibData( "sy" ) )

		npy = npy + CONST_LINE_SPACING
	end
end

-- Обновление громкости голоса от расстояния
function UpdateVoiceVolume( )
	local marked_for_removal = { }

	local dimension = getElementDimension( localPlayer )
	local px, py, pz = getElementPosition( localPlayer )
	local this_channel = localPlayer:GetFactionVoiceChannel( )

	local volume_mul = 10 * SETTING_VOICE_MUL
	for player_other, v in pairs( PLAYERS_LABELS ) do

		if player_other ~= localPlayer then
			local volume_old = getSoundVolume( player_other )

			local this_voice_channel = this_channel and player_other:GetFactionVoiceChannel( )
			local channel_matches = this_channel and this_voice_channel == this_channel

			local distance = not channel_matches and getDistanceBetweenPoints3D( px, py, pz, getElementPosition( player_other ) )

			local volume = volume_old
			
			if not v.ignore_distance then
				if distance then
					if getElementDimension( player_other ) == dimension then
						volume = math.min( 1, math.max( ( CONST_VOICE_RANGE - distance ) / CONST_VOICE_RANGE, 0 ) ) * volume_mul
					else
						table.insert( marked_for_removal, player_other )
					end
				else
					if channel_matches then
						volume = volume_mul
					else
						table.insert( marked_for_removal, player_other )
					end
				end

				if volume ~= volume_old then
					setSoundVolume( player_other, volume )
				end
			elseif v.ignore_distance and ( player_other:getData( "phone.call" ) or player_other:getData( "use_sputnik" ) ) then
				setSoundVolume( player_other, volume_mul )
			elseif localPlayer:GetFactionVoiceChannel( ) == player_other:GetFactionVoiceChannel( ) then
				setSoundVolume( player_other, volume_mul )
			else
				table.insert( marked_for_removal, player_other )
			end
		end

	end
	
	if #marked_for_removal > 0 then
		for _, v in pairs( marked_for_removal ) do
			v:DestroyFromTalkingList( )
		end
		SortVoiceChat( )
	end
end
UpdateVoiceVolume( )
setTimer( UpdateVoiceVolume, 50, 0 )

function onClientPlayerVoiceStart_handler( )
	local is_allowed = true

	-- Запреты для локального игрока
	if source == localPlayer then
		if not localPlayer:IsInGame( ) or localPlayer:IsVoiceMuted( ) then
			is_allowed = false
		end
	end

	local is_talking = PLAYERS_LABELS[ source ] ~= nil

	if is_allowed and not is_talking  then
		local voice_type = VOICE_TYPE_NORMAL
		local ignore_distance
		
		-- Рация
		local this_channel = localPlayer:GetFactionVoiceChannel( )
		if source:getData( "phone.call" ) then
			voice_type = VOICE_TYPE_PHONE
			ignore_distance = true

		elseif ( this_channel and this_channel == source:GetFactionVoiceChannel( ) ) 
		-- or ( source:getData( "use_sputnik" ) and source:GetFaction( ) == localPlayer:GetFaction( ) ) -- GetFaction возвращает приватную дату, т.е. у других игроков будет всегда false
		or ( source:getData( "use_sputnik" ) and ( source:GetClanID( ) or 0 ) == localPlayer:GetClanID( ) ) then -- все эти проверки уже выполняются в серверном onPlayerVoiceStart, можно и не чекать
			voice_type = VOICE_TYPE_FACTION
			ignore_distance = true

			-- Эффект рации для рации
			if not LAST_FACTION_EFFECT or getTickCount( ) - LAST_FACTION_EFFECT >= SETTING_FACTION_VOICE_EFFECT_DELAY then
				setSoundVolume( playSound( "sfx/noise.ogg" ), SETTING_FACTION_VOICE_VOLUME )
			end
		elseif source:getData( "use_sputnik" ) then
			cancelEvent( )
			return
		end
		
		PLAYERS_LABELS[ source ] = {
			element  = source:BuildTalkingLine( voice_type ),
			nickname = source:GetNickName( ),
			ignore_distance = ignore_distance,
		}

		SortVoiceChat( )

	elseif not is_allowed and is_talking then
		cancelEvent( )
		if source:DestroyFromTalkingList( ) then
			SortVoiceChat( )
		end

	end
end
addEventHandler( "onClientPlayerVoiceStart", root, onClientPlayerVoiceStart_handler, true, "high" )

function onClientPlayerVoiceStop_handler( )
	if source:DestroyFromTalkingList( ) then
		SortVoiceChat( )
	end
end
addEventHandler( "onClientPlayerVoiceStop", root, onClientPlayerVoiceStop_handler )
addEventHandler( "onClientPlayerQuit", root, onClientPlayerVoiceStop_handler )

function onClientElementDataChange_handler( key, old, new )
	-- Перенос строк в казино чуть выше
	if key == "in_casino" then
		--SETTING_Y_BOTTOM_OFFSET = new and SETTING_Y_BOTTOM_OFFSET_CASINO or SETTING_Y_BOTTOM_OFFSET_DEFAULT
		SortVoiceChat( )
	
	-- Не показывать игроков, находясь в самолёте КБ/большой комнате казино
	elseif key == "cr_big_room" then
		SetVoiceChatVisible( not new )
	elseif key == "photo_mode" then
		SetVoiceChatVisible( not new )
	end
end
addEventHandler( "onClientElementDataChange", localPlayer, onClientElementDataChange_handler )

function onSettingsChange_handler( changed, values )
	if changed.voice then
		if values.voice then
			SETTING_VOICE_MUL = values.voice
		end
	end
end
addEvent( "onSettingsChange" )
addEventHandler( "onSettingsChange", root, onSettingsChange_handler )

triggerEvent( "onSettingsUpdateRequest", localPlayer, "voice" )

function onClientEndPhoneCall_handler()
	source:DestroyFromTalkingList()
end
addEvent( "onClientEndPhoneCall", true )
addEventHandler( "onClientEndPhoneCall", root, onClientEndPhoneCall_handler )