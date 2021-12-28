loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "ShUtils" )
Extend( "CPlayer" )
Extend( "Globals" )
Extend( "CInterior" )
Extend( "CAI" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )

ibUseRealFonts( true )

local ui = { }
local is_started = nil

function PreRenderCamera( )
    local fProgress = ( getTickCount( ) - is_started ) / 2200

    local cx, cy, cz = interpolateBetween( OFFER_CONFIG.camera.start.x, OFFER_CONFIG.camera.start.y, OFFER_CONFIG.camera.start.z, OFFER_CONFIG.camera.finish.x, OFFER_CONFIG.camera.finish.y, OFFER_CONFIG.camera.finish.z, fProgress, "Linear" )
    setCameraMatrix( cx, cy, cz, OFFER_CONFIG.camera.finish.lx, OFFER_CONFIG.camera.finish.ly, OFFER_CONFIG.camera.finish.lz )

    if fProgress >= 1 then
        removeEventHandler( "onClientRender", root, PreRenderCamera )
        is_started = nil
    end
end

function MoveCameraTo( )
    is_started = getTickCount( )
    removeEventHandler( "onClientRender", root, PreRenderCamera )
	addEventHandler( "onClientRender", root, PreRenderCamera )
end

function CreatePointActiveAssemblyVehicle_handler( )
    local point = TeleportPoint( OFFER_CONFIG.point )
    point.PostJoin = function( ) 
        point:destroy( )
        fadeCamera( false, 1 )

        setTimer( function( )
            fadeCamera( true, 1 )
            triggerServerEvent( "GiveAssemblyVehicleVehicle", resourceRoot )
        end, 2000, 1 )
	end
end

function StartSceneGiveActiveAssemblyVehicle_handler( vehicle )
    MoveCameraTo( )
    setPedVehicleDriveTo( localPlayer, vehicle, OFFER_CONFIG.path.x, OFFER_CONFIG.path.y, OFFER_CONFIG.path.z, OFFER_CONFIG.path.speed_limit, _, _, 1 )
    BlockAllKeys( )
    DisableHUD( true )

    setTimer( function( )
        fadeCamera( false, 1 )
        setTimer( function( )
            fadeCamera( true, 1.5 )
            setCameraTarget( localPlayer )
            UnblockAllKeys( )
            DisableHUD( false )
        end, 1000, 1 )
    end, 4000, 1 )
end
addEvent( "StartSceneGiveActiveAssemblyVehicle", true )
addEventHandler( "StartSceneGiveActiveAssemblyVehicle", resourceRoot, StartSceneGiveActiveAssemblyVehicle_handler )

function CheckActiveAssemblyVehicleByPlace( place )
    if not CheckActiveAssemblyVehicle( ) then return false end
	if place then
		local details_in_inv = localPlayer:InventoryGetItem( IN_ASSEMBLY_VEHICLE )
		return not CheckAssemblyVehicleDetailByIdOrPlace( details_in_inv, place, true ) and not localPlayer:getData( "assembly_vehicle_passed" )
    end
    return false
end

function CheckAssemblyVehicleDetailByIdOrPlace( details_in_inv, detail, is_place )
    if not detail then return end
    local detail_id = is_place and DETAILS_PLACE[ detail ] or detail

	for i = 2, #details_in_inv do
        if details_in_inv[ i ].attributes[ 1 ] == detail_id then
            return true
        end
    end
    return false
end

function ShowOfferAssemblyVehicle_handler( state )
    if state then
        
        ShowOfferFastAssemblyVehicle_handler( )
        ShowOfferAssemblyVehicle_handler( )
        
        local details_in_inv = localPlayer:InventoryGetItem( IN_ASSEMBLY_VEHICLE )
        local assembly_vehicle_passed = localPlayer:getData( "assembly_vehicle_passed" )
		
		ui.black_bg = ibCreateBackground( _, _, true ):ibData( "alpha", 0 )
		ui.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg.png", ui.black_bg ):ibSetRealSize():center( )
		
		ibCreateButton( 971, 28, 24, 24, ui.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowOfferAssemblyVehicle_handler( )
			end, false )
			
		
        ui.time_label = ibCreateLabel( 548, 124, 0, 0, "", ui.bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_16 )
        local offerEndTime = localPlayer:getData( "assembly_vehicle_finish" )

        local function UpdateTimer( )
            ui.time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
        end
        ui.bg:ibTimer( UpdateTimer, 500, 0 )
        UpdateTimer( )

        local assembly_vehicle_part = 0

        -- детали
        for id, detail in pairs( DETAILS_INFO ) do
            ibCreateButton(	detail.x, detail.y, 100, 117 + ( detail.sy or 0 ), ui.bg, "img/" .. detail.type .. ".png", "img/" .. detail.type .. "_h.png", "img/" .. detail.type .. "_h.png" )

            -- получить деталь
            if not CheckAssemblyVehicleDetailByIdOrPlace( details_in_inv, id ) then
                ibCreateButton( detail.x, detail.y + 127 + ( detail.sy or 0 ), 100, 30, ui.bg, "img/btn_receive_i.png", "img/btn_receive_h.png", "img/btn_receive_h.png" ):ibData( "disabled", assembly_vehicle_passed and true or false )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    ShowOfferAssemblyVehicle_handler( )
                    DETAILS_INFO[ id ].show_source( )
                end, false )

                assembly_vehicle_part = assembly_vehicle_part + 1
            else
                ibCreateImage( detail.x + 76, detail.y + 27 + ( detail.sy or 0 ), 14, 12, "img/installed.png", ui.bg )
            end
        end

        -- список деталей
        ibCreateButton(	780, 50, 93, 11, ui.bg, "img/btn_task_i.png", "img/btn_task_h.png", "img/btn_task_h.png" )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            if isElement( ui.info_rt ) then return end
            ShowAssemblyVehicleInfo( true )
        end, false )

        -- собрать машину
        ibCreateButton( 414, 650, 194, 40, ui.bg, "img/btn_build_i.png", "img/btn_build_h.png", "img/btn_build_h.png" ):ibData( "disabled", assembly_vehicle_passed and true or false )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            if isElement( ui.info_rt ) then return end
            if localPlayer:InventoryGetItemCount( IN_ASSEMBLY_VEHICLE ) ~= 6 then
                localPlayer:ShowInfo( "Собери все детали" )
            else
                ShowOfferAssemblyVehicle_handler( )
                CreatePointActiveAssemblyVehicle_handler( )
            end
        end, false )

        -- быстрая сборка
        if localPlayer:InventoryGetItemCount( IN_ASSEMBLY_VEHICLE ) ~= 6 and offerEndTime - getRealTimestamp( ) < 60 * 60 * 24 and not assembly_vehicle_passed then
            ibCreateButton( 407, 570, 210, 50, ui.bg, "img/btn_fast_build_i.png", "img/btn_fast_build_h.png", "img/btn_fast_build_h.png" )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowOfferAssemblyVehicle_handler( )
                ShowOfferFastAssemblyVehicle_handler( true )
            end, false )
        end

		ui.black_bg:ibAlphaTo( 255 )
        showCursor( true )
	else
		if ui.black_bg then
			ShowAssemblyVehicleInfo( )
			destroyElement( ui.black_bg )
			ui = { }
		end
        showCursor( false )
	end
