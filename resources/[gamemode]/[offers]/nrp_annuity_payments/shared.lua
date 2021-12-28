loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )

enum "eDaysState" {
	"DAY_MISSED",
	"DAY_RECEIVED",
	"DAY_TAKEN",
}

CONST_DAYS = {
	[ 1 ] = { 35000, "repairbox", "firstaid" };
	[ 2 ] = { 45000, "firstaid", "canister" };
	[ 3 ] = { 55000, "canister", "repairbox" };
	[ 4 ] = { 65000, "firstaid", "firstaid" };
	[ 5 ] = { 75000, "canister", "canister" };
	[ 6 ] = { 95000, "repairbox", "repairbox" };
	[ 7 ] = { 105000, "repairbox", "firstaid" };
	[ 8 ] = { 125000, "firstaid", "canister" };
	[ 9 ] = { 135000, "canister", "repairbox" };
	[ 10 ] = { 165000, "firstaid", "firstaid" };
}