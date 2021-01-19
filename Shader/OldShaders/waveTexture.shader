
Shader "Unityshadertest/waveTexture"
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


			sampler2D _MainTex;
			sampler2D _WaveTex;
			 // sampler2D unity_Lightmap;

			struct v2f{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			} ;

			v2f vert(appdata_full v){
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.uv=v.texcoord.xy;
				return o;
			}

			fixed4 frag(v2f IN):COLOR{
				float2 uv=tex2D(_WaveTex,IN.uv).xy;
				uv=uv*2-1;
				uv*=0.03;

				IN.uv+=uv;

				fixed4 color=tex2D(_MainTex,IN.uv) ;
				return color;
			}

			ENDCG
		   
		}
	}
}
