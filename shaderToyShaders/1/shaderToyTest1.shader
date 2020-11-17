// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/shaderToyTest1"
{
   Properties{
        iMouse ("Mouse Pos", Vector) = (100, 100, 0, 0)
        iChannel0("iChannel0", 2D) = "white" {}  
        iChannelResolution0 ("iChannelResolution0", Vector) = (100, 100, 0, 0)
    }

    CGINCLUDE    
    #include "UnityCG.cginc"   
    #pragma target 3.0      

    #define vec2 float2
    #define vec3 float3
    #define vec4 float4
    #define mat2 float2x2
    #define mat3 float3x3
    #define mat4 float4x4
    #define iGlobalTime _Time.y
    #define mod fmod
    #define mix lerp
    #define fract frac
    #define texture2D tex2D
    #define iResolution _ScreenParams
    #define gl_FragCoord ((_iParam.scrPos.xy/_iParam.scrPos.w) * _ScreenParams.xy)

    #define PI2 6.28318530718
    #define pi 3.14159265358979
    #define halfpi (pi * 0.5)
    #define oneoverpi (1.0 / pi)

    fixed4 iMouse;
    sampler2D iChannel0;
    fixed4 iChannelResolution0;

  



    struct v2f {    
        float4 pos : SV_POSITION;    
        float4 scrPos : TEXCOORD0;   
    };              

    v2f vert(appdata_base v) {  
        v2f o;
        o.pos = UnityObjectToClipPos (v.vertex);
        o.scrPos = ComputeScreenPos(o.pos);
        return o;
    }  

    vec4 main(vec2 fragCoord);

    fixed4 frag(v2f _iParam) : COLOR0 { 
        vec2 fragCoord = gl_FragCoord;
        return main(fragCoord);
    }  




    ENDCG    

    SubShader {    
        Pass {    
            CGPROGRAM    

            #pragma vertex vert    
            #pragma fragment frag    
            #pragma fragmentoption ARB_precision_hint_fastest     
    float4 rotate(float a) {
        float c = cos(a), s = sin(a);
         return float4(c, s, -s, c);
    }
    float box(vec3 p, vec3 s) {
        vec3 d = abs(p) - s;
        return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
    }
    float ifsBox(vec3 p) {
        for (int i=0; i<4; i++) {
            p = abs(p) - 1.0;
            float a = 0.05+0.12*sin(1.6*_Time.y);
            p.xy *= rotate(a);
            p.xz *= rotate(a);
        }
        vec3 scale = vec3(0.5, 0.5, 0.5);
        return box(p, scale);
    }
    float map(vec3 p) {
        p.xy *= rotate(0.12*sin(_Time.y));
        p.xz *= rotate(pi*0.5 + 0.16*sin(0.7*_Time.y));
        return ifsBox(p);
    }
    vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d ) {
        return a + b*cos( 6.28318*(c*t+d) );
    }

    vec4 main(vec2 fragCoord) {
        vec2 p = (fragCoord.xy * 2.0 - iResolution.xy) / min(iResolution.x, iResolution.y);

    vec3 cPos = vec3(0, 0, 12);
    vec3 ray = normalize(vec3(p.xy, -1));

    float depth = 0.0;
    float d = 0.0;
    vec3 pos = vec3(0,0,0);
    vec3 colAcc = vec3(0,0,0);
    for (int i=0; i<99; i++) {
        pos = cPos + ray * depth;
        d = map(pos);
        if (d < 0.0001 || pos.z > 50.0) break;
        colAcc += exp(-d*2.0) * pal(length(pos)*0.2, vec3(0.5,0.5,0.5),vec3(0.5,0.2,0.2),vec3(1.0,1.0,1.0),vec3(0.0,0.3,0.4) );
        // colAcc += exp(-d*2.0) * pal(length(pos)*0.2, vec3(0.5,0.5,0.8),vec3(0.5,0.2,0.2),vec3(1.0,1.0,1.0),vec3(0.0,0.3,0.5) );
        depth += d*0.2;
    }

    vec3 col = colAcc * 0.03;
    return  vec4(col,0.5f);
    }
            ENDCG    
        }    
    }     
    FallBack Off   
}
