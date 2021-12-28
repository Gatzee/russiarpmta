

-- Вход в игру, инициализация стола
addEvent( "OnCasinoGameClassicRouletteStarted", true )
addEventHandler( "OnCasinoGameClassicRouletteStarted", resourceRoot, function( roulette_data )
    CreateRouletteGame( roulette_data )
    triggerEvent( "onClientShowUICasinoGame", root, false )
end )

-- Выход из игры, уничтожение стола
addEvent( "OnCasinoGameClassicRouletteLeaved", true )
addEventHandler( "OnCasinoGameClassicRouletteLeaved", resourceRoot, function( is_forced )
    DestroyRouletteGame( is_forced )
end )
