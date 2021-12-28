#include "mta-helper.fx"
#include "tex_matrix.fx"

texture sPicTexture;
texture TexOverlay;
texture TexOverlayRender;

float2 gUVPrePosition = float2( 0, 0 );
float2 gUVScale = float( 1 );                     // UV scale
float2 gUVScaleCenter = float2( 0.5, 0.5 );
float gUVRotAngle = float( 0 );                   // UV Rotation
float2 gUVRotCenter = float2( 0.5, 0.5 );
float2 gUVPosition = float2( 0, 0 );              // UV position

float2 position;
float2 TexUV = float2( 1, 1 );
float fAlphaMul = 1.0;
float fMapAlphaMul = 1.0;

sampler Sampler0 = sampler_state { Texture = <sPicTexture>; };
sampler Sampler1 = sampler_state { Texture = <TexOverlay>; };
sampler Sampler2 = sampler_state { Texture = <TexOverlayRender>; };

float4 blendColors( float4 A, float4 B )
{
    float4 C;
    C.a = A.a + ( 1 - A.a ) * B.a;
    C.rgb = ( 1 / C.a ) * ( A.a * A.rgb + ( 1 - A.a ) * B.a * B.rgb );
    return C;
}

float4 ps( float2 uv: TEXCOORD0 ) : COLOR0
{
  float4 pixel_color = tex2D( Sampler0, uv );
  pixel_color.a *= fMapAlphaMul;

  float4 overlay_color = tex2D( Sampler1, uv );
  float4 overlay_render_color = tex2D( Sampler2, uv );

  float4 resulting_color;

  resulting_color = blendColors( blendColors( overlay_render_color, overlay_color ), pixel_color );
  resulting_color.a *= fAlphaMul;

  return resulting_color;
}

float3x3 getTextureTransform()
{
    return makeTextureTransform( gUVPrePosition, gUVScale, gUVScaleCenter, gUVRotAngle, gUVRotCenter, gUVPosition );
}

technique nextrp
{
    pass P0
    {
        // Set up texture stage 0
        Texture[0] = sPicTexture;
        TextureTransform[0] = getTextureTransform();
        TextureTransformFlags[0] = Count2;
        AddressU[0] = Clamp;
        AddressV[0] = Clamp;
        // Color mix texture and diffuse
        ColorOp[0] = Modulate;
        ColorArg1[0] = Texture;
        ColorArg2[0] = Diffuse;
        // Alpha mix texture and diffuse
        AlphaOp[0] = Modulate;
        AlphaArg1[0] = Texture;
        AlphaArg2[0] = Diffuse;

        // Disable texture stage 2
        ColorOp[2] = Disable;
        AlphaOp[2] = Disable;

        PixelShader = compile ps_2_0 ps();
    }
}
