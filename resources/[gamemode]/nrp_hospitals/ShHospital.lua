HOSPITALS_LIST =
{
	{
		-- Ид больницы.
		iID = 1,

		-- Маркер входа внутрь
		position = Vector3(398.762, -2450.387, 23.5),

		-- Маркер выхода на улицу
		vecExit = Vector3(442.67, -1608.3, 1020.96),

		interior = 1,

		dimension = 1,

		-- Респавны по умолчанию если койки заняты.
		tDefaultRespawns =
		{
			{ position = Vector3( 457.8, -1598.5, 1020.97 ), rotation = 0.0, dimension = 1, interior = 1 },
			{ position = Vector3( 464.5, -1598.5, 1020.97 ), rotation = 0.0, dimension = 1, interior = 1 },
		},

		-- Койки.
		tBeds =
		{
			--{ position = Vector3( 455.927734, -1599.908203, 1021.523865 - 1.5 ), rotation = 90 };
			--{ position = Vector3( 456.038086, -1596.310547, 1021.602966 - 1.5 ), rotation = 90 };
			{ position = Vector3( 460.163086, -1599.820312, 1021.539307 - 1.5 ), rotation = 90 };
			{ position = Vector3( 460.140625, -1596.530273, 1021.602966 - 1.5 ), rotation = 90 };

			--{ position = Vector3( 462.629883, -1599.686523, 1021.524353 - 1.5 ), rotation = 90 };
			--{ position = Vector3( 462.544922, -1596.659180, 1021.533508 - 1.5 ), rotation = 90 };
			{ position = Vector3( 466.819336, -1596.401367, 1021.525146 - 1.5 ), rotation = 90 };
			{ position = Vector3( 466.877930, -1599.644531, 1021.520020 - 1.5 ), rotation = 90 };
		},

		tNoColZones = {
			 { x = 463.130, y = -1598.943, z = 1020.968, radius = 10 },
		},

		iFaction = false, -- enum фракции, если это фракционный.
	},

	{
		-- Ид больницы.
		iID = 2,

		-- Маркер входа внутрь
		position = Vector3( 1877.856, -528.05, 60.791 ),

		-- Маркер выхода на улицу
		vecExit = Vector3(1936.94, 302.77, 660.97),

		interior = 1,

		dimension = 1,

		-- Респавны по умолчанию если койки заняты.
		tDefaultRespawns =
		{
			{ position = Vector3( 1958.727539, 313.017578, 660.966492 ), rotation = 0.0, dimension = 1, interior = 1 },
            { position = Vector3( 1952.251953, 312.833008, 660.966492 ), rotation = 0.0, dimension = 1, interior = 1 },
		},

		-- Койки.
		tBeds =
		{
			{ position = Vector3( 1956.843750, 311.367188, 661.526794 - 1.5 ), rotation = 90 },
            { position = Vector3( 1960.953125, 311.372070, 661.523621 - 1.5 ), rotation = 90 },
            { position = Vector3( 1956.566406, 314.612305, 661.519775 - 1.5 ), rotation = 90 },
            { position = Vector3( 1960.989258, 314.366211, 661.535217 - 1.5 ), rotation = 90 },

            { position = Vector3( 1954.383789, 311.490234, 661.529419 - 1.5 ), rotation = 90 },
            { position = Vector3( 1950.184570, 311.416992, 661.521912 - 1.5 ), rotation = 90 },
            { position = Vector3( 1950.076172, 314.399414, 661.530457 - 1.5 ), rotation = 90 },
            --{ position = Vector3( 1954.386719, 314.624023, 661.612305 - 1.5 ), rotation = 90 },
		},

		tNoColZones = {
			{ x = 1956.532, y = 313.075, z = 660.966,  radius = 10 },
		},

		iFaction = false, -- enum фракции, если это фракционный.
	},

	{
		-- Ид больницы.
		iID = 3,

		-- Маркер входа внутрь
		position = Vector3( 1422.3211669922, 2722.2119140625, 10.910400390625 ),

		-- Маркер выхода на улицу
		vecExit = Vector3( -1995.098, 1989.576, 1797.890 ),

		interior = 2,

		dimension = 2,

		-- Респавны по умолчанию если койки заняты.
		tDefaultRespawns =
		{
			{ position = Vector3( -2018.129, 2008.942, 1797.890 ), rotation = 180.0, dimension = 2, interior = 2 },
			{ position = Vector3( -2012.492, 2009.743, 1797.890 ), rotation = 180.0, dimension = 2, interior = 2 },
			{ position = Vector3( -2006.000, 2008.072, 1797.890 ), rotation = 180.0, dimension = 2, interior = 2 },
			{ position = Vector3( -1998.427, 2008.325, 1797.890 ), rotation = 180.0, dimension = 2, interior = 2 },
		},

		tNoColZones = {
			{ x = -1974.308, y = 2000.305, z = 1797.886,  radius = 10 },
		},

		iFaction = false, -- enum фракции, если это фракционный.
	}
}
