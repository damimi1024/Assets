// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/test1" {
	Properties{
		_MainColor("MainColor",color)=(1,1,1,1)
	}
	SubShader {
		Pass
		{
			// CGPROGRAM
			// #pragma vertex vert
			// #pragma fragment frag
			// //#include "sbin/sbin.cginc"
		
			// float4 _MainColor;
			// uniform float4 _SecondColor;
			// // float Func2(float arr[2]){
			// // 	float sum=0;
			// // 	for(int i=0;i<arr.Length;i++){
			// // 		sum+=arr[i];
			// // 	}
			// // 	return sum;
			// // }
			// struct v2f{
			// 	float4 pos:POSITION;
			// };
			// v2f vert(appdata_base)
			// {
				
			// 	v2f o;
			// 	o.pos=UnityObjectToClipPos(v.vertex);
			// 	return o;
			// }

			// // void Func(out float4 c);
			// fixed4 frag():COlOR
			// {
			// 	//col=float4(0,1,0,1);
			// 	 //Func(col);
			// 	 //c.x= Func2(arr);
			// 	 //float arr[]={0.1,0.1};
			// 	 return (1,1,1,1);
			// }

			// ENDCG
		}
	}
}
