
MODES[ RACE_TYPE_CIRCLE_TIME ] = 
{
    id = RACE_TYPE_CIRCLE_TIME,
    countdown_text = { "Успей", "Не врезайся", "Гони", },
    name = RACE_TYPES_DATA[ RACE_TYPE_CIRCLE_TIME ].name,
    tabs = MODES[ RACE_TYPE_DRIFT ].tabs,
    create_content = MODES[ RACE_TYPE_DRIFT ].create_content,

    detect_wrong_size = true,
    detect_damage = true,

    leader_boards = true,
    text_points = "Время",
    prepare_points = function( value )
        local minute = math.floor( value / 60000 )
        local seconds = math.floor( (value - minute * 60000) / 1000 )
        local milliseconds = value - minute * 60000 - seconds * 1000
        return string.format( "%02d:%02d:%02d", minute, seconds, milliseconds )
	end,
}

