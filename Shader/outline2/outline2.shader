
//模型有时候会渲染背面，就需要关闭背面剔除（Cull Off），这种情况下，
//使用Cull Front只渲染背面，就有可能和第二次正常渲染的时候的背面穿插，造成效果不对的情况

//解决方案：用深度操作神器Offset指令，控制深度测试，比如我们可以让渲染描边的Pass深度远离相机一点，
//这样就不会与正常的Pass穿插了，修改一下描边的Pass，其实只多了一句话Offset 1,1： 即27行 （offset相关知识记录在日事清中）
Shader "Unlit/outline"
{
     Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse("DiffuseColor",Color)=(1,1,1,1)
        _OutLineStrength("strenght",Range(0,10))=1
        _OutLineColor("outLineColor",Color)=(1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        //将物体的顶点沿法线外移一定距离 
        //注意点：如果先外延再进行mvp变换 远时描边效果很小 解决方案：先MVP变换再外延
        Pass
        {
            //剔除正面，只渲染背面，对于大多数模型适用，不过如果需要背面的，就有问题了
            Cull Front
            Offset 1,1
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _OutLineColor;
            float _OutLineStrength;
            struct v2f{
                float4 pos:SV_POSITION;
                float3 normal:TEXCOORD0;

            };
            v2f vert(appdata_full v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //将法线方向转换到视空间(见注1)
                float3 vnormal=mul((float3x3)UNITY_MATRIX_IT_MV,v.normal);
                //将视空间法线xy坐标转化到投影空间，只有xy需要，z深度不需要了
                float2 offset=TransformViewToProjection(vnormal.xy);
                //在最终投影阶段输出进行偏移操作
                o.pos.xy+=offset*_OutLineStrength;
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                return _OutLineColor;
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"


            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Diffuse;
            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 viewDir:TEXCOORD1;
                float2 uv:TEXCOORD2;
            };


            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldNormal=mul(v.normal,(float3x3)unity_ObjectToWorld);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*_Diffuse.xyz;

                float3 worldNormal=normalize(i.worldNormal) ;

                fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);

                fixed3 halfLambert=0.5*dot(worldNormal,worldLightDir)+0.5;
                //最终输出颜色为lambert光强*材质diffuse颜色*光颜色
                fixed3 diffuse = halfLambert * _Diffuse.xyz * _LightColor0.xyz + ambient;
                //纹理采样
                fixed4 col;
                col=tex2D(_MainTex,i.uv);
                col.rgb =col.rgb *diffuse;
                return col;
            }
            ENDCG
        }
    }
}
