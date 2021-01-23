Shader "Unlit/scanCode"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor("MainColor",Color)=(1,1,1,1)
        _RimColor("RimColor",Color)=(1,1,1,1)
        //边缘光强度
        _RimStrenght("RimStrenght",float) = 1

        _RimMin("RimMin",Range(-1,1)) = 0
        _RimMax("RimMax",Range(0,2)) = 1
        //流光
        _FlowTex("FlowTex",2D) = "white"{}
        _Rate("Rate",float) = 1
        _FlowTilling("FlowTilling",Vector) =(1,1,0,0)
        _FlowSpeed("FlowSpeed",Vector) =(1,1,0,0)
    }
    SubShader
    {
        Cull Back
        ZWrite Off 
        Blend SrcAlpha One
        Tags { "Queue"="Transparent" }
        //LOD 100

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
                float3 normal :NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal :TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 center :TEXCOORD3 ;
                float3 oriPos :TEXCOORD4 ; 
            };

            sampler2D _MainTex;
            sampler2D _FlowTex;
            float4 _MainColor;
            float4 _MainTex_ST; 
            fixed4 _RimColor;
            float _RimStrenght;
            float _RimMin;
            float _RimMax;
            float _Rate;
            float4 _FlowTilling;
            float2 _FlowSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject)) ;
                //转化世界坐标空间
                o.oriPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.viewDir = _WorldSpaceCameraPos - o.oriPos;

                //将模型中点坐标计算出来
                o.center  = mul(unity_ObjectToWorld,float4(0,0,0,1));
                //o.center = mul(unity_WorldToObject,temp).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 world_normal=normalize(i.worldNormal);
                fixed3 view_dir = normalize(i.viewDir);
                fixed fresnel = 1-saturate(dot(view_dir,world_normal));//,_RimMin,_RimMax
                fresnel = smoothstep(_RimMin,_RimMax,fresnel);

                // fixed4 rim=_RimColor*_RimStrenght;
                // fixed4 RimColor = lerp(_MainColor,rim,fresnel);
                // float2 temp = (i.oriPos.xy-i.center.xy)*_Rate+_Time.y;
                // fixed4 FlowColor = tex2D(_FlowTex,temp);

                half emiss = tex2D(_MainTex,i.uv).r;
                emiss = pow(emiss,5);
                half final_fresnel = saturate(fresnel+emiss);
                half3 rim_color = lerp(_MainColor,_RimColor*_RimStrenght,final_fresnel).xyz;
                half rim_alpha = final_fresnel;

                half2 uv_flow = (i.oriPos.xy - i.center.xy)*_FlowTilling.xy;
                uv_flow = _Time.y*_FlowSpeed.xy +uv_flow;
                float4 flow_rgba = tex2D(_FlowTex,uv_flow)*0.1;
                float final_alpha = saturate(rim_alpha+flow_rgba.a+0.7);

                return fixed4(rim_color+flow_rgba,final_alpha);//fixed4(rim_color,rim_alpha);
            }
            ENDCG
        }
    }
}
