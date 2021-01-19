
Shader "Unityshadertest/starfog"
{
	Properties{
		_MainTex("_MainTex",2D)=""{}
		_SecondTex("_SecondTex",2D)=""{}
		_F("_F",range(0,10))=0
	}
	SubShader {

		Pass {
			//Tags { "LightMode"="ForwardBase" }
			colormask gb
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			//#include "Lighting.cginc"

			float4 _MainTex_ST;
			sampler2D _MainTex;
			sampler2D _SecondTex;
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
				fixed4 MainColor=tex2D(_MainTex,IN.uv);

				float offset_uv=0.05*sin(IN.uv*_F+_Time.x*2);
				float2 uv=IN.uv+offset_uv;
				uv.y+=0.3;
				fixed4 color_1=tex2D(_SecondTex,uv);
				MainColor.rgb*=color_1.b;
				MainColor.rgb*=2;

				uv=IN.uv-offset_uv;
				fixed4 color_2=tex2D(_SecondTex,uv);
				uv.y+=0.3;
				MainColor.rgb*=color_2.b;
				MainColor.rgb*=2;

				return MainColor;
			}

			ENDCG
		   
		}
	}
}
