#ifndef SG2_Card
#define SG2_Card

#define HASHSCALE1 .1031
#define HASHSCALE3 float3(.1031, .1030, .0973)
#define xTime (_Time.x)
#define yTime (_Time.y)
#define _Deg2Rad 0.01745329
#define _AllAngle 360.0 
#define _OneHalf2 float2(0.5,0.5)

float2 OffsetFactor(fixed zspeed,fixed wspeed)
{
    return float2(yTime * zspeed , yTime * wspeed);
}

fixed2 Rota22(float2 uvxy,fixed rote){
                fixed cosMain = cos(_Deg2Rad * rote * _AllAngle);
                fixed sinMain = sin(_Deg2Rad * rote * _AllAngle);
                return mul(uvxy - _OneHalf2, fixed2x2(cosMain,  -sinMain, sinMain, cosMain)) + _OneHalf2;
}

float Hash11(float p)
{
	float3 p3  = frac(p.xxx * HASHSCALE1);
    p3 += dot(p3, p3.yzx + 19.19);
    return frac((p3.x + p3.y) * p3.z); 
}

float2 Hash22(float2 p)
{
	float3 p3 = frac(float3(p.xyx) * HASHSCALE3);
    p3 += dot(p3, p3.yzx+19.19);
    return frac((p3.xx+p3.yz)*p3.zy);
}

#endif