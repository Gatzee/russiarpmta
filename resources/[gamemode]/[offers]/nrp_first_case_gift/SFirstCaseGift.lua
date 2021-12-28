loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

GIFT_CASES = {
	[ "gold_a" ] = true,
	[ "gold_b" ] = true,
}

function onCasesTakeItem_handler( case_id )
	if not GIFT_CASES[ case_id ] then return end

	triggerClientEvent( source, "ShowFirstCaseSkinInfo", resourceRoot )
end
addEvent( "onCasesTakeItem", true )
addEventHandler( "onCasesTakeItem", root, onCasesTakeItem_handler )