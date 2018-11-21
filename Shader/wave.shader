Shader "Unlit/wave"
{
	Properties
	{
		_Color("Color",Color  )=(1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
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
			uniform color _Color
			struct appdata {
    			float4 vertex : POSITION;
    			float3 normal : NORMAL;
    			float4 texcoord : TEXCOORD0;
    			float4 texcoord2 : TEXCOORD1;
			};
			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 color:COLOR;
			};

			v2f vert (appdata v)
			{
				v2f o;
				//v.vertex.y+=0.2*sin(-length(v.vertex.xz)+_Time.y*3);//圆形波
				v.vertex.y+=0.2*sin(v.vertex.x+v.vertex.z+_Time.y);
				v.vertex.y+=0.3*sin(v.vertex.x-v.vertex.z+_Time.w);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color=fixed4(v.vertex.y,v.vertex.y,v.vertex.y,1);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				
				return i.color;
			}
			ENDCG
		}


	}
}
