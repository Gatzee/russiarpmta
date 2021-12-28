-- CQuest.lua
Import( "ShUtils" )
Import( "Globals" )
Import( "CPlayer" )
Import( "CInterior" )
Import( "CVehicle" )
Import( "ib" )

scX, scY = guiGetScreenSize()

if not _QUEST_INIT then
	CURRENT_QUEST_INFO = nil
	CEs = {}
	GEs = {}

	_QUEST_INIT = true
end

function CQuest( data )
	local self = data
	
	if self.training_id then
		self.id = "training_".. self.training_id .."_".. self.training_role
	end

	self.ShowHudComponents = function( self, state )
		self._hide_hud_components = state
		local hide_hud_components = { "daily_quest", "factionradio", "cases_discounts", "ksusha", "wanted", "offers", }
		triggerEvent( "onClientHideHudComponents", root, hide_hud_components, state )
	end

	self.SetupTask = function( self, task )
		if task.Setup and task.Setup.client then
			local setup_event_name = self.id .."_".. task.id .."_SetupClient"

			addEvent( setup_event_name, true )
			addEventHandler( setup_event_name, root, function( custom_data )
				task.Setup.client( custom_data )

				if self.is_company_quest and not self._hide_hud_components then
					self:ShowHudComponents( true )
				end
			end )
		end

		local cleanup_event_name = self.id .."_".. task.id .."_CleanUpClient"

		addEvent( cleanup_event_name, true)
		addEventHandler( cleanup_event_name, root, function( custom_data, reason_data )
			if task.CleanUp and task.CleanUp.client then
				task.CleanUp.client( custom_data, failed )
			end

			localPlayer:setData( "QuestTimerFail", false, false )

			DestroyClientElements()

			if reason_data and reason_data.fail_text then
				DestroyTableElements( GEs )
				GEs = { }

				if reason_data.type == "quest_end_job_shift" then
					triggerEvent( "ShowPlayerUIQuestSuccess", root )
				else
					triggerEvent( "ShowPlayerUIQuestFailed", root, reason_data.fail_text, self.id, reason_data.type == "quest_stop" )
				end
			end
		end )

	end

	CURRENT_QUEST_INFO = {
		id = self.id;
		title = self.title;
		description = self.description;
		rewards = self.rewards;
		tutorial = self.tutorial;

		training_id = self.training_id;
		training_role = self.training_role;
		training_parent = self.training_parent;
		training_uncritical = self.training_uncritical;
		role_name = self.role_name;

		replay_timeout = self.replay_timeout;
		failed_timeout = self.failed_timeout;

		level_request = self.level_request;
		quests_request = self.quests_request;

		func_CheckToStart = self.CheckToStart;
		func_HideCondition = self.HideCondition;

		tasks = {};
		tasks_requests = {};
	}

	addEvent( self.id .. "_OnAnyFinish", true )
	addEventHandler( self.id .. "_OnAnyFinish", root, function( )
		if self.OnAnyFinish and self.OnAnyFinish.client then
			self.OnAnyFinish.client( )
		end
		
		if self.is_company_quest and self._hide_hud_components then
			self:ShowHudComponents( false )
		end

		DestroyTableElements( GEs )
		GEs = { }
	end )

	for i, task in pairs( self.tasks ) do
		task.id = i

		self:SetupTask( task )

		CURRENT_QUEST_INFO.tasks[ i ] = task.name
		CURRENT_QUEST_INFO.tasks_requests[ i ] = task.requests
	end

	triggerEvent("AddClientQuestInfo", root, self.id, CURRENT_QUEST_INFO)

	addEventHandler( "onClientResourceStart", resourceRoot, function()
		triggerEvent("AddClientQuestInfo", source, self.id, CURRENT_QUEST_INFO)
	end )

	addEventHandler( "onClientResourceStop", resourceRoot, function()
		triggerEvent( "RemoveClientQuestInfo", root, self.id )

		if localPlayer:IsInGame() then
			local quests_data = localPlayer:GetQuestsData()
			local current_quest = localPlayer:getData( "current_quest" )

			if current_quest and current_quest.id == self.id then
				local task = self.tasks[ quests_data.task ]
				if not task then return end

				triggerEvent( self.id .."_".. task.id .."_CleanUpClient", resourceRoot, quests_data.custom_data, true )
				if self.OnAnyFinish and self.OnAnyFinish.client then
					self.OnAnyFinish.client( )
				end

				setCameraTarget( localPlayer )
			end
		end
	end )

	return self
