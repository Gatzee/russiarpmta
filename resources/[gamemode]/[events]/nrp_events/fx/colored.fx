texture gTexture;

technique TexReplace
{
    pass P0
    {
    	PixelShader  = compile ps_2_0 PixelShaderExample();
    }
}