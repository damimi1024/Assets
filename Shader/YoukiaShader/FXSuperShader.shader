//********************************************
//SG2特效定制Shader
//提供特效需求的基础功能,有大型计算的不要放进来
//部分通用运算提到Cginc里面
//添加功能后在功能表单记录上便于维护
//使用顺序上,不要随意改变函数和运算位置避免冲突.
//                                    By:jinyang
//********************************************
// 约束:
// - 顶点流约束
//   - 自定义数据存储从:TEXCOORD4开始
//   - 顶点流数据TEXCOORD1,TEXCOORD2,TEXCOORD3
//   - TEXCOORD1
//     - X.控制溶解 (T1.x)
//     - Y.控制顶点动画 (T1.y)
//     - Z.控制U单次流动 (T1.z)
//     - W.控制V单次流动 (T1.w)
//   - TEXCOORD2
//     - X.弯曲(T2.x)
//     - Y.弯曲(T2.y) 
//     - Z.旋转(T2.z)(手动模式)
//   - TEXCOORD3:留原始UV,用于给遮罩一类的采样
// - 项目未分级,该Shder是基础Shader所以LOD初始化到200,如不分级不要改动
// - The default,表示默认支持,无需开启变体
// - 属性、变量、方法、系统项、设置、编译指令、均根据功能进行空格区分,便于维护
//********************************************
// 自定义数据:
// TEXCOORD4 xyz: UI剪裁坐标
// TEXCOORD5 x:菲涅尔
// TEXCOORD6 xy:细节纹理
// TEXCOORD7 xyzw:热力-齐次坐标下的屏幕坐标值
// TEXCOORD8 xyz:顶点动画法线方向
//********************************************
//  关于优化:
//  1- 运算提取
//  2- 色彩变量类型
//  3- 精度控制
//  4- 算法的修改
//  优化投产后,后续根据实际情况逐步进行
//********************************************


