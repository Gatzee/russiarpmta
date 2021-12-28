loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "Globals" )
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "ShUtils" )

local fScale = 1.4;
local fWidth, fHeight = math.ceil( 40 * fScale ), math.ceil( 6 * fScale );
local fBorder = math.ceil( 1.2 * fScale );
local pFont = exports.nrp_fonts:DXFont("OpenSans/OpenSans-Bold.ttf", 14, false, "default")

local recsx,recsy = fWidth - 2 * fBorder, fHeight - 2 * fBorder
local recsy1 = fHeight - 2 * fBorder

local hpr, hpg, hpb	= 180, 25, 29;

local onedivhundred_bar = ( fWidth - 2 * fBorder ) / 100

local tocolor = tocolor
local math_min = math.min
local math_floor = math.floor
local getCameraTarget = getCameraTarget
local getScreenFromWorldPosition = getScreenFromWorldPosition
local dxDrawText = dxDrawText
local dxDrawRectangle = dxDrawRectangle
local getElementsByType = getElementsByType
local string_match = string.match
local tostring = tostring

local function Draw(pElement, fDistance, vecPlayerPosition)
	local vecPosition;

	if getElementType(pElement) == "player" then
		vecPosition			= Vector3(getPedBonePosition(pElement, 4));

		vecPosition.z		= vecPosition.z + .5;
	else
		vecPosition			= pElement.position;

		vecPosition.z		= vecPosition.z + .9;
	end

	local fScreenX, fScreenY = getScreenFromWorldPosition( vecPosition.x, vecPosition.y, vecPosition.z );

	if fScreenX then
		local r, g, b 	= 255, 255, 255;
		local fCurrentDistance	= (vecPlayerPosition - vecPosition ).length
		local fAlpha	= Lerp( 255, 0, fCurrentDistance / fDistance );
		local sText		= pElement:GetID()

		local iColor3	= tocolor( 0, 0, 0, fAlpha );

		if getElementType(pElement) == "player" then
			sText = "PlayerID: ".. tostring(sText) .. "\nUserID: " .. tostring(pElement:GetUserID());

		elseif getElementType(pElement) == "vehicle" then
			sText = "VehicleID: ".. tostring(sText) .. "\nOwner: " .. tostring(pElement:GetOwnerID()) .."\nFlags: ".. tostring(pElement:getData("veh_flags"))

		elseif getElementType(pElement) == "teleport_points" then
			sText = "TPointID: ".. tostring(pElement:getData("type"));
		end

		if sText then
			local Color = pElement:getData( 'Nametag::Color' );

			if Color then
				r, g, b		= Color[ 1 ], Color[ 2 ], Color[ 3 ];
			end

			local iColor1	= tocolor( r, g, b, fAlpha );

			local fShiftedY = fScreenY - 20;

			local fsxp1 = fScreenX + 1
			local fsxm1 = fScreenX - 1
			local fsyp1 = fShiftedY + 1
			local fsym1 = fShiftedY - 1
			dxDrawText( sText, fsxp1, fsyp1, fsxp1, fsyp1, iColor3, 1.0, pFont, 'center', 'bottom' );
			dxDrawText( sText, fsxm1, fsym1, fsxm1, fsym1, iColor3, 1.0, pFont, 'center', 'bottom' );
			dxDrawText( sText, fsxp1, fsym1, fsxp1, fsym1, iColor3, 1.0, pFont, 'center', 'bottom' );
			dxDrawText( sText,fsxm1, fsyp1, fsxm1, fsyp1, iColor3, 1.0, pFont, 'center', 'bottom' );
			dxDrawText( sText, fScreenX, fShiftedY, fScreenX, fShiftedY, iColor1, 1.0, pFont, 'center', 'bottom' );
		end

		local fHealth = getElementHealth(pElement);
		if fHealth then
			fScreenY		= fScreenY + 8;

			fScreenX		= fScreenX - fWidth / 2;

			if getElementType(pElement) == "player" then
				fHealth	= math_min( 100, fHealth );
			else
				fHealth	= math_min( 1000, fHealth );
				fHealth = fHealth / 10
			end

			local iColor1	= tocolor( hpr, hpg, hpb, fAlpha );
			local iColor2	= tocolor( hpr, hpg, hpb, fAlpha * 0.4 );

			local rpx,rpy = fScreenX + fBorder,fScreenY + fBorder
			dxDrawRectangle( rpx, rpy, recsx, recsy, iColor2 );
			local recsx1 = math_floor( onedivhundred_bar * fHealth )
			dxDrawRectangle( rpx, rpy, recsx1, recsy1, iColor1 );
		end
	end
end;

local _, h = guiGetScreenSize();
local x = 10;
local y = h - 10;

local xp1 = x + 1
local xm1 = x - 1
local yp1 = y + 1
local ym1 = y - 1

local distance_vehicles = 80
local distance_players = 360
local distance_colshapes = 80

