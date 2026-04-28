Shader "Unlit/Pixelate_Simple"
{
    Properties
    {
        [Header(Mosaic Settings)]
        _PixelSize ("ドットの大きさ", Range(0.001, 0.1)) = 0.01
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
            // 両面描画（レンズの表からも裏からも見える）
            Cull Off 
            ZTest Always
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _GrabTexture;
            float _PixelSize;

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 grabPos : TEXCOORD0;
            };

            v2f vert(appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.pos);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                // スクリーン座標を取得して正規化
                float2 p = i.grabPos.xy / i.grabPos.w;

                // --- ピクセレートの計算 ---
                // UV座標を丸めることでカクカクにする
                float2 pixelatedUV = floor(p / _PixelSize) * _PixelSize;

                // 加工したUVで背景を取得
                float4 col = tex2D(_GrabTexture, pixelatedUV);
                
                return col;
            }
            ENDCG
        }
    }
}