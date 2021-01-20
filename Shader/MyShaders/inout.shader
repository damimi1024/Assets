﻿Shader "Unlit/inout"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed("Speed",Vector)=(0.1,0.1,0.1,0.1)
        _CutOut("CutOut",float) = 0
        _MainColor("_MainColor",Color) = (1,1,1,1)
    }
    SubShader
    {
        Cull Off

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Tags { "Queue"="Transparent" }
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Speed;
            float _CutOut;
            float4 _MainColor;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv*_MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
				half4 gradient = tex2D(_MainTex, i.uv);

                //clip(gradient - _CutOut*(-abs(_SinTime.x*0.5)));

                return gradient;
            }
            ENDCG
        }
    }
}
