﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/texcoordshader1"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color",Color)=(1,1,1,1)
		_Specular("Specular",Color)=(1,1,1,1)
		_Gloss("Gloss",Range(8,256))=8
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{

			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc" 
			sampler2D _MainTex;
			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;
			float4 _MainTex_ST;
			struct appdata
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0 ; 
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0 ;
				float3 worldPos:TEXCOORD1  ;
				float2 uv:TEXCOORD2 ; 
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.worldNormal=UnityObjectToWorldNormal(v.normal);
				o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
				o.uv=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
				//TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldNormal=normalize(i.worldNormal);
				fixed3 worldLight=normalize(UnityWorldSpaceLightDir(i.worldPos)) ;


				fixed3 albedo=tex2D(_MainTex,i.uv).rgb*_Color .rgb; 
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT .xyz;
				fixed3 diffuse=_LightColor0.rgb*albedo*saturate(dot(worldNormal,worldLight));
				fixed3 reflectDir=normalize(reflect(-worldLight,worldNormal));
				fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 specular=_LightColor0.rgb*albedo*pow(saturate(dot(viewDir,reflectDir)),_Gloss);

				return fixed4(ambient+diffuse+specular,1.0);
			}
			ENDCG
		}
	}
}
