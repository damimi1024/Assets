Shader "Custom/carPaint_surface" {
	Properties {
		_MainColor("MainColor",color)=(1,1,1,1)
		_SecondColor("SecondColor",color)=(1,1,1,1)
		_R("R",Range(0,0.5))=0.2
		_Center("Center",Range(-2.7,2.7))=0
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard vertex:vert fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;
		float4 _MainColor;
		float4 _SecondColor;
		float _R;
		float _Center;
		half _Glossiness;
		half _Metallic;


		struct Input {
			float2 uv_MainTex;
			float x;
		};
		void vert(inout appdata_full v,out Input o){
			o.uv_MainTex=v.texcoord.xy;
			o.x=v.vertex.x;
		}

		UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;

			float d=IN.x-_Center;
			float s=abs(d);
			d=d/s;
			float f=s/_R;
			f=saturate(f);
			d*=f;
			d=d/2+0.5;
			o.Albedo*=lerp(_MainColor,_SecondColor,d)*2;

		}
		ENDCG
	}
	FallBack "Diffuse"
}
