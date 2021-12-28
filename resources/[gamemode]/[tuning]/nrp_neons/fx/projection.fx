#include "mta-helper.fx"

const float fade_start_dist = 0.5f;
const float fade_dist = 0.3f;
const float3 default_normal = float3(0,0,1);

float scale;
float3 pos;
float3 mt;
float3 rt;

texture tex;

sampler Sampler0 = sampler_state
{
  Texture = <tex>;
};

 
struct vsin
{
  float4 Position : POSITION;
};

struct vsout
{
  float4 Position : POSITION;
  float3 WorldPos : TEXCOORD2;
};

vsout vs(vsin input)
{
  vsout output;
  output.Position = mul(input.Position,gWorldViewProjection);
  output.WorldPos = MTACalcWorldPosition(input.Position);
  return output;
}
 
 
float4 ps(vsout input) : COLOR0
{
  float3 vec = input.WorldPos - pos;
  float deg = dot(vec,mt)/length(vec);
  clip(deg);
  float nd = clamp(1.f - (length(deg*vec) - fade_start_dist)/fade_dist, 0.f, 1.f);
  clip(nd);
  float3 sinn,coss;
  sincos(rt,sinn,coss);
  float3x3 matrixX = {1.0f,0.0f,0.0f,0.0f,coss.y,-sinn.y,0.0f,sinn.y,coss.y};
  float3x3 matrixY = {coss.x,0.0f,sinn.x,0.0f,1.0f,0.0f,-sinn.x,0.0f,coss.x};
  float3x3 matrixZ = {coss.z,-sinn.z,0.0f,sinn.z,coss.z,0.0f,0.0f,0.0f,1.0f};
  float3 position = mul(matrixX,mul(matrixY,mul(matrixZ,vec)));
  position /= scale;
  if (abs(position.x) > 0.5f || abs(position.y) > 0.5f) discard;
  position += 0.5f;
  float4 color = tex2D(Sampler0,position);
  color.a *= nd;
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