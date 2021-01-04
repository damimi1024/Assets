using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UObject = UnityEngine.Object;
using System.Threading.Tasks;


public static class Asseter
{
    private static bool initialized;

    public static List<AssetLoader> loaders = new List<AssetLoader>();
    /// <summary>
    /// 缓存字典
    /// </summary>
    public static Dictionary<string, CacheAsset> cacheAssets = new Dictionary<string, CacheAsset>(200);

    public static void Init()
    {
        if (initialized) { return; }
        initialized = true;
        
    }
    /// <summary>
    ///  添加loader
    /// </summary>
    /// <param name="loader"></param>
    public static void AddLoader(AssetLoader loader)
    {
        if (loader == null)
        {
            throw new Exception("传入的loader为空");
        }
        if (!loaders.Contains(loader))
        {
            loader.initialized = true;
            loader.Initialized();
            loaders.Add(loader);
        }
        //计时器 固定时间销毁无使用资源
    }

    public static void Relese()
    {
        if (!initialized)
        {
            return;
        }
        initialized = false;
        loaders.Clear();
    }
    #region  同步加载

    public static LoadResult LoadAsset(string AssetPath, bool strongRef = false)
    {
        SplitPath(AssetPath, out string mainPath, out string subName);
        return LoadAsset(mainPath, subName, strongRef);
    }

    public static LoadResult LoadAsset(string AssetPath, UObject bindTarget)
    {
        SplitPath(AssetPath, out string mainPath, out string subName);
        return LoadAsset(mainPath, subName, bindTarget);
    }

    public static LoadResult LoadAsset(string mainAssetPath, string subAssetName, bool strongRef = false)
    {
        return LoadAsset(mainAssetPath, subAssetName, typeof(UObject), strongRef, null);
    }

    public static LoadResult LoadAsset(string mainAssetPath, string subAssetName, UObject bindTarget)
    {
        return LoadAsset(mainAssetPath, subAssetName, typeof(UObject), false, bindTarget);
    }

    public static LoadResult LoadAsset(string mainAssetPath, string subAssetName, Type assetType, bool strongRef, UObject bindTarget)
    {
        bool loadMainAsset = string.IsNullOrEmpty(subAssetName);
        UObject resAsset = null;
        AssetLoader loader = null;
        bool loadFromLoader = false;
        bool loadSuccess = false;
        //从缓存中获取
        if(cacheAssets.TryGetValue(mainAssetPath,out var cacheAsset))
        {
            if (loadMainAsset)
            {
                if (cacheAsset.MainAsset != null)
                {
                    resAsset = cacheAsset.MainAsset;
                    loadSuccess = true;
                }
                else
                {
                    loader = cacheAsset.loader;
                    loadFromLoader = true;
                }
            }
            else
            {
                cacheAsset.GetSubAsset(subAssetName, out var subAsset);
                if (subAsset == null)
                {
                    loader = cacheAsset.loader;
                    loadFromLoader = true;
                }
                else
                {
                    loadSuccess = true;
                    resAsset = subAsset;
                }
            }
        }
        if (loadFromLoader)
        {
            if (loadMainAsset)
            {
                if (loader == null)
                {
                    for (int i = 0; i < loaders.Count; i++)
                    {
                        resAsset = loaders[i].LoadAsset(mainAssetPath, assetType);
                        if (resAsset != null)
                        {
                            loader = loaders[i];
                            break;
                        }
                    }
                }
                else
                {
                    resAsset = loader.LoadAsset(mainAssetPath, assetType);
                }
                if (resAsset == null)
                {
                    Debug.LogError("加载资源错误" + mainAssetPath);
                }
                if (cacheAsset == null)
                {
                    cacheAsset = new CacheAsset();
                    cacheAsset.loader = loader;
                    cacheAssets.Add(mainAssetPath, cacheAsset);
                }

                loadSuccess = true;
                cacheAsset.MainAsset = resAsset;
            }
            else
            {
                UObject[] res = null;
                if (loader == null)
                {
                    for (int i = 0; i < loaders.Count; i++)
                    {
                        res = loaders[i].LoadSubAssets(mainAssetPath);
                        if (res != null && res.Length>0)
                        {
                            loader = loaders[i];
                            break;
                        }
                    }
                }
                else
                {
                    res = loader.LoadSubAssets(mainAssetPath);
                }
                for (int i = 0; i < res.Length; i++)
                {
                    if (res[i].name == subAssetName)
                    {
                        resAsset = res[i];
                    }
                }
                if (resAsset == null)
                {
                    Debug.LogError("加载资源错误" + mainAssetPath+"  "+ subAssetName);
                }
                if (cacheAsset == null)
                {
                    cacheAsset = new CacheAsset();
                    cacheAsset.loader = loader;
                    cacheAssets.Add(mainAssetPath, cacheAsset);
                }

                loadSuccess = true;
                cacheAsset.MainAsset = res[0];
                cacheAsset.SetSubAsset(res);
            }
        }
        int bindId = 0;
        //绑定
        if (loadSuccess)
        {
            bindId = cacheAsset.BindReference(strongRef, bindTarget);
        }
        
        return new LoadResult(bindId, resAsset);

    }

