using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
/// <summary>
/// 池的增长模式
/// </summary>
public enum PoolMode : byte
{
    /// <summary>
    /// 当前数量加上初始数量
    /// </summary>
    Add,
    /// <summary>
    /// 当前数乘以2
    /// </summary>
    Multiple
}

public class ObjectPool<T> : IObjectPool<T>, IObjectPool, IEnumerable<T>, IEnumerable
{
    #region variable
    /// <summary>
    /// 未使用的元素
    /// </summary>
    protected Stack<T> unUsed;

    /// <summary>
    ///  池容量
    /// </summary>
    protected int capacity;

    /// <summary>
    /// 模式
    /// </summary>
    public PoolMode Mode;

    protected static object locker = new object();

    protected static ObjectPool<T> shared;
    #endregion


    #region properties
    /// <summary>
    /// 残余未分配数量
    /// </summary>
    public int ResidueCount
    {
        get
        {
            return this.unUsed.Count;
        }
    }
    /// <summary>
    /// 容量
    /// </summary>
    public int Capacity
    {
        get
        {
            return this.capacity;
        }
        set
        {
            bool flag = value > 0 && value > this.capacity;
            if (flag)
            {
                this.AddCapacity(this.capacity);
                this.capacity = value;
            }
        }
    }

    /// <summary>
    /// 被分配数量
    /// </summary>
    public int SpawnCount
    {
        get
        {
            return this.Capacity - this.ResidueCount;
        }
    }

    #endregion

    #region protected Methods
    protected virtual void AddCapacity(int count)
    {
        for (int i = 0; i < count; i++)
        {
            this.unUsed.Push(this.CreateImpl());
        }
        this.capacity += count;
    }
    /// <summary>
    /// 创建实例实现
    /// </summary>
    /// <returns>创建后的新实例</returns>
    protected virtual T CreateImpl()
    {
        return Activator.CreateInstance<T>();
    }

    /// <summary>
    /// 获取添加的容量大小
    /// </summary>
    /// <returns>添加的容量大小</returns>
    protected virtual int GetAdditionCapacity()
    {
        bool flag = this.Mode == PoolMode.Multiple;
        int result;
        if (flag)
        {
            result = ((this.capacity < 1) ? 1 : this.capacity);
        }
        else
        {
            result = 1;
        }
        return result;
    }
    #endregion


    #region public Methods

    /// <summary>
    /// 全局共享的池
    /// </summary>
    public static ObjectPool<T> Shared
    {
        get
        {
            object obj = ObjectPool<T>.locker;
            lock (obj)
            {
                bool flag2 = ObjectPool<T>.shared == null;
                if (flag2)
                {
                    ObjectPool<T>.shared = new ObjectPool<T>();
                    Type type = typeof(T);
                    bool isArray = type.IsArray;
                    if (isArray)
                    {
                        throw new NotSupportedException("不支持数组");
                    }
                }
            }
            return ObjectPool<T>.shared;
        }
    }

    /// <summary>
    /// 构造
    /// </summary>
    public ObjectPool()
    {
        this.unUsed = new Stack<T>();
    }

    /// <summary>
    /// 构造
    /// </summary>
    /// <param name="capacity">初始容量大小</param>
    public ObjectPool(int capacity)
    {
        this.unUsed = new Stack<T>(capacity);
        this.AddCapacity(capacity);
    }

    /// <summary>
    /// 从池中分配未使用的元素
    /// </summary>
    /// <returns>元素对象</returns>
    public virtual T Spawn()
    {
        Stack<T> stack = this.unUsed;
        T item;
        lock (stack)
        {
            bool flag2 = this.unUsed.Count == 0;
            if (flag2)
            {
                this.AddCapacity(this.GetAdditionCapacity());
            }
            item = this.unUsed.Pop();
        }
        IPoolSpawnItem poolSpawnItem = item as IPoolSpawnItem;
        if (poolSpawnItem != null)
        {
            poolSpawnItem.OnSpawned();
        }
        return item;
    }

    /// <summary>
    /// 回收对象，内部不做null或者已经回收的检查
    /// </summary>
    /// <param name="item">回收元素</param>
    public virtual void Recycle(T item)
    {
        Stack<T> stack = this.unUsed;
        lock (stack)
        {
            this.unUsed.Push(item);
        }
        IPoolRecycleItem poolRecycleItem = item as IPoolRecycleItem;
        if (poolRecycleItem != null)
        {
            poolRecycleItem.OnRecycled();
        }
    }

    /// <summary>
    /// 清理
    /// </summary>
    public virtual void Clear()
    {
        Stack<T> stack = this.unUsed;
        lock (stack)
        {
            this.unUsed.Clear();
            this.capacity = 0;
        }
    }

    public void Recycle(object item)
    {
        this.Recycle((T)((object)item));
    }
    object IObjectPool.Spawn()
    {
        return this.Spawn();
    }


    public IEnumerator<T> GetEnumerator()
    {
        return this.unUsed.GetEnumerator();
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return this.unUsed.GetEnumerator();
    }

    #endregion



}
