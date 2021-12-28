
PODIM_BANK_DATA = {}
PODIUM_DATA =
{
    interior = 1,
    dimension = 1,

    marker_position = Vector3( -56.3415, -100.4115, 1372.7133 ),
    marker_radius = 5.5,
}

function InitPodium()
    PODIUM_DATA.area = createColSphere( PODIUM_DATA.marker_position, PODIUM_DATA.marker_radius )
    PODIUM_DATA.area.dimension = PODIUM_DATA.dimension
    PODIUM_DATA.area.interior = PODIUM_DATA.interior
    AddService( PODIUM_DATA.area, function()
       triggerServerEvent( "onServerPlayerWantOpenPodiumDance", localPlayer ) 
    end, "Нажмите “ALT”, чтобы открыть меню\nтанца", function()
        if PODIUM_DANCE then
            return false
        end
        return true
    end )
    ChangeBackgroundSound( 2 )
end

function DestroyPodium()
    if isElement( PODIUM_DATA.area ) then
        PODIUM_DATA.area:destroy()
        PODIUM_DATA.area = nil
    end
    if PODIUM_DANCE then
        PODIUM_DANCE:destroy_dance()
        PODIUM_DANCE = nil
    end

    ShowPodiumUI( false )
end

----------------------------------------------
-- Функционал подиумного танца
----------------------------------------------

ANIM_START_POSITION = 
{
    Vector3( -56.3934, -100.4822, 1373.6009 ),
    Vector3( -56.6534, -100.5022, 1373.6009 ),
    Vector3( -56.3534, -100.3022, 1373.6009 ),
}

