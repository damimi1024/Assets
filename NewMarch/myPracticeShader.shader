// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/myPracticeShader"
{
    Properties
    {
        _RimColor("Color",Color)=(1,1,1,1)
    }
    SubShader
    {
 
        Pass 
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            fixed4 _RimColor;
            uniform float4x4 rm;
            struct v2f
            {
                fixed4 pos:POSITION;
                fixed4 col:COLOR;
                fixed2 tex:TEXCOORD0; 
                
            };

            v2f vert(appdata_base v)
            {
                v2f o;

                o.pos=UnityObjectToClipPos(v.vertex)*_SinTime;

                return o;
            } 
            fixed4 frag(v2f IN):COLOR
            {
                return _RimColor;
            }
            ENDCG
        }
    }
}
