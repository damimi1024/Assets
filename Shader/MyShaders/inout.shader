Shader "Unlit/inout"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed("Speed",float)=0
    }
    SubShader
    {
        Cull Off
        Tags { "RenderType"="Transparent" }
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
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv*_MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);


                clip(_SinTime.x*_Speed-col.r);
                return col;
            }
            ENDCG
        }
    }
}
