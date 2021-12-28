
RATE =
{
    single =
    {
        friend = 
        {
            call = 1,
            msg = 2,
            
        },
        other = 
        {
            call  = 2,
            msg = 4,
        },
    },
}

MIN_PHONE_NUMBER = 1111111
MAX_PHONE_NUMBER = 9999999

CONST_TRIGGER_STANDARD_NUMBERS = 20

UNIQUE_NUMBERS = 
{
    [ 7777777 ] = 7777777,
    [ 1234567 ] = 1234567,
}

PREMIUM_NUMBERS =
{
    [ 1111111 ] = 1111111,
    [ 2222222 ] = 2222222,
    [ 3333333 ] = 3333333,
    [ 4444444 ] = 4444444,
    [ 5555555 ] = 5555555,
    [ 6666666 ] = 6666666,
    [ 8888888 ] = 8888888,
    [ 9999999 ] = 9999999,
}

LUX_VARIANTS =
{
    111111,
    222222,
    333333,
    444444,
    555555,
    666666,
    777777,
    888888,
    999999,
}

NUMBERS = 
{
    unique   = { name = "Уникальный", type = "unique",   cost = 3000000, },
    premium  = { name = "Премиум",    type = "premium",  cost = 2500000, },
    luxury   = { name = "Люкс",       type = "luxury",   cost = 1500000, },
    standard = { name = "Стандарт",   type = "standard", cost = 1000000, },
    ordinary = { name = "Обычный",    type = "ordinary", cost = 1000,    },
}

function CreatePhoneNumberModel( phone_number, data )
    return { number = tonumber( phone_number ), type = data.type, cost = data.cost }
end