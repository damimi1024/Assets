Shader "Unlit/Grow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScaleControl("ScaleControl",float) = 1
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
                float3 normal :NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _ScaleControl;

            v2f vert (appdata v)
            {
                v2f o;
                float3 offset = v.normal * 0.01 * 2;
                o.vertex = UnityObjectToClipPos(v.vertex+v.normal* _ScaleControl*0.01+offset);
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = fixed4(i.vertex.x,i.vertex.y,i.vertex.z,1); 
                return col;
            }
            ENDCG
        }
    }
}
