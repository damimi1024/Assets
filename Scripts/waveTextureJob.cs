
using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;
using Unity.Jobs;
using Unity.Collections;

struct textureJob : IJob
{
    public float[,] waveA;
    public float[,] waveB;
    public int waveWidth;
    public int waveHeight;

    public NativeArray<Color> colorBuffer;
    public void Execute()
    {
            for (int w = 1; w < waveWidth - 1; w++)
            {
                for (int h = 1; h < waveHeight - 1; h++)
                {
                    waveB[w, h] =
                        (waveA[w - 1, h] +
                        waveA[w + 1, h] +
                        waveA[w, h - 1] +
                        waveA[w, h + 1] +
                        waveA[w - 1, h - 1] +
                        waveA[w + 1, h - 1] +
                        waveA[w - 1, h + 1] +
                        waveA[w + 1, h + 1]) / 4 - waveB[w, h];

                    float value = waveB[w, h];
                    if (value > 1)
                        waveB[w, h] = 1;
                    if (value < -1)
                        waveB[w, h] = -1;

                    float offset_u = (waveB[w - 1, h] - waveB[w + 1, h]) / 2;
                    float offset_v = (waveB[w, h - 1] - waveB[w, h + 1]) / 2;

                    float r = offset_u / 2 + 0.5f;
                    float g = offset_v / 2 + 0.5f;

                    //tex_uv.SetPixel(w, h, new Color(r, g, 0));
                    colorBuffer[w + waveWidth * h] = new Color(r, g, 0);
                    waveB[w, h] -= waveB[w, h] * 0.03f;//能量衰减

                }
            }

            float[,] temp = waveA;
            waveA = waveB;
            waveB = temp;
    }
}
public class waveTextureJob : MonoBehaviour
{

    public int waveWidth = 128;
    public int waveHeight = 128;

    float[,] waveA;
    float[,] waveB;
    public int radius;
    Texture2D tex_uv;
    bool IsRun = true;
    
    // Use this for initialization
    void Start()
    {
        waveA = new float[waveWidth, waveHeight];
        waveB = new float[waveWidth, waveHeight];
        tex_uv = new Texture2D(waveWidth, waveHeight);
        GetComponent<Renderer>().material.SetTexture("_WaveTex", tex_uv);
     
    }
    RaycastHit hit;
    Ray ray;
    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out hit))
            {
                Vector3 pos = transform.worldToLocalMatrix.MultiplyPoint(hit.point);
                int w = (int)((pos.x + 0.5f) * waveWidth);
                int h = (int)((pos.y + 0.5f) * waveHeight);
                PutPop(w, h);
            }
        }
        ComputeWave();
    }


    void PutPop(int x, int y)
    {
        float dist;
        for (int i = -radius; i <= radius; i++)
        {
            for (int j = -radius; j <= radius; j++)
            {
                if (((x + i >= 0) && (x + i < waveWidth - 1)) && ((y + j >= 0) && (y + j < waveHeight - 1)))
                {
                    dist = Mathf.Sqrt(i * i + j * j);
                    if (dist < radius)
                        waveA[x + i, y + j] = Mathf.Cos(dist * Mathf.PI / radius);
                }
            }
        }
    }

    void ComputeWave()
    {
        NativeArray<Color> result = new NativeArray<Color>(1, Allocator.TempJob);
        textureJob textureJob = new textureJob();
        textureJob.waveWidth = waveWidth;
        textureJob.waveHeight = waveHeight;
        textureJob.waveA = new float[waveWidth, waveHeight];
        waveA.CopyTo(textureJob.waveA,0);
        textureJob.waveB = new float[waveWidth, waveHeight];
        waveB.CopyTo(textureJob.waveB, 0);
        JobHandle handle = textureJob.Schedule();
        handle.Complete();
        Color[] colors = new Color[result.Length];
        for (int i = 0; i < result.Length; i++)
        {
            colors[i] = result[i];
        }
        tex_uv.SetPixels(colors);
        result.Dispose();
    }

}
