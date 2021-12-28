-- LUA Script Berserker

local dxDrawImage = dxDrawImageExt
local dxDrawImageSection = dxDrawImageSectionExt

function string.getPath(res,path)
    if res and res ~= "global" then
        path = path:gsub("\\","/")
        if not path:find(":") and not path:find("*") then
            path = ":"..getResourceName(res).."/"..path
            path = path:gsub("//","/") or path
        end
    end
    return path
end

function dgsImageCreateTextureExternal(image,res,img)
	local ex = img
	img = string.getPath(res,img)
	local texture = img
	if not ex:find("*") then
		if isElement(texture) then
			dgsElementData[texture] = {parent=image}
			dgsAttachToAutoDestroy(texture,image)
			return texture,true
		end
	else
		return img,true
	end
	return false
end

dgsRenderer["dgs-dximage"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local colors,imgs = eleData.color,eleData.image
	colors = applyColorAlpha(colors,parentAlpha)
	if isElement(imgs) then
		local rotCenter = eleData.rotationCenter
		local rotOffx,rotOffy = rotCenter[3] and w*rotCenter[1] or rotCenter[1],rotCenter[3] and h*rotCenter[2] or rotCenter[2]
		local rot = eleData.rotation or 0
		local shadow = eleData.shadow
		local shadowoffx,shadowoffy,shadowc,shadowIsOutline
		if shadow then
			shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
		end
		local materialInfo = eleData.materialInfo
		local uvPx,uvPy,uvSx,uvSy
		if materialInfo[0] ~= imgs then	--is latest?
			materialInfo[0] = imgs	--Update if not
			if dgsGetType(imgs) == "texture" then
				materialInfo[1],materialInfo[2] = dxGetMaterialSize(imgs)
			else
				materialInfo[1],materialInfo[2] = 1,1
			end
		end
		local uvPos = eleData.UVPos
		local px,py,pRlt = uvPos[1],uvPos[2],uvPos[3]
		if px and py then
			uvPx = pRlt and px*materialInfo[1] or px
			uvPy = pRlt and py*materialInfo[2] or py
			local uvSize = eleData.UVSize
			local sx,sy,sRlt = uvSize[1] or 1,uvSize[2] or 1,uvSize[3] or true
			uvSx = pRlt and sx*materialInfo[1] or sx
			uvSy = sRlt and sy*materialInfo[2] or sy
		end
		if uvPx then
			if shadowoffx and shadowoffy and shadowc then
				local shadowc = applyColorAlpha(shadowc,parentAlpha)
				dxDrawImageSection(x+shadowoffx,y+shadowoffy,w,h,uvPx,uvPy,uvSx,uvSy,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
				if shadowIsOutline then
					dxDrawImageSection(x-shadowoffx,y+shadowoffy,w,h,uvPx,uvPy,uvSx,uvSy,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
					dxDrawImageSection(x-shadowoffx,y-shadowoffy,w,h,uvPx,uvPy,uvSx,uvSy,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
					dxDrawImageSection(x+shadowoffx,y-shadowoffy,w,h,uvPx,uvPy,uvSx,uvSy,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
				end
			end
			dxDrawImageSection(x,y,w,h,uvPx,uvPy,uvSx,uvSy,imgs,rot,rotOffy,rotOffy,colors,isPostGUI,rndtgt)
		else
			if shadowoffx and shadowoffy and shadowc then
				local shadowc = applyColorAlpha(shadowc,parentAlpha)
				dxDrawImage(x+shadowoffx,y+shadowoffy,w,h,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
				if shadowIsOutline then
					dxDrawImage(x-shadowoffx,y+shadowoffy,w,h,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
					dxDrawImage(x-shadowoffx,y-shadowoffy,w,h,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
					dxDrawImage(x+shadowoffx,y-shadowoffy,w,h,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
				end
			end
			dxDrawImage(x,y,w,h,imgs,rot,rotOffx,rotOffy,colors,isPostGUI,rndtgt)
		end
	else
		if type(imgs) == "string" then
			local rotCenter = eleData.rotationCenter
			local rotOffx,rotOffy = rotCenter[3] and w*rotCenter[1] or rotCenter[1],rotCenter[3] and h*rotCenter[2] or rotCenter[2]
			local rot = eleData.rotation or 0
			local shadow = eleData.shadow
			local shadowoffx,shadowoffy,shadowc,shadowIsOutline
			if shadow then
				shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
			end
			local materialInfo = eleData.materialInfo
			local uvPx,uvPy,uvSx,uvSy
			if materialInfo[0] ~= imgs then	--is latest?
				materialInfo[0] = imgs	--Update if not
			end
			local uvPos = eleData.UVPos
			local px,py,pRlt = uvPos[1],uvPos[2],uvPos[3]
			if px and py then
				uvPx = pRlt and px*materialInfo[1] or px
				uvPy = pRlt and py*materialInfo[2] or py
				local uvSize = eleData.UVSize
				local sx,sy,sRlt = uvSize[1] or 1,uvSize[2] or 1,uvSize[3] or true
				uvSx = pRlt and sx*materialInfo[1] or sx
				uvSy = sRlt and sy*materialInfo[2] or sy
			end
			if uvPx then
				if shadowoffx and shadowoffy and shadowc then
					local shadowc = applyColorAlpha(shadowc,parentAlpha)
					dxDrawImageSection(x+shadowoffx,y+shadowoffy,w,h,uvPx,uvPy,uvSx,uvSy,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
					if shadowIsOutline then
						dxDrawImageSection(x-shadowoffx,y+shadowoffy,w,h,uvPx,uvPy,uvSx,uvSy,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
						dxDrawImageSection(x-shadowoffx,y-shadowoffy,w,h,uvPx,uvPy,uvSx,uvSy,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
						dxDrawImageSection(x+shadowoffx,y-shadowoffy,w,h,uvPx,uvPy,uvSx,uvSy,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
					end
				end
				dxDrawImageSection(x,y,w,h,uvPx,uvPy,uvSx,uvSy,imgs,rot,rotOffy,rotOffy,colors,isPostGUI,rndtgt)
			else
				if shadowoffx and shadowoffy and shadowc then
					local shadowc = applyColorAlpha(shadowc,parentAlpha)
					dxDrawImage(x+shadowoffx,y+shadowoffy,w,h,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
					if shadowIsOutline then
						dxDrawImage(x-shadowoffx,y+shadowoffy,w,h,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
						dxDrawImage(x-shadowoffx,y-shadowoffy,w,h,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
						dxDrawImage(x+shadowoffx,y-shadowoffy,w,h,imgs,rot,rotOffx,rotOffy,shadowc,isPostGUI,rndtgt)
					end
				end
				dxDrawImage(x,y,w,h,imgs,rot,rotOffx,rotOffy,colors,isPostGUI,rndtgt)
			end
		else
			dxDrawRectangle(x,y,w,h,colors,isPostGUI)
		end
	end
	return rndtgt,false,mx,my,0,0
end

addEventHandler( "onDgsDestroy", resourceRoot, function()
	if dgsGetType(source) == 'dgs-dximage' then
		local texture = dgsImageGetImage( source )
		if texture and not isElement(texture) then
			if type(texture) == "string" then
				destroyAutoTexture( texture )
			end
		end
	end
end )