//
// file: material3D_ssao.fx
// version: v1.5
// Based on mxao 1.5.7-2.0
//

//--------------------------------------------------------------------------------------
// Settings
//--------------------------------------------------------------------------------------
float2 fViewportSize = float2(800, 600);
float2 fViewportScale = float2(1, 1);
float2 fViewportPos = float2(0, 0);
float2 fBlend = float2(1, 3);

float2 sPixelSize = float2(0.00125, 0.00166);
float sAspectRatio = 800 / 600;

#define iMXAOBayerDitherLevel  5 // Dither Size (int 2 - 8)
uniform float fMXAOSampleRadius = 1.4; // Sample radius of GI, higher means more large-scale occlusion with less fine-scale details.  (1 - 8)
#define iMXAOSampleCount 24 // Amount of MXAO samples. Higher means more accurate and less noisy AO at the cost of fps (int 8 - 255)
#define AO_BLUR_GAMMA 1.5
uniform float fMXAONormalBias = 0.25; // Normal bias. Normals bias to reduce self-occlusion of surfaces that have a low angle to each other. (0 - 0.8)

#define fMXAOBlurSteps  3  // Blur Steps. Offset count for AO bilateral blur filter. Higher means smoother but also blurrier AO. (int 2 - 5)
#define fMXAOBlurSharpness 2.0 // Blur Sharpness. AO sharpness, higher means sharper geometry edges but noisier AO, less means smoother AO but blurry in the distance. (0 - 5)

uniform float fMXAOAmbientOcclusionAmount = 0.7 * 4.0; // Ambient Occlusion Amount (0 - 3) * 4.0
uniform float fMXAOFadeoutStart = 0.90; // Fadeout start (0 - 1)
uniform float fMXAOFadeoutEnd = 0.95; // Fadeout end (0 - 1)

float4x4 sProjection;
float4x4 sView = {
     1,  0,  0,      0,
     0,  1,  0,      0,
     0,  0,  1,      0,
     0,  0,  1000.5, 1
};

static float4x4 sViewProjection = mul( sView, sProjection );

static const float3 offs = float3(sPixelSize, 0);
static const float finalDivisor = 4.0 * exp2(2.0 * iMXAOBayerDitherLevel)- 4.0;
static const float finalOffset = 1.0 / exp2(2.0 * iMXAOBayerDitherLevel);
static const float sampleRadiusCoef = 0.2 * fMXAOSampleRadius * fMXAOSampleRadius / iMXAOSampleCount;
static const float fNegInvR2 = -1.0 / (fMXAOSampleRadius * fMXAOSampleRadius);
static const float2x2 matVectorMul = float2x2(0.575, 0.81815, -0.81815, 0.575);
static const float2 aspectRatioVector = float2(1.0, sAspectRatio);
static const float fHuinyaKakayato = 0.4 * (1.0 - fMXAONormalBias)*iMXAOSampleCount * sqrt(fMXAOSampleRadius);
static const float REVERSED_AO_BLUR_GAMMA = 1.0 / AO_BLUR_GAMMA;
static const float2 horVector = float2(sPixelSize.x,0.0);
static const float2 vertVector = float2(0,sPixelSize.y);

//--------------------------------------------------------------------------------------
// Textures
//--------------------------------------------------------------------------------------
// Secondary render target textures
texture sRTColor < string renderTarget = "yes"; >;
texture sRTWater;

//--------------------------------------------------------------------------------------
// Variables set by MTA
//--------------------------------------------------------------------------------------
texture gDepthBuffer : DEPTHBUFFER;
float4x4 gProjection : PROJECTION;
float4x4 gView : VIEW;
float4x4 gViewInverse : VIEWINVERSE;
float3 gCameraPosition : CAMERAPOSITION;
int CUSTOMFLAGS < string skipUnusedParameters = "yes"; >;

//--------------------------------------------------------------------------------------
// Sampler 
//--------------------------------------------------------------------------------------
sampler2D SamplerColor = sampler_state
{
    Texture = (sRTColor);
    AddressU = Clamp;
    AddressV = Clamp;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
};

sampler SamplerDepth = sampler_state
{
    Texture = (gDepthBuffer);
    AddressU = Clamp;
    AddressV = Clamp;
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = None;
};

sampler SamplerWater = sampler_state
{
    Texture = (sRTWater);
    AddressU = Clamp;
    AddressV = Clamp;
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = None;
};

//--------------------------------------------------------------------------------------
// Structures
//--------------------------------------------------------------------------------------
struct VSInput
{
    float3 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
    float4 Diffuse : COLOR0;
};

