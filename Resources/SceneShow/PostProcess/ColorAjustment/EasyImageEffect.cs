using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode()]//非运行时执行
public class EasyImageEffect : MonoBehaviour
{
    public Material material;
    // Start is called before the first frame update
    void Start()
    {
        if (material == null || material.shader == null || material.shader.isSupported == false)
        {
            enabled = false;
            return;
        }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="source">帧缓冲数据传入</param>
    /// <param name="destination">后处理完毕后输出图像</param>
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, material,0);
    }
}
