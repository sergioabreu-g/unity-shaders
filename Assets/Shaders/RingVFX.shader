Shader "Unlit/RingVFX" {
    Properties {
        _ColorA ("ColorA", Color) = (1,1,1,1)
        _ColorB ("ColorB", Color) = (0,0,0,1)
        _Rows("Number of rows", Float) = 5
        _RippleScale("Ripple scale", Float) = 10
    }
    SubShader {
        Tags { "RenderType"="Transparent"
                "Queue"="Transparent" }

        Pass {
            Blend One One // additive
            Cull Off
            ZWrite OFf

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.2831853071795862

            float4 _ColorA;
            float4 _ColorB;
            float _Rows;
            float _RippleScale;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            Interpolators vert (appdata v) {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target {
                float offset = cos(i.uv.x * TAU * _RippleScale)/2;
                float t = cos(i.uv.y * TAU * _Rows + offset - _Time.w) * 0.5 + 0.5;
                t *= 1 - i.uv.y;

                // Remove top and bottom
                t = t * (abs(i.normal.y) < .99);

                float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);

                return gradient * t;
            }

            ENDCG
        }
    }
}
