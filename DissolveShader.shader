Shader "Custom/TopDownDissolve"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Cutoff ("Cutoff Level", Range(-1.0, 1.0)) = 0.0
        _EdgeColor ("Edge Color", Color) = (1,1,0,1)
        _EdgeWidth ("Edge Width", Range(0, 0.1)) = 0.05
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        // surf関数でStandardライティングを使用することを指定
        #pragma surface surf Standard addshadow vertex:vert

        struct Input
        {
            float2 uv_MainTex;
            float3 objPos; 
        };

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            // ローカル座標を渡す
            o.objPos = v.vertex.xyz; 
        }

        sampler2D _MainTex; // 修正：型をsampler2Dに
        float _Cutoff;
        float4 _EdgeColor;
        float _EdgeWidth;

        // 修正点：EditorSurfaceOutputStandard -> SurfaceOutputStandard
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // 指定した高さより上のピクセルを切り捨てる
            clip(_Cutoff - IN.objPos.y);

            // エッジの発光処理
            if (IN.objPos.y > _Cutoff - _EdgeWidth)
            {
                o.Emission = _EdgeColor.rgb;
            }

            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}