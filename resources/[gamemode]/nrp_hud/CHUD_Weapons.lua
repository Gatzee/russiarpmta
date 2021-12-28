HUD_CONFIGS.weapons = {
    elements = { },
    independent = true, -- Не управлять позицией худа
    create = function( self )
        local bg = ibCreateImage( x - 150, y - 70, 132, 37, "img/bg_weapon.png", bg )
        self.elements.bg = bg

        self.elements.lbl_clip = ibCreateLabel( 30, 20, 0, 0, "", bg, 0xffffffff, _, _, _, "center", ibFonts.regular_9 )
        self.elements.img_weapon = ibCreateImage( 97, 17, 0, 0, _, bg )

        function UpdateWeapon( )
            local weapon = localPlayer:getWeapon( )
            if weapon == 0 then
                RemoveHUDBlock( "weapons" )
                return
            end

            local clip = localPlayer:getAmmoInClip( ) or 0
			local total = localPlayer:getTotalAmmo( ) - clip or 0

			if weapon == 23 then
				clip = 1
				total = "∞"
            end
            local image = "img/weapons/" .. weapon .. ".png"

            local texture = self.elements[ "tex_" .. image ]
            if not texture then
                texture = fileExists(image) and dxCreateTexture( image )
                self.elements[ "tex_" .. image ] = texture
            end

            if isElement(texture) then
                local sx, sy = dxGetMaterialSize( texture )
                self.elements.img_weapon:ibBatchData( { texture = texture, px = 97 - sx / 2, py = 17 - sy / 2, sx = sx, sy = sy } )
                self.elements.lbl_clip:ibData( "text", clip .."/".. total )
            end
        end

        self.elements.timer = setTimer( UpdateWeapon, 50, 0 )
        UpdateWeapon( )
        
        AdjustWeaponHUDToVehicleHUD( )

        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}

function CheckWeapons_handler( _, new )
    if new ~= 0 and not localPlayer.vehicle then
        AddHUDBlock( "weapons" )
    end
end
addEventHandler( "onClientPlayerWeaponSwitch", localPlayer, CheckWeapons_handler )

function AdjustWeaponHUDToVehicleHUD( )
    local bg = HUD_CONFIGS.weapons.elements.bg
    if not bg then return end

    if IsHUDBlockActive( "vehicle" ) then
        bg:ibData( "px", x - 650 )
        bg:ibData( "py", y - 59 )
    else
        bg:ibData( "px", x - 150 )
        bg:ibData( "py", y - 70 )
    end
end

function EnterVehicle_handler( vehicle, seat )
    RemoveHUDBlock( "weapons" )
end
addEventHandler( "onClientPlayerVehicleEnter", localPlayer, EnterVehicle_handler, true, "low" )

function ExitVehicle_handler( vehicle, seat )
    if IsHUDBlockActive( "weapons" ) then
        AdjustWeaponHUDToVehicleHUD( )
    elseif localPlayer.weapon ~= 0 then
        AddHUDBlock( "weapons" )
    end
end
addEventHandler( "onClientPlayerVehicleExit", localPlayer, ExitVehicle_handler, true, "low" )

function Driveby_handler( state )
    if state then
        AddHUDBlock( "weapons" )
    else
        RemoveHUDBlock( "weapons" )
    end
end
addEvent( "onClientPlayerDrivebyStateChange", true )
addEventHandler( "onClientPlayerDrivebyStateChange", localPlayer, Driveby_handler )

function WEAPONS_onStart( )
    CheckWeapons_handler( )
end
addEventHandler( "onClientResourceStart", resourceRoot, WEAPONS_onStart )