end

function GetQuestInfo( check_to_start, check_hide_condition )
	if check_hide_condition then
		if CURRENT_QUEST_INFO.func_HideCondition and not CURRENT_QUEST_INFO.func_HideCondition( localPlayer ) then return end
	end
	if check_to_start then
		if not CURRENT_QUEST_INFO.func_CheckToStart or CURRENT_QUEST_INFO.func_CheckToStart( localPlayer ) then
			return CURRENT_QUEST_INFO
		end
	else
		return CURRENT_QUEST_INFO
	end
end

local DIALOG_SHADER_CODE = [[
    texture tRenderTarget;
    sampler tRenderTargetSampler = sampler_state
    {
        Texture = <tRenderTarget>;
    };
    
    float ease_out_quad(float x) {
        float t = x; float b = 0; float c = 1; float d = 1;
        return -c *(t/=d)*(t-2) + b;
    }

    float ease_out_cubic(float x) {
        float t = x; float b = 0; float c = 1; float d = 1;
        return c*((t=t/d-1)*t*t + 1) + b;
    }
    
    float4 MaskTextureMain( float2 uv : TEXCOORD0 ) : COLOR0
    {
        
        float4 color = tex2D( tRenderTargetSampler, uv );
        color.a *= ease_out_cubic( uv.y );
        return color;
    }
    
    technique tech
    {
        pass p1
        {
            AlphaBlendEnable = true;
            SrcBlend = SrcAlpha;
            DestBlend = InvSrcAlpha;
            PixelShader = compile ps_2_0 MaskTextureMain();
        }
    }
]]

CONST_DIALOG_OFFSET = 20

