
function OnPassportShowRequest_Request( target )
    if not isPlayerCanLookAtDocuments( target ) then return end

    local info = {
        name = source:GetNickName(),
        skin = source:GetPermanentData( "skin" ),
        start_city = source:GetStartCity(),
        birthday = source:GetPermanentData( "birthday" ),
        gender = source:GetPermanentData( "gender" ),
        reg_date = source:GetPermanentData( "reg_date" ),
        military = source:GetMilitaryLevel(),
    }
    target:triggerEvent( "ShowPassportUI", source, true, info )
    
    local target_players = {}
	for k, v in pairs( getElementsWithinRange( source.position, 150, "player" ) ) do
		if v:IsInGame() and FACTION_RIGHTS.WANTED_KNOW[ v:GetFaction() ] and v:IsOnFactionDuty() then
			table.insert( target_players, v )
		end
	end
	triggerClientEvent( target_players, "OnPlayerReceiveWantedData", source, source:GetWantedData( true ) )
end
addEvent( "OnPassportShowRequest", true )
addEventHandler( "OnPassportShowRequest", root, OnPassportShowRequest_Request )