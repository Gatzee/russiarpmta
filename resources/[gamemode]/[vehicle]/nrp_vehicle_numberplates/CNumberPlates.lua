-- Обработчик номеров
loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShVehicleConfig" )
Extend( "CVehicle" )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ib" )

local SHADER_CODE = [[
	texture gTexture;

	technique TexReplace
	{
		pass P0
		{
			Texture[0] = gTexture;
		}
	}
]]

local fPlateScale = 1

local fonts = 
{
	RobotoBold15		= dxCreateFont("files/font.ttf", 15*fPlateScale),
	RobotoBold40		= dxCreateFont("files/font.ttf", 40*fPlateScale),
	RobotoBold45		= dxCreateFont("files/font.ttf", 45*fPlateScale),
	RobotoBold59		= dxCreateFont("files/font.ttf", 59*fPlateScale),
	RealFont			= dxCreateFont("files/font.ttf", 38),
	RealFontRegion		= dxCreateFont("files/font.ttf", 28),
}

local CONST_IGNORED_VEHICLES = {
	[ 463 ] = true
}

-- Оптимизируем.
local dxDrawImage			= dxDrawImage;
local dxDrawText 			= dxDrawText;
local dxCreateRenderTarget 	= dxCreateRenderTarget;
local dxSetRenderTarget 	= dxSetRenderTarget;
local destroyElement		= destroyElement;
local tocolor				= tocolor;

local iPlateSizeX, iPlateSizeY = 512, 128

local aTexturesReplace =
{
	"numb";
	"numb1";
	"custom_car_plate";
	"white";
	"nomera";
	"rpbox_nomer";
	"rpbox_bk_nm";
	"rp_bk_nm";
}

local sPath = "files/img/plates/"

