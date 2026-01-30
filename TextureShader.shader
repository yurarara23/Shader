Shader "Unlit/TextureShader"
{   
    Properties
    {
        _Tex ("Tex", 2D) = "" {}
    }

    CGINCLUDE

    sampler2D _Tex;

    float4 paint(float2 uv)
    {
        return tex2D(_Tex, uv);
    }

    ENDCG
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv1 : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv1 : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv1 = v.uv1;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return paint(i.uv1);
            }
            ENDCG
        }
    }
}
