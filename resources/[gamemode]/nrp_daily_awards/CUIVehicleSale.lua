loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CVehicle")
Extend("ShVehicleConfig")

local ui = { }

local pBusinessesList = {
	["1"] = Vector3(-1011.702, -1475.423, 21.773),
	["2"] = Vector3(-362.323, -1741.648, 20.917),
	["3"] = Vector3(1782.086, -628.719, 60.852),
	["4"] = Vector3(2047.004, -860.692, 62.649),
}

function ShowUI_VehicleSale( state, data )
	if state then
		ShowUI_VehicleSale( false )

		showCursor(true)

		ui.main = ibCreateImage( 0, 0, 0, 0, "files/img/vehicles/bg.png" ):ibSetRealSize( ):center( )
		ibCreateLabel( 631, 39, 0, 0, data.percent .. "%", ui.main, 0xFFff5b5e ):ibData( "font", ibFonts.bold_16 )

		-- close
		ibCreateButton( 972, 29, 24, 24, ui.main, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function(key, state) 
			if key ~= "left" or state ~= "up" then return end
			ShowUI_VehicleSale( false )
			ibClick()
		end)

		local variant = data.variant or 1
		local vehicleConfig = VEHICLE_CONFIG[ data.model ].variants[ variant ]
		local className = VEHICLE_CLASSES_NAMES[ tostring( data.model ):GetTier( variant ) ]
		local driveType = DRIVE_TYPE_NAMES[ vehicleConfig.handling.driveType ]

		-- img of vehicle
		local image_vehicle_area = ibCreateArea( 340, 400, 0, 0, ui.main )
		local img_path = ":nrp_vehicle_passport/img/vehicles/" .. data.model .. ".png"

		if fileExists( img_path ) then
			ibCreateImage( 0, 0, 0, 0, img_path, image_vehicle_area ):ibSetRealSize( ):center( )
		end

		-- name / class
		ibCreateLabel( 687, 190, 290, 0, VEHICLE_CONFIG[ data.model ].model, ui.main, 0xFFffffff )
		:ibBatchData( { font = ibFonts.bold_24, wordbreak = true } )

		ibCreateLabel( 817, 269, 0, 0, className, ui.main, 0xFFffffff )
		:ibData( "font", ibFonts.regular_16 )

		ibCreateLabel( 906, 269, 0, 0, driveType, ui.main, 0xFFffffff )
		:ibData( "font", ibFonts.regular_16 )

		-- cost
		local old_cost = VEHICLE_CONFIG[ data.model ].variants[ variant ].cost or 0
		local new_cost = math.floor( old_cost * ( 100 - data.percent ) / 100 )

		ibCreateLabel( 885, 538, 0, 0, format_price( new_cost ), ui.main, 0xFFffffff )
		:ibData( "font", ibFonts.bold_20 )
		local old_cost_label = ibCreateLabel( 846, 517, 0, 0, format_price( old_cost ), ui.main, 0xa0ffffff )
		:ibData("font", ibFonts.bold_16 )

		ibCreateImage( 810, 527, old_cost_label:width( ) + 40, 1, nil, ui.main, 0xa0ffffff )

		-- characteristics
		local vPower = vehicleConfig.power
		local vMaxSpeed = vehicleConfig.max_speed
		local vAccelerationTo100 = vehicleConfig.ftc
		local vFuelLoss = vehicleConfig.fuel_loss
		local progressbar_width = 239

		local function getProgressWidth( value, maximum )
			return ( ( value / maximum ) * progressbar_width ) > progressbar_width and progressbar_width or ( value / maximum ) * progressbar_width
		end

		ibCreateLine( 733, 334, 733 , 334, 0xffff965e, 11, ui.main ):ibMoveTo( 733 + getProgressWidth( vPower, 600 ), 334, 800, "InOutQuad" )
		ibCreateLine( 733, 384, 733 , 384, 0xFFFF965D, 11, ui.main ):ibMoveTo( 733 + getProgressWidth( vMaxSpeed, 400 ), 384, 800, "InOutQuad" )
		ibCreateLine( 733, 434, 733 , 434, 0xFFFF965D, 11, ui.main ):ibMoveTo( 733 + getProgressWidth( vAccelerationTo100, 30 ), 434, 800, "InOutQuad" )
		ibCreateLine( 733, 484, 733 , 484, 0xFFFF965D, 11, ui.main ):ibMoveTo( 733 + getProgressWidth( vFuelLoss, 25 ), 484, 800, "InOutQuad" )

		ibCreateLabel( 973, 310, 0, 0, vPower .. " л.с.", ui.main, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
		ibCreateLabel( 973, 360, 0, 0, vMaxSpeed .. " км/ч", ui.main, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
		ibCreateLabel( 973, 410, 0, 0, vAccelerationTo100 .. " сек.", ui.main, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
		ibCreateLabel( 973, 460, 0, 0, vFuelLoss .. " л.", ui.main, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )

		-- timer
		local tick = getTickCount( )
        local label_elements = {
            { 632, 93 },
            { 659, 93 },

            { 707, 93 },
            { 733, 93 },

            { 778, 93 },
            { 806, 93 },
        }

        for i, v in pairs( label_elements ) do
            ui[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ] - 46, v[ 2 ] + 30, 0, 0, "0", ui.main ):ibBatchData( { font = ibFonts.regular_36, align_x = "center", align_y = "center" } )
        end

        local function UpdateTimer( )
            local passed = getTickCount( ) - tick
            local time_diff = math.ceil( data.time_left - passed / 1000 )

            if time_diff < 0 then OFFER_A_LEFT = nil return end

            local hours = math.floor( time_diff / 60 / 60 )
            local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )
            local seconds = math.floor( ( ( time_diff - hours * 60 * 60 ) - minutes * 60 ) )

            if hours > 99 then minutes = 60; seconds = 0 end

            hours = string.format( "%02d", math.min( hours, 99 ) )
            minutes = string.format( "%02d", math.min( minutes, 60 ) )
            seconds = string.format( "%02d", seconds )

            local str = hours .. minutes .. seconds

            for i = 1, #label_elements do
                local element = ui[ "tick_num_" .. i ]
                if isElement( element ) then
                    element:ibData( "text", utf8.sub( str, i, i ) )
                end
            end
        end
        ui.timer = Timer( UpdateTimer, 500, 0 )
        UpdateTimer( )

		-- gps
		ibCreateButton( 0, 615, 220, 44, ui.main, "files/img/vehicles/btn_gps.png", "files/img/vehicles/btn_gps.png", "files/img/vehicles/btn_gps.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:center_x( ):ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			local market_id = VEHICLE_CONFIG[ data.model ] and VEHICLE_CONFIG[ data.model ].marketlist or "all"
			local vec_gps = nil


			if market_id == "all" then
				local iClosestID, iMinDistance = "1", math.huge
				for k,v in pairs( pBusinessesList ) do
					local distance = (localPlayer.position - v).length

					if distance <= iMinDistance then
						iMinDistance = distance
						iClosestID = k
					end
				end

				vec_gps = pBusinessesList[iClosestID]
			else
				vec_gps = pBusinessesList[market_id]
			end

			triggerEvent( "ToggleGPS", localPlayer, vec_gps )

			ShowUI_VehicleSale( false )
			ibClick()
		end)
	else
		if isElement(ui.main) then
			destroyElement( ui.main )
		end

		if isTimer(ui.timer) then
			killTimer( ui.timer )
		end

		showCursor( false )
	end
end
addEvent("ShowUI_VehicleSale", true)
addEventHandler("ShowUI_VehicleSale", resourceRoot, ShowUI_VehicleSale)
-- crun triggerEvent("ShowUI_VehicleSale", getResourceRootElement(getResourceFromName("nrp_daily_awards")), true, {model = 6579,percent = 15,time_left = 3600})

function GetStatsFromModel( model )
	local conf = VEHICLE_CONFIG[ model ] and VEHICLE_CONFIG[ model ].variants[1]
	if conf then
		return { conf.stats_speed, conf.stats_acceleration, conf.stats_handling }
	end
end

--ShowUI_VehicleSale( true, { model = 424, percent = 20, time_left = 6000 } )