local pPlateTypes = 
{
	[ PLATE_TYPE_AUTO ] 		= -- Автомобильные
	{
		Background 		= dxCreateTexture(sPath.."number_ru.png");
		Background_CH	= dxCreateTexture(sPath.."number_flag_CH.png");
		Background_GE	= dxCreateTexture(sPath.."number_flag_GE.png");
		Background_KZ	= dxCreateTexture(sPath.."number_flag_KZ.png");
		Background_RU	= dxCreateTexture(sPath.."number_flag_RU.png");
		Background_UK	= dxCreateTexture(sPath.."number_flag_UK.png");

		sDefault = "01:о000оо99",

		iPosX = 0;
		iPosY = 200;

		iSizeX = 489; 
		iSizeY = 90;

		Texts = {
			{
				x = 50, y = 213,
				len = 1,
				color = "#000000",
				font = fonts.RealFont,
			},
			{
				x = 99, y = 213,
				len = 1,
				color = "#000000",
				font = fonts.RealFont,
			},
			{
				x = 145, y = 213,
				len = 1,
				color = "#000000",
				font = fonts.RealFont,
			},
			{
				x = 191, y = 213,
				len = 1,
				color = "#000000",
				font = fonts.RealFont,
			},
			{
				x = 240, y = 213,
				len = 1,
				color = "#000000",
				font = fonts.RealFont,
			},
			{
				x = 288, y = 213,
				len = 1,
				color = "#000000",
				font = fonts.RealFont,
			},

			{
				x = 325, y = 183,
				size_x = 489-330, size_y = 100,
				offset_x = "center", offset_y = "center",
				len = 3,
				color = "#000000",
				font = fonts.RealFontRegion,
			},

			Named =
			{
				x = 25, y = 31,
				len = 7,
				color = "#000000",
			}
		},
	};

	[ PLATE_TYPE_ARMY ] 		= -- Военные
	{
		Background 		= dxCreateTexture(sPath.."number_black.png");

		sDefault = "05:0000оо99",

		iPosX = 0;
		iPosY = 200;

		iSizeX = 489; 
		iSizeY = 90;

		Texts = {
			{
				x = 53, y = 212,
				len = 1,
				color = "#FFFFFF",
				font = fonts.RealFont,
			},
			{
				x = 99, y = 212,
				len = 1,
				color = "#FFFFFF",
				font = fonts.RealFont,
			},
			{
				x = 145, y = 212,
				len = 1,
				color = "#FFFFFF",
				font = fonts.RealFont,
			},
			{
				x = 191, y = 212,
				len = 1,
				color = "#FFFFFF",
				font = fonts.RealFont,
			},
			{
				x = 265, y = 212,
				len = 1,
				color = "#FFFFFF",
				font = fonts.RealFont,
			},
			{
				x = 310, y = 212,
				len = 1,
				color = "#FFFFFF",
				font = fonts.RealFont,
			},
			{
				x = 335, y = 183,
				size_x = 489-330, size_y = 100,
				offset_x = "center", offset_y = "center",
				len = 3,
				color = "#FFFFFF",
				font = fonts.RealFontRegion,
			},

			Named =
			{
				x = 25, y = 31,
				len = 7,
				color = "#000000",
			}
		},
	};

	[ PLATE_TYPE_POLICE ] 		= -- Военные
	{
		Background 		= dxCreateTexture(sPath.."number_police.png");

		sDefault = "06:о000099",

		iPosX = 0;
		iPosY = 198;

		iSizeX = 489; 
		iSizeY = 90;

		Texts = {
			{
				x = 60, y = 211,
				len = 1,
				color = "#FFFFFF",
				font = fonts.RealFont,
			},
			{
				x = 137, y = 211,
				len = 1,
				color = "#FFFFFF",
				font = fonts.RealFont,
			},
			{
				x = 183, y = 211,
				len = 1,
				color = "#FFFFFF",
				font = fonts.RealFont,
			},
			{
				x = 229, y = 211,
				len = 1,
				color = "#FFFFFF",
				font = fonts.RealFont,
			},
			{
				x = 275, y = 211,
				len = 1,
				color = "#FFFFFF",
				font = fonts.RealFont,
			},
			{
				x = 335, y = 183,
				size_x = 489-330, size_y = 100,
				offset_x = "center", offset_y = "center",
				len = 3,
				color = "#FFFFFF",
				font = fonts.RealFontRegion,
			},

			Named =
			{
				x = 25, y = 31,
				len = 7,
				color = "#000000",
			}
		},
	};

	[ PLATE_TYPE_TAXI ] 		= -- Такси и автобусы
	{
		Background 		= dxCreateTexture(sPath.."number_bus.png");

		sDefault = "04:оо00099",

		iPosX = 0;
		iPosY = 200;

		iSizeX = 489; 
		iSizeY = 90;

		Texts = {
			{
				x = 60, y = 211,
				len = 1,
				color = "#000000",
				font = fonts.RealFont,
			},
			{
				x = 105, y = 211,
				len = 1,
				color = "#000000",
				font = fonts.RealFont,
			},
			{
				x = 183, y = 211,
				len = 1,
				color = "#000000",
				font = fonts.RealFont,
			},
			{
				x = 229, y = 211,
				len = 1,
				color = "#000000",
				font = fonts.RealFont,
			},
			{
				x = 275, y = 211,
				len = 1,
				color = "#000000",
				font = fonts.RealFont,
			},

			{
				x = 335, y = 183,
				size_x = 489-330, size_y = 100,
				offset_x = "center", offset_y = "center",
				len = 3,
				color = "#000000",
				font = fonts.RealFontRegion,
			},

			Named =
			{
				x = 25, y = 31,
				len = 7,
				color = "#000000",
			}
		},
	};

	[ PLATE_TYPE_MOTO ] 			=  -- Мотоциклы
	{
		Background 		= dxCreateTexture(sPath.."number_moto.png");

		sDefault = "02:00000099",

		Texts = {

			{
				x = 0, y = 91,
				size_x = 256, size_y = 70,
				offset_x = "center", offset_y = "center",
				len = 4,
				color = "#000000",
				font = fonts.RealFont,
			},

			{
				x = 0, y = 171,
				size_x = 145, size_y = 70,
				offset_x = "center", offset_y = "center",
				len = 2,
				color = "#000000",
				font = fonts.RealFont,
			},

			{
				x = 115, y = 177,
				size_x = 140, size_y = 70,
				offset_x = "center", offset_y = "center",
				len = 2,
				color = "#000000",
				font = fonts.RealFontRegion,
			},

			Named =
			{
				x = 25, y = 31,
				len = 4,
				color = "#000000",
				font = fonts.RealFont,
			}
		},

		iPosX = 0;
		iPosY = 70;
		iSizeX = 256; 
		iSizeY = 190;
	};

	[ PLATE_TYPE_SPECIAL ] 		= -- Автомобильные донатные
	{
		Background 		= dxCreateTexture(sPath.."number_ru.png");
		Background_CH	= dxCreateTexture(sPath.."number_flag_CH.png");
		Background_GE	= dxCreateTexture(sPath.."number_flag_GE.png");
		Background_KZ	= dxCreateTexture(sPath.."number_flag_KZ.png");
		Background_RU	= dxCreateTexture(sPath.."number_flag_RU.png");
		Background_UK	= dxCreateTexture(sPath.."number_flag_UK.png");

		sDefault = "07:о000оо99",

		iPosX = 0;
		iPosY = 200;

		iSizeX = 489; 
		iSizeY = 90;

		Texts = {
			{
				x = 0, y = 180,
				size_x = 390, size_y = 128,
				offset_x = "center", offset_y = "center",
				len = 6,
				color = "#000000",
				font = ibFonts.bold_45,
			},

			{
				x = 325, y = 183,
				size_x = 489-330, size_y = 100,
				offset_x = "center", offset_y = "center",
				len = 3,
				color = "#000000",
				font = fonts.RealFontRegion,
			},
		},
	};
}

