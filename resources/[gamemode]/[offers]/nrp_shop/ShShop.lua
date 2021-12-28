enum "eNotificationTypes" {
    "OVERLAY_PROLONG_SUBSCRIPTION",
    "OVERLAY_PROLONG_PREMIUM",
    "OVERLAY_PREMIUM_FEATURES",
    "OVERLAY_CHANGE_SEX",
    "OVERLAY_CHANGE_NICKNAME",
    "OVERLAY_REMOVE_DISEASES",
    "OVERLAY_PURCHASE_HARD",
    "OVERLAY_DONATE_CONVERT",
    "OVERLAY_ACTION_KB",
    "OVERLAY_APPLY_NUMBERPLATE",
    "OVERLAY_CHANGE_NUMBERPLATE_REGION",
    "OVERLAY_PURCHASE_JAILKEYS",
    "OVERLAY_APPLY_VINYL",
    "OVERLAY_VEHICLE_DETAILS",
    "OVERLAY_PACK_PURCHASE",
    "OVERLAY_EXPAND_INVENTORY_VEHICLE",
    "OVERLAY_EXPAND_INVENTORY_HOUSE",
    "OVERLAY_ERROR",
}

SERVICE_SKIN_LIST = {
    [ 0 ] = { 117, 118, 156, 120, 82 },
    [ 1 ] = { 139, 141, 157, 145 },
}

function FilterOffersBySegment( offers_list, segments, ignore_table_copy )
    local offers_filtered = { }
    
    if not ignore_table_copy then
        offers_list = table.copy( offers_list )
    end

    for i, v in pairs( offers_list ) do
        if v.active_for_all or not v.segment then
            offers_filtered[ v ] = true
        else
            -- Сорри за костыль (нужен для тестовых серверов)
            local offer_segments = v.segments or v.segment
            v.segments = offer_segments
            local segment_type = type( offer_segments )

            if segment_type == "number" then
                v.segment = { offer_segments }
                segment_type = "table"
            end
            
            if segment_type == "table" then
                for n, offer_segment in pairs( offer_segments ) do
                    local required_segment = segments[ v.start_date or 0 ]
                    if required_segment and required_segment == offer_segment then
                        offers_filtered[ v ] = true
                        v.segment = offer_segment
                        break
                    end
                end
            elseif not v.segment then
                offers_filtered[ v ] = true
            end
        end
	end

	local offers_filtered_list = { }
    for i, v in pairs( offers_filtered ) do
        table.insert( offers_filtered_list, i )
	end

    return offers_filtered_list, offers_filtered
end