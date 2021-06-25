Shader "Custom/PixelateShader"
{
    HLSLINCLUDE

#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    float _Blend;
    float _resolutionX;
    float _resolutionY;
    float _pixelSizeX;
    float _pixelSizeY;

    float4 Frag(VaryingsDefault i) : SV_Target
    {
        float2 pixelation = (_resolutionX / _pixelSizeX, _resolutionY / _pixelSizeY);
        i.texcoord = round(i.texcoord * pixelation) / pixelation;
        
        return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
    }

        ENDHLSL

        SubShader
    {
        Cull Off ZWrite Off ZTest Always

            Pass
        {
            HLSLPROGRAM

                #pragma vertex VertDefault
                #pragma fragment Frag

            ENDHLSL
        }
    }

}