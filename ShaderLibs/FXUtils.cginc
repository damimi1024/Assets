#ifndef SG2_FXUTILS
#define SG2_FXUTILS

#include "UnityCG.cginc"
#include "UnityUI.cginc"
#include "Const.cginc" 
#include "PostProcess.cginc"
#include "Math.cginc"
#include "Common.cginc"

float4 _MainColor;

fixed2 Rota22(float2 uvxy,fixed rote){
    fixed cosMain = cos(_Deg2Rad * rote * _AllAngle);
    fixed sinMain = sin(_Deg2Rad * rote * _AllAngle);
    return mul(uvxy - _OneHalf2, fixed2x2(cosMain,  -sinMain, sinMain, cosMain)) + _OneHalf2;
}

fixed2 MoveFactor22(fixed u,fixed v)
{
    fixed uvX = u * ftime;
    fixed uvY = v * ftime;
    return fixed2(uvX,uvY);
}

float4 HSVColor(float4 mainColor,float4 vertexColor,fixed hue,fixed saturation,fixed value)
{
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

                mainColor.rgb = (vertexColor.rgb * vertexColor.a * (lerp(float3(1, 1, 1),
                saturate(3.0 * abs(1.0 - 2.0 * frac((hue + hsvValue1.r) + float3(0.0, -1.0 / 3.0, 1.0 / 3.0))) - 1),
                (hsvValue1.g + saturation)) * (hsvValue1.b + value)));  
                return mainColor;
}

void OverlayMode(float4 Ca,float4 Cb,out float4 Cc)
{
     fixed4 value = step(Ca , fixed4(0.5, 0.5, 0.5 ,0.5));
      Cc = value * Ca * Cb * 2 + (1 - value) * (1 - (1 - Ca) * (1 - Cb) * 2);
}

#endif