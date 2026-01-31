Shader "Custom/GerstnerWave"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Amplitude ("Amplitude", Float) = 0.2
        _Wavelength ("Wavelength", Float) = 3
        _Speed ("Speed", Float) = 1
        _Steepness ("Steepness", Range(0,1)) = 0.5
        _Direction ("Direction", Vector) = (1,0,0,0)
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
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            float4 _Color;
            float _Amplitude;
            float _Wavelength;
            float _Speed;
            float _Steepness;
            float4 _Direction;

            float3 Gerstner(float3 pos, out float3 normal)
            {
                float2 D = normalize(_Direction.xz);

                float k = 2 * UNITY_PI / _Wavelength;
                float c = sqrt(9.8 / k);
                float f = k * (dot(D, pos.xz) - c * _Time.y * _Speed);

                float a = _Amplitude;
                float q = _Steepness;

                float cosF = cos(f);
                float sinF = sin(f);

                pos.x += q * a * D.x * cosF;
                pos.z += q * a * D.y * cosF;
                pos.y += a * sinF;

                normal = normalize(float3(
                    -D.x * k * a * cosF,
                    1 - q * k * a * sinF,
                    -D.y * k * a * cosF
                ));

                return pos;
            }

            v2f vert (appdata v)
            {
                v2f o;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                float3 n;
                worldPos = Gerstner(worldPos, n);

                o.pos = mul(UNITY_MATRIX_VP, float4(worldPos,1));
                o.normal = normalize(n);
                o.worldPos = worldPos;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 N = normalize(i.normal);
                float3 L = normalize(_WorldSpaceLightPos0.xyz);

                float diff = saturate(dot(N, L));

                float3 col = _Color.rgb * _LightColor0.rgb * diff;

                return float4(col, 1);
            }

            ENDCG
        }
    }
}
