function OnMilitaryShowRequest_Request( target )
    if not isPlayerCanLookAtDocuments( target ) then return end

    if not source:GetPermanentData("military_date") then
        source:SetPermanentData("military_date", getRealTime().timestamp)
    end

    local info = {
        name = source:GetNickName( ),
        skin = source:GetPermanentData( "skins" ),
        userid = source:GetUserID( ),
        faction = source:GetFaction( ),
        on_duty = source:IsOnFactionDuty( ),
        faction_rank = source:IsInFaction( ) and source:GetFactionLevel( ) or source:GetMilitaryLevel( ),
		faction_date = source:GetPermanentData("military_date"),
		faction_name = source:getData( "faction_name" ),
    }

    target:triggerEvent( "ShowMilitaryUI", source, true, info )
end
addEvent( "OnMilitaryShowRequest", true )
addEventHandler( "OnMilitaryShowRequest", root, OnMilitaryShowRequest_Request )