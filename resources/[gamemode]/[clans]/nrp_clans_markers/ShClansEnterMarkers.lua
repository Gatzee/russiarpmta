CARTEL_BASEMENTS = {
    4,
    5,
}

CLAN_BUNKER_INTERIOR_BOUNDING_BOX = {
    position = Vector3{ x = -7.087, y = 73.895, z = 1265.049 }, 
    size = Vector3{ x = 25, y = 17.825 + 860, z = 7.880 },
    
    x0 = -7.087, y0 = 73.895, z0 = 1265.049,
    x1 = 17.913, y1 = 91.720, z1 = 1272.929,
}

CARTEL_HOUSES_INTERIORS_BOUNDING_SPHERES = {
    {
        position = Vector3{ x = 449.218, y = -1201.842, z = 1100 }, 
        radius = 22,
    },
    {
        position = Vector3{ x = 452.874, y = -1202.028, z = 1800 }, 
        radius = 20,
    },
}

CARTEL_HOUSES_MARKER_CONFIGS = {
    -- Запад
    {
        cartel_id = 1,
        color = { 135, 234, 154 },
        blip_id = 7,
        enter_position = { x = -1983.305, y = 656.233 + 860, z = 18.485 },
        exit_position = { x = 462.196, y = -1201.498, z = 1096.090, interior = 1, dimension = 1337 },
    },
    -- Восток
    {
        cartel_id = 2,
        color = { 231, 63, 94 },
        blip_id = 6,
        enter_position = { x = 1939.502, y = -2224.937 + 860, z = 32.410 },
        exit_position = { x = 452.6, y = -1214.3, z = 1798.4, interior = 1, dimension = 1337 },
    },
}