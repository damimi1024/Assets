using System;

/// <summary>
/// <see cref="T:System.WeakReference" />对象池
/// </summary>
public sealed class WeakReferencePool : ObjectPool<WeakReference>
{
    /// <summary>
    /// 全局共享的池
    /// </summary>
    public new static WeakReferencePool Shared
    {
        get
        {
            object locker = ObjectPool<WeakReference>.locker;
            lock (locker)
            {
                bool flag2 = ObjectPool<WeakReference>.shared == null;
                if (flag2)
                {
                    ObjectPool<WeakReference>.shared = new WeakReferencePool();
                }
            }
            return (WeakReferencePool)ObjectPool<WeakReference>.shared;
        }
    }

    /// <summary>
    /// 构造
    /// </summary>
    public WeakReferencePool()
    {
    }

    /// <summary>
    /// 构造
    /// </summary>
    /// <param name="capacity">初始容量大小</param>
    public WeakReferencePool(int capacity) : base(capacity)
    {
    }

    /// <summary>
    /// 从池中分配未使用的元素
    /// </summary>
    /// <param name="target">弱引用绑定对象</param>
    /// <returns>元素对象</returns>
    public WeakReference Spawn(object target)
    {
        WeakReference item = this.Spawn();
        item.Target = target;
        return item;
    }

    /// <inheritdoc />
    public override void Recycle(WeakReference item)
    {
        item.Target = null;
        base.Recycle(item);
    }

    /// <inheritdoc />
    protected override WeakReference CreateImpl()
    {
        return new WeakReference(null);
    }
}

public sealed class WeakReferencePool<T> : ObjectPool<WeakReference<T>> where T : class
{
	/// <summary>
	/// 全局共享的池
	/// </summary>
	public new static WeakReferencePool<T> Shared
	{
		get
		{
			object locker = ObjectPool<WeakReference<T>>.locker;
			lock (locker)
			{
				bool flag2 = ObjectPool<WeakReference<T>>.shared == null;
				if (flag2)
				{
					ObjectPool<WeakReference<T>>.shared = new WeakReferencePool<T>();
				}
			}
			return (WeakReferencePool<T>)ObjectPool<WeakReference<T>>.shared;
		}
	}

	/// <summary>
	/// 构造
	/// </summary>
	public WeakReferencePool()
	{
	}

	/// <summary>
	/// 构造
	/// </summary>
	/// <param name="capacity">初始容量大小</param>
	public WeakReferencePool(int capacity) : base(capacity)
	{
	}

	/// <summary>
	/// 从池中分配未使用的元素
	/// </summary>
	/// <param name="target">弱引用绑定对象</param>
	/// <returns>元素对象</returns>
	public WeakReference<T> Spawn(T target)
	{
		WeakReference<T> item = this.Spawn();
		item.SetTarget(target);
		return item;
	}

	/// <inheritdoc />
	public override void Recycle(WeakReference<T> item)
	{
		item.SetTarget(default(T));
		base.Recycle(item);
	}

	/// <inheritdoc />
	protected override WeakReference<T> CreateImpl()
	{
		return new WeakReference<T>(default(T));
	}
}
