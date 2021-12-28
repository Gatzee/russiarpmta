CONST_GRASS_POSITIONS = {
	Vector3( -2395.185, -294.942 + 860, 20.096 );
	Vector3( -2395.185, -304.942 + 860, 20.096 );
	Vector3( -2395.185, -314.942 + 860, 20.096 );
	Vector3( -2390.185, -304.942 + 860, 20.096 );
	Vector3( -2400.185, -304.942 + 860, 20.096 );
}

DENSITY = 40
AREA = 15

TEXTURES = { "files/img/texture1.png", "files/img/texture2.png" }
TEXTURES_MUL = { 
	5,
	5,
}

local function getPositionFromElementAtOffset( element, x, y, z )
	if not x or not y or not z then      
		return x, y, z   
	end        
	local matrix = getElementMatrix ( element )
	local offX = x * matrix[1][1] + y * matrix[2][1] + z * matrix[3][1] + matrix[4][1]
	local offY = x * matrix[1][2] + y * matrix[2][2] + z * matrix[3][2] + matrix[4][2]
	local offZ = x * matrix[1][3] + y * matrix[2][3] + z * matrix[3][3] + matrix[4][3]
	return offX, offY, offZ
end

QUEST_DATA = {
	id = "task_military_3";

	title = "Зимой и летом...";
	description = "";

	replay_timeout = 0;

	CheckToStart = function( player )
		return player:IsOnUrgentMilitary()
	end;

	tasks = {
		[1] = {
			name = "Поговори с прапорщиком";

			Setup = {
				client = function()
					CreateQuestPointToNPCWithDialog( 13, {
						{
							text = [[— Так, боец, запомни одну армейскую
									мудрость: зимой и летом одним цветом..]];
						};
						{
							text = [[— Конечно же трава, а ты что подумал, неуч?
									Бегом на склад за краской исправлять
									недочёты природы]];
						};
						{
							text = [[Используй “Левый ALT” на обозначенной
									области, чтобы красить траву.]];
							info = true;
						};
					}, "PlayerAction_Task_Militaty_3_step_1", _, true )
				end;
			};

			event_end_name = "PlayerAction_Task_Militaty_3_step_1";
		};
		[2] = {
			name = "Забери краску со склада";

			Setup = {
				client = function()
					CreateQuestPoint( Vector3( -2406.569, -252.189 + 860, 20 ), "PlayerAction_Task_Militaty_3_step_2" )
				end;
			};

			event_end_name = "PlayerAction_Task_Militaty_3_step_2";
		};
		[3] = {
			name = "Покрась 85% травы";

			Setup = {
				client = function()
					local grass_index = math.random( 1, #CONST_GRASS_POSITIONS )

					CreateQuestPoint( CONST_GRASS_POSITIONS[ grass_index ], function()
						CEs.marker:destroy()
					end, _, 10 )


					CEs.GRASS_SHADER = dxCreateShader( "files/fx/grass.fx", 0, 50, true, "world,object" )
					local pixels =  ( AREA * DENSITY )
					CEs.GRASS_RT = dxCreateRenderTarget( pixels, pixels, true )

					if not isElement( CEs.GRASS_SHADER ) or not isElement( CEs.GRASS_RT ) then
						triggerServerEvent( "PlayerFailStopQuest", localPlayer, { type = "quest_fail", fail_text = "Системная ошибка инициализации травы" } )
						return
					end
					
					dxSetShaderValue( CEs.GRASS_SHADER, "tex", CEs.GRASS_RT )
					engineApplyShaderToWorldTexture( CEs.GRASS_SHADER, "*" )
					local rm = {
						"",
						"*spoiler*",
						"*particle*",
						"*light*",
						"vehicle*",
						"?emap*",
						"?hite*",
						"*92*",
						"*wheel*",
						"*interior*",
						"*handle*",
						"*body*",
						"*decal*",
						"*8bit*",
						"*logos*",
						"*badge*",
						"*plate*",
						"*sign*",
						"*headlight*",
						"*shad*",
						"coronastar",
						"tx*",
						"lod*",
						"cj_w_grad",
						"*cloud*",
						"*smoke*",
						"sphere_cj",
						"particle*",
						"*water*",
						"coral",
						"shpere",
						"*inferno*",
						"*fire*",
						"*cypress*",
						"list",
						"*brtb*",
						"*tree*",
						"*leave*",
						"*spark*",
						"*eff*",
						"*branch",
						"*ash*",
						"*fire*",
						"*rocket*",
						"*hud*",
						"bark2",
						"bchamae",
						"*sfx*",
						"*wires*",
						"*agave*",
						"*plant*",
						"neon",
						"*log*",
						"sjmshopbk", -- fence secondary
						"*sand*",
						"*radar*",
						"*skybox*", -- maps skybox
						-- "*grass*", "*dirt*", "sw_sand"
						"metalox64",
						"metal1_128",
						-- vgncarshade1,vgshseing28
						"nitro",
						"repair",
						"carchange", -- pickups
						"bullethitsmoke",
						-- the smoke from the engine
						"toll_sfw1",
						"toll_sfw3",
						"trespasign1_256",
						"steel64",
						"beachwalkway",
						"ws_greymeta",
						"telepole2128",
						"ah_barpanelm",
						"plasticdrum1_128",
						"planks01",
						"unnamed",
						"aascaff128",
						"*effect*",
						"newfx*",
						"cardebris*",
					}
					for i, v in pairs( rm ) do
						engineRemoveShaderFromWorldTexture( CEs.GRASS_SHADER, v )
					end

					dxSetShaderValue( CEs.GRASS_SHADER, "pos", CONST_GRASS_POSITIONS[ grass_index ].x, CONST_GRASS_POSITIONS[ grass_index ].y, CONST_GRASS_POSITIONS[ grass_index ].z )
					dxSetShaderValue( CEs.GRASS_SHADER, "mt", 0, 0, -1 )
					local rx, ry, rz = 0, 0, 0
					dxSetShaderValue( CEs.GRASS_SHADER, "rt", ry, rx, rz )
					dxSetShaderValue( CEs.GRASS_SHADER, "scale", AREA )

					dxSetRenderTarget( CEs.GRASS_RT, false )
					dxDrawRectangle( 0, 0, pixels, pixels, 0x80008000 )
					dxSetRenderTarget( )

					local last_percent = 0
					local timeout = 0
					CEs.func_bindKey = function()
						if localPlayer.position.x > ( CONST_GRASS_POSITIONS[ grass_index ].x - AREA / 2 ) and localPlayer.position.x < ( CONST_GRASS_POSITIONS[ grass_index ].x + AREA / 2 )
						and localPlayer.position.y > ( CONST_GRASS_POSITIONS[ grass_index ].y - AREA / 2 ) and localPlayer.position.y < ( CONST_GRASS_POSITIONS[ grass_index ].y + AREA / 2 ) then
							if timeout > getTickCount() then return end
							timeout = getTickCount() + 1000

							setPedAnimation( localPlayer, "bomber", "bom_plant_crouch_in", -1, false, false, false, false )

							dxSetRenderTarget( CEs.GRASS_RT, false )

							local px, py, pz = getPositionFromElementAtOffset( localPlayer, 0, 1, 0 )
							local rotation = getPedRotation( localPlayer )

							local pixels =  ( AREA * DENSITY )
							local tx = pixels / 2 + ( px - CONST_GRASS_POSITIONS[ grass_index ].x ) * DENSITY
							local ty = pixels / 2 + ( py - CONST_GRASS_POSITIONS[ grass_index ].y ) * DENSITY
							local tz = pixels / 2 + ( pz - CONST_GRASS_POSITIONS[ grass_index ].z ) * DENSITY

							local texture_number = math.random( 1, #TEXTURES )
							local texture = TEXTURES[ texture_number ]
							local size = DENSITY * ( TEXTURES_MUL[ texture_number ] or 1 )
							dxDrawImage( tx - size / 2, ty - size / 2, size, size, texture, rotation, 0, 0, 0xff00ff00 )

							dxSetRenderTarget( )

							local sx, sy = dxGetMaterialSize( CEs.GRASS_RT )
							local total_pixels, colored_pixels = sx * sy, 0
							local pixels = dxGetTexturePixels( CEs.GRASS_RT )
							for pix = 1, sx do
								for piy = 1, sy do
									local r, g, b, a = dxGetPixelColor( pixels, pix, piy )
									if r and g > 128 then
										colored_pixels = colored_pixels + 1
									end
								end
							end
						
							local procent = colored_pixels / total_pixels

							if procent >= 0.85 then
								triggerServerEvent( "PlayerAction_Task_Militaty_3_step_3", localPlayer )
							else
								local new_percent = math.floor( procent * 100 )
								if last_percent ~= new_percent then
									localPlayer:ShowInfo( "Ты закрасил ~".. new_percent .."%" )
									last_percent = new_percent
								end
							end
						end
					end

					bindKey( "lalt", "down", CEs.func_bindKey )

					CEs.func_client_restore = function( clean )
						if clean then
							dxSetRenderTarget( CEs.GRASS_RT, true )
							dxDrawRectangle( 0, 0, pixels, pixels, 0x80008000 )
							dxSetRenderTarget( )

							localPlayer:ShowInfo( "Эй, солдат, чё отвлекаемся? Трава потеряла свой блеск!" )
						end
					end
					addEventHandler( "onClientRestore", root, CEs.func_client_restore )
				end;
			};

			CleanUp = {
				client = function()
					unbindKey( "lalt", "down", CEs.func_bindKey )
					removeEventHandler( "onClientRestore", root, CEs.func_client_restore )

					CEs.func_bindKey = nil
					CEs.func_client_restore = nil
				end;
			};

			event_end_name = "PlayerAction_Task_Militaty_3_step_3";
		};
	};

	rewards = {
		faction_exp = 30;
		military_exp = 600;
	};

	GiveReward = function( player )
		local rewards = player:IsOnUrgentMilitary( ) and { type = "military_exp", value = 600 } or { type = "faction_exp", value = 30 }
		player:ShowRewards( rewards )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_military_3", 30 )
	end;

	no_show_rewards = true,

	success_text = "Задача выполнена! Вы получили +30 очков ранга";
}