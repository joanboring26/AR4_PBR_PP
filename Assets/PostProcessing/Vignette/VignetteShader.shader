Shader "Custom/VignetteShader"
{
    HLSLINCLUDE

#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    float _Blend;
    float _lens_radius;
    float _lens_squaring;
    float _lens_feathering;
    float _PositionX;
    float _PositionY;
    float _deformationX;
    float _deformationY;
    float4 Frag(VaryingsDefault i) : SV_Target
    {
        float2 texcoord = (i.texcoord * 2) - 1;
        texcoord.x = pow(abs(texcoord.x), _lens_squaring);
        texcoord.y = pow(abs(texcoord.y), _lens_squaring);
        float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
        float dist = distance(texcoord , float2(_PositionX + texcoord.x * _deformationX, _PositionY + texcoord.y * _deformationY));
        float v = smoothstep(_lens_radius,(_lens_radius - 0.001) * _lens_feathering, dist);
                 return color * float4(v,v,v,1);
                 //return col;
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
