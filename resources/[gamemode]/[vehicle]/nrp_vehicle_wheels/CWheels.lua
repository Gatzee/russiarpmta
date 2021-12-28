loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CVehicle" )

local STREAMED_VEHICLES = { }
local RENDERED_VEHICLES = { }

local IGNORED_VEHICLE_TYPES = {
	Bike       = true,
	Helicopter = true,
	Quad       = true,
	Plane      = true,
	Boat       = true,
	Train      = true,
	Trailer    = true,
	BMX        = true,
}

local DEFAULT_VEH_CONF = {
	default = { 1, 0, 1 },

	[ 6597 ] = { 1, -0.031, 1 },
	[ 421 ] = { 1.05, -0.09, 0.75 },
	[ 427 ] = { 0.97, 0.02, 1 },
	[ 490 ] = { 1, 0, 0.9 },
	[ 579 ] = { 1, 0, 0.8 },
	[ 6580 ] = { 1, 0.04, 1 },
	[ 6581 ] = { 1, 0.04, 1 },
	[ 6582 ] = { 1, 0.04, 1 },
	[ 6586 ] = { 1.1, 0, 0.7 },
	[ 6585 ] = { 1, -0.02, 0.7 },
	[ 6569 ] = { 1, 0, 0.8 },
	[ 6577 ] = { 1.03, -0.02, 1.05 },
	[ 6589 ] = { 1.02, 0, 1 },
	[ 6590 ] = { 0.99, 0, 1 },
	[ 405 ] = { 1.08, 0.0, 1 },
	[ 400 ] = { 1, 0.02, 1 },
	[ 404 ] = { 1.075, 0, 1.1 },
	[ 426 ] = { 1, -0.02, 1.1 },
	[ 516 ] = { 1, -0.05, 1.1 },
	[ 517 ] = { 1.1, -0.1, 1 },
	[ 571 ] = { 1, 0.2, 1 },
	[ 436 ] = { 1, -0.03, 1 },
	[ 554 ] = { 1, 0.05, 1 },
	[ 6578 ]= { 1, -0.01, 1 },
	[ 491 ] = { 1, 0.025, 1 },
	[ 546 ] = { 1, 0.02, 1 },
	[ 412 ] = { 1, 0.03, 1 },
	[ 445 ] = { 1, -0.02, 1 },
	[ 6527 ] = { 1, 0.005, 1 },
	[ 6535 ] = { 0.95, -0.03, 1.15 },
	[ 6555 ] = { 1, 0, 0.9 },
	[ 6554 ] = { 0.95, 0, 1 },
	[ 555 ] = { 1, -0.02, 1 },
	[ 6546 ] = { 0.95, 0.03, 1.3 },
	[ 6549 ] = { 1.02, -0.02, 1 },
	[ 418 ] = { 1, -0.06, 1.2 },
	[ 6562 ] = { 1, -0.08, 1 },
	[ 585 ] = { 1, -0.065, 0.9 },
	[ 562 ] = { 0.98, 0.03, 1.1 },
	[ 6595 ] = { 1, -0.09, 1 },
	[ 459 ] = { 1.1, 0, 1.1 },
	[ 6596 ] = { 1, 0.03, 1 },
	[ 6601 ] = { 1, 0, 1 },
	[ 6602 ] = { 1, 0, 0.9 },
	[ 6603 ] = { 1, -0.045, 1 },
	[ 6605 ] = { 1, 0, 1.05 },
	[ 6607 ] = { 1, -0.03, 1.2 },
	[ 6613 ] = { 1, -0.015, 1 },
	[ 6612 ] = { 0.95, 0, 1 },
	[ 6615 ] = { 0.97, 0.02, 1 },
	[ 6616 ] = { 1, 0.04, 1 },
	[ 575 ] = { 1, 0, 1.5 },
	[ 6624 ] = { 1.05, 0.01, 0.67 },
	[ 6625 ] = { 1, -0.01, 0.87 },
	[ 6626 ] = { 1, -0.01, 0.8 },
	[ 6632 ] = { 1.05, 0.02, 1 },
	[ 419 ] = { 1.05, 0, 1 },
	[ 6629 ] = { 0.98, 0, 1 },
}