QUEU_PODIUM_DANCES =
{
    [ GIRL_POISON_IVY ] = {
        create_elements = function( self )
            self.girl = CreateAIPed( GIRL_MODELS[ self.dance_id ], Vector3( -70.7062, -101.0881, 1373.6947 ), 0 )
            self.girl.interior = 1
            setPedWalkingStyle( self.girl, 132 )
            SetUndamagable( self.girl, true )
        end,
        queu =
        {
            [ 1 ] = function( self )
                local timestamp = getRealTimestamp()
                local passed_duration = timestamp - self.start_timestamp
                local path = {
                    { x = -56.8337, y = -100.4994, z = 1373.6009, distance = 0.1, move_type = 4, duration = 10 },
                }

                if passed_duration <= 4 then
                    self.start_timestamp = self.start_timestamp + 3
                    self.effect = createEffect( "carwashspray", -68, -100, 1375, 90, 0, 0, 0, true )
                    self.effect.dimension = localPlayer.dimension
                    self.effect.interior = localPlayer.interior
                    setEffectSpeed( self.effect, 0.3 )
                    self.timer_start_dance = setTimer( function()
                        if self and isElement( self.effect ) and isElement( self.girl ) then
                            setEffectDensity( self.effect, 0 )
                            self.girl.dimension = localPlayer.dimension
                            SetAIPedMoveByDuration( self.girl, path, false, self.start_timestamp, function()
                                if self then 
                                    self:next_step()
                                end
                            end )
                        end
                    end, 3000, 1 )
                else
                    self.girl.dimension = localPlayer.dimension
                    if isElement( self.girl ) then
                        SetAIPedMoveByDuration( self.girl, path, false, self.start_timestamp, function()
                            self:next_step()
                        end )
                    end
                end
            end,
            [ 2 ] = function( self )
                if not isElement( self.girl ) then
                    return
                end

                if self.girl.dimension ~= 1 then
                    self.girl.dimension = 1
                end
                self.girl.position = ANIM_START_POSITION[ self.anim_id ]

                local timestamp = getRealTimestamp()
                local passed_duration = timestamp - self.start_timestamp

                self.girl:setAnimation( IFP_STRIP_BLOCK_NAME, "dance" .. self.anim_id, -1, true, false, false, false )
                
                local anim_progress = ( passed_duration - self.queu_duration[ self.cur_step - 1 ] ) / PODIUM_DANCE_GIRLS[ self.dance_id ].anim_duration
                self.girl:setAnimationProgress( "dance" .. self.anim_id, anim_progress )
                self.girl:setAnimationSpeed( "dance" .. self.anim_id, 0.6 )

                if isElement( self.effect ) then
                    destroyElement( self.effect )
                end
                passed_duration = math.max( 0, passed_duration - self.queu_duration[ self.cur_step - 1 ] )
                self.off_timer = setTimer( function()
                    if self then
                        self:next_step()
                    end 
                end, math.max( 50, ( PODIUM_DANCE_GIRLS[ self.dance_id ].anim_duration - passed_duration ) * 1000 ), 1 )
            end,
            [ 3 ] = function( self )
                if not isElement( self.girl ) then
                    return
                end

                if self.girl.dimension ~= 1 then
                    self.girl.dimension = 1
                    self.girl.position = ANIM_START_POSITION[ self.anim_id ]
                end

                self.girl:setAnimation()
                
                self.effect = createEffect( "carwashspray", -68, -100, 1375, 90, 0, 0, 0, true )
                self.effect.dimension = 1
                self.effect.interior = localPlayer.interior
                setEffectSpeed( self.effect, 0.3 )

                local path = {
                    { x = -72.1530, y = -100.4174, z = 1373.6009, distance = 0.1, move_type = 4, duration = 10 },
                }
                if isElement( self.girl ) then
                    SetAIPedMoveByDuration( self.girl, path, false, self.start_timestamp + self.queu_duration[ self.cur_step - 1 ], function()
                        if self and isElement( self.girl ) then
                            self:next_step()
                        end
                    end )
                end
            end,
        },
        queu_duration = { 10, 70, 80 },
    },
    [ GIRL_COMMON_DANCE ] = {
        create_elements = function( self )
            self.ivy       = CreateAIPed( GIRL_MODELS[ GIRL_POISON_IVY ],       Vector3( -70.7062, -99.8152,  1373.6947 ),  0 )
            self.valentine = CreateAIPed( GIRL_MODELS[ GIRL_FAYE_VALENTINE ],   Vector3( -71.9630, -99.8152,  1373.6947 ),  0 )
            self.sith      = CreateAIPed( GIRL_MODELS[ GIRL_DOMINEERING_SITH ], Vector3( -70.7062, -101.0881, 1373.6947 ), 0 )
            self.quin      = CreateAIPed( GIRL_MODELS[ GIRL_HARLEY_QUINN ],     Vector3( -71.9630, -101.0881, 1373.6947 ), 0 )
            self.girls = { self.quin, self.valentine, self.sith, self.ivy }
            for k, v in pairs( self.girls ) do
                v.interior = 1
                setPedWalkingStyle( v, 132 )
                setElementRotation( v, 0, 0, 270 )
                SetUndamagable( v, true )
            end
        end,
        queu =
        {
            [ 1 ] = function( self )
                local GIRL_PATHS = 
                {
                    [ 1 ] =
                    {
                        { x = -59.3444, y = -100.6186, z = 1373.6009, distance = 0.1, move_type = 4, duration = 10 },
                        { x = -55.6088, y = -103.5262, z = 1373.6009, distance = 0.1, move_type = 4, duration = 13 },
                    },
                    [ 2 ] =
                    {
                        { x = -59.7281, y = -100.1010, z = 1373.6009, distance = 0.1, move_type = 4, duration = 10 },
                        { x = -55.3174, y = -97.5168, z = 1373.6009, distance = 0.1, move_type = 4, duration = 13 },
                    },
                    [ 3 ] =
                    {
                        { x = -61.9050, y = -100.6529, z = 1373.6009, distance = 0.1, move_type = 4, duration = 9 }, --R
                        { x = -53.6703, y = -101.5174, z = 1373.6009, distance = 1.5, move_type = 4, duration = 4 },
                    },
                    [ 4 ] =
                    {
                        { x = -61.5659, y = -99.8201, z = 1373.6009, distance = 0.1, move_type = 4, duration = 9 }, --L
                        { x = -53.9452, y = -98.4046, z = 1373.6009, distance = 1.5, move_type = 4, duration = 4 },
                    },
                }

                StartMoveGirls = function( self )
                    if not self then return end

                    for k, v in pairs( self.girls ) do
                        v.dimension = localPlayer.dimension
                        if isElement( v ) then
                            SetAIPedMoveByDuration( v, GIRL_PATHS[ k ], false, self.start_timestamp, function( )
                                if k == 4 then
                                    self:next_step()
                                end
                            end )
                        end
                    end
                end

                local timestamp = getRealTimestamp()
                local passed_duration = timestamp - self.start_timestamp
                if passed_duration <= 4 then
                    self.start_timestamp = self.start_timestamp + 3
                    self.effect = createEffect( "carwashspray", -68, -100, 1375, 90, 0, 0, 0, true )
                    self.effect.dimension = localPlayer.dimension
                    self.effect.interior = localPlayer.interior
                    setEffectSpeed( self.effect, 0.3 )
                    self.timer_start_dance = setTimer( function()
                        if self and isElement( self.effect ) then
                            setEffectDensity( self.effect, 0 )
                            StartMoveGirls( self )
                        end
                    end, 3000, 1 )
                else
                    StartMoveGirls( self )
                end
                
                
            end,
            [ 2 ] = function( self )
                if not self then return end

                if self.ivy.dimension ~= 1 then
                    local restore_position = 
                    {
                        [ 1 ] = Vector3( -55.6088, -103.5262, 1373.6009 ),
                        [ 2 ] = Vector3( -55.3174, -97.5168, 1373.6009 ),
                        [ 3 ] = Vector3( -53.6703, -101.5174, 1373.6009 ),
                        [ 4 ] = Vector3( -53.9452, -98.4046, 1373.6009 ),
                    }
                    
                    for k, v in pairs( self.girls ) do
                        v.dimension = localPlayer.dimension
                        v.position = restore_position[ k ]
                    end
                end

                local timestamp = getRealTimestamp()
                local passed_duration = timestamp - self.start_timestamp
                local anim_progress = ( passed_duration - self.queu_duration[ self.cur_step - 1 ] ) / PODIUM_DANCE_GIRLS[ self.dance_id ].anim_duration

                for k, v in pairs( self.girls ) do
                    setElementCollisionsEnabled( v, false )
                    v:setAnimation( IFP_STRIP_BLOCK_NAME, "private", -1, true, false, false, false, 4000 )
                    v:setAnimationProgress( "private", anim_progress )
                end

                if isElement( self.effect ) then
                    destroyElement( self.effect )
                end

                local timestamp = getRealTimestamp()
                local passed_duration = timestamp - self.start_timestamp
                passed_duration = math.max( 0, passed_duration - self.queu_duration[ self.cur_step - 1 ] )
                self.off_timer = setTimer( function()
                    self:next_step()
                end, math.max( 50, ( PODIUM_DANCE_GIRLS[ self.dance_id ].anim_duration - passed_duration ) * 1000), 1 )
            end,
            [ 3 ] = function( self )
                if not self then return end
                
                if self.ivy.dimension ~= 1 then
                    local restore_position = 
                    {
                        [ 1 ] = Vector3( -55.6088, -103.5262, 1373.6009 ),
                        [ 2 ] = Vector3( -55.3174, -97.5168, 1373.6009 ),
                        [ 3 ] = Vector3( -53.6703, -101.5174, 1373.6009 ),
                        [ 4 ] = Vector3( -53.9452, -98.4046, 1373.6009 ),
                    }
                    
                    for k, v in pairs( self.girls ) do
                        v.dimension = 1
                        v.position = restore_position[ k ]
                    end
                end

                local GIRL_PATHS = 
                {
                    [ 1 ] =
                    {
                        { x = -59.3444, y = -100.6186, z = 1373.6009, distance = 0.1, move_type = 4, duration = 3 },
                        { x = -72.7062, y = -99.8152,  z = 1373.6009, distance = 0.1, move_type = 4, duration = 10  },
                    },
                    [ 2 ] =
                    {
                        { x = -59.7281, y = -100.1010, z = 1373.6009, distance = 0.1, move_type = 4, duration = 3 },
                        { x = -70.9630, y = -99.8152,  z = 1373.6009, distance = 0.1, move_type = 4, duration = 10 },
                    },
                    [ 3 ] =
                    {
                        { x = -72.7062, y = -101.0881, z = 1373.6009, distance = 0.1, move_type = 4, duration = 13 },
                    },
                    [ 4 ] =
                    {
                        { x = -70.9630, y = -101.0881, z = 1373.6009, distance = 0.1, move_type = 4, duration = 13 },
                    },
                }
                
                self.effect = createEffect( "carwashspray", -68, -100, 1375, 90, 0, 0, 0, true )
                self.effect.dimension = localPlayer.dimension
                self.effect.interior = localPlayer.interior
                setEffectSpeed( self.effect, 0.3 )

                for k, v in pairs( self.girls ) do
                    if isElement( v ) then
                        v:setAnimation()
                        setElementCollisionsEnabled( v, true )
                        SetAIPedMoveByDuration( v, GIRL_PATHS[ k ], false, self.start_timestamp + self.queu_duration[ self.cur_step - 1 ], function()
                            if k == 4 and self then
                                self:next_step()
                            end
                        end )
                    end
                end
            end,
        },
        queu_duration = { 10, 70, 80 },
    },
}

