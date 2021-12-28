local DEATH_TIMER
local DEATH_COUNTER

local x, y = guiGetScreenSize()
local TEXT_SCALE = x / 1600 * 3
local TEXT_FONT = "default-bold"
local TEXT_COLOR = 0xffff0000

function ShowUI_Wasted( time )
    if isTimer( DEATH_TIMER ) then killTimer( DEATH_TIMER ) end
    removeEventHandler( "onClientRender", root, RenderDeathText )

    if not time then return end

    DEATH_COUNTER = time

    DEATH_TIMER = Timer( 
        function() 
            DEATH_COUNTER = DEATH_COUNTER - 1
            if DEATH_COUNTER <= 0 then
                killTimer( DEATH_TIMER )
                DEATH_LAST_TIME = getTickCount()
                triggerServerEvent( "CEV:OnPlayerRequestRespawn", localPlayer )
            end
        end,
        1000, 0
    )
    addEventHandler( "onClientRender", root, RenderDeathText, false, "low-100" )
end
addEvent("ShowUI_Wasted", true)
addEventHandler("ShowUI_Wasted", resourceRoot, ShowUI_Wasted)

function RenderDeathText( )
    local text = DEATH_COUNTER > 0 and "Возрождение доступно через: " .. DEATH_COUNTER .. " сек." or "Возрождение..."

    dxDrawRectangle( 0, 0, x, y, 0x99000000 )
    dxDrawText( text, x / 2, y / 2, x / 2, y / 2, TEXT_COLOR, TEXT_SCALE, TEXT_FONT, "center", "center", false, false, false, true )
end

function OnClientPlayerSpawn_handler_ShowUI_Wasted()
    ShowUI_Wasted( )
end
addEventHandler( "onClientPlayerSpawn", localPlayer, OnClientPlayerSpawn_handler_ShowUI_Wasted )