
PAY_LEADESRS = {}
PAY_LEADERS_VISIBLE = 5

function InitPayLeadersTv()
    DB:queryAsync( function( qh )
        local result = dbPoll( qh, 0 )
        if not result or #result == 0 then return end
        
        PAY_LEADESRS = result
    end, {}, "SELECT id, nickname, pay_strip_money FROM nrp_players WHERE pay_strip_money > 0 ORDER BY pay_strip_money DESC LIMIT ?", PAY_LEADERS_VISIBLE )
end

function RefreshPayLeaders( player )
    local total_pay_money = player:GetPermanentData( "pay_strip_money" )
    
    local changed_top_list = nil
    local player_id = player:GetID()

    if #PAY_LEADESRS == PAY_LEADERS_VISIBLE then
        for k, v in ipairs( PAY_LEADESRS ) do
            if v.id == player_id then
                changed_top_list = true

                v.pay_strip_money = total_pay_money
                table.sort( PAY_LEADESRS, function( a, b ) return a.pay_strip_money > b.pay_strip_money end )
                break
            end
        end

        if not changed_top_list then
            for k, v in ipairs( PAY_LEADESRS ) do
                if total_pay_money > v.pay_strip_money then
                    changed_top_list = true
                    if k == 1 then player:SetPermanentData( "free_private_dance", true ) end

                    v.id = player_id
                    v.pay_strip_money = total_pay_money
                    v.nickname = player:GetNickName()
                    break
                end
            end
        end
    else
        changed_top_list = true
        table.insert( PAY_LEADESRS, { id = player_id, pay_strip_money = total_pay_money, nickname = player:GetNickName() } )
    end

    if changed_top_list then TryRefreshClientDataPayLeaders() end
end

function TryRefreshClientDataPayLeaders()
    local target_players = GetPlayersInStripClub()
    if #target_players > 0 then
        triggerClientEvent( target_players, "onClientRefreshPayTvLeaders", resourceRoot, PAY_LEADESRS )
    end
end