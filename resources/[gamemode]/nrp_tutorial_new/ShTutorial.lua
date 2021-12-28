loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ShSkin" )

TUTORIAL_STEPS = { }

REG_SKINS = {
    [ 0 ] = { 118, 117, 120 },
    [ 1 ] = { 141, 139, 145 },
}

REPLACE_NAME_CHARACTERS = 
{
	{ "Ё", "Е" },
    { "ё", "е" },
}

function FixWarningCharacters( name, last_name )
    for k, v in pairs( REPLACE_NAME_CHARACTERS ) do
		name = utf8.gsub( name, v[ 1 ], v[ 2 ] )
		last_name = utf8.gsub( last_name, v[ 1 ], v[ 2 ] )
    end
    return name, last_name
end

function CheckRegistrationData( name, last_name, day, month, year )
    -- Чекаем имя
    if ( { utf8.gsub( name, " ", "" ) } )[ 2 ] > 0 then
        return false, "Имя не может иметь пробелы"
    end

    if IncludesNonRussianCharacters( name ) then
        return false, "Имя персонажа должно быть полностью на русском языке"
    end

    if utf8.len( name ) > 16 then
        return false, "Имя персонажа не может быть длиннее 16 символов"
    end

    if utf8.len( name ) < 2 then
        return false, "Имя персонажа не может быть короче 2 символов"
    end

    -- Фамилию
    if ( { utf8.gsub( last_name, " ", "" ) } )[ 2 ] > 0 then
        return false, "Фамилия не может иметь пробелы"
    end

    if IncludesNonRussianCharacters( last_name ) then
        return false, "Фамилия должна быть полностью на русском языке"
    end

    if utf8.len( last_name ) > 16 then
        return false, "Фамилия не может быть длиннее 16 символов"
    end

    if utf8.len( last_name ) < 4 then
        return false, "Фамилия не может быть короче 4 символов"
    end

    -- Дату рождения
    if not day or day < 1 or day > 31 then
        return false, "Неверный день рождения"
    end

    if not month or month < 1 or month > 12 then
        return false, "Неверный месяц рождения"
    end

    if not year then
        return false, "Неверный год рождения"
    end

    if os.date( "*t" ).year - year >= 90 then
        return false, "Персонаж должен быть младше 90 лет"
    end

    if os.date( "*t" ).year - year < 18 then
        return false, "Персонаж должен быть старше 18 лет"
    end

    return true
end

function IncludesNonRussianCharacters( str )
    for i = 1, utf8.len( str ) do
        local character = utf8.sub( str, i, i )
        local code = utfCode( character )

        if ( code < 1040 or code > 1103 ) and not ( code == 1105 or code == 1024 ) then
            return true
        end
    end
end


-- 118 +++
-- 141 +++
-- 117 +++
-- 120 +++
-- 139 +++
-- 145 +++