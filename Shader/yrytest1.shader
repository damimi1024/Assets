
Shader "Unityshadertest/vertCommon"
{
	Properties{
		_MainTex("_MainTex",2D)=""{}
		_T("_T",Range(0,30))=10
		_F("_F",Range(0,0.1))=0.01
		_R("_R",range(0,1))=0
		_UVX("_UVX",range(0,1))=0
		_UVY("_UVY",range(0,1))=0

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
			float _T;
			float _F;
			float _R;
			float _UVX;
			float _UVY;
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
				//o.uv2=v.texcoord1.xy*unity_LightmapST.xy+unity_LightmapST.zw;
				return o;
			}

			fixed4 frag(v2f IN):COLOR{
				float2 uv=IN.uv;
				float dis=distance(uv,float2(_UVX,_UVY));
				float scale=0;
				//if(dis<_R)
				//{
				_F*=saturate(1-dis/_R); 
				scale=_F*sin(-dis*3.14*_T+_Time.y);
				uv+=uv*scale;

				//}

				//IN.uv+=_F*sin(IN.uv*3.14*_T+_Time.y);
				fixed4 color=tex2D(_MainTex,uv)+fixed4(1,1,1,1)*20*saturate(scale) ;
				return color;
			}

			ENDCG
		   
		}
	}
}
