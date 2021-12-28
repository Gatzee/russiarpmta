#include "mta-helper.fx"

float3 sMorphSize = float3(0, 0, 0);
float4 sMorphColor = float4(1, 1, 1, 1);
float3 pos = float3( 0, 0, 0 );

struct VSInput
{
	float3 Position : POSITION0;
	float3 Normal : NORMAL0;
	float4 Diffuse : COLOR0;
	float2 TexCoord : TEXCOORD0;
};

struct PSInput
{
	float4 Position : POSITION0;
	float4 Diffuse : COLOR0;
	float2 TexCoord : TEXCOORD0;
};

PSInput VertexShaderFunction(VSInput VS)
{
	PSInput PS = (PSInput)0;

    float3 vec = ( VS.Position + VS.Normal * sMorphSize ) - pos;
    float morph_scale = length( vec ) / sMorphSize;

	VS.Position += VS.Normal * ( sMorphSize + abs( sin( gTime * 2 ) ) * 2 ) / morph_scale * 2;
	PS.Position = MTACalcScreenPosition ( VS.Position );
	PS.TexCoord = VS.TexCoord;
	PS.Diffuse.rgb = sMorphColor.rgb * sMorphColor.a;
	PS.Diffuse.a = 1;

	return PS;
}

technique tec0
{
	pass P0
	{
		SrcBlend = SrcColor;
		DestBlend = One;
		VertexShader = compile vs_2_0 VertexShaderFunction();
	}
}

technique fallback
{
	pass P0
	{
		SrcBlend = Zero;
		DestBlend = One;
	}
}