--[[ { радиус, смещение_по_оси_Z, ширина } ]]

local VEH_CONF = {
	default = { 1.1, -0.005, 1.2 },

	[ 477 ] = { 0.93, 0.02, 1.1 },
	[ 6622 ] = { 1.13, 0.01, 1.3 },
	[ 6618 ] = { 1.1, 0.0, 1.5 },
	[ 6617 ] = { 1.13, 0.01, 1.5 },
	[ 6620 ] = { 1.05, 0.0, 1.3 },
	[ 6619 ] = { 1.1, 0.01, 1.45 },
	[ 6616 ] = { 1.12, 0.04, 1.5 },
	[ 6615 ] = { 1.15, 0.02, 1.6 },
	[ 6621 ] = { 1.15, 0.02, 1.5 },
	[ 6612 ] = { 1.15, 0.015, 1.3 },
	[ 6610 ] = { 1.15, 0, 1.2 },
	[ 6611 ] = { 1.3, 0.01, 1.3 },
	[ 6613 ] = { 1.25, -0.015, 1.2 },
	[ 475 ] = { 1.15, 0, 1.25 },
	[ 6595 ] = { 0.95, -0.06, 1.25 },
	[ 6597 ] = { 1, -0.031, 1.2 },
	[ 6551 ] = { 1.18, 0.03, 1 },
	[ 6552 ] = { 1.2, 0.03, 1 },
	[ 6545 ] = { 1.05, -0.03, 1 },
	[ 6542 ] = { 1.1, 0, 1.3 },
	[ 6538 ] = { 0.85, -0.07, 1.3 },
	[ 415 ] = { 1.17, 0.01, 1.2 },
	[ 401 ] = { 1.15, 0.01, 1.2 },
	[ 445 ] = { 1.05, -0.02, 1.2 },
	[ 412 ] = { 1.15, 0.03, 1.2 },
	[ 559 ] = { 1, -0.025, 1.2 },
	[ 546 ] = { 1.2, 0.025, 1.2 },
	[ 6578 ]= { 1, -0.02, 1.2 },
	[ 436 ] = { 1, -0.03, 1.2 },
	[ 516 ] = { 0.95, -0.05, 1.3 },
	[ 426 ] = { 1.095, -0.01, 1.2 },
	[ 585 ] = { 0.95, -0.05, 0.9 },
	[ 438 ] = { 1.2, 0.03, 1 },
	[ 527 ] = { 1.2, 0, 1.5 },
	[ 562 ] = { 1.2, 0.03, 1.1 },
	[ 419 ] = { 1.13, 0, 1.3 },
	[ 466 ] = { 1.17, 0.05, 1.3 },
	[ 400 ] = { 1.15, 0.02, 1.2 },
	[ 596 ] = { 1.05, 0, 1.2 },
	[ 554 ] = { 1.25, 0.05, 1.12 },
	[ 560 ] = { 1.165, 0.01, 1.2 },
	[ 547 ] = { 1.2, 0.02, 1.15 },
	[ 517 ] = { 0.8, -0.1, 1 },
	[ 421 ] = { 0.93, -0.08, 1 },
	[ 518 ] = { 1.15, 0, 1.4 },
	[ 479 ] = { 0.95, 0, 1.3 },
	[ 545 ] = { 1.12, 0, 1 },
	[ 490 ] = { 1.08, 0, 0.9 },
	[ 491 ] = { 1.2, 0.05, 1.5 },
	[ 492 ] = { 0.95, 0, 1.3 },
	[ 526 ] = { 1.2, 0, 1.5 },
	[ 579 ] = { 1.05, -0.03, 0.9 },
	[ 576 ] = { 1.15, 0, 1.2 },
	[ 602 ] = { 1.1, 0, 1.35 },
	[ 429 ] = { 1.35, 0.02, 1.25 },
	[ 410 ] = { 1.4, 0.02, 1.35 },
	[ 536 ] = { 1.2, -0.005, 1.2 },
	[ 439 ] = { 1.13, 0, 1.3 },
	[ 6535 ] = { 1.35, -0.03, 1.3 },
	[ 6528 ] = { 1.15, 0.02, 1.15 },
	[ 6530 ] = { 0.94, 0, 1.25 },
	[ 6537 ] = { 1.2, -0.02, 1.25 },
	[ 6529 ] = { 1.28, 0.02, 1.35 },
	[ 6527 ] = { 1.5, 0.005, 1.2 },
	[ 6536 ] = { 1.12, -0.06, 1 },
	[ 6531 ] = { 0.95, -0.06, 1.2 },
	[ 6526 ] = { 0.9, -0.06, 1.05 },
	[ 6550 ] = { 1, 0, 0.9 },
	[ 6546 ] = { 1.2, 0.03, 1.4 },
	[ 6553 ] = { 1, 0, 1.3 },
	[ 6539 ] = { 0.9, 0, 1 },
	[ 6540 ] = { 1.25, 0, 1.2 },
	[ 6544 ] = { 1.185, 0.02, 1 },
	[ 480 ] = { 1, 0, 1 },
	[ 402 ] = { 1.15, 0.01, 1.3 },
	[ 409 ] = { 1.15, 0.01, 1.2 },
	[ 502 ] = { 1.1, 0, 1.2 },
	[ 503 ] = { 1, -0.03, 1 },
	[ 533 ] = { 1.15, 0.01, 1.2 },
	[ 542 ] = { 1.05, 0, 1 },
	[ 550 ] = { 1.1, 0, 1.1 },
	[ 555 ] = { 1.02, -0.02, 1.1 },
	[ 558 ] = { 1.1, -0.02, 1.3 },
	[ 582 ] = { 1.2, 0.01, 1.3 },
	[ 6555 ] = { 1, -0.02, 1 },
	[ 6556 ] = { 1.2, 0.02, 1.3 },
	[ 6557 ] = { 1.1, -0.01, 1.3 },
	[ 6558 ] = { 1, 0, 1.21 },
	[ 6560 ] = { 1.05, -0.02, 1.15 },
	[ 6554 ] = { 1.1, 0.01, 1.15 },
	[ 6561 ] = { 0.9, 0.02, 1.3 },
	[ 6562 ] = { 0.95, -0.05, 1.4 },
	[ 6563 ] = { 1.28, -0.01, 1.4 },
	[ 6564 ] = { 1.17, 0.01, 1.2 },
	[ 6565 ] = { 1.17, 0.015, 1.3 },
	[ 6567 ] = { 1, 0, 1.1 },
	[ 6568 ] = { 1.1, 0, 1.3 },
	[ 6569 ] = { 1, 0, 0.9 },
	[ 6570 ] = { 1.1, 0, 1.3 },
	[ 6572 ] = { 1.15, 0, 1.1 },
	[ 6573 ] = { 1.15, 0, 1.2 },
	[ 6575 ] = { 1.15, 0, 1.3 },
	[ 6576 ] = { 1.20, 0.05, 1 },
	[ 6577 ] = { 1.05, -0.02, 1.25 },
	[ 6574 ] = { 1.1, -0.005, 1.45 },
	[ 6579 ] = { 1.15, 0, 1.35 },
	[ 6585 ] = { 1, -0.02, 0.9 },
	[ 6582 ] = { 1.2, 0.02, 1.5 },
	[ 6580 ] = { 1.23, 0.04, 1.15 },
	[ 6581 ] = { 1.2, 0.02, 1.4 },
	[ 6587 ] = { 1.1, 0, 1.4 },
	[ 6588 ] = { 1.25, 0, 1.3 },
	[ 6589 ] = { 1.05, 0, 1.2 },
	[ 6590 ] = { 1.05, 0, 1 },
	[ 6593 ] = { 1, 0, 1.5 },
	[ 551 ] = { 1.05, 0, 1.2 },
	[ 418 ] = { 1, -0.04, 1.3 },
	[ 6586 ] = { 0.95, 0, 1 },
	[ 6533 ] = { 1.2, 0, 1.2 },
	[ 6587 ] = { 1.1, 0, 1.1 },
	[ 6601 ] = { 1.15, 0, 1.1 },
	[ 6602 ] = { 1.1, -0.01, 1.5 },
	[ 6603 ] = { 1, -0.045, 1.1 },
	[ 6604 ] = { 1.1, 0.01, 1.22 },
	[ 6605 ] = { 1.26, 0, 1.2 },
	[ 6607 ] = { 1, -0.03, 1.2 },
	[ 575 ] = { 1.1, 0, 1.9 },
	[ 6623 ] = { 1.2, 0.01, 1.2 },
	[ 6633 ] = { 1.2, 0.01, 1.2 },
	[ 6624 ] = { 1.12, -0.01, 1.2 },
	[ 6625 ] = { 1.1, -0.003, 1.23 },
	[ 6626 ] = { 1.1, -0.002, 1.4 },
	[ 6632 ] = { 1.17, 0.02, 1.25 },
	[ 6634 ] = { 1.125, 0, 1.5 },
	[ 6638 ] = { 1.2, 0, 1.1 },
	[ 413 ] = { 1.8, 0, 1.1 },
	[ 6637 ] = { 1.4, 0, 1.0 },
}

