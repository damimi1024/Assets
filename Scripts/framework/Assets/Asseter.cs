using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Object = UnityEngine.Object;
using System.Threading.Tasks;


public static class Asseter
{
    private static bool initialized;

    public static List<AssetLoader> loaders = new List<AssetLoader>();

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

    public static LoadResult LoadAsset(string AssetPath, Object bindTarget)
    {
        SplitPath(AssetPath, out string mainPath, out string subName);
        return LoadAsset(mainPath, subName, bindTarget);
    }

    public static LoadResult LoadAsset(string mainAssetPath, string subAssetName, bool strongRef = false)
    {
        return LoadAsset(mainAssetPath, subAssetName, typeof(Object), strongRef, null);
    }

    public static LoadResult LoadAsset(string mainAssetPath, string subAssetName, Object bindTarget)
    {
        return LoadAsset(mainAssetPath, subAssetName, typeof(Object), false, bindTarget);
    }

    public static LoadResult LoadAsset(string mainAssetPath, string subAssetName, Type assetType, bool strongRef, Object bindTarget)
    {
        bool loadMainAsset = string.IsNullOrEmpty(subAssetName);
        Object resAsset = null;
        if (loadMainAsset)
        {
            resAsset = Resources.Load(mainAssetPath);
        }
        else
        {
            var allAsset = Resources.LoadAll(mainAssetPath);
            for (int i = 1; i < allAsset.Length; i++)
            {
                if (allAsset[i].name == subAssetName)
                {
                    resAsset = allAsset[i];
                }
            }
        }
        if (resAsset == null)
        {
            throw new Exception("加载资源出错,请检查路径或名称");
        }
        return new LoadResult(0, resAsset);

    }

    #endregion


    #region 异步加载
    public static void LoadResAsync(string assetPath, Action<LoadResult> callback, bool strongRef = false)
    {
        SplitPath(assetPath, out string mainPath, out string subpath);
        LoadResAsync(mainPath, subpath, callback, strongRef);

    }
    public static void LoadResAsync(string assetPath, Action<LoadResult> callback, Object bindTarget)
    {
        SplitPath(assetPath, out string mainPath, out string subpath);
        LoadResAsync(mainPath, subpath, callback, bindTarget);
    }

    public static void LoadResAsync(string mainAssetPath, string subAssetName, Action<LoadResult> callback, bool strongRef = false)
    {
        LoadResAsync(mainAssetPath, subAssetName, callback, null, strongRef);
    }
    public static void LoadResAsync(string mainAssetPath, string subAssetName, Action<LoadResult> callback, Object bindTarget)
    {
        LoadResAsync(mainAssetPath, subAssetName, callback, bindTarget, false);
    }

    public static void LoadResAsync(string mainAssetPath, string subAssetName, Action<LoadResult> callback, Object bindTarget, bool strongRef = false)
    {
        var isLoadSubAsset = !string.IsNullOrEmpty(subAssetName);


        if (isLoadSubAsset)
        {
            //todo Resources没有异步加载子资源的实现 只能通过同步加载 

        }
        else
        {
            var request = Resources.LoadAsync(mainAssetPath);
            request.completed += (AsyncOperation) =>
            {
                var res = (ResourceRequest)AsyncOperation;
                var result = new LoadResult(0, res.asset);
                callback?.Invoke(result);
            };
        }
    }


    #endregion

    public static Dictionary<string, Object> LoadSubResSync(string assetPath)
    {
        var res = Resources.LoadAll(assetPath);
        Dictionary<string, Object> dic = new Dictionary<string, Object>();
        for (int i = 1; i < res.Length; i++)
        {
            dic.Add(res[i].name, res[i]);
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
