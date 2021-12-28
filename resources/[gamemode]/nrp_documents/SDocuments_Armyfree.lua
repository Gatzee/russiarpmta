function OnArmyfreeShowRequest_Request( target )
    if not isPlayerCanLookAtDocuments( target ) then return end
    
    local date = source:GetPermanentData( "urgent_military_vacation" )
    if not date or date <= getRealTimestamp() then return end
    local info = {
        name = source:GetNickName(),
        date = date,
    }
    target:triggerEvent( "ShowArmyfreeUI", source, true, info )
end
addEvent( "OnArmyfreeShowRequest", true )
addEventHandler( "OnArmyfreeShowRequest", root, OnArmyfreeShowRequest_Request )