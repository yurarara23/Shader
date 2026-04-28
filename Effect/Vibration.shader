Shader "Unlit/Vibration"
{
    Properties
    {
        [Header(Vibration Settings)]
        _VibrationSpeed ("振動速度", Float) = 20.0
        _VibrationScale ("振動幅", Float) = 0.05
    }
    SubShader
    {
        Tags { "RenderType"="Overlay" "Queue"="Overlay" }

        LOD 100
        GrabPass { "_GrabTexture" }

        Pass
        {
            Cull Off 
            ZTest Always
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _GrabTexture;
            float _VibrationSpeed;
            float _VibrationScale;

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 grabPos : TEXCOORD0;
            };

            float Hash11(float t) {
                return frac(sin(t * 123.456) * 789.012) * 2.0 - 1.0;
            }

            float Noise(float t) {
                float i = floor(t);
                float f = frac(t);
                f = f * f * (3.0 - 2.0 * f);
                return lerp(Hash11(i), Hash11(i + 1.0), f);
            }

            v2f vert(appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.pos);
                return o;
            }

            float4 frag(v2f i) : SV_Target {
                float2 p = i.grabPos.xy / i.grabPos.w;
                float t = _Time.y * _VibrationSpeed;
                float aspect = _ScreenParams.x / _ScreenParams.y;

                float2 offset;
                offset.x = Noise(t) / aspect;
                offset.y = Noise(t + 100.0);

                float2 distortedUV = p + (offset * _VibrationScale);
                return tex2D(_GrabTexture, distortedUV);
            }
            ENDCG
        }
    }
}