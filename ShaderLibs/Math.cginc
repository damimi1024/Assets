
#ifndef SG2_MATH
#define SG2_MATH

#include "Const.cginc"
#include "Common.cginc"

#define clamp01(a) saturate(a)
#define length2 length //return sqrt( p.x*p.x + p.y*p.y );
float length6(float2 p)
{
	p = p * p * p; p = p * p;
	return pow(p.x + p.y, 1.0 / 6.0);
}
float length8(float2 p)
{
	p = p * p; p = p * p; p = p * p;
	return pow(p.x + p.y, 1.0 / 8.0);
}

//圆润渐变函数
float smin(float a, float b, float k)
{
	float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
	return lerp(b, a, h) - k * h * (1.0 - h);
}
#define _m2 (float2x2(0.8,-0.6,0.6,0.8))
#define _m3 (float3x3( 0.00,  0.80,  0.60, -0.80,  0.36, -0.48, -0.60, -0.48,  0.64 ))

float2x2 Rot2D(float a) { a *= _Rad2Deg; float sa = sin(a); float ca = cos(a); return float2x2(ca, -sa, sa, ca); }
float2x2 Rot2DRad(float a) { float sa = sin(a); float ca = cos(a); return float2x2(ca, -sa, sa, ca); }


float3x3 Rotx(float a) { a *= _Rad2Deg; float sa = sin(a); float ca = cos(a); return float3x3(1., .0, .0, .0, ca, sa, .0, -sa, ca); }
float3x3 Roty(float a) { a *= _Rad2Deg; float sa = sin(a); float ca = cos(a); return float3x3(ca, .0, sa, .0, 1., .0, -sa, .0, ca); }
float3x3 Rotz(float a) { a *= _Rad2Deg; float sa = sin(a); float ca = cos(a); return float3x3(ca, sa, .0, -sa, ca, .0, .0, .0, 1.); }

float3x3 RotEuler(float3 ang) {
	ang = ang * _Rad2Deg;
	float2 a1 = float2(sin(ang.x), cos(ang.x));
	float2 a2 = float2(sin(ang.y), cos(ang.y));
	float2 a3 = float2(sin(ang.z), cos(ang.z));
	float3x3 m;
	m[0] = float3(a1.y * a3.y + a1.x * a2.x * a3.x, a1.y * a2.x * a3.x + a3.y * a1.x, -a2.y * a3.x);
	m[1] = float3(-a2.y * a1.x, a1.y * a2.y, a2.x);
	m[2] = float3(a3.y * a1.x * a2.x + a1.y * a3.x, a1.x * a3.x - a1.y * a3.y * a2.x, a2.y * a3.y);
	return m;
}

float Remap(float oa, float ob, float na, float nb, float val) {
	return (val - oa) / (ob - oa) * (nb - na) + na;
}

fixed saturateSin(fixed speed, fixed frequency)
{
	return saturate(sin(ftime * speed) * frequency);
}

float2 OffsetFactor(fixed zspeed, fixed wspeed)
{
	return float2(ftime * zspeed, ftime * wspeed);
}

float3 RotateAround(float degree, float3 target)
{
	float rad = degree * UNITY_PI / 180;
	float2x2 m_rotate = float2x2(cos(rad), -sin(rad),
		sin(rad), cos(rad));
	float2 dir_rotate = mul(m_rotate, target.xz);
	target = float3(dir_rotate.x, target.y, dir_rotate.y);
	return target;
}
//ACES曲线 做色调映射使用
float3 ACESFilm(float3 x)
{
	float a = 2.51f;
	float b = 0.03f;
	float c = 2.43f;
	float d = 0.59f;
	float e = 0.14f;
	return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
}

float3 RGB2HSV(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float3 HSV2RGB(float3 c)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}
#endif 

