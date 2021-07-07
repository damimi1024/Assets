// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BurnFlag"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_VAT_POS("VAT_POS", 2D) = "white" {}
		_Noise("Noise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Vector) = (0,0,0,0)
		_VAT_NORMAL("VAT_NORMAL", 2D) = "white" {}
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.484758
		_FrameCount("FrameCount", Float) = 0
		[HDR]_ResovleColor("ResovleColor", Color) = (1,0,0,0)
		_EdgeWidth("EdgeWidth", Float) = 0.26
		_Speed("Speed", Float) = 0
		[HDR]_DissolveOutsideColor("DissolveOutsideColor", Color) = (1,0,0,0)
		_OutSideEdgeWidth("OutSideEdgeWidth", Float) = 0.26
		_Height("Height", Float) = 3.5
		_Spread("Spread", Range( 0 , 1)) = 0
		_BoudingMin("BoudingMin", Float) = 0
		_BoudingMax("BoudingMax", Float) = 0
		_Softness("Softness", Range( 0 , 0.5)) = 0.3582897
		[Toggle(_BOTTOMCENTER2_ON)] _BOTTOMCENTER2("模型中心点位于底部", Float) = 0
		_WindIntensity("WindIntensity", Range( 0.5 , 2)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _BOTTOMCENTER2_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform sampler2D _VAT_POS;
		uniform float _Speed;
		uniform float _FrameCount;
		uniform float _BoudingMax;
		uniform float _BoudingMin;
		uniform float _WindIntensity;
		uniform sampler2D _VAT_NORMAL;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _ResovleColor;
		uniform float _Height;
		uniform float _ChangeAmount;
		uniform float _Spread;
		uniform sampler2D _Noise;
		SamplerState sampler_Noise;
		uniform float2 _NoiseSpeed;
		uniform float4 _Noise_ST;
		uniform float _Softness;
		uniform float _EdgeWidth;
		uniform float _OutSideEdgeWidth;
		uniform float4 _DissolveOutsideColor;
		uniform float _Metallic;
		SamplerState sampler_MainTex;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float CurrentFrame16 = ( ( -ceil( ( frac( ( _Time.y * _Speed ) ) * _FrameCount ) ) / _FrameCount ) + ( -1.0 / _FrameCount ) );
			float2 appendResult19 = (float2(v.texcoord1.xy.x , CurrentFrame16));
			float2 UV_VAT20 = appendResult19;
			float3 appendResult31 = (float3(-( ( (tex2Dlod( _VAT_POS, float4( UV_VAT20, 0, 0.0) )).rgb * ( _BoudingMax - _BoudingMin ) ) + _BoudingMin ).x , 0.0 , 0.0));
			float3 VAT_VertexOffset32 = appendResult31;
			v.vertex.xyz += ( VAT_VertexOffset32 * _WindIntensity );
			v.vertex.w = 1;
			float3 break36 = ((tex2Dlod( _VAT_NORMAL, float4( UV_VAT20, 0, 0.0) )).rgb*-1.0 + 1.0);
			float3 appendResult39 = (float3(-break36.x , break36.z , break36.y));
			float3 VAT_VertexNormal35 = appendResult39;
			float3 ase_vertexNormal = v.normal.xyz;
			float clampResult203 = clamp( _WindIntensity , 0.0 , 1.0 );
			float3 lerpResult200 = lerp( VAT_VertexNormal35 , ase_vertexNormal , clampResult203);
			v.normal = lerpResult200;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode184 = tex2D( _MainTex, uv_MainTex );
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld144 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			#ifdef _BOTTOMCENTER2_ON
				float staticSwitch145 = 0.0;
			#else
				float staticSwitch145 = ( _Height / 2.0 );
			#endif
			float Gradient168 = ( ( ( ( ( ( ase_worldPos.y - objToWorld144.y ) + staticSwitch145 ) / _Height ) - (-_Spread + (_ChangeAmount - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread ) * 2.0 );
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner164 = ( 1.0 * _Time.y * _NoiseSpeed + uv_Noise);
			float noise169 = tex2D( _Noise, panner164 ).r;
			float temp_output_175_0 = distance( ( Gradient168 - noise169 ) , _Softness );
			float clampResult180 = clamp( ( 1.0 - ( temp_output_175_0 / _EdgeWidth ) ) , 0.0 , 1.0 );
			float4 lerpResult193 = lerp( tex2DNode184 , ( _ResovleColor * tex2DNode184 ) , clampResult180);
			float clampResult187 = clamp( ( 1.0 - ( temp_output_175_0 / _OutSideEdgeWidth ) ) , 0.0 , 1.0 );
			float temp_output_191_0 = ( clampResult187 - step( 0.001 , clampResult180 ) );
			float4 lerpResult197 = lerp( lerpResult193 , ( temp_output_191_0 * _DissolveOutsideColor ) , temp_output_191_0);
			float4 Emission137 = lerpResult197;
			o.Emission = Emission137.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = 0.0;
			o.Alpha = 1;
			float smoothstepResult194 = smoothstep( _Softness , 0.5 , ( Gradient168 - noise169 ));
			float Opacity136 = ( tex2DNode184.a * smoothstepResult194 );
			clip( Opacity136 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
95;254;1548;868;3339.368;3577.127;2.379754;True;False
Node;AmplifyShaderEditor.CommentaryNode;4;-4571.05,-297.0605;Inherit;False;2200.86;1190.064;VAT;35;39;38;37;36;35;34;33;32;31;30;29;28;27;26;25;24;23;22;21;20;19;18;17;16;15;14;13;12;11;10;9;8;7;6;5;VAT;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-4521.05,-110.553;Inherit;False;Property;_Speed;Speed;12;0;Create;True;0;0;False;0;False;0;0.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;6;-4496.776,-247.0605;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-4316.95,-234.0525;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;9;-4168.215,-234.943;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-4944.925,-1750.01;Inherit;False;Property;_Height;Height;15;0;Create;True;0;0;False;0;False;3.5;11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-4211.594,-71.59641;Inherit;False;Property;_FrameCount;FrameCount;9;0;Create;True;0;0;False;0;False;0;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-3974.975,-242.1605;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;141;-4970.485,-2111.979;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;149;-4159.242,-2520.321;Inherit;False;1396.732;649.8838;Comment;14;196;168;166;165;163;162;159;158;157;156;155;154;153;152;Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;142;-4688.151,-1744.101;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-4951.151,-1658.101;Inherit;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;144;-4984.485,-1944.979;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;145;-4524.151,-1675.101;Inherit;False;Property;_BOTTOMCENTER2;模型中心点位于底部;20;0;Create;False;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CeilOpNode;11;-3818.975,-224.1605;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;154;-4115.277,-1966.301;Inherit;False;Property;_Spread;Spread;16;0;Create;True;0;0;False;0;False;0;0.474;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;146;-4700.485,-2095.979;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;196;-4209.592,-2154.968;Inherit;False;Property;_ChangeAmount;ChangeAmount;8;0;Create;True;0;0;False;0;False;0.484758;0.567;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;12;-3700.075,-215.7332;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;156;-3805.277,-2099.301;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;147;-4475.151,-2077.101;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;159;-3600.724,-2144.575;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;150;-4165.602,-2953.883;Inherit;False;1259.266;378.3628;Comment;5;169;167;164;161;160;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;148;-4340.925,-2050.01;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;14;-3546.565,-217.6811;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;13;-3566.652,-80.70249;Inherit;False;2;0;FLOAT;-1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;160;-4114.282,-2736.519;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;6;0;Create;True;0;0;False;0;False;0,0;0,-0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;162;-3366.16,-2412.572;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;161;-4115.602,-2903.882;Inherit;False;0;167;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-3367.653,-161.7024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-3228.165,-162.5812;Inherit;False;CurrentFrame;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;165;-2994.309,-2000.982;Inherit;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;164;-3781.281,-2886.52;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;163;-3206.28,-1978.301;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;167;-3560.518,-2860.928;Inherit;True;Property;_Noise;Noise;5;0;Create;True;0;0;False;0;False;-1;cea807cca851fb44da696ea20abb3fed;cea807cca851fb44da696ea20abb3fed;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;17;-4474.814,75.22918;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;18;-4462.814,215.229;Inherit;False;16;CurrentFrame;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;166;-2992.309,-2126.982;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;19;-4122.813,95.90749;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;151;-2559.897,-2204.066;Inherit;False;1648.226;831.5799;Comment;16;192;191;188;187;182;181;180;179;178;177;176;175;174;173;171;170;EdgeColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;169;-3149.334,-2813.477;Inherit;False;noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;-3100.512,-2417.077;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;170;-2534.886,-2011.508;Inherit;False;169;noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;-2501.048,-2153.908;Inherit;False;168;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-3949.814,93.22915;Inherit;False;UV_VAT;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;173;-2312.756,-2077.196;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;-4478.124,439.6414;Inherit;False;20;UV_VAT;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;172;-2100.524,-2527.559;Inherit;False;Property;_Softness;Softness;19;0;Create;True;0;0;False;0;False;0.3582897;0.407;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-3863.031,530.0355;Inherit;False;Property;_BoudingMin;BoudingMin;17;0;Create;True;0;0;False;0;False;0;-2.653735;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-3865.731,429.1849;Inherit;False;Property;_BoudingMax;BoudingMax;18;0;Create;True;0;0;False;0;False;0;1.072085;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;24;-4188.883,321.003;Inherit;True;Property;_VAT_POS;VAT_POS;4;0;Create;True;0;0;False;0;False;-1;None;0680b1a9af24f4442b4e252b528cf1db;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;175;-2147.223,-2140.066;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;174;-1915.303,-2005.404;Inherit;False;Property;_EdgeWidth;EdgeWidth;11;0;Create;True;0;0;False;0;False;0.26;0.31;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;176;-1940.573,-1751.884;Inherit;False;Property;_OutSideEdgeWidth;OutSideEdgeWidth;14;0;Create;True;0;0;False;0;False;0.26;2.09;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;33;-4163.883,663.0032;Inherit;True;Property;_VAT_NORMAL;VAT_NORMAL;7;0;Create;True;0;0;False;0;False;-1;None;908c9706f47c33a4aa4a2f048c2d4f90;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;25;-3860.261,302.7687;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;26;-3646.941,433.3646;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;177;-1846.335,-2136.143;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;37;-3844.342,682.3348;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-3491.941,329.3646;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;179;-1837.315,-1893.984;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;178;-1726.671,-2136.498;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;180;-1534.67,-2137.39;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;34;-3646.805,683.3584;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-3355.742,565.3207;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;181;-1717.651,-1894.339;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;184;-2025.13,-3142.869;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;False;-1;84b9b3ff1190e104385e13edc319c5ab;de5969b59a7d5db48b198da3aa63c061;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;29;-3265.195,458.108;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;36;-3434.94,680.2877;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ColorNode;185;-2005.835,-3330.445;Inherit;False;Property;_ResovleColor;ResovleColor;10;1;[HDR];Create;True;0;0;False;0;False;1,0,0,0;31.62679,5.133145,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;182;-1274.518,-2138.493;Inherit;True;2;0;FLOAT;0.001;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;-2581.8,-2917.148;Inherit;True;168;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;187;-1525.65,-1897.232;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;-2608.498,-2606.552;Inherit;True;169;noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;188;-1286.502,-1619.946;Inherit;False;Property;_DissolveOutsideColor;DissolveOutsideColor;13;1;[HDR];Create;True;0;0;False;0;False;1,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;30;-3010.584,439.4792;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;191;-1270.359,-1897.079;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-1641.281,-3261.754;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;190;-2343.895,-2693.633;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;38;-3179.063,663.9117;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-2851.583,440.4792;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;194;-1800.424,-2586.959;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;193;-1112.697,-3146.977;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;39;-2999.949,669.0292;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;192;-1012.09,-1863.932;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;-1574.649,-2810.551;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;197;-810.4136,-3146.759;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;198;-269.6476,379.0463;Inherit;False;Property;_WindIntensity;WindIntensity;21;0;Create;True;0;0;False;0;False;0;1.07;0.5;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-2825.047,662.7708;Inherit;False;VAT_VertexNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-2638.19,437.8436;Inherit;False;VAT_VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;136;-347.6232,-2256.02;Inherit;False;Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-152.9631,504.4753;Inherit;False;35;VAT_VertexNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;203;250.3524,666.3463;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-202.1654,270.9565;Inherit;False;32;VAT_VertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;202;-151.3476,622.1463;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;137;-278.1813,-2612.385;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-273.9196,40.5631;Inherit;False;Constant;_Smoothness;Smoothness;1;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;199;63.15237,369.9463;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;158;-3817.104,-2477.602;Inherit;True;Property;_Gradient;Gradient;3;0;Create;True;0;0;False;0;False;-1;ee27ce608ae336a49af208ba200cc434;4226500b09883374a89cabfaf68e760a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;2;-283.9198,-70.43682;Inherit;False;Property;_Metallic;Metallic;2;0;Create;True;0;0;False;0;False;0;0.665;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;-3948.1,-2329.75;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;-4122.101,-2246.75;Inherit;False;Constant;_Float2;Float 2;11;0;Create;True;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;200;324.4524,457.0463;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;139;-97.95612,-229.4021;Inherit;False;137;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;138;-170.9561,152.5979;Inherit;False;136;Opacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;152;-4138.222,-2340.522;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;157;-3792.221,-2283.522;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;257,-166;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;BurnFlag;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;False;Transparent;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;0;6;0
WireConnection;7;1;5;0
WireConnection;9;0;7;0
WireConnection;10;0;9;0
WireConnection;10;1;8;0
WireConnection;142;0;140;0
WireConnection;145;1;142;0
WireConnection;145;0;143;0
WireConnection;11;0;10;0
WireConnection;146;0;141;2
WireConnection;146;1;144;2
WireConnection;12;0;11;0
WireConnection;156;0;154;0
WireConnection;147;0;146;0
WireConnection;147;1;145;0
WireConnection;159;0;196;0
WireConnection;159;3;156;0
WireConnection;148;0;147;0
WireConnection;148;1;140;0
WireConnection;14;0;12;0
WireConnection;14;1;8;0
WireConnection;13;1;8;0
WireConnection;162;0;148;0
WireConnection;162;1;159;0
WireConnection;15;0;14;0
WireConnection;15;1;13;0
WireConnection;16;0;15;0
WireConnection;164;0;161;0
WireConnection;164;2;160;0
WireConnection;163;0;162;0
WireConnection;163;1;154;0
WireConnection;167;1;164;0
WireConnection;166;0;163;0
WireConnection;166;1;165;0
WireConnection;19;0;17;1
WireConnection;19;1;18;0
WireConnection;169;0;167;1
WireConnection;168;0;166;0
WireConnection;20;0;19;0
WireConnection;173;0;171;0
WireConnection;173;1;170;0
WireConnection;24;1;21;0
WireConnection;175;0;173;0
WireConnection;175;1;172;0
WireConnection;33;1;21;0
WireConnection;25;0;24;0
WireConnection;26;0;22;0
WireConnection;26;1;23;0
WireConnection;177;0;175;0
WireConnection;177;1;174;0
WireConnection;37;0;33;0
WireConnection;27;0;25;0
WireConnection;27;1;26;0
WireConnection;179;0;175;0
WireConnection;179;1;176;0
WireConnection;178;0;177;0
WireConnection;180;0;178;0
WireConnection;34;0;37;0
WireConnection;28;0;27;0
WireConnection;28;1;23;0
WireConnection;181;0;179;0
WireConnection;29;0;28;0
WireConnection;36;0;34;0
WireConnection;182;1;180;0
WireConnection;187;0;181;0
WireConnection;30;0;29;0
WireConnection;191;0;187;0
WireConnection;191;1;182;0
WireConnection;189;0;185;0
WireConnection;189;1;184;0
WireConnection;190;0;183;0
WireConnection;190;1;186;0
WireConnection;38;0;36;0
WireConnection;31;0;30;0
WireConnection;194;0;190;0
WireConnection;194;1;172;0
WireConnection;193;0;184;0
WireConnection;193;1;189;0
WireConnection;193;2;180;0
WireConnection;39;0;38;0
WireConnection;39;1;36;2
WireConnection;39;2;36;1
WireConnection;192;0;191;0
WireConnection;192;1;188;0
WireConnection;195;0;184;4
WireConnection;195;1;194;0
WireConnection;197;0;193;0
WireConnection;197;1;192;0
WireConnection;197;2;191;0
WireConnection;35;0;39;0
WireConnection;32;0;31;0
WireConnection;136;0;195;0
WireConnection;203;0;198;0
WireConnection;137;0;197;0
WireConnection;199;0;41;0
WireConnection;199;1;198;0
WireConnection;155;0;152;0
WireConnection;155;1;153;0
WireConnection;200;0;40;0
WireConnection;200;1;202;0
WireConnection;200;2;203;0
WireConnection;157;0;155;0
WireConnection;0;2;139;0
WireConnection;0;3;2;0
WireConnection;0;4;3;0
WireConnection;0;10;138;0
WireConnection;0;11;199;0
WireConnection;0;12;200;0
ASEEND*/
//CHKSM=460D22C37C8D51F9CB3715EAB87002C629989596