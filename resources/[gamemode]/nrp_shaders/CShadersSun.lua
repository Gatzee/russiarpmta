SunShader = {}

function SunShader:enable( )
	if self.enabled then return end
	self.enabled = true

	self.screenWidth, self.screenHeight = guiGetScreenSize( )
	
	self.lensFlareDirt = dxCreateTexture( "images/lensflare_dirt.png" )
	self.lensFlareChroma = dxCreateTexture( "images/lensflare_chroma.png" )
	
	self.viewDistance = 0.00005
	
	self.sunColorInner = {0.9, 0.7, 0.6, 1}
	self.sunColorOuter = {0.85, 0.65, 0.55, 1}
	self.sunSize = 0.04
	self.godRayStrength = 0.8
	
	self.m_Update = function( ) self:update( ) end
	addEventHandler( "onClientPreRender", root, self.m_Update, true, "high+1" )
	
	if self:createShaders( ) then
		self.sun = Sun:create( )
	else
		self:disable( )
	end
end

function SunShader:createShaders( )
	self.screenSource = dxCreateScreenSource( self.screenWidth, self.screenHeight )
	self.renderTargetBW = dxCreateRenderTarget( self.screenWidth, self.screenHeight )
	self.renderTargetSun = dxCreateRenderTarget( self.screenWidth, self.screenHeight )
	self.renderTargetGodRaysBase = dxCreateRenderTarget( self.screenWidth, self.screenHeight )
	self.renderTargetGodRays = dxCreateRenderTarget( self.screenWidth, self.screenHeight )
	self.bwShader = dxCreateShader( "fx/sun/bw.fx" )
	self.godRayBaseShader = dxCreateShader( "fx/sun/godRayBase.fx" )
	self.sunShader = dxCreateShader( "fx/sun/sun.fx" )
	self.godRayShader = dxCreateShader( "fx/sun/godrays.fx" )
	self.lensFlareShader = dxCreateShader( "fx/sun/lensflares.fx" )
	
	if ( not self.bwShader ) or ( not self.godRayBaseShader ) or ( not self.sunShader ) or ( not self.godRayShader ) or ( not self.lensFlareShader ) or ( not self.screenSource ) or ( not self.renderTargetBW ) or ( not self.renderTargetSun ) or ( not self.renderTargetGodRaysBase ) or ( not self.renderTargetGodRays ) then
		outputDebugString( "Loading sun shader failed", 1 )
		
		return false
	end
	
	return true
end

