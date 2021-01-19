// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'



Shader "Unlit/shadertest1"
{
	Properties{
		_SonarBaseColor("Base Color",Color  )=(0.1,0.1,0.1,0)
		_SonarWaveColor("Wave Color",Color  )=(0.1,0.1,0.1,0)
		_SonarWaveParams("Wave Params",Vector  )=(1,20,20,10)
		_SonarWaveVector("Wave Vector",Vector  )=(0,0,1,0)
		_SonarAddColor("Add Color",Color  )=(0,0,0,0)

	}
	SubShader
	{
		Tags { "LightMode"="ForwardBase" }
		Pass
		{
			CGPROGRAM
			#pragma vertex  vert
			#pragma fragment frag
			#pragma multi_compile SONAR_DIRECTIONAL SONAR_SPERICAL

			#include "UnityCG.cginc" 

			struct vertexInput{

				float4 vertex:POSITION ;
				float3 normal:NORMAL;
			} ;

			struct vertexOutput
			{
				float4 pos:SV_POSITION;
				float4 col:COLOR;
			} ;

			float3 _SonarBaseColor;
			float3 _SonarWaveColor;
			float4 _SonarWaveParams;
			float3 _SonarWaveVector;
			float3 _SonarAddColor;
			uniform float4 _LightColor0;

			

			vertexOutput vert(vertexInput input){

				vertexOutput output;
				float4x4 modelMatrix=unity_ObjectToWorld ; 
				float4x4 modelMatrixInverse=unity_WorldToObject;

				float3 normalDirection=normalize(mul(float4(input.normal,0),modelMatrixInverse).xyz);
				float3 lightDirection=normalize(_WorldSpaceLightPos0.xyz);
				float3 diffuseReflection=_LightColor0.rgb*max(0,dot(normalDirection,lightDirection));

				output.col=float4 (diffuseReflection,1);
				output.pos=UnityObjectToClipPos(input.vertex );


				#ifdef SONAR_DIRECTIONAL
				float w=dot(output.pos.xyz,_SonarWaveVector);
				#else
				float w=length(output.pos.xyz-_SonarWaveVector);
				#endif

				w-=_Time.y*_SonarWaveParams.w;
				w/=_SonarWaveParams.z;
				w=w-floor(w);

				float p=_SonarWaveParams.y;
				w=(pow(w,p)+pow(1-w,p*4))*0.5;

				w*=_SonarWaveParams;

				fixed3 col=_SonarWaveColor*w+_SonarAddColor;
				output.col+=float4(col,1);

				return output;


			}

			float4 frag(vertexOutput input) : COLOR
			{

				return input.col;
			}
			ENDCG
		}
	}
}
