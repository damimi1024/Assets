Shader "Unlit/Diamond"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CubeMap("CubeMap",Cube) = "white"{}
        _NormalMap("NormalMap",2D) = "bump"{}
        _RefractTex ("RefractTex", 2D) = "white" {}
        _RimMask ("RimMask", 2D) = "white" {}
        _BaseColor ("BaseColor", Color) =  (1,1,1,1)
        _SpecIntensity("_SpecIntensity",Float) =1

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
            #include "AutoLight.cginc"

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

            samplerCUBE  _CubeMap;
            sampler2D _MainTex;
            sampler2D _NormalTex;
            sampler2D  _RefractTex;
            sampler2D _RimMask;
            float4 _MainTex_ST;
            float4 _RefractTex_ST;
            float _RefractIntensity;
            float _NormalIntensity;
            float4 _BaseColor;
            float4 _LightColor0;
            float _SpecIntensity;



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
                //采样
                float4 col = tex2D(_MainTex, i.uv);
                float4 normalMapuv = tex2D(_NormalTex,i.uv);
                float4 rim = tex2D(_RimMask,i.uv);
                //法线贴图准备
                float3 normal_world = normalize(i.normal_world);
                float3x3 TBN = float3x3(normalize(i.tangent_world),normalize(i.binormal_world),normalize(i.normal_world));
                float3 normal_data = UnpackNormal(normalMapuv);
                normal_data.xy = normal_data.xy * _NormalIntensity;
                //向量准备
                float3 normal_dir = normalize(mul(normal_data.xyz,TBN));
                float3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                float3 reflect_dir = normalize(reflect(-view_dir,normal_dir));
                float3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
                float3 half_dir = normalize(light_dir + view_dir);
                //变量准备
                float NdotL = max(0,dot(normal_dir,light_dir));
                half halfLambert = NdotL * 0.5 + 0.5;
                float fresenel = max(0, 1 - dot(i.normal_world,view_dir));
                //光照模型
                    //直接光漫反射
                    float3 direct_diffuse = col.xyz;
                    float3 dir_diffuse = NdotL * col.rgb * _LightColor0.xyz;
                    //直接光镜面反射
                    half NdotH = dot(normal_dir, half_dir);
                    float3 direct_spec = pow(max(0.0, NdotH),_SpecIntensity) * _LightColor0.xyz;


                    //直接光高光反射
                    // float3 blingphong = max(NdotL * 0)
                //晶体渲染
                float4 refractColor = tex2D(_RefractTex, reflect_dir.xy)*_RefractIntensity;
                float3 spec = texCUBE(_CubeMap, reflect_dir);
                float3 env_spec = spec * col *_LightColor0.xyz *refractColor;
                float3 final_color =dir_diffuse + direct_spec + env_spec;
                return fixed4(final_color,1);
            }
            ENDCG
        }
    }
}
