Player.GiveHobbyExp = function( self, hobby, exp )
    local iCurrent = self:GetHobbyExp( hobby )
    return self:SetHobbyExp( hobby, iCurrent + exp )
end

Player.TakeHobbyExp = function( self, hobby, exp )
    local iCurrent = self:GetHobbyExp( hobby )
    return self:SetHobbyExp( hobby, iCurrent - exp )
end

Player.SetHobbyExp = function( self, hobby, exp )
    local iNewExp = math.max( exp, 0 )
    local iCurrentLevel = self:GetHobbyLevel( hobby )
    local iNewLevel = iCurrentLevel

    for i = iCurrentLevel+1, #HOBBY_LEVELS[hobby] do
        local pLevelData = HOBBY_LEVELS[hobby][i]
        if pLevelData.exp <= iNewExp then
            iNewExp = iNewExp - pLevelData.exp
            iNewLevel = i
        end
    end

    if iCurrentLevel ~= iNewLevel then
        self:SetHobbyLevel( hobby, iNewLevel )
    end

    local pHobbiesData = self:GetHobbiesData()
    if not pHobbiesData[hobby] then pHobbiesData[hobby] = {} end

    pHobbiesData[hobby].exp = iNewExp

    self:SetPrivateData( "hobby_data", pHobbiesData )
    return self:SetPermanentData( "hobby_data", pHobbiesData )
end