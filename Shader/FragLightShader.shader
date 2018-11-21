// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/FragLightShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Shininess("_Shininess",Range(0,50))=0
		_Diffuse("_Diffuse",float)=2
	}
	SubShader
	{
		Tags{"LightMode"="ForwardBase"}
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include"Lighting.cginc"
			float _Diffuse;
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
				float3 worldNormal:TEXCOORD1;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal=mul(v.normal,(float3x3)unity_WorldToObject);
				//o.worldNormal=UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				//ambient
				float4 col=UNITY_LIGHTMODEL_AMBIENT;
				//diffuse
				float3 Normal=normalize(i.worldNormal);
				float3 Light=normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse=_LightColor0.rgb*saturate(dot(Normal,Light));
				//specular
				float3 reflectDir=normalize(reflect(-Light,Normal));
				float3 viewDir=WorldSpaceViewDir(i.vertex);
				fixed3 specular=_LightColor0.rgb*pow(saturate(dot(viewDir,reflectDir)),4);


				return fixed4(diffuse+col+specular+col,1);
			}
			ENDCG
		}
	}
}
