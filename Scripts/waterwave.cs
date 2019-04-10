using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
public class waterwave : MonoBehaviour,IPointerClickHandler {

    private Material mat;

    private Renderer render;

    public void OnPointerClick(PointerEventData eventData)
    {
        throw new System.NotImplementedException();
        //transform.worldToLocalMatrix.mul
    }



    // Use this for initialization
    void Start () {
        mat = GetComponent<Renderer>().material;
        render = GetComponent<Renderer>();
        
	}

    Ray ray;
    RaycastHit hit;

	// Update is called once per frame
	void Update ()
    {
        if (Input.GetMouseButtonDown(0))
        {
            ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            if(Physics.Raycast(ray,out hit))
            {
                Vector3 vec = transform.worldToLocalMatrix.MultiplyPoint(hit.point);
                Debug.Log((vec.x + 0.5f).ToString()+"______"+(vec.y+0.5f).ToString());
                mat.SetFloat("_UVX",vec.x+0.5f);
                mat.SetFloat("_UVY", vec.y+0.5f);
                mat.SetFloat("_T", 30);
                mat.SetFloat("_F", 0.05f);
                mat.SetFloat("_R", 0);

                StartCoroutine(temp());
            }
        }

	}
    float _F;
    float _R;
    IEnumerator temp()
    {
        while (mat.GetFloat("_R") < 0.44f || mat.GetFloat("_F") > 0)
        {
            yield return new WaitForSeconds(0.02f);
            _F = mat.GetFloat("_F");
            _R = mat.GetFloat("_R");
            if (_F > 0)
                mat.SetFloat("_F", mat.GetFloat("_F") - 0.001f);
            if(_R< 0.44f)
                mat.SetFloat("_R", mat.GetFloat("_R") + 0.01f);
            
        }
        Debug.Log("over");
        StopCoroutine(temp());
    }
  
}
