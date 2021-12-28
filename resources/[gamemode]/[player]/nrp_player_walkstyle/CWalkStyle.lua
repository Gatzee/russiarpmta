loadstring(exports.interfacer:extend("Interfacer"))()
Extend("Globals")
Extend( "ShSkin" )

local DEFAULT_WALK_STYLE = 118

local WALK_STYLES = {
    -- Женские скины
    [ 139 ] = 132,
    [ 141 ] = 132,
    [ 145 ] = 132,
}

for model, gender in pairs( SKINS_GENDERS ) do
	if not WALK_STYLES[ model ] then
		WALK_STYLES[ model ] = ( gender == 1 and 132 or DEFAULT_WALK_STYLE )
	end
end

function parseWalkStyles( )
    for _, player in pairs( getElementsByType( "player", root, true ) ) do
        local required_style = player:getData( "walkstyle" ) or WALK_STYLES[ player.model ] or DEFAULT_WALK_STYLE
        local current_style = player.walkingStyle
        if current_style ~= required_style then
            player.walkingStyle = required_style
        end
    end
end
setTimer( parseWalkStyles, 2500, 0 )