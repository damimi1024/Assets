// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/XRAYCull"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "Queue"="Geometry" "RenderType"="Opaque" }
		//LOD 100

		Pass
		{
			Blend SrcAlpha One
			Zwrite Off
			Ztest Greater

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#include "UnityCG.cginc"

	
			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex=UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(1,1,1,0.5);
			}
			ENDCG
		}

		Pass
		{
			ZWrite Off
			CGPROGRAM
			#include "Lighting.cginc"
			sampler2D _MainTex;
			float4 _MainTex_ST;
 
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD1;
			};
 
			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
 
			fixed4 frag(v2f i) : SV_Target
			{
				return tex2D(_MainTex, i.uv);
			}
 
			#pragma vertex vert
			#pragma fragment frag	
			ENDCG
		}
	}
}
