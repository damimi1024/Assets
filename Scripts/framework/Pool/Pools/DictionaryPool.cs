using System;
using System.Collections.Generic;

/// <summary>
/// <see cref="T:System.Collections.Generic.Dictionary`2" />对象池
/// </summary>
/// <typeparam name="TKey">键</typeparam>
/// <typeparam name="TValue">值</typeparam>
public class DictionaryPool<TKey, TValue> : ObjectPool<Dictionary<TKey, TValue>>
{
    /// <summary>
    /// 全局共享的池
    /// </summary>
    public new static DictionaryPool<TKey, TValue> Shared
    {
        get
        {
            object locker = ObjectPool<Dictionary<TKey, TValue>>.locker;
            lock (locker)
            {
                bool flag2 = ObjectPool<Dictionary<TKey, TValue>>.shared == null;
                if (flag2)
                {
                    ObjectPool<Dictionary<TKey, TValue>>.shared = new DictionaryPool<TKey, TValue>();
                }
            }
            return (DictionaryPool<TKey, TValue>)ObjectPool<Dictionary<TKey, TValue>>.shared;
        }
    }

    /// <summary>
    /// 构造
    /// </summary>
    public DictionaryPool()
    {
    }

    /// <summary>
    /// 构造
    /// </summary>
    /// <param name="capacity">初始容量大小</param>
    public DictionaryPool(int capacity) : base(capacity)
    {
    }

    /// <inheritdoc />
    public override void Recycle(Dictionary<TKey, TValue> item)
    {
        item.Clear();
        base.Recycle(item);
    }
}