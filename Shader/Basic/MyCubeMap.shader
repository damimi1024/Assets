Shader "Unlit/CubeMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CubeMap ("CubeMap", Cube) = "white" {}
        _NormalMap ("NormalMap", 2D) = "white" {}
        _NormalIntensity ("NormalIntensity", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float2 normal : NORMAL;
                float2 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 pos_world : TEXCOORD1;
                float2 normal_world : TEXCOORD2;
                float2 tagent_world : TEXCOORD3;
                float2 binormal_world : TEXCOORD4;
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            float4 _MainTex_ST;
            samplerCUBE _CubeMap;
            float _NormalIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal_world = mul(v.normal,unity_WorldToObject);
                o.tangent_world = mul(unity_ObjectToWorld,v.tangent)*v.tangent.w;
                o.binormal_world = cross(o.normal_world,o.tangent_world);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 tangentDir = normalize(i.tangent_world);
                half3 binormalDir = normalize(i.binormal_world);
                half3 normalDir = normalize(i.normal_world);

                half3 normalMap = tex2D(_NormalMap,i.uv);
                float3x3 TBN = float3x3(tangentDir,binormalDir,normalDir);
                half3 normalData = UnpackNormal(_NormalMap);
                normalData.xy = normalData.xy * _NormalIntensity;
                normalDir = normalize(mul(normalData.xyz,TBN)) ;

                half4 cubeColor = texCUBE(refDir,i.uv);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
