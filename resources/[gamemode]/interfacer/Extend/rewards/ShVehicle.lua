Import( "ShVehicleConfig" )

REGISTERED_ITEMS.vehicle = {
	available_params = 
	{
		model = { required = true, desc = "ID автомобиля", from_id = true },
		temp_days = { desc = "Срок временной выдачи автомобиля" },
		variant = { desc = "Вариант автомобиля" },
		event_name = { desc = "Имя ивента передаваемого в AddVehicle" },
		color = { desc = "Отображаемый цвет ( унификация )" },
		tuning = { desc = "Любые параметры автомобиля для присвоения после его выдачи" },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 300, 160 },
		{ 600, 316 },
	},

	IsValid = function( self, item )
		local params = item.params or item

		if not VEHICLE_CONFIG[ ( params.id or params.model ) ] then
			return false, "Автомобиль с указанным ID не найден"
		end

		return true
	end,

	Give = function( player, params )
		local vehicles = player:GetVehicles()
		if params.temp_days then
			for _, vehicle in pairs( vehicles ) do
				if ( params.id or params.model ) == vehicle.model then
					local temp_timeout = vehicle:GetPermanentData( "temp_timeout" )
					if temp_timeout and temp_timeout >= getRealTime().timestamp then
						vehicle:SetPermanentData( "temp_timeout", temp_timeout + params.temp_days * 24 * 60 * 60 )
						triggerEvent( "CheckTemporaryVehicle", vehicle )
						return
					end
				end
			end
		else
			for _, vehicle in pairs( vehicles ) do
				local temp_timeout = vehicle:GetPermanentData( "temp_timeout" )
				if ( params.id or params.model ) == vehicle.model and temp_timeout and temp_timeout > 0 then
					exports.nrp_vehicle:DestroyForever( vehicle:GetID( ) )
				end
			end
		end

		local sOwnerPID = "p:" .. player:GetUserID()

		local pRow	= {
			model 		= ( params.id or params.model );
			variant		= params.variant or 1;
			x			= 0;
			y			= 0;
			z			= 0;
			rx			= 0;
			ry			= 0;
			rz			= 0;
			owner_pid	= sOwnerPID;
			color		= { 255, 255, 255 };
			temp_timeout = ( params.temp_days and ( getRealTimestamp( ) + params.temp_days * 24 * 60 * 60 ) )
		}

		if params.tuning then
            for k, v in pairs( params.tuning ) do
                pRow[ k ] = v
            end
        end
		
		exports.nrp_vehicle:AddVehicle( pRow, true, params.event_name or "OnRewardVehicleAdded", { player = player, cost = VEHICLE_CONFIG[ ( params.id or params.model ) ].variants[ params.variant or 1 ].cost, temp_days = params.temp_days, temp_timeout = pRow.temp_timeout } )
	end;

	uiCreateItem = function( id, params, bg, sx, sy )
		local csx, csy = GetBetterRewardContentSize( id, sx, sy )
		local img = ibCreateContentImage( 0, 0, csx, csy, id, ( params.id or params.model ) .. ( params.color and "_" .. params.color or "" ), bg ):center( )
		
		if params.temp_days then
			ibCreateLabel( sx/2, sy*0.85, 0, 0, params.temp_days .." д.", bg ):ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" }):center( 0, 25 )
			img:center( 0, -15 )
		end
		
		return img
	end;
	
	uiCreateRewardItem = function( id, params, bg )
		ibCreateContentImage( 0, 0, 600, 316, id, ( params.id or params.model ) .. ( params.color and "_" .. params.color or "" ), bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		local config = VEHICLE_CONFIG[ ( params.id or params.model ) ]
		local name = config.model
		if config.variants[ 2 ] then
			name = name .. " " .. config.variants[ params.variant or 1 ].mod;
		end
		return {
			title = name;
			reward_title = name .. ( params.temp_days and ( " (на " .. params.temp_days * 24 .." ч)" ) or "" ),
		}
	end;
}

function OnRewardVehicleAdded_handler( vehicle, data )
	if isElement(vehicle) and isElement(data.player) then
		local sOwnerPID = "p:" .. data.player:GetUserID()

		vehicle:SetOwnerPID( sOwnerPID )
		vehicle:SetFuel( "full" )
		vehicle:SetParked( true )
		
		vehicle:SetPermanentData( "showroom_cost", data.cost )
		vehicle:SetPermanentData( "showroom_date", getRealTime().timestamp )
		vehicle:SetPermanentData( "first_owner", sOwnerPID )
		vehicle:SetPermanentData( "temp_timeout", data.temp_timeout )

		triggerEvent( "CheckTemporaryVehicle", vehicle )
		triggerEvent( "CheckPlayerVehiclesSlots", data.player )
	end
end
addEvent( "OnRewardVehicleAdded", true )
addEventHandler( "OnRewardVehicleAdded", resourceRoot, OnRewardVehicleAdded_handler )