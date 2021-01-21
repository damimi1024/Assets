using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class ShaderInspectorBase : ShaderGUI
{
    private bool[] isEnables = new bool[50];
    private bool[] isExpandeds = new bool[50];

    readonly GUIContent sTmpContent = new GUIContent();
    protected  GUIContent TempGUIContent(string _label, string _tooltip = null)
    {
        sTmpContent.text = _label;
        sTmpContent.tooltip = _tooltip;
        return sTmpContent;
    }

    protected GUIStyle _s_ShurikenModuleBg_style;
    protected GUIStyle ShurikenModuleBgStyle
    {
        get
        {
            if (_s_ShurikenModuleBg_style == null)
            {
                _s_ShurikenModuleBg_style = new GUIStyle("ShurikenModuleBg");
                _s_ShurikenModuleBg_style.margin = new RectOffset(0, 0, 0, -10);
            }
            return _s_ShurikenModuleBg_style;
        }
    }

    protected void ModuleHeader(string moduleName, ref bool isEnable, ref bool isExpanded)
    {
        Rect rect = GUILayoutUtility.GetRect(TempGUIContent(moduleName), new GUIStyle("ShurikenModuleTitle"));

        //Checkmark
        Rect toggleRect = new Rect(rect);
        toggleRect.width = 16f;
        toggleRect.x += 2f;
        toggleRect.y += 4f;

        isEnable = GUI.Toggle(toggleRect, isEnable, "", new GUIStyle("ShurikenCheckMark"));

        bool guiChanged = GUI.changed;

        EditorGUI.BeginChangeCheck();

        Color guiColor = GUI.color;
        GUI.Toggle(rect, isExpanded, moduleName, new GUIStyle("ShurikenModuleTitle"));
        GUI.color = guiColor;

        if (EditorGUI.EndChangeCheck() && Event.current.type == EventType.Used)
        {
            //Left click
            if (Event.current.button == 0)
            {
                isExpanded = !isExpanded;
            }
        }

        //Don't affect GUI.changed to prevent overwritting values when opening/closing module
        GUI.changed = guiChanged;

        //Checkmark (visual)
        GUI.Toggle(toggleRect, isEnable, "", new GUIStyle("ShurikenCheckMark"));

        if (isExpanded)
            GUILayout.Space(2f);

    }


    protected void SetKeyword(Material m, string keyword, bool state)
    {
        if (state)
            m.EnableKeyword(keyword);
        else
            m.DisableKeyword(keyword);
    }

    protected void GuiLine(int i_height = 1)
    {
        Rect rect = EditorGUILayout.GetControlRect(false, i_height/*, new GUIStyle("DefaultLineSeparator")*/);
        rect.height = i_height;
        EditorGUI.DrawRect(rect, new Color(0.12f, 0.12f, 0.12f, 1.333f));
    }

    protected void DrawUI(
        MaterialEditor materialEditor, 
        MaterialProperty[] properties,
        string[] macro,
        string[] macroName,
        string[] MainParameter,
        Func<int,string[]> GetParameter
        )
    {
        materialEditor.SetDefaultGUIWidths();
        MaterialProperty curProp = null;
        Material material = materialEditor.target as Material;

        //**主要属性**
        for (int i = 0; i < MainParameter.Length; i++)
        {
            curProp = FindProperty(MainParameter[i], properties);
            materialEditor.ShaderProperty(curProp, curProp.displayName);
        }

        for (int i = 0; i < macro.Length; i++)
        {
            GUILayout.BeginVertical(ShurikenModuleBgStyle, GUILayout.MinHeight(10f));
            isEnables[i] = material.IsKeywordEnabled(macro[i]);
            ModuleHeader(macroName[i], ref isEnables[i], ref isExpandeds[i]);
            GUILayout.Space(3);
            if (isExpandeds[i])
            {
                string[] value = GetParameter(i);
                if (value != null)
                {
                    for (int p = 0; p < value.Length; p++)
                    {
                        curProp = FindProperty(value[p], properties);
                        materialEditor.ShaderProperty(curProp, curProp.displayName);
                    }
                }
            }
            GUILayout.EndVertical();
            GuiLine();
            if (isEnables[i] != material.IsKeywordEnabled(macro[i]))
            {
                SetKeyword(material, macro[i], isEnables[i]);
            }
        }
        materialEditor.RenderQueueField();
        materialEditor.EnableInstancingField();
        materialEditor.DoubleSidedGIField();
    }
}