QUEU_PODIUM_DANCES[ GIRL_FAYE_VALENTINE ]   = QUEU_PODIUM_DANCES[ GIRL_POISON_IVY ]
QUEU_PODIUM_DANCES[ GIRL_DOMINEERING_SITH ] = QUEU_PODIUM_DANCES[ GIRL_POISON_IVY ]
QUEU_PODIUM_DANCES[ GIRL_HARLEY_QUINN ]     = QUEU_PODIUM_DANCES[ GIRL_POISON_IVY ]

PODIUM_DANCE = nil

function onClientStartPodiumDance_handler( dance_data )
    if PRIVATE_DANCE then
        STORE_PODIUM_DATA = table.copy( dance_data )
        return
    end
    
    if PODIUM_DANCE then
        PODIUM_DANCE:destroy_dance()
        PODIUM_DANCE = nil
    end
    
    local self = dance_data
    self.original_data = table.copy( dance_data )
    self.queu = QUEU_PODIUM_DANCES[ self.dance_id ].queu
    self.queu_duration = QUEU_PODIUM_DANCES[ self.dance_id ].queu_duration
    QUEU_PODIUM_DANCES[ self.dance_id ].create_elements( self )
    self.cur_step = nil

    local timestamp = getRealTimestamp()
    local passed_duration = timestamp - self.start_timestamp
    for k, v in pairs( self.queu_duration ) do
        if passed_duration < v then
            self.cur_step = k
            break
        end
    end
    if not self.cur_step then return end
    self.cur_step = self.cur_step - 1

    self.start_dance = function( self )
        ChangeBackgroundSound( 3 )
        self:next_step()
    end

    self.next_step = function( self )
        self.cur_step = self.cur_step + 1
        if self.cur_step > #self.queu then
            self:destroy_dance()
        elseif self and self.queu[ self.cur_step ] then
            self.queu[ self.cur_step ]( self )
        elseif self then
            self:destroy_dance()
        end
    end

    self.destroy_dance = function( self )
        for k, v in pairs( self.girls or {} ) do
            ResetAIPedPattern( v )
            removePedTask( v )
            destroyElement( v )
        end

        if isElement( self.girl ) then
            ResetAIPedPattern( self.girl )
            removePedTask( self.girl )
            destroyElement( self.girl )
        end
        
        if isTimer( self.timer_start_dance ) then
            killTimer( self.timer_start_dance )
        end

        if isTimer( self.off_timer ) then
            killTimer( self.off_timer )
        end
        DestroyTableElements( self )
        ChangeBackgroundSound( 2 )
        PODIUM_DANCE = nil
        self = nil
    end
    
    PODIUM_DANCE = self
    ShowPodiumUI( false )

    self.timer_start_dance = setTimer( function()
        PODIUM_DANCE:start_dance()
    end, 500, 1 )
end
addEvent( "onClientStartPodiumDance", true )
addEventHandler( "onClientStartPodiumDance", resourceRoot, onClientStartPodiumDance_handler )

function onClientRefreshPodiumBank_handler( data )
    if isElement( UI_elements.bg_podium ) then
        PODIM_BANK_DATA = data
        RefreshBankUI()
        RefreshCurrentGirl( UI_elements.current_girl.girl_id )
    end
end
addEvent( "onClientRefreshPodiumBank", true )
addEventHandler( "onClientRefreshPodiumBank", resourceRoot, onClientRefreshPodiumBank_handler )