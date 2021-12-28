#include "mta-helper.fx"
 
struct vsin
{
  float4 Position : POSITION;
  float2 TexCoord : TEXCOORD0;
};

struct vsout
{
  float4 Position : POSITION;
  float3 WorldPos : TEXCOORD2;
  float2 TexCoord : TEXCOORD0;
};

vsout vs(vsin input)
{
  vsout output;

  output.Position = mul( input.Position, gWorldViewProjection );
  output.WorldPos = MTACalcWorldPosition( input.Position );
  output.TexCoord = input.TexCoord;

  return output;
}
 
 
float4 ps(vsout input) : COLOR0
{
    return float4( input.TexCoord.x, input.TexCoord.y, 0, 1 );
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