// paint fix and reflection by Ren712
// car_refgene.fx
// 
//
// Badly converted from:
//
//      ShaderX2 � Shader Programming Tips and Tricks with DirectX 9
//      http://developer.amd.com/media/gpu_assets/ShaderX2_LayeredCarPaintShader.pdf
//
//      Chris Oat           Natalya Tatarchuk       John Isidoro
//      ATI Research        ATI Research            ATI Research
//

//some additional variables for the reflection
//for reflection factor look for brightnessFactor in piel shader

float sSparkleSize = 0.5;
float bumpSize = 1;

float2 uvMul = float2(1,1);
float2 uvMov = float2(0,0.25);

float minZviewAngleFade = -0.6;
float brightnessFactor = 0.20;
float sNormZ = 3;
float sAdd = 0.1;  
float sMul = 1.1; 
float sCutoff : CUTOFF = 0.16;         // 0 - 1
float sPower : POWER  = 2;            // 1 - 5
float sNorFacXY = 0.25;
float sNorFacZ = 1;

float3 sSkyColorTop = float3(0,0,0);
float3 sSkyColorBott = float3(0,0,0);
float sSkyLightIntensity = 0;
//---------------------------------------------------------------------
// Car paint settings
//---------------------------------------------------------------------
texture sReflectionTexture;
texture sCubeReflectionTexture;
texture sRandomTexture;

//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
#include "mta-helper.fx"

//------------------------------------------------------------------------------------------
// Samplers for the textures
//------------------------------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture         = (gTexture0);
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Linear;
};

sampler3D RandomSampler = sampler_state
{
    Texture = (sRandomTexture); 
    MAGFILTER = LINEAR;
    MINFILTER = LINEAR;
    MIPFILTER = POINT;
    MIPMAPLODBIAS = 0.000000;
};

sampler2D ReflectionSampler = sampler_state
{
    Texture = (sReflectionTexture);	
    AddressU = Mirror;
    AddressV = Mirror;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
};

samplerCUBE CubeReflectionSampler = sampler_state
{
    Texture = (sCubeReflectionTexture);	
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
   MIPMAPLODBIAS = 0.000000;
};

//---------------------------------------------------------------------
// Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VSInput
{
    float4 Position : POSITION; 
    float3 Normal : NORMAL0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
    float3 View : TEXCOORD1;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
    float4 Position : POSITION;
    float4 Diffuse : COLOR0;
    float4 Specular : COLOR1;   
    float2 TexCoord : TEXCOORD0;
    float3 SparkleTex : TEXCOORD1;
    float NormalZ : TEXCOORD2;
    float3 Normal : TEXCOORD3;
    float3 View : TEXCOORD5;
};


//------------------------------------------------------------------------------------------
// VertexShaderFunction
//  1. Read from VS structure
//  2. Process
//  3. Write to PS structure
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    float4 worldPosition = mul ( VS.Position, gWorld );
    float4 viewPosition  = mul ( worldPosition, gView );
    PS.Position  = mul ( viewPosition, gProjection );
 
    PS.View = normalize(gCameraPosition - worldPosition);

    float3 Normal = normalize( mul(VS.Normal, (float3x3)gWorld) );
    PS.Normal = Normal;

    PS.SparkleTex.x = fmod( VS.Position.x, 10 ) * 4.0/sSparkleSize;
    PS.SparkleTex.y = fmod( VS.Position.y, 10 ) * 4.0/sSparkleSize;
    PS.SparkleTex.z = fmod( VS.Position.z, 10 ) * 4.0/sSparkleSize; 
	
    float3 ViewNormal = normalize( mul(VS.Normal, (float3x3)gWorldView) );	
    float4 posNorm = float4(VS.Position.xyz,1);
    posNorm.xyz += float3(ViewNormal.xy * sNorFacXY, ViewNormal.z * sNorFacZ);	

    float4 pPos = mul(posNorm, gWorldViewProjection); 
    float projectedX = (0.5 * (pPos.x/pPos.w)) * uvMul.x + 0.5 + uvMov.x;
    float projectedY = (0.5 * (pPos.y/pPos.w)) * uvMul.y + 0.5 + uvMov.y;
    PS.TexCoord = float2(projectedX,projectedY);

    // Calc lighting
    PS.Diffuse = MTACalcGTAVehicleDiffuse( Normal, VS.Diffuse );
    // PS.Diffuse.a *= step( -0.0, PS.Normal.z );
    // Normal Z vector for sky light 
    float skyTopmask = pow(Normal.z,5);
    PS.Specular.rgb = (skyTopmask * sSkyColorTop + saturate(Normal.z-skyTopmask)* sSkyColorBott );
    PS.Specular.rgb *= gGlobalAmbient.xyz;
    PS.Specular.a = pow(Normal.z,sNormZ);
    PS.NormalZ = PS.Specular.a;
    if (gCameraDirection.z < minZviewAngleFade) PS.Specular.a = PS.NormalZ * (1 - saturate((-1/minZviewAngleFade ) * (minZviewAngleFade - gCameraDirection.z)));	
    return PS;
}