local pPlates = {}

local STREAMED_VEHS = { }

local symbol_convert = {
	[ "а" ] = "a";
	[ "в" ] = "b";
	[ "с" ] = "c";
	[ "е" ] = "e";
	[ "н" ] = "h";
	[ "к" ] = "k";
	[ "м" ] = "m";
	[ "о" ] = "o";
	[ "р" ] = "p";
	[ "т" ] = "t";
	[ "х" ] = "x";
	[ "у" ] = "y";
}

function GenerateNumberPlate( sNumber, pColor )
	local sNumber = sNumber and sNumber ~= "" and sNumber or "01:о123ук99"
	local pNumbers = split(sNumber, ":")
	local iType = tonumber(pNumbers[1])
	local pData = pPlateTypes[iType] or pPlateTypes[1]
	local bNamed = sNumber[3]
	local pColor = pColor or {255,255,255}

	local pRenderTarget = dxCreateRenderTarget( (pData.iSizeX or iPlateSizeX) * fPlateScale, (pData.iSizeX or iPlateSizeX) * fPlateScale )

	if not isElement( pRenderTarget ) then return end

	dxSetRenderTarget( pRenderTarget, true )
		-- BG
		local bg = pData.Background

		if iType == PLATE_TYPE_SPECIAL or iType == PLATE_TYPE_AUTO then
			local len = utf8.len( pNumbers[2] )
			local region = utf8.sub( pNumbers[2], len - 1, len )

			bg = pData[ "Background_" .. region ] or pData.Background
		end

		dxDrawRectangle( (pData.iPosX or 0) + 15, pData.iPosY or 0, ((pData.iSizeX or iPlateSizeX) - 30) * fPlateScale, (pData.iSizeY or iPlateSizeY) * fPlateScale, tocolor(unpack(pColor)) )
		dxDrawImage((pData.iPosX or 0) + 15, pData.iPosY or 0, ((pData.iSizeX or iPlateSizeX) - 30) * fPlateScale, (pData.iSizeY or iPlateSizeY) * fPlateScale, bg, 0, 0, 0, tocolor(255,255,255) )

		-- TEXTS
		if iType == PLATE_TYPE_SPECIAL then
			local parts = {
				utf8.sub( pNumbers[2], 1, utf8.len( pNumbers[2] ) - 2 ),
				utf8.sub( pNumbers[2], utf8.len( pNumbers[2] ) - 1 ),
			}

			for k, v in pairs( pData.Texts ) do
				local iColor = tocolor( getColorFromString( v.color or "#ffffff" ) )
				local font_scale = 1
				local len = utf8.len( parts[k] )

				if k == 1 then
					if len == 7 then
						font_scale = 0.9
					elseif len >= 8 then
						font_scale = 0.8
					end
				end

				if k == #pData.Texts and not tonumber( parts[ k ] ) then break end

				dxDrawText(parts[k], v.x * fPlateScale, v.y * fPlateScale, ( v.x + ( v.size_x or 300 ) ) * fPlateScale, ( v.y + (v.size_y or 50) ) * fPlateScale, iColor, font_scale, v.font, v.offset_x or "left", v.offset_y or "top")
			end
		else
			local iStartFrom = 1
			for k,v in ipairs(pData.Texts) do
				local sPart = utf8.sub( pNumbers[2], iStartFrom, iStartFrom + v.len - 1 )
				
				if utf8.len( sPart ) == 2 and not tonumber( sPart ) then break end

				sPart = symbol_convert[ utf8.lower( sPart ) ] or sPart
				local iColor = tocolor( getColorFromString( v.color or "#ffffff" ) )

				dxDrawText(utf8.upper(sPart), v.x * fPlateScale, v.y * fPlateScale, ( v.x + ( v.size_x or 300 ) ) * fPlateScale, ( v.y + (v.size_y or 50) ) * fPlateScale, iColor, 1, v.font, v.offset_x or "left", v.offset_y or "top")
				iStartFrom = iStartFrom + v.len
			end
		end
	dxSetRenderTarget()

	return pRenderTarget
