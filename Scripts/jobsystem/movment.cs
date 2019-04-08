using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class movment : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}

    void Update()
    {
        Vector3 pos = transform.position;
        pos += transform.forward * GameManager.GM.enemySpeed * Time.deltaTime;

        if (pos.y < GameManager.GM.bottomBound)
            pos.y= GameManager.GM.topBound;

        transform.position = pos;
    }
}
