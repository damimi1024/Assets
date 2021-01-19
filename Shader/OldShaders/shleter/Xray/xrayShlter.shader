Shader "Unlit/xrayShlter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RayColor("Color",Color)=(1,1,1,1)
    }
    SubShader
    {
        Tags {"Queue"="Geometry" "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Blend SrcAlpha One
            ZTest Greater
            ZWrite Off 
            CGPROGRAM
            #include "Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal:NORMAL;
                float3 viewDir:TEXCOORD0 ; 
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _RayColor; 

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal=v.normal;
                o.viewDir=ObjSpaceViewDir(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal=normalize(i.normal);
                float3 viewDir=normalize(i.viewDir);
                float rim=1-dot(normal,viewDir);
                return _RayColor*rim;
            }
            ENDCG
        }
        Pass {
            ZWrite On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            sampler2D _MainTex;
            float4 _MainTex_ST; 
            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD1  ;

            };
            v2f vert ( appdata_base v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }
            fixed4 frag(v2f i):SV_Target{
                return tex2D(_MainTex,i.uv);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
