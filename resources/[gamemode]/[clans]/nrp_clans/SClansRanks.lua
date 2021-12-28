function onPlayerClanEXPChange_handler( value )
    local player = client or source
    
    if not value then 
        player:SetPermanentData( "clan_exp", nil )
        player:SetPrivateData( "clan_exp", nil )
        return
    end
    
	local clan = player:GetClan( )
    if not clan then return end
    
	local old_exp = player:GetClanEXP( )
    local old_rank = player:GetClanRank( )
    
    local new_rank
    local max_rank = #CLAN_RANKS
    for i = old_rank + 1, max_rank do
        local rank = CLAN_RANKS[ i ]
        if value >= rank.required_exp then
            value = value - rank.required_exp
            new_rank = i
        else
            break
        end
    end

    if old_rank == max_rank or new_rank == max_rank then
        value = 0
    end
	player:SetPermanentData( "clan_exp", value )
    player:SetPrivateData( "clan_exp", value )

    if new_rank then
        player:SetClanRank( new_rank )
        clan:UpdateMemberData( player:GetUserID( ), "rank", new_rank )

        for rank = old_rank + 1, new_rank do
            local rank_conf = CLAN_RANKS[ rank ]
            if rank_conf.fn_OnReached then
                rank_conf.fn_OnReached( player )
            end
            if rank_conf.skins then
                player:GiveSkin( rank_conf.skins[ clan.way ] )
            end
        end
        if new_rank ~= 1 then
            player:ShowNotification( "Поздравляем, ты достиг нового ранга в своем клане!" )
        end

        triggerEvent( "onPlayerClanRankReached", player, new_rank )
    end
end
addEvent( "onPlayerClanEXPChange", true )
addEventHandler( "onPlayerClanEXPChange", root, onPlayerClanEXPChange_handler )

-- На случай, если лидер сменил путь клана
function CheckClanSkins( clan, player )
    for rank = 1, player:GetClanRank( ) do
        local rank_conf = CLAN_RANKS[ rank ]
        if rank_conf.skins then
            player:GiveSkin( rank_conf.skins[ clan.way ] )
        end
    end
end

addEvent( "onClanWayChange" )
addEventHandler( "onClanWayChange", root, function( clan_id )
    local clan = CLANS_BY_ID[ clan_id ]
    for i, player in pairs( clan:GetOnlineMembers( ) ) do
        CheckClanSkins( clan, player )
    end
end )

function UpdateClanRankUnlocks( player )
	-- local player = isElement( player ) and player or source
	-- local clan_id = player:GetClanID( )
	-- local clan = clan_id and CLANS_BY_ID[ clan_id ]
    -- if not clan then
    --     player:SetPermanentData( "temp_unlocks", false )
	--     player:SetPrivateData( "temp_unlocks", false )
    --     return
    -- end

    -- Updating level-based unlocks
    
	-- local rank = player:GetClanRank( ) or 0
	-- local new_temp_unlocks = {}
	-- for i = 1, rank do
	-- 	local unlocks = CLAN_RANKS[ i ].unlocks
	-- 	local rank_unlocks = type( unlocks[ clan.way ] ) == "table" and unlocks[ clan.way ] or unlocks or { }
	-- 	for k,v in pairs( rank_unlocks ) do
	-- 		new_temp_unlocks[ tostring( v ) ] = true
	-- 	end
	-- end
	-- player:SetPermanentData( "temp_unlocks", new_temp_unlocks )
	-- player:SetPrivateData( "temp_unlocks", new_temp_unlocks )
end
addEvent( "onPlayerClanRankChange", true )
addEventHandler( "onPlayerClanRankChange", root, UpdateClanRankUnlocks )