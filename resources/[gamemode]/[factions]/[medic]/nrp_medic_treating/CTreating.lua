loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CPlayer" )
Extend( "ib" )

local is_treating_minigame_started = false

function onClientPlayerStartTreat_handler( disease_id, disease_stage )
    if is_treating_minigame_started then return end
    is_treating_minigame_started = true
    showCursor( true )

    local target = source
    function OnTreatingComplete( )
		triggerServerEvent( "onPlayerTreatComplete", localPlayer, target, disease_id )
        is_treating_minigame_started = false
        showCursor( false )
	end

    MINIGAMES[ disease_stage ][ 1 ]( )
end
addEvent( "onClientPlayerStartTreat", true )
addEventHandler( "onClientPlayerStartTreat", root, onClientPlayerStartTreat_handler )

MINIGAMES = {
    [ 1 ] = {
        [ 1 ] = function(  )
            ibInfoPressKey( {
                do_text = "Нажми",
                text = "чтобы осмотреть пациента",
                key = "lalt",
				key_text = "ALT",
                black_bg = 0x80495f76,
                key_handler = MINIGAMES[ 1 ][ 2 ],
            } )
		end,
		
        [ 2 ] = function(  )
            ibInfoPressKey( {
                do_text = "Нажми",
                text = "чтобы взять стетоскоп",
                key = "mouse1",
                black_bg = 0x80495f76,
                key_handler = MINIGAMES[ 1 ][ 3 ],
            } )
        end,

        [ 3 ] = function( )
            ibInfoPressKeyZone( {
                do_text = "Вовремя нажмай",
                text = "чтобы прослушать пациента",
                key = "mouse2",
                click_count = 3,
                black_bg = 0x80495f76,
                end_handler = MINIGAMES[ 1 ][ 4 ],
            } )
        end,

        [ 4 ] = function( )
            ibInfoPressKeyProgress( {
                do_text = "Нажимай",
                text = "чтобы выписать лекарства",
                key = "mouse1",
                click_count = 10,
                black_bg = 0x80495f76,
                end_handler = OnTreatingComplete,
            } )
        end,
    },



    [ 2 ] = {
        [ 1 ] = function(  )
            ibInfoPressKey( {
                do_text = "Нажми",
                text = "чтобы осмотреть пациента",
                key = "lalt",
				key_text = "ALT",
                black_bg = 0x80495f76,
                key_handler = MINIGAMES[ 2 ][ 2 ],
            } )
        end,

        [ 2 ] = function( )
            ibInfoPressKey( {
                do_text = "Нажми",
                text = "чтобы взять флакон с таблетками",
                key = "mouse1",
                black_bg = 0x80495f76,
                key_handler = MINIGAMES[ 2 ][ 3 ],
            } )
        end,

        [ 3 ] = function( )
            ibInfoPressKeyProgress( {
                do_text = "Нажимай",
                text = "чтобы выбрать нужные таблетки",
                key = "mouse2",
                click_count = 10,
                timeout = 1000,
                black_bg = 0x80495f76,
                end_handler = MINIGAMES[ 2 ][ 4 ],
            } )
		end,
		
        [ 4 ] = function(  )
            ibInfoPressKeyCircle( {
                do_text = "Нажми",
                text = "чтобы дать таблетки пациенту",
                key = "mouse1",
                black_bg = 0x80495f76,
                end_handler = MINIGAMES[ 2 ][ 5 ],
            } )
		end,
		
        [ 5 ] = function(  )
            ibInfoPressKey( {
                do_text = "Удерживай",
                text = "чтобы положить инструмент",
				key = "mouse1",
				hold = true,
                black_bg = 0x80495f76,
                key_handler = OnTreatingComplete,
            } )
        end,
	},
	


    [ 3 ] = {
        [ 1 ] = function(  )
            ibInfoPressKey( {
                do_text = "Нажми",
                text = "чтобы осмотреть пациента",
                key = "lalt",
				key_text = "ALT",
                black_bg = 0x80495f76,
                key_handler = MINIGAMES[ 3 ][ 2 ],
            } )
		end,
		
        [ 2 ] = function(  )
            ibInfoPressKey( {
                do_text = "Нажми",
                text = "чтобы взять шприц",
                key = "mouse1",
                black_bg = 0x80495f76,
                key_handler = MINIGAMES[ 3 ][ 3 ],
            } )
        end,

        [ 3 ] = function( )
            ibInfoPressKeyZone( {
                do_text = "Вовремя нажми",
                text = "чтобы сделать укол",
                key = "mouse2",
                click_count = 1,
                black_bg = 0x80495f76,
                end_handler = MINIGAMES[ 3 ][ 4 ],
            } )
        end,

        [ 4 ] = function( )
            ibInfoPressKeyProgress( {
                do_text = "Нажимай",
                text = "чтобы ввести лекарство",
                key = "mouse1",
                click_count = 10,
                black_bg = 0x80495f76,
                end_handler = MINIGAMES[ 3 ][ 5 ],
            } )
        end,
		
        [ 5 ] = function(  )
            ibInfoPressKey( {
                do_text = "Удерживай",
                text = "чтобы достать иглу",
				key = "mouse2",
				hold = true,
				hold_time = 2000,
                black_bg = 0x80495f76,
                key_handler = MINIGAMES[ 3 ][ 6 ],
            } )
        end,
		
        [ 6 ] = function(  )
            ibInfoPressKey( {
                do_text = "Удерживай",
                text = "чтобы положить шприц",
				key = "mouse1",
				hold = true,
                black_bg = 0x80495f76,
                key_handler = OnTreatingComplete,
            } )
        end,
    },
}