addCommandHandler( "defwheels", function ( _, size, z, width )
	if localPlayer:getData( "_srv" )[ 1 ] > 100 and localPlayer.vehicle then
		DEFAULT_VEH_CONF[ localPlayer.vehicle.model ] = { tonumber( size ) or 1, tonumber( z ) or 1, tonumber( width ) or 1 }
	end
end )

addCommandHandler( "cuswheels", function ( _, size, z, width )
	if localPlayer:getData( "_srv" )[ 1 ] > 100 and localPlayer.vehicle then
		VEH_CONF[ localPlayer.vehicle.model ] = { tonumber( size ) or 1, tonumber( z ) or 1, tonumber( width ) or 1 }
	end
end )

local WHEELS_TEXTURES = {
			"yokohama_tread",
			"yokohama_sidewall",
			"brake_disk_278_172_2",
			"rpb_disk1",
			"rpb_disk2",
			"rpb_disk3",
			"rpb_disk4",
			"rpb_disk5",
			"rpb_disk6",
			"rpb_disk7",
			"rpb_disk8",
			"rpb_disk8_2",
			"rpb_disk9",
			"rpb_disk10",
			"rpb_disk11",
			"rpb_disk12",
			"rpb_disk13",
			"rpb_disk14",
			"rpb_disk15",
			"rpb_disk16",
			"rpb_disk17",
			"rp_wheel_1",
			"rp_wheel1",
			"rp_wheel2",
			
			"rpb_disk1",
			"rpb_disk1b",

			"rdm_tire",
			"lex_logo",
			"lex_is_rim",

			"sidewall",
			"yokohama",

			"tread",
			"wheel",
			"rim",

			"Wheel1B_DiffuseAOSO", -- 429 Continental GT
}

