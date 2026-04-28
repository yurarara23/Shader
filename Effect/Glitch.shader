Shader "Unlit/DigitalGlitch_Simple"

{

    Properties

    {

        [Header(Glitch Settings)]

        _GlitchIntensity ("ズレの強さ", Range(0, 0.5)) = 0.1

        _ColorDrift ("色ズレ", Range(0, 0.1)) = 0.02

        _WaveSpeed ("速さ", Float) = 10.0

    }

    SubShader

    {

        Tags

        {

            "RenderType"="Overlay"

            "Queue"="Overlay"

        }



        LOD 100

        GrabPass { "_GrabTexture" }



        Pass

        {

            // 両面描画設定

            Cull Off

            ZTest Always

            ZWrite Off



            CGPROGRAM

            #pragma vertex vert

            #pragma fragment frag

            #include "UnityCG.cginc"



            sampler2D _GrabTexture;

            float _GlitchIntensity;

            float _ColorDrift;

            float _WaveSpeed;



            struct appdata {

                float4 vertex : POSITION;

            };



            struct v2f {

                float4 pos : SV_POSITION;

                float4 grabPos : TEXCOORD0;

            };



            // ランダムなブロック生成用

            float hash(float n) { return frac(sin(n) * 43758.5453123); }



            v2f vert(appdata v) {

                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.grabPos = ComputeGrabScreenPos(o.pos);

                return o;

            }



            float4 frag(v2f i) : SV_Target

            {

                // スクリーン座標を取得

                float2 p = i.grabPos.xy / i.grabPos.w;

               

                // 時間をカクカクにさせる

                float time = floor(_Time.y * _WaveSpeed);



                // 水平方向のブロック状のズレを作る計算

                // p.y * 10.0 の数値を大きくすると、ズレる横線の密度が細かくなります

                float lineNoise = pow(hash(floor(p.y * 10.0) + time), 3.0);

                float xOffset = lineNoise * _GlitchIntensity;



                // RGB分離（色収差）をさせながらサンプリング

                float4 col;

                col.r = tex2D(_GrabTexture, p + float2(xOffset + _ColorDrift, 0)).r;

                col.g = tex2D(_GrabTexture, p + float2(xOffset, 0)).g;

                col.b = tex2D(_GrabTexture, p + float2(xOffset - _ColorDrift, 0)).b;

                col.a = 1.0;



                return col;

            }

            ENDCG

        }

    }

}