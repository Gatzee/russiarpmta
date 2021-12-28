function ClearBusinesses( businesses )
    for i, v in pairs( businesses ) do
        exports.nrp_businesses:ResetBusiness( v )
    end
end

function ClearApartments( viphouse_list, apartments_data_list )
    if #viphouse_list > 0 then
        for i, viphouse in ipairs( viphouse_list ) do
            exports.nrp_vip_house:ResetViphouse( viphouse.hid )

            local hid = viphouse.hid
            local house_type = GetHouseTypeFromHID( viphouse.hid )

            -- обнуляем продажу на бирже недвижимости
            local pData = {
                hid                      = hid,
                house_type               = house_type,
                possible_buyer_id        = 0,
                seller_id                = 0,
                sale_state               = CONST_SALE_STATE.NOT_SALE,
                total_rental_fee         = 0,
                sale_publish_date        = 0,
                sale_cost                = 0,
                location_id              = GetLocationIDFromHID( hid, house_type ),
            }

            triggerEvent( "onChangeHouseSaleData", resourceRoot, hid, pData )
        end
    end

    if #apartments_data_list > 0 then
        for i, apart_data in ipairs( apartments_data_list ) do
            local id, number, info, data = unpack( apart_data )
            if info then
                exports.nrp_apartment:ResetApartments( id, number )

                -- обнуляем продажу на бирже недвижимости
                local hid = id.."_"..number

                local pData = {
                    hid                      = hid,
                    house_type               = CONST_HOUSE_TYPE.APARTMENT,
                    possible_buyer_id        = 0,
                    seller_id                = 0,
                    sale_state               = CONST_SALE_STATE.NOT_SALE,
                    total_rental_fee         = 0,
                    sale_publish_date        = 0,
                    sale_cost                = 0,
                    location_id              = GetLocationIDFromHID( hid, CONST_HOUSE_TYPE.APARTMENT ),
                }

                triggerEvent( "onChangeHouseSaleData", resourceRoot, hid, pData )
            end
        end
    end

end

function ClearPhoneNumber( number )
    if number then
        exports.nrp_sim_shop:FreePhoneNumber( number )
        DB:exec( "UPDATE nrp_players SET phone_number = NULL, phone_number_type = NULL, phone_number_date_pur = NULL WHERE phone_number = ? LIMIT 1", number )
    end
end