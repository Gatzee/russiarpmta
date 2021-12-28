local nrp_transfer = getResourceFromName( "nrp_transfer" )
if nrp_transfer and nrp_transfer.state == "running" then
	exports.nrp_transfer:AddTransferDataHandler( )
end

addEventHandler( "onResourceStart", root, function( resource )
	if resource.name == "nrp_transfer" then
		exports.nrp_transfer:AddTransferDataHandler( )
	end
end )

function GetTransferData( player )
    return
end

addEvent( "onTransferPrepareData" )
addEventHandler( "onTransferPrepareData", root, function( )
    local player = source

    player:GetMedbook( function( medbook )
        if not isElement( player ) then return end
        triggerEvent( "onTransferPrepareData_callback", player, {
            transfer_medbook = medbook,
        } )
    end )
end )

addEvent( "onTransferFinish", false )
addEventHandler( "onTransferFinish", root, function ( user_id, client_id, transfered_data )
    local medbook = transfered_data.transfer_medbook
    if medbook and next( medbook ) then
        UpdateMedbookData( user_id, medbook )
    end
end )