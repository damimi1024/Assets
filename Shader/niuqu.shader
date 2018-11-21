// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/niuqu"
{
	Properties
	{
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

			struct v2f  
			{ 
				float4 pos:POSITION;
				fixed4 color:COLOR;
			};

			v2f vert (appdata_base v)
			{
				float angle=length(v.vertex)*_SinTime.w;
				float4x4 m={ 
					float4(cos(angle),0,sin(angle),0 ),
					float4(0,1,0,0),
					float4(-sin(angle),0,cos(angle),0),
					float4(0,0,0,1),
				};

				v.vertex=mul(m,v.vertex);
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);

				o.color=fixed4(0,1,1,1);
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
