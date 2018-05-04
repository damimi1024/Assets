// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unityshadertest/textcoordshader1"
{
	Properties
	{
		_Color("Color",Color  )=(1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_Specular("Specular",Color )=(1,1,1,1)
		_Gloss("Gloss",Range(1,256))=8
		_Diffuse("Diffuse Color",Color )=(1,1,1,1)
		_Bumpmap("NormalMap",2D  )="bump"{}
		_BumpScale("Bumpscale",float)=1
	}
	SubShader
	{
		Pass
		{
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc" 
			float4 _Specular;
			float4 _Diffuse;
			float _Gloss;
			fixed4 _Color;
			sampler2D _Bumpmap;
			sampler2D _MainTex;
			float4 _Bumpmap_ST;
			float4 _MainTex_ST;
			float _BumpScale;
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0; 
				
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2 ; 
			};

			
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.uv.xy=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
				o.uv.zw=v.texcoord.xy*_Bumpmap_ST.xy+_Bumpmap_ST.zw;
				TANGENT_SPACE_ROTATION;
				o.lightDir=mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir=mul(rotation,ObjSpaceViewDir(v.vertex )).xyz;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 tangentlightDir=normalize(i.lightDir);
				fixed3 tangentViewDir=normalize(i.viewDir);
				fixed4 packedNormal=tex2D(_Bumpmap,i.uv.zw);
				fixed3 tangentnormal;
				tangentnormal=UnpackNormal(packedNormal);
				tangentnormal.xy*=_BumpScale;
				tangentnormal.z=sqrt(1-saturate(dot(tangentnormal.xy,tangentnormal.xy)));
				fixed3 albedo=tex2D(_MainTex,i.uv).rgb*_Color.rgb;

				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT .xyz*albedo;
				fixed3 diffuse=_LightColor0*albedo*saturate(dot(tangentnormal,tangentlightDir));
				fixed3 halfdir=normalize(tangentlightDir+tangentViewDir);
				fixed3 specular=_LightColor0*_Specular.rgb*pow(saturate(dot(tangentnormal,halfdir)),_Gloss);
				return fixed4(ambient+diffuse+specular,1.0);
			}
			ENDCG
		}

	}
	FallBack"Specular"
}
