texture tex;
float dg = 0;
float angle = 1;
float4 rgba = float4(255,255,255,255);
float4 urgba = float4(0,0,0,0);

sampler Sampler0 = sampler_state
{
    Texture = (tex);
};

float4 PixelShaderFunction(float2 coords: TEXCOORD0) : COLOR0   
{
    float4 color = tex2D(Sampler0,coords);
    clip(color.a);
    float dx = coords.x - 0.435f;
    float dy = coords.y - 0.435f;
    float degree = -90 + dg*90;
    clip((radians(degree) - atan2(dy,dx))*angle);
    return color *= rgba/255;
}
 
technique radarcircle
{
    pass Pass0
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
} 
