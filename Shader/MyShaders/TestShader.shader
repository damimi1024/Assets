Shader "Unlit/TestShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DiffuseColor("DiffuseColor",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normalDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _DiffuseColor;
            float4 _LightColor0;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normalDir = mul(v.normal,unity_WorldToObject).xyz;
                o.viewDir = mul(unity_ObjectToWorld,_WorldSpaceCameraPos).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 ndotv = 0.5*(dot(i.normalDir,_WorldSpaceLightPos0.xyz))+0.5;
                fixed4 col = fixed4(_LightColor0*_DiffuseColor*ndotv,1) ;
                return col;
            }
            ENDCG
        }
    }
}
