using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
public interface IObjectPool
{
    object  Spawn();

    public void Recycle(object item);
}

public interface IObjectPool<T> : IObjectPool
{
    T Spawn();

    void Recycle(T item);
}

/// <summary>
/// Pool取出元素接口
/// </summary>
public interface IPoolSpawnItem
{
	/// <summary>
	/// 被分配了
	/// </summary>
	void OnSpawned();
}

/// <summary>
/// Pool元素回收接口
/// </summary>
public interface IPoolRecycleItem
{
	/// <summary>
	/// 被回收了
	/// </summary>
	void OnRecycled();
}