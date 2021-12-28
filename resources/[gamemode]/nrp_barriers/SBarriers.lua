loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend("SPlayer")
Extend("SInterior")

function CheckAccess( self, player )
    if self.faction then
        local forbidden = false
        if type( self.faction ) == "table" then
            if not self.faction[ player:GetFaction() ] then
                forbidden = true
            end
        else
            if player:GetFaction() ~= self.faction then
                forbidden = true
            elseif player:getData( "jailed" ) then
                forbidden = true
            end
        end
        if forbidden then
            local text = self.resource_config and self.resource_config.no_keys_message or "У тебя нет ключ-карты"
            return false, text
        end
    end
    return true
end

BARRIERS = 
{   -- ППС НСК
    { model = 1264, x = -327.2374, y = -827.8628, z = 20.5996, rx = 0, ry = 0, rz = 0, mrx = 0, mry = 70, mrz = 0, duration = 2000, radius = 2, dimension, interior = 0, 
    faction = 
    {
        [ F_POLICE_PPS_NSK ] = true,
        [ F_FSIN ] = true,
    }, },
    --ДПС НСК
    { model = 1264, x = 341.21936, y = -1226.276, z = 20.5395, rx = 0, ry = 0, rz = 0, mrx = 0, mry = 70, mrz = 0, duration = 2000, radius = 2, dimension, interior = 0, faction = 
    {
        [ F_POLICE_DPS_NSK ] = true,
    }, },
    -- ДПС Горки
    { model = 1264, x = 2193.9468, y = 205.16748, z = 60.4910, rx = 0, ry = 0, rz = -49, mrx = 0, mry = 70, mrz = 0, duration = 2000, radius = 2, dimension, interior = 0, faction = 
    {
        [ F_POLICE_DPS_GORKI ] = true,
    }, },
    -- ППС Горки
    { model = 1264, x = 1911.5824, y = 147.15086, z = 60.4396, rx = 0, ry = 0, rz = -55.5, mrx = 0, mry = 70, mrz = 0, duration = 2000, radius = 2, dimension, interior = 0, faction = 
    {
        [ F_POLICE_PPS_GORKI ] = true,
        [ F_FSIN ] = true,
    }, },
}

function onResourceStart_handler( resource )
    for i, v in pairs( BARRIERS ) do
        local config = {
            id = i .. "_barrier",
            open_text = "ALT Взаимодействие",
            close_text = "ALT Взаимодействие",
            model = v.model,
            x = v.x, y = v.y, z = v.z,
            rx = v.rx, ry = v.ry, rz = v.rz,
            move = {
                rx = v.mrx,
                ry = v.mry,
                rz = v.mrz,
            },
            faction = v.faction,
            CheckAccess = CheckAccess,
            duration = v.duration,
            dimension = v.dimension,
            interior = v.interior,
            radius = v.radius,
        }
        local door = DoorInteractive( config )
        door.PostJoin = function( self, player )
            if self.CheckAccess then
                local result, err = self:CheckAccess( player )
                if not result then return result, err end
            end
            self.door:Toggle( )
            self.OnLeave ( player )
            self.OnHit( player, true )
            self.door.object:setCollisionsEnabled( not self.state )
        end

        door.CheckAccess = function( self, player )
            local player_faction = player:GetFaction()
            return self.faction[ player_faction ]
        end
        
    end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )