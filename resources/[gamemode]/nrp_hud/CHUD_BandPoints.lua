local UI
local DATA = {
    clans_tags = { },
    scores = { },
    old_scores = { },
    duration = 10 * 60,
}

HUD_CONFIGS.bandpoints = {
    elements = { },
    independent = true, -- Не управлять позицией худа
    create = function( self )
        local bg = ibCreateArea( _SCREEN_X_HALF, 33, 0, 0 )
        self.elements.bg = bg

        local bg_img = ibCreateImage( 0, 0, 277, 10, "img/bg_bands.png", bg ):center_x( )

        self.elements.lbl_vs = ibCreateLabel( 0, -9, 0, 0, "VS", bg, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.extrabold_20 )
            :ibData( "outline", true )

        self.elements.progress_left = ibCreateImage( 1, 1, 0, 8, _, bg_img, 0xFF87ea9a )

        local clan_name = GetClanName( DATA.clan_id ) or "Ваш клан"
		self.elements.left_clan_name = ibCreateLabel( 0, -9 - 10, 100, 20, clan_name, self.elements.progress_left, COLOR_WHITE, _, _, "left", "center" )
			:ibBatchData( {
                clip = true,
                outline = 1,
                font = dxGetTextWidth( clan_name, 1, ibFonts.extrabold_9 ) > 100 and ibFonts.extrabold_8 or ibFonts.extrabold_9,
            } )
		self.elements.left_clan_tag = ibCreateImage( 0, -31, 67, 67, ":nrp_clans_events/img/bg_clan_tag.png", bg )
        ibCreateImage( 1, 1, 64, 64, ":nrp_clans/img/tags/band/" .. ( DATA.clans_tags[ DATA.clan_id ] or -1 ) .. ".png", self.elements.left_clan_tag )
        self.elements.lbl_score_left = ibCreateLabel( -155, 5, 0, 0, 0, bg, 0xFFFFFFFF, 1, 1, "right", "center", ibFonts.bold_18 )
            :ibData( "outline", true )

        self.elements.progress_right = ibCreateImage( 276, 1, 0, 8, _, bg_img, 0xFFe73f5e )

        local clan_name = GetClanName( DATA.enemy_clan_id ) or "Вражеский клан"
		self.elements.right_clan_name = ibCreateLabel( -100, -9 - 10, 100, 20, clan_name, self.elements.progress_right, COLOR_WHITE, _, _, "right", "center" )
            :ibBatchData( {
                clip = true,
                outline = 1,
                font = dxGetTextWidth( clan_name, 1, ibFonts.extrabold_9 ) > 100 and ibFonts.extrabold_8 or ibFonts.extrabold_9,
            } )
        self.elements.right_clan_tag = ibCreateImage( 0, -31, 67, 67, ":nrp_clans_events/img/bg_clan_tag.png", bg )
        ibCreateImage( 1, 1, 64, 64, ":nrp_clans/img/tags/band/" .. ( DATA.clans_tags[ DATA.enemy_clan_id ] or -2 ) .. ".png", self.elements.right_clan_tag )
        self.elements.lbl_score_right = ibCreateLabel( 155, 5, 0, 0, 0, bg, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_18 )
            :ibData( "outline", true )

        local start_date = getRealTimestamp( ) + DATA.duration
        self.elements.lbl_time_left = ibCreateLabel( 0, 18, 0, 0, getTimerString( start_date ), bg, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_18 )
            :ibData( "outline", true )
            :ibTimer( function( self )
                local timer_str, time_left = getTimerString( start_date )
                self:ibData( "text", timer_str )
            end, 1000, 0 )

        UI = self.elements

        UpdateBandpoints_handler( )

        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}

