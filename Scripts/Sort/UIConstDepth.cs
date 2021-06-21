using UnityEngine;
using System.Collections;
using UnityEngine.UI;

/// <summary>
/// UI的特效叠层控制 
/// </summary>
public class UIConstDepth : MonoBehaviour
{
    public bool isUI = false;
    public bool isGraphicRaycaster = false;
    public int sortOrder = 1;
    private Canvas tagerCanvas;

    private bool is_init = false;
    void Start()
    {
        if (!is_init)
        {
            Init();
        }
    }

    public void Init()
    {
        is_init = true;
        tagerCanvas = GetComponentInParent<Canvas>();
        DoUISorting();
    }

    public void DoUISorting()
    {
        if (isUI)
        {
            Canvas canvas = GetComponent<Canvas>();
            if (canvas == null)
            {
                canvas = this.gameObject.AddComponent<Canvas>();
            }
            GraphicRaycaster graphicRaycaster = GetComponent<GraphicRaycaster>();
            if (isGraphicRaycaster && graphicRaycaster == null)
            {
                graphicRaycaster = this.gameObject.AddComponent<GraphicRaycaster>();
            }
            try
            {
                canvas.overrideSorting = true;
                canvas.sortingOrder = tagerCanvas.sortingOrder + sortOrder;
            }
            catch (System.Exception)
            {
                throw;
            }
        }
    }

    public void DoEffectSorting(UIEffectRenderer ef)
    {
        if (tagerCanvas == null)
        {
            tagerCanvas = GetComponentInParent<Canvas>();
        }
        
        int sortingOrder = tagerCanvas ? tagerCanvas.sortingOrder : sortOrder;
        if (ef.renders != null)
        {
            foreach (Renderer item in ef.renders)
            {
                if (item != null)
                {
                    item.sortingOrder = sortingOrder + sortOrder;
                }
            }
        }
    }
}