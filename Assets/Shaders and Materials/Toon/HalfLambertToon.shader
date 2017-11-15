Shader "Pipeworks_Custom/HalfLambertToon"
{
	Properties
	{
		[Toggle]_UseRampTex("Use Ramp  Tex", Float) = 1
		_ToonRampRGB("Toon Ramp (RGB)", 2D) = "white" {}
		[IntRange]_CellShadingLevels("Cell Shading Levels", Range( 2 , 10)) = 2
		_DiffuseTint("Diffuse Tint", Color) = (0,0,0,0)
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_SpecularIntensity("Specular Intensity", Range( 0 , 10)) = 1
		_GlossSpecPower("Gloss (Spec Power)", Range( 0 , 10)) = 3
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldNormal;
			float3 worldPos;
			half4 data60;
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

		uniform fixed _UseRampTex;
		uniform half _CellShadingLevels;
		uniform sampler2D _ToonRampRGB;
		uniform fixed4 _DiffuseTint;
		uniform half _GlossSpecPower;
		uniform half _SpecularIntensity;
		uniform fixed4 _SpecularColor;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			half3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult50 = normalize( ( ase_worldlightDir + ase_worldViewDir ) );
			float dotResult52 = dot( ase_worldNormal , normalizeResult50 );
			o.data60 = ( pow( max( dotResult52 , 0.0 ) , ( _GlossSpecPower * 128.0 ) ) * _SpecularIntensity * _SpecularColor * _LightColor0 );
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
			float3 normalizeResult6 = normalize( i.worldNormal );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float dotResult2 = dot( normalizeResult6 , ase_worldlightDir );
			float temp_output_24_0 = (0.0 + (dotResult2 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0));
			float temp_output_27_0 = ( temp_output_24_0 * temp_output_24_0 );
			fixed4 temp_cast_0 = (( floor( ( _CellShadingLevels * temp_output_27_0 ) ) / ( _CellShadingLevels - 0.5 ) )).xxxx;
			float2 appendResult29 = (half2(temp_output_27_0 , 0.5));
			fixed4 LIGHTING_DIFFUSE63 = ( lerp(temp_cast_0,tex2D( _ToonRampRGB, appendResult29 ),_UseRampTex) * _LightColor0 * ase_lightAtten * _DiffuseTint );
			fixed4 LIGHTING_SPECULAR64 = i.data60;
			c.rgb = saturate( ( LIGHTING_DIFFUSE63 + LIGHTING_SPECULAR64 ) ).xyz;
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
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			# include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD6;
				float3 worldNormal : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			fixed4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}