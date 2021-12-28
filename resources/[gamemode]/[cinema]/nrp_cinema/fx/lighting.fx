#include "mta-helper.fx"

float dim = 0.5;

sampler Sampler0 = sampler_state
{
  Texture = <gTexture0>;
};


struct vsin
{
  float4 Position : POSITION;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
};

struct vsout
{
  float4 Position : POSITION;
  float3 WorldPos : TEXCOORD2;
  float2 TexCoord : TEXCOORD0;
  float4 Diffuse : COLOR0;
};

vsout vs(vsin input)
{
  vsout output;
  output.Position = mul( input.Position, gWorldViewProjection );
  output.WorldPos = MTACalcWorldPosition( input.Position );
  output.Diffuse = MTACalcGTABuildingDiffuse( input.Diffuse );
  output.TexCoord = input.TexCoord;
  return output;
}
 
float4 ps(vsout input) : COLOR0
{
  float4 color = tex2D( Sampler0, input.TexCoord );
  return color * float4( input.Diffuse.rgb * dim, input.Diffuse.a );
}
 
technique tec
{
  pass Pass0
  {
    VertexShader = compile vs_2_0 vs( );
    PixelShader = compile ps_2_0 ps( );
  }
}