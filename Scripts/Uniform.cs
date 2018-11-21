#region 模块信息
// **********************************************************************
// 作者(Author):                  #yangry#
// 修改者列表(modifier):
// 模块描述(Module description):
// **********************************************************************
#endregion
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Uniform : MonoBehaviour {

	// Use this for initialization
	void Start () {
		GetComponent<Renderer>().material.SetVector("_SecondColor",new Vector4 (1,0,0,1));
	}
	

}
