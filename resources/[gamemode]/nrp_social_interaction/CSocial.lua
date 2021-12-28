Extend( "CPlayer" )

data = { }

local iSessionStartRating = 0
local iLastNotification = 0

function updateData( dataName, ... )
    local t = { ... }

    if dataName == "findedPlayerData" then
        data[dataName] = getUserIDFromNickName( t[1] ) and { id = getUserIDFromNickName( t[1] ), nickname = t[1] } or false
        if data[dataName] then return end
    end

    triggerServerEvent( "socialInteractionUpData", localPlayer, dataName, ... )
end

addEvent( "socialInteractionUpData", true )
addEventHandler( "socialInteractionUpData", root, function ( dataName, dataFromServer )
    data[dataName] = dataFromServer
end )

function GetSocialRatingDelta( )
    return localPlayer:GetSocialRating() - iSessionStartRating
end

function UpdateSocialRatingDelta( key, old, new )
    if key ~= "social_rating" then return end

    if not old then
        iSessionStartRating = localPlayer:GetSocialRating()
        return
    end

    local delta = GetSocialRatingDelta( )

    if math.abs( iLastNotification - delta ) >= 100 then
        iLastNotification = delta
        localPlayer:PhoneNotification( { title = "Изменение рейтинга", msg = "Ваш рейтинг изменился на " .. delta .. " ед" } )
    end
end
addEventHandler( "onClientElementDataChange", localPlayer, UpdateSocialRatingDelta )

RATING_NAMES = {
    { name = "Идеальный",                   value = 1000  },
    { name = "Влиятельный",                 value = 800   },
    { name = "Уравновешенный",              value = 700   },
    { name = "Положительный",               value = 600   },
    { name = "Обаятельный",                 value = 500   },
    { name = "Активный",                    value = 400   },
    { name = "Ответственный",               value = 300   },
    { name = "Спокойный",                   value = 200   },
    { name = "Учтивый",                     value = 100   },
    { name = "Законопослушный гражданин",   value = 0     },
    { name = "Безразличный",                value = -100  },
    { name = "Агрессивный",                 value = -200  },
    { name = "Жестокий",                    value = -300  },
    { name = "Злой",                        value = -400  },
    { name = "Отвратительный",              value = -500  },
    { name = "Отрицательный",               value = -600  },
    { name = "Неуравновешенный",            value = -700  },
    { name = "Опасный",                     value = -800  },
    { name = "Психопат",                    value = -1000 },
}