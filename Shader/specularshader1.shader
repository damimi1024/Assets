// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/specularshader1"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Specular("Specular",Color )=(1,1,1,1)
		_Gloss("Gloss",Range(1,256))=8
		_Diffuse("Diffuse Color",Color )=(1,1,1,1)
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc" 
			float4 _Specular;
			float4 _Diffuse;
			float _Gloss;
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal:NORMAL;
				
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 color:COLOR;
			
			};

			
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal=normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				fixed3 worldlight=normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldlight));
				fixed3 reflectDir=normalize(reflect(-worldlight,worldNormal));
				fixed3 viewDir=normalize(_WorldSpaceCameraPos.xyz-mul(unity_ObjectToWorld,v.vertex ).xyz);
				fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(saturate( dot(reflectDir,viewDir)),_Gloss);
				
				o.color.rgb=ambient+diffuse+specular;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(i.color, 1.0);
			}
			ENDCG
		}

	}
	FallBack"Specular"
}
