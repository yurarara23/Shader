Shader "Unlit/Speed Lines"
{
    Properties
    {
        [Header(Base Settings)]
        _LineColor ("色", Color) = (1,1,1,1)
        
        [Header(Shape Settings)]
        _LineCount ("線の密度", Float) = 50.0
        _LineSpeed ("チカチカ速度", Float) = 15.0
        _LineThreshold ("線の出現率", Range(0.0, 1.0)) = 0.5
        
        [Header(Center Settings)]
        _CenterHole ("中心の空白", Range(0.0, 1.0)) = 0.2
        _CenterSmooth ("中心のボケ", Range(0.0, 1.0)) = 0.3
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Overlay+101"
        }

        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
            Cull Off
            ZTest Always

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _LineColor;
            float _LineCount;
            float _LineSpeed;
            float _LineThreshold;
            float _CenterHole;
            float _CenterSmooth;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float2 centeredUV = i.uv - 0.5;
                
                float angle = atan2(centeredUV.y, centeredUV.x);
                float dist = length(centeredUV);

                float lineID = floor(angle * _LineCount);

                float randomVal = frac(sin(lineID * 123.456) * 43758.5453);
                float speedNoise = frac(sin(lineID * 789.123 + _Time.y * _LineSpeed));

                float lineStart = _CenterHole + (randomVal * 0.2); 
                float mask = smoothstep(lineStart, lineStart + _CenterSmooth, dist);

                float alpha = step(_LineThreshold, speedNoise);

                alpha *= mask;

                return fixed4(_LineColor.rgb, alpha * _LineColor.a);
            }
            ENDCG
        }
    }
}