Shader "Pipeworks_Custom/JCOR Basic Terrain"
{
	Properties
	{
		_BaseTint("Base Tint", Color) = (1,1,1,1)
		[NoScaleOffset]_MainTex("Main Tex", 2D) = "white" {}
		_SpecMap("Spec Map", 2D) = "black" {}
		_Shininess("Gloss", Range( 0.01 , 1)) = 0.1
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		[NoScaleOffset]_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 4)) = 1
		_AtmosphereFar("Atmosphere Far", Color) = (0.359,0.7974198,1,1)
		_AtmosphereNear("Atmosphere Near", Color) = (1,0.3724138,0,1)
		_AtmosphereFalloff("Atmosphere Falloff", Range( 0.1 , 5)) = .66
		[NoScaleOffset]_NightLights("Night Lights", 2D) = "black" {}
		_NightLightsIntensity("Night Lights Intensity", Range( 0 , 2)) = 1
		_NightLightsSoftness("Night Lights Softness", Range( 0.1 , 1)) = 0.3
		_NightLightRed("Night Light Red", Range( 0 , 1)) = 1
		_NightLightGreen("Night Light Green", Range( 0 , 1)) = 0.75
		_NightLightBlue("Night Light Blue", Range( 0 , 1)) = 0.35
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		ColorMask RGB
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 4.6
		#pragma surface surf StandardCustomLighting keepalpha nolightmap  nodynlightmap nodirlightmap nofog noforwardadd vertex:vertexDataFunc
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			half2 uv_texcoord;
			half3 vertexToFrag251;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			fixed3 Albedo;
			fixed3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			fixed Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform half4 _SpecularColor;
		uniform half _NormalScale;
		uniform sampler2D _NormalMap;
		uniform half _Shininess;
		uniform sampler2D _SpecMap;
		uniform float4 _SpecMap_ST;
		uniform sampler2D _MainTex;
		uniform half4 _BaseTint;
		uniform half4 _AtmosphereNear;
		uniform half4 _AtmosphereFar;
		uniform half _AtmosphereFalloff;
		uniform fixed _NightLightRed;
		uniform sampler2D _NightLights;
		uniform half _NightLightsIntensity;
		uniform half _NightLightsSoftness;
		uniform fixed _NightLightGreen;
		uniform fixed _NightLightBlue;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			half3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			half3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float fresnelNDotV90 = dot( normalize( ase_worldNormal ), ase_worldViewDir );
			float fresnelNode90 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNDotV90, _AtmosphereFalloff ) );
			float temp_output_105_0 = saturate( fresnelNode90 );
			float3 lerpResult138 = lerp( (_AtmosphereNear).rgb , (_AtmosphereFar).rgb , temp_output_105_0);
			o.vertexToFrag251 = saturate( ( lerpResult138 * temp_output_105_0 ) );
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#if DIRECTIONAL
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			float4 temp_output_43_0_g128 = _SpecularColor;
			float3 ase_worldPos = i.worldPos;
			half3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float3 normalizeResult4_g129 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float2 uv_NormalMap63 = i.uv_texcoord;
			half3 NORMALS65 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap63 ) ,_NormalScale );
			float3 normalizeResult64_g128 = normalize( WorldNormalVector( i , NORMALS65 ) );
			float dotResult19_g128 = dot( normalizeResult4_g129 , normalizeResult64_g128 );
			float3 temp_output_40_0_g128 = ( _LightColor0.rgb * ase_lightAtten );
			float2 uv_SpecMap = i.uv_texcoord * _SpecMap_ST.xy + _SpecMap_ST.zw;
			float dotResult14_g128 = dot( normalizeResult64_g128 , ase_worldlightDir );
			float temp_output_15_0_g128 = max( dotResult14_g128 , 0.0 );
			UnityGI gi34_g128 = gi;
			float3 diffNorm34_g128 = normalizeResult64_g128;
			gi34_g128 = UnityGI_Base( data, 1, diffNorm34_g128 );
			float3 indirectDiffuse34_g128 = gi34_g128.indirect.diffuse + diffNorm34_g128 * 0.0001;
			float2 uv_MainTex147 = i.uv_texcoord;
			half3 ATMOSPHERE142 = i.vertexToFrag251;
			float4 temp_output_42_0_g128 = half4( saturate( ( ( (tex2D( _MainTex, uv_MainTex147 )).rgb * ( (_BaseTint).rgb * _BaseTint.a ) ) + ATMOSPHERE142 ) ) , 0.0 );
			float2 uv_NightLights160 = i.uv_texcoord;
			float smoothstepResult111_g128 = smoothstep( 0.0 , _NightLightsSoftness , temp_output_15_0_g128);
			fixed NL_ALPHA85_g128 = ( 1.0 - saturate( ( smoothstepResult111_g128 * 1.0 ) ) );
			float temp_output_84_0_g128 = min( saturate( ( (tex2D( _NightLights, uv_NightLights160 )).r * _NightLightsIntensity ) ) , NL_ALPHA85_g128 );
			half NL_R80_g128 = ( _NightLightRed * temp_output_84_0_g128 );
			half NL_G81_g128 = ( _NightLightGreen * temp_output_84_0_g128 );
			half NL_B82_g128 = ( temp_output_84_0_g128 * _NightLightBlue );
			float3 appendResult99_g128 = (half3(( ( ( (temp_output_43_0_g128).rgb * (temp_output_43_0_g128).a * pow( max( dotResult19_g128 , 0.0 ) , ( _Shininess * 128.0 ) ) * temp_output_40_0_g128 * (tex2D( _SpecMap, uv_SpecMap )).rgb ) + ( ( ( temp_output_40_0_g128 * temp_output_15_0_g128 ) + indirectDiffuse34_g128 ) * (temp_output_42_0_g128).rgb ) ).x + NL_R80_g128 ) , ( ( ( (temp_output_43_0_g128).rgb * (temp_output_43_0_g128).a * pow( max( dotResult19_g128 , 0.0 ) , ( _Shininess * 128.0 ) ) * temp_output_40_0_g128 * (tex2D( _SpecMap, uv_SpecMap )).rgb ) + ( ( ( temp_output_40_0_g128 * temp_output_15_0_g128 ) + indirectDiffuse34_g128 ) * (temp_output_42_0_g128).rgb ) ).y + NL_G81_g128 ) , ( ( ( (temp_output_43_0_g128).rgb * (temp_output_43_0_g128).a * pow( max( dotResult19_g128 , 0.0 ) , ( _Shininess * 128.0 ) ) * temp_output_40_0_g128 * (tex2D( _SpecMap, uv_SpecMap )).rgb ) + ( ( ( temp_output_40_0_g128 * temp_output_15_0_g128 ) + indirectDiffuse34_g128 ) * (temp_output_42_0_g128).rgb ) ).z + NL_B82_g128 )));
			c.rgb = appendResult99_g128;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
	}
	Fallback "Diffuse"
}