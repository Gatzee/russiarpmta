#include "mta-helper.fx"
 
struct vsin
{
  float4 Position : POSITION;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
  float3 Normal : NORMAL0;
};

struct vsout
{
  float4 Position : POSITION;
  float3 WorldPos : TEXCOORD2;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
  float3 Normal : NORMAL0;
};

vsout vs(vsin input)
{
  vsout output;

  output.Position = mul( input.Position, gWorldViewProjection );
  output.WorldPos = MTACalcWorldPosition( input.Position );
  output.Diffuse  = input.Diffuse;
  output.TexCoord = input.TexCoord;

  MTAFixUpNormal( input.Normal );
  output.Normal   = input.Normal; //MTACalcWorldNormal( input.Normal );

  return output;
}
 
 
float4 ps(vsout input) : COLOR0
{
    float divisor = cos( gTime / input.TexCoord.x );

    // TEXCOORD
    float4 color = float4( input.TexCoord.x, input.TexCoord.y, 0, 1 );

    // NORMAL
    //float4 color = float4( input.Normal.xyz, 1 );
    return color;
}
 
technique tec
{
  pass Pass0
  {
    DepthBias = -0.0002;
    VertexShader = compile vs_3_0 vs();
    PixelShader = compile ps_3_0 ps();
  }
}