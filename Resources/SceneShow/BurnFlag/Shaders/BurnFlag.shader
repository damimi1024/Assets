// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BurnFlag"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_VAT_POS("VAT_POS", 2D) = "white" {}
		_VAT_NORMAL("VAT_NORMAL", 2D) = "white" {}
		_FrameCount("FrameCount", Float) = 0
		_BoudingMin("BoudingMin", Float) = 0
		_BoudingMax("BoudingMax", Float) = 0
		_WindIntensity("WindIntensity", Range( 0.5 , 2)) = 0
		_Speed("Speed", Float) = 0
		_Softness("Softness", Range( 0 , 0.5)) = 0.3582897
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.484758
		_EdgeWidth("EdgeWidth", Float) = 0.26
		_OutSideEdgeWidth("OutSideEdgeWidth", Float) = 0.26
		[HDR]_ResovleColor("ResovleColor", Color) = (1,0,0,0)
		[HDR]_DissolveOutsideColor("DissolveOutsideColor", Color) = (1,0,0,0)
		_Height("Height", Float) = 3.5
		_Spread("Spread", Range( 0 , 1)) = 0
		[Toggle(_BOTTOMCENTER2_ON)] _BOTTOMCENTER2("模型中心点位于底部", Float) = 0
		_Noise("Noise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Vector) = (0,0,0,0)
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
			float4 temp_cast_0 = (Gradient168).xxxx;
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner225 = ( 1.0 * _Time.y * _NoiseSpeed + uv_Noise);
			float4 noise169 = tex2D( _Noise, panner225 );
			float4 temp_cast_1 = (_Softness).xxxx;
			float temp_output_175_0 = distance( ( temp_cast_0 - noise169 ) , temp_cast_1 );
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
			float4 temp_cast_3 = (_Softness).xxxx;
			float4 temp_cast_4 = (Gradient168).xxxx;
			float4 smoothstepResult194 = smoothstep( temp_cast_3 , float4( 0.5,0,0,0 ) , ( temp_cast_4 - noise169 ));
			float4 Opacity136 = ( tex2DNode184.a * smoothstepResult194 );
			clip( Opacity136.r - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
-1919;359;1918;1017;6973.354;3863.351;4.950483;True;True
Node;AmplifyShaderEditor.CommentaryNode;4;-2474.77,-1115.675;Inherit;False;2200.86;1190.064;VAT;35;39;38;37;36;35;34;33;32;31;30;29;28;27;26;25;24;23;22;21;20;19;18;17;16;15;14;13;12;11;10;9;8;7;6;5;VAT;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2424.77,-929.1678;Inherit;False;Property;_Speed;Speed;8;0;Create;True;0;0;False;0;False;0;0.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;6;-2400.497,-1065.675;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-2220.671,-1052.667;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;149;-5251.232,-2271.886;Inherit;False;2382.657;970.5276;Comment;18;168;166;163;165;162;148;159;147;156;196;146;154;145;144;143;142;141;140;Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.FractNode;9;-2071.936,-1053.557;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-2115.315,-890.2108;Inherit;False;Property;_FrameCount;FrameCount;4;0;Create;True;0;0;False;0;False;0;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-5134.187,-1847.805;Inherit;False;Property;_Height;Height;16;0;Create;True;0;0;False;0;False;3.5;11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;144;-5173.748,-2042.774;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;143;-5140.414,-1755.895;Inherit;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;142;-4877.414,-1841.895;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-1878.695,-1060.775;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;141;-5159.748,-2209.774;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;145;-4713.414,-1772.895;Inherit;False;Property;_BOTTOMCENTER2;模型中心点位于底部;18;0;Create;False;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;146;-4889.748,-2193.774;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CeilOpNode;11;-1722.695,-1042.775;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;154;-4221.342,-1717.866;Inherit;False;Property;_Spread;Spread;17;0;Create;True;0;0;False;0;False;0;0.287;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;156;-3891.893,-1749.73;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;196;-4266.364,-1889.961;Inherit;False;Property;_ChangeAmount;ChangeAmount;11;0;Create;True;0;0;False;0;False;0.484758;0.529;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;12;-1603.795,-1034.348;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;147;-4664.414,-2174.896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;150;-4519.01,-3065.94;Inherit;False;1513.547;559.3765;Comment;5;169;222;223;225;226;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;14;-1450.285,-1036.296;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;148;-4530.187,-2147.805;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;13;-1470.372,-899.3168;Inherit;False;2;0;FLOAT;-1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;159;-3706.79,-1896.141;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;162;-3472.226,-2164.137;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-1271.373,-980.3168;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;223;-4408.417,-2970.764;Inherit;False;0;222;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;226;-4395.494,-2803.345;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;20;0;Create;True;0;0;False;0;False;0,0;0,-0.6;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-1131.885,-981.1958;Inherit;False;CurrentFrame;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;225;-4077.487,-2943.043;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;163;-3312.345,-1729.866;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;165;-3305.375,-1606.547;Inherit;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;166;-3098.375,-1878.548;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;222;-3772.529,-2982.099;Inherit;True;Property;_Noise;Noise;19;0;Create;True;0;0;False;0;False;-1;None;cea807cca851fb44da696ea20abb3fed;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;18;-2366.535,-603.3854;Inherit;False;16;CurrentFrame;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;17;-2378.535,-743.3853;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;168;-3116.578,-2027.642;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;151;-2495.198,-2110.125;Inherit;False;1791.65;830.0037;Comment;16;192;191;188;187;182;180;181;178;179;176;177;174;175;173;170;171;EdgeColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;19;-2026.534,-722.7069;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;169;-3200.065,-2907.534;Inherit;False;noise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-1853.534,-725.3853;Inherit;False;UV_VAT;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;-2436.35,-2059.967;Inherit;False;168;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;170;-2470.188,-1917.567;Inherit;False;169;noise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;-2381.845,-378.9731;Inherit;False;20;UV_VAT;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;173;-2248.058,-1983.255;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;172;-2284.012,-2535.963;Inherit;False;Property;_Softness;Softness;9;0;Create;True;0;0;False;0;False;0.3582897;0.266;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1766.751,-288.5789;Inherit;False;Property;_BoudingMin;BoudingMin;5;0;Create;True;0;0;False;0;False;0;-2.653735;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;174;-1850.604,-1911.463;Inherit;False;Property;_EdgeWidth;EdgeWidth;12;0;Create;True;0;0;False;0;False;0.26;0.84;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;24;-2092.603,-497.6115;Inherit;True;Property;_VAT_POS;VAT_POS;2;0;Create;True;0;0;False;0;False;-1;None;0680b1a9af24f4442b4e252b528cf1db;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;22;-1769.451,-389.4295;Inherit;False;Property;_BoudingMax;BoudingMax;6;0;Create;True;0;0;False;0;False;0;1.072085;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;175;-2082.524,-2046.125;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;26;-1550.661,-385.25;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;177;-1781.636,-2042.202;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;176;-1875.874,-1657.943;Inherit;False;Property;_OutSideEdgeWidth;OutSideEdgeWidth;13;0;Create;True;0;0;False;0;False;0.26;8.11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;33;-2067.603,-155.6113;Inherit;True;Property;_VAT_NORMAL;VAT_NORMAL;3;0;Create;True;0;0;False;0;False;-1;None;908c9706f47c33a4aa4a2f048c2d4f90;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;25;-1763.981,-515.8458;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1395.661,-489.2499;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;37;-1748.062,-136.2797;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;179;-1772.616,-1800.042;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;178;-1661.973,-2042.557;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;181;-1652.953,-1800.397;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;180;-1469.972,-2043.449;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;34;-1550.525,-135.2561;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-1327.462,-359.2937;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;185;-2005.835,-3330.445;Inherit;False;Property;_ResovleColor;ResovleColor;14;1;[HDR];Create;True;0;0;False;0;False;1,0,0,0;72.65929,13.31453,1.141245,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;183;-2581.8,-2917.148;Inherit;True;168;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;36;-1338.66,-138.3267;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;186;-2608.498,-2606.552;Inherit;True;169;noise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;182;-1209.819,-2044.552;Inherit;True;2;0;FLOAT;0.001;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;187;-1460.952,-1803.291;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;184;-2025.13,-3142.869;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;False;-1;84b9b3ff1190e104385e13edc319c5ab;de5969b59a7d5db48b198da3aa63c061;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;29;-1168.915,-360.5066;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ColorNode;188;-1221.803,-1526.005;Inherit;False;Property;_DissolveOutsideColor;DissolveOutsideColor;15;1;[HDR];Create;True;0;0;False;0;False;1,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;191;-1205.661,-1803.137;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;30;-914.3044,-379.1353;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;190;-2327.722,-2766.41;Inherit;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NegateNode;38;-1082.783,-154.7028;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-1697.181,-3485.354;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-755.3035,-378.1353;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;39;-903.6694,-149.5853;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;193;-1112.697,-3146.977;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;194;-1952.043,-2892.218;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.5,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;192;-947.3911,-1769.99;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-541.9104,-380.771;Inherit;False;VAT_VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;197;-810.4136,-3146.759;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-728.7676,-155.8436;Inherit;False;VAT_VertexNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;-1648.649,-2932.551;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;198;-408.1996,-1686.528;Inherit;False;Property;_WindIntensity;WindIntensity;7;0;Create;True;0;0;False;0;False;0;0.5;0.5;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-405.3371,-1794.618;Inherit;False;32;VAT_VertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-130.7325,-1542.121;Inherit;False;35;VAT_VertexNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;203;-83.74312,-1268.956;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;137;-622.9466,-2859.253;Inherit;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;136;-1425.58,-2918.744;Inherit;False;Opacity;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalVertexDataNode;202;-99.1713,-1451.243;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;200;150.9654,-1463.832;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;199;9.709159,-1810.683;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-420.8959,-2126.555;Inherit;False;Property;_Metallic;Metallic;10;0;Create;True;0;0;False;0;False;0;0.15;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-410.8956,-2015.554;Inherit;False;Constant;_Smoothness;Smoothness;1;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;138;-374.1277,-1912.976;Inherit;False;136;Opacity;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;139;-403.5736,-2279.215;Inherit;False;137;Emission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;302.7103,-2156.526;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;BurnFlag;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;0;6;0
WireConnection;7;1;5;0
WireConnection;9;0;7;0
WireConnection;142;0;140;0
WireConnection;10;0;9;0
WireConnection;10;1;8;0
WireConnection;145;1;142;0
WireConnection;145;0;143;0
WireConnection;146;0;141;2
WireConnection;146;1;144;2
WireConnection;11;0;10;0
WireConnection;156;0;154;0
WireConnection;12;0;11;0
WireConnection;147;0;146;0
WireConnection;147;1;145;0
WireConnection;14;0;12;0
WireConnection;14;1;8;0
WireConnection;148;0;147;0
WireConnection;148;1;140;0
WireConnection;13;1;8;0
WireConnection;159;0;196;0
WireConnection;159;3;156;0
WireConnection;162;0;148;0
WireConnection;162;1;159;0
WireConnection;15;0;14;0
WireConnection;15;1;13;0
WireConnection;16;0;15;0
WireConnection;225;0;223;0
WireConnection;225;2;226;0
WireConnection;163;0;162;0
WireConnection;163;1;154;0
WireConnection;166;0;163;0
WireConnection;166;1;165;0
WireConnection;222;1;225;0
WireConnection;168;0;166;0
WireConnection;19;0;17;1
WireConnection;19;1;18;0
WireConnection;169;0;222;0
WireConnection;20;0;19;0
WireConnection;173;0;171;0
WireConnection;173;1;170;0
WireConnection;24;1;21;0
WireConnection;175;0;173;0
WireConnection;175;1;172;0
WireConnection;26;0;22;0
WireConnection;26;1;23;0
WireConnection;177;0;175;0
WireConnection;177;1;174;0
WireConnection;33;1;21;0
WireConnection;25;0;24;0
WireConnection;27;0;25;0
WireConnection;27;1;26;0
WireConnection;37;0;33;0
WireConnection;179;0;175;0
WireConnection;179;1;176;0
WireConnection;178;0;177;0
WireConnection;181;0;179;0
WireConnection;180;0;178;0
WireConnection;34;0;37;0
WireConnection;28;0;27;0
WireConnection;28;1;23;0
WireConnection;36;0;34;0
WireConnection;182;1;180;0
WireConnection;187;0;181;0
WireConnection;29;0;28;0
WireConnection;191;0;187;0
WireConnection;191;1;182;0
WireConnection;30;0;29;0
WireConnection;190;0;183;0
WireConnection;190;1;186;0
WireConnection;38;0;36;0
WireConnection;189;0;185;0
WireConnection;189;1;184;0
WireConnection;31;0;30;0
WireConnection;39;0;38;0
WireConnection;39;1;36;2
WireConnection;39;2;36;1
WireConnection;193;0;184;0
WireConnection;193;1;189;0
WireConnection;193;2;180;0
WireConnection;194;0;190;0
WireConnection;194;1;172;0
WireConnection;192;0;191;0
WireConnection;192;1;188;0
WireConnection;32;0;31;0
WireConnection;197;0;193;0
WireConnection;197;1;192;0
WireConnection;197;2;191;0
WireConnection;35;0;39;0
WireConnection;195;0;184;4
WireConnection;195;1;194;0
WireConnection;203;0;198;0
WireConnection;137;0;197;0
WireConnection;136;0;195;0
WireConnection;200;0;40;0
WireConnection;200;1;202;0
WireConnection;200;2;203;0
WireConnection;199;0;41;0
WireConnection;199;1;198;0
WireConnection;0;2;139;0
WireConnection;0;3;2;0
WireConnection;0;4;3;0
WireConnection;0;10;138;0
WireConnection;0;11;199;0
WireConnection;0;12;200;0
ASEEND*/
//CHKSM=D44FA01A1A4851D8211974961AA1A3B6B2AB77C5