struct PSInput
{
    float4 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
    float2 PixPos : TEXCOORD1;
    float4 UvToView : TEXCOORD2;
    float4 Diffuse : COLOR0;
};

//--------------------------------------------------------------------------------------
// Vertex Shader 
//--------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    // pass screen position to be used in PS
    PS.PixPos = VS.TexCoord * fViewportSize;
	
    // calculate screen position of the vertex
    PS.Position = mul(float4(PS.PixPos, 0, 1), sViewProjection);

    // pass texCoords
    PS.TexCoord = VS.TexCoord;
	
    // pass vertex color to PS
    PS.Diffuse = VS.Diffuse;
	
    // calculations for perspective-correct position recontruction
    float2 uvToViewADD = - 1 / gProjection._m00_m11;	
    float2 uvToViewMUL = -2.0 * uvToViewADD;
    PS.UvToView = float4(uvToViewMUL, uvToViewADD);
	
    return PS;
}

//-----------------------------------------------------------------------------
//-- Get value from the depth buffer
//-- Uses define set at compile time to handle RAWZ special case (which will use up a few more slots)
//-----------------------------------------------------------------------------
float FetchDepthBufferValue( float2 uv )
{
    float4 texel = tex2D(SamplerDepth, uv);
#if IS_DEPTHBUFFER_RAWZ
    float3 rawval = floor(255.0 * texel.arg + 0.5);
    static const float3 valueScaler = float3(0.996093809371817670572857294849, 0.0038909914428586627756752238080039, 1.5199185323666651467481343000015e-5) / 255.0;
    return dot(rawval, valueScaler);
#else
    return texel.r;
#endif
}

//--------------------------------------------------------------------------------------
//-- Use the last scene projecion matrix to linearize the depth (to world units)
//--------------------------------------------------------------------------------------
float Linearize(float posZ)
{
    return gProjection[3][2] / (posZ - gProjection[2][2]);
}

//--------------------------------------------------------------------------------------
//-- Use the last scene projecion matrix to transform linear depth to logarithmic
//--------------------------------------------------------------------------------------
float InvLinearize(float posZ)
{
    return (gProjection[3][2] / posZ) + gProjection[2][2];
}

//--------------------------------------------------------------------------------------
//-- Use the last scene projecion matrix to linearize the depth (0-1)
//--------------------------------------------------------------------------------------
float LinearizeToFloat(float posZ)
{
    return (1 - gProjection[2][2])/ (posZ - gProjection[2][2]);
}

//--------------------------------------------------------------------------------------
// GetPositionFromDepth
//--------------------------------------------------------------------------------------
float3 GetPositionFromDepth(float2 coords, float4 uvToView)
{
    return float3(coords.x * uvToView.x + uvToView.z, (1 - coords.y) * uvToView.y + uvToView.w, 1.0) 
        * Linearize(FetchDepthBufferValue(coords));
}

//--------------------------------------------------------------------------------------
//  Calculates normals based on partial depth buffer derivatives.
//--------------------------------------------------------------------------------------
float3 GetNormalFromDepth(float2 coords, float4 uvToView)
{
    float3 f = GetPositionFromDepth(coords, uvToView);
    float3 d_dx1 = - f + GetPositionFromDepth(coords + offs.xz, uvToView);
    float3 d_dx2 =   f - GetPositionFromDepth(coords - offs.xz, uvToView);
    float3 d_dy1 = - f + GetPositionFromDepth(coords + offs.zy, uvToView);
    float3 d_dy2 =   f - GetPositionFromDepth(coords - offs.zy, uvToView);

    d_dx1 = lerp(d_dx1, d_dx2, abs(d_dx1.z) > abs(d_dx2.z));
    d_dy1 = lerp(d_dy1, d_dy2, abs(d_dy1.z) > abs(d_dy2.z));

    return (- normalize(cross(d_dy1, d_dx1)));
}

//------------------------------------------------------------------------------------------
//  Calculates the bayer dither pattern that's used to jitter
//  the direction of the AO samples per pixel.
//------------------------------------------------------------------------------------------
float GetBayerFromCoordLevel(float2 pixelpos)
{
    float finalBayer = 0.0;

    for(float i = 1-iMXAOBayerDitherLevel; i<= 0; i++)
    {
        float bayerSize = exp2(i);
        float2 bayerCoord = floor(pixelpos * bayerSize) % 2.0;
        float bayer = 2.0 * bayerCoord.x - 4.0 * bayerCoord.x * bayerCoord.y + 3.0 * bayerCoord.y;
        finalBayer += exp2(2.0*(i+iMXAOBayerDitherLevel))* bayer;
    }

    //raising all values by increment is false but in AO pass it makes sense. Can you see it?
    return finalBayer/ finalDivisor + finalOffset;
}

