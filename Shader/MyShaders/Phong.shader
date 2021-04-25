Shader "Unlit/MyShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AOMap("AO",2D) = "white"{}
        _SpecMap("_SpecMap",2D) = "white"{}
        _NormalMap("_NormalMap",2D) = "bump"{}
        _Smoothness("Smoothness", Range(1,100)) = 1
        _AmbientColor("_AmbientColor",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{ "LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normalWorld :TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float3 bioNormalWorld : TEXCOORD3 ;
                float3 tangentWorld : TEXCOORD4 ; 
            };

            sampler2D _MainTex;
            sampler2D _AOMap;
            sampler2D _SpecMap;
            sampler2D _NormalMap;
            float4 _MainTex_ST;
            float _Smoothness;
            float4 _AmbientColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normalWorld = UnityObjectToWorldNormal(v.normal);
                o.tangentWorld = mul(unity_ObjectToWorld,v.tangent);
                o.bioNormalWorld = cross(o.normalWorld,o.tangentWorld);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
            //文理采样
                fixed4 base_color = tex2D(_MainTex,i.uv);
                fixed4 ao_color = tex2D(_AOMap,i.uv);
                fixed4 spec_color = tex2D(_SpecMap,i.uv);
                fixed4 normal_info = tex2D(_NormalMap,i.uv);

            //获取向量信息
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz-i.worldPos);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 halfDir = normalize(lightDir + viewDir);
                float3 tangentDir = normalize(i.tangentWorld);
                float3 bioNormalWorld = normalize(i.bioNormalWorld);
                float3 normalDir = normalize(i.normalWorld);
                //法线贴图
                float3 normalData = UnpackNormal(normal_info);
                float3x3 TBN = float3x3(tangentDir,bioNormalWorld,normalDir);
                normalDir = normalize(mul(normalData,TBN)) ;
                float3 reflectDir = normalize(reflect(-lightDir, normalDir));

            //变量信息
                fixed3 diffuseColor = max(0,dot(normalDir,lightDir)) * _LightColor0.xyz * base_color.xyz;
                fixed3 specColor = pow(max(0,dot(reflectDir, viewDir)),_Smoothness) * _LightColor0.xyz * base_color;

            //光照公式
                
                //float blinnPhong = pow(max(0, dot(halfDir, normalDir)), _Smoothness);
                // float Phong = pow(max(0, dot(reflectDir, viewDir)), _Smoothness);
                //fixed4 col = tex2D(_MainTex, i.uv);
                fixed3 finalcolor = (diffuseColor + specColor + _AmbientColor.xyz) * ao_color * spec_color ;
                return fixed4(finalcolor,1);
            }
            ENDCG
        }

        Pass
        {
            Tags{ "LightMode" = "ForwardAdd"}
            Blend One One 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
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
                float3 normalWorld :TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _AOMap;
            sampler2D _SpecMap;
            float4 _MainTex_ST;
            float _Smoothness;
            float4 _AmbientColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normalWorld = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //文理采样
                fixed4 base_color = tex2D(_MainTex,i.uv);
                fixed4 ao_color = tex2D(_AOMap,i.uv);
                fixed4 spec_color = tex2D(_SpecMap,i.uv);
                //获取向量信息
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz-i.worldPos);
                float3 lightDir;
                float attenuation = 0;
                #if defined (DIRECTIONAL)
                lightDir = normalize(_WorldSpaceLightPos0.xyz);
                attenuation = 1;
                #elif defined (POINT)
                lightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos );
                float distance = length(_WorldSpaceLightPos0.xyz - i.worldPos );
                float range = 1 / unity_WorldToLight[0][0];
                attenuation = saturate( (range - distance) / range) ;
                #elif defined (POINT)
                lightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos );
                float distance = length(_WorldSpaceLightPos0.xyz - i.worldPos );
                float range = 1 / unity_WorldToLight[0][0];
                attenuation = saturate( (range - distance) / range) ;
                #endif  
                float3 halfDir = normalize(lightDir + viewDir);
                float3 normalDir = normalize(i.normalWorld);
                float3 reflectDir = normalize(reflect(-lightDir, normalDir));

                //变量信息
                fixed3 diffuseColor = max(0,dot(normalDir,lightDir)) * _LightColor0.xyz * base_color.xyz * attenuation;
                fixed3 specColor = pow(max(0,dot(reflectDir, viewDir)),_Smoothness) * _LightColor0.xyz * base_color * attenuation;

                //光照公式
                
                //float blinnPhong = pow(max(0, dot(halfDir, normalDir)), _Smoothness);
                // float Phong = pow(max(0, dot(reflectDir, viewDir)), _Smoothness);
                //fixed4 col = tex2D(_MainTex, i.uv);
                fixed3 finalcolor = (diffuseColor + specColor + _AmbientColor.xyz) * ao_color * spec_color ;
                return fixed4(finalcolor,1);
            }
            ENDCG
        }
    }
}
