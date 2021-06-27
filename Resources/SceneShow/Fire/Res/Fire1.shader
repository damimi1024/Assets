// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Fire1"
{
	Properties
	{
		_Noise("Noise", 2D) = "white" {}
		[HDR]_Color0("Color 0", Color) = (0,0,0,0)
		_Speed("Speed", Vector) = (0,0,0,0)
		_Gradient("Gradient", 2D) = "white" {}
		_Softness("Softness", Range( 0 , 1)) = 1
		_FireShape("FireShape", 2D) = "white" {}
		_GradientEnd("GradientEnd", Range( 0 , 10)) = 0.3328565
		_MaskControl("MaskControl", Float) = 0.1
		_Emiss("Emiss", Range( 1 , 5)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Stencil
		{
			Ref 0
		}
		Blend SrcAlpha OneMinusSrcAlpha , Zero Zero
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _Color0;
		uniform float _Emiss;
		uniform sampler2D _Gradient;
		SamplerState sampler_Gradient;
		uniform float4 _Gradient_ST;
		uniform float _GradientEnd;
		uniform sampler2D _Noise;
		SamplerState sampler_Noise;
		uniform float4 _Speed;
		uniform float4 _Noise_ST;
		uniform sampler2D _FireShape;
		uniform float _MaskControl;
		uniform float _Softness;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 break62 = ( _Color0 * _Emiss );
			float2 uv_Gradient = i.uv_texcoord * _Gradient_ST.xy + _Gradient_ST.zw;
			float4 tex2DNode30 = tex2D( _Gradient, uv_Gradient );
			float clampResult66 = clamp( ( ( 1.0 - tex2DNode30.r ) * _GradientEnd ) , 0.0 , 1.0 );
			float GradientEndControl55 = clampResult66;
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner20 = ( 1.0 * _Time.y * _Speed.xy + uv_Noise);
			float Noise47 = tex2D( _Noise, panner20 ).r;
			float4 appendResult64 = (float4(break62.r , ( GradientEndControl55 * break62.g * Noise47 ) , break62.b , 0.0));
			o.Emission = appendResult64.xyz;
			float4 appendResult74 = (float4(( i.uv_texcoord.x + ( (Noise47*2.0 + -1.0) * _MaskControl * GradientEndControl55 ) ) , i.uv_texcoord.y , 0.0 , 0.0));
			float clampResult43 = clamp( ( Noise47 - _Softness ) , 0.0 , 1.0 );
			float Gradient44 = tex2DNode30.r;
			float smoothstepResult34 = smoothstep( clampResult43 , Noise47 , Gradient44);
			o.Alpha = ( tex2D( _FireShape, appendResult74.xy ) * smoothstepResult34 ).r;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
-1919;359;1918;1017;1864.759;338.6876;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;49;-1704.815,-1017.38;Inherit;False;1557.394;751.5984;Gradient and noise;13;44;30;47;37;14;20;23;21;53;55;56;57;66;Gradient and noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;37;-1464.044,-507.3839;Inherit;False;0;30;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;30;-1134.447,-537.8608;Inherit;True;Property;_Gradient;Gradient;4;0;Create;True;0;0;False;0;False;-1;3f6fe21d74bde9e49871a05671bee3f5;3f6fe21d74bde9e49871a05671bee3f5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-1654.815,-949.6649;Inherit;False;0;14;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;23;-1583.265,-739.361;Inherit;False;Property;_Speed;Speed;3;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;57;-839.7131,-394.0517;Inherit;False;Property;_GradientEnd;GradientEnd;7;0;Create;True;0;0;False;0;False;0.3328565;0.72;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;53;-707.4137,-591.4512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;20;-1349.397,-941.0256;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-722.9129,-495.0514;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-1161.619,-967.3802;Inherit;True;Property;_Noise;Noise;0;0;Create;True;0;0;False;0;False;-1;dc12af17bb1612e45b27367c72669e71;dc12af17bb1612e45b27367c72669e71;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;76;-1675.016,-203.8759;Inherit;False;1221.691;646.1938;Shape;9;73;72;70;68;75;58;71;74;50;Shape;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-497.7801,-940.9749;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;66;-528.9025,-433.6959;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;-405.213,-530.4517;Inherit;True;GradientEndControl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;-1625.016,23.21215;Inherit;False;47;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-1353.978,327.318;Inherit;False;55;GradientEndControl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;75;-1353.978,7.317854;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-1348.353,200.4303;Inherit;False;Property;_MaskControl;MaskControl;8;0;Create;True;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;72;-1430.978,-145.6822;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1125.394,131.1242;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-422.377,621.5093;Inherit;False;Property;_Softness;Softness;5;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-127.2017,631.3777;Inherit;False;47;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-125.9685,-429.5255;Inherit;False;Property;_Emiss;Emiss;9;0;Create;True;0;0;False;0;False;1;0;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;17;-117.0724,-660.8798;Inherit;False;Property;_Color0;Color 0;2;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;70;-1082.394,-153.8759;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;169.0315,-574.5255;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-479.1885,-802.5662;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;42;-340.9715,419.7329;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-134.4426,326.0086;Inherit;False;44;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;201.0315,-332.5255;Inherit;False;55;GradientEndControl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;74;-941.9759,-8.198288;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;341.4536,-216.5927;Inherit;False;47;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;62;342.0315,-543.5255;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ClampOpNode;43;-82.21255,416.5889;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;565.9216,-335.9398;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;34;139.5705,505.6429;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;-774.3243,-82.9841;Inherit;True;Property;_FireShape;FireShape;6;0;Create;True;0;0;False;0;False;-1;2fe2d20b10e48dd4eb6f14c8e2d81427;2fe2d20b10e48dd4eb6f14c8e2d81427;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;441.4203,36.14218;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;64;666.0315,-550.5255;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;8;935,-231;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Fire1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;AlphaTest;ForwardOnly;14;all;True;True;True;True;0;False;-1;True;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;30;1;37;0
WireConnection;53;0;30;1
WireConnection;20;0;21;0
WireConnection;20;2;23;0
WireConnection;56;0;53;0
WireConnection;56;1;57;0
WireConnection;14;1;20;0
WireConnection;47;0;14;1
WireConnection;66;0;56;0
WireConnection;55;0;66;0
WireConnection;75;0;68;0
WireConnection;71;0;75;0
WireConnection;71;1;58;0
WireConnection;71;2;73;0
WireConnection;70;0;72;1
WireConnection;70;1;71;0
WireConnection;60;0;17;0
WireConnection;60;1;61;0
WireConnection;44;0;30;1
WireConnection;42;0;48;0
WireConnection;42;1;41;0
WireConnection;74;0;70;0
WireConnection;74;1;72;2
WireConnection;62;0;60;0
WireConnection;43;0;42;0
WireConnection;65;0;59;0
WireConnection;65;1;62;1
WireConnection;65;2;67;0
WireConnection;34;0;45;0
WireConnection;34;1;43;0
WireConnection;34;2;48;0
WireConnection;50;1;74;0
WireConnection;51;0;50;0
WireConnection;51;1;34;0
WireConnection;64;0;62;0
WireConnection;64;1;65;0
WireConnection;64;2;62;2
WireConnection;8;2;64;0
WireConnection;8;9;51;0
ASEEND*/
//CHKSM=8DDF3EB8BBC53320FA327CBD4C2A69097F86A09E