using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIEffectRenderer : MonoBehaviour
{
    public static void SortRenderersInChildren(Transform trans, int sortingOrder)
    {
        var effectRenderer = trans.GetComponent<UIEffectRenderer>();
        Renderer[] renderers;
        if (effectRenderer != null)
        {
            renderers = effectRenderer.renders;
        }
        else
        {
            renderers = trans.GetComponentsInChildren<Renderer>(true);
        }
        SortSortingOrderAll(renderers, sortingOrder);
    }

    public static void SortSortingOrderAll(Renderer[] renders, int sortingOrder)
    {
        if (renders != null)
        {
            for (int i = renders.Length - 1; i >= 0; i--)
            {
                var renderer = renders[i];
                if (renderer != null)
                {
                    renderer.sortingOrder = sortingOrder;
                }
            }
        }
    }

    public static void SortCanvas(Transform trans, int sortingOrder)
    {
        var canvas = trans.GetComponent<Canvas>();
        if (canvas == null)
            canvas = trans.gameObject.AddComponent<Canvas>();
        canvas.sortingOrder = sortingOrder;
    }

    public Renderer[] renders;

    public bool enableAutoDepth = true;

    void OnEnable()
    {
        if (enableAutoDepth)
        {
            var parentCanvas = this.GetComponentInParent<Canvas>();
            if (parentCanvas)
            {
                var parentDepth = GetComponentInParentRange<UIConstDepth>(this.transform, parentCanvas.transform);
                if (parentDepth == null)
                {
                    parentDepth = parentCanvas.gameObject.AddComponent<UIConstDepth>();
                    parentDepth.isUI = false;
                    parentDepth.Init();
                }
                parentDepth.DoEffectSorting(this);
            }
            else
            {
                // 无法排序还是报个错, 以方便后续分析问题
                //Debug.LogError("无法排序节点" + this.name, this);
            }
        }
    }

    public void Save()
    {
        renders = GetComponentsInChildren<Renderer>(true);
    }

    private void Reset()
    {
        renders = GetComponentsInChildren<Renderer>(true);
    }

    // 获取到指定位置的指定组件
    private static T GetComponentInParentRange<T>(Transform startTrans, Transform endTrans) where T : Component
    {
        var pT = startTrans.GetComponentInParent<T>();
        if (pT != null)
        {
            // 如果2个不相同, 则获取一个最近的
            var pTrans = pT.transform;
            var p = startTrans;
            while (p != null)
            {
                // 找到了
                if (p == pTrans)
                {
                    return pT;
                }
                // 结束点, 应该停止了
                else if (p == endTrans)
                {
                    return null;
                }
                // 下一个节点判断
                else
                {
                    p = p.parent;
                }
            }
        }
        return null;
    }
}
