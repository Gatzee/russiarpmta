local PLAYERS_FIST_DAMAGE = { }

CLAN_BUFF_CONTROLLERS[ CLAN_UPGRADE_FIST_DAMAGE ] = {
    Enable = function( self, player, conf )
        PLAYERS_FIST_DAMAGE[ player ] = conf.buff_value
    end,

    Disable = function( self, player )
        self:Clear( player )
    end,

    Clear = function( self, player )
        PLAYERS_FIST_DAMAGE[ player ] = nil
    end,
}

addEventHandler ( "onPlayerDamage", root, function( attacker, weapon )
	if weapon ~= 0 or not PLAYERS_FIST_DAMAGE[ attacker ] then return end

	source.health = source.health - PLAYERS_FIST_DAMAGE[ attacker ]
end )