Shader "Unlit/ZWriteTest"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_COlOR("COLOR",Color)=(0,0,0,0)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		Tags {"Queue"="Transparent-1"}
		//ZWrite Off
		//ZTest GEqual
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _COlOR;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex:POSITION;
			};

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _COlOR;
			}
			ENDCG
		}
	}
}
