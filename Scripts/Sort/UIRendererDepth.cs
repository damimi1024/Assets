using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Obsolete("请使用ctrl+G 大地图层级控制")]
[RequireComponent(typeof(Renderer))]
public class UIRendererDepth : MonoBehaviour
{
    [SerializeField][HideInInspector] private Renderer _renderer;

    [SerializeField] private Canvas _canvas;

    [SerializeField] private int _addSortingOrder = 0;

    private void Reset()
    {
        _renderer = GetComponent<Renderer>();
        //_canvas = GetComponentInParent<Canvas>();
    }

    // Use this for initialization
    void Start ()
    {
        if (_canvas == null)
        {
            _canvas = GetComponentInParent<Canvas>();
        }
        if (_canvas != null)
        {
            _renderer.sortingOrder = _canvas.sortingOrder + _addSortingOrder;
        }
	}
	
}
