using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
//using Unity.Collections;
using Unity.Jobs;
using UnityEngine;
using UnityEngine.Jobs;

[ComputeJobOptimization]
public struct MovementJob : IJobParallelForTransform
{
    public float moveSpeed;
    public float topBound;
    public float bottomBound;
    public float deltaTime;
    public void Execute(int index, TransformAccess transform)
    {
        Vector3 pos = transform.position;
        pos += moveSpeed * deltaTime * (transform.rotation * new Vector3(0f, 1f, 0f));

        if (pos.y < bottomBound)
            pos.y = topBound;

        transform.position = pos;
    }
}


public class jobSystemTest : MonoBehaviour {

    TransformAccessArray transforms;
    MovementJob moveJob;
    JobHandle moveHandle;


    public GameObject enemyShipPrefab;
    public float leftBound=0;
    public float rightBound=960;
    public float topBound=0;
    public float bottomBound = 750;
    public int enemyShipIncremement;
    public float enemySpeed = 0.05f;

    private void Start()
    {
        //GameManager.GM = this;
        transforms = new TransformAccessArray();
    }
    private void Update()
    {
        moveHandle.Complete();

        if (Input.GetKeyDown("space"))
            AddShips(enemyShipIncremement);

        moveJob = new MovementJob()
        {
            moveSpeed = enemySpeed,
            topBound = topBound,
            bottomBound = bottomBound,
            deltaTime = Time.deltaTime
        };

        moveHandle = moveJob.Schedule(transforms);

        JobHandle.ScheduleBatchedJobs();
   
    }
    void AddShips(int amount)
    {
        moveHandle.Complete();
        transforms.capacity = transforms.length + amount;
        for (int i = 0; i < amount; i++)
        {
            float xVal = UnityEngine.Random.Range(leftBound, rightBound);
           // float zVal = UnityEngine.Random.Range(0f, 10f);
            float yVal = UnityEngine.Random.Range(0f, 10f);
            Vector3 pos = new Vector3(xVal, yVal + topBound, 0f);// zVal + topBound);
            Quaternion rot = Quaternion.Euler(90f,0f, 0f);

            var obj = Instantiate(enemyShipPrefab, pos, rot) as GameObject;
            transforms.Add(obj.transform);
        }
    }
}
