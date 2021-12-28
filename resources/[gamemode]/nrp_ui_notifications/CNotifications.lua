loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )

ibUseRealFonts( true )

local SOUNDS = {
	[ 1 ] = "sfx/info.ogg",
	[ 2 ] = "sfx/error.ogg",
	[ 3 ] = "sfx/success.ogg",
}
local MAX_MESSAGES = 4
local MESSAGE_TIMEOUT = 5 -- seconds
local messages = { }

function updatePositionsOfMessages( )
	for index, message in pairs( messages ) do
		local newY = _SCREEN_Y - index * 100
		message.element:ibMoveTo( nil, newY, 200 )
	end
end

function removeMessage( index )
	if not index then index = #messages end -- if not index, then remove last message

	local element = messages[ index ].element
	local fadeOutDuration = 500

	element:ibAlphaTo( 0, fadeOutDuration )
	element:ibTimer( function( self )
		destroyElement( self )
	end, fadeOutDuration, 1 )

	table.remove( messages, index )

	if #messages == 0 then
		triggerEvent( "onHintsAlphaRequest", localPlayer, 255 )
	else
		updatePositionsOfMessages( )
	end
end

function CreateNotification( text, type )
	for index, message in pairs( messages ) do
		if message.type == type and message.text == text then
			removeMessage( index )
			break
		end
	end

	if #messages >= MAX_MESSAGES then removeMessage( ) end

	local bg = ibCreateArea( 0, _SCREEN_Y - 100, 398, 80 )
	:center_x( ):ibData( "alpha", 0 ):ibAlphaTo( 255, 500 ):ibDeepSet( "disabled", true )
	:ibTimer( function ( self )
		if messages[ #messages ].element == self then removeMessage( )
		else self:destroy( ) end
	end, MESSAGE_TIMEOUT * 1000, 1 )

	local bg_img = ibCreateImage( 0, 0, 398, 80, "img/" .. type .. ".png", bg )
	ibCreateLabel( 0, 0, 300, 0, text, bg_img, nil, nil, nil, "center", "center", ibFonts.bold_14 )
	:ibData( "wordbreak", true ):center( 0, 3 ):ibData( "outline", 1 )

	if not isElement( CURRENT_SOUND ) or SOUND_TYPE ~= type then
		SOUND_TYPE = type
		CURRENT_SOUND = playSound( SOUNDS[ type ] )
		setSoundVolume( CURRENT_SOUND, 0.35 )
	end

	table.insert( messages, 1, { element = bg, text = text, type = type } )
	updatePositionsOfMessages( )
	triggerEvent( "onHintsAlphaRequest", localPlayer, 0 )
end

function ShowInfo_handler( text )
	CreateNotification( text, 1 )
end
addEvent( "ShowInfo", true )
addEventHandler( "ShowInfo", root, ShowInfo_handler )

function ShowError_handler( text )
	CreateNotification( text, 2 )
end
addEvent( "ShowError", true )
addEventHandler( "ShowError", root, ShowError_handler )
addEvent( "ShowWarning", true )
addEventHandler( "ShowWarning", root, ShowError_handler )

function ShowSuccess_handler( text )
	CreateNotification( text, 3 )
end
addEvent( "ShowSuccess", true )
addEventHandler( "ShowSuccess", root, ShowSuccess_handler )

function CloseInfo_handler( )
	for _, message in pairs( messages ) do
		message.element:destroy( )
	end

	messages = { }
	triggerEvent( "onHintsAlphaRequest", localPlayer, 255 )
end
addEvent( "CloseInfo", true )
addEventHandler( "CloseInfo", root, CloseInfo_handler )