CONST_SALE_STATE = {
    NOT_SALE        = 0,
    SHARED_SALE     = 1,
    INDIVIDUAL_SALE = 2,
}

-- игровые типы недвижимости
CONST_HOUSE_TYPE = {
    VILLA     = 1,
    COTTAGE   = 2,
    COUNTRY   = 3,
    APARTMENT = 4,
}

-- типы недвижимости по ресурсу
RESOURCE_VIP_HOUSE = 1
RESOURCE_APARTMENT = 2

CONST_LOCATION = {
    NONE        = -1,
    NSK         = 1,
    GORKI       = 2,
    SOCHI       = 3,
    RUBLEVO     = 4,
    PODMOSKOVIE = 5,
    NSK_AREA    = 6,
    GORKI_AREA  = 7,
    MSK         = 8,
}

-- принадлежность дома к локациии
LOCATION_DATA = {
    [ CONST_LOCATION.NSK ] = {
        [RESOURCE_VIP_HOUSE] = { },
        [RESOURCE_APARTMENT] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, },
    },
    [ CONST_LOCATION.GORKI ] = {
        [RESOURCE_VIP_HOUSE] = { "cottage2", "cottage3", "cottage4", "cottage5", "cottage6", },
        [RESOURCE_APARTMENT] = { 20, 21, 22, 23, 24, 25, 36, 37, 38, 39, 51, 52, 53, 54, }
    },
    [ CONST_LOCATION.SOCHI ] = {
        [RESOURCE_VIP_HOUSE] = { },
        [RESOURCE_APARTMENT] = { 55, 56, 57, 58, 59, }
    },
    [ CONST_LOCATION.RUBLEVO ] = {
        [RESOURCE_VIP_HOUSE] = { "villa1", "villa2", "villa3", "villa4", "villa5", "villa6", "villa7", "villa8", "villa9", "villa10", "villa11", "villa12", "villa13", "villa14", "cottage41", "cottage42", "cottage43", "cottage44", "cottage45", "cottage46", "cottage47", "cottage48", "cottage49", "cottage50", "cottage51", "cottage52", "cottage53", "cottage54", "cottage55", "cottage56", "cottage57", "cottage58", "cottage59", "cottage60", "cottage61", "cottage62", "cottage63", "cottage64", "cottage65", "cottage66", "cottage67", "cottage68", "cottage69", "cottage70", "cottage71", "cottage72", "cottage73", "cottage74", "cottage75", "cottage76", "cottage77", "cottage78", "cottage79", "cottage80", "cottage81", "cottage82", "cottage83", "cottage84", "cottage85", "cottage86", "cottage87", "cottage88", "cottage89", "cottage90", "cottage91", "cottage92", "cottage94", "cottage95", "cottage96", "cottage97", "cottage98", "cottage99", "cottage100", "cottage101", "cottage102", "cottage103", "cottage104", "cottage105", "cottage106", "cottage107", "cottage108", "cottage109",  },
        [RESOURCE_APARTMENT] = { }
    },
    [ CONST_LOCATION.PODMOSKOVIE ] = {
        [RESOURCE_VIP_HOUSE] = { },
        [RESOURCE_APARTMENT] = { 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, }
    },
    [ CONST_LOCATION.NSK_AREA ] = {
        [RESOURCE_VIP_HOUSE] = { "cottage1", "country1", "country2", "country3", "country4", "country5", "country6", "country7", "country8", "country9", "country10", "country11", "country12" },
        [RESOURCE_APARTMENT] = { }
    },
    [ CONST_LOCATION.GORKI_AREA ] = {
        [RESOURCE_VIP_HOUSE] = { "vh1", },
        [RESOURCE_APARTMENT] = { }
    },
    [ CONST_LOCATION.MSK ] = {
        [RESOURCE_VIP_HOUSE] = { },
        [RESOURCE_APARTMENT] = { 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162 }
    }
}

LOCATION_DATA_REVERSE = {}
for location_id, pData in pairs( LOCATION_DATA ) do
    for rType, pHouseList in pairs( pData ) do
        for i, sHouse in pairs( pHouseList ) do
            LOCATION_DATA_REVERSE[ sHouse ] = location_id
        end
    end
end

function GetLocationIDFromHID( hid, house_type )
    if house_type == CONST_HOUSE_TYPE.APARTMENT then
        local _, _, id, number = utf8.find( hid, "^(%d+)_(%d+)$" )
        id = tonumber( id )

        if not id then
            outputDebugString( "nrp_house_sale: Не удалось определить локацию для hid: "..hid, 1 )
            return
        end

        return LOCATION_DATA_REVERSE[ id ]
    else
        return LOCATION_DATA_REVERSE[ hid ]
    end
end

function GetRelativeResourceTypeFromHID( hid )
    -- если после match остается число, значит это ресурс - nrp_apartment, иначе nrp_vip_house
    local id = utf8.match( hid, "([^_]+)_" )
    local is_num = id and utf8.match( id, "^%d+$" ) or false
    return is_num and RESOURCE_APARTMENT or RESOURCE_VIP_HOUSE
end

function GetHouseTypeFromHID( hid )
    local resource_type = GetRelativeResourceTypeFromHID( hid )

    if resource_type == RESOURCE_APARTMENT then
        return CONST_HOUSE_TYPE.APARTMENT
    elseif utf8.find( hid, "^vh" ) or utf8.find( hid, "^villa" ) then
        return CONST_HOUSE_TYPE.VILLA
    elseif utf8.find( hid, "^cottage" ) then
        return CONST_HOUSE_TYPE.COTTAGE
    elseif utf8.find( hid, "^country" ) then
        return CONST_HOUSE_TYPE.COUNTRY
    else
        outputDebugString( "ERROR ShHouseSale.lua: Не удалось определить тип дома", 1 )
    end
end
