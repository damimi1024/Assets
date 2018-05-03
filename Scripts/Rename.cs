using UnityEditor;
using UnityEngine;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System.Linq;
public class Rename :EditorWindow {

    [MenuItem("MyTool/RenameEffect")]
    static void Apply()
    {
        Rect wr = new Rect(0, 0, 200 , 200);
        Rename window = (Rename)EditorWindow.GetWindowWithRect(typeof(Rename),
             wr, true, "rename");
        window.Show();
    }
    static void Renames()
    {
       
        foreach (Object o in Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets))
        {
            if (!(o is Object))
                continue;
            //string[] temp = o.name.Split('_');
            //string i = temp[1];
            //string i = o.name.Remove(0,2);
            AssetDatabase.RenameAsset(AssetDatabase.GetAssetPath(o), rename + a);
            a = ((int.Parse(a)) + 1).ToString();
        }
    }
    //Assets/texture
    static string rename = "";
    static string a = "1";
    void OnGUI()
    {

        #region make prefab
        GUILayout.Label("明名名称：", EditorStyles.boldLabel);
        rename = EditorGUILayout.TextField(rename);
        GUILayout.Label("编号起点：", EditorStyles.boldLabel);
        a = EditorGUILayout.TextField(a);
        if (GUILayout.Button("重命名"))
        {

            Renames();
        }
        #endregion
        GUILayout.Label("贴图路径：", EditorStyles.boldLabel);
        texture_path = EditorGUILayout.TextField(texture_path);
        if (GUILayout.Button("材质球ao贴图添加++"))
        {
            fn_add_ao_texture();
        }

    }
    //Asset/texture
    private void fn_add_ao_texture()
    {
        List<Texture2D> ao_textures=fn_finde_all_path_texture(texture_path);
        foreach (Material mat in Selection.GetFiltered(typeof(Material), SelectionMode.DeepAssets))
        {

            foreach (var item in ao_textures)
            {

                if (fn_aos_texture(mat.name, item.name))
                {

                   // string texture_type = "_OcclusionMap";
                    //string texture_key = "_DETAIL_MULX2";
                    mat.EnableKeyword("_OCCLUSIONMAP");
                    mat.SetTexture("_OcclusionMap", item);
                }
               
            }
       
        }
    }

    static string texture_path = "";

    private bool fn_aos_texture(string mat_name,string texture_name) {
       //string[] mat_name_info= mat_name.Split('_');
       // string mat_remove_tile=
       //string[] text_name_info = texture_name.Split('_');
        mat_name = mat_name.Substring(mat_name.IndexOf('_') + 1);
        texture_name = texture_name.Substring(texture_name.IndexOf('_') + 1);
     
            return mat_name == texture_name;
    }

    private List<Texture2D> fn_finde_all_path_texture(string path) {
        string[] guids = AssetDatabase.FindAssets("t:Texture", new string[]{texture_path});
        //从GUID获得资源所在路径
        List<string> paths = new List<string> ();
        guids.ToList().ForEach(m => paths.Add(AssetDatabase.GUIDToAssetPath(m)));
        //从路径获得该资源
        List<Texture2D> textures = new List<Texture2D>();
        paths.ForEach(p => textures.Add(AssetDatabase.LoadAssetAtPath(p, typeof(Texture2D)) as Texture2D));
        return textures;
    }
}
