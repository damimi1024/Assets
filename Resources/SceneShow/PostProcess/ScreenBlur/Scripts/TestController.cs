using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestController : BaseController
{
    // 界面缓存
    GameObject test_view1;

    protected override void InitEvents()
    {
        EventManager.AddEvent<bool>(EventName.OPEN_TEST_VIEW1, OpenTestView1);
    }

    void OpenTestView1(bool show)
    {
        if (show)
        {
            if (test_view1 == null)
            {
                OpenView("TestView1", out test_view1);
            }
        }
        else
        {
            if (test_view1 != null)
            {
                Destroy(test_view1);
                test_view1 = null;
            }
        }
    }

    public void OnOpenBtnClick()
    {
        EventManager.DispatchEvent<bool>(EventName.OPEN_TEST_VIEW1, true);
    }

    protected override void RemoveAllEvent()
    {
        EventManager.RemoveEvent<bool>(EventName.OPEN_TEST_VIEW1, OpenTestView1);
    }
}