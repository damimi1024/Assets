// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "realDiamond"
{
	Properties
	{
		_RefractTex("RefractTex", CUBE) = "white" {}
		_ReflectTex("ReflectTex", CUBE) = "white" {}
		[HDR]_Color0("Color 0", Color) = (0,0,0,0)
		_RefractIntensity("RefractIntensity", Float) = 0
		_ReflectStrength("ReflectStrength", Float) = 1
		_RimBias("RimBias", Float) = 0
		_RimScale("RimScale", Float) = 0
		_RimPower("RimPower", Float) = 0
		[HDR]_RimColor("RimColor", Color) = (0,0,0,0)

	}

	SubShader
	{
		

		Tags { "RenderType"="Opaque" "Queue"="Geometry" }
	LOD 100


		
		Pass
		{
			Name "Pass1"
			Blend One Zero
			Cull Front
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
		//only defining to not throw compilation error over Unity 5.5
		#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
		#endif
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile_instancing
		#include "UnityCG.cginc"
		#define ASE_NEEDS_FRAG_WORLD_POSITION


		struct appdata
		{
			float4 vertex : POSITION;
			float4 color : COLOR;
			float3 ase_normal : NORMAL;
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		struct v2f
		{
			float4 vertex : SV_POSITION;
			#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
			float3 worldPos : TEXCOORD0;
			#endif
			float4 ase_texcoord1 : TEXCOORD1;
			UNITY_VERTEX_INPUT_INSTANCE_ID
			UNITY_VERTEX_OUTPUT_STEREO
		};

		uniform float4 _Color0;
		uniform samplerCUBE _RefractTex;
		uniform samplerCUBE _ReflectTex;
		uniform float _RefractIntensity;


		v2f vert(appdata v )
		{
			v2f o;
			UNITY_SETUP_INSTANCE_ID(v);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
			UNITY_TRANSFER_INSTANCE_ID(v, o);

			float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
			o.ase_texcoord1.xyz = ase_worldNormal;
			
			
			//setting value to unused interpolator channels and avoid initialization warnings
			o.ase_texcoord1.w = 0;
			float3 vertexValue = float3(0, 0, 0);
			#if ASE_ABSOLUTE_VERTEX_POS
			vertexValue = v.vertex.xyz;
			#endif
			vertexValue = vertexValue;
			#if ASE_ABSOLUTE_VERTEX_POS
			v.vertex.xyz = vertexValue;
			#else
			v.vertex.xyz += vertexValue;
			#endif
			o.vertex = UnityObjectToClipPos(v.vertex);

			#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
			o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			#endif
			return o;
		}

		fixed4 frag(v2f i ) : SV_Target
		{
			UNITY_SETUP_INSTANCE_ID(i);
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
			fixed4 finalColor;
			#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
			float3 WorldPosition = i.worldPos;
			#endif
			float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
			ase_worldViewDir = normalize(ase_worldViewDir);
			float3 ase_worldNormal = i.ase_texcoord1.xyz;
			float3 temp_output_5_0 = reflect( -ase_worldViewDir , ase_worldNormal );
			float4 texCUBENode3 = texCUBE( _ReflectTex, temp_output_5_0 );
			float4 temp_output_13_0 = ( _Color0 * texCUBE( _RefractTex, temp_output_5_0 ) * texCUBENode3 * _RefractIntensity );
			

			finalColor = temp_output_13_0;
			return finalColor;
		}
		ENDCG
	}
		
		Pass
		{
			Name "Pass2"
			Cull Back
			Blend One One
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
					//only defining to not throw compilation error over Unity 5.5
					#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
					#endif
					#pragma vertex vert
					#pragma fragment frag
					#pragma multi_compile_instancing
					#include "UnityCG.cginc"
					#define ASE_NEEDS_FRAG_WORLD_POSITION


					struct appdata
					{
						float4 vertex : POSITION;
						float4 color : COLOR;
						float3 ase_normal : NORMAL;
						UNITY_VERTEX_INPUT_INSTANCE_ID
					};

					struct v2f
					{
						float4 vertex : SV_POSITION;
						#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
						float3 worldPos : TEXCOORD0;
						#endif
						float4 ase_texcoord1 : TEXCOORD1;
						UNITY_VERTEX_INPUT_INSTANCE_ID
						UNITY_VERTEX_OUTPUT_STEREO
					};

					uniform float4 _Color0;
					uniform samplerCUBE _RefractTex;
					uniform samplerCUBE _ReflectTex;
					uniform float _RefractIntensity;
					uniform float _ReflectStrength;
					uniform float _RimBias;
					uniform float _RimScale;
					uniform float _RimPower;
					uniform float4 _RimColor;


					v2f vert(appdata v )
					{
						v2f o;
						UNITY_SETUP_INSTANCE_ID(v);
						UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
						UNITY_TRANSFER_INSTANCE_ID(v, o);

						float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
						o.ase_texcoord1.xyz = ase_worldNormal;
						
						
						//setting value to unused interpolator channels and avoid initialization warnings
						o.ase_texcoord1.w = 0;
						float3 vertexValue = float3(0, 0, 0);
						#if ASE_ABSOLUTE_VERTEX_POS
						vertexValue = v.vertex.xyz;
						#endif
						vertexValue = vertexValue;
						#if ASE_ABSOLUTE_VERTEX_POS
						v.vertex.xyz = vertexValue;
						#else
						v.vertex.xyz += vertexValue;
						#endif
						o.vertex = UnityObjectToClipPos(v.vertex);

						#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
						o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
						#endif
						return o;
					}

					fixed4 frag(v2f i ) : SV_Target
					{
						UNITY_SETUP_INSTANCE_ID(i);
						UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
						fixed4 finalColor;
						#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
						float3 WorldPosition = i.worldPos;
						#endif
						float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
						ase_worldViewDir = normalize(ase_worldViewDir);
						float3 ase_worldNormal = i.ase_texcoord1.xyz;
						float3 temp_output_5_0 = reflect( -ase_worldViewDir , ase_worldNormal );
						float4 texCUBENode3 = texCUBE( _ReflectTex, temp_output_5_0 );
						float4 temp_output_13_0 = ( _Color0 * texCUBE( _RefractTex, temp_output_5_0 ) * texCUBENode3 * _RefractIntensity );
						float fresnelNdotV25 = dot( ase_worldNormal, ase_worldViewDir );
						float fresnelNode25 = ( _RimBias + _RimScale * pow( 1.0 - fresnelNdotV25, _RimPower ) );
						

						finalColor = ( ( temp_output_13_0 + ( texCUBENode3 * _ReflectStrength * ( fresnelNode25 * _RimColor ) ) ) + float4( 0,0,0,0 ) );
						return finalColor;
					}
					ENDCG
				}
		
	}
		CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18500
442;271;1906;1005;1780.433;668.5884;1.3;True;True
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;6;-1676.128,-329.8468;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;8;-1430.747,-298.9986;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;9;-1516.279,-132.139;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;19;-1235.232,541.7817;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;18;-1237.232,384.7817;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;28;-1008.142,947.1979;Inherit;False;Property;_RimPower;RimPower;7;0;Create;True;0;0;False;0;False;0;6.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1072.142,817.1979;Inherit;False;Property;_RimScale;RimScale;6;0;Create;True;0;0;False;0;False;0;0.53;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1057.142,669.1979;Inherit;False;Property;_RimBias;RimBias;5;0;Create;True;0;0;False;0;False;0;0.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;25;-825.7483,416.3391;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;34;-756.3321,659.0062;Inherit;False;Property;_RimColor;RimColor;8;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;2.719234,2.719234,2.719234,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ReflectOpNode;5;-1109.646,-244.3136;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-512.7462,-151.5577;Inherit;False;Property;_RefractIntensity;RefractIntensity;3;0;Create;True;0;0;False;0;False;0;0.41;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-498.2334,386.3954;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-807.7462,174.4423;Inherit;False;Property;_ReflectStrength;ReflectStrength;4;0;Create;True;0;0;False;0;False;1;1.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-865.6671,-399.9557;Inherit;True;Property;_RefractTex;RefractTex;0;0;Create;True;0;0;False;0;False;-1;None;b9aba6a9f85d1cf478ead1fa473f354b;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-853.0474,-112.5085;Inherit;True;Property;_ReflectTex;ReflectTex;1;0;Create;True;0;0;False;0;False;-1;None;2dbc8567c5db25547b8fcc6e7ed41511;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;12;-756.1896,-594.9;Inherit;False;Property;_Color0;Color 0;2;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;2.84697,4.822486,6.883182,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-375.1896,-413.9;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-420.7462,162.4423;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-219.7462,75.44226;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;51.06335,144.734;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-58,-356;Float;False;True;-1;2;ASEMaterialInspector;100;11;realDiamond;341d204219bc70646ae1e51b5d9aae9e;True;Pass1;0;0;Pass1;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;2;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;159,67;Float;False;False;-1;2;ASEMaterialInspector;100;11;New Amplify Shader;341d204219bc70646ae1e51b5d9aae9e;True;Pass2;0;1;Pass2;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;0;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;0;False;0
WireConnection;8;0;6;0
WireConnection;25;0;18;0
WireConnection;25;4;19;0
WireConnection;25;1;26;0
WireConnection;25;2;27;0
WireConnection;25;3;28;0
WireConnection;5;0;8;0
WireConnection;5;1;9;0
WireConnection;35;0;25;0
WireConnection;35;1;34;0
WireConnection;2;1;5;0
WireConnection;3;1;5;0
WireConnection;13;0;12;0
WireConnection;13;1;2;0
WireConnection;13;2;3;0
WireConnection;13;3;14;0
WireConnection;16;0;3;0
WireConnection;16;1;17;0
WireConnection;16;2;35;0
WireConnection;15;0;13;0
WireConnection;15;1;16;0
WireConnection;30;0;15;0
WireConnection;0;0;13;0
WireConnection;1;0;30;0
ASEEND*/
//CHKSM=3D3B6CC63380B1616F883F5229465E40B79542B4