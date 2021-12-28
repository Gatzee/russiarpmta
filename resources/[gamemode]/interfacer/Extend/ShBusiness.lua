--[[
	business_elements: ( элементы, где создаются и т.д )
	id
	business_id		-- ID бизнеса
	building_type	-- Тип здания (атм, заправка )
	x float
	y float
	z float
	dimension
	interior
	object			-- Если это объект, а не метка.
	data text		-- Экстра данные.
]]

BUSINESS_TYPE_GAS_STATION = 1
BUSINESS_TYPE_CAR_REPAIR = 2
BUSINESS_TYPE_CAR_TUNING = 3
BUSINESS_TYPE_CAR_SHOWROOM = 4
BUSINESS_TYPE_ATM = 6
BUSINESS_TYPE_DRIVESCHOOL = 7
BUSINESS_TYPE_CAR_SELL = 8
BUSINESS_TYPE_BOUTIQUE = 9
BUSINESS_TYPE_CAR_NUMBERS = 10
BUSINESS_TYPE_CAR_SERVICE_SHOWROOM = 11


BUSINESS_ELEMENTS = {
	-- Заправка
	-- НСК
	{ business_id = 1, building_type = "gas", x = 534, y = -1636.5, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 534, y = -1636.5, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 534, y = -1636.5, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 534, y = -1630, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 534, y = -1643, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 585, y = -2038.5, z = 20.72, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 579.2, y = -2038.5, z = 20.72, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 573, y = -2038.5, z = 20.72, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 95.5, y = -2628.41, z = 20.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 108.8, y = -2623.7, z = 20.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 102.09, y = -2625.6, z = 20.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 135, y = -2416.2, z = 20.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 143.5, y = -2416.2, z = 20.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 140, y = -2416.2, z = 20.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 131.3, y = -2416.2, z = 20.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -504.9, y = -1825.5, z = 20.8, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -504.9, y = -1820, z = 20.8, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -442, y = -1656.3, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -448, y = -1656.6, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -1077.5, y = -498.3, z = 22.29, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -1045.81, y = -372.11, z = 22.29, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -1462.91, y = -142.3, z = 19.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -1513.5, y = -236.21, z = 19.5, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -2097.155, y = 239.348, z = 18.76, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -2104.486, y = 238.718, z = 18.76, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -2147.134, y = 140.242, z = 18.761, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -2154.645, y = 140.805, z = 18.761, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -2163.504, y = 141.342, z = 18.761, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -2699.9, y = -718.7, z = 19, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -2756.2, y = -751.1, z = 19, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -2416.61, y = -1603.6, z = 26.15, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -1959.2, y = -1962, z = 20.5, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -1971.31, y = -1899.81, z = 20.5, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	-- Горки
	{ business_id = 1, building_type = "gas", x = 2280.27, y = -691.78, z = 60.62, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 2274.21, y = -675.94, z = 60.62, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 2277.2, y = -683.71001, z = 60.62, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 1751.99, y = -1907.6, z = 39.13, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 1768.21, y = -1845.69, z = 38.9, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 1767.16, y = -1852, z = 38.9, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 1868.77, y = -730.23, z = 60.71, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 1753.38, y = -1900.9, z = 39.13, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 1568.35, y = -430.86001, z = 36.78, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 1872.78, y = -737.98, z = 60.71, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 1573.45, y = -434.31001, z = 36.78, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 1645.6, y = -254.03998, z = 27.28, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 1652.37, y = -254.03998, z = 27.28, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 1769.55, y = -1839.19, z = 38.9, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 1638.77, y = -254.03998, z = 27.28, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 1580.1753, y = -550.545, z = 36.69, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 1586.1071, y = -552.639, z = 36.69, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 1751.08, y = -1913.58, z = 39.13, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	-- Подмосковье
	{ business_id = 1, building_type = "gas", x = 412.319, y = -661.126, z = 20.701, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 406.039, y = -661.392, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 418.219, y = -659.751, z = 20.701, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 463.849, y = -163.378, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = 462.155, y = -157.849, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -56.16, y = 455.702, z = 20.698, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -55.633, y = 461.952, z = 20.706, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -630.618, y = 231.35, z = 20.699, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -623.986, y = 231.173, z = 20.699, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -1037.141, y = 1118.505, z = 20.699, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "gas", x = -1038.709, y = 1112.513, z = 20.699, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1,	building_type = "gas",	x = 548.12, y = 493.33, z = 20.69,	rotation = nil,	dimension = nil,	interior = nil,	object = "No",	data = nil  },
	{ business_id = 1,	building_type = "gas",	x = 545.58, y = 498.76, z = 20.69,	rotation = nil,	dimension = nil,	interior = nil,	object = "No",	data = nil  },
	-- МСК
--[[	{ business_id = 1,	building_type = "gas",	x = -1405.54, y = 2778.71, z = 15.13,	rotation = nil,	dimension = nil,	interior = nil,	object = "No",	data = nil  },
	{ business_id = 1,	building_type = "gas",	x = -1410.59, y = 2778.66, z = 15.13,	rotation = nil,	dimension = nil,	interior = nil,	object = "No",	data = nil  },
	{ business_id = 1,	building_type = "gas",	x = -1415.5, y = 2778.74, z = 15.13,	rotation = nil,	dimension = nil,	interior = nil,	object = "No",	data = nil  },
	{ business_id = 1,	building_type = "gas",	name = "ОАО 'НекстНефть'", x = 1683.136, y = 2609.657, z = 8.150,	rotation = nil,	dimension = nil,	interior = nil,	object = "No",	data = nil  },
	{ business_id = 1,	building_type = "gas",	name = "ОАО 'НекстНефть'", x = 1667.384, y = 2609.507, z = 8.148,	rotation = nil,	dimension = nil,	interior = nil,	object = "No",	data = nil  },
	{ business_id = 1,	building_type = "gas",	name = "ОАО 'НекстНефть'", x = 1667.107, y = 2602.349, z = 8.099,	rotation = nil,	dimension = nil,	interior = nil,	object = "No",	data = nil  },
	{ business_id = 1,	building_type = "gas",	name = "ОАО 'НекстНефть'", x = 1683.146, y = 2602.063, z = 8.116,	rotation = nil,	dimension = nil,	interior = nil,	object = "No",	data = nil  },
	{ business_id = 1, 	building_type = "electro", name = "ОАО 'НекстНефть'", icon = "img/yellow.png", x = 1689.19, y = 2596.82, z = 8.09, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil, color = { 196, 199, 0, 50 } },
	{ business_id = 1, 	building_type = "electro", name = "ОАО 'НекстНефть'", icon = "img/yellow.png", x = 1694.69, y = 2596.94, z = 8.09, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil, color = { 196, 199, 0, 50 } },
	{ business_id = 1,	building_type = "gas",	name = "ОАО 'НекстНефть'", x = -276.893, y = 2838.297, z = 15.133,	rotation = nil,	dimension = nil,	interior = nil,	object = "No",	data = nil  },
	{ business_id = 1,	building_type = "gas",	name = "ОАО 'НекстНефть'", x = -260.780, y = 2840.119, z = 15.133,	rotation = nil,	dimension = nil,	interior = nil,	object = "No",	data = nil  },
	{ business_id = 1,	building_type = "gas",	name = "ОАО 'НекстНефть'", x = -261.436, y = 2847.411, z = 15.141,	rotation = nil,	dimension = nil,	interior = nil,	object = "No",	data = nil  },
	{ business_id = 1,	building_type = "gas",	name = "ОАО 'НекстНефть'", x = -277.563, y = 2845.599, z = 15.133,	rotation = nil,	dimension = nil,	interior = nil,	object = "No",	data = nil  },
	{ business_id = 1, 	building_type = "electro", name = "ОАО 'НекстНефть'", icon = "img/yellow.png", x = -285.27, y = 2850.2, z = 15.13, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil, color = { 196, 199, 0, 50 } },
	{ business_id = 1, 	building_type = "electro", name = "ОАО 'НекстНефть'", icon = "img/yellow.png", x = -289.39, y = 2849.68, z = 15.13, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil, color = { 196, 199, 0, 50 } },
	{ business_id = 1,	building_type = "gas",	name = "ОАО 'НекстНефть'", x = 1058.765, y = 2602.247, z = 10.297,	rotation = nil,	dimension = nil,	interior = nil,	object = "No",	data = nil  },
	{ business_id = 1,	building_type = "gas",	name = "ОАО 'НекстНефть'", x = 1058.598, y = 2618.275, z = 10.305,	rotation = nil,	dimension = nil,	interior = nil,	object = "No",	data = nil  },
	{ business_id = 1,	building_type = "gas",	name = "ОАО 'НекстНефть'", x = 1052.261, y = 2618.477, z = 10.305,	rotation = nil,	dimension = nil,	interior = nil,	object = "No",	data = nil  },
	{ business_id = 1,	building_type = "gas",	name = "ОАО 'НекстНефть'", x = 1052.334, y = 2602.584, z = 10.305,	rotation = nil,	dimension = nil,	interior = nil,	object = "No",	data = nil  },
	{ business_id = 1, 	building_type = "electro", name = "ОАО 'НекстНефть'", icon = "img/yellow.png", x = 1064.54, y = 2630.03, z = 10.3, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil, color = { 196, 199, 0, 50 } },
	{ business_id = 1, 	building_type = "electro", name = "ОАО 'НекстНефть'", icon = "img/yellow.png", x = 1064.65, y = 2624.75, z = 10.3, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil, color = { 196, 199, 0, 50 } },]]

	-- Канистра
	-- НСК
	{ business_id = 1, building_type = "jerry", x = 546.9, y = -1642.21, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = -432.3, y = -1655.71, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = -505, y = -1835.8, z = 20.79, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = 573.5, y = -2051.31, z = 20.79, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = 101.59, y = -2639.7, z = 20.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = -1957.00854, y = -1971.113, z = 20.65, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = -1973.2774658203, y = -1890.99621, z = 20.55, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = -2407.31, y = -1600.91, z = 26.1, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = -2769.9, y = -752.41, z = 18.79, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = -2686.4, y = -716.5, z = 18.79, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = -2081.7, y = 252.98, z = 18.76, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = -2171.89, y = 129.26, z = 18.76, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = -1464.21, y = -132.99, z = 19.55, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = -1511.83, y = -245.17, z = 19.54, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = -1087.17, y = -497.62, z = 22.34, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = -1036.95, y = -369, z = 22.34, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = 1595.21, y = -556.01, z = 36.68, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = 125.261, y = -2428.493, z = 20.601, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	-- Горки
	{ business_id = 1, building_type = "jerry", x = 2266.6101, y = -687.44, z = 60.62, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = 1857.89, y = -734.27, z = 60.71, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = 1758.34, y = -1917.55, z = 39.13, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = 1778.13, y = -1838.97998, z = 38.9, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = 1561, y = -425.4, z = 36.77, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = 1653.71, y = -242.81, z = 27.27, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	-- Подмосковье
	{ business_id = 1, building_type = "jerry", x = 402.786, y = -661.395, z = 20.701, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = 465.393, y = -173.15, z = 20.706, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = -1035.151, y = 1127.78, z = 20.699, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = -639.898, y = 231.055, z = 20.699, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = -57.83, y = 446.21, z = 20.698, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", x = 543.32, y = 507.18, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	-- МСК
	--[[{ business_id = 1, building_type = "jerry", x = -1410.637, y = 2767.140, z = 15.13, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", title = "НекстНефть", x = 1675.1, y = 2598.5, z = 8.09, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", title = "НекстНефть", x = -268.2, y = 2851, z = 15.13, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 1, building_type = "jerry", title = "НекстНефть", x = 1063.117, y = 2610.492, z = 10.296, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },]]


	-- Автосервис
	-- НСК
	{ business_id = 2, building_type = "nil", x = 168.5, y = -2427.6, z = 20.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 299.89, y = -2071.7, z = 20.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 525.5, y = -1665, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 548, y = -2051.5, z = 20.72, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = -2392.71, y = -1632.3, z = 26.39, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = -1990.3, y = -1983.6, z = 20.79, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 163.5, y = -2427.41, z = 20.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 158.1, y = -2427.31, z = 20.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 299.79, y = -2077.1, z = 20.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 299.79, y = -2082.81, z = 20.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = -476, y = -1851.8, z = 20.75, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = -482.21, y = -1851.8, z = 20.75, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = -487, y = -1851.6, z = 20.75, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 520.5, y = -1665, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 558.5, y = -2051.5, z = 20.72, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 553.29, y = -2051.5, z = 20.72, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = -2394.2, y = -1627.41, z = 26.5, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = -2390.9, y = -1637.8, z = 26.5, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = -1995.1, y = -1984.91, z = 20.5, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = -1984.41, y = -1982.31, z = 20.5, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	-- Горки
	{ business_id = 2, building_type = "nil", x = 1794.1899, y = -699.98, z = 60.67, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 2107.71, y = -622.88, z = 60.62, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 2111.55, y = -619.57001, z = 60.62, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 2090.53, y = -642.13, z = 60.63, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 1824.35, y = -698.88, z = 60.68, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 1789.05, y = -700.50999, z = 60.67, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 1665.54, y = -247.79999, z = 27.19, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 1670.72, y = -247.72998, z = 27.15, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 1561.9399, y = -1512.26001, z = 29.5, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 1567.0699, y = -1512.40002, z = 29.5, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 2215.8301, y = -1238.44, z = 60.66, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 2193.3701, y = -1249.57001, z = 60.65, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 2190.6899, y = -1245.06, z = 60.66, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	-- Подмосковье
	{ business_id = 2, building_type = "nil", x = 486.59, y = -163.718, z = 20.701, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = 489.376, y = -174.71, z = 20.701, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = -704.945, y = 400.045, z = 20.698, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = -697.503, y = 407.352, z = 20.698, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = -1326.042, y = 1170.251, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = "nil", x = -1315.557, y = 1168.526, z = 20.701, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = nil, x = 569.12, y = 451.75, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = nil, x = 570.32, y = 447.1, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	-- МСК
	--[[{ business_id = 2, building_type = nil, x = -1025.64, y = 2248.97, z = 16.15, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = nil, x = -1021.4, y = 2246.69, z = 16.14, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = nil, x = -1017.48, y = 2244.02, z = 16.14, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = nil, x = -998.11, y = 2255.3, z = 16.14, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = nil, x = -370.7, y = 2764.93, z = 14.93, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = nil, x = -364.24, y = 2760.12, z = 14.93, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = nil, x = -357.05, y = 2755.17, z = 14.93, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = nil, x = -349.77, y = 2750.14, z = 14.92, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = nil, x = 1596.78, y = 2586.6, z = 9.79, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = nil, x = 1597.07, y = 2591.26, z = 9.79, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = nil, x = 1596.97, y = 2596.19, z = 9.79, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 2, building_type = nil, x = 1577.71, y = 2607.12, z = 9.79, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },]]

	-- Тюнинг
	-- НСК
	{ business_id = 3, building_type = "nil", x = 176, y = -2423.2, z = 20.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 3, building_type = "nil", x = 177, y = -2409.3, z = 20.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 3, building_type = "nil", x = 536.5, y = -1668, z = 20.75, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 3, building_type = "nil", x = 543.29, y = -1667.91, z = 20.75, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 3, building_type = "nil", x = 176.7, y = -2416.31, z = 20.6, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 3, building_type = "nil", x = 550.5, y = -1668.1, z = 20.75, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	-- Горки
	{ business_id = 3, building_type = "nil", x = 1817.46, y = -699.23, z = 60.67, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 3, building_type = "nil", x = 2101.8101, y = -634.13, z = 60.62, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 3, building_type = "nil", x = 2096.3101, y = -638.34, z = 60.62, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 3, building_type = "nil", x = 2210.3999, y = -1242.76999, z = 60.65, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 3, building_type = "nil", x = 2205.8899, y = -1248.13, z = 60.64, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 3, building_type = "nil", x = 1810.34, y = -699.44, z = 60.67, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	-- МСК
	--[[{ business_id = 3, building_type = nil, x = 1119.91, y = 2505.29, z = 11.37, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 3, building_type = nil, x = 1103.96, y = 2505.36, z = 11.37, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 3, building_type = nil, x = -1011.516, y = 2392.894, z = 17.96, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },
	{ business_id = 3, building_type = nil, x = -1005.013, y = 2408.140, z = 17.96, rotation = nil, dimension = nil, interior = nil, object = "No", data = nil },]]

	-- Автосалон LADA
	{ business_id = 4,	building_type = "pay",	x = -1011.702, 	y = -1475.423, 	z = 21.773,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = { assortment = 1, veh_spot = { -1016.002, -1480.410, 21.5}, veh_spawn = {-988.315, -1492.753, 20.887} }, gps_marker = {-1011.6, -1491.2, 20.9}, blip = 29 },
	-- Автосалон Toyota
	{ business_id = 4,	building_type = "pay",	x = -362.323, 	y = -1741.648, 	z = 20.917,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = { assortment = 2, veh_spot = {-372.159, -1743.672, 20.917}, veh_spawn = {-355.926, -1769.467, 20.771} }, gps_marker = {-362.7, -1755.8, 20.8}, blip = 29 },
	-- Автосалон Mercedes в Горках
	{ business_id = 4,	building_type = "pay",	x = 1782.086, 	y = -628.719, 	z = 60.852,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = { assortment = 3, veh_spot = {1781.807, -637.083, 60.852}, veh_spawn = {1794.666, -602.92, 60.697} }, gps_marker = {1794, -625.5, 60.7}, blip = 28 },
	-- Автосалон Lamborghini в Горках
	{ business_id = 4,	building_type = "pay",	x = 2047.004, 	y = -806.692, 	z = 62.649,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = { assortment = 4, veh_spot = {2058.045, -787.029, 62.3}, veh_spawn = {2013.100, -769.606, 60.649} }, gps_marker = {2026.3, -790, 60.6}, blip = 28 },
	-- Автосалон в МСК
	--{ business_id = 4,	building_type = "pay",	x = 1227.788, 	y = 2488.171, 	z = 11.11,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = { assortment = 5, veh_spot = {1227.606, 2485.464, 16.704}, veh_spawn = {1193.04, 2501.78, 11.04} }, gps_marker = {1242.287, 2466.162, 11.046}, blip = 28 },

	-- Мотосалон
	{ business_id = 4,	building_type = "pay",	x = -256.490, 	y = -1901.199, 	z = 20.802,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = { assortment = 8, veh_spot = { -252.607, -1909.772, 20.370 }, veh_spawn = { -214.686, -1908.643, 20.370 } }, gps_marker = { -256.490, -1901.199, 20.802 }, blip = 30, marker_text = "Мотосалон", marker_image = "img/moto_shop_icon.png", only_special = true },

	-- Продажа транспорта государству
	{ business_id = 4,	building_type = "sell",	x = 504.983, y = -2050.903, z = 20.754, rotation = nil,	dimension = nil, interior = nil, object = nil, data = { blip = 28 } },
	{ business_id = 4,	building_type = "sell",	x = 4.2, y = 407.1, z = 20.7, rotation = nil, dimension = nil, interior = nil, object = nil, data = { blip = 28 } },

	-- Продажа авиатехники
	{ business_id = 4,	building_type = "sell",	x = 2305.124, y = -2382.321, z = 21.29, rotation = nil, dimension = nil, interior = nil, object = nil, marker_text = "Продажа авиатехники", radius = 10, blip = 14, accepted_special_types = { helicopter = true, airplane = true } },

	-- Продажа морского транспорта
	{ business_id = 4,	building_type = "sell",	x = -427.314, y = 125.858, z = 2.174, rotation = nil, dimension = nil, interior = nil, object = nil, marker_text = "Продажа\n морского транспорта", radius = 2, blip = 14, accepted_special_types = { boat = true } },

	-- Автошкола
	{ business_id = 7,	building_type = nil,	x = 452.0218,		y = -1200.2188,	z = 1189.8,		rotation = nil,	dimension = 1,		interior = 1,	object = nil,	data = nil },
	{ business_id = 7,	building_type = nil,	x = 452.0218,		y = -1203.5480,	z = 1189.8,		rotation = nil,	dimension = 1,		interior = 1,	object = nil,	data = nil },
	{ business_id = 7,	building_type = nil,	x = 452.0218,		y = -1207.0500,	z = 1189.8,		rotation = nil,	dimension = 1,		interior = 1,	object = nil,	data = nil },

	-- Авторынок
	--{ business_id = 8,	building_type = nil,	x = 293.31,		y = -1188.57,	z = 20.76,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = nil },
	--{ business_id = 8,	building_type = nil,	x = 293.31,		y = -1170.23,	z = 20.76,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = nil },
	{ business_id = 8, carsale_id = "carsale_gorki", create_blip = true, building_type = nil,	x = 1599.63, y = -337.02, z = 27.27, rotation = nil, dimension = nil, interior = nil, object = nil, data = nil, data = { blip = 14 } },
	{ business_id = 8, carsale_id = "carsale_gorki", building_type = nil,	x = 1599.56, y = -340.98, z = 27.27, rotation = nil, dimension = nil, interior = nil, object = nil, data = nil },
	{ business_id = 8, carsale_id = "carsale_gorki", building_type = nil,	x = 1599.54, y = -351.7, z = 27.24, rotation = nil,	dimension = nil, interior = nil, object = nil, data = nil },
	{ business_id = 8, carsale_id = "carsale_gorki", building_type = nil,	x = 1599.48, y = -355.65, z = 27.23, rotation = nil, dimension = nil, interior = nil, object = nil, data = nil },

	{ business_id = 8, carsale_id = "carsale_mo", create_blip = true, building_type = nil,	x = 22.063, y = 298.082, z = 20.788, rotation = nil, dimension = nil, interior = nil, object = nil, data = nil },
	{ business_id = 8, carsale_id = "carsale_mo", building_type = nil,	x = 20.583, y = 294.423, z = 20.788, rotation = nil, dimension = nil, interior = nil, object = nil, data = nil },
	{ business_id = 8, carsale_id = "carsale_mo", building_type = nil,	x = 25.317, y = 310.483, z = 20.788, rotation = nil, dimension = nil, interior = nil, object = nil, data = nil },
	{ business_id = 8, carsale_id = "carsale_mo", building_type = nil,	x = 26.540, y = 314.151, z = 20.788, rotation = nil, dimension = nil, interior = nil, object = nil, data = nil },
	
	{ business_id = 9,	building_type = "pay",	x = 1008.94, 	y = 2370.97, 	z = 11.65,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = nil },
	{ business_id = 9,	building_type = "pay",	x = 1438.89, 	y = 2246.24, 	z = 9.3 ,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = nil },
	{ business_id = 9,	building_type = "pay",	x = 247.76, 	y = 2674.85, 	z = 21.34,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = nil },
	{ business_id = 9,	building_type = "pay",	x = -698.94, 	y = 2449.69, 	z = 18.8,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = nil },
	{ business_id = 9,	building_type = "pay",	x = 2170.01, 	y = 2706.34, 	z = 8.08,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = nil },

	-- Автомобильные номера
	{ business_id = 10,	building_type = nil,	x = 293.31,		y = -1178.79,	z = 20.76,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = nil },
	{ business_id = 10,	building_type = nil,	x = 1601.14,	y = 498.45,	z = 27.19,			rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = nil },

	-- Автосалон служебного транспорта
	-- { business_id = 11,	building_type = "pay",	x = 342.289, 	y = -322.042, 	z = 20.936,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = { blip = 29 } },
	-- { business_id = 11,	building_type = "sell",	x = 362.965, 	y = -267.601, 	z = 20.877,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = { blip = 29 } },
	-- { business_id = 4,	building_type = "pay",	x = -723.332, 	y = -846.925, 	z = 21.156,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = { blip = 28, assortment = 5, veh_spot = {-739.914, -850.940, 21.141}, veh_spawn = {-716.196, -855.701, 21.186} }, gps_marker = {-716.196, -855.701, 21.186} },
	{ business_id = 4,	building_type = "sell",	x = -691.048, 	y = -1705.849, 	z = 21.200,		rotation = nil,	dimension = nil,	interior = nil,	object = nil,	data = { blip = 14 } },
}

function GetCoords( id, building_type )
	if type( id ) == "table" then
		local res = {}
		for _,t in pairs( id ) do
			for _,n in pairs( GetCoords( t[1], t[2] ) ) do
				table.insert( res, n )
			end
		end
		return res
	end

	local res = {}
	for i,business in pairs( BUSINESS_ELEMENTS ) do
		if business.business_id == id then
			if (not building_type or business.building_type == building_type) then
				table.insert( res, Vector3( business.x, business.y, business.z ) )
			end
		end
	end
	return res
end

function GetGPSCoords( id, building_type )
	-- iprint("Collect GPS for type: ", inspect(type))

	if type( id ) == "table" then
		local res = {}
		for _,t in pairs( id ) do
			for _,n in pairs( GetGPSCoords( t[1], t[2] ) ) do
				table.insert( res, n )
			end
		end
		return res
	end

	local res = {}
	for i,business in pairs( BUSINESS_ELEMENTS ) do
		if business.business_id == id then
			if (not building_type or business.building_type == building_type) and not (type(business.gps_marker) == "boolean" and business.gps_marker == false) then
				if business.gps_marker then
					table.insert( res, Vector3( business.gps_marker[1], business.gps_marker[2], business.gps_marker[3] ) )
				else
					table.insert( res, Vector3( business.x, business.y, business.z ) )
				end
			end
		end
	end
	-- iprint("result: ", #res)
	return res
end

function GetGPSCoords_Table( id, building_type, filter_function )
	if type( id ) == "table" then
		local res = {}
		for _,t in pairs( id ) do
			for _,n in pairs( GetGPSCoords_Table( t[1], t[2] ) ) do
				table.insert( res, n )
			end
		end
		return res
	end

	local res = { }
	for i, business in pairs( BUSINESS_ELEMENTS ) do
		if business.business_id == id and ( not filter_function or filter_function( business ) ) then
			if (not building_type or business.building_type == building_type) and not (type(business.gps_marker) == "boolean" and business.gps_marker == false) then
				if business.gps_marker then
					table.insert( res, { x = business.gps_marker[1], y = business.gps_marker[2], z = business.gps_marker[3] } )
				else
					table.insert( res, { x = business.x, y = business.y, z = business.z } )
				end
			end
		end
	end
	-- iprint("result: ", #res)
	return res
end

for i,b in ipairs(BUSINESS_ELEMENTS) do
	b.id = i
end