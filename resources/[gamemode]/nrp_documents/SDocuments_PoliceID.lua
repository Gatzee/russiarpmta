function OnPoliceIDShowRequest_Request( target )
    if not isPlayerCanLookAtDocuments( target ) then return end

    if not source:GetPermanentData( "military_date" ) then
        source:SetPermanentData( "military_date", getRealTime().timestamp )
    end

    local info = {
        name = source:GetNickName(),
        faction = source:GetFaction(),
        faction_rank = source:GetFactionLevel(),
    }
    target:triggerEvent( "ShowUI_PoliceID", source, true, info )

    triggerEvent( "OnPlayerShownPoliceID", source, target )
end
addEvent( "OnPoliceIDShowRequest", true )
addEventHandler( "OnPoliceIDShowRequest", root, OnPoliceIDShowRequest_Request )