Shader "Unlit/ScreenImage"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 screen_pos :TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // o.screen_pos = o.pos;
                //* _ProjectionParams.x 是为了处理不同平台坐标系差异问题
                // o.screen_pos.y = o.screen_pos.y * _ProjectionParams.x;
                o.screen_pos = ComputeScreenPos(o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                //透视除法(-1,1) 放在片源shader是因为如果在定点shader中 光栅化过程会有影响
                half2 screen_uv = i.screen_pos.xy / (i.screen_pos.w+0.000001);
                //(0,1) 因为ComputeScreenPos 下面这步就不用了
                // screen_uv = (screen_uv + 1) * 0.5;
                fixed4 col = tex2D(_MainTex, screen_uv);
                return col;
            }
            ENDCG
        }
    }
}
