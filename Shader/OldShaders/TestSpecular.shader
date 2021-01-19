// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/TestSpecular"
{
	Properties
	{
		_SpecularColor("_specular",color)=(1,1,1,1)
		_Shininess("_Shininess",float)=0
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
			float4 _SpecularColor;
			float _Shininess;
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
				float3 I=WorldSpaceLightDir(v.vertex);
				float3 R=reflect(I,N);
				float3 V=WorldSpaceViewDir(v.vertex);
				R=normalize(R);
				V=normalize(V);
				float SpecularScale=pow( saturate(dot(R,V)),_Shininess);
				o.color.rgb+=_LightColor0*SpecularScale;
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
