loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "ShFood" )

local PLAYER_PUKE = { }

Player.Puke = function( self, is_fast_food )
    if not PLAYER_PUKE[ self ] or getTickCount( ) - PLAYER_PUKE[ self ] >= 10 * 60 * 1000 then
        PLAYER_PUKE[ self ] = getTickCount( )
        return false
    else
        PLAYER_PUKE[ self ] = nil
        local players = getElementsWithinRange( self.position, 50, "player" )
        local dimension = self.dimension
        for i, v in pairs( players ) do
            if v.dimension ~= dimension then
                players[ i ] = nil
            end
        end

        if not isPedInVehicle( self ) then
            triggerClientEvent( players, "OnPlayerPuke", self, is_fast_food )
        end

        triggerEvent( "onPlayerSomeDo", self, "puke" ) -- achievements

        self:SetCalories( 85 )
        if self.health > 10 then
            self:SetHP( math.max( 10, self.health - 10 ) )
        end
    end
    return true
end

function onCaloriesUpdate_handler( delta_value )
    local value = math.max( 0, client:GetCalories( ) - delta_value )
    client:SetPermanentData( "calories", value )
    client:setData( "calories", value, false )
end
addEvent( "onCaloriesUpdate", true )
addEventHandler( "onCaloriesUpdate", root, onCaloriesUpdate_handler )

function onPlayerEatFood_handler( food_id )
    local food = FOOD_DISHES[ food_id ]
    local new_calories = source:GetCalories() + ( food and food.calories or 50 )

    if new_calories < 100 or not source:Puke( ) then
        source:SetCalories( new_calories )
        if food and food.buffs then
            ApplyFoodBuffs( source, food_id )
        end
    end

    source:ShowSuccess( "Вы употребили " .. ( food and food.name or "ланч" ) )
end
addEvent( "onPlayerEatFood", true )
addEventHandler( "onPlayerEatFood", root, onPlayerEatFood_handler )

function onPlayerPreLogout_handler( )
    PLAYER_PUKE[ source ] = nil
end
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_handler )