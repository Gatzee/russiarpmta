PROGRESSES =
{
	hdd_1 =
	{
		id = 1,
		max = 1,
		visible_name = "Забрать первый жесткий диск"
	},
	wait_1 = 
	{
		id = 2,
		max = 4,
		unit = "ч",
		visible_name = "Ожидать расшировки",
	},
	hdd_2 =
	{
		id = 3,
		max = 1,
		visible_name = "Забрать второй жесткий диск",
	}
}

E_DATA = {}
EVENT_COUNT = 0
EVENT =
{
	[ "stage_1" ] =
	{
        id = "stage_1",
        stage_type = "proc",
        tittle = "Поговори с Колей",
        description = "Кажется Коле нужна твоя помощь",
		dialog =
		{
			messages = { 
				[[Привет, у меня тут проблемы на работе.
				 Ограбили меня и забрали жесткие диски.
				 Вернешь мне оба жестких диска заплачу 75 000 рублей.]],
			},
			font = "regular_14",
	
			camera_matrix = { x = -101.3936, y = -1127.4626, z = 21.3882, tx =-97.8840, ty = -1227.3006, tz = 16.9103 },
		},
		client = function( data )
			local conf = {
				x = EVENT_PED_POSITION.x,
				y = EVENT_PED_POSITION.y,
				z = EVENT_PED_POSITION.z,
				dimension = 0,
				interior = 0,
				radius = 4,
				keypress = false,
				marker_text = "Коля",
                text = false,
                gps = true,
				color = { 255, 255, 255, 0 },
			}
			E_DATA.point = TeleportPoint( conf )
			E_DATA.point.PostJoin = function( point, player )
				E_DATA.point:destroy()
                CreatetDialog( data, function()
                    triggerServerEvent( "onServerPlayerStartStage", localPlayer, data )
                end )
			end
			ResetEventContent()
		end,
		
    },
    [ "stage_2" ] =
    {
        id = "stage_2",
        stage_type = "proc",
        tittle = "Проучи грабителя",
        description = "Выбей из грабителя жесткий диск",
		client = function( data )
			local ped_position = nil
			local event_content = LoadEventContent()
			if event_content and event_content.ped_1_position then
				ped_position = PED_POSITIONS[ event_content.ped_1_position ]
			else
				local ped_id = math.random( 1, #PED_POSITIONS )
				ped_position = PED_POSITIONS[ ped_id ]
				SaveEventContent( { ped_1_position = ped_id } )
			end
			
			ped_position.z = ped_position.z + 0.7
			local conf = {
				x = ped_position.x,
				y = ped_position.y,
				z = ped_position.z,
				dimension = 0,
				interior = 0,
				radius = 15,
				keypress = false,
				marker_text = "",
				text = false,
				color = { 255, 255, 255, 0 },
				gps = true,
			}
			E_DATA.point = TeleportPoint( conf )
			E_DATA.point.PostJoin = function( point )
				localPlayer:ShowInfo( "Избейте грабителя, чтобы он отдал диск" )
				E_DATA.point:destroy() 
			end
			
			E_DATA.ped_position = ped_position
			E_DATA.ped = createPed( 298, ped_position )
			
			E_DATA.timer_correct_position = setTimer( function()
				if E_DATA and E_DATA.ped and math.abs( E_DATA.ped.position.z - E_DATA.ped_position.z ) > 2 then
					E_DATA.ped.position = E_DATA.ped_position
				end
			end, 2000, 0 )

			function onColshapeHit( theElement )
				if theElement ~= localPlayer or isElement( E_DATA.btn_1 ) or isElement( E_DATA.btn_2 ) then return end
                removeEventHandler( "onClientColShapeHit", E_DATA.colshape, onColshapeHit )

				function onPlayerWasted()
					DestroyCurrentData()
					removeEventHandler( "onClientPlayerWasted", localPlayer, onPlayerWasted )
					triggerServerEvent( "onServerPlayerFailStage", localPlayer, data )
					localPlayer:ShowInfo( "Грабитель сбежал..." )
				end
				addEventHandler( "onClientPlayerWasted", localPlayer, onPlayerWasted )
				
				E_DATA.colshape = source
				E_DATA.btn_1 = ibInfoPressKey( {
					do_text = "Нажмите",
					text = "чтобы ограбить";
					key = "h";
					key_text = "H",
					py = scY / 2 - 100,
					black_bg = 0xA0000000,
					no_auto_destroy = true,
					key_handler = function( )
						if not isElement( E_DATA.colshape ) then
							return false
						end
						if isElement( E_DATA.colshape ) and not isElementWithinColShape( localPlayer, E_DATA.colshape ) then
							localPlayer:ShowError( "Вернись к грабителю, чтобы забрать жесткий диск!" )
                            return false
						end
						
						removeEventHandler( "onClientPedDamage", E_DATA.ped, onPedDamage )
						removeEventHandler( "onClientPlayerWasted", localPlayer, onPlayerWasted )
                    	E_DATA.colshape:destroy()
						E_DATA.btn_1:destroy()
						E_DATA.btn_2:destroy()

						localPlayer:setAnimation( "bomber", "bom_plant_loop", 2000, false, false, false, false )
						setTimer( function()
							data.type_operation = 1
							triggerServerEvent( "onServerPlayerStartStage", localPlayer, data )
						end, 1200, 1 )
					end;
				} )

				E_DATA.btn_2 = ibInfoPressKey( {
					do_text = "Нажмите",
					text = "чтобы забрать только жесткий диск";
					key = "lalt";
					key_text = "ALT",
					py = scY / 2 - 50,
					black_bg = 0x00000000,
					no_auto_destroy = true,
					key_handler = function( )
						if not isElement( E_DATA.colshape ) then
							return false
						end
						if isElement( E_DATA.colshape ) and not isElementWithinColShape( localPlayer, E_DATA.colshape ) then
							localPlayer:ShowError( "Вернись к грабителю, чтобы забрать жесткий диск!" )
                            return false
						end
						removeEventHandler( "onClientPedDamage", E_DATA.ped, onPedDamage )
                    	E_DATA.colshape:destroy()
						E_DATA.btn_1:destroy()
						E_DATA.btn_2:destroy()

						localPlayer:setAnimation( "bomber", "bom_plant_loop", 2000, false, false, false, false )
						setTimer( function()
							data.type_operation = 2
							triggerServerEvent( "onServerPlayerStartStage", localPlayer, data )
						end, 1200, 1 )
					end;
				} )

			end

            local is_animation = false
			function onPedDamage( attacker ) 
				if attacker ~= localPlayer then return end
                E_DATA.ped:setAnimation( "ped", "cower" )
                if not is_animation then
                    is_animation = true
                    
                    if isElement( E_DATA.colshape ) then return end
					E_DATA.point:destroy()

					if isTimer( E_DATA.timer_correct_position ) then
						E_DATA.timer_correct_position:destroy()
					end

					E_DATA.colshape = createColCircle( source.position.x, source.position.y, 2 )
                    addEventHandler( "onClientColShapeHit", E_DATA.colshape, onColshapeHit )
                else
                    cancelEvent()
                end
			end
			addEventHandler( "onClientPedDamage", E_DATA.ped, onPedDamage )

		end,
    },
	[ "stage_3" ] =
	{
        id = "stage_3",
        stage_type = "proc",
        tittle = "Верни жесткий диск",
        description = "Диск у тебя, пора вернуть его Коле",
		dialog = 
		{
			messages = { 
		        [[Отлично, мне нужно время на расшифровку данных,
		        как закончу приходи. Может получится узнать
		        где прячется второй грабитель.]],
			},
			font = "regular_14",
		
			camera_matrix = { x = -101.3936, y = -1127.4626, z = 21.3882, tx =-97.8840, ty = -1227.3006, tz = 16.9103 },
		
			on_finished = function( data )
				triggerServerEvent( "onServerPlayerStartStage", localPlayer, data )
			end
		},
		client = function( data )
			
			local conf = {
				x = EVENT_PED_POSITION.x,
				y = EVENT_PED_POSITION.y,
				z = EVENT_PED_POSITION.z,
				dimension = 0,
				interior = 0,
				radius = 4,
				keypress = false,
				marker_text = "Коля",
				text = false,
				color = { 255, 255, 255, 0 },
				gps = true,
			}
			E_DATA.point = TeleportPoint( conf )
			E_DATA.point.PostJoin = function( point )
                E_DATA.point:destroy()
                CreatetDialog( data )
			end
		end,
	},
	[ "stage_4" ] =
	{
        id = "stage_4",
        tittle = "Расшифровка",
        stage_type = "wait",
        start_text = "Время ожидания: ",
        finish_text = "Жесткий диск расшифрован,\nпоговори с Колей!",

        client = function( data )
            if not isElement( E_DATA.point ) then
                local conf = {
                    x = EVENT_PED_POSITION.x,
                    y = EVENT_PED_POSITION.y,
                    z = EVENT_PED_POSITION.z,
                    dimension = 0,
                    interior = 0,
                    radius = 4,
                    keypress = false,
                    marker_text = "Коля",
                    text = false,
                    color = { 255, 255, 255, 0 },
                    gps = false,
                }
                E_DATA.point = TeleportPoint( conf )
                E_DATA.point.PostJoin = function( point )
                    triggerServerEvent( "onServerPlayerStartStage", resourceRoot, data )
                end
            end
		end,
    },
    [ "stage_5" ] =
	{
        id = "stage_5",
        tittle = "Расшифровка",
        stage_type = "proc",
        description = "Жесткий диск расшифрован,\nпоговори с Колей!",

        dialog = 
		{
			messages = { 
			    [[Я расшифровал данные, но узнать где
			    он находится не получилось. Найди его!]],
			},
			font = "regular_14",

            camera_matrix = { x = -101.3936, y = -1127.4626, z = 21.3882, tx = -97.8840, ty = -1227.3006, tz = 16.9103 },
            
            on_finished = function( data )
				triggerServerEvent( "onServerPlayerStartStage", localPlayer, data )
			end
		},

        client = function( data )
            CreatetDialog( data )
		end,
	},
	[ "stage_6" ] =
	{
        id = "stage_6",
        stage_type = "proc",
        tittle = "Найди грабителя",
        description = "Коле не удалось узнать где 2 грабитель,\nнайди его...",
		client = function( data )
			local ped_position = nil
			local event_content = LoadEventContent()
			if event_content and event_content.ped_2_position then
				ped_position = PED_POSITIONS[ event_content.ped_2_position ]
			else
				local ped_id = math.random( 1, #PED_POSITIONS )
				ped_position = PED_POSITIONS[ ped_id ]
				SaveEventContent( { ped_2_position = ped_id } )
			end
			
			ped_position.z = ped_position.z + 0.7
            local conf = {
				x = ped_position.x,
				y = ped_position.y,
				z = ped_position.z,
				dimension = 0,
				interior = 0,
				radius = 15,
				keypress = false,
				marker_text = "",
				text = false,
				color = { 255, 255, 255, 0 },
				gps = false,
			}
			E_DATA.point = TeleportPoint( conf )
			E_DATA.point.PostJoin = function( point )
				localPlayer:ShowInfo( "Избейте грабителя, чтобы он отдал диск" )
				E_DATA.point:destroy() 
			end

			E_DATA.ped_position = ped_position
			E_DATA.ped = createPed( 298, ped_position )
			
			E_DATA.timer_correct_position = setTimer( function()
				if E_DATA and E_DATA.ped and math.abs( E_DATA.ped.position.z - E_DATA.ped_position.z ) > 2 then
					E_DATA.ped.position = E_DATA.ped_position
				end
			end, 2000, 0 )
			
			function onColshapeHit( theElement )
				if theElement ~= localPlayer or isElement( E_DATA.btn_1 ) then return end
				removeEventHandler( "onClientColShapeHit", E_DATA.colshape, onColshapeHit )

				local key = "h"
				local text = "чтобы ограбить"
				if data.type_operation == 2 then
					key = "lalt"
					text = "чтобы забрать только жесткий диск"
				end

				function onPlayerWasted()
					DestroyCurrentData()
					removeEventHandler( "onClientPlayerWasted", localPlayer, onPlayerWasted )
					triggerServerEvent( "onServerPlayerFailStage", localPlayer, data )
					localPlayer:ShowInfo( "Грабитель сбежал..." )
				end
				addEventHandler( "onClientPlayerWasted", localPlayer, onPlayerWasted )

				E_DATA.btn_1 = ibInfoPressKey( {
					do_text = "Нажмите",
					text = "чтобы ограбить";
					key = key;
					key_text = key,
					py = scY / 2 - 100,
					black_bg = 0xA0000000,
					no_auto_destroy = true,
					key_handler = function( )
						if not isElement( E_DATA.colshape ) then
							return false
						end
						if isElement( E_DATA.colshape ) and not isElementWithinColShape( localPlayer, E_DATA.colshape ) then
							localPlayer:ShowError( "Вернись к грабителю, чтобы забрать жесткий диск!" )
                            return false
						end

						E_DATA.btn_1:destroy()

						removeEventHandler( "onClientPedDamage", E_DATA.ped, onPedDamage )
						removeEventHandler( "onClientPlayerWasted", localPlayer, onPlayerWasted )
						localPlayer:setAnimation( "bomber", "bom_plant_loop", 2000, false, false, false, false )
						setTimer( function()
							triggerServerEvent( "onServerPlayerStartStage", localPlayer, data )
						end, 1200, 1 )
					end;
				})
			end

            local is_animation = false
			function onPedDamage( attacker )
				if attacker ~= localPlayer then return end
                E_DATA.ped:setAnimation( "ped", "cower" )
				if not is_animation then
                    is_animation = true                    
					
					if isElement( E_DATA.colshape ) then return end
					E_DATA.point:destroy()

					if isTimer( E_DATA.timer_correct_position ) then
						E_DATA.timer_correct_position:destroy()
					end

					E_DATA.colshape = createColCircle( source.position.x, source.position.y, 2 )
                    addEventHandler( "onClientColShapeHit", E_DATA.colshape, onColshapeHit )
                else
                    cancelEvent()
                end
			end
			addEventHandler( "onClientPedDamage", E_DATA.ped, onPedDamage )
		end,
	},
	[ "stage_7" ] =
	{
        id = "stage_7",
        stage_type = "proc",
        tittle = "Верни жесткий диск",
        description = "Второй диск у тебя, пора вернуть\nего Коле",
		dialog = 
		{
			messages = { 
                [[Отлично! Спасибо тебе! А, кстати насчет награды,
                давай как-нибудь в другой раз.]],
			},
			font = "regular_14",

			camera_matrix = { x = -101.3936, y = -1127.4626, z = 21.3882, tx =-97.8840, ty = -1227.3006, tz = 16.9103 },

	        on_finished = function( data )
				triggerServerEvent( "onServerPlayerStartStage", localPlayer, data )
			end
		},
		client = function( data )
			local conf = {
				x = EVENT_PED_POSITION.x,
				y = EVENT_PED_POSITION.y,
				z = EVENT_PED_POSITION.z,
				dimension = 0,
				interior = 0,
				radius = 4,
				keypress = false,
				marker_text = "Коля",
				text = false,
				color = { 255, 255, 255, 0 },
				gps = true,
			}
			E_DATA.point = TeleportPoint( conf )
			E_DATA.point.PostJoin = function( point )				
				E_DATA.point:destroy()
				CreatetDialog( data )
			end
		end,
    },
    [ "stage_8" ] =
	{
        id = "stage_8",
        stage_type = "proc",
        tittle = "Награда",
        description = "",
		client = function( data )
			triggerEvent( "ShowUI_Rewards", resourceRoot, true, data )
		end,
	},
}

for k, v in pairs( EVENT ) do
    EVENT_COUNT = EVENT_COUNT + 1
end