local WHEELS_TEXTURES_PAINT = {
	"rpb_disk1c",
}

local SHADER_CODE = [[
			float4x4 gWorld : WORLD;
			float4x4 gView : VIEW;
			float4x4 gProjection : PROJECTION;
			float4x4 gWorldView : WORLDVIEW;
			float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;
			float4x4 gViewInverse : VIEWINVERSE;
			float4x4 gViewInverseTranspose : VIEWINVERSETRANSPOSE;
			float4 gLightAmbient : LIGHTAMBIENT;
			float4 gLightDiffuse : LIGHTDIFFUSE;
			float3 gLightDirection : LIGHTDIRECTION;
			float4 gGlobalAmbient              < string renderState="AMBIENT"; >;
			int gDiffuseMaterialSource         < string renderState="DIFFUSEMATERIALSOURCE"; >;
			int gAmbientMaterialSource         < string renderState="AMBIENTMATERIALSOURCE"; >;
			int gEmissiveMaterialSource        < string renderState="EMISSIVEMATERIALSOURCE"; >;
			float4 gMaterialAmbient     < string materialState="Ambient"; >;
			float4 gMaterialDiffuse     < string materialState="Diffuse"; >;
			float4 gMaterialEmissive    < string materialState="Emissive"; >;

			float3 VehicleUp;
			float3 VehicleForward;
			float4x4 VehicleWorldInverse;
			float Scale = 1;
			float Height = 0;
			float Width = 1;
			float FrontWidth = 0;
			float RearWidth = 0;
			float FrontCamber = 0;
			float RearCamber = 0;
			float4 rgba = (255,255,255,255);

			struct VSInput
			{
				float4 Position : POSITION0;
				float3 Normal : NORMAL0;
				float4 Diffuse : COLOR0;
				float2 TexCoord : TEXCOORD0;
			};

			struct PSInput
			{
				float4 Position : POSITION0;
				float4 Diffuse : COLOR0;
				float2 TexCoord : TEXCOORD0;
			};

			float3 rotate_position(float3 v, float3 axis, float angle)
			{ 
				float c, s;
				sincos(angle * 0.5, s, c);
				float3 q = axis * s;
				return v + 2.0 * cross(q, cross(q, v) + c * v);
			}

			PSInput VertexShaderFunction(VSInput VS)
			{
				PSInput PS = (PSInput)0;
				float3 axisVec = gWorld._11_12_13 * Width;
				float3 forwardVec = gWorld._21_22_23;
				float3 upVec = gWorld._31_32_33;
				float3 position = gWorld._41_42_43 + VehicleUp * Height;

				float defaultScale = length(forwardVec);
				float4 vehiclePos = mul(float4(position,1), VehicleWorldInverse);
				float is_front_wheels = step( 0, vehiclePos.y );
				axisVec *= 1 + is_front_wheels * FrontWidth + (1 - is_front_wheels) * RearWidth;
				upVec = normalize(cross(-axisVec, -forwardVec));
				forwardVec = normalize(cross(-axisVec, upVec));

				float3x3 mat = { axisVec, forwardVec, upVec };
				
				float is_left_wheels = -1 + 2 * step( vehiclePos.x, 0 );
				float camber_angle = (is_front_wheels * FrontCamber + (1 - is_front_wheels) * RearCamber);
				position -= VehicleUp * camber_angle * 0.1;
				float4 worldPos = float4(rotate_position(mul(VS.Position * defaultScale * Scale, mat), VehicleForward, camber_angle * is_left_wheels) + position, 1);

				float4 viewPos = mul(worldPos, gView);
				float4 projPos = mul(viewPos, gProjection);
				PS.Position = projPos;
				PS.TexCoord = VS.TexCoord;
				float3 WorldNormal = mul(VS.Normal, gWorld);
				float4 ambient  = gAmbientMaterialSource  == 0 ? gMaterialAmbient  : VS.Diffuse;
				float4 diffuse  = gDiffuseMaterialSource  == 0 ? gMaterialDiffuse  : VS.Diffuse;
				float4 emissive = gEmissiveMaterialSource == 0 ? gMaterialEmissive : VS.Diffuse;
				float4 TotalAmbient = ambient * ( gGlobalAmbient + gLightAmbient );
				float DirectionFactor = max(0,dot(WorldNormal, -gLightDirection ));
				float4 TotalDiffuse = ( diffuse * gLightDiffuse * DirectionFactor );
				PS.Diffuse = saturate(TotalDiffuse + TotalAmbient + emissive);
				PS.Diffuse.a *= diffuse.a;
				PS.Diffuse *= rgba / 255;
				return PS;
			}

			technique tec
			{
				pass P0
				{
					VertexShader = compile vs_2_0 VertexShaderFunction();
				}
			}
]]

