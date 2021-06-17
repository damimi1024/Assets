// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Green" {  
    SubShader {  
        Tags { "RenderType"="Opaque" "Queue"="Geometry+1"}  //渲染次序为Geometry+1，在红球之后  
        Pass {  
            Stencil {  
                Ref 2                 //参考值为2  
                Comp equal            //stencil比较方式是相同，只有等于2的才能通过  
                Pass keep           //stencil和Zbuffer都测试通过时，选择保持  
                Fail decrWrap        //stencil没通过，选择溢出型减1，所以被平面挡住的那层stencil值就变成254  
                ZFail keep           //stencil通过，深度测试没通过时，选择保持  
            }  

            CGPROGRAM  
            #pragma vertex vert  
            #pragma fragment frag  
            struct appdata {  
                float4 vertex : POSITION;  
            };  
            struct v2f {  
                float4 pos : SV_POSITION;  
            };  
            v2f vert(appdata v) {  
                v2f o;  
                o.pos = UnityObjectToClipPos(v.vertex);  
                return o;  
            }  
            half4 frag(v2f i) : SV_Target {  
                return half4(0,1,0,1);  
            }  
            ENDCG  
        }  
    }
}  