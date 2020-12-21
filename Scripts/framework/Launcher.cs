using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Launcher : MonoBehaviour
{
    [SerializeField]
    private string resPath;
    public Image image;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.A))
        {
             Asseter.LoadResAsync(resPath,(obj)=> {
                 //GameObject.Instantiate(obj);
                 //image.sprite = (Sprite)obj;
             });
            //image.sprite = (Sprite)res.ResAsset;
        }
    }
}