function SunShader:update( )
	if self.sun.size == 0 then return end

	self.sunX, self.sunY, self.sunZ = self.sun:getSunPosition( )
	self.sunScreenX, self.sunScreenZ = getScreenFromWorldPosition( self.sunX, self.sunY, self.sunZ, 1, true )
	
	dxUpdateScreenSource( self.screenSource )
	
	if ( self.sunScreenX ) and ( self.sunScreenZ ) then
		-- scenario bw
		dxSetShaderValue( self.bwShader, "screenSource", self.screenSource )
		dxSetShaderValue( self.bwShader, "viewDistance", self.viewDistance )

		dxSetRenderTarget( self.renderTargetBW, true )
		dxDrawImage( 0, 0, self.screenWidth, self.screenHeight, self.bwShader )
		dxSetRenderTarget( )
		
		-- sun
		dxSetShaderValue( self.sunShader, "screenSource", self.screenSource )
		dxSetShaderValue( self.sunShader, "bwSource", self.renderTargetBW )
		dxSetShaderValue( self.sunShader, "sunPos", {( 1 / self.screenWidth ) * self.sunScreenX, ( 1 / self.screenHeight ) * self.sunScreenZ} )
		dxSetShaderValue( self.sunShader, "sunColorInner", self.sunColorInner )
		dxSetShaderValue( self.sunShader, "sunColorOuter", self.sunColorOuter )
		dxSetShaderValue( self.sunShader, "sunSize", self.sunSize * self.sun.size )

		dxSetRenderTarget( self.renderTargetSun, true )
		dxDrawImage( 0, 0, self.screenWidth, self.screenHeight, self.sunShader )
		dxSetRenderTarget( )

		-- godray base
		dxSetShaderValue( self.godRayBaseShader, "screenSource", self.screenSource )
		dxSetShaderValue( self.godRayBaseShader, "renderTargetBW", self.renderTargetBW )
		dxSetShaderValue( self.godRayBaseShader, "renderTargetSun", self.renderTargetSun )
		dxSetShaderValue( self.godRayBaseShader, "screenSize", {self.screenWidth, self.screenHeight} )

		dxSetRenderTarget( self.renderTargetGodRaysBase, true )
		dxDrawImage( 0, 0, self.screenWidth, self.screenHeight, self.godRayBaseShader )
		dxSetRenderTarget( )
		
		-- godrays
		dxSetShaderValue( self.godRayShader, "godRayStrength", self.godRayStrength * self.sun.size )
		dxSetShaderValue( self.godRayShader, "sunLight", self.renderTargetGodRaysBase )
		dxSetShaderValue( self.godRayShader, "lensDirt", self.lensFlareDirt )
		dxSetShaderValue( self.godRayShader, "sunPos", {( 1 / self.screenWidth ) * self.sunScreenX, ( 1 / self.screenHeight ) * self.sunScreenZ} )

		dxSetRenderTarget( self.renderTargetGodRays, true )
		dxDrawImage( 0, 0, self.screenWidth, self.screenHeight, self.godRayShader )
		dxSetRenderTarget( )
		
		
		-- lensflares
		dxSetShaderValue( self.lensFlareShader, "screenSource", self.screenSource )
		dxSetShaderValue( self.lensFlareShader, "sunLight", self.renderTargetGodRays )
		dxSetShaderValue( self.lensFlareShader, "lensDirt", self.lensFlareDirt )
		dxSetShaderValue( self.lensFlareShader, "lensChroma", self.lensFlareChroma )
		dxSetShaderValue( self.lensFlareShader, "sunPos", {( 1 / self.screenWidth ) * self.sunScreenX, ( 1 / self.screenHeight ) * self.sunScreenZ} )
		dxSetShaderValue( self.lensFlareShader, "sunColor", self.sunColorInner )
		dxSetShaderValue( self.lensFlareShader, "screenSize", {self.screenWidth, self.screenHeight} )
		
		--dxDrawImage( 0, 0, self.screenWidth, self.screenHeight, self.bwShader )
		--dxDrawImage( 0, 0, self.screenWidth, self.screenHeight, self.sunShader )
		--dxDrawImage( 0, 0, self.screenWidth, self.screenHeight, self.godRayBaseShader )
		--dxDrawImage( 0, 0, self.screenWidth, self.screenHeight, self.godRayShader )
		dxDrawImage( 0, 0, self.screenWidth, self.screenHeight, self.lensFlareShader )
	end
end

function SunShader:removeShaders( )
	removeEventHandler( "onClientPreRender", root, self.m_Update )

	if ( self.bwShader ) then
		destroyElement( self.bwShader )
		self.bwShader = nil
	end
	
	if ( self.godRayBaseShader ) then
		destroyElement( self.godRayBaseShader )
		self.godRayBaseShader= nil
	end
	
	if ( self.sunShader ) then
		destroyElement( self.sunShader )
		self.sunShader= nil	
	end
	
	if ( self.godRayShader ) then
		destroyElement( self.godRayShader )
		self.godRayShader= nil	
	end

	if ( self.lensFlareShader ) then
		destroyElement( self.lensFlareShader )
		self.lensFlareShader= nil	
	end
	
	if ( self.screenSource ) then
		destroyElement( self.screenSource )
		self.screenSource = nil
	end
	
	if ( self.renderTargetBW ) then
		destroyElement( self.renderTargetBW )
		self.renderTargetBW = nil
	end
	
	if ( self.renderTargetSun ) then
		destroyElement( self.renderTargetSun )
		self.renderTargetSun = nil
	end
	
	if ( self.renderTargetGodRaysBase ) then
		destroyElement( self.renderTargetGodRaysBase )
		self.renderTargetGodRaysBase = nil
	end
	
	if ( self.renderTargetGodRays ) then
		destroyElement( self.renderTargetGodRays )
		self.renderTargetGodRays = nil
	end
end

function SunShader:disable( )
	if not self.enabled then return end	
	self.enabled = false

	self:removeShaders( )
	
	if ( self.sun ) then
		self.sun:destroy( )
		self.sun = nil
	end
end