loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CQuest")

addEventHandler("onClientResourceStart", resourceRoot, function()
	CQuest(QUEST_DATA)
end)

function Client_CancelPlayerInVehicleDamage()
	local all_damage = localPlayer:getData( "all_damage" )
	if not all_damage then return end

	if all_damage < CONST_DAMAGE_ARMOR then
		cancelEvent()
	end
end

function Client_CancelPedInVehicleDamage()
	local ped = localPlayer:getData( "ambassador_quest_ped" )
	if source ~= ped then return end

	local vehicle = localPlayer:getData( "quest_vehicle" )
	if not vehicle then return end

	local all_damage = localPlayer:getData( "all_damage" )
	if not all_damage then return end

	if all_damage < CONST_DAMAGE_ARMOR then
		cancelEvent()
	end
end

function CheckPlayerQuestVehicle()
	if not isElement( localPlayer.vehicle ) or localPlayer.vehicle ~= localPlayer:getData( "quest_vehicle" ) then
		localPlayer:ShowError( "Ты не в джипе" )
		return false
	end

	if localPlayer.vehicleSeat ~= 0 then
		localPlayer:ShowError( "Ты не водитель" )
		return false
	end

	return true
end