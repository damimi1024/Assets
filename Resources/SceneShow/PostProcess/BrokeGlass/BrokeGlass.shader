Shader "Unlit/BrokeGlass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GlassMask ("GlassMask",2D) = "black" {}
        _GlassColor ("GlassColor",Color) = (1,1,1,1)
        _GlassCrack ("GlassCrack",Range(-10,10)) = 1
        _GlassNormal ("GlassNormal",2D) = "bump" {}
        _Distort ("Distort",Range(0,10)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _GlassMask;
            float4 _GlassMask_ST;
            float4 _GlassColor;
            float _GlassCrack;
            sampler2D _GlassNormal;
            float _Distort;

            fixed4 frag (v2f_img i) : SV_Target
            {
                //宽高比
                half aspect = _ScreenParams.x / _ScreenParams.y;
                half2 glass_uv = i.uv * _GlassMask_ST.xy + _GlassMask_ST.zw;
                // glass_uv.x = glass_uv.x * aspect;
                half glass_opacity = tex2D(_GlassMask,glass_uv).r * _GlassCrack;

                //折射偏移部分
                half3 glassNormal = UnpackNormal(tex2D(_GlassNormal,glass_uv));
                float2 d = 1 - smoothstep(0.95,1,abs(glassNormal.xy * 2 -1));
                float vfactor = d.x * d.y;

                float2 d_mask = step(0.005,abs(glassNormal.xy));
                float mask = d_mask.x * d_mask.y;

                half2 uvDistort = i.uv + glassNormal.xy * _Distort * mask *vfactor;
                fixed4 col = tex2D(_MainTex, uvDistort);
                half3 finalColor = col.rgb;
                
                finalColor = lerp(finalColor.rgb,_GlassCrack.xxx,glass_opacity);
                return half4(finalColor,col.a);
            }
            ENDCG
        }
    }
}
