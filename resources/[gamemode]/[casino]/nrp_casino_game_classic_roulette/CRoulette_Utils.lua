
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
	['tab'] = true,
	['q'] = true,
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
	local sound = playSound( "sfx/chip_sound.mp3" )
    sound.volume = 0.5
end

function OnClientKey_handler( key, state )
	if locked_keys[ key ] then 
		cancelEvent()
		return
	end
	
	if key == "space" then
		if isElement( UI_elements.black_bg_result ) then
			UI_elements.info_access:ibData( "alpha", 255 )
			destroyElement( UI_elements.black_bg_result )
		end
	end
end