//------------------------------------------------------------------------------------------
// Structure of color data sent to the renderer ( from the pixel shader  )
//------------------------------------------------------------------------------------------
struct Pixel
{
    float4 World : COLOR0;      // Render target #0
    float4 Color : COLOR1;      // Render target #1
};

//--------------------------------------------------------------------------------------
// Pixel shaders 
//--------------------------------------------------------------------------------------
Pixel PixelShaderFunctionAO(PSInput PS)
{
    Pixel output;
	
    float3 viewPos = GetPositionFromDepth(PS.TexCoord, PS.UvToView);

    // recreate world normal from depth
    float3 viewNormal = GetNormalFromDepth(PS.TexCoord, PS.UvToView);

    float radiusJitter	= GetBayerFromCoordLevel(PS.PixPos);

    float scenedepth = LinearizeToFloat(FetchDepthBufferValue(PS.TexCoord));
    viewPos += viewNormal * scenedepth;

    float SampleRadiusScaled = sampleRadiusCoef / viewPos.z;

    float2 currentVector;
    sincos(2.0*3.14159274*radiusJitter, currentVector.y, currentVector.x);
    currentVector *= SampleRadiusScaled;
			  
    float AO = 0.0;
    float2 currentOffset;

    for(float iSample=0; iSample < iMXAOSampleCount; iSample++)
    {
        currentVector = mul(currentVector, matVectorMul);
        currentOffset = PS.TexCoord + currentVector * aspectRatioVector * (iSample + radiusJitter);
		
        float3 posLod = GetPositionFromDepth(currentOffset, PS.UvToView);
		
        float3 occlVec = -viewPos + posLod;

        float  occlDistanceRcp 	= rsqrt(dot(occlVec, occlVec));
        float  occlAngle = dot(occlVec, viewNormal) * occlDistanceRcp;

        float fAO = saturate(1.0 + fNegInvR2 / occlDistanceRcp) * saturate(occlAngle - fMXAONormalBias);

        AO += fAO;
    }

    float res = saturate(AO/fHuinyaKakayato);

    res = pow(abs(res), REVERSED_AO_BLUR_GAMMA);

    viewNormal = viewNormal * 0.5 + 0.5;	
    output.Color = float4(viewNormal.xy, res, 1);
    output.World = 0;
    return output;
}

/* Calculates weights for bilateral AO blur. Using only
   depth is surely faster but it doesn't really cut it, also
   areas with a flat angle to the camera will have high depth
   differences, hence blur will cause stripes as seen in many
   AO implementations, even HBAO+. Taking view angle into
   account greatly helps to reduce these problems. */
float GetBlurWeight(float4 tempKey, float4 centerKey, float surfacealignment)
{
    float depthdiff = abs(tempKey.w-centerKey.w);
    float normaldiff = 1 - saturate(dot(tempKey.xyz,centerKey.xyz));

    float depthweight = saturate(rcp(fMXAOBlurSharpness*depthdiff*5.0*surfacealignment));
    float normalweight = saturate(rcp(fMXAOBlurSharpness*normaldiff*10.0));
	
    return min(normalweight,depthweight);
}

//------------------------------------------------------------------------------------------
// Structure of color data sent to the renderer ( from the pixel shader  )
//------------------------------------------------------------------------------------------
Pixel PixelShaderFunctionBlur1(PSInput PS)
{
    Pixel output;

    float4 centerkey = 0.0, tempkey = 0.0;
    float  centerweight, tempweight;
    float surfacealignment;
    float2 blurcoord;
    float3 blurcolor;

    float3 normalColor = tex2D(SamplerColor, PS.TexCoord);
    float2 normalTex = normalColor.xy;
    float AO = normalColor.z * 0.5;
    
    centerkey.xy = (normalTex - 0.5) * 2; // viewNormal
    centerkey.z = 1 - length(centerkey.xy);
    centerkey = normalize(centerkey);
    centerkey.w = LinearizeToFloat(FetchDepthBufferValue(PS.TexCoord));
    centerweight = 0.5;
    
    surfacealignment = saturate(-dot(centerkey.xyz, normalize(float3(PS.TexCoord * 2.0 - 1.0, 1.0) * centerkey.w)));

    for(float orientation=-1; orientation<=1; orientation+=1)
    {
        for(float iStep = 1.0; iStep <= fMXAOBlurSteps; iStep++)
        {
            blurcoord = (2.0 * iStep - 0.5) * orientation * horVector + PS.TexCoord;
            blurcolor = tex2D(SamplerColor, blurcoord);

            tempkey.xy = (blurcolor.xy - 0.5) * 2;
            tempkey.z =  1 - length(tempkey.xy);
			tempkey = normalize(tempkey);
            tempkey.w = LinearizeToFloat(FetchDepthBufferValue(blurcoord));

            tempweight = GetBlurWeight(tempkey, centerkey, surfacealignment);
            AO += blurcolor.z * tempweight;
            centerweight += tempweight;
        }
    }

    output.Color = saturate(float4(normalTex, AO / centerweight, 1));
    output.World = 0;

    return output;
}

