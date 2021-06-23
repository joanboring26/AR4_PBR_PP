Shader "Custom/VignetteShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _lens_radius("Lens radius", Range(0, 1)) = 0.5
        _lens_squaring("Lens Squaring", Range(1,10)) = 1
        _lens_feathering("Lens feathering", Range(0, 1)) = 0.5
        _PositionX("Position X", Range(0, 1)) = 0.5 
        _PositionY("Position Y", Range(0, 1)) = 0.5
        _deformationX("deformation_X", Range(-1,1)) = 0
        _deformationY("deformation_Y", Range(-1,1)) = 0
        
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float _lens_radius;
            float _lens_feathering;
            float _lens_squaring;
            float _deformationY;
            float _deformationX;
            float _NegativedeformationX;
            float _NegativedeformationY;
            float _PositionX;
            float _PositionY;
            fixed4 frag (v2f i) : SV_Target
            {
                float2 texcoord = i.uv;
	            float4 color = tex2D( _MainTex, i.uv);
             
               // float dist = distance(pow(abs(texcoord), _lens_squaring), float2(0, 0));
                float dist = distance(pow(abs(texcoord), _lens_squaring), float2(_PositionX + texcoord.x * _deformationX, _PositionY + texcoord.y * _deformationY));

                float v = smoothstep(_lens_radius,(_lens_radius-0.001)*_lens_feathering, dist);
	            return color * float4(v,v,v,1);
                //return col;
            }
            ENDCG
        }
    }
}
