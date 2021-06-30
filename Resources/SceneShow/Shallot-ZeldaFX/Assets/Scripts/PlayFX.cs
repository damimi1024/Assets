using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayFX : MonoBehaviour {

    // Use this for initialization
    private Animator myAnimator;

	void Start () {

        myAnimator = GetComponent<Animator>();
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    public void ShowAnimator()
    {
        myAnimator.enabled = !myAnimator.enabled;
    }
}
