using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseController : MonoBehaviour
{
    public GameObject[] ui_list_data;
    Dictionary<string, GameObject> view_dic = new Dictionary<string, GameObject>();
    Transform temp_parent_node;
    void Awake()
    {
        for (int i = 0; i < ui_list_data.Length; i++)
        {
            view_dic.Add(ui_list_data[i].name, ui_list_data[i]);
        }
        temp_parent_node = GameObject.Find("Canvas").transform;
        InitEvents();
    }
    void OnDestroy()
    {
        RemoveAllEvent();
    }

    protected void OpenView(string view_name, out GameObject target_go)
    {
        Debug.Log(view_name);
        if (view_dic.ContainsKey(view_name))
        {
            target_go = GameObject.Instantiate(view_dic[view_name], temp_parent_node);
            target_go.GetComponent<RectTransform>().anchoredPosition = Vector3.zero;
        }
        else
        {
            target_go = null;
        }
    }
    protected virtual void InitEvents() { }
    protected virtual void RemoveAllEvent() { }
}