//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    // Some settings for something or another
    float microflakePerturbation = 1.00;

    // Micro-flakes normal map is a high frequency normalized
    // vector noise map which is repeated across the surface.
    float3 vFlakesNormal = tex3D(RandomSampler, PS.SparkleTex).rgb;

    // Don't forget to bias and scale to shift color into [-1.0, 1.0] range:
    vFlakesNormal = 2 * vFlakesNormal - 1.0;

    // To compute the surface normal for the second layer of micro-flakes, which
    // is shifted with respect to the first layer of micro-flakes, we use this formula:
    // Np2 = ( c * Np + d * N ) / || c * Np + d * N || where c == d
    float3 vNp2 = microflakePerturbation * (( vFlakesNormal + 1.0)/2) ;

    // reflection lookup coords
    float2 vReflection = float2(PS.TexCoord.x,PS.TexCoord.y);
	
    // Hack in some bumpyness
    vReflection.x += vNp2.x * (0.1 * bumpSize) - (0.1 * bumpSize);
    vReflection.y += vNp2.y * (0.05 * bumpSize) - (0.05 * bumpSize);
	
    float4 envMap = tex2D( ReflectionSampler, vReflection );
    float lum = (envMap.r + envMap.g + envMap.b)/3;
    float adj = saturate( lum - sCutoff );
    adj = adj / (1.01 - sCutoff);
    envMap += sAdd+1.0; 
    envMap = (envMap * adj);
    envMap = pow(envMap, sPower+2); 
    envMap *= sMul;

    // Brighten the environment map sampling result:
    envMap.rgb *= brightnessFactor;	
	
    envMap.a =1;	
    float4 first = float4((envMap.rgb+ 0.5 * PS.Specular.rgb * sSkyLightIntensity),PS.Specular.a);
    float skyLightCoef = -pow(PS.NormalZ*0.7, 2) + 1;
    float4 second = float4(1.1 * (PS.Specular.rgb),1.1 * sSkyLightIntensity * skyLightCoef);

    envMap = lerp(first,second,1-PS.Specular.a);

    float3 vCubeReflection = reflect(PS.View, PS.Normal);
    // Hack in some bumpyness
    vCubeReflection.x += vNp2.x * (0.1 * bumpSize) - (0.1 * bumpSize);
    vCubeReflection.y += vNp2.y * (0.05 * bumpSize) - (0.05 * bumpSize);
    float4 envMap2 = texCUBE( CubeReflectionSampler, -vCubeReflection.xzy );
    envMap2.rgb = envMap2.rgb * envMap2.rgb * envMap2.rgb * 0.1;
    // float CubeNormalZ = PS.Normal.z;
    // float x = abs(PS.Normal.z);
    // float CubeNormalZ = max(0, 1 - (x + x*x));
    float CubeNormalZ = max(0, 1 - PS.NormalZ * 2 );
    envMap2.rgb *= CubeNormalZ;
    envMap2.a = CubeNormalZ;

    // float4 envMap2 = tex2D( SkyboxSampler, PS.SkyboxTexCoord );
	
    float4 Color = envMap * ( 1 - envMap2.a * 0.5 ) + envMap2;
    Color.a *= PS.Diffuse.a;

    return Color;
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique car_reflect_generic_v3
{
    pass P0
    {
        DepthBias = -0.0007;
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        CullMode = 2;
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
}

// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
