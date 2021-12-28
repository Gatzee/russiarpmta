loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "CPlayer" )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShAsync" )

STREAMED_PLAYERS = { }
SEASON_WINNERS = {}
SOCIAL_RATING_CHANGED = { }

local MAX_DISTANCE = 70
local TIME_TEXT_SHOW = 10000

local fonts = {
	regular_10 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Regular.ttf", 11, false, "default"),
	bold_10 = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Bold.ttf", 11, false, "default"),
	bold_level = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Bold.ttf", 9, false, "default"),
}

local NAMETAGS_DISABLED = false

function CanSeeClanNametags( player )
	if localPlayer:IsAdmin() then return true end
	if localPlayer:IsInClan() then
		if not player:getData( "onshift" ) or player.weaponSlot ~= 0 then
			return true
		end
	end
end

addCommandHandler( "notags", function()
	NAMETAGS_DISABLED = not NAMETAGS_DISABLED
	outputChatBox( NAMETAGS_DISABLED and "Никнеймы над игроками отключены" or "Никнеймы над игроками включены", 255, 255, 0 )
end)

function onStreamIn_handler( player )
	local player = isElement( player ) and player or source
	if getElementType( player ) ~= "player" then return end
	if STREAMED_PLAYERS[ player ] then return end
	STREAMED_PLAYERS[ player ] = true
	addEventHandler( "onClientElementStreamOut", player, onStreamOut_handler )
	addEventHandler( "onClientPlayerQuit", player, onStreamOut_handler )
end
addEventHandler( "onClientElementStreamIn", root, onStreamIn_handler )

function onStreamIn_ResourceStartHandler()
	for i, v in pairs( getElementsByType( "player", root, true ) ) do
		onStreamIn_handler( v )
	end
end
addEventHandler( "onClientResourceStart", resourceRoot, onStreamIn_ResourceStartHandler)

function onStreamOut_handler()
	STREAMED_PLAYERS[ source ] = nil
	removeEventHandler( "onClientElementStreamOut", source, onStreamOut_handler )
	removeEventHandler( "onClientPlayerQuit", source, onStreamOut_handler )
end

local DRAWABLE_PLAYERS = { }
local TALKING_LIST = { }
function UpdateSuitablePlayers()
	local is_admin = localPlayer:IsAdmin()
	local position = Vector3( getCameraMatrix() )

	local my_dimension = localPlayer.dimension
	local my_interior = localPlayer.interior

	DRAWABLE_PLAYERS = { }

	local CanSeeClanNametags = CanSeeClanNametags
	local in_clan_event_lobby = localPlayer:getData( "in_clan_event_lobby" )
	local my_clan = localPlayer:GetClanTeam()

	Async:foreach( STREAMED_PLAYERS, function( _, player )
		setPlayerNametagShowing( player, false )
		if player == localPlayer then return end
		if player.dimension ~= my_dimension or player.interior ~= my_interior or not isElementOnScreen(player) or player.alpha < 200 then return end
		--if getElementData( player, "_aduty" ) then break end
		local vecBonePosition = Vector3( getPedBonePosition( player, 4 ) )
		vecBonePosition.z = vecBonePosition.z + 0.5
		local fDistance = (position - vecBonePosition).length
		if fDistance > MAX_DISTANCE or not isLineOfSightClear( position, vecBonePosition, true, false, false, true, false, false, true ) then return end
		local r, g, b = getPlayerNametagColor( player )

		local clan_text
		local clan = player:GetClanTeam()
		if clan and CanSeeClanNametags( player ) then
			-- local cr, cg, cb = clan:getColor()
			if in_clan_event_lobby and my_clan == clan then
				r, g, b = 135, 234, 154
			else
				r, g, b = 231, 63, 94
			end
			clan_text = "[ " .. clan:getName() .. " ]"
			-- if cr == r and cg == g and cb == b then
			-- 	r, g, b = 255, 255, 255
			-- end
		end
		
		local nickname = is_admin and table.concat( { getPlayerNametagText( player ) or getPlayerName(player) , " (", tostring( player:GetID() ), ")" }, '' ) or getPlayerNametagText( player ) or getPlayerName(player)
		table.insert( DRAWABLE_PLAYERS, 
			{ 
				player,
				nickname,
				r, g, b,
				getElementData( player, "chatbox_active" ),
				TALKING_LIST[ player ],
				getElementData( player, "bubble_list" ),
				player:GetLevel(),
				player:IsPremiumActive(),
				player:getData( "wanted_data" ),
				player:getData( "wanted_check" ),
				clan_text,
				player:getData( "nickname_color" ),
				player:getData( "social_rating" ),
				player:IsNickNameHidden( ),
			} 
		)
	end )
