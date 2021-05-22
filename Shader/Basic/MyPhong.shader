Shader "Unlit/MyPhong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DiffuseColor ("Diffuse", Color) = (1,1,1,1)
        _Shininess ("Shininess", Range(0,100)) = 1
        _SpecIntensity ("SpecIntensity", float) = 1
        _NormalMap ("bump",2D) = "white"{}
        _NormalIntensity ("NormalIntensity",Range(0.0,5.0)) = 1
        _AOMap ("AOMap",2D) = "white"{}
        _SpecMap ("SpecMap",2D) = "white"{}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightModel" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            half4 _DiffuseColor;
            half _Shininess;
            half _SpecIntensity;
            sampler2D _NormalMap;
            sampler2D _AOMap;
            sampler2D _SpecMap;
             //ACES曲线 做色调映射使用
            float3 ACESFilm(float3 x)
            {
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;
                return saturate((x*(a*x + b)) / (x*(c*x + d) + e));
            };

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
                float3 tangent_world:TEXCOORD3;
                float3 binormal_world:TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _LightColor0;
            half _NormalIntensity;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal_world = mul(float4(v.normal, 0.0),unity_WorldToObject);
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.tangent_world = mul(unity_ObjectToWorld,v.tangent).xyz;
                o.binormal_world = normalize(cross(o.normal_world,o.tangent_world))*v.tangent.w ;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //获取向量信息
                //法线
                half3 normalDir = normalize(i.normal_world);
                //视口
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                //切线
                half3 tangengDir = normalize(i.tangent_world);
                //副法线
                half3 binormalDir = normalize(i.binormal_world);
                //光
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);


                //贴图信息
                //贴图
                half4 base_color = tex2D(_MainTex, i.uv);
                base_color = pow(base_color, 2.2);
                //法线
                half4 normalMap = tex2D(_NormalMap,i.uv);
                float3x3 TBN = float3x3(tangengDir,binormalDir,normalDir);
                half3 normalData = UnpackNormal(normalMap);
                normalData.xy = normalData.xy * _NormalIntensity;
                normalDir = normalize(mul(normalData.xyz,TBN)) ;
                //AO
                half4 AOColor = tex2D(_AOMap,i.uv);
                //高光贴图
                half4 SpecColor = tex2D(_SpecMap,i.uv);

                //blingphong :diffuse + spec + ambient
                //漫反射 diffuse
                //diffuse = max(0,ndotl)*diffusecolor*lightcolor
                half3 diffuse = max(0,dot(normalDir,lightDir)) * base_color.xyz *  _LightColor0.xyz;
                //高光计算 spec
                //spec = pow(max(0,ndoth),shiness)
                half3 halfDir = normalize(lightDir + viewDir);
                half NdotH = dot(normalDir, halfDir);
                half3 spec = pow(max(0,NdotH),_Shininess) * _SpecIntensity * SpecColor;
                //环境 ambient
                half3 ambient =  UNITY_LIGHTMODEL_AMBIENT.rgb * base_color.xyz;

                half3 finalCol = (diffuse + spec + ambient)*AOColor;
                half3 tone_color = ACESFilm(finalCol);
                finalCol = pow(tone_color, 1.0 / 2.2);
                return half4(finalCol,1);
            }
            ENDCG
        }

    Pass
        {
            Tags {"LightModel" = "ForwardAdd"}
            Blend One One 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            half4 _DiffuseColor;
            half _Shininess;
            half _SpecIntensity;
            sampler2D _NormalMap;
            sampler2D _AOMap;

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
                float3 tangent_world:TEXCOORD3;
                float3 binormal_world:TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _LightColor0;
            half _NormalIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal_world = mul(float4(v.normal, 0.0),unity_WorldToObject);
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.tangent_world = mul(unity_ObjectToWorld,v.tangent).xyz;
                o.binormal_world = normalize(cross(o.normal_world,o.tangent_world))*v.tangent.w ;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //获取向量信息
                //法线
                half3 normalDir = normalize(i.normal_world);
                //视口
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                //切线
                half3 tangengDir = normalize(i.tangent_world);
                //副法线
                half3 binormalDir = normalize(i.binormal_world);
                //点光
                half3 lightDirPoint = normalize(_WorldSpaceLightPos0.xyz - i.pos_world);
                //光
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //真实光
                lightDir = lerp(lightDir , lightDirPoint , _WorldSpaceLightPos0.w);

                //贴图信息
                //贴图
                half4 base_color = tex2D(_MainTex, i.uv);
                base_color = pow(base_color, 2.2);
                //法线
                half4 normalMap = tex2D(_NormalMap,i.uv);
                float3x3 TBN = float3x3(tangengDir,binormalDir,normalDir);
                half3 normalData = UnpackNormal(normalMap);
                normalData.xy = normalData.xy * _NormalIntensity;
                normalDir = normalize(mul(normalData.xyz,TBN)) ;
                //AO
                half4 AOColor = tex2D(_AOMap,i.uv);

                //blingphong :diffuse + spec + ambient
                //漫反射 diffuse
                //diffuse = max(0,ndotl)*diffusecolor*lightcolor
                half3 diffuse = max(0,dot(normalDir,lightDir)) * base_color.xyz *  _LightColor0.xyz;
                //高光计算 spec
                //spec = pow(max(0,ndoth),shiness)
                half3 halfDir = normalize(lightDir + viewDir);
                half NdotH = dot(normalDir, halfDir);
                half3 spec = pow(max(0,NdotH),_Shininess) * _SpecIntensity;
                
                half3 finalCol = (diffuse + spec)*AOColor;
                return half4(finalCol,1);
            }
            ENDCG
        }
    /*
    */
        
    }
    Fallback "Diffuse"
}
