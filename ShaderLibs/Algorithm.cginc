#ifndef YangAlgorithm
#define YangAlgorithm


//flowmap为了解决跳变的效果，采用的解决方案是采样两次，然后在这两次采样之间做一个插值，然后做一个插值；
//注意插值系数也是要动态改变的，而且插值系数采用了绝对值的计算，也就是它是循环的（从0到1，再从1到0，而不会从1跳变到0）
//计算flowmap
//flowspeed 流动速度
//flowIntensity 流动强度
//maintex 采样主贴图
//flowmap 采样flowmap贴图
//maintexUV 采样主贴图的UV
//flowmapUV 采样flowmap贴图的UV
half4 FlowMapFunction(float flowspeed, float2 flowIntensity, sampler2D maintex, sampler2D flowmap, float2 maintexUV, float2 flowmapUV)
{
	//先算个时间
	float2 timeDelta = frac(_Time.y * flowspeed) * flowIntensity;
	//再算个间隔帧时间
	float2 timeNext = frac(_Time.y * flowspeed + 0.5) * flowIntensity;
	//再算个两个时间插值的插值因子
	float timeLerp = abs(frac(_Time.y * flowspeed) * 2 - 1);
	//采样flowmap 当做干扰方向
	half2 flowDirection = (0.5 - tex2D(flowmap, flowmapUV).rg);
	//前一状态的流动效果
	half2 flowMap = flowDirection * timeDelta;
	half4 mainTexpre = tex2D(maintex, maintexUV + flowMap);
	//后一状态的流动效果
	half2 flowMapNext = flowDirection * timeNext;
	half4 mainTex = tex2D(maintex, maintexUV + flowMapNext);
	//插值两个流动效果 减少顿挫感
	half4 col = lerp(mainTexpre, mainTex, timeLerp);
	//输出最终效果
	return col;
}
#endif