end
Timer( UpdateSuitablePlayers, 100, 0 )

function VoiceOnStart()
	local player = source
	if wasEventCancelled( ) or player:IsVoiceMuted() then return end
	if TALKING_LIST[ player ] then return end
	TALKING_LIST[ player ] = true
	addEventHandler( "onClientPlayerVoiceStop", player, VoiceOnStop )
end
addEventHandler( "onClientPlayerVoiceStart", root, VoiceOnStart, true, "low-100" )

function VoiceOnStop()
	local player = source
	TALKING_LIST[ player ] = nil
	removeEventHandler( "onClientPlayerVoiceStop", player, VoiceOnStop )
	removeEventHandler( "onClientElementStreamOut", player, VoiceOnStop )
	removeEventHandler( "onClientPlayerQuit", player, VoiceOnStop )
end

local icon_size = 24

local tocolor = tocolor
local Vector3 = Vector3
local getCameraMatrix = getCameraMatrix
local getScreenFromWorldPosition = getScreenFromWorldPosition
local pairs = pairs
local dxDrawText = dxDrawText
local dxDrawRectangle = dxDrawRectangle
local dxDrawImage = dxDrawImage

function HUDRender()
	local position = Vector3( getCameraMatrix() )
	local tick = getTickCount()

	local show_police_wanted_info = FACTION_RIGHTS.WANTED_KNOW[ localPlayer:GetFaction() ] and localPlayer:IsOnFactionDuty()
	for _, player_conf in pairs( DRAWABLE_PLAYERS ) do
		if isElement( player_conf[ 1 ] ) then
			local player, text, r, g, b, is_chatbox_active, is_voice_active, bubble_list, level, premium, wanted_data, wanted_check, clan_text, nickname_color_index, social_rating, hidden_nickname = unpack( player_conf )
			if not NAMETAGS_DISABLED and not hidden_nickname then
				while true do
					local vecBonePosition = player.position
					vecBonePosition.z = player:getBonePosition( 8 ).z + 0.3

					local fDistance = (position - vecBonePosition).length
					
					local screen_x, screen_y = getScreenFromWorldPosition( vecBonePosition )
					if not screen_x or not screen_y then break end

					local alpha	= Lerp( 255, 0, fDistance / MAX_DISTANCE )

					local color_3 = tocolor( 0, 0, 0, alpha )
					
					local color_1	= tocolor( r, g, b, alpha )
					local color_white	= tocolor( 255, 255, 255, alpha )

					local color_name = color_white
					if nickname_color_index and PLAYER_NAMETAG_COLORS[ nickname_color_index ] then
						local r, g, b = fromColor( PLAYER_NAMETAG_COLORS[ nickname_color_index ] )
						color_name = tocolor( r, g, b, alpha )
					end

					local xp1 = screen_x + 1
					local yp1 = screen_y + 1
					local xm1 = screen_x - 1
					local ym1 = screen_y - 1
					dxDrawText( text, xp1, yp1, xp1, yp1, color_3, 1.0, fonts.bold_10, 'center', 'center' )
					dxDrawText( text, xm1, ym1, xm1, ym1, color_3, 1.0, fonts.bold_10, 'center', 'center' )
					dxDrawText( text, xp1, ym1, xp1, ym1, color_3, 1.0, fonts.bold_10, 'center', 'center' )
					dxDrawText( text, xm1, yp1, xm1, yp1, color_3, 1.0, fonts.bold_10, 'center', 'center' )

					dxDrawText( text, screen_x, screen_y, screen_x, screen_y, color_name, 1.0, fonts.bold_10, 'center', 'center' )
					
					if social_rating then
						local rating_bias_y = ( clan_text and 55 or 30 )
						dxDrawImage( screen_x - 30, screen_y - rating_bias_y, 42, 14, "images/" .. ( social_rating >= 0 and "good" or "bad" ) .. ".png", 0, 0, 0, color_white )
						dxDrawText( social_rating, screen_x+28, screen_y - rating_bias_y, screen_x+28, screen_y - rating_bias_y + 14, color_white, 1, fonts.bold_10, 'center', 'center' )

						local rating_delta = SOCIAL_RATING_CHANGED[ player ]

						if rating_delta then
							if tick - rating_delta.tick <= 5000 then
								local color_rating_green = tocolor( 141, 255, 111, alpha )
								local color_rating_red = tocolor( 231, 63, 94, alpha )

								local fWidth = dxGetTextWidth( rating_delta.delta, 1, fonts.regular_10 )
								dxDrawImage( screen_x + 50 + fWidth, screen_y - rating_bias_y + 1, 13, 9, "images/rating_" .. ( rating_delta.delta >= 0 and "up" or "down" ) ..".png", 0, 0, 0, color_white  )
								dxDrawText( rating_delta.delta, screen_x + 46, screen_y - rating_bias_y, screen_x, screen_y - rating_bias_y + 14, rating_delta.delta >= 0 and color_rating_green or color_rating_red, 1, fonts.regular_10, 'left', 'center' )
							else
								SOCIAL_RATING_CHANGED[ player ] = nil
							end
						end
					end

					if show_police_wanted_info and not player:getData( "jailed" ) then
						local offset = -30 *  ( 0.5 + alpha / 255 / 2 )

						if wanted_data and #wanted_data > 0 then
							local text = "Преступник\n(требуется задержание)"

							dxDrawText( text, xp1, yp1 + offset, xp1, yp1 + offset, color_3, 1.0, fonts.bold_10, 'center', 'center' )
							dxDrawText( text, xm1, ym1 + offset, xm1, ym1 + offset, color_3, 1.0, fonts.bold_10, 'center', 'center' )
							dxDrawText( text, xp1, ym1 + offset, xp1, ym1 + offset, color_3, 1.0, fonts.bold_10, 'center', 'center' )
							dxDrawText( text, xm1, yp1 + offset, xm1, yp1 + offset, color_3, 1.0, fonts.bold_10, 'center', 'center' )

							dxDrawText( text, screen_x, screen_y + offset, screen_x, screen_y + offset, color_white, 1.0, fonts.bold_10, 'center', 'center' )
						
						elseif wanted_check then
							local text = "Возможный преступник\n(требуется проверка документов)"

							dxDrawText( text, xp1, yp1 + offset, xp1, yp1 + offset, color_3, 1.0, fonts.bold_10, 'center', 'center' )
							dxDrawText( text, xm1, ym1 + offset, xm1, ym1 + offset, color_3, 1.0, fonts.bold_10, 'center', 'center' )
							dxDrawText( text, xp1, ym1 + offset, xp1, ym1 + offset, color_3, 1.0, fonts.bold_10, 'center', 'center' )
							dxDrawText( text, xm1, yp1 + offset, xm1, yp1 + offset, color_3, 1.0, fonts.bold_10, 'center', 'center' )

							dxDrawText( text, screen_x, screen_y + offset, screen_x, screen_y + offset, color_white, 1.0, fonts.bold_10, 'center', 'center' )
						end
					elseif clan_text then
						local offset = -25 *  ( 0.5 + alpha / 255 / 2 )
						
						dxDrawText( clan_text, xp1, yp1 + offset, xp1, yp1 + offset, color_3, 1.0, fonts.bold_10, 'center', 'center' )
						dxDrawText( clan_text, xm1, ym1 + offset, xm1, ym1 + offset, color_3, 1.0, fonts.bold_10, 'center', 'center' )
						dxDrawText( clan_text, xp1, ym1 + offset, xp1, ym1 + offset, color_3, 1.0, fonts.bold_10, 'center', 'center' )
						dxDrawText( clan_text, xm1, yp1 + offset, xm1, yp1 + offset, color_3, 1.0, fonts.bold_10, 'center', 'center' )

						dxDrawText( clan_text, screen_x, screen_y + offset, screen_x, screen_y + offset, color_1, 1.0, fonts.bold_10, 'center', 'center' )
					end

					local text_width_half = dxGetTextWidth( text, 1, fonts.bold_10 ) / 2

					local icon_px = screen_x - text_width_half - icon_size - 7
					local icon_py = screen_y - icon_size / 2
					local icon = false

					if is_voice_active then
						icon = "images/voice.png"
					elseif is_chatbox_active then
						icon = "images/chat.png"
					end

					if icon then
						dxDrawImage( icon_px, icon_py, icon_size, icon_size, icon, 0, 0, 0, color_white )
					end

					local icon_px = math.floor( screen_x + text_width_half + 7 )
					local icon_py = math.floor( screen_y - icon_size / 2 )
					local circle_icon = premium and "images/circle_premium.png" or "images/circle.png"
					dxDrawImage( icon_px, icon_py, icon_size, icon_size, circle_icon, 0, 0, 0, color_1 )
					if premium then
						dxDrawImage( icon_px, icon_py - 17, 24, 17, "images/corona.png", 0, 0, 0, color_white )
					end

					local user_id = player:GetID()
					if SEASON_WINNERS[ user_id ] then
						dxDrawImage( math.floor( screen_x - (text_width_half + 35) ), icon_py, 25, 25, ":nrp_races/files/img/hud/place_" .. SEASON_WINNERS[ user_id ] .. ".png" )
					end
					--local icon_py = icon_py + 1

					local xp1 = icon_px + 1
					local yp1 = icon_py + 1
					local xm1 = icon_px - 1
					local ym1 = icon_py - 1
					dxDrawText( level, xp1, yp1, xp1 + icon_size, yp1 + icon_size, color_3, 1.0, fonts.bold_level, 'center', 'center' )
					dxDrawText( level, xm1, ym1, xm1 + icon_size, ym1 + icon_size, color_3, 1.0, fonts.bold_level, 'center', 'center' )
					dxDrawText( level, xp1, ym1, xp1 + icon_size, ym1 + icon_size, color_3, 1.0, fonts.bold_level, 'center', 'center' )
					dxDrawText( level, xm1, yp1, xm1 + icon_size, yp1 + icon_size, color_3, 1.0, fonts.bold_level, 'center', 'center' )
					dxDrawText( level, icon_px, icon_py, icon_px + icon_size, icon_py + icon_size, color_white, 1.0, fonts.bold_level, 'center', 'center' )

					if not bubble_list then break end
					if fDistance > 8.0 then break end

					vecBonePosition.z = vecBonePosition.z + 0.07
					local screen_x, screen_y = getScreenFromWorldPosition( vecBonePosition.x, vecBonePosition.y, vecBonePosition.z )
					if not screen_x or not screen_y then break end

					for iIndex = #bubble_list, 1, -1 do
						local bubble = bubble_list[iIndex]

						if bubble.time_end < tick then
							table.remove(bubble_list, iIndex)
							setElementData(player, "bubble_list", bubble_list, false)
						else
							local screen_y = screen_y - ( 24 * iIndex )
							local alphaP = ( bubble.time_end - tick ) / TIME_TEXT_SHOW

							local color_a = bubble.color.A
							local background_color_a = bubble.background_color.A
							if alphaP <= 0.5 then
								color_a = color_a *  2 * alphaP
								background_color_a = background_color_a * 2 * alphaP
							end
							
							local iColor			= tocolor( bubble.color.R, bubble.color.G, bubble.color.B, color_a )
							local iBackgroundColor	= tocolor( bubble.background_color.R, bubble.background_color.G, bubble.background_color.B, background_color_a )
							
							do
								local fWidth = dxGetTextWidth( bubble.text, 1.0, "default-bold" ) + 50.0
								local screen_x	= screen_x - ( fWidth * 0.5 )
								local screen_y	= screen_y - 2
								dxDrawRectangle( screen_x, screen_y, fWidth, 18, iBackgroundColor )
							end
							
							dxDrawText( bubble.text, screen_x, screen_y, screen_x, screen_y, iColor, 1.0, 'default-bold', 'center', 'top' )
						end
					end
					break
				end
			end
		end
	end
