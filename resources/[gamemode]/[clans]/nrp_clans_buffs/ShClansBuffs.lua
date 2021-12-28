loadstring( exports.interfacer:extend( "Interfacer" ) )( )

NEED_CLAN_RANK = 3

CLAN_BUFF_CONTROLLERS = { }

Player.ApplyClanBuff = function( self, upgrade_id, lvl )
    local upgrade_conf = CLAN_UPGRADES_LIST[ upgrade_id ]
    if upgrade_conf.buff_id then
        self:SetBuff( upgrade_conf.buff_id, upgrade_conf[ lvl ].buff_value, "clan_buff" .. upgrade_id )
    elseif CLAN_BUFF_CONTROLLERS[ upgrade_id ] then
        CLAN_BUFF_CONTROLLERS[ upgrade_id ]:Enable( self, upgrade_conf[ lvl ] )
    end
end

Player.ApplyAllClanBuffs = function( self, upgrades )
    for upgrade_id, lvl in pairs( upgrades or GetClanData( self:GetClanID( ), "upgrades" ) ) do
        self:ApplyClanBuff( upgrade_id, lvl )
    end
end

Player.RemoveClanBuff = function( self, upgrade_id )
    local upgrade_conf = CLAN_UPGRADES_LIST[ upgrade_id ]
    if upgrade_conf.buff_id then
        self:SetBuff( upgrade_conf.buff_id, nil, "clan_buff" .. upgrade_id )
    elseif CLAN_BUFF_CONTROLLERS[ upgrade_id ] then
        CLAN_BUFF_CONTROLLERS[ upgrade_id ]:Disable( self )
    end
end

Player.RemoveAllClanBuffs = function( self )
    for upgrade_id, upgrade_conf in pairs( CLAN_UPGRADES_LIST ) do
        if upgrade_conf.buff_id then
            self:SetBuff( upgrade_conf.buff_id, nil, "clan_buff" .. upgrade_id )
        elseif CLAN_BUFF_CONTROLLERS[ upgrade_id ] then
            CLAN_BUFF_CONTROLLERS[ upgrade_id ]:Disable( self )
        end
    end
end