    #endregion


    #region 异步加载
    public static void LoadResAsync(string assetPath, Action<LoadResult> callback, bool strongRef = false)
    {
        SplitPath(assetPath, out string mainPath, out string subpath);
        LoadResAsync(mainPath, subpath, callback, strongRef);

    }
    public static void LoadResAsync(string assetPath, Action<LoadResult> callback, UObject bindTarget)
    {
        SplitPath(assetPath, out string mainPath, out string subpath);
        LoadResAsync(mainPath, subpath, callback, bindTarget);
    }

    public static void LoadResAsync(string mainAssetPath, string subAssetName, Action<LoadResult> callback, bool strongRef = false)
    {
        LoadResAsync(mainAssetPath, subAssetName,typeof(UObject), callback, null, strongRef);
    }
    public static void LoadResAsync(string mainAssetPath, string subAssetName, Action<LoadResult> callback, UObject bindTarget)
    {
        LoadResAsync(mainAssetPath, subAssetName, typeof(UObject), callback, bindTarget, false);
    }

    public static void LoadResAsync(string mainAssetPath, string subAssetName,Type assetType, Action<LoadResult> callback, UObject bindTarget, bool strongRef = false)
    {
        bool loadMainAsset = string.IsNullOrEmpty(subAssetName);
        UObject resAsset = null;
        AssetLoader loader = null;
        bool loadFromLoader = false;
        bool loadSuccess = false;
        //从缓存中获取
        if (cacheAssets.TryGetValue(mainAssetPath, out var cacheAsset))
        {
            if (loadMainAsset)
            {
                if (cacheAsset.MainAsset != null)
                {
                    resAsset = cacheAsset.MainAsset;
                    loadSuccess = true;
                }
                else
                {
                    loader = cacheAsset.loader;
                    loadFromLoader = true;
                }
            }
            else
            {
                cacheAsset.GetSubAsset(subAssetName, out var subAsset);
                if (subAsset == null)
                {
                    loader = cacheAsset.loader;
                    loadFromLoader = true;
                }
                else
                {
                    loadSuccess = true;
                    resAsset = subAsset;
                }
            }
        }
        if (loadFromLoader)
        {
            if (loadMainAsset)
            {
                if (loader == null)
                {
                    for (int i = 0; i < loaders.Count; i++)
                    {
                        resAsset = loaders[i].LoadAsset(mainAssetPath, assetType);
                        if (resAsset != null)
                        {
                            loader = loaders[i];
                            break;
                        }
                    }
                }
                else
                {
                    resAsset = loader.LoadAsset(mainAssetPath, assetType);
                }
                if (resAsset == null)
                {
                    Debug.LogError("加载资源错误" + mainAssetPath);
                }
                if (cacheAsset == null)
                {
                    cacheAsset = new CacheAsset();
                    cacheAsset.loader = loader;
                    cacheAssets.Add(mainAssetPath, cacheAsset);
                }

                loadSuccess = true;
                cacheAsset.MainAsset = resAsset;
            }
            else
            {
                UObject[] res = null;
                if (loader == null)
                {
                    for (int i = 0; i < loaders.Count; i++)
                    {
                        res = loaders[i].LoadSubAssets(mainAssetPath);
                        if (res != null && res.Length > 0)
                        {
                            loader = loaders[i];
                            break;
                        }
                    }
                }
                else
                {
                    res = loader.LoadSubAssets(mainAssetPath);
                }
                for (int i = 0; i < res.Length; i++)
                {
                    if (res[i].name == subAssetName)
                    {
                        resAsset = res[i];
                    }
                }
                if (resAsset == null)
                {
                    Debug.LogError("加载资源错误" + mainAssetPath + "  " + subAssetName);
                }
                if (cacheAsset == null)
                {
                    cacheAsset = new CacheAsset();
                    cacheAsset.loader = loader;
                    cacheAssets.Add(mainAssetPath, cacheAsset);
                }

                loadSuccess = true;
                cacheAsset.MainAsset = res[0];
                cacheAsset.SetSubAsset(res);
            }
        }
        int bindId = 0;
        //绑定
        if (loadSuccess)
        {
            bindId = cacheAsset.BindReference(strongRef, bindTarget);
        }

        return new LoadResult(bindId, resAsset);
    }


    #endregion

    public static Dictionary<string, UObject> LoadSubResSync(string assetPath)
    {
        var res = Resources.LoadAll(assetPath);
        Dictionary<string, UObject> dic = new Dictionary<string, UObject>();
        for (int i = 1; i < res.Length; i++)
        {
            dic.Add(res[i].name, (UObject)res[i]);
        }
        return dic;
    }

    //public static void 

    public static void SplitPath(string assetPath, out string mainAssetPath, out string subAssetName)
    {
        int index = assetPath.LastIndexOf('>');
        if (index > 2)
        {
            mainAssetPath = assetPath.Substring(0, index - 1);
            subAssetName = assetPath.Substring(index + 1);
        }
        else
        {
            mainAssetPath = assetPath;
            subAssetName = string.Empty;
        }
    }


    #region private method


    #endregion
}
