texture tex;
float coeff = 2.42;
float start_angle = -2.42;
float progress = 1;
float4 rgba = float4( 255, 255, 255, 255 );
sampler Sampler0 = sampler_state
{
    Texture = ( tex );
};
float4 PixelShaderFunction( float2 coords: TEXCOORD0 ) : COLOR0   
{
    float2 uv = float2( coords.x - 0.5, coords.y - 0.5 );
    float angle = atan2( uv.x, -uv.y );
    float real_progress = progress - ( 1 - progress );
    if ( angle < start_angle || angle > real_progress * coeff ) { return 0; }
    return tex2D( Sampler0, coords ) * rgba / 255;
}
technique fuel_shader
{
    pass Pass0
    {
        PixelShader = compile ps_2_0 PixelShaderFunction( );
    }
} 
