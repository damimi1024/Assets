// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/inout"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed("Speed",Vector)=(0.1,0.1,0.1,0.1)
        _CutOut("CutOut",float) = 0
        _MainColor("_MainColor",Color) = (1,1,1,1)
        _InOutTex("InOutTex",2D) = "white"{}

        _Dis("Dis",Range(0,2)) = 0
    }
    SubShader
    {
        Cull Off

        Blend Zero SrcAlpha
        ZWrite Off
        Tags { "Queue"="Transparent" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Speed;
            float _CutOut;
            float4 _MainColor;
            sampler2D _InOutTex;
            float _Dis;
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 center :  TEXCOORD2;
                float3 oriPos : TEXCOORD3;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv*_MainTex_ST.xy + _MainTex_ST.zw;
                //将模型中点坐标计算出来
                float4 temp = mul(unity_ObjectToWorld,float4(0,0,0,1));
                o.center = mul(unity_WorldToObject,temp).xyz;
                o.oriPos = v.vertex.xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //采样 进行扩散
                // float4 uv_color=tex2D(_MainTex,i.uv);
                // fixed4 color=tex2D(_MainTex,uv_color.xy+_Time.y/2) ;//
                // clip(color.r-0.5);

                //剔除边缘
                // fixed dis = distance(fixed2(i.uv.x,i.uv.y),fixed2(0.5,0.5));
                // clip(0.5-dis);

                float dis = distance(i.oriPos.xyz,i.center);
                clip(_Dis-dis);
                return _MainColor;

            }
            ENDCG
        }
    }
}
