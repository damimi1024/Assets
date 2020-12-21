using System;
using System.Collections.Generic;
using UObject = UnityEngine.Object;

public enum RefMode
{
    strong,
    weak,
}

internal class CacheAsset : IPoolRecycleItem
{
    /// <summary>
    /// 强引用计数
    /// </summary>
    private int strongRefCount;
    /// <summary>
    /// 弱引用绑定目标
    /// </summary>
    private Dictionary<int, WeakReference> weakRefTargets;
    /// <summary>
    /// 引用模式
    /// </summary>
    private RefMode refrenceMode;
    /// <summary>
    /// 主资源
    /// </summary>
    private UObject mainAsset;


    //子资源 get set

    //是否还在使用
    public bool IsAlive() {
        return false;
    }


    //强引用记录引用计数
    //弱引用记录绑定目标

    public void OnRecycled()
    {
    }
}
