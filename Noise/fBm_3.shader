Shader "Custom/fBm_3" {
    Properties {
        _BaseMap ("Albedo (RGB)", 2D) = "white" {}
        _ScrollSpeed ("Scroll Speed", Range(0, 10)) = 1.0

        _Metallic ("Metallic", Range(0, 1)) = 0.0
        _Glossiness ("Smoothness", Range(0, 1)) = 0.5
        _BumpScale ("Normal Strength", Range(0, 10)) = 1.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        #include "UnityCG.cginc"

        sampler2D _BaseMap;
        float _ScrollSpeed;

        half _Metallic;
        half _Glossiness;
        float _BumpScale;

        struct Input {
            float2 uv_BaseMap;
        };

        fixed2 random2(fixed2 st){
            st = fixed2( dot(st,fixed2(127.1,311.7)),
                           dot(st,fixed2(269.5,183.3)) );
            return -1.0 + 2.0*frac(sin(st)*43758.5453123);
        }

        float perlinNoise(fixed2 st) 
        {
            fixed2 p = floor(st);
            fixed2 f = frac(st);
            fixed2 u = f*f*(3.0-2.0*f);

            fixed2 v00 = random2(p+fixed2(0,0));
            fixed2 v10 = random2(p+fixed2(1,0));
            fixed2 v01 = random2(p+fixed2(0,1));
            fixed2 v11 = random2(p+fixed2(1,1));

            return lerp( lerp( dot( v00, f - fixed2(0,0) ), dot( v10, f - fixed2(1,0) ), u.x ),
                         lerp( dot( v01, f - fixed2(0,1) ), dot( v11, f - fixed2(1,1) ), u.x ), 
                         u.y)+0.5f;
        }

        float fBm (fixed2 st) 
        {
            float f = 0;
            fixed2 q = st;
            f += 0.5000*perlinNoise( q ); q = q*2.01;
            f += 0.2500*perlinNoise( q ); q = q*2.02;
            f += 0.1250*perlinNoise( q ); q = q*2.03;
            f += 0.0625*perlinNoise( q ); q = q*2.01;
            return f;
        }

        fixed3 calculateNormal(fixed2 uv, float scale)
        {
            float delta = 0.01;
            float h = fBm(uv * scale);
            float h_right = fBm((uv + fixed2(delta, 0)) * scale);
            float h_up = fBm((uv + fixed2(0, delta)) * scale);
            
            // _BumpScale を使って凸凹の強さを変えられるようにしました
            fixed3 normal = fixed3((h - h_right) * _BumpScale, (h - h_up) * _BumpScale, 1.0);
            return normalize(normal);
        }

        void surf (Input IN, inout SurfaceOutputStandard o) {
            float2 uv = IN.uv_BaseMap;
            
            uv.y += _Time.y * _ScrollSpeed;

            float c = fBm(uv * 6.0);
            
            o.Albedo = fixed3(c,c,c);

            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Normal = calculateNormal(uv, 6.0);
            o.Alpha = 1;
        }
        ENDCG
    }
    FallBack "Diffuse"
}