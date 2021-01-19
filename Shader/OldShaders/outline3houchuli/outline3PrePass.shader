Shader "Unlit/outline3PrePass"
{
    //用于把模型渲染到render texture的shader
    SubShader
    {
        Pass{
               CGPROGRAM
                 #include "UnityCG.cginc"
                 #pragma vertex vert
                 #pragma fragment frag
                 fixed4 _OutlineCol;

                 struct v2f{
                 float4 pos:SV_POSITION;
                 };

                v2f vert(appdata_base v){
                 v2f o;
                 o.pos=UnityObjectToClipPos(v.vertex);
                return o;
                }
                fixed4 frag(v2f i):SV_Target{
                return fixed4(1,0,0,1);
                }
                ENDCG
        }
    
    }
}
