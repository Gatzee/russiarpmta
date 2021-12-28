Player.IsHobbyEquipmentUnlocked = function( self, hobby, class, id )
    local pUnlocks = self:GetHobbyUnlocks( hobby )

    if pUnlocks[class] and pUnlocks[class] >= id then
        return true
    end

    local iHobbyLevel = self:GetHobbyLevel( hobby )
    local iGameLevel = self:GetLevel()

    local pItems
    for k,v in pairs(HOBBY_EQUIPMENT[hobby]) do
        if v.class == class then
            pItems = v.items
            break
        end
    end

    if pItems[id].level and pItems[id].level <= iHobbyLevel then
        return true
    end

    if pItems[id].player_level and pItems[id].player_level <= iGameLevel then
        return true
    end
end