Shader "Custom/ValueNoise"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        float random (fixed2 p) { 
            return frac(sin(dot(p, fixed2(12.9898,78.233))) * 43758.5453);
        }

        float noise(fixed2 st)
        {
            fixed2 p = floor(st);
            return random(p);
        }

        float valueNoise(fixed2 st)
        {
            fixed2 p = floor(st);
            fixed2 f = frac(st);

            float v00 = random(p+fixed2(0,0));
            float v10 = random(p+fixed2(1,0));
            float v01 = random(p+fixed2(0,1));
            float v11 = random(p+fixed2(1,1));
            
            fixed2 u = f * f * (3.0 - 2.0 * f);            

            float v0010 = lerp(v00, v10, u.x);
            float v0111 = lerp(v01, v11, u.x);
            return lerp(v0010, v0111, u.y);
        }

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            float c = valueNoise( IN.uv_MainTex*8);
            o.Albedo = fixed3(c,c,c);
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = 1.0;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
