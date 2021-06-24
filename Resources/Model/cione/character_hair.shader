 Shader "character_Hair"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap("NormalMap",2D) = "bump"{}
        _CubeMap("Cube Map",Cube) = "white"{}
        _CompMask("_CompMask",2D) = "compMask"{}
        _SpecIntensity("SpecIntensity",Range(0.01,5)) = 1.0
        _NormalIntensity("Normal Intensity",Range(0.0,5.0)) = 1.0
        _Rotate("Rotate",Range(0,360)) = 0
        _Expose("Expose",Range(0,1)) = 1.0
        _BaseColor("BaseColor",Color) = (1,1,1,1)


        _AnisoMap ("Aniso Map",2D) = "white" {}    
        _Shininess1 ("Shininess 1",Range(0,1)) = 1.0
        _SpecColor1 ("SpecColor 1",Color) = (1,1,1,1)
        _SpecNoise1 ("SpecNoise 1",float) = 1.0
        _SpecOffset1("SpecOffset 1",float) = 0
 

        _Shininess2 ("Shininess 2",Range(0,1)) = 1.0
        _SpecColor2 ("SpecColor 2",Color) = (1,1,1,1)
        _SpecNoise2 ("SpecNoise 2",float) = 1.0
        _SpecOffset2("SpecOffset 2",float) = 0

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
            samplerCUBE _CubeMap;
            float4 _CubeMap_HDR;
            float4 _MainTex_ST;
            float _Rotate;
            float4 _LightColor0;
            float _SpecIntensity;
            float _NormalIntensity;
            float _Expose;
            float4 _BaseColor;

            sampler2D _AnisoMap;
            float4 _AnisoMap_ST;
            float _Shininess1;
            float4 _SpecColor1;
            float _SpecNoise1;
            float _SpecOffset1;

            float _Shininess2;
            float4 _SpecColor2;
            float _SpecNoise2;
            float _SpecOffset2;


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
                half3 base_color = pow(col, 2.2)*_BaseColor;
                half3 spec_color = base_color;
                half roughness = saturate(0.5);

                //shadow map 需要写在for循环前 其实是因为变量i重名 或者将for循环的i改名 
                 //half atten = SHADOW_ATTENUATION(i);

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
                //直接光漫反射计算
                half3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
                half atten = LIGHT_ATTENUATION(i);

                half diff_term = max(0.0,dot(normal_dir, light_dir));
                half half_lambert = (diff_term + 1) * 0.5;
                half3 common_direct_diffuse = diff_term * _LightColor0.xyz * base_color.xyz * atten;
                half3 direct_diffuse =  base_color;
                //direct_diffuse = min(direct_diffuse, common_direct_diffuse);
                

                //直接光高光反射计算
                half2 uv_aniso = i.uv * _AnisoMap_ST.xy + _AnisoMap_ST.zw;
                half aniso_noise = tex2D(_AnisoMap,uv_aniso).r - 0.5;
                half3 half_dir = normalize(light_dir + view_dir);
                half NdotH = dot(normal_dir, half_dir);
                half TdotH = dot(half_dir,tangent_dir);
                half NdotV = max(0,dot(view_dir,normal_dir));
                //求出各向异性高光衰减值 否则阴影部分也能看到高光
                float aniso_atten = saturate(sqrt(max(0,half_lambert/NdotV)))*atten;
                float3 spec_color1 = _SpecColor1.rgb + base_color;
                float3 aniso_offset1 = normal_dir * (aniso_noise * _SpecNoise1 + _SpecOffset1);
                float3 binormal_dir1 = normalize(binormal_dir + aniso_offset1);
                float BdotH1 = dot(half_dir,binormal_dir1)/_Shininess1;
                float3 spec_term1 = exp(-(TdotH *TdotH + BdotH1 * BdotH1)/(1 + NdotH));
                float3 final_spec1 = spec_term1 * aniso_atten * atten * spec_color1 *_LightColor0.xyz;

                // half smoothness = 1-roughness;
                // half shininess = lerp(1,_Shininess1,smoothness);
                // half3 direct_spec = pow(max(0.0, NdotH),shininess * smoothness) * spec_color
                //       * _LightColor0.xyz *atten;// _SpecIntensity;
                


                //间接光镜面反射计算
                half3 reflect_dir = reflect(-view_dir,normal_dir);
                reflect_dir = RotateAround(_Rotate,reflect_dir);
                roughness = roughness * (1.7 - 0.7 * roughness);
                float mip_level = roughness * 6.0;
                half4 color_cubemap = texCUBElod(_CubeMap, float4(reflect_dir,mip_level));
                half3 env_color = DecodeHDR(color_cubemap, _CubeMap_HDR);//确保在移动端能拿到HDR信息
                half3 env_spec = env_color * spec_color * _Expose *  half_lambert;// ;


                // half3 final_color = direct_diffuse + direct_spec + env_diffuse * 0.5 + env_spec;
                //half3 final_color = direct_diffuse + final_spec1 + env_spec;
                half3 final_color = direct_diffuse + final_spec1 + env_spec ;
                half3 tone_color = ACESFilm(final_color);
                tone_color = pow(tone_color, 1.0 / 2.2);

                return half4(tone_color,1.0);
            }
            ENDCG
        }
    }
    FallBack  "Diffuse"
}