function AdminModeRender()
	if localPlayer:IsAdminMode() then
		local vecPlayerPosition	= getCameraTarget() and getCameraTarget().position or Vector3(getCameraMatrix());
		
		local vehicles = getElementsByType( "vehicle", root, true )
		local players = getElementsByType( "player", root, true )
		local colshapes = getElementsByType( "teleport_points", root, true )

		for _, pVehicle in pairs( vehicles ) do
			if isElement(pVehicle) and (pVehicle.position - vecPlayerPosition).length < distance_vehicles then
				Draw( pVehicle, distance_vehicles, vecPlayerPosition );
			end
		end

		for _, pPlayer in pairs( players ) do
			if pPlayer ~= localPlayer then
				if isElement(pPlayer) and (pPlayer.position - vecPlayerPosition).length < distance_players then
					Draw( pPlayer, distance_players, vecPlayerPosition );
				end
			end
		end

		for _, aColshape in pairs( colshapes ) do
			if isElement(aColshape) and (aColshape.position - vecPlayerPosition).length < distance_colshapes then
				Draw( aColshape, distance_colshapes, vecPlayerPosition );
			end
		end

		local sText = localPlayer:GetNickName() .. " (pID:" .. string_match(tostring(localPlayer:GetID()),"%d+") .. ")(cID:".. tostring(localPlayer:GetUserID()) ..")";
		local color = 0xFFFFFFFF;

		local Color = localPlayer:getData( 'Nametag::Color' );
		if Color then
			r, g, b = Color[ 1 ], Color[ 2 ], Color[ 3 ];
			color = tocolor( r, g, b, 0xFF );
		end

		dxDrawText( sText, xp1, yp1, xp1, yp1, 0xFF000000, 1.0, pFont, 'left', 'bottom' );
		dxDrawText( sText, xm1, ym1, xm1, ym1, 0xFF000000, 1.0, pFont, 'left', 'bottom' );
		dxDrawText( sText, xp1, ym1, xp1, ym1, 0xFF000000, 1.0, pFont, 'left', 'bottom' );
		dxDrawText( sText, xm1, yp1, xm1, yp1, 0xFF000000, 1.0, pFont, 'left', 'bottom' );
		dxDrawText( sText, x, y, x, y, color, 1.0, pFont, 'left', 'bottom' );
	end
end

function refreshVehicleFlags()
	if not localPlayer:IsAdminMode() then return end
	if getElementType(source) ~= "vehicle" then return end
	if localPlayer:GetAccessLevel() < ACCESS_LEVEL_DEVELOPER then return end

	-- triggerServerEvent("UpdateAdminVehiclesFlag", resourceRoot, {source})
end

function refreshVehiclesFlag()
	if not localPlayer:IsAdminMode() then return end
	if localPlayer:GetAccessLevel() < ACCESS_LEVEL_DEVELOPER then return end

	-- local vehicles_list = getElementsByType( "vehicle", root, true )
	-- triggerServerEvent("UpdateAdminVehiclesFlag", resourceRoot, vehicles_list)
end

function UpdateAdminVehiclesFlag(vehicles_list)
	for i, data in ipairs(vehicles_list) do
		if data[2] and type(data[2]) == "table" then
			local flags_list = {}
			for i,v in pairs(data[2]) do
				table.insert(flags_list, i)
			end
			data[1]:setData("veh_flags", table.concat(flags_list, ","), false)
		else
			data[1]:setData("veh_flags", "false", false)
		end
	end
end
addEvent("UpdateAdminVehiclesFlag", true)

-- Сворачиваем игру
function OnAdminModeMinimize()
	removeEventHandler("onClientRender", root, AdminModeRender)
end

-- Разворачиваем игру
function OnAdminModeRestore()
	OnAdminModeMinimize()
	addEventHandler("onClientRender", root, AdminModeRender)
end

FLAG_TIMER = nil
function onClientElementDataChange_handler( key )
	if key ~= "_amode" then return end

	removeEventHandler( "onClientRender", root, AdminModeRender )
	removeEventHandler( "onClientRestore", root, OnAdminModeRestore )
	removeEventHandler( "onClientResourceStart", resourceRoot, OnAdminModeRestore )
	removeEventHandler( "onClientMinimize", root, OnAdminModeMinimize )
	removeEventHandler( "onClientElementStreamIn", root, refreshVehicleFlags )
	removeEventHandler( "UpdateAdminVehiclesFlag", resourceRoot, UpdateAdminVehiclesFlag )
	if isTimer( FLAG_TIMER ) then killTimer( FLAG_TIMER ) end

	local value = localPlayer:getData( key )

	if value then
		addEventHandler( "onClientRender", root, AdminModeRender )
		addEventHandler( "onClientRestore", root, OnAdminModeRestore )
		addEventHandler( "onClientResourceStart", resourceRoot, OnAdminModeRestore )
		addEventHandler( "onClientMinimize", root, OnAdminModeMinimize )
		addEventHandler( "onClientElementStreamIn", root, refreshVehicleFlags )
		addEventHandler( "UpdateAdminVehiclesFlag", resourceRoot, UpdateAdminVehiclesFlag )
		FLAG_TIMER = setTimer( refreshVehiclesFlag, 5000, 0 )
	end
end
addEventHandler( "onClientElementDataChange", localPlayer, onClientElementDataChange_handler )