Extend( "SPlayer" )
Extend( "SDB" )
Extend( "ShSocialRating" )

function onPlayerCompleteLogin_handler( player )
    local player = isElement( player ) and player or source
    if not player then return end

    local today_timestamp = getCurrentDayTimestamp( )
    local last_rating_reset = player:GetPermanentData( "last_sr_reset" ) or 0
    
    if last_rating_reset ~= today_timestamp then
        player:SetSocialRatingAnchor( player:GetSocialRating( ) )
        player:SetPermanentData( "last_sr_reset", today_timestamp )
    else
        player:SetSocialRatingAnchor( player:GetSocialRatingAnchor( ) )
    end
end
addEvent( "onPlayerCompleteLogin" )
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )

function getAvailableRatingForDonate( player )
    local availableRating = player:GetPermanentData( "available_rating" ) or 0
    local lastDonate = player:GetPermanentData( "last_rating_donate" ) or 0
    local currentTimestamp = getRealTimestamp()
    local timeToUpdate = ( lastDonate + 3600 * 24 ) - currentTimestamp
    timeToUpdate = timeToUpdate < 0 and 0 or timeToUpdate

    if timeToUpdate == 0 then
        availableRating = AVAILABLE_RATING_DONATE
        player:SetPermanentData( "available_rating", availableRating )
    end

    return availableRating, timeToUpdate
end

function updateDataForClient( client, dataName, value )
    triggerClientEvent( client, "socialInteractionUpData", client, dataName, value )
end

