CARTELS_TAGS = {
    { x = -1940.94 , y =  659.47 , z = 18.75, rz = 100.0620428, size = 1.6, tag_id = -2, cartel_id = 1 },
    { x = -1942.40 , y =  667.741, z = 18.75, rz = 100.0620428, size = 1.6, tag_id = -2, cartel_id = 1 },
    { x =  1935.039, y = -2258.21 , z = 30   , rx = 3          , size = 2  , tag_id = -1, cartel_id = 2 },
    { x =  1944.100, y = -2258.21 , z = 30   , rx = 3          , size = 2  , tag_id = -1, cartel_id = 2 },
}

for k, v in pairs( CARTELS_TAGS ) do
    v.rz = v.rz or 0
    v.rx = v.rx or 0

    local size = v.size
    local half_size = size / 2

    v.vector_pos = Vector3( v.x, v.y, v.z )

    local matrix = Matrix( v.vector_pos, Vector3( v.rx, 0, v.rz ) )

    v.vector_from_pos = v.vector_pos + matrix.up * half_size
    v.vector_to_pos = v.vector_pos - matrix.up * half_size

    v.vector_img_direction = v.vector_pos - matrix.forward * size
end

addEvent( "onClientCartelsTagsUpdate", true )
addEventHandler( "onClientCartelsTagsUpdate", root, function( new_tags )
    for k, v in pairs( CARTELS_TAGS ) do
        if new_tags[ v.cartel_id ] then
            v.tag_id = new_tags[ v.cartel_id ]
        end
    end
end )