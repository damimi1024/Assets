
Shader "Tri_PlanarMapping"
{
	Properties
    {
        _AlbedoMap ("Albedo Map", 2D) = "white" {}
        _TextureScale("Texture Scale", float) = 1
        _TriplanarBlendSharpness("Blend Sharpness", float)=1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct vertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct vertexOutput
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            sampler2D _AlbedoMap;
            float4 _AlbedoMap_ST;
            float _TextureScale;
            float _TriplanarBlendSharpness;

            vertexOutput vert (vertexInput i)
            {
                vertexOutput o;
                o.vertex = UnityObjectToClipPos(i.vertex);
                o.uv = TRANSFORM_TEX(i.uv, _AlbedoMap);
                o.worldPos = mul(unity_ObjectToWorld, i.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(i.normal);
                return o;
            }

            fixed4 frag (vertexOutput i) : SV_Target
            {
                // find our UVs for each axis based on world position of the fragment
                half2 yUV = i.worldPos.xz / _TextureScale;
                half2 xUV = i.worldPos.zy / _TextureScale;
                half2 zUV = i.worldPos.xy / _TextureScale;

                // do texture samples from our albedo mao with each of the 3 UV set's we've just made.
                half3 yDiff = tex2D(_AlbedoMap, yUV);
                half3 xDiff = tex2D(_AlbedoMap, xUV);
                half3 zDiff = tex2D(_AlbedoMap, zUV);

                // get the absolute value of the world normal.
                // put the blend weights to the power of BlendSharpness, the higher the value,
                // the sharpness the transition between the planar maps will be.
                half3 blendWeights = pow(abs(i.worldNormal), _TriplanarBlendSharpness);

                // divide our blend mask by the sum of it's components, this will make x+y+z = 1
                blendWeights = blendWeights / (blendWeights.x + blendWeights.y + blendWeights.z);

                // finally, blend together all three samples based on the blend mask.
                fixed4 col = fixed4(xDiff * blendWeights.x + yDiff * blendWeights.y + zDiff * blendWeights.z, 1.0);
                return col;
            }
            ENDCG
        }
    }
}