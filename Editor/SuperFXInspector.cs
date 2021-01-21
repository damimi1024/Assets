using UnityEditor;
using UnityEngine;


public class SuperFXInspector : ShaderInspectorBase
{
    #region 宏
    private string[] macro = new string[]
    {
        "MAINMOVE_ON",
        "MASK_ON",
        "DISSIPATE_ON",
        "VERTEX_ANIMATION",
        "MAINMOVEONE_ON",
        "BENDING_ON",
        "ROTA_ON",
        "UIMASKCLIP_ON",
        "HSV_ON",
        "FRESNEL_ON",
        "DETAIL_ON",
        "DISTORT2_ON",
        "MAINMOVEATAN_ON",
        "MIRROR_ON",
        "CIRCLE_ON",
        
    };

    private string[] macroName = new string[]
    {
        "流动",
        "遮罩",
        "溶解(T1.x)",
        "顶点动画(T1.y)",
        "单次流动(T1.z)(T1.w)",
        "弯曲(T2.x)(T2.y)(默认值1)",
        "旋转(T2.z)",
        "防穿剪裁",
        "HSV(HSB)色彩空间",
        "菲涅尔",
        "细节纹理",
        "扭曲",
        "极扩散",
        "镜像",
        "圆",
    };

    #endregion

    #region 功能参数

    private string[] MainParameter = new string[]
    {
         "_MainTex",
         "_MainColor",
         "_Alpha",
         "_zWrite",
        "_zTest",
        "_cull",
        "_srcBlend",
        "_dstBlend",
        "_srcAlphaBlend",
        "_dstAlphaBlend"
    };

    private string[] MainMoveParameter = new string[]
   {
        "_MainTexSpeedU",
        "_MainTexSpeedV"
   };

    private string[] MaskParameter = new string[]
   {
        "_MaskTex"
   };

    private string[] DissipateParameter = new string[]
   {
       "_DissolveTex",
       "_DissolveEdge",
       "_DissolveProgress",
       "_DissolveTimeOnOff",
       "_DissolveT1OnOff",
       "_DissolveTexOffsetSpeedZ",
       "_DissolveTexOffsetSpeedW",
   };


    private string[] HSVParameter = new string[]
   {
        "_Hue",
        "_Sat",
        "_Val"
   };

    private string[] FresnelParameter = new string[]
   {
        "_FresnelColor",
        "_FresnelBias",
        "_FresnelScale",
        "_FresnelPower"
   };

    private string[] DetailParameter = new string[]
   {
        "_DetailTex",
        "_DetailTexSpeed_U",
        "_DetailTexSpeed_V",
        "_DetailTexAngle",
   };

    private string[] Distort2Parameter = new string[]
   {
        "_DistortionMap",
        "_DistortionPower",
        "_DistortionSpeed",
   };

    private string[] VertexAnimation = new string[]
   {
   };

    private string[] Atan2Parameter = new string[]
    {
        "_Atan2Speed",
        "_Atan2Density"
    };

    private string[] MirrorParameter = new string[]
   {
        "_U_Mirror",
         "_V_Mirror",
   };

    private string[] BendingParameter = new string[]
    {
        "_BendingTex",
    };

    private string[] CircleParamenter = new string[]
    {
        "_CircleSpeed",
    };

    private string[] RotateParamenter = new string[]
    {
        "_AutoZRote",
        "_RoteValue"
    };

    #endregion

    private string[] GetParameter(int i)
    {
        switch (i)
        {
            case 0:
                return MainMoveParameter;
            case 1:
                return MaskParameter;
            case 2:
                return DissipateParameter;
            case 3:
                return VertexAnimation;
            case 4:
                return null;
            case 5:
                return BendingParameter;
            case 6:
                return RotateParamenter;
            case 7:
                return null;
            case 8:
                return HSVParameter;
            case 9:
                return FresnelParameter;
            case 10:
                return DetailParameter;
            case 11:
                return Distort2Parameter;
            case 12:
                return Atan2Parameter;
            case 13:
                return MirrorParameter;
            case 14:
                return CircleParamenter;
            default:
                return null;
        }
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        DrawUI(
            materialEditor,
            properties,
            macro,
            macroName,
            MainParameter,
            GetParameter);
    }
}
