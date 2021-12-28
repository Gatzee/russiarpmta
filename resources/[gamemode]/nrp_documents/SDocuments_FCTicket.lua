function OnFCTicketShowRequest_Request( target )
    if not isPlayerCanLookAtDocuments( target ) then return end
    if not source:HasFCMembership() then return end

    local info = {
        name = source:GetNickName(),
        time_left = source:GetPermanentData("fc_membership") - getRealTime().timestamp,
    }
    target:triggerEvent( "ShowFCTicketUI", source, true, info )
end
addEvent( "OnFCTicketShowRequest", true )
addEventHandler( "OnFCTicketShowRequest", root, OnFCTicketShowRequest_Request )