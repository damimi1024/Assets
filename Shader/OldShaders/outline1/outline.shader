// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

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
//注1：
//我们通过UNITY_MATRIX_IT_MV矩阵将法线转换到视空间，这里可能会比较好奇，为什么不用正常的顶点转化矩阵来转化法线，
//其实主要原因是如果按照顶点的转换方式，对于非均匀缩放（scalex, scaley,scalez不一致）时，
//会导致变换的法线归一化后与面不垂直。如下图所示，左边是变化前的，而中间是沿x轴缩放了0.5倍的情况，
//显然变化后就不满足法线的性质了，而最右边的才是我们希望的结果。造成这一现象的主要原因是法线只能保证方向的一致性，
//而不能保证位置的一致性；顶点可以经过坐标变换变换到正确的位置，但是法线是一个向量，我们不能直接使用顶点的变换矩阵进行变换。

//我们可以推导一个法线的变换矩阵，就能够保证转化后的法线与面垂直，法线的变换矩阵为模型变换矩阵的逆转置矩阵。
//在把法线变换到了视空间后，就可以取出其中只与xy面有关的部分，视空间的z轴近似于深度，我们只需要法线在x,y轴的方向，再通过TransformViewToProjection方法，
//将这个方向转化到投影空间，最后用这个方向加上经过MVP变换的坐标，实现轻微外拓的效果。（从网上和书上看到了不少在这一步计算的时候，又乘上了pos.z的操作，
//个人感觉没有太大的用处，而且会导致描边效果越远，线条越粗的情况，离远了就会出现一团黑的问题，
