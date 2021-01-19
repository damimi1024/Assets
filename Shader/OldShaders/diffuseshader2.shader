
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unityshadertest/diffuseshader2"
{
	Properties{
		_Diffuse("Diffuse",Color)=(1,1,1,1)

	}
	SubShader {

		Pass {
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Diffuse;

			struct appdata{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			} ;
			struct v2f{
				float4 pos:SV_POSITION;
				float3 worldnormal:TEXCOORD0;
			} ;

			v2f vert(appdata v){
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.worldnormal=mul(v.normal,(float3x3)unity_WorldToObject);
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				//c light *c diffuse max(0,normal*l 指向光源的单位矢量)
				
				float3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
				float3 worldlight=normalize(_WorldSpaceLightPos0.xyz);
				float3 worldNormal=normalize(i.worldnormal);
				float3 diffuse_color=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldlight));
				float3 color;
			
				color=ambient+diffuse_color;
				return fixed4(color,1.0);
			}

			ENDCG
		   
		}
	}
}
