
-- Сгенрировать списки доступных к покупке номеров
function GetNumbersList()
    return 
    {
        GenerateNumbersByType( NUMBERS.unique.type ),
        GenerateNumbersByType( NUMBERS.premium.type ),
        GenerateNumbersByType( NUMBERS.luxury.type ),
        GenerateNumbersByType( NUMBERS.standard.type ),
    }
end

-- Сгенерировать список по типу
function GenerateNumbersByType( type )
    local numbers = {}
    for k, v in pairs( NUMBERS[ type ].GetNumbers() ) do
        table.insert( numbers, NUMBERS.CreateModel( v, NUMBERS[ type ] ) )
    end
    return numbers
end

-- Получаем свободные уникальные номера
function GetUniqueNumbers()
    local numbers = {}
    for k, v in pairs( UNIQUE_NUMBERS ) do
        if not NUMBERS.uses_numbers[ k ] then
            table.insert( numbers, k )
        end
    end
    return numbers
end

-- Номер уникальный?
function IsPhoneNumberIsUnique( number )
    return UNIQUE_NUMBERS[ number ] or false
end

-- Получить свободные премиумные номера
function GetPremiumNumbers()
    local numbers = {}
    for k, v in pairs( PREMIUM_NUMBERS ) do
        if not NUMBERS.uses_numbers[ k ] then
            table.insert( numbers, k )
        end
    end
    return numbers
end

-- Номер премиумный?
function IsPhoneNumberIsPremium( number )
    return PREMIUM_NUMBERS[ number ] or false
end

-- Получить свободные люксовые номера
function GetLuxNumbers()
    local numbers = {}
    for i = 1, 9 do
        for k, v in pairs( LUX_VARIANTS ) do
            local number = tonumber( i .. v )
            --Если номер не использован и он не люксовый/премиумный
            if not NUMBERS.uses_numbers[ number ] and not NUMBERS.unique.IsNumber( number ) and not NUMBERS.premium.IsNumber( number ) then
               table.insert( numbers, number )
            end
        end
    end
    return numbers
end

-- Номер люксовый?
function IsPhoneNumberIsLux( number )
    return number % 1000000 % 111111 == 0 and not NUMBERS.unique.IsNumber( number ) and not NUMBERS.premium.IsNumber( number )
end

function GetStandardNumbers()
    local triad = 111
    local numbers = {}
    repeat
        local x = math.random( 1, 9 )
        local n = math.random( 1, 9 )
        local m = math.random( 1, 9 )
        local number = x .. ( n * triad ) .. ( m * triad )
        if not NUMBERS.uses_numbers[ temp ] and NUMBERS.standard.IsNumber( number ) then
            table.insert( numbers, number )
        end
    until #numbers > CONST_TRIGGER_STANDARD_NUMBERS
    return numbers
end

function IsPhoneNumberIsStandard( number )
    local triad = 111
    local temp = number % 1000000
    local n, m = math.modf( temp / 1000 )
    m = math.floor( m )
    if n ~= m and n % triad == 0 and m % triad == 0 then
        return true
    end
    return false
end

-- Сгенерировать обычный номер
function GenerateOrdinaryNumbers()
    local number = nil
    repeat
        local temp = math.random( MIN_PHONE_NUMBER + 1, MAX_PHONE_NUMBER - 1 )
        if not NUMBERS.uses_numbers[ temp ] and NUMBERS.ordinary.IsNumber( temp ) then
            number = temp
        end
    until number ~= nil
    return NUMBERS.CreateModel( number, NUMBERS.ordinary )
end

-- Номер обычный?
function IsPhoneNumberIsOrdinary( number )
    --Если это номер другого типа или присутствуют символы
    if not number or NUMBERS.unique.IsNumber( number ) or NUMBERS.premium.IsNumber( number ) or NUMBERS.luxury.IsNumber( number ) or NUMBERS.standard.IsNumber( number ) or number < MIN_PHONE_NUMBER or number > MAX_PHONE_NUMBER  then
        return false
    end
    return true
end

function IsAnyPhoneNumber( phone_number )
    if tonumber( phone_number ) and phone_number >= MIN_PHONE_NUMBER and phone_number <= MAX_PHONE_NUMBER then
        return true
    end
    return false
end

-- Вспомогательный функционал
function InitializeHelpNumberFunctions()
    NUMBERS.unique.IsNumber   = IsPhoneNumberIsUnique
    NUMBERS.premium.IsNumber  = IsPhoneNumberIsPremium
    NUMBERS.luxury.IsNumber   = IsPhoneNumberIsLux
    NUMBERS.standard.IsNumber = IsPhoneNumberIsStandard
    NUMBERS.ordinary.IsNumber = IsPhoneNumberIsOrdinary

    NUMBERS.IsAnyNumber = IsAnyPhoneNumber

    NUMBERS.unique.GetNumbers   = GetUniqueNumbers
    NUMBERS.premium.GetNumbers  = GetPremiumNumbers
    NUMBERS.luxury.GetNumbers   = GetLuxNumbers
    NUMBERS.standard.GetNumbers = GetStandardNumbers
    NUMBERS.ordinary.GenerateNumber = GenerateOrdinaryNumbers

    NUMBERS.CreateModel = CreatePhoneNumberModel
    
    NUMBERS.uses_numbers = {}
end