function ShowDialogMessage( npc_id, text_list, event_to_end, is_reset_camera )
    local self = { 
		elements = { },
		current_id = 0,
		animation_duration = 500,
		click_time_out = getTickCount() + 600,
	}

	local sx, sy = 800, math.floor( 256 * 3 / 5 )
    local main_py = _SCREEN_Y - sy
	
    local bg_list_fake = ibCreateImage( _SCREEN_X_HALF - sx / 2, main_py - 50 - CONST_DIALOG_OFFSET, sx, sy )
    local bg_list = ibCreateRenderTarget( bg_list_fake:ibData( "px" ), bg_list_fake:ibData( "py" ), bg_list_fake:width( ), bg_list_fake:height( ) ):ibData( "no_render_to_screen", true )

	local shader = dxCreateShader( DIALOG_SHADER_CODE )
    bg_list_fake:ibData( "texture", shader )
    dxSetShaderValue( shader, "tRenderTarget", bg_list:ibData( "render_target" ) )

    local function CreateDialogPart( dialog_part )
        local old_real_fonts = ibIsUsingRealFonts( )
        ibUseRealFonts( true )

        local bg

        if dialog_part.custom then
            bg = dialog_part.custom( bg_list )
        else
            local name, text = dialog_part.name or (QUESTS_NPC[ npc_id ] and QUESTS_NPC[ npc_id ].name), dialog_part.text

            local _, lines = utf8.gsub( text, "\n", "" )

            bg = ibCreateArea( 0, 0, 800, 0, bg_list )
            local bg_image = ibCreateImage( 0, 0, 800, 0, ":nrp_shared/img/action_tasks/bg_dialog_contents.png", bg )

            local npy = 9
            if name then
                ibCreateLabel( 0, npy, 0, 0, name, bg, 0xffffdf93, 1, 1, "center", "top", ibFonts.bold_16 ):center_x( )
                npy = npy + 22
            end

            for i, v in pairs( split( text, "\n" ) ) do
                ibCreateLabel( 0, npy, 0, 0, v, bg, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_16 ):center_x( )
                npy = npy + 21
            end

            npy = npy + 12

            bg:ibData( "sy", npy )
            bg_image:ibData( "sy", npy )

            ibCreateImage( 0, 1, 800, 2, ":nrp_shared/img/action_tasks/bg_dialog_edges.png", bg_image )
            ibCreateImage( 0, npy - 3, 800, 2, ":nrp_shared/img/action_tasks/bg_dialog_edges.png", bg_image ):ibData( "rotation", 180 )
        end

        ibUseRealFonts( old_real_fonts )

        return bg
    end

    self.dialog_parts = { }

    local npy = sy
    for i, v in pairs( text_list ) do
        local bg = CreateDialogPart( v )
        bg:ibData( "is_author", v.name )

        table.insert( self.dialog_parts, bg )

        bg:ibData( "py", npy )
        npy = npy + bg:ibData( "sy" ) + CONST_DIALOG_OFFSET
    end

    local function SetDialogState( bg, state )
        local bg_image = getElementChild( bg, 0 )
        bg_image:ibAlphaTo( state and 255 or 0, self.animation_duration )
    end

    self.destroy = function( self )
        DestroyTableElements( { bg_list, bg_list_fake, shader, self.destroy_timer } )
        DestroyTableElements( self.elements )
        self.elements = nil
        setmetatable( self, nil )
    end

    self.destroy_with_animation = function( self, duration )
        local duration = duration or 200
        bg_list:ibAlphaTo( 0, duration )
        self.destroy_timer = setTimer( function( ) self:destroy( ) end, duration, 1 )
    end

    self.relocate = function( self )
        local npy = sy - self.dialog_parts[ self.current_id ]:ibData( "sy" ) - CONST_DIALOG_OFFSET
        self.dialog_parts[ self.current_id ]:ibMoveTo( _, npy, self.animation_duration )
        SetDialogState( self.dialog_parts[ self.current_id ], true )

        if self.current_id > 1 then
            for i = self.current_id - 1, 1, -1 do
                npy = npy - self.dialog_parts[ i ]:ibData( "sy" )
                self.dialog_parts[ i ]:ibMoveTo( _, npy, self.animation_duration )
                SetDialogState( self.dialog_parts[ i ], false )
            end
        end

        if self.current_id < #self.dialog_parts then
            local npy = 256
            for i = self.current_id + 1, #self.dialog_parts do
                self.dialog_parts[ i ]:ibMoveTo( _, npy, self.animation_duration )
                npy = npy + self.dialog_parts[ i ]:ibData( "sy" ) + CONST_DIALOG_OFFSET
                SetDialogState( self.dialog_parts[ i ], true )
            end
        end
    end

    self.next = function( self )
        if self.dialog_parts[ self.current_id + 1 ] then
            self.current_id = self.current_id + 1
            self:relocate( )
            if self.next_callback then
                self:next_callback( text_list[ self.current_id - 1 ], text_list[ self.current_id ] )
            end
        else
            self:destroy()
            if event_to_end then
				triggerServerEvent( event_to_end, localPlayer )
				if is_reset_camera then setCameraTarget( localPlayer ) end
			end
        end
    end

    self.start = function( self, time )
        self.timer = setTimer( function( )
            self:next( )
        end, time or 2000, 1 )
    end

	self.elements.btn_apply = ibCreateButton( (scX - 110) / 2, _SCREEN_Y - 50 - CONST_DIALOG_OFFSET, 110, 44, false, ":nrp_quests/files/button_apply_idle.png", ":nrp_quests/files/button_apply_hover.png", ":nrp_quests/files/button_apply_click.png", 0x80FFFFFF, 0xCCFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "up" or self.click_time_out > getTickCount() then return end
			self.click_time_out = getTickCount() + 600

			self:next()
		end )
	
	showCursor( true )
	self:next()

    CEs.dialog = self
