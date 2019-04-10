// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable

// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D


// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unityshadertest/vertCommon"
{
	Properties{
		_MainTex("_MainTex",2D)=""{}


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
			 // float4 unity_LightmapST;
			sampler2D _MainTex;
			 // sampler2D unity_Lightmap;

			struct v2f{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
				float2 uv2:TEXCOORD1;
			} ;

			v2f vert(appdata_full v){
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uv2=v.texcoord1.xy*unity_LightmapST.xy+unity_LightmapST.zw;
				return o;
			}

			fixed4 frag(v2f IN):COLOR{
				//c light *c diffuse max(0,normal*l 指向光源的单位矢量)
				float3 lm=DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap,IN.uv2));
				fixed4 color=tex2D(_MainTex,IN.uv);
				color.rgb*=lm*2;
				return color;
			}

			ENDCG
		   
		}
	}
}
