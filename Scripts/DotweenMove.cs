using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class DotweenMove : MonoBehaviour
{
    public Transform trans;
    public float distance;
    // Start is called before the first frame update

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {

            var move1 = trans.DOLocalMoveZ(distance, 3);
            move1.OnComplete(() => {
                trans.DOLocalMoveZ(-distance, 3);
            });
        }
    }

}
