#include "mta-helper.fx"

float3 sMorphSize = float3(0, 0, 0);
float4 sMorphColor = float4(1, 1, 1, 1);
float fMoveSpeed = 3;

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

	VS.Position += VS.Normal * sMorphSize;
	PS.Position = MTACalcScreenPosition( VS.Position );
	PS.TexCoord = VS.TexCoord;
    float fAlphaMul = ( 0.9 + frac( gTime * PS.TexCoord.x * fMoveSpeed ) * 1 );
	PS.Diffuse.rgba = sMorphColor.rgba;
    PS.Diffuse.a *= fAlphaMul;

	return PS;
}

technique tec0
{
	pass P0
	{
		VertexShader = compile vs_2_0 VertexShaderFunction();
	}
}

technique fallback
{
	pass P0
	{

	}
}
