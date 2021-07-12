using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GPUInstanceTest : MonoBehaviour
{
    public Material instanceMat;//参数输入：材质
    public Mesh instanceMesh;//参数输入：模型
    Matrix4x4[] matrices;//绘制位置
    MaterialPropertyBlock block;
    public float Range = 10;
    private Vector3 targetPoint = new Vector3();
    private Vector3 movePoint = new Vector3();

    private Vector3 SphereCenter = new Vector3();

    void BuildMatrixAndBlock()
    {
        block = new MaterialPropertyBlock();
        matrices = new Matrix4x4[1023];
        Vector4[] colors = new Vector4[1023];
        for (var i = 0; i < 32; i++)
        {
            for (var j = 0; j < 32; j++)
            {
                var ind = j * 32 + i;
                if (ind >= 1023) break;
                Vector3 range = CalualteSphere(ind,1023,2,Vector3.zero);// Random.insideUnitSphere
                matrices[ind] = Matrix4x4.TRS(range * Range, Quaternion.identity, Vector3.one);
                colors[ind] = new Vector4(1 - i / 32.0f, 1 - j / 32.0f, 1, 1);

            }
        }
        block.SetVectorArray("_MainColor", colors);
    }
    bool option;
    private void OnGUI()
    {
        var support = SystemInfo.supportsInstancing;

        GUILayout.Label("是否支持Instance渲染 = " + support);
        bool newop = GUILayout.Toggle(option, "使用commandbuffer");
        if (newop != option)
        {
            option = newop;
            if (option == true)
            {
                UnityEngine.Rendering.CommandBuffer buffer = new UnityEngine.Rendering.CommandBuffer();
                buffer.DrawMeshInstanced(instanceMesh, 0, instanceMat, 0, matrices, 1023, block);
                Camera.main.AddCommandBuffer(UnityEngine.Rendering.CameraEvent.AfterForwardOpaque, buffer);
            }
            else
            {
                Camera.main.RemoveAllCommandBuffers();
            }
        }
    }
    void Start()
    {
        BuildMatrixAndBlock();
        var support = SystemInfo.supportsInstancing;
        Debug.Log("是否支持Instance渲染 = " + support);
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            //需要碰撞到物体才可以
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            bool isCollider = Physics.Raycast(ray, out hit);
            if (isCollider)
            {
                Debug.Log("射线检测到的点是" + hit.point);
            }
            targetPoint = hit.point;
        }
        if (targetPoint != Vector3.zero){

            for (int i = 0; i < matrices.Length; i++)
            {

                var position = new Vector3(matrices[i][0, 3], matrices[i][1, 3], matrices[i][2, 3]);
                movePoint = Vector3.Lerp(position, targetPoint, 0.1f);
                Vector3 range = CalualteSphere(i, 1023, 2, movePoint);// Random.insideUnitSphere
                matrices[i].SetTRS(range, Quaternion.identity, Vector3.one);
            }
        }
        //for (int i = 0; i < matrices.Length; i++)
        //{
        //    var position = new Vector3(matrices[i][0, 3], matrices[i][1, 3], matrices[i][2, 3]);
        //    movePoint = Vector3.Lerp(targetPoint, position, 0.1f);
        //    matrices[i].SetTRS(position + movePoint, Quaternion.identity, Vector3.one);
        //}
        if (!option)
        {
            Graphics.DrawMeshInstanced(instanceMesh, 0, instanceMat, matrices, 1023, block, UnityEngine.Rendering.ShadowCastingMode.Off, false);
        }
    }


    Vector3 CalualteSphere(int index, int count, int radius,Vector3 offset)
    {
        float inc = Mathf.PI * (3.0f - Mathf.Sqrt(5.0f));
        float off = 2.0f / count;
        float y = (float)index * off - 1.0f + (off / 2.0f);
        float r = Mathf.Sqrt(1.0f - y * y);
        float phi = index * inc;
        Vector3 pos = new Vector3(Mathf.Cos(phi) * r * radius + offset.x, y * radius+offset.y, Mathf.Sin(phi) * r * radius + offset.z);
        return pos;
    }
}