end

local pDefaultTextures = {}
local pDefaultNumbers = {}
for k,v in pairs(pPlateTypes) do
	pDefaultTextures[k] = dxCreateTexture( dxGetTexturePixels( GenerateNumberPlate(v.sDefault) ) )
	pDefaultNumbers[k] = dxCreateShader( SHADER_CODE )
	dxSetShaderValue(pDefaultNumbers[k], "gTexture", pDefaultTextures[k])
end

function UpdateVehicleNumberPlate( pVehicle )
	DestroyVehicleNumberPlate( pVehicle )

	local sNumber = pVehicle:GetNumberPlate( nil, true )

	if not sNumber or sNumber == "" then
		local iPlateType = ( VEHICLE_CONFIG[ pVehicle.model ] or { } ).is_moto and PLATE_TYPE_MOTO or PLATE_TYPE_AUTO
		local shader = pDefaultNumbers[iPlateType]
		for k,v in pairs( aTexturesReplace ) do
			engineApplyShaderToWorldTexture( shader, v, pVehicle )
		end

		return true
	end

	local shader = dxCreateShader( SHADER_CODE, 0, 30, false, "vehicle" )
	if not isElement( shader ) then return end

	local r,g,b = 255, 255, 255
	if string.find(sNumber, "#%x%x%x%x%x%x") then
		r, g, b = hex2rgb(sNumber)
	end
	local tex = GenerateNumberPlate( sNumber:RemoveHex(), {r,g,b} )
	if not isElement( tex ) then
		if isElement( shader ) then destroyElement( shader ) end
		return
	end

	dxSetShaderValue(shader, "gTexture", tex)
	for k,v in pairs( aTexturesReplace ) do
		engineApplyShaderToWorldTexture( shader, v, pVehicle )
	end
	pPlates[pVehicle] = { shader, tex }
end

function DestroyVehicleNumberPlate( pVehicle )
	if pPlates[pVehicle] then
		for k,v in pairs(pPlates[pVehicle]) do
			if isElement(v) then
				destroyElement( v )
			end
		end
		pPlates[pVehicle] = nil
	end
end

addEventHandler("onClientRestore",root,function( bState )
	if bState then
		for k,v in pairs( pPlates ) do
			if isElement( k ) then
				onClientElementStreamOut_handler( k )
			elseif isElement( v ) then
				destroyElement( v )
			end
		end
		pPlates = {}

		for k,v in pairs( getElementsByType( "vehicle", root, true ) ) do
			onClientElementStreamIn_handler( v )
		end
	end
end)

function onClientElementStreamIn_handler( vehicle )
	local vehicle = vehicle or source

	if getElementType( vehicle ) ~= "vehicle" then return end
	if CONST_IGNORED_VEHICLES[ vehicle.model ] then return end
	if STREAMED_VEHS[ vehicle ] then return end

	UpdateVehicleNumberPlate( vehicle )
	addEventHandler( "onClientElementStreamOut", vehicle, onClientElementStreamOut_handler )
	addEventHandler( "onClientElementDestroy", vehicle, onClientElementStreamOut_handler )
	addEventHandler( "onClientElementDataChange", vehicle, onClientElementDataChange_handler )
	STREAMED_VEHS[ vehicle ] = true
end
addEventHandler( "onClientElementStreamIn", root, onClientElementStreamIn_handler )

function onClientElementDataChange_handler( key )
	if key ~= "_numplate" then return end
	UpdateVehicleNumberPlate( source )
end

function onClientElementStreamOut_handler( vehicle )
	local vehicle = vehicle or source
	STREAMED_VEHS[ vehicle ] = nil
	if pPlates[ vehicle ] then
		for k, v in pairs( pPlates[ vehicle ] ) do
			if isElement( v ) then
				destroyElement( v )
			end
		end
		pPlates[ vehicle ] = nil
	end
	removeEventHandler( "onClientElementStreamOut", vehicle, onClientElementStreamOut_handler )
	removeEventHandler( "onClientElementDestroy", vehicle, onClientElementStreamOut_handler )
	removeEventHandler( "onClientElementDataChange", vehicle, onClientElementDataChange_handler )
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	for k,v in pairs( getElementsByType( "vehicle", root, true ) ) do
		onClientElementStreamIn_handler( v )
	end
end)