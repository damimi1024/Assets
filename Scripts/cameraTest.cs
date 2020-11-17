using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class cameraTest : MonoBehaviour
{
    public Transform rayPos;
    public LineRenderer rayLine;
    public int rayLength = 10;

    void Update()
    {
        Ray ray = new Ray(rayPos.position, rayPos.forward);
        rayLine.SetPosition(0, ray.origin);//SetPosition中第一个参数表示射线的发射点还是终点 0表示起始点，1表示终点
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit, rayLength))
        {
            rayLine.SetPosition(1, hit.point);
        }
        else
        {
            rayLine.SetPosition(1, ray.origin + ray.direction * rayLength);
        }
    }
}
