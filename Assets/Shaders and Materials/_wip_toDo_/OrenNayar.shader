Shader "Pipeworks_Custom/Oren Nayar" {
	Properties {
		_ColorTint ("Color Tint", Color) = (1,1,1,1)
		_MainTex ("Main (RGB) Spec (A)", 2D) = "white" {}
	    _Normal("Normal",2D)="bump"{}
        _NormalScale("Normal Scale", Range(0, 2)) = 1.0
        _Roughness("Roughness", Range(0, 2)) = 0.0
		[Header(Specular)]
		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_SpecPower("Specular Power", Range(0.0, 2)) = 1
		[Header(Rim Lighting)]
		_RimColor("Rim Color", Color) = (0.61, 0.62, 0.86,1.0)
		_RimPower("Rim Power", Range(0.5, 10.0)) = 3.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		ColorMask RGB
		LOD 200

		CGPROGRAM
		// Physically based Oren Nayar approximation lighting model, and enable shadows on all light types
		#pragma surface surf OrenNayar finalcolor:ColorTint fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		uniform float	_Roughness;
		uniform half	_SpecPower;

		// Blinn-Phong specular.
		fixed BlinnPhong(fixed3 N, fixed3 L, fixed3 V)
		{
			fixed3 H = normalize(V + L);
			fixed ndotH = max(0.0, dot(N, H));
			return saturate(pow(ndotH, (_SpecPower * 128.0)));
		}

		half4 LightingOrenNayar(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
			// roughness A, Ap and B
			half roughness = _Roughness;
			half roughness2 = roughness * roughness;
			half3 oren_nayar_fraction = roughness2 / (roughness2 + half3(0.33, 0.13, 0.09));
			half3 oren_nayar = half3(1, 0, 0) + half3(-0.5, 0.17, 0.45) * oren_nayar_fraction;

			// components
			half cos_nl = saturate(dot(s.Normal, lightDir));
			half cos_nv = saturate(dot(s.Normal, viewDir));
			half oren_nayar_s = saturate(dot(lightDir, viewDir)) - cos_nl * cos_nv;
			oren_nayar_s /= lerp(max(cos_nl, cos_nv), 1, step(oren_nayar_s, 0));

			// Blinn-Phong specular
			fixed specularHighlight = BlinnPhong(s.Normal, lightDir, viewDir);
			fixed3 specL = specularHighlight * _SpecColor.rgb * _SpecColor.a * s.Alpha;

			// diffuse composition
			half3 diffuseL =  cos_nl * (oren_nayar.x + s.Albedo * oren_nayar.y + oren_nayar.z * oren_nayar_s);
			diffuseL *= s.Albedo * _LightColor0.rgb * atten;
			specL *= _LightColor0.rgb * atten;

			return half4((diffuseL + specL), s.Alpha);
		}

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_Normal;
			float3 viewDir;
			float3 lightDir;
			INTERNAL_DATA
		};

		fixed4 _ColorTint;
		//
		void ColorTint(Input IN, SurfaceOutput o, inout fixed4 color)
		{
			color *= _ColorTint;
		}

		uniform sampler2D	_MainTex;
		uniform sampler2D	_Normal;
		uniform float		_NormalScale;
		uniform float4		_RimColor;
		uniform float		_RimPower;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutput o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			fixed specMap = c.a;

			// Bumpity bump...
			half3 normals = UnpackNormal(tex2D(_Normal, IN.uv_Normal));
			o.Normal = fixed3(normals.x * _NormalScale, normals.y * _NormalScale, normals.z);

			// (Tweaked) Fresnel rim lighting.
			half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
			half3 worldNormal = WorldNormalVector(IN, o.Normal);
			rim *= saturate(dot(fixed3(0, 1, 0), worldNormal) * 0.5 + 0.5) * saturate(dot(fixed3(0, 1, 0), -IN.viewDir) + 1.75);
			o.Emission = _RimColor.rgb * pow(rim, _RimPower);

			o.Albedo = c.rgb;
			o.Alpha = specMap;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
