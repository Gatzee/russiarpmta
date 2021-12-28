DIM_VALUE = 1
DIM_STEP = 0.005

DIM_MINIMAL_EDGE = 0.2

function CreateCinemaDimmer_handler( )
    DestroyCinemaDimmer_handler( true )

    SHADER = dxCreateShader( "fx/lighting.fx", 0, 30 )
    engineApplyShaderToWorldTexture( SHADER, "k_teatr*" )

    local removal = {
        "k_teatr20",
        "k_teatr31",
        "k_teatr26",
        "k_teatr13",
        "k_teatr12",
        "k_teatr46",
        "k_teatr45",
        "k_teatr44",
        "k_teatr43",
        "k_teatr42",
    }
    for i, v in pairs( removal ) do
        engineRemoveShaderFromWorldTexture( SHADER, v )
    end

    dxSetShaderValue( SHADER, "dim", 1 )
    DIM_TURN = true

    removeEventHandler( "onClientRender", root, RenderDimmer )
    addEventHandler( "onClientRender", root, RenderDimmer )
end
addEvent( "CreateCinemaDimmer", true )
addEventHandler( "CreateCinemaDimmer", root, CreateCinemaDimmer_handler )

function RenderDimmer( )
    if DIM_TURN then
        DIM_VALUE = DIM_VALUE - DIM_STEP
        if DIM_VALUE <= DIM_MINIMAL_EDGE then
            DIM_VALUE = DIM_MINIMAL_EDGE
            removeEventHandler( "onClientRender", root, RenderDimmer )
        end
        dxSetShaderValue( SHADER, "dim", DIM_VALUE )
        
    else
        DIM_VALUE = DIM_VALUE + DIM_STEP
        if DIM_VALUE >= 1 then
            DIM_VALUE = 1
            removeEventHandler( "onClientRender", root, RenderDimmer )
            if isElement( SHADER ) then destroyElement( SHADER ) SHADER = nil end
        else
            dxSetShaderValue( SHADER, "dim", DIM_VALUE )
        end
    end
end

function DestroyCinemaDimmer_handler( force_immediate )
    if force_immediate then
        DIM_VALUE = 1
        removeEventHandler( "onClientRender", root, RenderDimmer )
        if isElement( SHADER ) then destroyElement( SHADER ) SHADER = nil end

    else
        DIM_TURN = false

        removeEventHandler( "onClientRender", root, RenderDimmer )
        addEventHandler( "onClientRender", root, RenderDimmer )
    end
end
addEvent( "DestroyCinemaDimmer", true )
addEventHandler( "DestroyCinemaDimmer", root, DestroyCinemaDimmer_handler )