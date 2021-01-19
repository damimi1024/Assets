// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/testColor33"
{
	Properties
	{
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				fixed4 color:COLOR;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				//float4 wpos=mul(unity_ObjectToWorld,v.vertex);
				if(v.vertex.x==0.5&&v.vertex.y==0.5&&v.vertex.z==-0.5)
					o.color=fixed4(_SinTime.w/2+0.5f,_CosTime.w/2+0.5f,_SinTime.y/2+0.5f,1);
				else
					o.color=fixed4(1,1,1,1);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_TARGET
			{
				// sample the texture
				fixed4 col = i.color;
				return col;
			}
			ENDCG
		}
	}
}
