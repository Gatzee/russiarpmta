Extend( "ib" )

local bg = nil

addEvent( "onClientGotAchievements", true )
addEventHandler( "onClientGotAchievements", resourceRoot, function ( achieve_id )
    -- add indicator
    local counter = localPlayer:getData( "new_achievement" ) or 0
    localPlayer:setData( "new_achievement", counter + 1, false )

    -- draw
    if isElement( bg ) then
        bg:destroy( )
    end

    local name = ACHIEVEMENTS[ achieve_id ].name

    bg = ibCreateArea( 0, -100, 0, 0 ):center_x( ):ibMoveTo( nil, 20, 300 )

    local achievement_bg = ibCreateImage( 0, 0, 80, 80, "img/achievement.png", bg )
    :center_x( )
    local achievement = ibCreateContentImage( 0, 0, 80, 80, "achievement", achieve_id, achievement_bg )
    :center( )
    ibCreateLabel( 1, 97, 0, 0, "Получено достижение:", bg, 0x55000000, nil, nil, "center", "center", ibFonts.bold_14 )
    :center_x( )
    ibCreateLabel( 0, 96, 0, 0, "Получено достижение:", bg, nil, nil, nil, "center", "center", ibFonts.bold_14 )
    :center_x( )
    ibCreateLabel( 1, 119, 0, 0, name, bg, 0x55000000, nil, nil, "center", "center", ibFonts.bold_16 )
    :center_x( )
    ibCreateLabel( 0, 118, 0, 0, name, bg, 0xffffe743, nil, nil, "center", "center", ibFonts.bold_16 )
    :center_x( )

    bg:ibTimer( function ( )
        bg:destroy( )
    end, 7000, 1 )

    bg:ibTimer( function ( )
        achievement:ibRotateTo( 360, 500 )
        ibSoundFX( "reward_get" )
    end, 500, 1 )
end )