function SetWheelsVectors( )
	for vehicle, shader_data in pairs( RENDERED_VEHICLES ) do
		local matrix = vehicle.matrix
		dxSetShaderValue ( shader_data.main_shader, "VehicleUp", matrix.up )
		dxSetShaderValue ( shader_data.main_shader, "VehicleForward", matrix.forward )

		dxSetShaderValue ( shader_data.paint_shader, "VehicleUp", matrix.up )
		dxSetShaderValue ( shader_data.paint_shader, "VehicleForward", matrix.forward )
	end
end
Timer( SetWheelsVectors, 50, 0 )

function onClientRender_handler_wheels( )
	for vehicle, shader_data in pairs( RENDERED_VEHICLES ) do
		local m = vehicle.matrix:inverse( )
		dxSetShaderValue ( shader_data.main_shader, "VehicleWorldInverse", m )
		dxSetShaderValue ( shader_data.paint_shader, "VehicleWorldInverse", m )
	end
end 
addEventHandler( "onClientPreRender", root, onClientRender_handler_wheels )

local WHEEL_COMPONENTS = { "wheel_lf_dummy", "wheel_rf_dummy", "wheel_lb_dummy", "wheel_rb_dummy" }
local WHEEL_COMPONENTS_OFFSETS = { }
function UpdateVehicleWheelsStuff()
	for vehicle, shader_data in pairs ( STREAMED_VEHICLES ) do
		local model = getElementModel( vehicle )
		local conf_real = getVehicleUpgradeOnSlot( vehicle, 12 ) > 0 and ( VEH_CONF[ model ] or VEH_CONF.default ) or DEFAULT_VEH_CONF[ model ]
		local front_width, rear_width = vehicle:GetWheelsWidth( )
		local front_camber, rear_camber = vehicle:GetWheelsCamber( )
		local front_offset, rear_offset = vehicle:GetWheelsOffset( )

		local main_shader = shader_data and shader_data.main_shader
		local paint_shader = shader_data and shader_data.paint_shader

		if conf_real or ( front_width + rear_width + front_camber + rear_camber + front_offset + rear_offset ) > 0 then
			if not RENDERED_VEHICLES[ vehicle ] then
				main_shader = dxCreateShader( SHADER_CODE, 0, 50, false, "vehicle" )
				if main_shader then
					for _, texture_name in pairs( WHEELS_TEXTURES ) do
						engineApplyShaderToWorldTexture ( main_shader, texture_name, vehicle )
					end
					STREAMED_VEHICLES[ vehicle ] = { main_shader = main_shader }
					RENDERED_VEHICLES[ vehicle ] = { main_shader = main_shader }
					
					paint_shader = dxCreateShader( SHADER_CODE, 0, 50, false, "vehicle" )
					if paint_shader then
						for _, texture_name in pairs( WHEELS_TEXTURES_PAINT ) do
							engineApplyShaderToWorldTexture( paint_shader, texture_name, vehicle )
						end
						STREAMED_VEHICLES[ vehicle ].paint_shader = paint_shader
						RENDERED_VEHICLES[ vehicle ].paint_shader = paint_shader
					end
				end
			end
			
			if main_shader then
				-- Изменяем эти значения в таймере, т.к. у машины могут поменяться колёса (соответственно conf_real тоже)
				conf_real = conf_real or DEFAULT_VEH_CONF.default
				dxSetShaderValue( main_shader, "Scale", conf_real[ 1 ] )
				dxSetShaderValue( main_shader, "Height", conf_real[ 2 ] )
				dxSetShaderValue( main_shader, "Width", conf_real[ 3 ] )

				local int_to_float_coef = 1 / 100

				local max_width = 0.3
				dxSetShaderValue( main_shader, "FrontWidth", front_width * int_to_float_coef * max_width )
				dxSetShaderValue( main_shader, "RearWidth", rear_width * int_to_float_coef * max_width )

				local max_camber = math.rad( 15 )
				dxSetShaderValue( main_shader, "FrontCamber", front_camber * int_to_float_coef * max_camber )
				dxSetShaderValue( main_shader, "RearCamber", rear_camber * int_to_float_coef * max_camber )

				local max_offset = 0.1
				front_offset = front_offset * int_to_float_coef * max_offset
				rear_offset = rear_offset * int_to_float_coef * max_offset
				WHEEL_COMPONENTS_OFFSETS[ 1 ] = -front_offset
				WHEEL_COMPONENTS_OFFSETS[ 2 ] = front_offset
				WHEEL_COMPONENTS_OFFSETS[ 3 ] = -rear_offset
				WHEEL_COMPONENTS_OFFSETS[ 4 ] = rear_offset
				for i, component in pairs( WHEEL_COMPONENTS ) do
					resetVehicleComponentPosition( vehicle, component )
					local x, y, z = getVehicleComponentPosition( vehicle, component )
					if x then
						setVehicleComponentPosition( vehicle, component, x + WHEEL_COMPONENTS_OFFSETS[ i ], y, z )
					end
				end
				
				if paint_shader then
					dxSetShaderValue( paint_shader, "Scale",  conf_real[ 1 ] )
					dxSetShaderValue( paint_shader, "Height", conf_real[ 2 ] )
					dxSetShaderValue( paint_shader, "Width",  conf_real[ 3 ] )
	
					dxSetShaderValue( paint_shader, "FrontWidth", front_width * int_to_float_coef * max_width )
					dxSetShaderValue( paint_shader, "RearWidth",  rear_width * int_to_float_coef * max_width )
	
					dxSetShaderValue( paint_shader, "FrontCamber", front_camber * int_to_float_coef * max_camber )
					dxSetShaderValue( paint_shader, "RearCamber", rear_camber * int_to_float_coef * max_camber )
	
					if ( vehicle:GetWheels() or 0 ) ~= 0 then
						local wr, wg, wb = vehicle:GetWheelsColor()
						dxSetShaderValue( paint_shader, "rgba", wr or 255, wg or 255, wb or 255, 255 )
					end
				end
			end
		else
			if isElement( shader_data and shader_data.main_shader ) then destroyElement( shader_data.main_shader ) end
			if isElement( shader_data and shader_data.paint_shader ) then destroyElement( shader_data.paint_shader ) end
			STREAMED_VEHICLES[ vehicle ] = false
			if RENDERED_VEHICLES[ vehicle ] then
				RENDERED_VEHICLES[ vehicle ] = nil
			end
			for i, component in pairs( WHEEL_COMPONENTS ) do
				resetVehicleComponentPosition( vehicle, component )
			end
		end
	end
