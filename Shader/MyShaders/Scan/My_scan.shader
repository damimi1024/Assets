Shader "Unlit/My_scan"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor("MainColor",Color)=(1,1,1,1)
        [HDR]_RimColor("RimColor",Color)=(1,1,1,1)
        //边缘光强度
        _RimStrenght("RimStrenght",float) = 1
        _RimMin("RimMin",Range(-1,1)) = 0
        _RimMax("RimMax",Range(0,2)) = 1
        //流光
        _FlowTex("FlowTex",2D) = "white"{}
        _Rate("Rate",float) = 1
        _FlowTilling("FlowTilling",Vector) =(1,1,0,0)
        _FlowSpeed("FlowSpeed",Vector) =(1,1,0,0)
        _FlowStrength("FlowStrength",float) = 0.5

    }
    SubShader
    {
        Cull Back
        ZWrite Off 
        Blend SrcAlpha OneMinusSrcAlpha
        Tags { "Queue"="Transparent" }

        Pass {
            Cull Off 
            ZWrite On 
            ColorMask 0
            CGPROGRAM
            float4 _Color;
            #pragma vertex vert 
            #pragma fragment frag

            float4 vert(float4 vertexPos : POSITION) : SV_POSITION
            {
                return UnityObjectToClipPos(vertexPos);
            }

            float4 frag(void) : COLOR
            {
                return _Color;
            }
            ENDCG
        }

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
            float _FlowStrength;


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
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 world_normal = normalize(i.worldNormal);
                fixed3 world_view = normalize(i.viewDir);
                fixed4 color = tex2D(_MainTex,i.uv);
                //rim
                float NDotV = smoothstep(_RimMin,_RimMax,saturate(1-dot(world_normal,world_view))) ;
                fixed4 rimColor = lerp(_MainColor,_RimColor*_RimStrenght,NDotV);
                fixed rimAlpha = NDotV;
                //flow
                float2 flow_uv = (i.oriPos.xy-i.center.xy)+_Time.y*_FlowSpeed;
                float4 flowColor = tex2D(_FlowTex,flow_uv)*rimColor;
                fixed flowAlpha = flowColor.a+rimAlpha;

                fixed4 col = tex2D(_MainTex,i.uv); 
                fixed4 oriFlowColor = tex2D(_FlowTex,flow_uv);

                fixed4 final_color = flowColor+col;
                float final_alpha ;
                if (oriFlowColor.a >=0.1 )
                    final_alpha = flowAlpha;
                else
                    final_alpha = 1;

                return fixed4(final_color.xyz,final_alpha) ;
            }
            ENDCG
        }
    }
}