float4 PixelShaderFunctionBlur2(PSInput PS) : COLOR0
{
    float4 centerkey = 0.0, tempkey = 0.0;
    float  centerweight, tempweight;
    float surfacealignment;
    float2 blurcoord;
    float3 blurcolor;

    float3 normalColor = tex2D(SamplerColor, PS.TexCoord);
    float2 normalTex = normalColor.xy;
    float AO = normalColor.z * 0.5;
    
    centerkey.xy = (normalTex - 0.5) * 2; // viewNormal
    centerkey.z = 1 - length(centerkey.xy);
    centerkey = normalize(centerkey);
    centerkey.w = LinearizeToFloat(FetchDepthBufferValue(PS.TexCoord));
    centerweight = 0.5;
    
    surfacealignment = saturate(-dot(centerkey.xyz, normalize(float3(PS.TexCoord * 2.0 - 1.0, 1.0) * centerkey.w)));

    for(float orientation=-1; orientation<=1; orientation+=1)
    {
        for(float iStep = 1.0; iStep <= fMXAOBlurSteps; iStep++)
        {
            blurcoord = (2.0 * iStep - 0.5) * orientation * vertVector + PS.TexCoord;
            blurcolor = tex2D(SamplerColor, blurcoord);

            tempkey.xy = (blurcolor.xy - 0.5) * 2;
            tempkey.z =  1 - length(tempkey.xy);
			tempkey = normalize(tempkey);
            tempkey.w = LinearizeToFloat(FetchDepthBufferValue(blurcoord));

            tempweight = GetBlurWeight(tempkey, centerkey, surfacealignment);
            AO += blurcolor.z * tempweight;
            centerweight += tempweight;
        }
    }

    AO = pow(AO / centerweight, AO_BLUR_GAMMA);

    AO = 1.0-pow(1.0-AO, fMXAOAmbientOcclusionAmount);

    AO = lerp(AO, 0.0, smoothstep(fMXAOFadeoutStart, fMXAOFadeoutEnd, centerkey.w));
	
    float4 outColor = saturate(1 - AO + tex2D(SamplerWater, PS.TexCoord).r);
    // outColor.a = PS.Diffuse.a;
    
    return outColor;
}

//--------------------------------------------------------------------------------------
// Techniques
//--------------------------------------------------------------------------------------
technique dxDrawMaterial3D_ssao
{
  pass P0
  {
    ZEnable = false;
    ZWriteEnable = false;
    CullMode = 1;
    ShadeMode = Gouraud;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = InvSrcAlpha;
    AlphaTestEnable = false;
    AlphaRef = 1;
    AlphaFunc = GreaterEqual;
    Lighting = false;
    FogEnable = false;
    VertexShader = compile vs_3_0 VertexShaderFunction();
    PixelShader  = compile ps_3_0 PixelShaderFunctionAO();
  }
  pass P1
  {
    ZEnable = false;
    ZWriteEnable = false;
    CullMode = 1;
    ShadeMode = Gouraud;
    AlphaBlendEnable = true;
    SrcBlend = SrcAlpha;
    DestBlend = InvSrcAlpha;
    AlphaTestEnable = false;
    AlphaRef = 1;
    AlphaFunc = GreaterEqual;
    Lighting = false;
    FogEnable = false;
    VertexShader = compile vs_3_0 VertexShaderFunction();
    PixelShader  = compile ps_3_0 PixelShaderFunctionBlur1();
  }
  pass P2
  {
    ZEnable = false;
    ZWriteEnable = true;
    CullMode = 1;
    ShadeMode = Gouraud;
    AlphaBlendEnable = true;
    SrcBlend = fBlend.x;
    DestBlend = fBlend.y;
    AlphaTestEnable = false;
    AlphaRef = 1;
    AlphaFunc = GreaterEqual;
    Lighting = false;
    FogEnable = false;
    VertexShader = compile vs_3_0 VertexShaderFunction();
    PixelShader  = compile ps_3_0 PixelShaderFunctionBlur2();
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
	
