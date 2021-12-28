loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SVehicle" )

--1. Выдать фракционный опыт игроку
addCommandHandler( "givefactionexp", function( player, cmd, amount ) 
    if not amount or not tonumber( amount ) then player:ShowError( "Нужно указать кол-во опыта\n example: givefactionexp 228" ) return end

    player:GiveFactionExp( tonumber( amount ), "Тестирование" )
    player:ShowInfo( "Опыт успешно выдан" )
end )

addCommandHandler( "setfactionexp", function( player, cmd, amount ) 
    if not amount or not tonumber( amount ) then player:ShowError( "Нужно указать кол-во опыта\n example: setfactionexp 228" ) return end

    player:SetFactionExp( tonumber( amount ), "Тестирование" )
    player:ShowInfo( "Опыт успешно изменён" )
end )

--11. Выдать и отнять постоянный скин
addCommandHandler( "giveskin", function( player, cmd, model ) 
    if not model or not tonumber( model ) then player:ShowError( "Нужно указать ID скина\n example: giveskin 228" ) return end
    model = tonumber( model )

    if player:GiveSkin( model ) then
        player:ShowInfo( "Скин успешно выдан" )
        player:SetDefaultSkin( model )
        player.model = model
    else
        if player:HasSkin( model ) then 
            player:SetDefaultSkin( model )
            player.model = model
            player:ShowInfo( "Скин уже находился в гардеробе и был одет" )
        else
            player:ShowError( "Произошла ошибка при выдаче скина(возможно такой нельзя выдать)" )
        end
    end
end )

addCommandHandler( "takeskin", function( player, cmd, model ) 
    if not model or not tonumber( model ) then player:ShowError( "Нужно указать ID скина\n example: takeskin 228" ) return end
    if player:RemoveSkin( tonumber( model ) ) then
        for i, v in pairs ( player:GetSkins()) do 
            player:SetDefaultSkin( v )
            player.model = v
        end
        player:ShowInfo( "Скин успешно удален из гардероба" )

    else
        player:ShowError( "Произошла ошибка при удалении скина(возможно он уже удален из гардероба)" )
    end
end )

--12. Выдать и отнять постоянный аксессуар 
addCommandHandler( "giveaccessory", function( player, cmd, model ) 
    if not model then player:ShowError( "Нужно указать ID аксессуара\n example: giveaccessory 228" ) return end

    if not CONST_ACCESSORIES_INFO[ model ] then player:ShowError( "Указанный ID не найден в прописанных аксессуарах" ) return end

    player:AddOwnedAccessory( model )

    player:ShowInfo( "Аксессуар ".. CONST_ACCESSORIES_INFO[ model ].name .." успешно выдан" )
end )

addCommandHandler( "takeaccessory", function( player, cmd, model ) 
    if not model then player:ShowError( "Нужно указать ID аксессуара\n example: giveaccessory 228" ) return end

    local accessories = player:GetOwnedAccessories( )
    
    if not accessories[ model ] then 
        player:ShowError( "Аксессуар не найден в инвентаре" )
    else
        accessories[ model ] = nil
        player:SetPermanentData( "own_accessories", accessories )
        player:ShowInfo( "Аксессуар ".. ( CONST_ACCESSORIES_INFO[ model ].name or "" ) .." успешно удален" )
    end

end )

--13. Снять статьи розыска на персонаже
addCommandHandler( "removewanted", function( player, cmd, article ) 
    if article then player:ShowError( "Нужно указать статью\n example: removewanted 1.11" ) return end

    player:RemoveWanted( article )
    player:ShowInfo( "Статья сброшена" )
end )

addCommandHandler( "clearwanted", function( player, cmd ) 
    player:ClearWanted( article )
    player:ShowInfo( "Все статьи розыска сброшены" )
end )

--14. Снять кд на продажу машины
addCommandHandler( "settradeban", function( player, cmd, timestamp ) 
    local common_list = player:GetVehicles( _, true )
    for i, v in pairs( common_list ) do 
            v:SetPermanentData("last_trade_date", timestamp )
            v:SetPermanentData("showroom_date", timestamp )
    end
    
    if timestamp then 
        player:ShowInfo( "Кд на продажу установлены на все ваши автомобили" )
    else
        player:ShowInfo( "Кд на продажу снято с всех ваших автомобилей" )
    end
end )