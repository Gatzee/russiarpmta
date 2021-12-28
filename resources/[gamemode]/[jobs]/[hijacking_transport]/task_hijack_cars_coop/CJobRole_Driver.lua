
function ToggleMinigameDriver( state, data )
    if state then
        ToggleMinigameDriver( false )

        local self = data
        self.iter = 1
        self.enter_password = ""
        self.len_passowrd = self.password:len()
        self.anim_duration = 1000
        
        self.bg = ibCreateImage( 0, 0, 800, 350, "img/driver/bg.png" ):center()
        ibCreateLabel( 115, 84, 160, 29, VEHICLE_CONFIG[ self.hijacked_vehicle.model ].model, self.bg, 0xFF0A1620, nil, nil, "center", "center", ibFonts.bold_12 )
        
        self.status = ibCreateImage( 305, 63, 190, 57, "img/driver/status_process.png", self.bg )
        self.plug_status = ibCreateImage( 350, 310, 100, 26, "img/master/plug_body_down_success.png", self.bg ):ibData( "alpha", 0 )
        self.change_status = function( self, status, is_reset )
            self.status:ibData( "texture", "img/driver/status_" .. status .. ".png" )
            for i = 1, 6 do
                local block_type = is_reset and (i == 1 and "_active" or "") or ("_" .. status)
                self.blocks[ i ]:ibData( "texture", "img/driver/block" .. block_type .. ".png" )
                if block_type == "_success" or block_type == "_fail" then
                    self.plug_status:ibBatchData( { texture = "img/master/plug_body_down" .. block_type .. ".png", alpha = 255 } )
                end
                if is_reset then
                    self.plug_status:ibData( "alpha", 0 )
                    self.blocks[ i .. "lbl" ]:ibData( "text", "*" )
                end
                if status == "fail" or status == "success" then
                    setSoundVolume( playSound( "sfx/hijacking_number_" .. status .. ".ogg" ), 0.5 )
                end
            end
        end

        self.blocks = {}
        local px, py =  62, 174
        for i = 1, 6 do
            self.blocks[ i ] = ibCreateImage( px, py, 96, 96, "img/driver/block" .. (i == 1 and "_active" or "") .. ".png", self.bg )
            self.blocks[ i .. "lbl" ] = ibCreateLabel( 0, 0, 96, 96, "*", self.blocks[ i ], nil, nil, nil, "center", "center", ibFonts.oxaniumbold_40 )
            px = px + 116
        end

        self.func_on_client_key_handler = function( key, state )
            key = key:upper()   
            if not state or not REVERSE_PASSWORD_SYMBOLS[ key ] or self.is_animation or self.iter > self.len_passowrd then return end
            cancelEvent()
            
            self.enter_password = self.enter_password .. key
            self.blocks[ self.iter .. "lbl" ]:ibData( "text", key )
            self.blocks[ self.iter ]:ibData( "texture", "img/driver/block.png" )

            self.iter = self.iter + 1
            if self.iter > self.len_passowrd then
                if self.enter_password == self.password then
                    self.success_callback()
                    
                    self:change_status( "success" )

                    self.bg:ibTimer( function()
                        ToggleMinigameDriver( false )
                    end, 1500, 1 )
                else
                    self:change_status( "fail" )
                    self.bg:ibTimer( function()
                        self.iter = 1
                        self.enter_password = ""
                        self:change_status( "process", true )
                    end, 1500, 1 )
                end
            else
                self.blocks[ self.iter ]:ibData( "texture", "img/driver/block_active.png" )
            end
        end
        addEventHandler( "onClientKey", root, self.func_on_client_key_handler )

        self.destroy = function( self )
            removeEventHandler( "onClientKey", root, self.func_on_client_key_handler )

            destroyElement( self.bg )
            showCursor( false )
            
            setmetatable( self, nil )
        end
        
        triggerEvent( "onClientSwitchChatChannel", root, CHAT_TYPE_NORMAL )
        triggerEvent( "onClientSetChatState", root, true )

        showCursor( true )

        CEs.ui_minigame = self
    elseif CEs.ui_minigame then
        CEs.ui_minigame:destroy()
        CEs.ui_minigame = nil
    end
end

--[[
ToggleMinigameDriver( true, {
    hijacked_vehicle = localPlayer.vehicle,
    password = "ABCDEF",
    success_callback = function()

    end,
})
--]]