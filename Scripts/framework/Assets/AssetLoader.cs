using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


 public abstract class AssetLoader
{

    public bool initialized;

    public abstract void Initialized();

    public abstract void Release();

    public abstract Object LoadAsset(string path, Type assetType);

    public abstract Object[] LoadSubAssets(string mainAssetPath);

    public abstract void LoadAssetAsync(string path, Type assetType,Action<LoadSubResult> callback);

    public abstract void LoadSubAssetsAsync(string mainAssetPath,Action<LoadSubResult> callback);

}

