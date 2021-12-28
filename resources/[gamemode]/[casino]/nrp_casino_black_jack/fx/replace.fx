
struct PSInput 
{ 
    float4 Diffuse : COLOR0; 
}; 
  
float4 PixelShaderFunction( PSInput PS ) : COLOR0 
{ 
    float4 color = PS.Diffuse; 
    
    color.a = 0; 
    
    return color; 
} 
  
technique transparency 
{ 
    pass p0 
    { 
        AlphaBlendEnable    = TRUE; 
        DestBlend           = INVSRCALPHA; 
        SrcBlend            = SRCALPHA; 
         
        PixelShader         = compile ps_2_0 PixelShaderFunction(); 
    } 
}