end
addEventHandler("onClientHUDRender", root, HUDRender)

function NametagUpdateState()
	--[[if m_bChatBoxActive then
		if not isChatBoxInputActive() then
			setElementData( localPlayer, 'chatbox_active', false )
			m_bChatBoxActive = false
		end
	else
		if isChatBoxInputActive() then
			setElementData( localPlayer, 'chatbox_active', true )
			m_bChatBoxActive = true
		end
	end]]
	
	--[[if m_bConsoleActive then
		if not isConsoleActive() then
			setElementData( localPlayer, 'console_active', false )
			m_bConsoleActive = false
		end
	else
		if isConsoleActive() then
			setElementData( localPlayer, 'console_active', true )
			m_bConsoleActive = true
		end
	end]]
end
Timer( NametagUpdateState, 1000, 0 )

addEvent("onChat", true)
addEventHandler( "onChat", root,
	function ( sMessage, iType, fDistance )
		local iColor, iBackgroundColor
		
		if iType == 0 then
			iColor				= { R = 255, G = 255, B = 255, A = 200 }
			iBackgroundColor	= { R = 0,   G = 0,   B = 0,   A = 200 }
		elseif iType == 1 then
			iColor				= { R = 255, G = 0, B = 128, A = 200 }
			iBackgroundColor	= { R = 0,   G = 0,   B = 0,   A = 200 }
		else
			return
		end

		local bubble_list = getElementData(source, "bubble_list") or {}
		table.insert(bubble_list, {
			text = utf8.sub( sMessage, 1, 100 ) .. (utf8.len( sMessage ) > 100 and  "..." or ""),
			time_end = getTickCount() + TIME_TEXT_SHOW,
			color = iColor,
			background_color = iBackgroundColor,
		})
		setElementData(source, "bubble_list", bubble_list, false)
	end
)

function OnClientRefreshWinnersData_handler( season_winners )
	table.sort( season_winners, function( a, b )
		return a.place < b.place
	end )

	for k, v in pairs( season_winners ) do
		-- На случай если игрок занял 1 и 3 место, отображаем максимальное
		if not SEASON_WINNERS[ v.user_id ] then
			SEASON_WINNERS[ v.user_id ] = v.place
		end
	end
end
addEvent( "OnClientRefreshWinnersData", true )
addEventHandler( "OnClientRefreshWinnersData", root, OnClientRefreshWinnersData_handler )

function onClientElementDataChange_handler( key, old, new )
	if key ~= "social_rating" then return end
	if not STREAMED_PLAYERS[ source ] then return end
	if not old then return end

	local delta = new - old

	if SOCIAL_RATING_CHANGED[ source ] then
		SOCIAL_RATING_CHANGED[ source ].delta = SOCIAL_RATING_CHANGED[ source ].delta + delta
	else
		SOCIAL_RATING_CHANGED[ source ] = { delta = delta, tick = getTickCount() }
	end
end
addEventHandler( "onClientElementDataChange", root, onClientElementDataChange_handler )