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
            #include "yang.cginc"
            fixed4 _RimColor;
            struct v2f
            {
                fixed4 pos:POSITION;
                fixed4 col:COLOR;
                fixed2 tex:TEXCOORD0; 
                
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos=fixed4(1,1,1,1);
                o.col=fixed4(1,0,1,0.5);
                func(1);
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
