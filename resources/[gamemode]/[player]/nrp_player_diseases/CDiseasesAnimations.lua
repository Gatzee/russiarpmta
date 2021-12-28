addEventHandler( "onClientResourceStart", resourceRoot, function( )
    engineLoadIFP( "files/diseases.ifp", "DISEASES" )
end )

addEvent( "onClientPlayerDiseaseAnimation", true )
addEventHandler( "onClientPlayerDiseaseAnimation", root, function( disease_id )
    ANIMATION_SKIP = true
    
    local old_block, old_anim = getPedAnimation( source )
    if old_block and old_anim then
        return false
    end

    ANIMATION_SKIP = false
    
    local animations = DISEASES_ANIMATIONS[ disease_id ]
    local animation = animations[ math.random( #animations ) ]

    source:setAnimation( "DISEASES", animation, -1, false, true, false, false )
end )