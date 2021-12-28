float4 rgba = (1,1,1,1);

texture gTexture0 < string textureState="0,Texture"; >;

struct VSInput
{
  float3 Position : POSITION;
  float4 Diffuse  : COLOR0;
  float2 TexCoord : TEXCOORD0;
};

sampler Sampler0 = sampler_state
{
  Texture = (gTexture0);
};


struct PSInput
{
  float4 Position : POSITION0;
  float4 Diffuse  : COLOR0;
  float2 TexCoord : TEXCOORD0;
};

 
float4 PixelShaderExample(PSInput PS) : COLOR0
{
  float4 finalColor = tex2D(Sampler0,PS.TexCoord);
  finalColor = rgba;
  return finalColor * PS.Diffuse;
}

technique complercated
{
  pass P0
  {
    PixelShader  = compile ps_2_0 PixelShaderExample();
    
  }
}
