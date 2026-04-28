Shader "Custom/Water" {
    Properties {
        _BaseMap ("Albedo (RGB)", 2D) = "white" {}
        _ScrollSpeed ("Scroll Speed", Range(0, 10)) = 1.0

        _Metallic ("Metallic", Range(0, 1)) = 0.0
        _Glossiness ("Smoothness", Range(0, 1)) = 0.5
        _BumpScale ("Normal Strength", Range(0, 10)) = 1.0
        _Distortion ("Distortion Strength", Range(0, 1)) = 0.1
    }

    SubShader {
        // 背景を歪ませる場合は透過(Transparent)キューに置く必要があります
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        // 背景を "_BackgroundTexture" としてキャプチャ
        GrabPass { "_BackgroundTexture" }
        
        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert
        #pragma target 3.0

        #include "UnityCG.cginc"

        sampler2D _BaseMap;
        sampler2D _BackgroundTexture;
        float _ScrollSpeed;
        half _Metallic;
        half _Glossiness;
        float _BumpScale;
        float _Distortion;

        struct Input {
            float2 uv_BaseMap;
            float4 screenPos; // 画面上の位置を受け取る
        };

        // 頂点シェーダーでスクリーン座標を計算
        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            float4 pos = UnityObjectToClipPos(v.vertex);
            o.screenPos = ComputeScreenPos(pos);
        }

        fixed2 random2(fixed2 st){
            st = fixed2( dot(st,fixed2(127.1,311.7)), dot(st,fixed2(269.5,183.3)) );
            return -1.0 + 2.0*frac(sin(st)*43758.5453123);
        }

        float perlinNoise(fixed2 st) {
            fixed2 p = floor(st);
            fixed2 f = frac(st);
            fixed2 u = f*f*(3.0-2.0*f);
            fixed2 v00 = random2(p+fixed2(0,0));
            fixed2 v10 = random2(p+fixed2(1,0));
            fixed2 v01 = random2(p+fixed2(0,1));
            fixed2 v11 = random2(p+fixed2(1,1));
            return lerp( lerp( dot( v00, f - fixed2(0,0) ), dot( v10, f - fixed2(1,0) ), u.x ),
                         lerp( dot( v01, f - fixed2(0,1) ), dot( v11, f - fixed2(1,1) ), u.x ), u.y)+0.5f;
        }

        float fBm (fixed2 st) {
            float f = 0;
            fixed2 q = st;
            f += 0.5000*perlinNoise( q ); q = q*2.01;
            f += 0.2500*perlinNoise( q ); q = q*2.02;
            f += 0.1250*perlinNoise( q ); q = q*2.03;
            f += 0.0625*perlinNoise( q ); q = q*2.01;
            return f;
        }

        fixed3 calculateNormal(fixed2 uv, float scale) {
            float delta = 0.01;
            float h = fBm(uv * scale);
            float h_right = fBm((uv + fixed2(delta, 0)) * scale);
            float h_up = fBm((uv + fixed2(0, delta)) * scale);
            fixed3 normal = fixed3((h - h_right) * _BumpScale, (h - h_up) * _BumpScale, 1.0);
            return normalize(normal);
        }

        void surf (Input IN, inout SurfaceOutputStandard o) {
            float2 uv = IN.uv_BaseMap;
            uv.y += _Time.y * _ScrollSpeed;

            // 1. 法線を計算
            fixed3 normal = calculateNormal(uv, 6.0);
            o.Normal = normal;

            // 2. 背景をサンプリングする座標を法線で歪ませる
            float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
            // 法線のXとYを使って背景のUVをずらす
            screenUV += normal.xy * _Distortion;

            // 3. 歪んだ背景を読み込む
            fixed3 background = tex2D(_BackgroundTexture, screenUV).rgb;

            // 4. 結果を統合
            float c = fBm(uv * 6.0);
            // 背景にノイズの色を少し乗せる（ガラスのような表現）
            o.Albedo = background + (fixed3(c,c,c) * 0.1);
            
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = 1;
        }
        ENDCG
    }
    FallBack "Diffuse"
}