end
addEvent( "ShowOfferAssemblyVehicle", true )
addEventHandler( "ShowOfferAssemblyVehicle", resourceRoot, ShowOfferAssemblyVehicle_handler )

function ShowOfferFastAssemblyVehicle_handler( state )
	if state then
		ShowOfferFastAssemblyVehicle_handler( )
		
		ui.black_bg = ibCreateBackground( _, _, true ):ibData( "alpha", 0 )
		ui.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg_fast.png", ui.black_bg ):ibSetRealSize():center( )
		
		ibCreateButton( 971, 28, 24, 24, ui.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowOfferFastAssemblyVehicle_handler( )
			end, false )
			
		
        ui.time_label = ibCreateLabel( 548, 159, 0, 0, "", ui.bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "top", ibFonts.bold_16 )
        local offerEndTime = localPlayer:getData( "assembly_vehicle_finish" )

        local function UpdateTimer( )
            ui.time_label:ibData( "text", getHumanTimeString( offerEndTime, true ) )
        end
        ui.bg:ibTimer( UpdateTimer, 500, 0 )
        UpdateTimer( )

        ibCreateButton( 430, 634, 160, 56, ui.bg, "img/btn_buy_i.png", "img/btn_buy_h.png", "img/btn_buy_h.png" )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            triggerServerEvent( "BuyAssemblyVehicleDetails", resourceRoot )
        end, false )

        local count_detail = localPlayer:InventoryGetItemCount( IN_ASSEMBLY_VEHICLE )
        local cost =  ( 6 - count_detail ) *  OFFER_CONFIG.cost_hard

        ibCreateLabel( 572, 562, 0, 0, cost, ui.bg, COLOR_WHITE, _, _, "left", "top", ibFonts.bold_30 )

		ui.black_bg:ibAlphaTo( 255 )
        showCursor( true )
	else
		if ui.black_bg then
			ShowAssemblyVehicleInfo( )
			destroyElement( ui.black_bg )
			ui = { }
		end
        showCursor( false )
	end
end
addEvent( "ShowOfferFastAssemblyVehicle", true )
addEventHandler( "ShowOfferFastAssemblyVehicle", resourceRoot, ShowOfferFastAssemblyVehicle_handler )

function ActivateAssemblyVehicle_handler( )
    local finish_date = localPlayer:getData( "assembly_vehicle_finish" )
	triggerEvent( "ShowSplitOfferInfo", root, "assembly_vehicle", finish_date - getRealTimestamp( ) )

    local count_detail = localPlayer:InventoryGetItemCount( IN_ASSEMBLY_VEHICLE )

    if finish_date - getRealTimestamp( ) < 60 * 60 * 24 and count_detail > 0 and count_detail ~= 6 and not localPlayer:getData( "assembly_vehicle_passed" ) then
        ShowOfferFastAssemblyVehicle_handler( true )
    else
	    ShowOfferAssemblyVehicle_handler( true )
    end
end
addEvent( "ActivateAssemblyVehicle", true )
addEventHandler( "ActivateAssemblyVehicle", resourceRoot, ActivateAssemblyVehicle_handler )

function ShowAssemblyVehicleInfo( state )
    if not ui.black_bg then return end

	local sx, sy = 1024, 630

    if state then
        ShowAssemblyVehicleInfo( )

        ui.info_rt = ibCreateRenderTarget( 0, 92, sx, sy, ui.bg ):ibData( "priority", 5 )
        ui.info = ibCreateImage( 0, -sx, sx, sy, "img/info.png", ui.info_rt )
        
		ibCreateButton(	458, 604 - 46, 108, 42, ui.info, "img/btn_hide_i.png", "img/btn_hide_h.png", "img/btn_hide_h.png" )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            ibClick( )
            ShowAssemblyVehicleInfo( )
        end )

        ui.info:ibMoveTo( 0, 0, 300 )
        ibOverlaySound( )
    elseif isElement( ui.info_rt ) then
        ui.info:ibMoveTo( 0, -sy, 300 )
        :ibTimer( function()
            destroyElement( ui.info_rt )
        end, 300, 1 )
        ibOverlaySound( )
    end
end