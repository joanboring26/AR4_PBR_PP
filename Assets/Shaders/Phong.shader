Shader "Unlit/Phong"
{
	Properties
	{
	 	_objectColor("Main color",Color) = (0,0,0,1)
	 	_ambientInt("Ambient int", Range(0,1)) = 0.25
	 	_ambientColor("Ambient Color", Color) = (0,0,0,1)
	
	 	_diffuseInt("Diffuse int", Range(0,1)) = 1
		_scecularExp("Specular exponent",Float) = 2.0

		_pointLightPos("Point light Pos",Vector) = (0,0,0,1)
		_pointLightColor("Point light Color",Color) = (0,0,0,1)
		_pointLightIntensity("Point light Intensity",Float) = 1

		_directionalLightDir("Directional light Dir",Vector) = (0,1,0,1)
		_directionalLightColor("Directional light Color",Color) = (0,0,0,1)
		_directionalLightIntensity("Directional light Intensity",Float) = 1
		//
		_Color ("Main Color", Color) = (1,1,1,1)
        _Metallic ("Metallic", Range (0, 1)) = 1
        _FresnelParam ("Fresnel parameter", Range (0, 1)) = 1
        _Roughness ("Roughness", Range (0, 1)) = 1
		//

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile __ POINT_LIGHT_ON 
			#pragma multi_compile __ DIRECTIONAL_LIGHT_ON
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD1;
				float3 wPos : TEXCOORD2;
            	//float2 fresnelValue : TEXCOORD3;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv = v.uv;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
            	//o.fresnelValue.x = 1 - saturate ( dot ( v.normal, normalize(_WorldSpaceCameraPos.xyz - o.wPos) ) );
                return o;
            }

			fixed4 _objectColor;
			
			float _ambientInt;//How strong it is?
			fixed4 _ambientColor;
			float _diffuseInt;
			float _scecularExp;

			float4 _pointLightPos;
			float4 _pointLightColor;
			float _pointLightIntensity;

			float4 _directionalLightDir;
			float4 _directionalLightColor;
			float _directionalLightIntensity;

            float4 _Color;
            
            float _FresnelParam;
            float _Metallic;
            float _Roughness;

            fixed4 frag (v2f i) : SV_Target
            {
				//3 phong model light components
                //We assign color to the ambient term		
				fixed4 ambientComp = _ambientColor * _ambientInt;//We calculate the ambient term based on intensity
				fixed4 finalColor = ambientComp;
				
				float3 viewVec;
				float3 halfVec;
				float3 difuseComp = float4(0, 0, 0, 1);
				float3 specularComp = float4(0, 0, 0, 1);
				float3 lightColor;
				float3 lightDir;
            	
            	//
				float4 finalDiffuse = float4(0, 0, 0, 1);

            	float3 viewDir;
            	float3 attenColor;
            	float3 specularity;
            	float3 lightingModel;

				float attenuation;
            	
            	float dotHL;
            	float testFresnel = 0;
            	float topVal;
            	float bottomRes;
            	float finalRes;
            	float neumannResult;
				//
            	
            	
#if DIRECTIONAL_LIGHT_ON

				difuseComp = _Color * (1-_Metallic);
                attenuation = _directionalLightIntensity;
            	lightColor = _directionalLightColor.xyz;
                attenColor = attenuation * lightColor;
            	viewDir = normalize(_WorldSpaceCameraPos.xyz - i.wPos);
                
                //Fresnel section
                lightDir =  normalize(_directionalLightDir);
                halfVec = normalize( viewDir + lightDir);
                dotHL = dot(halfVec, lightDir);
                testFresnel = pow(_FresnelParam + (1 - _FresnelParam) * (1 - dotHL), 5);
                //End of fresnel

                //GGX(Isotrópico):
                topVal = _Roughness * _Roughness;
                bottomRes = ((pow(dot(i.worldNormal,halfVec),2)) * ((_Roughness * _Roughness) - 1)) + 1;
                bottomRes = UNITY_PI * (bottomRes * bottomRes);
                finalRes = topVal / bottomRes;
                //

                //Neumann
                neumannResult =
                    (dot(i.worldNormal,lightDir) * dot(i.worldNormal, viewDir))
                    /
                    max(dot(i.worldNormal,lightDir),dot(i.worldNormal, viewDir));
                //
                
                specularity = (finalRes * testFresnel * neumannResult) / (4 * (  dot(i.worldNormal,lightDir) * dot(i.worldNormal, viewDir)));

                lightingModel = (difuseComp + specularity);
                lightingModel *= dot(i.worldNormal,lightDir);
                finalDiffuse = float4(lightingModel * attenColor,1);
            	
#endif
#if POINT_LIGHT_ON

            	difuseComp = _Color * (1-_Metallic);
                attenuation = _pointLightIntensity;
            	lightColor = _pointLightColor.xyz;
                attenColor = attenuation * lightColor;
            	viewDir = normalize(_WorldSpaceCameraPos.xyz - i.wPos);
                
                //Fresnel section
                lightDir =  normalize( _pointLightPos - i.wPos);
                halfVec = normalize( viewDir + lightDir);
                dotHL = dot(halfVec, lightDir);
                testFresnel = pow(_FresnelParam + (1 - _FresnelParam) * (1 - dotHL), 5);
                //End of fresnel

                //GGX(Isotrópico):
                topVal = _Roughness * _Roughness;
                bottomRes = ((pow(dot(i.worldNormal,halfVec),2)) * ((_Roughness * _Roughness) - 1)) + 1;
                bottomRes = UNITY_PI * (bottomRes * bottomRes);
                finalRes = topVal / bottomRes;
                //

                //Neumann
                neumannResult =
                    (dot(i.worldNormal,lightDir) * dot(i.worldNormal, viewDir))
                    /
                    max(dot(i.worldNormal,lightDir),dot(i.worldNormal, viewDir));
                //
                
                specularity = (finalRes * testFresnel * neumannResult) / (4 * (  dot(i.worldNormal,lightDir) * dot(i.worldNormal, viewDir)));

                lightingModel = (difuseComp + specularity);
                lightingModel *= dot(i.worldNormal,lightDir);
                finalDiffuse = float4(lightingModel * attenColor,1);
				
#endif
				//pointLight
                
				//return float4(1,1,1,1) * neumannResult;
				return finalDiffuse * _objectColor;
            }
            ENDCG
        }
    }
}
