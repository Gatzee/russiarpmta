texture RT < string renderTarget = "yes"; >;

struct Pixel
{
    float4 World : COLOR0;
    float4 RT : COLOR1;
};

Pixel PixelShaderFunctionDB(float4 Position : POSITION0)
{
    Pixel output;
    output.World = 0;
    output.RT = 1;

    return output;
}

technique water_depth
{
    pass P0
    {
        DepthBias = 0.00000002;
        AlphaTestEnable = false;
        PixelShader = compile ps_2_0 PixelShaderFunctionDB();
    }
}

technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
