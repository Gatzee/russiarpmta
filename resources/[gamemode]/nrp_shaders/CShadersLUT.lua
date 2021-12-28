local scx, scy = guiGetScreenSize( )

LUT = { enabled = false }

function enableLUT( )
	if LUT.enabled then return end
	LUT.enabled = true

	LUT.shader = DxShader( "fx/lut.fx" )
	LUT.texture = DxTexture( "images/lut.dds", "argb", false )
	LUT.screen_source = DxScreenSource( scx , scy )

	if LUT.shader and LUT.screen_source and LUT.texture then
		LUT.shader:setValue( "sColorTex", LUT.screen_source )
		LUT.shader:setValue( "sLutTex", LUT.texture )
		
		LUT.shader:setValue( "fLUT_AmountChroma", 1.00 ) -- Intensity of color/chroma change of the LUT.

		LUT.shader:setValue( "fLUT_AmountLuma", 1.00 ) -- Intensity of luma change of the LUT.

		addEventHandler( "onClientHUDRender", root, onClientHUDRender_LUT, true, "high+101" )
	else
		disableLUT( )
	end
end

function disableLUT( )
	if not LUT.enabled then return end

	removeEventHandler( "onClientHUDRender", root, onClientHUDRender_LUT )

	if isElement( LUT.shader ) then
		LUT.shader:destroy( )
	end

	if isElement( LUT.texture ) then
		LUT.texture:destroy( )
	end

	if isElement( LUT.screen_source ) then
		LUT.screen_source:destroy( )
	end

	LUT = { }
end

function onClientHUDRender_LUT( )
	LUT.screen_source:update( true )
	dxDrawImage( 0, 0, scx, scy, LUT.shader )
end