Shader "Custom/FXSuperShader"
{
    Properties
    {
        _MainTex("主贴图", 2D) = "white" {}
         [HDR]_MainColor("颜色", Color) = (1, 1, 1, 1)
        _Alpha ("Alpha强度", float) = 1
        
        [MaterialToggle]_U_Mirror ("U镜像", Float ) = 0
        [MaterialToggle]_V_Mirror ("V镜像", Float ) = 0

        _MainTexSpeedU("X方向速度",Range(-10,10)) = 0
        _MainTexSpeedV("Y方向速度",Range(-10,10)) = 0

        _MaskTex("遮罩", 2D) = "white" {}

        _DissolveTex ("溶解图", 2D) = "white" {}
        _DissolveEdge("软硬强度",Float) = 0
        _DissolveProgress("手动进度",Range(-0.5,1.5)) = 0
        _DissolveTimeOnOff("手动开关(填 0 或 1(手动))",Range(0,1)) = 0
        _DissolveT1OnOff("T1开关(填 0(关) 或 1)",Range(0,1)) = 0
        _DissolveTexOffsetSpeedZ("溶解贴图Offset速度X",Range(-5,5)) = 0 
         _DissolveTexOffsetSpeedW("溶解贴图Offset速度Y",Range(-5,5)) = 0 

        [Toggle(UIMASKCLIP_ON)] _Redify("UI剪裁", Int) = 0

        _Hue("色彩名称",Range(-1,1)) = 0
        _Sat("饱和度",Range(-1,1)) = 0
        _Val("亮度（Brightness）",Range(-1,1)) = 0

        _FresnelColor("Fresnel Color", Color) = (1,1,1,1)
		    _FresnelBias("Fresnel Bias", Float) = 0
		    _FresnelScale("Fresnel Scale", Float) = 1
		    _FresnelPower("Fresnel Power", Float) = 1

        _DistortTex ("DistortTex", 2D) = "white" {}
		    _DistRGBA ("DistRGBA", Vector) = (0, 0, 0, 1)
		    _DistForceU ("DistStrength_U", range (-1,1)) = 1
		    _DistForceV ("DistStrength_V", range (-1,1)) = 1
        _DistTime("DistSpeed", range (-1,1)) = 0.1

        _DetailTex ("DetailTex", 2D) = "white" {}
		    _DetailTexAngle ("DetailTexAngle", Range(0, 360)) = 0
		    _DetailTexSpeed_U ("DetailTexSpeed_U", Float) = 0
		    _DetailTexSpeed_V ("DetailTexSpeed_V", Float) = 0
		    _DetailTexStrength ("DetailTexStrength", Range(0, 10)) = 1
		    _DetailChoiceRGB ("DetailChoiceRGB", Range(0, 1)) = 0
		    _DetailAddorMultiply ("DetailAddorMultiply", Range(0, 1)) = 0
        _MainTexStrength ("主贴图A通道强度(细节用的)", Range(0, 10)) = 1

         _DistortionMap("RG图", 2D) = "" {}
         _DistortionPower("Distortion Power", Range(0,2)) = 0
         _DistortionSpeed("DistortionSpeed", Range(0,1)) = 1

        _Atan2Speed("极扩散速度",Range(-10,10)) = 0
        _Atan2Density("极扩散密度",Range(-100,100)) = 0

        _BendingTex("弯曲贴图",2D) = "white" {}
        _CircleSpeed("圆速度",Range(-10,10)) = 0

        _AutoZRote("T2.Z旋转开关:0关闭-1开启 (默认1)",Range(0,1)) = 1
        _RoteValue("Z旋转关闭时,手动控制转动",Float) = 1

        [Enum(Off, 0, On, 1)] _zWrite("ZWrite", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _zTest("ZTest", Float) = 8
        [Enum(UnityEngine.Rendering.CullMode)] _cull("Cull Mode", Float) = 2
        [Enum(UnityEngine.Rendering.BlendMode)] _srcBlend("Src Blend Mode", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _dstBlend("Dst Blend Mode", Float) = 10
        [Enum(UnityEngine.Rendering.BlendMode)] _srcAlphaBlend("Src Alpha Blend Mode", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _dstAlphaBlend("Dst Alpha Blend Mode", Float) = 10

        //增加一个混合操作,让混合完全开放
        //_BlendOp
    }
    
    SubShader
    {
       Tags
       {
          "IgnoreProjector" = "True"
          "Queue" = "Transparent"
          "RenderType" = "Transparent"
          "PreviewType" = "Plane"
       }

        Pass
        {
            Name "FORWARD_P1"

            Tags
            {
               "LightMode" = "ForwardBase"
            }

            //**设置**
            ColorMask RGBA
            Blend[_srcBlend][_dstBlend],[_srcAlphaBlend][_dstAlphaBlend]
            ZWrite[_zWrite]
            ZTest [unity_GUIZTestMode]//[_zTest]
            Cull[_cull]
            LOD 200

            CGPROGRAM

            //**系统项**
            //顶点，片段，启用顶点流，引用头文件，
            //支持3.0，编译约束OGL，支持GPU实例化，实例化限定,精度保留
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_particles
            #pragma multi_compile_instancing
            #pragma multi_compile __ UNITY_UI_CLIP_RECT
            #pragma multi_compile __ UNITY_UI_ALPHACLIP
            #include "UnityCG.cginc"
            #include "UnityUI.cginc"
            #pragma target 3.0
            //不进行排除编译,需要对模拟器支持
            //#pragma exclude_renderers gles
            //#pragma fragmentoption ARB_precision_hint_fastest

            //**功能表**
            //（使用了对应功能，打包时需对其生成材质球与变体存储，详见工程工具）
            //HDR
            //The default
            //Alpha强度
            //The default
            //流动
            #pragma shader_feature MAINMOVE_ON
			 //单次流动
			 #pragma shader_feature MAINMOVEONE_ON
            //遮罩
            #pragma shader_feature MASK_ON
            //溶解
            #pragma shader_feature DISSIPATE_ON
            //UI防穿剪裁
            #pragma shader_feature UIMASKCLIP_ON
            //HSV(HSB)色彩空间
            #pragma shader_feature HSV_ON
            //菲涅尔
            #pragma shader_feature FRESNEL_ON
            //细节纹理
            #pragma shader_feature DETAIL_ON
            //扭曲
            //(只扭曲MainTex与DetailTex）
            #pragma shader_feature DISTORT2_ON
            //顶点动画
            #pragma shader_feature VERTEX_ANIMATION
            //极扩散
            #pragma shader_feature MAINMOVEATAN_ON
            //镜子
            #pragma shader_feature MIRROR_ON
            //弯曲
            #pragma shader_feature BENDING_ON
            //圆
            #pragma shader_feature CIRCLE_ON
            //旋转
            #pragma shader_feature ROTA_ON

            //**变量**
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            #ifdef ROTA_ON
            fixed _AutoZRote;
            half  _RoteValue;
            #endif

            #ifdef MIRROR_ON
            fixed _U_Mirror;
            fixed _V_Mirror;
            #endif

            #ifdef MAINMOVE_ON
            fixed _MainTexSpeedU;
            fixed _MainTexSpeedV;
            #endif

            #ifdef MASK_ON
            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            #endif

            #ifdef DISSIPATE_ON
            sampler2D _DissolveTex;
            float4 _DissolveTex_ST;
            float _DissolveEdge;
            float _DissolveProgress;
            float _DissolveTimeOnOff;
            float _DissolveT1OnOff;
            float _DissolveTexOffsetSpeedZ;
            float _DissolveTexOffsetSpeedW;
            #endif

           
            float4 _ClipRect;
           
            #ifdef HSV_ON
            float _Hue;
            float _Sat;
            float _Val;
            #endif

            #ifdef FRESNEL_ON
            fixed4 _FresnelColor;
			      fixed _FresnelBias;
			      fixed _FresnelScale;
			      fixed _FresnelPower;
            #endif

            #ifdef DETAIL_ON
            sampler2D _DetailTex;
            fixed4 _DetailTex_ST;
            fixed _DetailTexSpeed_U; 
            fixed _DetailTexSpeed_V;
            fixed _DetailTexAngle;
            fixed _MainTexStrength;
            fixed _DetailChoiceRGB;
            fixed _DetailAddorMultiply;
            fixed _DetailTexStrength;
            #endif

            #ifdef DISTORT2_ON
            sampler2D _DistortionMap;
            float4 _DistortionMap_ST;
            float _DistortionPower;
            float _DistortionSpeed;
            #endif

            #ifdef MAINMOVEATAN_ON
            fixed _Atan2Speed;
            fixed _Atan2Density;
            #endif 

            #ifdef BENDING_ON
            sampler2D _BendingTex;
            float4 _BendingTex_ST;
            #endif

            #ifdef CIRCLE_ON
            fixed _CircleSpeed;
            #endif

            UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_DEFINE_INSTANCED_PROP(float4, _MainColor)
            UNITY_DEFINE_INSTANCED_PROP(fixed, _Alpha)
            UNITY_INSTANCING_BUFFER_END(Props)

            //**IO结构体**
            struct int_vert
            {
                float4 vertex : POSITION;
                float4 vertexColor : COLOR;
                float4 uv : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
                half3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct out_vert
            {
                float4 pos : SV_POSITION;
                float4 vertexColor : COLOR;
                float4 uv : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
				        float4 originalUV : TEXCOORD3;
                float3 vpos : TEXCOORD4;
                float fresnel : TEXCOORD5;
                float2 detail : TEXCOORD6;
                float4 screenpos : TEXCOORD7; 
                float3 normaldir : TEXCOORD8;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


             out_vert vert(int_vert v)
            {
                 out_vert o = (out_vert)0;
                 UNITY_SETUP_INSTANCE_ID(v);
			     UNITY_TRANSFER_INSTANCE_ID(v, o);
                 o.vertexColor = v.vertexColor;
                 o.uv = v.uv;
                 o.uv1 = v.uv1;
                 o.uv2 = v.uv2;
				 o.originalUV = v.uv;
                 
                 //**顶点动画**
                 #ifdef VERTEX_ANIMATION
                 o.normaldir = UnityObjectToWorldNormal(v.normal);
                 float4 _MainTex_var = tex2Dlod(_MainTex,float4(TRANSFORM_TEX(o.uv, _MainTex),0.0,0));
                 v.vertex.xyz += (_MainTex_var.rgb * o.uv1.y * v.normal);
                 #endif
                 
                 o.pos = UnityObjectToClipPos( v.vertex );

                //**剪裁**
                #ifdef UIMASKCLIP_ON
                o.vpos = mul(unity_ObjectToWorld, v.vertex).xyz;
                #endif

                fixed oneDegree = (UNITY_PI / 180.0);
                 //**旋转**
                 #ifdef ROTA_ON
                 float rote = lerp(_RoteValue,o.uv2.z,_AutoZRote);
                 fixed cosMain = cos(oneDegree * rote * 360);
                 fixed sinMain = sin(oneDegree * rote * 360);
                 fixed2 mainRota = mul(v.uv.xy - fixed2(0.5, 0.5), fixed2x2(cosMain,  -sinMain, sinMain, cosMain)) + fixed2(0.5, 0.5);
                 o.uv.xy = mainRota;
                 #endif

                 //**镜像**
                 #ifdef MIRROR_ON
                 o.uv.x = lerp(v.uv.x,(1 - v.uv.x),_U_Mirror);
                 o.uv.y = lerp(v.uv.y,(1 - v.uv.y),_V_Mirror);
                 #endif

                 //**移动**
                 #ifdef MAINMOVE_ON
                  fixed uvX = _MainTexSpeedU * _Time.y;
                  fixed uvY = _MainTexSpeedV * _Time.y;
                  o.uv.xy += fixed2(uvX, uvY); 
                 #endif

                 //**菲涅尔**
                 #ifdef FRESNEL_ON
                 float3 i = normalize(ObjSpaceViewDir(o.pos));
				         o.fresnel = _FresnelBias + _FresnelScale * pow(1 + dot(i, v.normal), _FresnelPower);
				         #endif

                  //**细节**
                  #ifdef DETAIL_ON
                  fixed2 dSpeed = _Time.y * (fixed2(_DetailTexSpeed_U, _DetailTexSpeed_V)); 
				          fixed2 uv_Detail = (o.uv.xy * _DetailTex_ST.xy + _DetailTex_ST.zw); 
				          fixed cosD = cos(oneDegree * _DetailTexAngle); 
				          fixed sinD = sin(oneDegree * _DetailTexAngle); 
				          fixed2 dRota = mul(uv_Detail - fixed2(0.5, 0.5), fixed2x2(cosD,  - sinD, sinD, cosD)) + fixed2(0.5, 0.5);
				          o.detail.xy = dRota + frac(dSpeed); 
                  #endif
                  
                 return o;
            }

            fixed4 frag(out_vert i) : COLOR
            {
                UNITY_SETUP_INSTANCE_ID(i);

				#ifdef MAINMOVEONE_ON
				i.uv.xy = (i.uv.xy + float2(i.uv1.z,i.uv1.w));
				#endif

                 //**主体采样**
                fixed4 mainColor;
                
                //极扩散
                #ifdef MAINMOVEATAN_ON
                float2 uvCenter = i.uv - 0.5;
                float circleUVX = length(uvCenter) + _Time.y *_Atan2Speed;
                float circleUVY = atan2(uvCenter.y,uvCenter.x) / _Atan2Density;
                i.uv.xy = float2(circleUVX, circleUVY);
                mainColor = tex2D(_MainTex,TRANSFORM_TEX(i.uv.xy,_MainTex)) * UNITY_ACCESS_INSTANCED_PROP(Props, _MainColor);
                #endif
                
                //圆
                #ifdef CIRCLE_ON
                float2 circleUV = (i.uv - 0.5) * 2;
                float circleX =  length(circleUV); 
                float circleSpeed = _Time.y * _CircleSpeed;
                i.uv.xy = float2(circleX + circleSpeed, circleX + circleSpeed);
                #endif

                mainColor = tex2D(_MainTex,TRANSFORM_TEX(i.uv,_MainTex)) * UNITY_ACCESS_INSTANCED_PROP(Props, _MainColor);
                
                 //**扭曲**
                float2 offsetUV = float2(0.0,0.0);
				        #ifdef DISTORT2_ON
                float2 disTexUV= float2( frac(_Time.y * _DistortionSpeed),frac(_Time.y * _DistortionSpeed));
                float4 disTex = tex2D(_DistortionMap, TRANSFORM_TEX(i.uv+disTexUV, _DistortionMap));
                offsetUV = -1 * (disTex * _DistortionPower - (_DistortionPower * 0.5)) - float2(0,0);
                mainColor = tex2D(_MainTex, TRANSFORM_TEX(i.uv + offsetUV, _MainTex)) * UNITY_ACCESS_INSTANCED_PROP(Props, _MainColor);
                #endif

                //弯曲
                #ifdef BENDING_ON
                float4 _bendingTexColor = tex2D(_BendingTex,TRANSFORM_TEX(i.uv,_BendingTex));
                float bendingX = lerp(_bendingTexColor.r,i.uv.x,i.uv2.x);
                float bendingY = lerp(_bendingTexColor.g,i.uv.y,i.uv2.y);
                mainColor = tex2D(_MainTex,TRANSFORM_TEX(float2(bendingX,bendingY),_MainTex));
                #endif

                //**细节**
                #ifdef DETAIL_ON
				        float2 detailUV = i.detail.xy + offsetUV;
				        fixed4 detailTexColor = tex2D(_DetailTex,TRANSFORM_TEX(detailUV,_DetailTex)); 
				        fixed3 colorLerp = lerp(mainColor.rgb, detailTexColor.rgb, _DetailChoiceRGB); 
				        fixed detailAlpha = detailTexColor.a * _DetailTexStrength; 
				        fixed alphaStrength = mainColor.a * _MainTexStrength; 
                        fixed alphaLerp = lerp(alphaStrength + detailAlpha, alphaStrength * detailAlpha, _DetailAddorMultiply); 
				        mainColor = float4(colorLerp,alphaLerp) * UNITY_ACCESS_INSTANCED_PROP(Props, _MainColor);
                #endif
                
                //**遮罩**
                #ifdef MASK_ON
                fixed4 maskColor = tex2D(_MaskTex,TRANSFORM_TEX(i.originalUV,_MaskTex));
                mainColor *= maskColor.r;
                #endif
				
                //**菲涅尔**
                #ifdef FRESNEL_ON
                mainColor = lerp(mainColor, _FresnelColor, 1 - i.fresnel);
                #endif

                //**HSV色彩空间**
                //(RGB -> HSV -> Operation -> HSV -> RGB)
                #ifdef HSV_ON
                float4 k = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp(
                    float4(mainColor.bg, k.wz),
                    float4(mainColor.gb, k.xy), 
                step(mainColor.b, mainColor.g));
                   float4 q = lerp(
                    float4(p.xyw, mainColor.r), 
                    float4(mainColor.r, p.yzx), 
                step(p.x, mainColor.r));
                    float d = q.x - min(q.w, q.y);
                    float e = 1.0e-10;
                    float3 hsvValue1 = float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);

                mainColor.rgb = (i.vertexColor.rgb * i.vertexColor.a * (lerp(float3(1, 1, 1),
                saturate(3.0 * abs(1.0 - 2.0 * frac((_Hue + hsvValue1.r) + float3(0.0, -1.0 / 3.0, 1.0 / 3.0))) - 1),
                (hsvValue1.g + _Sat)) * (hsvValue1.b + _Val)));  
                #endif

                
                
                //**溶解**
                #ifdef DISSIPATE_ON
                 float2 moveDissolveTex = float2(_Time.y * _DissolveTexOffsetSpeedZ,_Time.y * _DissolveTexOffsetSpeedW);
                 float2 DissolveTexUV = i.originalUV * _DissolveTex_ST.xy + moveDissolveTex;

                 float4 _DissolveTexColor = tex2D(_DissolveTex,TRANSFORM_TEX(DissolveTexUV,_DissolveTex));
                 float value = _DissolveTimeOnOff * _DissolveProgress + _DissolveT1OnOff * i.uv1.x;
                 mainColor = fixed4(mainColor.rgb,(mainColor.a * i.vertexColor.a * smoothstep( 0.0, _DissolveEdge, (_DissolveTexColor.r + ( value * -1.0)))));
                #endif

                
                //**Alpha强度**
                mainColor.a = min(1,(mainColor.a * UNITY_ACCESS_INSTANCED_PROP(Props, _Alpha)));

                //**顶点动画**
                #ifdef VERTEX_ANIMATION
                 i.normaldir = normalize(i.normaldir);
                float3 normalDirection = i.normaldir;
                #endif

                //**顶点色接入**
				        mainColor = mainColor * i.vertexColor;
			
                //**剪裁**
                #ifdef UIMASKCLIP_ON
                uint clipThreshold;
                clipThreshold = UnityGet2DClipping(i.vpos.xy, _ClipRect);
                clip(clipThreshold - 0.5);
                #endif

                //加入系统剪裁
                #ifdef UNITY_UI_CLIP_RECT
					mainColor.a *= UnityGet2DClipping(i.vpos.xy, _ClipRect);
				#endif

                #ifdef UNITY_UI_ALPHACLIP
					clip(mainColor.a - 0.001);
				#endif

                return mainColor;
            }
            ENDCG
        }
    }
    CustomEditor "SuperFXInspector"
}
