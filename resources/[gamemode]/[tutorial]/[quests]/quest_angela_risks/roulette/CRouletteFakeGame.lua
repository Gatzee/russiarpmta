local positions = {
    player = Vector3( -88.893783569336, -470.83206176758, 913.97650146484 ),
    player_rotation = Vector3( 0, 0, 268.02474975586 ),

    bot = Vector3( -85.192918395996, -470.78317260742, 913.97650146484 ),
    bot_rotation = Vector3( 0, 0, 92.893188476563 )
}

local saved_position

local rounds_to_kill = 3

function StartFakeRouletteGame( )
    saved_position = localPlayer.position

    iprint( getTickCount( ), "start" )
    localPlayer.position = positions.player
    localPlayer.rotation = positions.player_rotation

    CEs.enemy = createPed( 15, positions.bot )
    CEs.enemy.rotation = positions.bot_rotation
    CEs.enemy.dimension = localPlayer.dimension
    CEs.enemy.interior = localPlayer.interior

    OnRouletteGameStart( { } )

    local round = 1
    local turn_player

    function Shoot( player, result )
        StartShot( {
            player = player,
            result = result,
        } )
    end

    function MyShoot( )
        Shoot( localPlayer, false )
        OnRouletteTurnFinished( { player = localPlayer } )
        removeEventHandler( "OnCasinoGameRouletteFakeTurnMade", localPlayer, MyShoot )
        CEs.timer = setTimer( SwitchTurn, 8000, 1 )
    end

    function SwitchTurn( )
        turn_player = turn_player == CEs.enemy and localPlayer or CEs.enemy
        if turn_player == localPlayer then
            round = round + 1
            OnRouletteTurnStarted( localPlayer, 20000 )
            addEventHandler( "OnCasinoGameRouletteFakeTurnMade", localPlayer, MyShoot )
        else
            OnRouletteTurnStarted( CEs.enemy, 20000 )
            local is_kill = round > rounds_to_kill
            Shoot( CEs.enemy, round > rounds_to_kill )
            if is_kill then
                CEs.timer = setTimer( function( )
                    --OnClientDicesWon_handler( )
                    ShowGameResult( true )
                    triggerServerEvent( "angela_risks_step_8", localPlayer )
                end, 5500, 1 )
            else
                CEs.timer = setTimer( SwitchTurn, 8000, 1 )
            end
        end
    end

    CEs.timer = setTimer( SwitchTurn, 2000, 1 )

    local round = 1
end

function FinishFakeRouletteGame( )
    OnRouletteGameFinished( )
    if saved_position then localPlayer.position = saved_position end
end