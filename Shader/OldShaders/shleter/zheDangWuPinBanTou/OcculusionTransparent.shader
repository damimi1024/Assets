/*
Shader "ApcShader/OcclusionTransparent" {
    Properties {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        
        ZWrite Off
 
        CGPROGRAM
        #pragma surface surf Lambert alpha
 
        sampler2D _MainTex;
        fixed4 _Color;
 
        struct Input {
            float2 uv_MainTex;
        };
 
        void surf (Input IN, inout SurfaceOutput o) {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    } 
    FallBack "VertexLit"
}

上面这个半透会出现一个情况就是物体内部一些我们不想看到的东西也会显示

因为我们为了保证渲染的正确性，一般是有两种方法保证渲染的正确性。一种是Z Buffer算法，也是我们现在渲染最常用的一种
。比如我们渲染一个物体的一个像素，首先要进行Z Test（深度测试），如果深度测试不通过，那么它本身就没有必要在这个像素进行渲染了。
而Z Write（深度写入）则是在上面的深度测试通过之后，更新该像素深度值的一个操作。半透渲染深度测试也是有效的，比如一个半透物体如果在一个不透明的物体之后，深度测试失败，
那么就没有必要再进行混合操作了，但是半透渲染没有办法开启深度写入，因为半透需要Blend，需要原缓冲区的颜色与当前fragment的颜色进行混合，如果前后两个物体同时开启了深度写入，
那么前面那个就会挡住后面那个。不过这种情况在Unity里面我们并没有看到，其实是因为Unity对半透明物体采用了另一种算法，也就是画家算法，所谓画家算法就是先画后面的，再画前面的。
Unity会对同一个渲染队列的半透物体进行排序，然后再按照远近顺序进行渲染。这样基本就可以保证Blend的正确性。

虽然说一般我们不会开启半透物体的深度写入，但是这样就会出现上图的问题。比如我们想渲染一个人，不透明渲染的话，从左边看，我们只会看到人的左手边，但是如果用了半透渲染，
我们就会在看到人的左手的同时看到右手，这肯定效果很奇怪。有一种解决办法，就是我们可以进行一次Z PrePass操作，用两个pass渲染遮挡物体，先用一个不写入颜色，
只写入深度的pass渲染一遍，这样这个位置就已经写入了深度；第二个pass进行正常的渲染，离我们近的面深度测试成功，会正常渲染，但是远离我们的面深度测试失败，就不会渲染了。
把上面的shader加工一下，增加一个Prepass：
*/
Shader "ApcShader/OcclusionTransparent" {
    Properties {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent-1"}
        Pass
		{
			ZWrite On 	//开启深度写入
			ColorMask 0	//不写颜色
		}	
        ZWrite Off
 
        CGPROGRAM
        #pragma surface surf Lambert alpha
 
        sampler2D _MainTex;
        fixed4 _Color;
 
        struct Input {
            float2 uv_MainTex;
        };
 
        void surf (Input IN, inout SurfaceOutput o) {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    } 
    FallBack "VertexLit"
}
