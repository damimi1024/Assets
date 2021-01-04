using System;
using UObject = UnityEngine.Object;


public abstract class AssetLoader
{

    public bool initialized;

    public abstract void Initialized();

    public abstract void Release();

    public abstract UObject LoadAsset(string path, Type assetType);

    public abstract UObject[] LoadSubAssets(string mainAssetPath);

    public abstract void LoadAssetAsync(string path, Type assetType,Action<LoadSubResult> callback);

    public abstract void LoadSubAssetsAsync(string mainAssetPath,Action<LoadSubResult> callback);

}

