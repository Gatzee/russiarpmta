#include "mta-helper.fx"

#define MAX_ITER 15

float2 resolution = float2(1, 1);
float intensity = 1;
float opacity = 1;
float3 color = float3(1.0, 1.0, 1.0);
float rate = 1.0;

float3 def_normal = float3( 0, 0, 1 );

struct vsin
{
	float4 Position : POSITION;
	float2 TexCoord : TEXCOORD0;
    float3 Normal : NORMAL0;
};

struct vsout
{
	float4 Position : POSITION;
	float2 TexCoord : TEXCOORD0;
    float3 Normal : TEXCOORD3;
};

vsout vs(vsin input)
{
	vsout output;
	output.Position = mul(input.Position, gWorldViewProjection);

    if ( length( input.Normal ) == 0 ) {
        input.Normal = def_normal;
    }
    output.Normal = MTACalcWorldNormal(input.Normal);

	output.TexCoord = input.TexCoord;
	return output;
}

float VELOCITY        = 1.0  ;           // speed of lines [ 0.5  .. 1.5  ] =  1.0
float HEIGHT          = 0.5    ;           // height of the lines  [ 0    .. 1.0  ] =  0.5
float FREQUENCY       = 7.5 ;           // frequency  [ 1.0  .. 14.0 ] =  9.0
float AMPLITUDE       = 0.3 ;           // amplitude  [ 0.1  .. 0.5  ] =  0.2
int   NUMBER          = 10    ;           // lines      [ 0    .. 20   ] = 10.0
float INVERSE         = 1.0 / float(10);  // inverse

float4 ps(vsout input) : COLOR0
{
	float time = ( gTime + gTime * rate );
    
    input.TexCoord.xy = input.TexCoord.xy;
    
    float3 col = color;
   
    float rColMod;
    float gColMod;
    float bColMod;
    
    float offset;
    float t;
    
    float colorb;
    float colora;
    
    float tsin;
            
    for (int i = 0; i < NUMBER; ++i)
    {
        float2 pos= input.TexCoord.xy/resolution.xy;
        
        offset = float(i) * INVERSE;
                
        t      = time + VELOCITY *(offset * offset * 2.);
        
        tsin   = sin( t );
        
        pos.y -= HEIGHT;
        pos.y+=sin(pos.x * FREQUENCY + t ) * AMPLITUDE * tsin;
        
        colorb  = 1.0 - pow( abs( pos.y ) , 0.2 );
        colora = pow( 1. , 0.2 * abs( pos.y ) );
        
        rColMod = (1. - (offset * .5) + .5) * colora ;
        gColMod = ((offset * .5) + .5) * colora ;
        bColMod = ((offset * .5) + .5) * colora ;
            
        col -= colorb * INVERSE * float3( lerp(rColMod, gColMod, tsin), lerp(gColMod, bColMod, tsin) , lerp(bColMod, rColMod, tsin)) ;      
    }
    return float4( col.x, col.x, col.x , 1.0);
}

float countDepthBias(float minBias, float maxBias, float closeBias)
{
    float4 viewPos = mul(float4(gWorld[3].xyz, 1), gView);
    float4 projPos = mul(viewPos, gProjection);
    float depthImpact = minBias + ((maxBias - minBias) * (1 - saturate(projPos.z / projPos.w)));
    depthImpact += closeBias * saturate(0.5 - (viewPos.z / viewPos.w));
    return depthImpact;
}

technique tec
{
	pass Pass0
	{
        SlopeScaleDepthBias = -0.5;
        DepthBias = countDepthBias(-0.000002, -0.0004, -0.001);
		AlphaBlendEnable = true;
		AlphaRef = 1;
		VertexShader = compile vs_3_0 vs();
		PixelShader = compile ps_3_0 ps();
	}
}