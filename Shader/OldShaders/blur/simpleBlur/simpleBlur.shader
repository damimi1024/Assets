Shader "Unlit/simpleBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    //通过CGINCLUDE我们可以预定义一些下面在Pass中用到的struct以及函数，
    //这样在pass中只需要设置渲染状态以及调用函数,shader更加简洁明了
    CGINCLUDE
            #include "UnityCG.cginc"

            //blur结构体，从blur的vert函数传递到frag函数的参数
            struct v2f_data
            {
                float4 vertex:SV_POSITION;
                float2 uv:TEXCOORD0;
                float2 uv1:TEXCOORD1;
                float2 uv2:TEXCOORD2;
                float2 uv3:TEXCOORD3;
                float2 uv4:TEXCOORD4;
            };
            sampler2D _MainTex;
            //XX_TexelSize，XX纹理的像素相关大小width，height对应纹理的分辨率，x = 1/width, y = 1/height, z = width, w = height
            float4 _MainTex_TexelSize;

            //模糊半径
            float radius;
            v2f_data vertex_blur(appdata_img v){
                v2f_data o;
                o.vertex=UnityObjectToClipPos(v.vertex);
                o.uv=v.texcoord.xy;
                //计算uv上下左右四个点对于blur半径下的uv坐标
                o.uv1=v.texcoord.xy+radius*_MainTex_TexelSize*float2(1,1);
                o.uv2=v.texcoord.xy+radius*_MainTex_TexelSize*float2(-1,1);
                o.uv3=v.texcoord.xy+radius*_MainTex_TexelSize*float2(-1,-1);
                o.uv4=v.texcoord.xy+radius*_MainTex_TexelSize*float2(1,-1);
                return o;
            }

            fixed4 frag_blur(v2f_data i):SV_TARGET
            {
                fixed4 color=fixed4(0,0,0,0);
                color+=tex2D(_MainTex,i.uv);
                color+=tex2D(_MainTex,i.uv1);
                color+=tex2D(_MainTex,i.uv2);
                color+=tex2D(_MainTex,i.uv3);
                color+=tex2D(_MainTex,i.uv4);
                //相加取平均，据说shader中乘法比较快
                return color*0.2;
            }


    ENDCG
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
      
        Pass
        {
          ZTest Always
          Cull Off
          ZWrite Off
          Fog{ Mode Off }
          CGPROGRAM
          #pragma vertex vertex_blur
          #pragma fragment frag_blur
          ENDCG 
        }
    }
    FallBack "Diffuse"
}
