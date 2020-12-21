using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public struct LoadResult
{
    public Object ResAsset { get; set; }

    public int Id { get; set; }

    public LoadResult(int id, Object resObj)
    {
        ResAsset = resObj;
        Id = id;
    }
}

public struct LoadResult<T> where T : Object
{
    public T ResAsset { get; set; }

    public int Id { get; set; }

    public LoadResult(int id, T resObj)
    {
        ResAsset = resObj;
        Id = id;
    }
}
