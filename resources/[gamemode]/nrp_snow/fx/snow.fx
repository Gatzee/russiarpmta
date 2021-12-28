float3 cam_position = float3( 0, 0, 0 );
float3 cam_rotation = float3( 0, 0, 0 );
float3 cam_velocity = float3( 0, 0, 0 );

float alpha = 0;
float sensivity = 7;

float gTime : TIME;

float2 resolution = float2( 1024, 1024 );
float2 middle = float2( 0.5, 0.5 );
float kx12[ 6 ] = {
	12 * 1,
	12 * 2,
	12 * 3,
	12 * 4,
	12 * 5,
	12 * 6
};
float4 gradient_color = float4( 0.5, 0.8, 1.0, 0.0 );
float2 val_stat = float2( 32.4691, 94.615 );
float2 static_random = float2( 12.9898, 78.233 );

float4 PixelShaderFunction( float4 fragCoord : VPOS ) : COLOR
{
	float snow = 0.0;

	fragCoord.y = 1 - fragCoord.y;

    float gradient = ( 1.0 - float( fragCoord.y / resolution.x ) ) * 0.4;

	fragCoord.x = fragCoord.x + cam_rotation.z * sensivity;
	fragCoord.y = fragCoord.y - cam_rotation.x * sensivity;

    float random = frac( sin( dot( fragCoord.xy, static_random ) ) * 43758.5453 );

	float iTime = gTime + length( cam_velocity ) * 10;

	float magnitude_mul = iTime * 2.5;

    for ( int k = 0; k < 1; k++ ) {
		float k6185 = k * 6185;
		float k1352 = k * 1352;
		float k315 = k * 315.156;
		float k9495 = 94.674 + k * 95.0;
		float k6223 = 62.2364 + k * 23.0;
        for ( int i = 0; i < 12; i++ ) {
            float cellSize = 2.0 + i * 3.0;
			float downSpeed = 0.3 + ( sin( iTime * 0.4 + k + i * 20 ) + 1.0 ) * 0.00008;
            float2 uv = ( fragCoord.xy / resolution.x ) + 
				float2(
					0.01 * sin( ( iTime + k6185 ) * 0.6 + i ) * ( 5.0 / i ),
					downSpeed * ( iTime + k1352 ) * ( 1.0 / i ) 
				);
            float2 uvStep = ( ceil ( uv * cellSize - middle ) / cellSize );

            float x = frac(
				sin(
					dot( uvStep.xy,
						float2( 12.9898 + kx12[ k ], 78.233 + k315 )
						)
					)
				* 43758.5453 + kx12[ k ]
			) - 0.5;

            float y = frac(
				sin(
					dot( uvStep.xy,
						float2( k6223, k9495 )
						)
					) 
				* 62159.8432 + kx12[ k ]
			) - 0.5 ;

            float randomMagnitude1 = sin( magnitude_mul ) * 0.7 / cellSize;
            float randomMagnitude2 = cos( magnitude_mul ) * 0.7 / cellSize;

            float d = 5.0 * distance( ( uvStep.xy + float2( x * sin( y ), y ) * randomMagnitude1 + float2( y, x ) * randomMagnitude2 ), uv.xy );

            float omiVal = frac( sin( dot( uvStep.xy, val_stat ) ) * 31572.1684 );

            if ( omiVal < 0.09 ) {
                float newd = ( x + 1.0 ) * 0.4 * clamp( 1.9 - d * ( 15.0 + ( x * 6.3 ) ) * ( cellSize / 1.4 ), 0.0, 1.0 );
                snow += newd;
            }
        }
    }

    return float4( 1, 1, 1, alpha ) * snow + gradient * gradient_color + random * 0.01;
}

technique snow
{
    pass P0
    {
        PixelShader  = compile ps_3_0 PixelShaderFunction();
    }
}