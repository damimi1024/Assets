 Shader "character"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap("NormalMap",2D) = "bump"{}
        _CubeMap("Cube Map",Cube) = "white"{}
        _CompMask("_CompMask",2D) = "compMask"{}
        _SkinLut("Skin Lut",2D) = "white"{}
        _SSSOffset("SSS Offset",Range(0,1)) = 1.0
        _Shininess("Shininess",Range(0.01,100)) = 1.0
        _SpecIntensity("SpecIntensity",Range(0.01,5)) = 1.0
        _NormalIntensity("Normal Intensity",Range(0.0,5.0)) = 1.0
        _Rotate("Rotate",Range(0,360)) = 0
        _Tint("Tint",Color) = (1,1,1,1)
        _Expose("Expose",Range(0,1)) = 1.0

        [HideInInspector]
        custom_SHAr("Custom SHAr", Vector) = (0, 0, 0, 0)
        [HideInInspector]
        custom_SHAg("Custom SHAg", Vector) = (0, 0, 0, 0)
        [HideInInspector]
        custom_SHAb("Custom SHAb", Vector) = (0, 0, 0, 0)
        [HideInInspector]
        custom_SHBr("Custom SHBr", Vector) = (0, 0, 0, 0)
        [HideInInspector]
        custom_SHBg("Custom SHBg", Vector) = (0, 0, 0, 0)
        [HideInInspector]
        custom_SHBb("Custom SHBb", Vector) = (0, 0, 0, 0)
        [HideInInspector]
        custom_SHC("Custom SHC", Vector) = (0, 0, 0, 1)



        [Toggle(DIR_DIFFUSE)] DIR_DIFFUSE("漫反射", Int) = 1
        [Toggle(DIR_SPEC)] DIR_SPEC("高光反射", Int) = 1
        [Toggle(ENV_DIFFUSE)] ENV_DIFFUSE("间接漫反射", Int) = 1
        [Toggle(ENV_SPEC)] ENV_SPEC("间接高光反射", Int) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma enable_d3d11_debug_symbols
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #pragma  shader_feature DIR_DIFFUSE
            #pragma  shader_feature DIR_SPEC
            #pragma  shader_feature ENV_DIFFUSE
            #pragma  shader_feature ENV_SPEC

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Assets/ShaderLibs/Math.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal  : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal_dir : TEXCOORD1;
                float3 pos_world : TEXCOORD2;
                float3 tangent_dir : TEXCOORD3;
                float3 binormal_dir : TEXCOORD4;
                //shadow map
                LIGHTING_COORDS(5,6)
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            sampler2D _CompMask;
            samplerCUBE _CubeMap;
            float4 _CubeMap_HDR;
            float4 _MainTex_ST;
            float _Rotate;
            float4 _LightColor0;
            float _Shininess;
            float _SpecIntensity;
            float _NormalIntensity;
            float4 _Tint;
            float _Expose;
            //sh
            half4 custom_SHAr;
            half4 custom_SHAg;
            half4 custom_SHAb;
            half4 custom_SHBr;
            half4 custom_SHBg;
            half4 custom_SHBb;
            half4 custom_SHC;
            //sss
            sampler2D _SkinLut;
            float _SSSOffset;

            float3 custom_sh(float3 normal_dir){
                float4 normalForSH = float4(normal_dir, 1.0);
                //SHEvalLinearL0L1
                half3 x;
                x.r = dot(custom_SHAr, normalForSH);
                x.g = dot(custom_SHAg, normalForSH);
                x.b = dot(custom_SHAb, normalForSH);

                //SHEvalLinearL2
                half3 x1, x2;
                // 4 of the quadratic (L2) polynomials
                half4 vB = normalForSH.xyzz * normalForSH.yzzx;
                x1.r = dot(custom_SHBr, vB);
                x1.g = dot(custom_SHBg, vB);
                x1.b = dot(custom_SHBb, vB);

                // Final (5th) quadratic (L2) polynomial
                half vC = normalForSH.x*normalForSH.x - normalForSH.y*normalForSH.y;
                x2 = custom_SHC.rgb * vC;

                float3 sh = max(float3(0.0, 0.0, 0.0), (x + x1 + x2));
                sh = pow(sh, 1.0 / 2.2);
                return sh;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal_dir = mul(float4(v.normal, 0.0), unity_WorldToObject).xyz;
                o.tangent_dir = mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz;
                //* v.tangent.w 是为了处理不同平台的副法线翻转问题
                o.binormal_dir = normalize(cross(o.normal_dir,o.tangent_dir)) * v.tangent.w;
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                // TRANSFER_SHADOW(o)
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
            //texture info
                fixed4 col = tex2D(_MainTex, i.uv);
                half4 comp_mask = tex2D(_CompMask,i.uv);
            //参数获取
                half3 albedo_color = pow(col, 2.2);
                half roughness = comp_mask.r;
                half metal = comp_mask.g;
                half skin = 1-comp_mask.b;
                //区分金属属性材质和普通材质
                half3 base_color = albedo_color.rgb * ( 1 - metal);
                half3 spec_color = lerp(0.04,albedo_color.rgb,metal);
                half atten = LIGHT_ATTENUATION(i);

            //向量计算
                half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                //发现方向
                half3 normal_dir = normalize(i.normal_dir);
                //切线方向
                half3 tangent_dir = normalize(i.tangent_dir);
                //副法线方向
                half3 binormal_dir = normalize(i.binormal_dir);
                //法线贴图
                float3x3 TBN = float3x3(tangent_dir, binormal_dir, normal_dir);
                half4 normalmap = tex2D(_NormalMap, i.uv);
                half3 normal_data = UnpackNormal(normalmap);
                normal_data.xy = normal_data.xy * _NormalIntensity;
                normal_dir = normalize(mul(normal_data.xyz, TBN));
                //平行光向量
                half3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
                //半角向量
                half3 half_dir = normalize(light_dir + view_dir);
            //直接光漫反射计算
                half3 direct_diffuse = base_color.xyz;
                half diff_term = max(0.0,dot(normal_dir, light_dir));
                half half_lambert = (diff_term + 1) * 0.5;
                #ifdef DIR_DIFFUSE
                half3 common_direct_diffuse = diff_term * _LightColor0.xyz * base_color.xyz * atten;
                //sss
                half2 uv_lut = half2(diff_term * atten + _SSSOffset, 1);
                half3 lut_color = tex2D(_SkinLut, uv_lut);
                half3 lut_linner = pow(lut_color, 2.2);
                half3 sss_diffuse = lut_linner * _LightColor0.xyz * base_color.xyz * half_lambert;
                direct_diffuse = lerp(common_direct_diffuse, sss_diffuse, skin);
                #endif


            //直接光高光反射计算
                half3 direct_spec = half3(0,0,0);
                #ifdef DIR_SPEC
                half NdotH = dot(normal_dir, half_dir);
                half smoothness = 1-roughness;
                half shininess = lerp(1,_Shininess,smoothness);
                direct_spec = pow(max(0.0, NdotH),shininess * smoothness) * spec_color
                      * _LightColor0.xyz *atten;// _SpecIntensity;
                #endif
                    
            //间接光漫反射计算
                half3 env_diffuse = half3(0,0,0);
                #ifdef ENV_DIFFUSE
                env_diffuse = custom_sh(normal_dir) * half_lambert * base_color;
                #endif

            //间接光高光反射计算
                half3 env_spec = half3(0,0,0);
                #ifdef ENV_SPEC
                half3 reflect_dir = reflect(-view_dir,normal_dir);
                reflect_dir = RotateAround(_Rotate,reflect_dir);
                roughness = roughness * (1.7 - 0.7 * roughness);
                float mip_level = roughness * 6.0;
                half4 color_cubemap = texCUBElod(_CubeMap, float4(reflect_dir,mip_level));
                half3 env_color = DecodeHDR(color_cubemap, _CubeMap_HDR);//确保在移动端能拿到HDR信息
                env_spec = env_color * spec_color * _Expose * _Tint.rgb * half_lambert;// ;
                #endif


                // half3 final_color = direct_diffuse + direct_spec + env_diffuse * 0.5 + env_spec;
                half3 final_color = direct_diffuse + direct_spec + env_diffuse * 0.5 + env_spec;
                half3 tone_color = ACESFilm(final_color);
                tone_color = pow(tone_color, 1.0 / 2.2);

                return half4(tone_color,1.0);
            }
            ENDCG
        }
    }
    FallBack  "Diffuse"
}
