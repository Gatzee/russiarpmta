loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SDB")

local CONST_SERVER = ("PROD" ) .."_"..101
local CURRENT_ECONOMY_DATA = {
	courier = {
		[1] = { 252, 9 };
		[2] = { 758, 23 };
		[3] = { 845, 24 };
		[4] = { 931, 25 };
	};
	loader = {
		[1] = { 147, 5 };
		[2] = { 275, 8 };
		[3] = { 378, 17 };
		[4] = { 469, 25 };
	};
	driver = {
		[1] = { 0.96, 0.036 };
		[2] = { 1.18, 0.043 };
		[3] = { 1.26, 0.045 };

		[4] = { 0.98, 0.043 };
		[5] = { 1.00, 0.058 };
		[6] = { 1.20, 0.05 };
	};
	trucker = {
		[1] = { 1.9, 0.099 };
		[2] = { 2.2, 0.1027 };
		[3] = { 2.7, 0 };
	};

	taxi = {
		[1] = { 1472, 57 };
		[2] = { 1787, 61 };
		[3] = { 1795, 64 };
	};

	pilot = {
		[1] = { 1472, 57 };
		[2] = { 1787, 61 };
		[3] = { 1795, 64 };
	};

	park_employee = {
		[1] = { 6000, 5 };
		[2] = { 15000, 10 };
		[3] = { 25000, 13 };
	};

	woodcutter = {
		[1] = { 80000, 27 };
		[2] = { 105000, 31 };
		[3] = { 145000, 40 };
	};
	
	towtrucker = {
		[1] = { 6786, 329 };
		[2] = { 7500, 371 };
		[3] = { 8571, 414 };
	};

	incasator = {
		[1] = { 6786, 329 };
		[2] = { 7500, 371 };
		[3] = { 8571, 414 };
	};

	trashman = {
		[1] = { 6786, 329 };
		[2] = { 7500, 371 };
		[3] = { 8571, 414 };
	};

	delivery_cars = {
		[1] = { 3295, 169 };
		[2] = { 4215, 192 };
		[3] = { 5594, 421 };
	};

	industrial_fishing = {
		[1] = { 22513, 1466 };
		[2] = { 28796, 1649 };
		[3] = { 36649, 3037 };
	};

	hijack_cars = {
		[1] = { 3368, 164 };
		[2] = { 4102, 203 };
		[3] = { 5095, 302 };
	};
}

local CONST_CLASS_TO_ID_LEVEL = {
	-- Курьер
	courier_base      = { "courier", 1 };
	courier_company_1 = { "courier", 2 };
	courier_company_2 = { "courier", 3 };
	courier_company_3 = { "courier", 4 };

	-- Грузчик
	loader_base      = { "loader", 1 };
	loader_company_1 = { "loader", 2 };
	loader_company_2 = { "loader", 3 };
	loader_company_3 = { "loader", 4 };

	-- Водитель
	driver_company_1 = { "driver", 1 };
	driver_company_2 = { "driver", 2 };
	driver_company_3 = { "driver", 3 };

	-- Дальнобойщик
	trucker_company_1 = { "trucker", 1 };
	trucker_company_2 = { "trucker", 2 };
	trucker_company_3 = { "trucker", 3 };

	-- Таксист
	taxi_company_1 = { "taxi", 1 };
	taxi_company_2 = { "taxi", 2 };
	taxi_company_3 = { "taxi", 3 };

	-- Фермер
	farmer_helper    = { "farmer", 1 };
	farmer_company_1 = { "farmer", 2 };
	farmer_company_2 = { "farmer", 3 };
	farmer_company_3 = { "farmer", 4 };

	-- Таксист частник
	taxi_private_1 = { "taxi_private", 1 };
	taxi_private_2 = { "taxi_private", 2 };
	taxi_private_3 = { "taxi_private", 3 };
	taxi_private_4 = { "taxi_private", 4 };
	taxi_private_5 = { "taxi_private", 5 };

	-- Пилот
	pilot_company_1 = { "pilot", 1 };
	pilot_company_2 = { "pilot", 2 };
	pilot_company_3 = { "pilot", 3 };

	-- Механик
	mechanic_company_1 = { "mechanic", 1 };
	mechanic_company_2 = { "mechanic", 2 };
	mechanic_company_3 = { "mechanic", 3 };

	--Сотрудник парка
	park_employee_company_1 = { "park_employee", 1 };
	park_employee_company_2 = { "park_employee", 2 };
	park_employee_company_3 = { "park_employee", 3 };

	--Дровосек
	woodcutter_company_1 = { "woodcutter", 1 };
	woodcutter_company_2 = { "woodcutter", 2 };
	woodcutter_company_3 = { "woodcutter", 3 };
	
	-- ЖКХ
	hcs_company_1 = { "hcs", 1 };
	hcs_company_2 = { "hcs", 2 };
	hcs_company_3 = { "hcs", 3 };

	--Эвакуаторщик
	tow_company_1 = { "towtrucker", 1 };
	tow_company_2 = { "towtrucker", 2 };
	tow_company_3 = { "towtrucker", 3 };

	--Инкассатор
	incasator_company_1 = { "incasator", 1 };
	incasator_company_2 = { "incasator", 2 };
	incasator_company_3 = { "incasator", 3 };

	--Мусорщик
	trashman_company_1 = { "trashman", 1 };
	trashman_company_2 = { "trashman", 2 };
	trashman_company_3 = { "trashman", 3 };

	--Мусорщик
	delivery_cars_company_1 = { "delivery_cars", 1 };
	delivery_cars_company_2 = { "delivery_cars", 2 };
	delivery_cars_company_3 = { "delivery_cars", 3 };

	--Промышленная рыбалка
	industrial_fishing_company_1 = { "industrial_fishing", 1 };
	industrial_fishing_company_2 = { "industrial_fishing", 2 };
	industrial_fishing_company_3 = { "industrial_fishing", 3 };

	-- Угон ТС
	hijack_cars_company_1 = { "hijack_cars", 1 };
	hijack_cars_company_2 = { "hijack_cars", 2 };
	hijack_cars_company_3 = { "hijack_cars", 3 };
}

function UpdateEconomyData( )
	local db_result = MariaGet( "economy" )
	local economy_data = db_result and fromJSON( db_result ) or { }

	CURRENT_ECONOMY_DATA = ( economy_data.custom_servers and economy_data.custom_servers[ CONST_SERVER ] or economy_data.global ) or CURRENT_ECONOMY_DATA
end
addEventHandler( "onResourceStart", resourceRoot, UpdateEconomyData )

function GetEconomyJobData( job_id, job_level )
	UpdateEconomyData( )
	if not job_level then
		if CONST_CLASS_TO_ID_LEVEL[ job_id ] then
			job_id, job_level = unpack( CONST_CLASS_TO_ID_LEVEL[ job_id ] )
		end
	end

	if CURRENT_ECONOMY_DATA[ job_id ] then
		return unpack( CURRENT_ECONOMY_DATA[ job_id ][ job_level ] )
	end
end