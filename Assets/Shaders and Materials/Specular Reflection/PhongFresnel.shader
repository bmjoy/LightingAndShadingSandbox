Shader "Pipeworks_Custom/Phong Fresnel"
{
	Properties
	{
		_BaseTint("Base Tint", Color) = (0.6397059,0.620891,0.620891,1)
		_BaseRGB("Base (RGB)", 2D) = "white" {}
		_RimColor("Rim Color", Color) = (0,1,1,1)
		_RimPower("Rim Power", Range( 0.1 , 10)) = 5
		[Toggle]_SpecularEnable("SpecularEnable", Float) = 0
		_SpecularColor("Specular Color", Color) = (0.9191176,0.5205312,0.2840074,1)
		_SpecularIntensity("Specular Intensity", Range( 0 , 10)) = 1
		_SpecularPower("Specular Power", Range( 0.001 , 1)) = 0.2
		_Normals("Normals", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 4)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting keepalpha noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd
		struct Input
		{
			float3 worldPos;
			half2 uv_texcoord;
			INTERNAL_DATA
			float3 worldNormal;
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

		uniform half4 _RimColor;
		uniform half _NormalScale;
		uniform sampler2D _Normals;
		uniform float4 _Normals_ST;
		uniform half _RimPower;
		uniform half4 _BaseTint;
		uniform sampler2D _BaseRGB;
		uniform float4 _BaseRGB_ST;
		uniform fixed _SpecularEnable;
		uniform half _SpecularPower;
		uniform half _SpecularIntensity;
		uniform fixed4 _SpecularColor;

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
			float2 uv_Normals = i.uv_texcoord * _Normals_ST.xy + _Normals_ST.zw;
			half3 tex2DNode63 = UnpackScaleNormal( tex2D( _Normals, uv_Normals ) ,_NormalScale );
			float3 temp_output_93_0 = ( (tex2DNode63).xyz * _NormalScale );
			float dotResult94 = dot( temp_output_93_0 , temp_output_93_0 );
			float3 appendResult99 = (half3(temp_output_93_0.x , temp_output_93_0.y , sqrt( ( 1.0 - saturate( dotResult94 ) ) )));
			#ifdef UNITY_NO_DXT5nm
				float3 staticSwitch101 = appendResult99;
			#else
				float3 staticSwitch101 = (tex2DNode63).xyz;
			#endif
			half3 NORMALS65 = staticSwitch101;
			float3 newWorldNormal22_g100 = WorldNormalVector( i , NORMALS65 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float dotResult3_g102 = dot( newWorldNormal22_g100 , ase_worldlightDir );
			float temp_output_6_0_g101 = (saturate( max( dotResult3_g102 , 0.0 ) )*0.5 + ( 1.0 - 0.5 ));
			float3 normalizeResult24_g100 = normalize( newWorldNormal22_g100 );
			UnityGI gi37_g100 = gi;
			float3 diffNorm37_g100 = normalizeResult24_g100;
			gi37_g100 = UnityGI_Base( data, 1, diffNorm37_g100 );
			float3 indirectDiffuse37_g100 = gi37_g100.indirect.diffuse + diffNorm37_g100 * 0.0001;
			float2 uv_BaseRGB = i.uv_texcoord * _BaseRGB_ST.xy + _BaseRGB_ST.zw;
			float4 temp_output_28_0_g100 = tex2D( _BaseRGB, uv_BaseRGB );
			float4 appendResult107 = (half4(( ( ( saturate( max( ( temp_output_6_0_g101 * temp_output_6_0_g101 ) , 0.0 ) ) * ( _LightColor0.rgb * ase_lightAtten ) ) + indirectDiffuse37_g100 ) * (_BaseTint).rgb * (temp_output_28_0_g100).rgb ) , (temp_output_28_0_g100).a));
			fixed4 DIFFUSE8 = appendResult107;
			fixed TINT_A115 = _BaseTint.a;
			half3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNDotV90 = dot( WorldNormalVector( i , NORMALS65 ), ase_worldViewDir );
			float fresnelNode90 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNDotV90, _RimPower ) );
			fixed FRESNEL126 = fresnelNode90;
			float lerpResult117 = lerp( ( (DIFFUSE8).a * TINT_A115 ) , 1.0 , FRESNEL126);
			float3 temp_output_3_0_g104 = ase_worldlightDir;
			float3 temp_output_2_0_g104 = WorldNormalVector( i , NORMALS65 );
			float dotResult5_g104 = dot( temp_output_3_0_g104 , temp_output_2_0_g104 );
			float dotResult7_g103 = dot( ase_worldViewDir , ( ( 2.0 * saturate( max( dotResult5_g104 , 0.0 ) ) * temp_output_2_0_g104 ) - temp_output_3_0_g104 ) );
			fixed3 SPECULAR22 = ( pow( saturate( max( dotResult7_g103 , 0.0 ) ) , ( _SpecularPower * 128.0 ) ) * _SpecularIntensity * (_SpecularColor).rgb * _LightColor0.rgb * ase_lightAtten );
			c.rgb = saturate( ( (DIFFUSE8).rgb + lerp(float3( 0,0,0 ),SPECULAR22,_SpecularEnable) ) );
			c.a = lerpResult117;
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
			float3 ase_worldPos = i.worldPos;
			half3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_Normals = i.uv_texcoord * _Normals_ST.xy + _Normals_ST.zw;
			half3 tex2DNode63 = UnpackScaleNormal( tex2D( _Normals, uv_Normals ) ,_NormalScale );
			float3 temp_output_93_0 = ( (tex2DNode63).xyz * _NormalScale );
			float dotResult94 = dot( temp_output_93_0 , temp_output_93_0 );
			float3 appendResult99 = (half3(temp_output_93_0.x , temp_output_93_0.y , sqrt( ( 1.0 - saturate( dotResult94 ) ) )));
			#ifdef UNITY_NO_DXT5nm
				float3 staticSwitch101 = appendResult99;
			#else
				float3 staticSwitch101 = (tex2DNode63).xyz;
			#endif
			half3 NORMALS65 = staticSwitch101;
			float fresnelNDotV90 = dot( WorldNormalVector( i , NORMALS65 ), ase_worldViewDir );
			float fresnelNode90 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNDotV90, _RimPower ) );
			o.Emission = saturate( ( (_RimColor).rgb * _RimColor.a * fresnelNode90 ) );
		}

		ENDCG
	}
	Fallback "Legacy Shaders/Transparent/Diffuse"
}