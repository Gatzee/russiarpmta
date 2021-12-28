Extend( "ShUtils" )
Extend( "SVehicle" )
Extend( "SPlayer" )

function OnRadialMenuActionApply( iAction, pPlayer, pTarget, pArgs )
	local pAction = RADIAL_ACTIONS[iAction]
	pAction.fServerApply( pPlayer, pTarget, pArgs )
end
addEvent("OnRadialMenuActionApply", true)
addEventHandler("OnRadialMenuActionApply", root, OnRadialMenuActionApply)