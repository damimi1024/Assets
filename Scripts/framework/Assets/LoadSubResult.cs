using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public struct LoadSubResult
{
    public Object[] Targets { get; private set; }

    public int BindId { get; private set; }

    public LoadSubResult (Object[] target,int bindId)
    {
        Targets = target;
        BindId = bindId;
    }
}
