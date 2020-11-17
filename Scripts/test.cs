using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class test : MonoBehaviour
{
    /// <summary>
    /// 要移动的物体
    /// </summary>
    [Header("要移动的物体"), SerializeField]
    private GameObject go;
    /// <summary>
    /// 角度
    /// </summary>
    private float angle;
    /// <summary>
    /// 圆半径
    /// </summary>
    [Header("圆半径"), SerializeField]
    private float Circular_R;
    /// <summary>
    /// 原点
    /// </summary>
    [Header("原点"), SerializeField]
    private GameObject Point;

    public Camera mainCam;


    private Vector3 lastDir;

    private LineRenderer line;
    private void Start()
    {
        line = GetComponent<LineRenderer>();

    }
    private void Update()
    {
        //角度
        angle += Time.deltaTime / 50f;

        Move(Circular_X(0, Circular_R, angle), Circular_Y(0, Circular_R, angle));

        Vector3 camForward = Vector3.Normalize(mainCam.transform.forward);

        Vector3 nowDir =Vector3.Normalize(go.transform.position - Point.transform.position);

        Vector3 forwardDir = Vector3.Normalize(Vector3.Cross(lastDir, nowDir));

        var res = Vector3.Dot(camForward, forwardDir);
        
        if (res>0)
        {
            print("逆时针");
        }
        if(res<0)
        {
            print("顺时针");

        }
        lastDir = nowDir;

    }

    /// <summary>
    /// 移动
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    private void Move(float x, float y)
    {
        go.transform.position = new Vector3(x + Point.transform.position.x, y + Point.transform.position.y, 0);
    }



    /// <summary>
    /// 圆x坐标
    /// </summary>
    /// <param name="a">圆心x坐标</param>
    /// <param name="r">半径</param>
    /// <param name="angle">角度</param>
    /// <returns></returns>
    private float Circular_X(float a, float r, float angle)
    {
        return (a + r * Mathf.Cos(angle * Mathf.Rad2Deg));
    }

    /// <summary>
    /// 圆y坐标
    /// </summary>
    /// <param name="b">圆心y坐标</param>
    /// <param name="r">半径</param>
    /// <param name="angle">角度</param>
    /// <returns></returns>
    private float Circular_Y(float b, float r, float angle)
    {
        return (b + r * Mathf.Sin(angle * Mathf.Rad2Deg));
    }

}