end

function StartQuestTimerFail( time, name, fail_text, func_fail )
	if isTimer( CEs._timer ) then killTimer( CEs._timer ) end

	CEs._timer = Timer( function( )
		localPlayer:setData( "QuestTimerFail", false, false )

		triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "fail_timeout", fail_text = fail_text or "Вы не успели за отведенное время" } )

		if fail_text then
			localPlayer:ShowError( fail_text )
		end

		if func_fail then
			func_fail( )
		end
	end, time, 1 )

	localPlayer:setData( "QuestTimerFail", { name, getRealTimestamp( ) + math.floor( time / 1000 ) }, false )
end

function StartQuestTimerWait( time, name, fail_text, event_to_end, func_succ )
	if isTimer( CEs._timer ) then killTimer( CEs._timer ) end

	CEs._timer = Timer( function( )
		localPlayer:setData( "QuestTimerFail", false, false )

		local success = true
		if func_succ then
			success = func_succ( )
		end

		if success then
			if event_to_end then
				triggerServerEvent( event_to_end, localPlayer )
			end
		else
			triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "fail_timeout", fail_text = fail_text or "Вы не успели за отведенное время" } )
			
			if fail_text then
				localPlayer:ShowError( fail_text )
			end
		end
	end, time, 1 )

	localPlayer:setData( "QuestTimerFail", { name, getRealTimestamp( ) + math.floor( time / 1000 ) }, false )
end

function AddCustomTimer( timer )
	if not CEs.custom_timers then
		CEs.custom_timers = { }
	end

	table.insert( CEs.custom_timers, timer )
end

local save_cam_matrix = {}

function LockAtQuestsNPC(npc_id)
	if not QUESTS_NPC[npc_id] then return end

	local npc = QUESTS_NPC[npc_id]

	save_cam_matrix.x, save_cam_matrix.y, save_cam_matrix.z, save_cam_matrix.lx, save_cam_matrix.ly, save_cam_matrix.lz = getCameraMatrix()
	smoothMoveCamera(save_cam_matrix.x, save_cam_matrix.y, save_cam_matrix.z, save_cam_matrix.lx, save_cam_matrix.ly, save_cam_matrix.lz,
					npc.cam_position.x, npc.cam_position.y, npc.cam_position.z, npc.position.x, npc.position.y, npc.position.z + 0.6, 1500)
end

function ResetLockAtQuestsNPC()
	local x, y, z, lx, ly, lz = getCameraMatrix()
	smoothMoveCamera(x, y, z, lx, ly, lz, save_cam_matrix.x, save_cam_matrix.y, save_cam_matrix.z, save_cam_matrix.lx, save_cam_matrix.ly, save_cam_matrix.lz, 1500)
	
	Timer(setCameraTarget, 500, 1, localPlayer)
end

function LockAtQuestsNPCWithDialog( npc_id, text_list, event_to_end, reset_camera )
	LockAtQuestsNPC(npc_id)
	showCursor(true)
	Timer( ShowDialogMessage, 1500, 1, npc_id, text_list, event_to_end, reset_camera )
end

