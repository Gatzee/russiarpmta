CLAN_BUFF_CONTROLLERS[ CLAN_UPGRADE_MAX_HP_AND_STAMINA ] = {
    Enable = function( self, player, conf )
        player:SetBuff( "max_health", conf.buff_value, "clan_buff" .. CLAN_UPGRADE_MAX_HP_AND_STAMINA )
        player:SetBuff( "max_stamina", conf.buff_value, "clan_buff" .. CLAN_UPGRADE_MAX_HP_AND_STAMINA )
    end,

    Disable = function( self, player )
        player:SetBuff( "max_health", nil, "clan_buff" .. CLAN_UPGRADE_MAX_HP_AND_STAMINA )
        player:SetBuff( "max_stamina", nil, "clan_buff" .. CLAN_UPGRADE_MAX_HP_AND_STAMINA )
    end,
}