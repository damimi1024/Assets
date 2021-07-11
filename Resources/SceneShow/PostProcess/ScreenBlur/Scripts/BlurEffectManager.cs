using System;
using UnityEngine;
public class BlurEffectManager : MonoBehaviour
{
    private static BlurEffectManager _instance;
    public static BlurEffectManager Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = FindObjectOfType(typeof(BlurEffectManager)) as BlurEffectManager;
            }
            return _instance;
        }
    }
    // 获取模糊脚本
    public ScreenBlur ui_blur_effect;
    void Awake()
    {
        if (ui_blur_effect == null)
        {
            ui_blur_effect = GameObject.Find("UICamera").GetComponent<ScreenBlur>();
        }
    }

    // 提供模糊截屏
    public void EnableBlurScreenshot(BlurData data = null, Action<RenderTexture> callback = null)
    {
        ui_blur_effect.EnableBlurRender(data, callback);
    }

    public void DisabledBlurCameraEffect()
    {
        ui_blur_effect.DisabledBlurRender();
    }
}