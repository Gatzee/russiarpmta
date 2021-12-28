local blocked_controls = 
{
	"forwards",
	"backwards",
	"right",
	"left",
	"jump",
	"fire",
	"crouch",
}

local locked_keys = 
{
	[ "tab" ] = true,
	[ "q" ]   = true,
}

function DisableControls()
    for k,v in pairs( blocked_controls ) do
		toggleControl( v, false )
	end

    addEventHandler( "onClientKey", root, OnClientKey_handler )
end

function EnableControls()
    for k,v in pairs( blocked_controls ) do
		toggleControl( v, true )
    end
    
    removeEventHandler( "onClientKey", root, OnClientKey_handler )
end

function soundChip()
	local sound = playSound( "sfx/chip_sound.ogg" )
    sound.volume = 0.5
end

function soundCard()
	local sound = playSound( "sfx/card_sound.mp3" )
    sound.volume = 0.5
end

function OnClientKey_handler( key, state )
	if locked_keys[ key ] then 
		cancelEvent()
		return
	end
	
	if key == "space" and isElement( UI_elements.black_bg_result ) then
		destroyElement( UI_elements.black_bg_result )
	end
end