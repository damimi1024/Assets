Shader "Unlit/Diamond"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CubeMap("CubeMap",Cube) = "white"{}
        _NormalMap("NormalMap",2D) = "bump"{}
        _RefractTex ("RefractTex", 2D) = "white" {}
        _BaseColor ("BaseColor", Color) =  (1,1,1,1)

        _RefractIntensity ("RefractIntensity", Float) = 1
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
                float3 normal : NORMAL;
                float4 tangent : TANGENT;

            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal_world : TEXCOORD1;
                float3 pos_world :TEXCOORD2;
                float3 tangent_world :TEXCOORD3;
                float3 binormal_world :TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            samplerCUBE  _CubeMap;
            sampler2D _NormalTex;
            sampler2D  _RefractTex;
            float4 _RefractTex_ST;
            float _RefractIntensity;
            float _NormalIntensity;
            float4 _BaseColor;



            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal_world = mul(float4(v.normal, 0.0), unity_WorldToObject).xyz;
                o.pos_world = mul(unity_ObjectToWorld,float4(v.vertex)).xyz;
                o.tangent_world = mul(unity_ObjectToWorld,float4(v.tangent.xyz,0)).xyz;
                o.binormal_world = cross(o.normal_world,o.tangent_world) * v.tangent.w;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //空间准备
                float3x3 TBN = float3x3(normalize(i.tangent_world),normalize(i.binormal_world),normalize(i.normal_world));
                float3 normal_data = UnpackNormal(tex2D(_NormalTex,i.uv));
                normal_data.xy = normal_data.xy * _NormalIntensity;
                float3 normal_dir = normalize(mul(normal_data.xyz,TBN));
                //向量准备
                float3 normal_world = normalize(i.normal_world);
                float3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                float3 reflect_dir = reflect(-view_dir,normal_dir);



                float4 col = tex2D(_MainTex, i.uv);
                float4 refractColor = tex2D(_RefractTex, reflect_dir.xy)*_RefractIntensity;
                float3 spec = texCUBE(_CubeMap, reflect_dir);
                float3 final_color = col.rgb * spec *refractColor* _BaseColor;
                return fixed4(final_color,1);
            }
            ENDCG
        }
    }
}
