Shader "Unlit/2dCharacter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SSSTex ("SSSTex", 2D) = "black" {}
        _IMLTex ("IMLTex", 2D) = "white" {}


        _ToonThesHold ("ToonThesHold", Range(0,1)) = 0.5
        _ToonHardness ("ToonHardness", Float) = 0.5
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
            #pragma mult_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 normal : NORMAL;
                float3 vertexColor : COLOR;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 pos_world : TEXCOORD1;
                float3 normal_world :TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _SSSTex;
            sampler2D _IMLTex;

            float _ToonThesHold;
            float _ToonHardness;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.pos_world = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.normal_world = mul(v.normal,unity_WorldToObject).xyz;
                o.uv = float4(v.uv,v.uv2);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half2 uv1 = i.uv.xy;
                half2 uv2 = i.uv.zw;
                fixed4 baseColor = tex2D(_MainTex, uv1);
                fixed4 sssColor = tex2D(_SSSTex,uv1);
                //常用向量
                float3 normal_dir = normalize(i.normal_world);
                float3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
                //常用变量
                half NdotL = dot(normal_dir,light_dir);
                half half_lambert = (NdotL + 1) * 0.5;
                half toon_diffuse = saturate((half_lambert - _ToonThesHold) * _ToonHardness);

                fixed4 finalColor = baseColor * toon_diffuse+ sssColor * abs(1 - toon_diffuse);
                //参数获取
                return finalColor;
            }
            ENDCG
        }
    }
}
