loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
addEvent( "onWeaponEditorRequest", true )
addEventHandler( "onWeaponEditorRequest", root, function( weapon_id, skill ) 
	local propertiesTable = {}
	local flagsTable = {}

	for i,v in pairs( PROPERTIES ) do
		propertiesTable[ v ] = getWeaponProperty( weapon_id, skill, v )
	end

	for i,v in pairs( FLAGS ) do
		flagsTable[ i ] = getFlagState( weapon_id, skill, v )
	end
	
	triggerClientEvent( client or source, "onWeaponEditorResponse", client or source, propertiesTable, flagsTable )

end )
addEvent( "onWeaponStatsEdit", true )
addEventHandler( "onWeaponStatsEdit", root, function( weapon_id, skill, properties, flags ) 
	local hasErrors = false

	for i,v in pairs( properties ) do 
		if not setWeaponProperty( weapon_id, skill, i, v ) then 
			hasErrors = true
			outputDebugString( "EDITING OF ".. tostring( i ).." FAILED" )
		end
	end
	for i,v in pairs( flags ) do 
		setWeaponPropertyFlag( weapon_id, skill, FLAGS[ i ], v )
	end

	if hasErrors then client:ShowError( "Некоторые значения не применились, проверьте дебаг консоль" ) end
end )
function getFlagState( weapon, skill, flagBit)
	return bitAnd( getWeaponProperty( weapon, skill, "flags" ), flagBit ) ~= 0
end
function setWeaponPropertyFlag( weapon, skill, flagBit, bSet )
    local bIsSet = getFlagState( weapon, skill, flagBit )
    if bIsSet ~= bSet then
        setWeaponProperty( weapon, skill, "flags", flagBit )
    end
end