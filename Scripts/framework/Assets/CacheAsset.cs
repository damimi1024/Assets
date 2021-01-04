using System;
using System.Collections.Generic;
using UObject = UnityEngine.Object;

public enum RefMode
{
    strong,
    weak,
}

public class CacheAsset : IPoolRecycleItem
{

    #region variables
    /// <summary>
    /// 强引用计数
    /// </summary>
    private int strongRefCount;
    /// <summary>
    /// 弱引用自增数
    /// </summary>
    private int weakRefIndex;
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
    /// <summary>
    /// 主资源弱引用
    /// </summary>
    private WeakReference<UObject> mainAssetWeakRef;
    /// <summary>
    /// 子资源
    /// </summary>
    public Dictionary<string,WeakReference<UObject> > subAssets = new Dictionary<string, WeakReference<UObject>>();
    /// <summary>
    /// 资源加载器
    /// </summary>
    public AssetLoader loader;

    private WeakReferencePool<UObject> weakRefPool = new WeakReferencePool<UObject>();
    private WeakReferencePool weakRefobjPool = new WeakReferencePool();
    private DictionaryPool<string, WeakReference<UObject>> weakRefDicPool = new DictionaryPool<string, WeakReference<UObject>>(20);
    private DictionaryPool<int, WeakReference> weakRefTargetPool = new DictionaryPool<int, WeakReference>(20);
    #endregion

    public void OnRecycled()
    {
        strongRefCount = 0;
        weakRefIndex = 0;
        mainAsset = null;
        if (mainAssetWeakRef != null)
        {
            weakRefPool.Recycle(mainAssetWeakRef);
            mainAssetWeakRef = null;
        }
        if (subAssets != null)
        {
            foreach (var item in subAssets)
            {
                weakRefPool.Recycle(item.Value);

            }
        }
        subAssets.Clear();
        weakRefTargets.Clear();
    }
    #region properties
    public UObject MainAsset
    {
        get
        {
            if (refrenceMode == RefMode.strong)
            {
                return mainAsset;
            }
            else
            {
                mainAssetWeakRef.TryGetTarget(out var target);
                return target;
            }
        }
        set
        {
            if (refrenceMode == RefMode.strong)
            {
                mainAsset = value;
            }
            else
            {
                mainAssetWeakRef.SetTarget(value);
            }
        }
    }

    //是否还在使用
    public bool IsAlive()
    {
        if(refrenceMode == RefMode.strong)
        {
            return strongRefCount <= 0;
        }
        else
        {
            return weakRefTargets.Count <= 0;
        }
    }


    #endregion


    #region public methods

    public bool SetSubAsset(UObject[] subAsset)
    {
        Dictionary<string, WeakReference<UObject>> map;
        if (subAssets == null)
        {
            subAssets = map = weakRefDicPool.Spawn();
        }
        else
        {
            map = subAssets;
            map.Clear();
        }
        var length = subAsset.Length;
        int i = length == 1 ? 0 : 1;
        for (; i < length; i++)
        {
            map.Add(subAsset[i].name, weakRefPool.Spawn(subAsset[i]));
        }
        return true;
    }

    public bool GetSubAsset(string subAssetPath,out UObject subAsset)
    {
        if (subAssets==null)
        {
            subAsset = null;
            return false;
        }
        WeakReference<UObject> subAssetWkRef;
        subAssets.TryGetValue(subAssetPath, out subAssetWkRef);
        subAssetWkRef.TryGetTarget(out subAsset);
        return subAsset != null;
    }

    public bool GetSubAsset(out UObject[] subAsset)
    {
        if (subAssets == null)
        {
            subAsset = null;
            return false;
        }
        else
        {
            int index = 0;
            subAsset = new UObject[subAssets.Count];
            foreach (var item in subAssets)
            {
                UObject target;
                item.Value.TryGetTarget(out target);
                if (target == null)
                {
                    subAsset = null;
                    return false;
                }
                subAsset[index] = target;
                index++;
            }
            return true;
        }
    }

    public int BindReference(bool strongRef,object bindTarget)
    {
        if (strongRef)
        {
            refrenceMode = RefMode.strong;
            strongRefCount++;
            return 0;
        }
        else
        {
            refrenceMode = RefMode.weak;
            weakRefTargets.Add(weakRefIndex++, weakRefobjPool.Spawn(bindTarget));
            return weakRefIndex;
        }
    }
    
    public void UnBindReference(int bindid)
    {
        if (refrenceMode == RefMode.strong)
        {
            strongRefCount--;
        }
        else
        {
            weakRefTargets.Remove(bindid);
        }
    }

    #endregion

}
