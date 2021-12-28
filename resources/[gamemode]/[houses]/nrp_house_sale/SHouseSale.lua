Extend( "SDB" )
Extend( "SPlayer" )
Extend( "ShTimelib" )
Extend( "SPlayerOffline" )


-- Сохраняемые динамические данные
HOUSE_SALES_DATA = {}

COLUMNS = {
    { Field = "hid",                        Type = "varchar(128)",		    Null = "NO",    Key = "PRI",	Default = ""	};
    { Field = "house_type",				    Type = "smallint(3) unsigned",	Null = "NO",	Key = "",		Default = 0	    };
    { Field = "seller_id",                  Type = "int(11)",		        Null = "NO",	Key = "",       Default = 0     };
    { Field = "possible_buyer_id",          Type = "int(11)",			    Null = "NO",	Key = "",       Default = 0     };
    { Field = "sale_state",				    Type = "smallint(3)",	        Null = "NO",	Key = "",		Default = 0	    };
    { Field = "sale_cost",					Type = "bigint(20)",			Null = "NO",	Key = "",	    Default = 0,	};
    { Field = "sale_publish_date",          Type = "int(11)",			    Null = "NO",	Key = "",       Default = 0     };
    { Field = "total_rental_fee",		    Type = "int(11)",			    Null = "NO",	Key = "",       Default = 0     };
    { Field = "location_id",			    Type = "smallint(3) unsigned",	Null = "NO",	Key = "",		Default = 0	    };
}
DB:createTable( "nrp_house_sales", COLUMNS )

COLUMNS_REVERSE = { }
for i, v in pairs( COLUMNS ) do
    COLUMNS_REVERSE[ v.Field ] = true
end

function AsyncLoadHouseSaleData( )
    DB:queryAsync( function ( query )
        local result = dbPoll( query, -1 )
        if type( result ) == "table" and #result > 0 then
            for k, v in pairs( result ) do
                HOUSE_SALES_DATA[ v.hid ] = v
			end
        else
            outputDebugString( "Таблица nrp_house_sales пуста", 1 )
        end

    end , {}, "SELECT * FROM nrp_house_sales WHERE sale_state>0;" )
end

-- Постоянные данные
function GetHouseSaleData( hid, key )
    if COLUMNS_REVERSE[ key ] then
        return HOUSE_SALES_DATA[ hid ][ key ]
    end
end

function SetHouseSaleData( hid, key, value )
    if COLUMNS_REVERSE[ key ] then
        if not HOUSE_SALES_DATA[ hid ] then
            -- По идее SetHouseSaleData не должен вызываться в этом случае, т.к.
            -- SetHouseSaleData (в onUpdateTotalRentalFee) вызывается только если house.sale_state > CONST_SALE_STATE.NOT_SALE
            -- при этом при изменении house.sale_state триггерится onChangeHouseSaleData,
            -- где назначается HOUSE_SALES_DATA[ hid ] и сохраняется в бд.
            -- Скорее всего инсерт в бд фейлится из-за какой-то ошибки (некоторые ошибки бд не пишутся в грейлоге), 
            -- из-за чего после перезапуска сервера HOUSE_SALES_DATA[ hid ] = nil

            -- Сбрасываем house.sale_state, т.к. на бирже его всё равно нет (not HOUSE_SALES_DATA[ hid ])
            local id, number = hid:match( "^(%d+)_(%d+)$" )
            id = tonumber( id )
            number = tonumber( number )
            exports.nrp_apartment:SetApartmentsData( id, number, "sale_state", CONST_SALE_STATE.NOT_SALE )
            return
        end
        HOUSE_SALES_DATA[ hid ][ key ] = value
    end
end

function onResourceStart_handler( )
    AsyncLoadHouseSaleData( )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function onChangeHouseSaleData_handler( hid, pData )

    if not HOUSE_SALES_DATA[ hid ] then
        HOUSE_SALES_DATA[ hid ] = {}
    end

    local pHouse = HOUSE_SALES_DATA[ hid ]

    pHouse.hid                       = pData.hid
    pHouse.house_type                = pData.house_type
    pHouse.possible_buyer_id         = pData.possible_buyer_id
    pHouse.seller_id                 = pData.seller_id
    pHouse.sale_state                = pData.sale_state
    pHouse.total_rental_fee          = pData.total_rental_fee
    pHouse.sale_publish_date         = pData.sale_publish_date
    pHouse.sale_cost                 = pData.sale_cost
    pHouse.location_id               = pData.location_id

    local query = DB:exec( "INSERT INTO nrp_house_sales "
        .. "(hid, house_type, possible_buyer_id, seller_id, "
        .. "sale_state, total_rental_fee, sale_publish_date, sale_cost, location_id) "
        .. "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) "
        .. "ON DUPLICATE KEY UPDATE "
        .. "possible_buyer_id=VALUES(possible_buyer_id), "
        .. "seller_id=VALUES(seller_id), "
        .. "sale_state=VALUES(sale_state), "
        .. "total_rental_fee=VALUES(total_rental_fee), "
        .. "sale_publish_date=VALUES(sale_publish_date), "
        .. "sale_cost=VALUES(sale_cost);",
        pData.hid,
        pData.house_type,
        pData.possible_buyer_id,
        pData.seller_id,
        pData.sale_state,
        pData.total_rental_fee,
        pData.sale_publish_date,
        pData.sale_cost,
        pData.location_id
    )

	if not query then
		outputDebugString( "nrp_house_sale: House sale error, hid " .. pData.hid, 1 )
	end

end
addEvent( "onChangeHouseSaleData", false )
addEventHandler( "onChangeHouseSaleData", root, onChangeHouseSaleData_handler )

-- обновление суммарной арендной платы с учетом апгрейдов на снижение
function onUpdateTotalRentalFee_handler( hid, total_rental_fee )
    SetHouseSaleData( hid, "total_rental_fee", total_rental_fee )
    DB:exec( "UPDATE nrp_house_sales SET total_rental_fee = ? WHERE hid = ?;",
        total_rental_fee, hid )
end
addEvent( "onUpdateTotalRentalFee", false )
addEventHandler( "onUpdateTotalRentalFee", root, onUpdateTotalRentalFee_handler )


function IsPlayerHouseOwner( player, hid, house_type )
    local bIsOwner = false
    local pHouseList = GetPlayerHouseList( player )

    if house_type == CONST_HOUSE_TYPE.APARTMENT then
        for k, v in pairs( pHouseList[ RESOURCE_APARTMENT ] ) do
            if v.hid == hid and v.user_id == player:GetUserID( ) then
                bIsOwner = true
                break
            end
        end
    else
        for k, v in pairs( pHouseList[ RESOURCE_VIP_HOUSE ] ) do
            if v.hid == hid and v.owner == player:GetUserID( ) then
                bIsOwner = true
                break
            end
        end
    end

    return bIsOwner
end

function GetPlayerHouseList( player )
    local house_list = {}
    house_list[ RESOURCE_APARTMENT ] = exports.nrp_apartment:GetPlayerApartmentList( player )
    house_list[ RESOURCE_VIP_HOUSE ] = exports.nrp_vip_house:GetPlayerVipHouseList( player )
    return house_list
end
