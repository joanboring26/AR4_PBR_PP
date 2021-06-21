// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PBRColored"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _Metallic ("Metallic", Range (0, 1)) = 1
        _FresnelParam ("Shininess", Range (0.01, 3)) = 1
        _Roughness ("Roughness", Range (0.01, 3)) = 1
    }
    SubShader
    {
        LOD 100

        Pass
        {
            Tags {	"RenderType"="Opaque" 
        	"LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile __ POINT_LIGHT_ON 
			#pragma multi_compile __ DIRECTIONAL_LIGHT_ON

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"            

            //float4 _Color;
            
            float _FresnelParam;
            float _Roughness;
            float _Metallic;

            float4 _Color;
            //float4 _MainTex_ST;

            //Automatically filled out by unity
            struct MeshData //Per vertex mesh data
            {
                float4 vertex : POSITION; //Vertex position
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0; //Uv coordinates
            };

            struct Interpolators
            {
                float4 pos : SV_POSITION; //Clip space position
                float3 posWorld : TEXCOORD4; //Clip space position
                float2 uv : TEXCOORD0; //We can use it to pass data (or uv data)
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float2 fresnelValue : TEXCOORD3;
            	LIGHTING_COORDS(4,5)
            };


            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.pos = UnityObjectToClipPos(v.vertex); //Local space to clip space
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex));
                o.fresnelValue.x = 1 - saturate ( dot ( v.normal, o.viewDir ) );
                o.uv = v.uv;
            	TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
            	//Establish base vars
                float4 finalDiffuse;
            	float3 diffuseColor;
            	float3 specularity;
            	float3 lightingModel;

            	float4 _pointLightPos;
            	
            	float attenuation;
            	
            	float3 attenColor;
            	float3 lightVec;
            	float3 halfVec;
            	
            	float dotHL;
            	float testFresnel;
            	
            	float topVal;
            	float bottomRes;
            	float finalRes;
            	float neumannResult;
            	
            	#if DIRECTIONAL_LIGHT_ON
                diffuseColor = _Color * (1-_Metallic);
                attenuation = LIGHT_ATTENUATION(i);
                attenColor = attenuation * _LightColor0.rgb;
                
                //Fresnel section
                lightVec =  normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                halfVec = normalize( i.viewDir + lightVec);
                dotHL = dot(halfVec, lightVec);
                testFresnel = pow(i.fresnelValue.x + (1 - i.fresnelValue.x) * (1 - dotHL), 5);
                testFresnel = testFresnel * _FresnelParam;
                //End of fresnel

                //GGX(Isotrópico):
                topVal = _Roughness * _Roughness;
                bottomRes = ((pow(dot(i.normal,halfVec),2)) * ((_Roughness * _Roughness) - 1)) + 1;
                bottomRes = UNITY_PI * (bottomRes * bottomRes);
                finalRes = topVal / bottomRes;
                //

                //Neumann
                neumannResult =
                    (dot(i.normal,lightVec) * dot(i.normal, i.viewDir))
                    /
                    max(dot(i.normal,lightVec),dot(i.normal, i.viewDir));
                //
                
                specularity = (finalRes * testFresnel * neumannResult) / (4 * (  dot(i.normal,lightVec) * dot(i.normal, i.viewDir)));

                lightingModel = (diffuseColor + specularity);
                lightingModel *= dot(i.normal,lightVec);
                finalDiffuse = float4(lightingModel * attenColor,1);
            	#endif

            	#if POINT_LIGHT_ON
                diffuseColor = _Color * (1-_Metallic);
                attenuation = unity_4LightAtten0.x;
                attenColor = attenuation * unity_LightColor[0].rgb;

            	_pointLightPos.xyz = float3(unity_4LightPosX0.x,unity_4LightPosY0.x,unity_4LightPosZ0.x);
            	
                //Fresnel section
                lightVec =  normalize(lerp(_pointLightPos.xyz, _pointLightPos.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                halfVec = normalize( i.viewDir + lightVec);
                dotHL = dot(halfVec, lightVec);
                testFresnel = pow(i.fresnelValue.x + (1 - i.fresnelValue.x) * (1 - dotHL), 5);
                testFresnel = testFresnel * _FresnelParam;
                //End of fresnel

                //GGX(Isotrópico):
                topVal = _Roughness * _Roughness;
                bottomRes = ((pow(dot(i.normal,halfVec),2)) * ((_Roughness * _Roughness) - 1)) + 1;
                bottomRes = UNITY_PI * (bottomRes * bottomRes);
                finalRes = topVal / bottomRes;
                //

                //Neumann
                neumannResult =
                    (dot(i.normal,lightVec) * dot(i.normal, i.viewDir))
                    /
                    max(dot(i.normal,lightVec),dot(i.normal, i.viewDir));
                //
                
                specularity = (finalRes * testFresnel * neumannResult) / (4 * (  dot(i.normal,lightVec) * dot(i.normal, i.viewDir)));

                lightingModel = (diffuseColor + specularity);
                lightingModel *= dot(i.normal,lightVec);
                finalDiffuse = float4(lightingModel * attenColor,1);
                finalDiffuse = float4(unity_LightColor[0].rgb,1);
            	#endif

            	
            	
                return finalDiffuse;
            }
            ENDCG
        }

        // Pass to render object as a shadow caster
		Pass 
		{
			Name "CastShadow"
			Tags { "LightMode" = "ShadowCaster" }
	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"
	
			struct v2f 
			{ 
				V2F_SHADOW_CASTER;
			};
	
			v2f vert( appdata_base v )
			{
				v2f o;
				TRANSFER_SHADOW_CASTER(o)
				return o;
			}
	
			float4 frag( v2f i ) : COLOR
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
    }
}
