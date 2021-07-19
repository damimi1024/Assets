Shader "Unlit/StormStar"
{
    Properties
    {
        _Normal ("Normal", 2D) = "bump" {}

        //边缘光
        [Header(RimLight)]
        _RimBias ("RimBias", Float) = 1
        _RimScale ("RimScale", Float) = 1
        _RimPower ("RimPower", Float) = 1
        [HDR]_RimColor ("RimColor", Color) = (1,1,1,1)
        _NormalIntensity ("NormalIntensity", Float) = 1

        //流光
        [Header(Flow)]
        _FlowTex("FlowTex",2D) = "white"{}
        _FlowTillingSpeed("FlowTillingSpeed",Vector) =(1,1,0,0)
        _FlowStrength("FlowStrength",float) = 0.5
        [HDR]_FlowColor ("FlowColor", Color) = (1,1,1,1)

        //星云效果
        [Header(StarStorm)]
        [NoScaleOffset]_StarTex("StarTex",2D) = "white"{}
        [NoScaleOffset]_StarFlowMap ("StarFlowMap", 2D) = "black" {}
        _StarTillingOffset("_StarTillingOffset",Vector) =(1,1,0,0)
        _StarFlowMapSpeed ("StarFlowMapSpeed", float) = 1

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
            #include "Lighting.cginc"

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
                float3 normalWorld : TEXCOORD1;
                float3 tangentWorld : TEXCOORD2;
                float3 binormalWorld : TEXCOORD3;
                float3 posWorld : TEXCOORD4;
                float3 centerWorld :TEXCOORD5;
                float3 pos :TEXCOORD6;
            };

            sampler2D _Normal;
            float _NormalIntensity;
            float3 _RimColor;
            float _RimBias;
            float _RimScale;
            float _RimPower;

            sampler2D _FlowTex;
            float4 _FlowTillingSpeed;
            float _FlowStrength;
            float3 _FlowColor;

            sampler2D _StarTex;
            sampler2D _StarFlowMap;
            float4 _StarTillingOffset;
            float _StarFlowMapSpeed;
       

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normalWorld = mul(float4(v.normal, 0.0), unity_WorldToObject).xyz;
                o.tangentWorld  = mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz;
                o.binormalWorld  = cross(o.normalWorld,o.tangentWorld) * v.tangent.w *unity_WorldTransformParams.w;
                o.posWorld  = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 0.0)).xyz;
                //将模型中点坐标计算出来
                o.centerWorld  = mul(unity_ObjectToWorld,float4(0,0,0,1));
                o.pos = v.vertex;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //向量
                    //发现方向
                    half3 normal_dir = normalize(i.normalWorld);
                    //切线方向
                    half3 tangent_dir = normalize(i.tangentWorld);
                    //副法线方向
                    half3 binormal_dir = normalize(i.binormalWorld);
                    //光向量
                    half3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
                    //视角向量
                    half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);

                //法线计算
                    float3x3 TBN = float3x3(tangent_dir,binormal_dir,normal_dir);
                    float3 normalData = UnpackNormal(tex2D(_Normal,i.uv));
                    normalData.xy = normalData.xy * _NormalIntensity;
                    normal_dir = normalize(mul(normalData.xyz, TBN));

                //常用变量
                    float NDotL = max(0.0,dot(normal_dir,light_dir)); 
                    float NDotV = max(0.0,dot(normal_dir,view_dir)); 
                    float halfLambert = (NDotL+1) * 0.5;
                    half3 fresenel = (_RimBias + _RimScale * pow((1-NDotV),_RimPower)) * _RimColor;

                //流光
                    float2 flow_uv = (i.posWorld.xy-i.centerWorld.xy) * _FlowTillingSpeed.xy+_Time.y*_FlowTillingSpeed.zw ;//+ (NDotV*0.5 +0.5)
                    fixed3 flowColor = tex2D(_FlowTex,flow_uv).xyz  *_FlowStrength * _FlowColor * (1- NDotV);

                //星云效果
                    float3 objToView = mul( UNITY_MATRIX_MV, float4( i.pos.xyz, 1 ) ).xyz;
                    float3 objToView2 = mul( UNITY_MATRIX_MV, float4(0,0,0,1)).xyz;
                    float2 star_uv = (objToView.xy-objToView2.xy) * _StarTillingOffset.xy + _StarTillingOffset.zw;
                    //加上一个flowmap效果
                    //先算个时间
                    float2 timeDelta = frac(_Time.y*_StarFlowMapSpeed);
                    //再算个间隔帧时间
                    float2 timeNext = frac(_Time.y*_StarFlowMapSpeed+0.5);
                    //再算个两个时间插值的插值因子
                    float timeLerp = abs(frac(_Time.y*_StarFlowMapSpeed)*2-1);
                    //采样flowmap 当做干扰方向
                    half2 flowDir = (0.5-tex2D(_StarFlowMap,star_uv).xy);
                    //前后状态的流动效果
                    half2 flowMap = flowDir*timeDelta;
                    half2 flowMapNext = flowDir*timeNext; 
                    half4 mainTexpre = tex2D(_StarTex,star_uv+flowMap);
                    half4 mainTexNext = tex2D(_StarTex,star_uv+flowMapNext);
                    //插值两个流动效果 减少顿挫感
                    half3 starCol =  lerp(mainTexpre,mainTexNext,timeLerp).xyz;

                float3 finalCol = (fresenel + flowColor + starCol);
                return fixed4(finalCol,1);
            }
            ENDCG
        }
    }
}