addEvent( "socialInteractionUpData", true )
addEventHandler( "socialInteractionUpData", root, function ( dataName, ... )
    if not isElement( client ) or client ~= source then return end

    local t = { ... }

    if dataName == "findedPlayerData" then
        local nickName = t[1]
        local player = getPlayerFromNickName( nickName )

        if player then
            updateDataForClient( client, nickName, { id = player:GetID( ), nickname = player:GetNickName( ) } )
        else
            updateDataForClient( client, nickName, false )
        end
    elseif dataName == "sendDonate" then
        local rating = tonumber( t[1] )
        local direction = t[2]

        if not rating then return else rating = math.floor( rating ) end

        local availableRating, timeToUpdate = getAvailableRatingForDonate( client )

        if availableRating < 1 or rating < 1 then
            local hour = math.ceil( timeToUpdate / 3600 )
            client:ShowError( "Вы привысили лимит изменения,\nприходите через " .. hour .. " ч." )
            return
        elseif rating > availableRating then
            return -- info were move to client side
        end

        local price = rating * CONVERT_CASH_TO_RATING

        local oldSocialRating = client:GetSocialRating( )
        local newSocialRating = oldSocialRating + ( direction and rating or - 1 * rating )

        if newSocialRating < -1000 or newSocialRating > 1000 then
            client:ShowError( "Соц. рейтинг не может превысить лимит." )
            return
        end

        if client:TakeMoney( price, "social_rating_upgrade", "change_rating" ) then
            client:ChangeSocialRating( direction and rating or - 1 * rating, "sr_donation" )
            client:SetPermanentData( "available_rating", availableRating - rating )

            if availableRating >= AVAILABLE_RATING_DONATE then
                client:SetPermanentData( "last_rating_donate", getRealTimestamp() )
            end

            local newSocialRating = client:GetSocialRating( )

            updateDataForClient( client, "social_rating", newSocialRating )
            updateDataForClient( client, "available_rating", availableRating - rating )

            -- for analytics
            triggerEvent( "onPlayerSentDonateForSocialRating", client, direction, price, "soft", oldSocialRating, newSocialRating, rating )
        end

    elseif dataName == "sendStatistic" then
        local nickName = t[1]
        local toPlayer = getPlayerFromNickName( nickName )

        if isAvailableStat( toPlayer, client ) then -- already sent
            toPlayer = true
        end

        if toPlayer and toPlayer ~= true then
            local propertyStats = getPlayerPropertyStats( client )

            toPlayer:PhoneNotification( {
                title = "Данные об имуществе",
                msg = "Общая стоимость имущества " .. client:GetNickName( ) .. " составляет:\n" .. format_price( propertyStats.property ) .. " рублей",
                special = "got_player_statistic",
                player = client,
            } )

            setAvailableStat( toPlayer, client, true ) -- allow toPlayer get statistic of client
        end

        updateDataForClient( client, dataName, toPlayer )

    elseif dataName == "sendAchievements" then
        local nickName = t[1]
        local toPlayer = getPlayerFromNickName( nickName )

        if isAvailableStat( toPlayer, client ) then -- already sent
            toPlayer = true
        end

        if toPlayer and toPlayer ~= true then
            toPlayer:PhoneNotification( {
                title = "Данные о достижениях",
                msg = client:GetNickName( ) .. " отправил(а) вам список своих достижений",
                special = "got_player_statistic",
                player = client,
                is_achievements = true,
            } )

            setAvailableStat( toPlayer, client, true ) -- allow toPlayer get statistic of client

            -- analytics
            local counter = 0
            local list = client:GetPermanentData( "achievements_list" ) or { }
            for i, lvl in pairs( list ) do counter = counter + lvl end

            SendElasticGameEvent( client:GetClientID( ), "achievement_share", {
                achieve_count = counter,
                player_id = toPlayer:GetClientID( ),
            } )
        end

        updateDataForClient( client, dataName, toPlayer )

    elseif dataName == "available_rating" then
        updateDataForClient( client, "available_rating", getAvailableRatingForDonate( client ) )

    elseif dataName == "statistic_other_player" then
        local player = t[ 1 ]
        if not isElement( player ) or not isAvailableStat( client, player ) then return end

        updateDataForClient( client, dataName, getPlayerPropertyStats( player ) )
        setAvailableStat( client, player, false )

    elseif dataName == "achievements_other_player" then
        local player = t[ 1 ]
        if not isElement( player ) or not isAvailableStat( client, player ) then return end

        local list = player:GetPermanentData( "achievements_list" ) or { }

        updateDataForClient( client, dataName, player:GetPermanentData( "achievements_list" ) or { } )
        setAvailableStat( client, player, false )

        -- analytics
        local counter = 0
        for i, lvl in pairs( list ) do counter = counter + lvl end

        SendElasticGameEvent( client:GetClientID( ), "achievement_look", {
            achieve_count = counter,
            player_id = player:GetClientID( ),
        } )

    elseif dataName == "dislikeFindedPlayer" or dataName == "likeFindedPlayer" then
        local playerData = t[1]
        local player = getPlayerFromNickName( playerData.nickname )
        local lastRatedPlayers = client:GetPermanentData( "last_rated_players" ) or { }

        if not player then
            client:ShowError( "Игрок не найден" )
            return
        end

        if not player:IsSocialRatingChangeAvailable( dataName == "likeFindedPlayer" and 1 or -1 ) then
            client:ShowError( "У данного игрока превышен дневной лимит на изменение соц. рейтинга" )
            return
        end

        if not tonumber( playerData.id ) or lastRatedPlayers[playerData.id] then
            client:ShowError( "Вы уже голосовали за данного игрока\n(обновление раз в 12 часов)" )
            return
        elseif player == client then
            client:ShowError( "Вы не можете выдать\nсамому себе " .. (  dataName == "dislikeFindedPlayer" and "дизлайк" or "лайк" ) )
            return
        else
            lastRatedPlayers[playerData.id] = 1
            client:SetPermanentData( "last_rated_players", lastRatedPlayers )
        end

        local dislike = client:GetPermanentData( "available_dislike" ) or 0
        local like = client:GetPermanentData( "available_like" ) or 0

        if dataName == "dislikeFindedPlayer" then
            if dislike < 1 then return end
            client:SetPermanentData( "available_dislike", dislike - 1 )
            updateDataForClient( client, "available_dislike", client:GetPermanentData( "available_dislike" ) )
        elseif dataName == "likeFindedPlayer" then
            if like < 1 then return end
            client:SetPermanentData( "available_like", like - 1 )
            updateDataForClient( client, "available_like", client:GetPermanentData( "available_like" ) )
        end

        if dislike >= AVAILABLE_DISLIKE and like >= AVAILABLE_LIKE then
            client:SetPermanentData( "last_date_like", getRealTimestamp() )
        end

        local ratingValue = dataName == "dislikeFindedPlayer" and SOCIAL_RATING_RULES.dislike.rating or SOCIAL_RATING_RULES.like.rating

        if player then
            player:ChangeSocialRating( ratingValue )

            -- for analytics
            triggerEvent( "onPlayerSentRating", client, dataName == "dislikeFindedPlayer" and "dislike" or "like", tostring( playerData.nickname ), player )
        else
            local function callback( query, client, dataName, nickName )
                if not query then return end
                dbFree( query )

                if not isElement( client ) then return end

                -- for analytics
                triggerEvent( "onPlayerSentRating", client, dataName == "dislikeFindedPlayer" and "dislike" or "like", nickName )
            end

            if ratingValue > 0 then
                DB:queryAsync(
                    callback,
                    { client, dataName, tostring( playerData.nickname ) },
                    "UPDATE nrp_players SET `social_rating` = IF ( `social_rating` + " .. ratingValue .. " < 1001, `social_rating` + " .. ratingValue .. ", 1000 ) WHERE nickname = ? LIMIT 1",
                    tostring( playerData.nickname )
                )
            else
                DB:queryAsync(
                    callback,
                    { client, dataName, tostring( playerData.nickname ) },
                    "UPDATE nrp_players SET `social_rating` = IF ( `social_rating` + " .. ratingValue .. " > - 1001, `social_rating` + " .. ratingValue .. ", - 1000 ) WHERE nickname = ? LIMIT 1",
                    tostring( playerData.nickname )
                )
            end
        end

        client:ShowInfo( dataName == "dislikeFindedPlayer" and "Вы поставили игроку дизлайк" or "Вы поставили игроку лайк" )

    elseif dataName == "top_players" then
        updateDataForClient( client, dataName, getTopPlayers( ) )

    elseif dataName == "statistic" then
        updateDataForClient( client, dataName, getPlayerStats( client ) )

    elseif dataName == "property_statistic" then
        updateDataForClient( client, dataName, getPlayerPropertyStats( client ) )

    elseif dataName == "buffs" then
        updateDataForClient( client, dataName, getPlayerBuffs( client ) )

    else
        if dataName == "available_like" or dataName == "available_dislike" then
            local currentTime = getRealTimestamp()
            local lastDateTime = client:GetPermanentData( "last_date_like" ) or 0

            if currentTime - lastDateTime > 3600 * 12 then -- reset likes and dislikes
                client:SetPermanentData( "available_dislike", AVAILABLE_DISLIKE )
                client:SetPermanentData( "available_like", AVAILABLE_LIKE )
                client:SetPermanentData( "last_rated_players", { } )
            end
        end

        updateDataForClient( client, dataName, client:GetPermanentData( dataName ) )
    end
end )

function onPlayerCompleteLogin_handler( player )
    local player = isElement( player ) and player or source
    player:SetSocialRating( player:GetSocialRating() )
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )

if SERVER_NUMBER > 100 then
    addCommandHandler( "reset_rating_limit", function( ply )
        if not ply:IsAdmin( ) then return end

        ply:SetSocialRatingAnchor( ply:GetSocialRating() )
        outputChatBox( "Лимит рейтинга успешно сброшен", ply, 255, 255, 255 )
    end)

    addCommandHandler( "change_rating", function( ply, cmd, value )
        if not ply:IsAdmin( ) then return end
        ply:ChangeSocialRating( tonumber( value ) or 0 )
        outputChatBox( "Социальный рейтинг изменён", ply, 255, 255, 255 )
    end)
end