function CreateQuestPoint( position, callback_func, name, radius, interior, dimension, check_func, keypress, keytext, marker_type, r, g, b, a, ignore_gps_route )
	name = name or "marker"

	local current_quest = localPlayer:getData( "current_quest" ) or { }
	if current_quest.is_company_quest then
		r, g, b = r or 0, g or 250, b or 80
	else
		r, g, b = r or 130, g or 173, b or 221
	end

	CEs[name] = TeleportPoint( {
		x = position.x, y = position.y, z = position.z,
		radius = radius or 2.75,
		gps = true,
		quest_state = current_quest.is_company_quest or false,
		ignore_gps_route = ignore_gps_route or IGNORE_GPS_ROUTE or false,
		keypress = keypress or false, text = keytext or false,
		interior = interior or localPlayer.interior,
		dimension = dimension or localPlayer.dimension
	} )
	CEs[name].accepted_elements = { player = true, vehicle = true }
	CEs[name].marker.markerType = marker_type or "checkpoint"
	CEs[name].marker:setColor( r, g, b, a or 150 )
	CEs[name].elements = {}
	CEs[name].elements.blip = createBlipAttachedTo(CEs[name].marker, 41, 5, 250, 100, 100)
	CEs[name].elements.blip.position = CEs[name].marker.position

	if current_quest.is_company_quest then
		CEs[name].elements.blip:setData( "extra_blip", 80, false )
	else
		CEs[name].elements.blip:setData( "extra_blip", 81, false )
	end

	triggerEvent( "RefreshRadarBlips", localPlayer )

	if type( callback_func ) == "function" then
		CEs[name].PostJoin = callback_func
		CEs[name].PreJoin = check_func
	elseif type( callback_func ) == "string" then
		CEs[name].PostJoin = function()
			if not check_func or check_func() then
				CEs[name].destroy()
				triggerEvent( "RefreshRadarBlips", localPlayer )
				triggerServerEvent( callback_func, localPlayer )
			end
		end
	end
end

function CreateQuestPointToNPC(npc_id, callback_func, name)
	local position = QUESTS_NPC[npc_id].point_position or QUESTS_NPC[npc_id].position
	CreateQuestPoint( position, callback_func, name, _, QUESTS_NPC[npc_id].interior or 0, QUESTS_NPC[npc_id].dimension or 0 )
end

function CreateQuestPointToNPCWithDialog( npc_id, dialog, name_event, marker_name, reset_camera )
	CreateQuestPointToNPC( npc_id, function(self, player)
		CEs[marker_name or "marker"].destroy()
		LockAtQuestsNPCWithDialog( npc_id, dialog, name_event, reset_camera )
	end)
end

function HideUIWithDestroyClientElements()
	if not isElement( CEs.bg_img ) then return end

	CEs.bg_img:ibAlphaTo( 0, 500, "OutQuad")

	Timer( DestroyClientElements, 500, 1 )
end

function DestroyClientElements( )
	DestroyTableElements( CEs )
	CEs = { }

	showCursor(false)
end

function FindQuestNPC( id )
	return exports.nrp_quests:GetQuestNPC( id )
end

function FailCurrentQuest( reason, reason_type )
	triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = reason_type or "quest_fail", fail_text = reason } )
end

function WatchElementCondition( element, conf )
	local self = {
		element = element,
	}

	local function on_destroy( )
		iprint( "Element destroyed" )
		self:destroy( )
	end

	self.destroy = function( )
		if isTimer( self.timer ) then killTimer( self.timer ) end
		if isElement( element ) then
			removeEventHandler( "onClientElementDestroy", element, on_destroy )
		end
	end

	local function check_condition( )
		if conf.condition then
			local result = conf.condition( self, conf )
			if result == true then
				self:destroy( )
			end
		end
	end

	self.timer = setTimer( check_condition, conf.interval or 1000, 0 )
	addEventHandler( "onClientElementDestroy", element, on_destroy )

	return self
end

function EnableCheckQuestDimension( state )
    if state then
        EnableCheckQuestDimension( false )
        GEs._check_quest_dimension_tmr = setTimer( function()
            if localPlayer.dimension == 0 then
                EnableCheckQuestDimension( false )
                FailCurrentQuest( "Вы покинули зону задания" )
            end
        end, 1000, 0 )
    elseif isTimer( GEs._check_quest_dimension_tmr ) then
        killTimer( GEs._check_quest_dimension_tmr )
    end
end

function EnterLocalDimension( )
	triggerServerEvent( "EnterLocalDimension", resourceRoot, EnterLocalDimension )
	localPlayer.dimension = localPlayer:GetUniqueDimension( )
    triggerEvent( "onPlayerMoveQuestElements", localPlayer )
end