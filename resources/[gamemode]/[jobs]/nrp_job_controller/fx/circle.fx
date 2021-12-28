texture tex;
float dg = 0;
float angle = 1;

sampler Sampler0 = sampler_state
{
    Texture = (tex);
};

float4 PixelShaderFunction(float2 coords: TEXCOORD0) : COLOR0   
{
    float4 color = tex2D(Sampler0,coords);
    clip(color.a);
    float degree = -180 + dg*180;
    clip((radians(degree) - atan2(coords.y - 0.5f, coords.x - 0.5f)));
    return color;
}
 
technique radarcircle
{
    pass Pass0
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
} 
