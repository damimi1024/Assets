// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "scan"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_FlowTex("FlowTex", 2D) = "white" {}
		_MainColor("MainColor", Color) = (0,0,0,0)
		_rimcolor("rimcolor", Color) = (0,0,0,0)
		_speed("speed", Vector) = (0,0,0,0)
		_rate("rate", Vector) = (0,0,0,0)
		_rimmin("rimmin", Range( -1 , 1)) = 0
		_rimmax("rimmax", Range( 0 , 2)) = 0
		_rimstrength("rimstrength", Float) = 0
		_FlowInensity("FlowInensity", Float) = 0.5
		_TexPower("TexPower", Float) = 1
		_inneralpha("inneralpha", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha One
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 viewDir;
			float3 worldPos;
		};

		uniform float4 _MainColor;
		uniform float4 _rimcolor;
		uniform float _rimstrength;
		uniform sampler2D _MainTex;
		SamplerState sampler_MainTex;
		uniform float4 _MainTex_ST;
		uniform float _TexPower;
		uniform float _rimmin;
		uniform float _rimmax;
		uniform sampler2D _FlowTex;
		uniform float2 _rate;
		uniform float2 _speed;
		uniform float _FlowInensity;
		SamplerState sampler_FlowTex;
		uniform float _inneralpha;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float3 ase_worldNormal = i.worldNormal;
			float dotResult27 = dot( ase_worldNormal , i.viewDir );
			float clampResult32 = clamp( dotResult27 , 0.0 , 1.0 );
			float smoothstepResult29 = smoothstep( _rimmin , _rimmax , ( 1.0 - clampResult32 ));
			float clampResult75 = clamp( ( pow( tex2D( _MainTex, uv_MainTex ).r , _TexPower ) + smoothstepResult29 ) , 0.0 , 1.0 );
			float4 lerpResult40 = lerp( _MainColor , ( _rimcolor * _rimstrength ) , clampResult75);
			float4 finalRimColor88 = lerpResult40;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult55 = (float2(ase_worldPos.x , ase_worldPos.y));
			float3 objToWorld62 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 appendResult63 = (float2(objToWorld62.x , objToWorld62.y));
			float4 tex2DNode42 = tex2D( _FlowTex, ( ( _rate * ( appendResult55 - appendResult63 ) ) + ( _speed * _Time.y ) ) );
			float4 flowres83 = ( tex2DNode42 * _FlowInensity );
			o.Emission = ( finalRimColor88 + flowres83 ).rgb;
			float finalRimAlpha90 = clampResult75;
			float flowalpha85 = ( _FlowInensity * tex2DNode42.a );
			o.Alpha = ( finalRimAlpha90 + flowalpha85 + _inneralpha );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows exclude_path:deferred 

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
				float3 worldNormal : TEXCOORD3;
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
				o.worldNormal = worldNormal;
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
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
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
1;1;1844;1051;165.0882;231.7849;1.428955;True;True
Node;AmplifyShaderEditor.CommentaryNode;92;-845.4843,-622.0267;Inherit;False;1940.904;1030.472;Comment;20;31;26;39;36;33;35;75;32;30;70;71;73;27;28;76;25;29;40;90;88;边缘光;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;87;-797.3752,512.9933;Inherit;False;1893.505;771.1835;Comment;17;62;53;63;64;60;59;55;46;80;81;42;47;69;67;68;83;85;流光;0.9811321,0.6988252,0.6988252,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;26;-787.3359,224.4449;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;25;-795.4843,15.50092;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;53;-743.0794,648.6172;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;62;-747.3752,847.7735;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;27;-550.7795,47.10558;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;32;-359.2134,46.23815;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;63;-480.3753,843.7734;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;55;-474.0797,679.6172;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;59;-745.3454,1174.177;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;28;-160.9556,43.08503;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;70;-584.7265,-334.1766;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;False;-1;None;be8f19aec22965b418fd04de4f9f5f25;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;80;-329.7314,562.9933;Inherit;False;Property;_rate;rate;6;0;Create;True;0;0;False;0;False;0,0;2,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;30;-219.9555,160.7605;Inherit;False;Property;_rimmin;rimmin;7;0;Create;True;0;0;False;0;False;0;0.13;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;64;-322.3753,766.7733;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;60;-744.3454,1021.876;Inherit;False;Property;_speed;speed;5;0;Create;True;0;0;False;0;False;0,0;0,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;31;-224.2524,261.1926;Inherit;False;Property;_rimmax;rimmax;8;0;Create;True;0;0;False;0;False;0;1.35;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-472.7266,-30.17675;Inherit;False;Property;_TexPower;TexPower;11;0;Create;True;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;73;-149.7975,-145.4919;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-162.0315,662.1927;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-480.6224,1025.595;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;29;139.0443,15.76038;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-13.95176,788.1913;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;33;143.1979,-371.532;Inherit;False;Property;_rimcolor;rimcolor;4;0;Create;True;0;0;False;0;False;0,0,0,0;0.09803921,0.2604075,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;35;168.1979,-179.532;Inherit;False;Property;_rimstrength;rimstrength;9;0;Create;True;0;0;False;0;False;0;2.74;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;312.6494,-59.48745;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;448.0043,-277.3242;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;39;117.4974,-572.0267;Inherit;False;Property;_MainColor;MainColor;3;0;Create;True;0;0;False;0;False;0,0,0,0;0.454902,0.5876901,0.9529412,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;68;422.7125,823.0844;Inherit;False;Property;_FlowInensity;FlowInensity;10;0;Create;True;0;0;False;0;False;0.5;0.98;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;42;110.6665,763.014;Inherit;True;Property;_FlowTex;FlowTex;2;0;Create;True;0;0;False;0;False;-1;None;80811b8d3bc834e4d854f2eabfac7165;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;75;486.7351,-60.18126;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;615.613,904.0841;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;40;663.6957,-463.7452;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;603.4067,711.5372;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;83;836.2252,735.7318;Inherit;False;flowres;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;853.1299,893.9031;Inherit;False;flowalpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;852.4197,-278.5584;Inherit;False;finalRimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;798.4811,-73.74609;Inherit;False;finalRimAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;1321.678,341.8885;Inherit;False;90;finalRimAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;1297.15,-3.747988;Inherit;False;88;finalRimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;1316.58,476.9963;Inherit;False;85;flowalpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;84;1309.564,197.8225;Inherit;False;83;flowres;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;97;1338.173,591.2933;Inherit;False;Property;_inneralpha;inneralpha;12;0;Create;True;0;0;False;0;False;0;0.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;1603.997,27.68094;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;1634.291,236.567;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;93;446.4606,174.1524;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1806.736,-14.59551;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;scan;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;0;Custom;0.5;True;True;0;True;Custom;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;8;5;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;27;0;25;0
WireConnection;27;1;26;0
WireConnection;32;0;27;0
WireConnection;63;0;62;1
WireConnection;63;1;62;2
WireConnection;55;0;53;1
WireConnection;55;1;53;2
WireConnection;28;0;32;0
WireConnection;64;0;55;0
WireConnection;64;1;63;0
WireConnection;73;0;70;1
WireConnection;73;1;71;0
WireConnection;81;0;80;0
WireConnection;81;1;64;0
WireConnection;46;0;60;0
WireConnection;46;1;59;0
WireConnection;29;0;28;0
WireConnection;29;1;30;0
WireConnection;29;2;31;0
WireConnection;47;0;81;0
WireConnection;47;1;46;0
WireConnection;76;0;73;0
WireConnection;76;1;29;0
WireConnection;36;0;33;0
WireConnection;36;1;35;0
WireConnection;42;1;47;0
WireConnection;75;0;76;0
WireConnection;69;0;68;0
WireConnection;69;1;42;4
WireConnection;40;0;39;0
WireConnection;40;1;36;0
WireConnection;40;2;75;0
WireConnection;67;0;42;0
WireConnection;67;1;68;0
WireConnection;83;0;67;0
WireConnection;85;0;69;0
WireConnection;88;0;40;0
WireConnection;90;0;75;0
WireConnection;65;0;89;0
WireConnection;65;1;84;0
WireConnection;66;0;91;0
WireConnection;66;1;86;0
WireConnection;66;2;97;0
WireConnection;0;2;65;0
WireConnection;0;9;66;0
ASEEND*/
//CHKSM=DD78E14BD5D095A45DCE182E66FAC1984C625462