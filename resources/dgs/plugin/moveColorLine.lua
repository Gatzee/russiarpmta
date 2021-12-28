-- LUA Script Berserker

function dgsColorPickerCreateComponentSelectorMove(x,y,w,h,image,mask,voh,relative,parent,color,thickness,offset,selImg,selColor)
	local selector
	local ColorPickerMove = dgsCreateImage(x,y,w,h,image,relative,parent)
	local rt = dxCreateRenderTarget( w,h,true )
	thickness = thickness or 2
	offset = offset or 4
	if not selImg then
		selector = dgsCreateImage(0,-offset,thickness,h+offset*2,_,false,ColorPickerMove)
	else
		offset = offset*0.5
		selector = dgsCreateImage(0,-offset*0.5,h+offset,h+offset,selImg or false,false,ColorPickerMove, selColor or 0xFFFFFFFF)
	end
	local shader = dxCreateShader("plugin/ColorPicker/HSVComponent_m.fx")
	dxSetShaderValue(shader,"StaticMode",{1,0,0})
	dxSetShaderValue(shader,"vertical",voh or false)
	dxSetShaderValue(shader,"isReversed",false)
	if isElement( mask ) then dxSetShaderValue(shader,"sMaskTexture",mask) end
	dgsSetEnabled(selector,false)
	dgsSetData(ColorPickerMove,"thickness",thickness)
	dgsSetData(ColorPickerMove,"offset",offset)
	dgsSetData(ColorPickerMove,"asPlugin","dgs-dxcomponentselector")
	dgsSetData(ColorPickerMove,"voh",voh)
	dgsSetData(ColorPickerMove,"cp_images",{ColorPickerMove,selector})
	dgsSetData(ColorPickerMove,"value",0)	--0~100
	dgsSetData(ColorPickerMove,"isReversed",false)
	addEventHandler("onDgsMouseDrag",ColorPickerMove,ComponentChange,false)
	addEventHandler("onDgsMouseClickDown",ColorPickerMove,ComponentChange,false)
	addEventHandler("onDgsSizeChange",ColorPickerMove,ComponentResize,false)
	addEventHandler("onDgsDestroy",ColorPickerMove,function()
		if isElement(dgsElementData[source].cp_shader) then
			destroyElement(dgsElementData[source].cp_shader)
		end
	end,false)
	
	local customRenderer = dgsCreateCustomRenderer([[
		local dgsElement = dgsElementData[self].dgsElement
		local image = dgsElementData[dgsElement].images
		local RT = dgsElementData[dgsElement].RTarget
		local color = dgsElementData[dgsElement].color
		local shader = dgsElementData[dgsElement].shader
		dxSetRenderTarget(RT, true)
			if shader then
				dxDrawImage( posX,posY,width,height, shader, 0, 0, 0, _, postGUI )
			end
			if image then
				dxDrawImage( posX,posY,width,height, image, 0, 0, 0, color, postGUI )
			end
		dxSetRenderTarget()
		dxDrawImage( posX,posY,width,height, RT, 0, 0, 0, _, postGUI )
		
	]])
	dgsSetProperty(ColorPickerMove,"asPlugin","dgs-dxmyplugin")
	dgsSetProperty(customRenderer,"dgsElement",ColorPickerMove)
	dgsSetProperty(ColorPickerMove,"cpTargetProp",{"HSV","H"})
	dgsSetProperty(ColorPickerMove,"shader",shader or false)
	dgsSetProperty(ColorPickerMove,"color",color or 0xFFFFFFFF)
	dgsSetProperty(ColorPickerMove,"RTarget",rt)
	dgsSetProperty(ColorPickerMove,"mask",mask or false)
	dgsSetProperty(ColorPickerMove,"images",image or false)
	dgsSetProperty(ColorPickerMove,"image",customRenderer)
	
	dgsAttachToAutoDestroy(customRenderer,ColorPickerMove,-1)	-- Use index "-1" as the meaning of "built-in"
	triggerEvent("onDgsPluginCreate",ColorPickerMove,sourceResource)
	-- dgsBindToColorPicker(ColorPickerMove,cpElem,"HSV","H",true,false)
	return ColorPickerMove
end