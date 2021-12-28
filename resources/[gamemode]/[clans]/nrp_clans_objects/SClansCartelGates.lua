loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SInterior" )

function onResourceStart_handler( resource )
    for i, v in pairs( GATES ) do
        local config = {
            id = i .. "_barrier",
            open_text = "ALT Взаимодействие",
            close_text = "ALT Взаимодействие",
            model = v.model,
            x = v.x, y = v.y, z = v.z,
            rx = v.rx, ry = v.ry, rz = v.rz,
            move = {
                x = v.mx,
                y = v.my,
                z = v.mz,
            },
            cartel_id = v.cartel_id,
            CheckAccess = CheckAccess,
            duration = v.duration,
            dimension = v.dimension,
            interior = v.interior,
            radius = v.radius,
        }

        local door = DoorInteractive( config )
        door.object.scale = v.scale
        door.object.dimension = 0

        door.PostJoin = function( self, player )
            if self.CheckAccess then
                local result, err = self:CheckAccess( player )
                if not result then return result, err end
            end
            self.door:Toggle( )
            self.OnLeave( player )
            self.OnHit( player, true )
            self.door.object:setCollisionsEnabled( not self.state )
        end

        door.CheckAccess = function( self, player )
            return player:GetClanCartelID( ) == door.cartel_id
        end
    end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )