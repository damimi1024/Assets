// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dissovle3"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_Noise("Noise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Vector) = (0,0,0,0)
		[HDR]_ResovleColor("ResovleColor", Color) = (1,0,0,0)
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.4338944
		_EdgeWidth("EdgeWidth", Float) = 0.26
		_Spread("Spread", Range( 0 , 1)) = 0
		_Softness("Softness", Range( 0 , 0.5)) = 0.3582897
		_Height("Height", Float) = 3.5
		[Toggle(_BOTTOMCENTER_ON)] _BOTTOMCENTER("模型中心点位于底部", Float) = 0
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
		#pragma shader_feature_local _BOTTOMCENTER_ON
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _ResovleColor;
		uniform float _Height;
		uniform float _ChangeAmount;
		uniform float _Spread;
		uniform sampler2D _Noise;
		SamplerState sampler_Noise;
		uniform float2 _NoiseSpeed;
		uniform float _Softness;
		uniform float _EdgeWidth;
		SamplerState sampler_MainTex;
		uniform float _Cutoff = 0.5;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld106 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			#ifdef _BOTTOMCENTER_ON
				float staticSwitch129 = 0.0;
			#else
				float staticSwitch129 = ( _Height / 2.0 );
			#endif
			float clampResult123 = clamp( ( ( ( ase_worldPos.y - objToWorld106.y ) + staticSwitch129 ) / _Height ) , 0.0 , 1.0 );
			float Gradient82 = ( ( ( clampResult123 - (-_Spread + (_ChangeAmount - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread ) * 2.0 );
			float2 panner72 = ( 1.0 * _Time.y * _NoiseSpeed + i.uv_texcoord);
			float noise95 = tex2D( _Noise, panner72 ).r;
			float clampResult52 = clamp( ( 1.0 - ( distance( ( Gradient82 - noise95 ) , _Softness ) / _EdgeWidth ) ) , 0.0 , 1.0 );
			float4 lerpResult50 = lerp( tex2DNode1 , ( _ResovleColor * tex2DNode1 ) , clampResult52);
			o.Emission = lerpResult50.rgb;
			o.Alpha = 1;
			float smoothstepResult92 = smoothstep( _Softness , 0.5 , ( Gradient82 - noise95 ));
			clip( ( tex2DNode1.a * smoothstepResult92 ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
1;1;2558;1377;2220.593;709.2627;1.20819;True;True
Node;AmplifyShaderEditor.CommentaryNode;61;-2488.653,-89.04785;Inherit;False;1424.732;989.8838;Comment;19;107;115;128;126;31;123;114;90;30;82;102;103;91;53;89;105;106;129;130;Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-2443.836,314.5179;Inherit;False;Property;_Height;Height;9;0;Create;True;0;0;False;0;False;3.5;0.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;106;-2483.396,119.5489;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;128;-2187.062,320.4266;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-2450.062,406.4266;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;105;-2469.396,-47.45111;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;129;-2023.062,389.4266;Inherit;False;Property;_BOTTOMCENTER;模型中心点位于底部;10;0;Create;False;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;107;-2199.396,-31.45111;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;126;-1974.062,-12.57343;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-2445.9,757.2999;Inherit;False;Property;_Spread;Spread;7;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;114;-1839.836,14.51788;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2472,568.3;Inherit;False;Property;_ChangeAmount;ChangeAmount;5;0;Create;True;0;0;False;0;False;0.4338944;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;90;-2093,711;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;104;-2386.528,-542.1365;Inherit;False;1259.266;378.3628;Comment;5;63;73;72;62;95;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;53;-1917,567;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;123;-1636.962,160.8408;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;63;-2336.528,-492.1363;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;31;-1478.571,161.7017;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;73;-2335.209,-324.7729;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;3;0;Create;True;0;0;False;0;False;0,0;0,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;91;-1517,737.4;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-1309,711;Inherit;False;Constant;_Float0;Float 0;9;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;72;-2002.207,-474.7734;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-1309,583;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;62;-1781.444,-449.1819;Inherit;True;Property;_Noise;Noise;2;0;Create;True;0;0;False;0;False;-1;cea807cca851fb44da696ea20abb3fed;cb6fc684c58081647aed6fc6ac5fbedd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;81;-994.6839,211.6086;Inherit;False;1669.226;296.58;Comment;8;52;42;54;41;55;101;83;100;EdgeColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;82;-1231.923,424.196;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-1370.26,-401.7307;Inherit;False;noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;-969.6734,404.1672;Inherit;False;95;noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;-935.835,261.7674;Inherit;False;82;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;101;-700.543,329.4788;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-429.9345,-96.28563;Inherit;False;Property;_Softness;Softness;8;0;Create;True;0;0;False;0;False;0.3582897;0;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-226.0904,404.2712;Inherit;False;Property;_EdgeWidth;EdgeWidth;6;0;Create;True;0;0;False;0;False;0.26;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;41;-488.0107,277.6087;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;84;-1008.075,-459.6406;Inherit;True;82;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;54;-183.122,264.5325;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;-978.2692,-173.26;Inherit;True;95;noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;98;-673.3052,-262.3592;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-397.4411,-805.196;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;False;-1;84b9b3ff1190e104385e13edc319c5ab;84b9b3ff1190e104385e13edc319c5ab;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;43;-375.546,-1008.372;Inherit;False;Property;_ResovleColor;ResovleColor;4;1;[HDR];Create;True;0;0;False;0;False;1,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;42;-2.458145,278.1778;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;92;-129.8343,-155.6856;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;52;220.5433,298.285;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;31.90791,-946.1802;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;50;171.4928,-777.204;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;146.3403,-403.0779;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;444.0188,-440.7127;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Dissovle3;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;False;Transparent;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;128;0;115;0
WireConnection;129;1;128;0
WireConnection;129;0;130;0
WireConnection;107;0;105;2
WireConnection;107;1;106;2
WireConnection;126;0;107;0
WireConnection;126;1;129;0
WireConnection;114;0;126;0
WireConnection;114;1;115;0
WireConnection;90;0;89;0
WireConnection;53;0;30;0
WireConnection;53;3;90;0
WireConnection;123;0;114;0
WireConnection;31;0;123;0
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
WireConnection;98;0;84;0
WireConnection;98;1;99;0
WireConnection;42;0;54;0
WireConnection;92;0;98;0
WireConnection;92;1;93;0
WireConnection;52;0;42;0
WireConnection;60;0;43;0
WireConnection;60;1;1;0
WireConnection;50;0;1;0
WireConnection;50;1;60;0
WireConnection;50;2;52;0
WireConnection;21;0;1;4
WireConnection;21;1;92;0
WireConnection;0;2;50;0
WireConnection;0;10;21;0
ASEEND*/
//CHKSM=7D467C0660E4D2F9248A50B61CB4E8293763CA26