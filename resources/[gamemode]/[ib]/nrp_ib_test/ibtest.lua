loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ib" )
Extend("CActionTasksUtils")

CreateDialog( {
    { name = "Игорь Бойко", text = "ПАПУПИ ПАПУПАМ ПАПУПИ ПАПУПАМ\nЯ НА НЕКСТРП Я НА НЕКСТРП", voice_line = "Dominic_1" },
    { text = "Спустя час, за ним приехала скорая" },
    { text = "А потом он нашёл чепрошку" },
    { name = "Чепрошка", text = "НЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕТ\nСпасите меня, пожалуйста, мне в ухо кричат:\nПАПУПИ ПАПУПАММММММ" },
    { text = "Чепрошка Умер в агонии" },
    { name = "Чепрошка", text = "НЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕТ\nСпасите меня, пожалуйста, мне в ухо кричат:\nПАПУПИ ПАПУПАММММММНЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕТ\nСпасите меня, пожалуйста, мне в ухо кричат:\nПАПУПИ ПАПУПАММММММНЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕТ\nСпасите меня, пожалуйста, мне в ухо кричат:\nПАПУПИ ПАПУПАММММММНЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕТ\nСпасите меня, пожалуйста, мне в ухо кричат:" },
    { text = "Спустя час, за ним приехала скорая" },
    { text = "А потом он нашёл чепрошку" },
} )
:next( )

--[[showCursor( true )
local image = ibCreateImage( 200, 200, 100, 100, _, _, 0x20000000 )
:ibCreateStyle( "red_longx", { sx = 400, color = 0x20ff0000 } )
:ibCreateStyle( "blue_longy", { sy = 400, color = 0x200000ff } )


local edit = ibWebEdit( {
    px = 400, py = 200,
    sx = 400, sy = 40,
    text = "asdfgh", color = 0xffff0000, bg_color = 0xffffff00, font = "regular_10", max_length = 50
} )

edit:ibTimer( function( self )
    self:ibData( "text", "TEST PASSED" )
    self:ibData( "color", 0x77ff00ff )
    self:ibData( "bg_color", 0x7700ff00 )
    self:ibData( "font", "bold_18" )
    self:ibData( "max_length", "10" )
end, 3000, 1 )


local memo = ibWebMemo( {
    px = 850, py = 200,
    sx = 400, sy = 400,
    text = "MEMO", color = 0xffff0000, bg_color = 0xffffff00, font = "regular_10",
} )

memo:ibTimer( function( self )
    self:ibData( "color", 0x77ffffff )
    self:ibData( "bg_color", 0x7700ffff )
    self:ibData( "font", "regular_14" )
end, 3000, 1 )


--ibBrowser( { px = 0, py = 0, sx = 200, sy = 300, is_local = true, is_transparent = false } )]]