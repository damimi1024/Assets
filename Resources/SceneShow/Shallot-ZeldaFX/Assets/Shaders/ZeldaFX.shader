// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:True,fgod:False,fgor:False,fgmd:0,fgcr:0,fgcg:0,fgcb:0,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:4795,x:32724,y:32693,varname:node_4795,prsc:2|emission-1128-OUT;n:type:ShaderForge.SFN_Tex2d,id:6074,x:32069,y:32372,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:_MainTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:2393,x:32381,y:32687,varname:node_2393,prsc:2|A-6074-RGB,B-2053-RGB,C-797-RGB,D-3744-OUT;n:type:ShaderForge.SFN_VertexColor,id:2053,x:32152,y:32564,varname:node_2053,prsc:2;n:type:ShaderForge.SFN_Color,id:797,x:32069,y:32196,ptovrint:True,ptlb:MainColor,ptin:_TintColor,varname:_TintColor,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Tex2d,id:9449,x:31586,y:32499,ptovrint:False,ptlb:AnimTex,ptin:_AnimTex,varname:node_9449,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-1399-OUT;n:type:ShaderForge.SFN_Tex2d,id:111,x:31586,y:32925,ptovrint:False,ptlb:Mask,ptin:_Mask,varname:node_111,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Color,id:9906,x:31586,y:32714,ptovrint:False,ptlb:AnimColorTex,ptin:_AnimColorTex,varname:node_9906,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:8755,x:31900,y:32671,varname:node_8755,prsc:2|A-9449-RGB,B-9906-RGB;n:type:ShaderForge.SFN_Slider,id:403,x:31523,y:33144,ptovrint:False,ptlb:MaskIntensity,ptin:_MaskIntensity,varname:node_403,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Multiply,id:6035,x:31885,y:32976,varname:node_6035,prsc:2|A-111-RGB,B-403-OUT;n:type:ShaderForge.SFN_Multiply,id:3189,x:32394,y:32896,varname:node_3189,prsc:2|A-8755-OUT,B-6035-OUT,C-3744-OUT;n:type:ShaderForge.SFN_TexCoord,id:6631,x:30833,y:32397,varname:node_6631,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Time,id:280,x:30628,y:32918,varname:node_280,prsc:2;n:type:ShaderForge.SFN_Vector4Property,id:5649,x:30607,y:32657,ptovrint:False,ptlb:Speed,ptin:_Speed,varname:node_5649,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0,v2:0,v3:0,v4:0;n:type:ShaderForge.SFN_Multiply,id:9728,x:30859,y:32716,varname:node_9728,prsc:2|A-5649-X,B-280-T;n:type:ShaderForge.SFN_Multiply,id:7856,x:30846,y:32936,varname:node_7856,prsc:2|A-5649-Y,B-280-T;n:type:ShaderForge.SFN_Add,id:8971,x:31120,y:32438,varname:node_8971,prsc:2|A-6631-U,B-9728-OUT;n:type:ShaderForge.SFN_Add,id:8866,x:31120,y:32556,varname:node_8866,prsc:2|A-6631-V,B-7856-OUT;n:type:ShaderForge.SFN_Append,id:1399,x:31341,y:32499,varname:node_1399,prsc:2|A-8971-OUT,B-8866-OUT;n:type:ShaderForge.SFN_ValueProperty,id:3744,x:32124,y:32772,ptovrint:False,ptlb:HDR,ptin:_HDR,varname:node_3744,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Add,id:1128,x:32523,y:32811,varname:node_1128,prsc:2|A-2393-OUT,B-3189-OUT;proporder:797-6074-9906-9449-111-3744-403-5649;pass:END;sub:END;*/

Shader "Custom/ZeldaFX" {
    Properties {
        _TintColor ("MainColor", Color) = (0.5,0.5,0.5,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _AnimColorTex ("AnimColorTex", Color) = (0.5,0.5,0.5,1)
        _AnimTex ("AnimTex", 2D) = "white" {}
        _Mask ("Mask", 2D) = "white" {}
        _HDR ("HDR", Float ) = 1
        _MaskIntensity ("MaskIntensity", Range(0, 1)) = 0
        _Speed ("Speed", Vector) = (0,0,0,0)
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _TintColor;
            uniform sampler2D _AnimTex; uniform float4 _AnimTex_ST;
            uniform sampler2D _Mask; uniform float4 _Mask_ST;
            uniform float4 _AnimColorTex;
            uniform float _MaskIntensity;
            uniform float4 _Speed;
            uniform float _HDR;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
////// Emissive:
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float4 node_280 = _Time;
                float2 node_1399 = float2((i.uv0.r+(_Speed.r*node_280.g)),(i.uv0.g+(_Speed.g*node_280.g)));
                float4 _AnimTex_var = tex2D(_AnimTex,TRANSFORM_TEX(node_1399, _AnimTex));
                float4 _Mask_var = tex2D(_Mask,TRANSFORM_TEX(i.uv0, _Mask));
                float3 emissive = ((_MainTex_var.rgb*_TintColor.rgb*_HDR)+((_AnimTex_var.rgb*_AnimColorTex.rgb)*(_Mask_var.rgb*_MaskIntensity)*_HDR));
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
