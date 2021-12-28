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
    local saved = { }

    if player:IsInFaction( ) then
        table.insert( saved, { text = "Опыт во фракции " .. FACTIONS_NAMES[ player:GetFaction( ) ] } )
    end

    return currency, logdata, info, saved
end

addEvent( "onTransferPrepareData" )
addEventHandler( "onTransferPrepareData", root, function( )
    local player = source
    if not player:IsInFaction( ) then
        triggerEvent( "onTransferPrepareData_callback", player )
        return
    end

    local total_exp = player:GetFactionExp( )
    for lvl = 1, player:GetFactionLevel( ) - 1 do
        total_exp = total_exp + FACTION_EXPERIENCE[ lvl ]
    end

	triggerEvent( "onTransferPrepareData_callback", player, nil, {
        transfer_faction = {
            id = player:GetFaction( ),
            exp = total_exp,
        },
    } )
end )

addEvent( "onPlayerFactionChange", false )
addEventHandler( "onPlayerFactionChange", root, function ( old_faction_id, faction_id )
    local player = source
    local transfer_faction = player:GetPermanentData( "transfer_faction" )
	if transfer_faction and faction_id == transfer_faction.id then
        player:GiveFactionExp( transfer_faction.exp )
        player:SetPermanentData( "transfer_faction", nil )
    end
end )