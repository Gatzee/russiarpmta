loadstring( exports.interfacer:extend( "Interfacer" ) )( )

CONST_OFFICE_BUILD_ENTER_POSITIONS = {
	[ 1 ] = Vector3( 395.4154, -1433.1344 + 860, 21.65 );
}

CONST_OFFICE_INTERIOR_EXIT_POSITIONS = {
	[ 1 ] = Vector3( -2.128, -4.559, 915.497 );
	[ 2 ] = Vector3( 2.418, -657.719, 2267.757 );
	[ 3 ] = Vector3( -103.402, -2463.578, 4406.249 );
}

CONST_OFFICE_INTERIOR_CONTROL_POSITIONS = {
	[ 1 ] = Vector3( -7.381, 4.826, 915.497 );
	[ 2 ] = Vector3( 18.024, -661.483, 2267.757 );
	[ 3 ] = Vector3( -92.817, -2485.044, 4406.265 );
}

CONST_OFFICE_SECRETARY = {
	[ 1 ] = {
		ped_position = Vector3( 4.45, 2.153, 915.497 );
		ped_rotation = 90;

		marker_position = Vector3( 2.7, 2.090, 915.497 );
	};
	[ 2 ] = {
		ped_position = Vector3( 17.820, -653.684, 2267.758 );
		ped_rotation = 53;

		marker_position = Vector3( 16.192, -653.472, 2267.758 );
	};
	[ 3 ] = {
		ped_position = Vector3( -102.788, -2478.819, 4406.265 );
		ped_rotation = 8;

		marker_position = Vector3( -103.35, -2477.03, 4406.265 );
	};
}

CONST_OFFICE_SECRETARY_MODELS = {
	[ 1 ] = 106;
	[ 2 ] = 132;
	[ 3 ] = 135;
	[ 4 ] = 178;
}

CONST_FOOD_LIST = {
    { name = "Гематоген", calories = 4, cost = 50 },
    { name = "Квас 0,5л", calories = 12, cost = 120 },
    { name = "Чебурек кошачий", calories = 15, cost = 150 },
    { name = "Кисель с ватрушкой", calories = 19, cost = 180 },
    { name = "Молоко с батоном", calories = 22, cost = 220 },
    { name = "Беляш из барашек", calories = 28, cost = 240 },
    { name = "Шаверма", calories = 35, cost = 300 },
    { name = "Ланч с собой", calories = 50, cost = 1250, inventory = true },
}

CONST_MEDS_LIST = {
    { name = "Аспирин", health = 9, cost = 110 },
    { name = "Парацетамол", health = 15, cost = 130 },
    { name = "Ибупрофен", health = 20, cost = 150 },
    { name = "Анальгин", health = 25, cost = 240 },
    { name = "Адреналин", health = 33, cost = 280 },
}

CONST_OFFICE_PAY_AMOUNT = {
	[ 1 ] = 10000;
	[ 2 ] = 15000;
	[ 3 ] = 30000;
}