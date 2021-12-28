loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

function onPlayerCompleteTutorial_handler( )
    client:SetHintsActive( "keyboard" )
    client:RefreshHints( )
end
addEvent( "onPlayerCompleteTutorial", true )
addEventHandler( "onPlayerCompleteTutorial", root, onPlayerCompleteTutorial_handler )

function onPlayerHintExpired_handler( )
    client:SetHintsActive( true )
    client:RefreshHints( )
end
addEvent( "onPlayerHintExpired", true )
addEventHandler( "onPlayerHintExpired", root, onPlayerHintExpired_handler )

function onPlayerReadyToPlay_handler( )
    if source:GetHintsActive( ) then
        source:RefreshHints( )
    end
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )

function Player:SetHintsActive( state )
    self:SetPermanentData( "hints", state or nil )
end

function Player:GetHintsActive( )
    return self:GetPermanentData( "hints" )
end

function Player:RefreshHints( )
    triggerClientEvent( self, "onClientPlayerHintsRefresh", resourceRoot, self:GetHintsActive( ) )
end

addEventHandler( "onResourceStart", resourceRoot, function( )
    setTimer( function( )
        for i, v in pairs( GetPlayersInGame( ) ) do
            if v:GetHintsActive( ) then
                v:RefreshHints( )
            end
        end
    end, 1000, 1 )
end )