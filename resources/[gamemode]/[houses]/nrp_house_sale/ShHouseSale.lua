loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )
Extend( "ShApartments" )
Extend( "ShVipHouses" )
Extend( "ShHouseSale" )

CONST_LOCATION_INFO = {
    [ CONST_LOCATION.NONE        ] = { name = "Все",                   value = CONST_LOCATION.NONE        };
    [ CONST_LOCATION.NSK         ] = { name = "Новороссийск",          value = CONST_LOCATION.NSK         };
    [ CONST_LOCATION.GORKI       ] = { name = "Горки",                 value = CONST_LOCATION.GORKI       };
    [ CONST_LOCATION.SOCHI       ] = { name = "Сочи",                  value = CONST_LOCATION.SOCHI       };
    [ CONST_LOCATION.RUBLEVO     ] = { name = "Рублево",               value = CONST_LOCATION.RUBLEVO     };
    [ CONST_LOCATION.PODMOSKOVIE ] = { name = "Подмосковье",           value = CONST_LOCATION.PODMOSKOVIE };
    [ CONST_LOCATION.NSK_AREA    ] = { name = "Область Новороссийска", value = CONST_LOCATION.NSK_AREA    };
    [ CONST_LOCATION.GORKI_AREA  ] = { name = "Область Горки",         value = CONST_LOCATION.GORKI_AREA  };
    [ CONST_LOCATION.MSK         ] = { name = "Москва",                value = CONST_LOCATION.MSK         };
}

function GetApartmentIdAndNumber( hid )
    local id, number = hid:match( "^(%d+)_(%d+)$" )
    return tonumber( id ), tonumber( number )
end