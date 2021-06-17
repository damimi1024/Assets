Shader "Unlit/GpuInstance"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor ("_BaseColor", Color) = (1,1,1,1)
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
            #include "AutoLight.cginc"
            #pragma multi_compile_instancing

            UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_DEFINE_INSTANCED_PROP(float4, _MainColor)
            UNITY_DEFINE_INSTANCED_PROP(fixed, _Alpha)
            UNITY_INSTANCING_BUFFER_END(Props)
            half4 _BaseColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal_world :TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                 UNITY_SETUP_INSTANCE_ID(v);
                 UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal_world = mul(v.normal,unity_WorldToObject);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                half3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
                half3 nDotL = normalize(dot(i.normal_world,light_dir));
                fixed4 col = tex2D(_MainTex, i.uv);
                half3 diffuse_color = col.xyz * nDotL * _BaseColor.xyz * UNITY_ACCESS_INSTANCED_PROP(Props, _MainColor);
                // sample the texture
                return fixed4(diffuse_color,1);
            }
            ENDCG
        }
    }
}
