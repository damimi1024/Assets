// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/rimLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RimPower("Strength",Range(0.0001,3.0))=0.1
        _RimColor("Color",Color)=(1,1,1,1)
        _Diffuse("Diffuse",Color)=(1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
        #include "Lighting.cginc"

            sampler2D _MainTex;
            float _RimPower;
            fixed4 _RimColor;
            fixed4 _Diffuse;
            //使用了Transform_Tex宏就要定义xxx_ST
            float4 _MainTex_ST;

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal:NORMAL;
                float3 WorldNormal:TEXCOORD1;
                float3 viewDir :TEXCOORD2;
                

            };
            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //通过TRANSFORM_TEX宏转化纹理坐标，主要处理了Offset和Tiling的改变,默认时等同于o.uv = v.texcoord.xy;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.WorldNormal=mul(v.normal,(float3x3)unity_WorldToObject);
                //顶点转化到世界空间
                float3 worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
                //可以把计算计算ViewDir的操作放在vertex shader阶段，毕竟逐顶点计算比较省
                o.viewDir=_WorldSpaceCameraPos.xyz-worldPos;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //计算环境光
                fixed3 diffuse=UNITY_LIGHTMODEL_AMBIENT.xyz*_Diffuse.xyz;
                //法线归一化
                fixed3 worldNormal=normalize(i.WorldNormal);
                //光照归一化
                fixed3 lightDir=normalize(_WorldSpaceLightPos0.xyz);
            
                //根据半兰伯特计算像素的光照信息
                fixed3 lambert=0.5*dot(worldNormal,lightDir)+0.5;
                //文理采样
                fixed4 color=tex2D(_MainTex,i.uv);






                //视线方向归一化
                fixed3 viewDir=normalize(i.viewDir);
                //计算视线方向与法线方向的夹角，夹角越大，dot值越接近0，
                //说明视线方向越偏离该点，也就是平视，该点越接近边缘
                float rim=1-max(0,dot(viewDir,worldNormal));
            //计算rimlight
                fixed3 rimcolor=_RimColor*pow(rim,1/_RimPower);
                //输出颜色+边缘光颜色
                color.rgb=color.rgb*diffuse+rimcolor;

                return fixed4(color);
            }
            ENDCG
        }
    }
}
