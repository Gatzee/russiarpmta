loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

function onPlayerUseTeleportPoint_handler( old_position, old_interior, old_dimension )
    if old_interior == 0 and old_dimension == 0 then
        local new_interior = source.interior
        local new_dimension = source.dimension
        if ( new_interior ~= old_interior or new_dimension ~= old_dimension ) then
            local interior_tpoint_position = {
                old_position = old_position,
                new_interior = new_interior,
                new_dimension = new_dimension,
            }
            source:SetPermanentData( "interior_tpoint_position", interior_tpoint_position )
        end
    elseif source:GetPermanentData( "interior_tpoint_position" ) then
        source:SetPermanentData( "interior_tpoint_position", nil )
    end
end
addEvent( "onPlayerUseTeleportPoint", true )
addEventHandler( "onPlayerUseTeleportPoint", root, onPlayerUseTeleportPoint_handler )

function onPlayerSpawn_handler( )
    local interior_tpoint_position = source:GetPermanentData( "interior_tpoint_position" )
    if not interior_tpoint_position then return end

    if source.interior ~= interior_tpoint_position.new_interior or source.dimension ~= interior_tpoint_position.new_dimension then
        source:SetPermanentData( "interior_tpoint_position", nil )
    end
end
addEvent( "onPlayerSpawn", true )
addEventHandler( "onPlayerSpawn", root, onPlayerSpawn_handler )