using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using Unity.Entities;
using Unity.Jobs;
using Unity.Mathematics;
using Unity.Transforms;
using UnityEngine;
public struct MoveData : IComponentData
{
    public Position pos;
    public TransformMatrix tm;
    public float speed;
}
public class jobSystemTest2 : MonoBehaviour
{
    public GameObject enemyShipPrefab;
    public float leftBound = 0;
    public float rightBound = 960;
    public float topBound = 0;
    public float bottomBound = 750;
    public int enemyShipIncremement;
    public float enemySpeed = 0.05f;
    EntityManager manager;
    //[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    void Start()
    {
        GameManager.GM = this;
        manager = World.Active.GetOrCreateManager<EntityManager>();
       // AddShips(enemyShipIncremement);
    }

    void Update()
    {
        if (Input.GetKeyDown("space"))
            AddShips(enemyShipIncremement);
    }

    void AddShips(int amount)
    {
        NativeArray<Entity> entities = new NativeArray<Entity>(amount, Allocator.Temp);
        manager.Instantiate(enemyShipPrefab, entities);

        for (int i = 0; i < amount; i++)
        {
            float xVal = Random.Range(leftBound, rightBound);
            float yVal = UnityEngine.Random.Range(0f, 10f);
            Quaternion rot = Quaternion.Euler(90f, 0f, 0f);
            manager.SetComponentData(entities[i], new Position { Value = new float3(xVal, yVal + topBound, 0f) });
            manager.SetComponentData(entities[i], new Rotation { Value = rot });
            manager.SetComponentData(entities[i], new MoveData { speed = enemySpeed });
        }
        entities.Dispose();
    }

}


public class MovementSys : JobComponentSystem
{
    struct MovementJob : IJobProcessComponentData<Position, Rotation, MoveSpeed>
    {
        public float topBound;
        public float bottomBound;
        public float deltaTime;
        public void Execute(ref Position position, [ReadOnly]ref Rotation rotation, [ReadOnly]ref MoveSpeed speed)
        {
            float3 value = position.Value;

            value += deltaTime * speed.speed * math.forward(rotation.Value);

            if (value.z < bottomBound)
                value.z = topBound;

            position.Value = value;
        }
    }
    protected override JobHandle OnUpdate(JobHandle inputDeps)
    {
        MovementJob moveJob = new MovementJob
        {
            topBound = GameManager.GM.topBound,
            bottomBound = GameManager.GM.bottomBound,
            deltaTime = Time.deltaTime
        };

        JobHandle moveHandle = moveJob.Schedule(this, 64, inputDeps);

        return moveHandle;
    }
}