function UpdateBandpoints_handler( )
    local points_left  = math.floor( DATA.scores[ DATA.clan_id ] or 0 )
    local points_right = math.floor( DATA.scores[ DATA.enemy_clan_id ] or 0 )
    local points_total = DATA.need_score or points_left + points_right

    local relative_left  = points_total > 0 and math.min( 1, points_left / points_total ) or 0
    local relative_right = points_total > 0 and math.min( 1, points_right / points_total ) or 0

    UI.lbl_score_left:ibData( "text", points_left )
    UI.lbl_score_right:ibData( "text", points_right )

    UI.left_clan_tag:ibData( "px", UI.lbl_score_left:ibGetBeforeX( - 10 - UI.left_clan_tag:width( ) ) )
    UI.right_clan_tag:ibData( "px", UI.lbl_score_right:ibGetAfterX( 10 ) )

    UI.progress_left:ibResizeTo( math.ceil( 100 * relative_left ), _, 500 )
    UI.progress_right:ibResizeTo( -math.floor( 100 * relative_right ), _, 500 )

    local old_points_left  = math.floor( DATA.old_scores[ DATA.clan_id ] or 0 )
    local old_points_right = math.floor( DATA.old_scores[ DATA.enemy_clan_id ] or 0 )

	local delta_left = points_left - old_points_left
	local delta_right = points_right - old_points_right

	if delta_left ~= 0 then
        local label = ibCreateLabel( -UI.lbl_score_left:width( ) / 2, 0, 0, 0, 
                ( delta_left > 0 and "+ " or "- " ) .. math.abs( delta_left ), UI.lbl_score_left, 
                delta_left > 0 and 0xFF22FF22 or 0xFFFF2222, 1, 1, "center", "center", ibFonts.bold_16 )
            :ibAlphaTo( 0, 4000 )
            :ibMoveTo( _, 60, 4000 )
            :ibTimer( destroyElement, 4000, 1 )
	end

	if delta_right ~= 0 then
        local label = ibCreateLabel( UI.lbl_score_right:width( ) / 2, 0, 0, 0, 
                ( delta_right > 0 and "+ " or "- " ) .. math.abs( delta_right ), UI.lbl_score_right, 
                delta_right > 0 and 0xFF22FF22 or 0xFFFF2222, 1, 1, "center", "center", ibFonts.bold_16 )
            :ibAlphaTo( 0, 4000 )
            :ibMoveTo( _, 60, 4000 )
            :ibTimer( destroyElement, 4000, 1 )
	end
end

function ShowBandPoints( should_show_points )
    -- local resource = getResourceFromName( "devmode" )
	-- if resource and getResourceState( resource ) == "running" then return end

    -- local should_show_points =
    --     BAND_BALANCE_STATE
    --     and localPlayer:GetClanID( )
    --     and not localPlayer:getData( "memory_cleanup_ui_active" )
    --     and not localPlayer:getData( "in_clan_event_lobby" )
    --     and not localPlayer:getData( "is_on_event" )
    --     and not localPlayer:getData( "in_race" )
    --     and not ( resource and getResourceState( resource ) == "running" )

    if IsHUDBlockActive( "bandpoints" ) and not should_show_points then
        RemoveHUDBlock( "bandpoints" )
    elseif not IsHUDBlockActive( "bandpoints" ) and should_show_points then
        AddHUDBlock( "bandpoints" )
    end
end

-- function onSettingsChange_handler( changed, values )
-- 	if changed.bandbalance then
--         BAND_BALANCE_STATE = values.bandbalance
--         CheckBandpoints_handler( )
-- 	end
-- end
-- addEvent( "onSettingsChange" )
-- addEventHandler( "onSettingsChange", root, onSettingsChange_handler )

-- function bandpoints_onStart( )
--     triggerEvent( "onSettingsUpdateRequest", localPlayer, "bandbalance" )

--     CheckBandpoints_handler( )
--     setTimer( CheckBandpoints_handler, 500, 0 )
-- end
-- addEventHandler( "onClientResourceStart", resourceRoot, bandpoints_onStart )

function bandpoints_onStart( data )
    DATA.clans_tags = data.clans_tags or { }
    DATA.duration = data.duration or 10 * 60
    DATA.need_score = data.need_score
    DATA.old_scores = { }
    DATA.scores = { }

    DATA.clan_id = localPlayer:GetClanID( )
    for other_clan_id in pairs( DATA.clans_tags ) do
        if other_clan_id ~= DATA.clan_id then
            DATA.enemy_clan_id = other_clan_id
        end
    end

    ShowBandPoints( true )
end
addEvent( "CEV:OnClientGameStarted", true )
addEventHandler( "CEV:OnClientGameStarted", root, bandpoints_onStart )

function bandpoints_onEnd( )
    ShowBandPoints( false )
end
addEvent( "CEV:OnClientPlayerLobbyLeave", true )
addEventHandler( "CEV:OnClientPlayerLobbyLeave", root, bandpoints_onEnd )

function bandpoints_onUpdate( scores, need_score )
    if scores then
        DATA.old_scores = DATA.scores
        DATA.scores = scores
        UpdateBandpoints_handler( )
    elseif need_score then
        DATA.need_score = need_score
        local text = "До " .. need_score .. plural( need_score, " очка", " очков", " очков" )
        UI.lbl_need_score = ibCreateLabel( 0, 50, 0, 0, text, UI.bg, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_18 )
            :ibData( "outline", true )
    end
end
addEvent( "CEV:UpdateGameUI", true )
addEventHandler( "CEV:UpdateGameUI", root, bandpoints_onUpdate )