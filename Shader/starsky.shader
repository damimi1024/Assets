﻿// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable

// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D


// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unityshadertest/starsky"
{
	Properties{
		_MainTex("_MainTex",2D)=""{}

		_F("_F",range(0,10))=0
	}
	SubShader {

		Pass {
			//Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			//#include "Lighting.cginc"

			float4 _MainTex_ST;
			sampler2D _MainTex;
			float _F;
			struct v2f{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			} ;

			v2f vert(appdata_full v){
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				//o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uv=v.texcoord1.xy;//*unity_LightmapST.xy+unity_LightmapST.zw;
				return o;
			}

			fixed4 frag(v2f IN):COLOR{
				float2 uv=IN.uv;
				float offset=sin(uv*_F+_Time.x*2)*0.05;
				uv+=offset;
				fixed4 color_1=tex2D(_MainTex,uv);
				uv=IN.uv;
				uv-=offset*2;
				fixed4 color_2=tex2D(_MainTex,uv);
			
				return (color_1+color_2)/2;
			}

			ENDCG
		   
		}
	}
}
