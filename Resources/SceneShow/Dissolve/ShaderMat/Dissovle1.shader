// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dissovle1"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_Gradient("Gradient", 2D) = "white" {}
		_Noise("Noise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Vector) = (0,0,0,0)
		[HDR]_ResovleColor("ResovleColor", Color) = (1,0,0,0)
		_EdgeWidth("EdgeWidth", Float) = 0.26
		[HDR]_DissolveOutsideColor("DissolveOutsideColor", Color) = (1,0,0,0)
		_OutSideEdgeWidth("OutSideEdgeWidth", Float) = 0.26
		_Spread("Spread", Range( 0 , 1)) = 0
		_Softness("Softness", Range( 0 , 0.5)) = 0.3582897
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _ResovleColor;
		uniform sampler2D _Gradient;
		SamplerState sampler_Gradient;
		uniform float4 _Gradient_ST;
		uniform float _Spread;
		uniform sampler2D _Noise;
		SamplerState sampler_Noise;
		uniform float2 _NoiseSpeed;
		uniform float _Softness;
		uniform float _EdgeWidth;
		uniform float _OutSideEdgeWidth;
		uniform float4 _DissolveOutsideColor;
		SamplerState sampler_MainTex;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float2 uv_Gradient = i.uv_texcoord * _Gradient_ST.xy + _Gradient_ST.zw;
			float Gradient82 = ( ( ( tex2D( _Gradient, uv_Gradient ).r - (-_Spread + (frac( ( _Time.y * 0.2 ) ) - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread ) * 2.0 );
			float2 panner72 = ( 1.0 * _Time.y * _NoiseSpeed + i.uv_texcoord);
			float noise95 = tex2D( _Noise, panner72 ).r;
			float temp_output_41_0 = distance( ( Gradient82 - noise95 ) , _Softness );
			float clampResult52 = clamp( ( 1.0 - ( temp_output_41_0 / _EdgeWidth ) ) , 0.0 , 1.0 );
			float4 lerpResult50 = lerp( tex2DNode1 , ( _ResovleColor * tex2DNode1 ) , clampResult52);
			float clampResult106 = clamp( ( 1.0 - ( temp_output_41_0 / _OutSideEdgeWidth ) ) , 0.0 , 1.0 );
			float temp_output_110_0 = ( clampResult106 - step( 0.001 , clampResult52 ) );
			float4 lerpResult116 = lerp( lerpResult50 , ( temp_output_110_0 * _DissolveOutsideColor ) , temp_output_110_0);
			o.Emission = lerpResult116.rgb;
			float smoothstepResult92 = smoothstep( _Softness , 0.5 , ( Gradient82 - noise95 ));
			o.Alpha = ( tex2DNode1.a * smoothstepResult92 );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
741;585;2558;1377;3009.427;557.6813;1.202027;True;True
Node;AmplifyShaderEditor.CommentaryNode;61;-2488.653,-89.04785;Inherit;False;1396.732;649.8838;Comment;14;31;3;53;30;86;87;89;90;91;82;102;103;119;120;Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;86;-2467.632,90.75116;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-2451.511,184.5231;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-2444.688,464.9729;Inherit;False;Property;_Spread;Spread;9;0;Create;True;0;0;False;0;False;0;0.247;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-2277.511,101.5231;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;87;-2121.632,147.7512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;90;-2134.688,331.9729;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-2146.515,-46.32854;Inherit;True;Property;_Gradient;Gradient;1;0;Create;True;0;0;False;0;False;-1;ee27ce608ae336a49af208ba200cc434;4226500b09883374a89cabfaf68e760a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;53;-1930.135,286.6987;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;104;-2495.012,-522.6093;Inherit;False;1259.266;378.3628;Comment;5;63;73;72;62;95;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;73;-2443.693,-305.2458;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;3;0;Create;True;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;63;-2445.012,-472.6089;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;31;-1695.571,18.70166;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;91;-1535.691,452.9729;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;72;-2110.692,-455.2461;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-1323.72,430.2917;Inherit;False;Constant;_Float0;Float 0;9;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-1321.72,304.2917;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;62;-1889.929,-429.6548;Inherit;True;Property;_Noise;Noise;2;0;Create;True;0;0;False;0;False;-1;cea807cca851fb44da696ea20abb3fed;cb6fc684c58081647aed6fc6ac5fbedd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;-1429.923,14.19599;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-1478.745,-382.2036;Inherit;False;noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;81;-889.3073,227.207;Inherit;False;1648.226;831.5799;Comment;16;110;83;111;52;106;108;107;105;55;54;42;41;101;100;113;114;EdgeColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;-864.2968,419.7654;Inherit;False;95;noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;-830.4583,277.3657;Inherit;False;82;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;101;-642.1666,354.0771;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-429.9345,-96.28563;Inherit;False;Property;_Softness;Softness;10;0;Create;True;0;0;False;0;False;0.3582897;0.348;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-244.7141,425.8694;Inherit;False;Property;_EdgeWidth;EdgeWidth;6;0;Create;True;0;0;False;0;False;0.26;0.69;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;41;-476.6341,291.2069;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-502.822,676.8447;Inherit;False;Property;_OutSideEdgeWidth;OutSideEdgeWidth;8;0;Create;True;0;0;False;0;False;0.26;1.97;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;54;-175.7457,295.1307;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;42;-56.08188,294.776;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;107;-344.8536,541.1061;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;52;135.9196,293.8832;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;105;-225.1898,540.7513;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;-937.9089,-175.278;Inherit;True;95;noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;43;-335.246,-899.172;Inherit;False;Property;_ResovleColor;ResovleColor;5;1;[HDR];Create;True;0;0;False;0;False;1,0,0,0;63.25359,17.88321,9.272778,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;106;-33.18829,537.8586;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-354.5411,-711.5959;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;False;0;False;-1;84b9b3ff1190e104385e13edc319c5ab;84b9b3ff1190e104385e13edc319c5ab;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;84;-911.2104,-485.8747;Inherit;True;82;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;111;459.2299,298.1942;Inherit;True;2;0;FLOAT;0.001;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;110;400.2299,534.1942;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;29.30792,-830.4802;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;113;306.4749,806.2381;Inherit;False;Property;_DissolveOutsideColor;DissolveOutsideColor;7;1;[HDR];Create;True;0;0;False;0;False;1,0,0,0;0.8818038,0.2994805,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;98;-673.3052,-262.3592;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;588.2426,772.1885;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;50;557.8929,-715.7039;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;92;-129.8343,-155.6856;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2459.703,278.9057;Inherit;False;Property;_ChangeAmount;ChangeAmount;4;0;Create;True;0;0;False;0;False;0.484758;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;95.94032,-379.2779;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;116;860.1757,-715.4852;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1200.82,-398.9296;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Dissovle1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;119;0;86;0
WireConnection;119;1;120;0
WireConnection;87;0;119;0
WireConnection;90;0;89;0
WireConnection;53;0;87;0
WireConnection;53;3;90;0
WireConnection;31;0;3;1
WireConnection;31;1;53;0
WireConnection;91;0;31;0
WireConnection;91;1;89;0
WireConnection;72;0;63;0
WireConnection;72;2;73;0
WireConnection;102;0;91;0
WireConnection;102;1;103;0
WireConnection;62;1;72;0
WireConnection;82;0;102;0
WireConnection;95;0;62;1
WireConnection;101;0;83;0
WireConnection;101;1;100;0
WireConnection;41;0;101;0
WireConnection;41;1;93;0
WireConnection;54;0;41;0
WireConnection;54;1;55;0
WireConnection;42;0;54;0
WireConnection;107;0;41;0
WireConnection;107;1;108;0
WireConnection;52;0;42;0
WireConnection;105;0;107;0
WireConnection;106;0;105;0
WireConnection;111;1;52;0
WireConnection;110;0;106;0
WireConnection;110;1;111;0
WireConnection;60;0;43;0
WireConnection;60;1;1;0
WireConnection;98;0;84;0
WireConnection;98;1;99;0
WireConnection;114;0;110;0
WireConnection;114;1;113;0
WireConnection;50;0;1;0
WireConnection;50;1;60;0
WireConnection;50;2;52;0
WireConnection;92;0;98;0
WireConnection;92;1;93;0
WireConnection;21;0;1;4
WireConnection;21;1;92;0
WireConnection;116;0;50;0
WireConnection;116;1;114;0
WireConnection;116;2;110;0
WireConnection;0;2;116;0
WireConnection;0;9;21;0
ASEEND*/
//CHKSM=9FD35D65E86DA05B915C9CFD145056973AB5BD52