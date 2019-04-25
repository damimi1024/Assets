using System.Collections;
using System.Collections.Generic;
using UnityEngine;



[ExecuteInEditMode]
public class simpleBlur : PostEffectBase
{
    //一次模糊我们感觉效果不是很尽人意，那么，我们可以尝试迭代模糊，也就是用上一次模糊的输出作为下一次模糊的输入，迭代之后的模糊效果更加明显。
    //先看一下代码，这次，我们的shader代码和上面的一样，没有变动，仅仅是修改了脚本，增加了降分辨率和迭代的两个操作。


    //模糊半径
    public float BlurRadius = 1.0f;
    //降分辨率
    public int downSample = 2;
    //迭代次数
    public int iteration = 3;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_Material)
        {

            //blur 
            //_Material.SetFloat("radius", BlurRadius);
            //Graphics.Blit(source, destination, _Material);


            //申请RenderTexture，RT的分辨率按照downSample降低
            RenderTexture rt1 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);
            RenderTexture rt2 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);

            Graphics.Blit(source,rt1);

            //进行迭代，一次迭代进行了两次模糊操作，使用两张RT交叉处理
            for (int i = 0; i < iteration; i++)
            {
                //用降过分辨率的RT进行模糊处理
                _Material.SetFloat("radius", BlurRadius);
                Graphics.Blit(rt1, rt2, _Material);
                Graphics.Blit(rt2, rt1, _Material);
            }

            //将结果拷贝到目标RT
            Graphics.Blit(rt1, destination);

            //释放申请的两块RenderBuffer内容
            RenderTexture.ReleaseTemporary(rt1);
            RenderTexture.ReleaseTemporary(rt2);

        }
    }

}
