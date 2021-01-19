// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/TestDiffuse"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "LightMode"="ForwardBase"}
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal:NORMAL;
			}; 

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				fixed4 color:COLOR;
			};

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float3 ambient=UNITY_LIGHTMODEL_AMBIENT;
				float3 N=normalize(mul(v.normal,unity_WorldToObject) );//此处博大精深 详细参考冯女神4.7和6.4章节
				float3 L=normalize(_WorldSpaceLightPos0);
				float3 nDotl=saturate(dot(N,L));
				o.color=fixed4(ambient,0)+ fixed4(_LightColor0*nDotl,1);
				float3 wpos=mul(unity_ObjectToWorld,v.vertex).xyz;
				o.color.rgb+=Shade4PointLights(unity_4LightPosX0,unity_4LightPosY0,unity_4LightPosZ0,
					unity_LightColor[0].rgb,unity_LightColor[1].rgb,unity_LightColor[2].rgb,unity_LightColor[3].rgb,
					unity_4LightAtten0,wpos,N);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_TARGET
			{
				
				return i.color;
			}
			ENDCG
		}
	}
}
