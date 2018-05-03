using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System;
using UnityEditor;
using System.Linq;
public class web_copy_filltexture : MonoBehaviour {




//    // 贴图类型
//string[] TEXTURE_TYPE = { "_MetallicGlossMap", "_BumpMap", "_ParallaxMap", "_OcclusionMap", "_DetailMask", "_DetailAlbedoMap", "_DetailNormalMap"};

//// Material需要设置的关键字
//string[] TEXTURE_KEYWORD = { "_METALLICGLOSSMAP", "_NORMALMAP", "_PARALLAXMAP", "", "_DETAIL_MULX2", "_DETAIL_MULX2", "_DETAIL_MULX2" };
//    /// <summary> 
//    /// 设置材质中shader的相关属性 
//    ///<para name = "mat"> 需要设置的Material </para> 
//    ///<para name = "meshMat">　要传入shader的数据集合 </para> 
//    ///<para name = "fbxName">　模型的名字，在这里主要是为了得到材质贴图文件夹的位置 </para>
//    /// </summary>
//    void SetShader(Material mat, ShaderData data, string fbxName)
//    {  // 这里默认贴图资源中主贴图的名字就是材质名，其他贴图的名字是材质名+贴图类型
//        string diffuseName = mat.name;
//        // textureFiles用于记录贴图文件夹中所有的图片文件，记录它们的贴图名和路径
//        Dictionary<string, string> textureFiles = new Dictionary<string, string>();
//        // texturePath是之前记录好的一个fbx模型对应的贴图文件夹的路径
//        string[] filesPath = Directory.GetFiles(texturePath[fbxName]);
//        foreach (string filePath in filesPath)
//        {   // TEXTURE_EXT是预设的图片后缀名，用于标记图片格式(如.jpg,.png,.tif等)
//            if (Array.IndexOf(TEXTURE_EXT, Path.GetExtension(filePath)) != -1)
//            {
//                string fileName = Path.GetFileNameWithoutExtension(filePath);
//                if (fileName.IndexOf(diffuseName) == 0)
//                {
//                    textureFiles[fileName] = filePath;
//                    Debug.Log(fileName + " , " + filePath);
//                    // 设置法线贴图的类型
//                    if (fileName == diffuseName + TEXTURE_TYPE[1])
//                    {
//                        TextureImporter importer = (TextureImporter)AssetImporter.GetAtPath(filePath);
//                        importer.textureType = TextureImporterType.NormalMap;
//                        importer.SaveAndReimport();
//                    }
//                }
//            }
//        }

//        // 设置材质的主贴图，也就是Albedo贴图
//        if (textureFiles.ContainsKey(diffuseName))
//        {
//            Debug.Log("MainTexture Exist");
//            mat.mainTexture = AssetDatabase.LoadAssetAtPath<Texture>(textureFiles[diffuseName]);
//        }
//        // 设置其他特殊类型的贴图
//        for (int i = 0; i < TEXTURE_TYPE.Length; ++i)
//        {
//            if (textureFiles.ContainsKey(diffuseName + TEXTURE_TYPE[i]))
//            {
//                Debug.Log(TEXTURE_TYPE[i] + " Exist ");
//                if (TEXTURE_KEYWORD[i] != "")
//                    mat.EnableKeyword(TEXTURE_KEYWORD[i]);
//                mat.SetTexture(TEXTURE_TYPE[i], AssetDatabase.LoadAssetAtPath<Texture>(textureFiles[diffuseName + TEXTURE_TYPE[i]]));
//            }
//        }

//        mat.color = data.color;
//        mat.SetFloat("_Metallic", data.metallic);
//        mat.SetFloat("_Glossiness", data.glossiness);
//        mat.SetColor("_EmissionColor", data.emissionColor);
//    }
}
