TABS_CONF.services = {
    fn_create = function( self, parent )
        local rt, sc = ibCreateScrollpane( 30, 45, 740, 463, parent, { scroll_px = 10 } )
        sc:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.2 )
        
        local npx, npy = 0, 20
        if (localPlayer:getData( "offer_discount_gift_time_left" ) or 0) > getRealTimestamp() then
            local coupon_discount_list = localPlayer:GetCouponDiscountListByItemType( "special_services" )
            local count_special_coupons = #coupon_discount_list
            if count_special_coupons > 0 then
                CreateSaleTab( npy, rt, {
                    discount_text = (count_special_coupons == 1 and "Скидочный купон на услуги: " or "Скидочные купоны на услуги: ") .. coupon_discount_list[ 1 ].value .. "%",
					count_special_coupons = count_special_coupons,
                } )

                npy = npy + 70
            end
        end

        local i = 0
        for n, v in pairs( SERVICES ) do
            if v.active == true or type( v.active ) == "function" and v.active( ) then
                i = i + 1

                if i > 1 and i % 2 == 1 then
                    npx = 0
                    npy = npy + 280 + 20
                elseif i > 1 then
                    npx = npx + 360 + 20
                end

                local bg = v.fn_create( rt )
                if bg then
                    bg:ibBatchData( { px = npx, py = npy } )
                end
            end
        end

        rt:AdaptHeightToContents( )
        rt:ibData( "sy", rt:ibData( "sy" ) + 20 )
    end,
}