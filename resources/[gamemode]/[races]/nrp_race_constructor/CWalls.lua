function CreateWallShader( )
    local UVSpeed = { -0.5, 0 }
    local UVResize = { 1, 1 }
    local pSpeed = 0 
    local pMinBright = 1

    local shader = dxCreateShader( "files/fx/shader.fx" )
    local texture = dxCreateTexture( "files/fx/blue.dds", "dxt3" )

    local txd = engineLoadTXD ( "files/models/kubik.txd" )
    engineImportTXD( txd, 1340 )
    local dff = engineLoadDFF ( "files/models/kubik.dff" )
    engineReplaceModel( dff, 1340 )
    local col = engineLoadCOL ( "files/models/kubik.col" )
    engineReplaceCOL( col, 1340 )

    dxSetShaderValue( shader, "Tex", texture )
    dxSetShaderValue( shader, "UVSpeed", UVSpeed )
    dxSetShaderValue( shader, "UVResize", UVResize )
    dxSetShaderValue( shader, "pSpeed", pSpeed )
    dxSetShaderValue( shader, "pMinBright", pMinBright )
    engineApplyShaderToWorldTexture( shader, "kubik" )
end
setTimer( CreateWallShader, 2500, 1 )
--addEventHandler( "onClientResourceStart", resourceRoot, CreateWallShader, true, "low-10000" )