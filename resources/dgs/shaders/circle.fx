float antiAliased = 0.01;
float radius = 0.4;
float thickness = 0.05;
float2 progress = float2(0.6,0.3);
float4 baseColor = float4(1,0,0,1);
float4 extensionColor = float4(0,0,0,0);
float PI2 = 6.2831853071795864769;
float EPSILON = 0.0001;

float4 myShader(float2 tex : TEXCOORD0) : COLOR0
{
	float4 color = 0;
	float dis = abs(distance(tex,0.5)-radius);
	float4 diff = extensionColor-baseColor;
	if(dis < thickness+antiAliased)
		color = baseColor+diff*(dis-thickness+antiAliased)/antiAliased;
		
	float angle = degrees(atan2(tex.x-0.5,tex.y-0.5))/360+0.5;
	float2 tempAngle = progress*PI2;
	float4 anglePosition = 0.5+float4(cos(tempAngle[0]),sin(tempAngle[0]),cos(tempAngle[1]),sin(tempAngle[1]))*radius;
	if(progress[0]>progress[1])
	{
		if((angle < progress[0]) && (angle > progress[1]))
		{
			float2 ang;
			float2 vec;
			float2 k;
			tempAngle = (progress+antiAliased)*PI2;
			ang = 0.5+float2(cos(tempAngle[0]),sin(tempAngle[0]))*radius;
			vec = anglePosition.xy-ang;
			k.x = (abs(tex.y*vec.x+tex.x*vec.y-ang.x*vec.x-ang.y*vec.y)/sqrt(vec.x*vec.x+vec.y*vec.y))/antiAliased;

			ang = 0.5+float2(cos(tempAngle[1]),sin(tempAngle[1]))*radius;
			vec = anglePosition.zw-ang;
			k.y = (abs(tex.y*vec.x+tex.x*vec.y-ang.x*vec.x-ang.y*vec.y)/sqrt(vec.x*vec.x+vec.y*vec.y))/antiAliased;

			if(k.x>1)
				k.x=0;
			if(k.y>1)
				k.y=0;
			if(k.x+k.y == 0)
				k = 0.5;
			color = baseColor+diff*(k.x+k.y);


		}
	}
	else
	{
		if((angle < progress[0]) || (angle > progress[1]))
		{
			color = 0;
		}
	}
	
	float SampleWeights[15];

	SampleWeights[0] = ComputeGaussian(0);
	float totalWeights = SampleWeights[0];
	for (int i = 0; i < 15 / 2; i++)
	{
		float weight = ComputeGaussian(i + 1);
		SampleWeights[i * 2 + 1] = weight;
		SampleWeights[i * 2 + 2] = weight;
		totalWeights += weight * 2;
	}

	for (int j = 0; j < 15; j++)
	{
		SampleWeights[j] /= totalWeights;
	}
	
	for(int k = 0; k < 15; k++ )
	{
		color += tex2D( inputTexture, texCoord ) * SampleWeights[k];
	}
	
	return color;
}

technique DrawCircle
{
	pass P0
	{
		PixelShader = compile ps_2_a myShader();
	}
}
