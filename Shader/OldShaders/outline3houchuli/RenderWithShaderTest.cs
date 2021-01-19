using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//后处理描边效果
//用后处理进行描边的原理，就是把物体的轮廓渲染到一张RenderTexture上，然后把RT按照某种方式再贴回原始场景图。
//首先，我们可以渲染一个物体到RT上，可以通过RenderCommond进行处理用一个额外的摄像机：通过增加一个和Main Camera一样的摄像机，
//通过设置摄像机的LayerMask，将要渲染的对象设置到这个层中，然后将摄像机的Render Target设置
//为我们设定好的一张Render Texture上，就实现了渲染到RT上的部分，而这张RT由于我们需要在后处理的时候使用，所以我们在之前获得这张RT，Unity为我们提供了
//一个 OnPreRender函数，这个函数是在渲染之前的回调，我们就可以在这个地方完成RT的渲染。但是还有一个问题，就是我们默认的shader是模型自身设置的shader，
//而不是纯色的shader，我们要怎么临时换成一个纯色的shader呢？其实Unity也为我们准备好了一个函数：Camera.RenderWithShader，可以让摄像机的本次渲染采用
//我们设置的shader，这个函数接受两个参数，第一个是需要用的shader，第二个是一个字符串，还记得shader里面经常写的RenderType吗，其实主要就是为了
//RenderWithShader服务的，如果我们没给RenderType，那么摄像机需要渲染的所有物体都会被替换shader渲染，如果我们给了RenderType，Unity就会去对比目前
//使用的shader中的RenderType，有的话才去渲染，不匹配的不会被替换shader渲染

//下一步，为了让轮廓出现，我们需通过模糊效果，就可以让轮廓图胖一些，所谓模糊，就是让当前像素的颜色值从当前像素以及像素周围的几个采样点按照加权平均
//重新计算，人边缘部分的颜色肯定会和周围的黑色平均，导致颜色溢出，进而达到发胖的效果。

//最后，再把这张RT和我们正常渲染的场景图进行结合，就可以得到基于后处理的描边效果了。最后的结合方式有很多种，最简单的方式是直接叠加，为了更清晰，此处把每个步骤拆成单独的Pass实现了。

public class RenderWithShaderTest : PostEffectBase
{
    private Camera mainCam = null;
    private Camera additionalCam = null;
    private RenderTexture renderTexture = null;

    public Shader outlineShader = null;
    //采样率
    public float samplerScale = 1;
    public int downSample = 1;
    public int iteration = 2;

    private void Awake()
    {
        InitAdditionCam();
    }

    private void InitAdditionCam()
    {
        //通过RenderCommond进行处理用一个额外的摄像机：通过增加一个和Main Camera一样的摄像机，
        mainCam = GetComponent<Camera>();
        if (mainCam == null) return;
        Transform addCamTransform = transform.Find("additionCam");
        if (addCamTransform != null)
        {
            DestroyImmediate(addCamTransform.gameObject);
        }
        GameObject additionlCamObj = new GameObject("additionalCam");
        additionalCam = additionlCamObj.AddComponent<Camera>();
        setAdditionalCam();
    }

    private void setAdditionalCam()
    {
        if (!additionalCam) return;
        additionalCam.transform.parent = mainCam.transform;
        additionalCam.transform.localPosition = Vector3.zero;
        additionalCam.transform.localRotation = Quaternion.identity;
        additionalCam.transform.localScale = Vector3.one;
        additionalCam.farClipPlane = mainCam.farClipPlane;
        additionalCam.nearClipPlane = mainCam.nearClipPlane;
        additionalCam.fieldOfView = mainCam.fieldOfView;
        additionalCam.backgroundColor = Color.clear;
        additionalCam.clearFlags = CameraClearFlags.Color;
        additionalCam.cullingMask = 1 << LayerMask.NameToLayer("Additional");
        additionalCam.depth = -999;
        if (renderTexture == null)
            renderTexture = RenderTexture.GetTemporary(additionalCam.pixelWidth >> downSample, additionalCam.pixelHeight >> downSample, 0);
    }
    void OnEnable()
    {
        setAdditionalCam();
        additionalCam.enabled = true;
    }

    void OnDisable()
    {
        if(additionalCam!=null)
            additionalCam.enabled = false;
    }

    void OnDestroy()
    {
        DestroyImmediate(additionalCam.gameObject);
        if (renderTexture)
        {
            RenderTexture.ReleaseTemporary(renderTexture);
        }
    }

    private void OnPreRender()
    {
        //使用OutlinePrepass进行渲染，得到RT
        if (additionalCam.enabled)
        {
            //渲染到RT上
            //首先检查是否需要重设RT，比如屏幕分辨率变化了
            if (renderTexture != null && (renderTexture.width != Screen.width >> downSample || renderTexture.height != Screen.height >> downSample))
            {
                RenderTexture.ReleaseTemporary(renderTexture);
                renderTexture = RenderTexture.GetTemporary(Screen.width >> downSample, Screen.height >> downSample, 0);
            }
            additionalCam.targetTexture = renderTexture;
            additionalCam.RenderWithShader(outlineShader, "");
        }
    }
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_Material && renderTexture)
        {
            //renderTexture.width = 111;
            //对RT进行Blur处理
            RenderTexture temp1 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0);
            RenderTexture temp2 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0);

            //高斯模糊，两次模糊，横向纵向，使用pass0进行高斯模糊
            _Material.SetVector("_offsets", new Vector4(0, samplerScale, 0, 0));
            Graphics.Blit(renderTexture, temp1, _Material, 0);
            _Material.SetVector("_offsets", new Vector4(samplerScale, 0, 0, 0));
            Graphics.Blit(temp1, temp2, _Material, 0);

            //如果有叠加再进行迭代模糊处理
            for (int i = 0; i < iteration; i++)
            {
                _Material.SetVector("_offsets", new Vector4(0, samplerScale, 0, 0));
                Graphics.Blit(temp2, temp1, _Material, 0);
                _Material.SetVector("_offsets", new Vector4(samplerScale, 0, 0, 0));
                Graphics.Blit(temp1, temp2, _Material, 0);
            }

            //用模糊图和原始图计算出轮廓图
            _Material.SetTexture("_BlurTex", temp2);
            Graphics.Blit(renderTexture, temp1, _Material, 1);

            //轮廓图和场景图叠加
            _Material.SetTexture("_BlurTex", temp1);
            Graphics.Blit(source, destination, _Material, 2);

            RenderTexture.ReleaseTemporary(temp1);
            RenderTexture.ReleaseTemporary(temp2);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
    
}
