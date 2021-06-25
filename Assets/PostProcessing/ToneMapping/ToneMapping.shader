Shader "Custom/ToneMapping"
{
    HLSLINCLUDE

#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    float _Blend;
    float _ExposureR;
    float _ExposureG;
    float _ExposureB;
    float _Gamma;
    float4 Frag(VaryingsDefault i) : SV_Target
    {
        float3 sceneColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord).rgb;
        float3 m = float3(1 - exp(-sceneColor.x * _ExposureR), 
                          1 - exp(-sceneColor.y * _ExposureG),
                          1 - exp(-sceneColor.z * _ExposureB));// - exp(-sceneColor * _ExposureR);
        float gamCorr = 1.0 / _Gamma;
        m = pow(m, float3(gamCorr, gamCorr, gamCorr));

        return  float4(m, 1.0);
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