end
Timer( UpdateVehicleWheelsStuff, 250, 0 )

function onClientElementStreamOut_handler()
	local shader_data = STREAMED_VEHICLES[ source ]
	if isElement( shader_data and shader_data.main_shader ) then destroyElement( shader_data.main_shader ) end
	if isElement( shader_data and shader_data.paint_shader ) then destroyElement( shader_data.paint_shader ) end

	STREAMED_VEHICLES[ source ] = nil
	RENDERED_VEHICLES[ source ] = nil
	for i, component in pairs( WHEEL_COMPONENTS ) do
		resetVehicleComponentPosition( source, component )
	end

	removeEventHandler( "onClientElementStreamOut", source, onClientElementStreamOut_handler )
	removeEventHandler( "onClientElementDestroy", source, onClientElementStreamOut_handler )
end

function onClientElementStreamIn_handler( vehicle )
	local vehicle = vehicle or source
	if getElementType( vehicle ) ~= "vehicle" then return end
	local vehicle_type = getVehicleType( vehicle )
	if IGNORED_VEHICLE_TYPES[ vehicle_type ] then return end
	if STREAMED_VEHICLES[vehicle] ~= nil then return end
	STREAMED_VEHICLES[ vehicle ] = false

	addEventHandler( "onClientElementStreamOut", vehicle, onClientElementStreamOut_handler, false )
	addEventHandler( "onClientElementDestroy", vehicle, onClientElementStreamOut_handler, false )
end
addEventHandler( "onClientElementStreamIn", root, onClientElementStreamIn_handler )

function onClientResourceStart_handler( )
	for _, vehicle in pairs( getElementsByType( "vehicle", root, true ) ) do
		onClientElementStreamIn_handler( vehicle )
	end
end
addEventHandler( "onClientResourceStart", resourceRoot, onClientResourceStart_handler )