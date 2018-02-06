// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pipeworks_Custom/Terrain 16K ASE"
{
	Properties
	{
		[Header(Blinn Phong Light JCOR)]
		_Shininess("Gloss", Range( 0.01 , 1)) = 0.1
		_TessValue( "Max Tessellation", Range( 1, 32 ) ) = 15
		_TessMin( "Tess Min Distance", Float ) = 1
		_TessMax( "Tess Max Distance", Float ) = 700
		_TessPhongStrength( "Phong Tess Strength", Range( 0, 1 ) ) = 0.5
		_BaseTint("Base Tint", Color) = (0,0,0,0)
		[NoScaleOffset]_MainTex0("Main Tex Top Left", 2D) = "white" {}
		[NoScaleOffset]_MainTex1("Main Tex Top Right", 2D) = "white" {}
		[NoScaleOffset]_MainTex2("Main Tex Bottom Left", 2D) = "white" {}
		[NoScaleOffset]_MainTex3("Main Tex Bottom Right", 2D) = "white" {}
		_NormalScale("Normal Scale", Range( 0 , 4)) = 1
		[NoScaleOffset]_NormalMap0("Normal Map Top Left", 2D) = "white" {}
		[NoScaleOffset]_NormalMap1("Normal Map Top Right", 2D) = "white" {}
		[NoScaleOffset]_NormalMap2("Normal Map Bottom Left", 2D) = "white" {}
		[NoScaleOffset]_NormalMap3("Normal Map Bottom Right", 2D) = "white" {}
		[NoScaleOffset]_LSD0("Lights Spec Disp Top Left (RGB)", 2D) = "white" {}
		[NoScaleOffset]_LSD1("Lights Spec Disp Top Right (RGB)", 2D) = "white" {}
		[NoScaleOffset]_LSD2("Lights Spec Disp Bottom Left (RGB)", 2D) = "white" {}
		[NoScaleOffset]_LSD3("Lights Spec Disp Bottom Right (RGB)", 2D) = "white" {}
		_SpecularColor("Specular Color", Color) = (0,0,0,0)
		_DisplacementScale("Displacement Scale", Range( 0 , 0.1)) = 1
		_NightLightsIntensity("Night Lights Intensity", Range( 0 , 2)) = 1
		_NightLightsSoftness("Night Lights Softness", Range( 0.1 , 1)) = 0.3
		_NightLightRed("Night Light Red", Range( 0 , 1)) = 1
		_NightLightGreen("Night Light Green", Range( 0 , 1)) = 0.75
		_NightLightBlue("Night Light Blue", Range( 0 , 1)) = 0.35
		_AtmosphereFar("Atmosphere Far", Color) = (0.359,0.7974198,1,1)
		_AtmosphereNear("Atmosphere Near", Color) = (1,0.3724138,0,1)
		_AtmosphereFalloff("Atmosphere Falloff", Range( 0.1 , 5)) = 5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
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
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf StandardCustomLighting keepalpha nolightmap  nodynlightmap nodirlightmap nofog noforwardadd vertex:vertexDataFunc tessellate:tessFunction tessphong:_TessPhongStrength 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			half2 uv_texcoord;
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
		uniform sampler2D _NormalMap0;
		uniform float4 _NormalMap0_ST;
		uniform sampler2D _NormalMap3;
		uniform sampler2D _NormalMap1;
		uniform sampler2D _NormalMap2;
		uniform half _NormalScale;
		uniform half _Shininess;
		uniform sampler2D _LSD0;
		uniform float4 _LSD0_ST;
		uniform sampler2D _LSD3;
		uniform sampler2D _LSD1;
		uniform sampler2D _LSD2;
		uniform sampler2D _MainTex0;
		uniform float4 _MainTex0_ST;
		uniform sampler2D _MainTex3;
		uniform sampler2D _MainTex1;
		uniform sampler2D _MainTex2;
		uniform half4 _BaseTint;
		uniform half4 _AtmosphereNear;
		uniform half4 _AtmosphereFar;
		uniform half _AtmosphereFalloff;
		uniform fixed _NightLightRed;
		uniform half _NightLightsIntensity;
		uniform half _NightLightsSoftness;
		uniform fixed _NightLightGreen;
		uniform fixed _NightLightBlue;
		uniform half _DisplacementScale;
		uniform half _TessValue;
		uniform half _TessMin;
		uniform half _TessMax;
		uniform half _TessPhongStrength;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, _TessMin, _TessMax, _TessValue );
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float2 uv_LSD0 = v.texcoord.xy * _LSD0_ST.xy + _LSD0_ST.zw;
			half2 LSD_UV442 = uv_LSD0;
			float2 temp_output_443_0 = ( LSD_UV442 * 2.0 );
			fixed3 LSD3465 = (tex2Dlod( _LSD3, half4( ( temp_output_443_0 - float2( 1,0 ) ), 0, 0.0) )).rgb;
			fixed4 BLACK8_g145 = fixed4(0,0,0,0);
			fixed3 LSD1463 = (tex2Dlod( _LSD1, half4( ( temp_output_443_0 - float2( 1,1 ) ), 0, 0.0) )).rgb;
			fixed3 LSD2464 = (tex2Dlod( _LSD2, half4( temp_output_443_0, 0, 0.0) )).rgb;
			fixed3 LSD0462 = (tex2Dlod( _LSD0, half4( ( temp_output_443_0 - float2( 0,1 ) ), 0, 0.0) )).rgb;
			fixed DISP_MAP511 = (( LSD_UV442.x >= 0.5 ) ? (( LSD_UV442.y <= 0.5 ) ? ( half4( LSD3465 , 0.0 ) + BLACK8_g145 ) :  ( half4( LSD1463 , 0.0 ) + BLACK8_g145 ) ) :  (( LSD_UV442.y <= 0.5 ) ? ( half4( LSD2464 , 0.0 ) + BLACK8_g145 ) :  ( half4( LSD0462 , 0.0 ) + BLACK8_g145 ) ) ).z;
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( DISP_MAP511 * _DisplacementScale * ase_vertexNormal );
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
			float4 temp_output_43_0_g147 = _SpecularColor;
			float3 ase_worldPos = i.worldPos;
			half3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float3 normalizeResult4_g148 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float2 uv_NormalMap0 = i.uv_texcoord * _NormalMap0_ST.xy + _NormalMap0_ST.zw;
			half2 NORMALS_UV399 = uv_NormalMap0;
			float2 temp_output_401_0 = ( NORMALS_UV399 * 2.0 );
			half4 N3397 = tex2D( _NormalMap3, ( temp_output_401_0 - float2( 1,0 ) ) );
			fixed4 BLACK8_g144 = fixed4(0,0,0,0);
			half4 N1395 = tex2D( _NormalMap1, ( temp_output_401_0 - float2( 1,1 ) ) );
			half4 N2396 = tex2D( _NormalMap2, temp_output_401_0 );
			half4 N065 = tex2D( _NormalMap0, ( temp_output_401_0 - float2( 0,1 ) ) );
			half4 COMPOSITE_NORMALS412 = (( NORMALS_UV399.x >= 0.5 ) ? (( NORMALS_UV399.y <= 0.5 ) ? ( N3397 + BLACK8_g144 ) :  ( N1395 + BLACK8_g144 ) ) :  (( NORMALS_UV399.y <= 0.5 ) ? ( N2396 + BLACK8_g144 ) :  ( N065 + BLACK8_g144 ) ) );
			float3 localUnpackNormal414 = UnpackScaleNormal( COMPOSITE_NORMALS412 ,_NormalScale );
			float3 appendResult434 = (half3(( localUnpackNormal414.x * -1.0 ) , localUnpackNormal414.y , localUnpackNormal414.z));
			half3 NORMALS429 = appendResult434;
			float3 normalizeResult64_g147 = normalize( WorldNormalVector( i , NORMALS429 ) );
			float dotResult19_g147 = dot( normalizeResult4_g148 , normalizeResult64_g147 );
			float3 temp_output_40_0_g147 = ( _LightColor0.rgb * ase_lightAtten );
			float2 uv_LSD0 = i.uv_texcoord * _LSD0_ST.xy + _LSD0_ST.zw;
			half2 LSD_UV442 = uv_LSD0;
			float2 temp_output_443_0 = ( LSD_UV442 * 2.0 );
			fixed3 LSD3465 = (tex2D( _LSD3, ( temp_output_443_0 - float2( 1,0 ) ) )).rgb;
			fixed4 BLACK8_g145 = fixed4(0,0,0,0);
			fixed3 LSD1463 = (tex2D( _LSD1, ( temp_output_443_0 - float2( 1,1 ) ) )).rgb;
			fixed3 LSD2464 = (tex2D( _LSD2, temp_output_443_0 )).rgb;
			fixed3 LSD0462 = (tex2D( _LSD0, ( temp_output_443_0 - float2( 0,1 ) ) )).rgb;
			fixed SPEC_MAP507 = (( LSD_UV442.x >= 0.5 ) ? (( LSD_UV442.y <= 0.5 ) ? ( half4( LSD3465 , 0.0 ) + BLACK8_g145 ) :  ( half4( LSD1463 , 0.0 ) + BLACK8_g145 ) ) :  (( LSD_UV442.y <= 0.5 ) ? ( half4( LSD2464 , 0.0 ) + BLACK8_g145 ) :  ( half4( LSD0462 , 0.0 ) + BLACK8_g145 ) ) ).y;
			half3 temp_cast_16 = (SPEC_MAP507).xxx;
			float dotResult14_g147 = dot( normalizeResult64_g147 , ase_worldlightDir );
			float temp_output_15_0_g147 = max( dotResult14_g147 , 0.0 );
			UnityGI gi34_g147 = gi;
			float3 diffNorm34_g147 = normalizeResult64_g147;
			gi34_g147 = UnityGI_Base( data, 1, diffNorm34_g147 );
			float3 indirectDiffuse34_g147 = gi34_g147.indirect.diffuse + diffNorm34_g147 * 0.0001;
			float2 uv_MainTex0 = i.uv_texcoord * _MainTex0_ST.xy + _MainTex0_ST.zw;
			half2 MAINTEX_UV315 = uv_MainTex0;
			float2 temp_output_302_0 = ( MAINTEX_UV315 * 2.0 );
			fixed3 C3314 = (tex2D( _MainTex3, ( temp_output_302_0 - float2( 1,0 ) ) )).rgb;
			fixed4 BLACK8_g139 = fixed4(0,0,0,0);
			fixed3 C1312 = (tex2D( _MainTex1, ( temp_output_302_0 - float2( 1,1 ) ) )).rgb;
			fixed3 C2313 = (tex2D( _MainTex2, temp_output_302_0 )).rgb;
			fixed3 C0310 = (tex2D( _MainTex0, ( temp_output_302_0 - float2( 0,1 ) ) )).rgb;
			fixed3 COMPOSITE_MAIN378 = ((( MAINTEX_UV315.x >= 0.5 ) ? (( MAINTEX_UV315.y <= 0.5 ) ? ( half4( C3314 , 0.0 ) + BLACK8_g139 ) :  ( half4( C1312 , 0.0 ) + BLACK8_g139 ) ) :  (( MAINTEX_UV315.y <= 0.5 ) ? ( half4( C2313 , 0.0 ) + BLACK8_g139 ) :  ( half4( C0310 , 0.0 ) + BLACK8_g139 ) ) )).xyz;
			half3 ase_worldNormal = WorldNormalVector( i, half3( 0, 0, 1 ) );
			float fresnelNDotV90 = dot( normalize( ase_worldNormal ), ase_worldViewDir );
			float fresnelNode90 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNDotV90, _AtmosphereFalloff ) );
			float temp_output_105_0 = saturate( fresnelNode90 );
			float3 lerpResult138 = lerp( (_AtmosphereNear).rgb , (_AtmosphereFar).rgb , temp_output_105_0);
			float3 temp_output_153_0 = saturate( ( lerpResult138 * temp_output_105_0 ) );
			half3 ATMOSPHERE142 = temp_output_153_0;
			float4 appendResult432 = (half4(saturate( ( ( COMPOSITE_MAIN378 * ( (_BaseTint).rgb * _BaseTint.a ) ) + ATMOSPHERE142 ) ) , 0.0));
			fixed4 DIFFUSE294 = appendResult432;
			float4 temp_output_42_0_g147 = DIFFUSE294;
			fixed COMPOSITE_NIGHTLIGHTS435 = (( LSD_UV442.x >= 0.5 ) ? (( LSD_UV442.y <= 0.5 ) ? ( half4( LSD3465 , 0.0 ) + BLACK8_g145 ) :  ( half4( LSD1463 , 0.0 ) + BLACK8_g145 ) ) :  (( LSD_UV442.y <= 0.5 ) ? ( half4( LSD2464 , 0.0 ) + BLACK8_g145 ) :  ( half4( LSD0462 , 0.0 ) + BLACK8_g145 ) ) ).x;
			fixed NIGHTLIGHTS467 = saturate( ( COMPOSITE_NIGHTLIGHTS435 * _NightLightsIntensity ) );
			float smoothstepResult111_g147 = smoothstep( 0.0 , _NightLightsSoftness , temp_output_15_0_g147);
			fixed NL_ALPHA85_g147 = ( 1.0 - saturate( ( smoothstepResult111_g147 * 1.0 ) ) );
			float temp_output_84_0_g147 = min( NIGHTLIGHTS467 , NL_ALPHA85_g147 );
			half NL_R80_g147 = ( _NightLightRed * temp_output_84_0_g147 );
			half NL_G81_g147 = ( _NightLightGreen * temp_output_84_0_g147 );
			half NL_B82_g147 = ( temp_output_84_0_g147 * _NightLightBlue );
			float3 appendResult99_g147 = (half3(( ( ( (temp_output_43_0_g147).rgb * (temp_output_43_0_g147).a * pow( max( dotResult19_g147 , 0.0 ) , ( _Shininess * 128.0 ) ) * temp_output_40_0_g147 * temp_cast_16 ) + ( ( ( temp_output_40_0_g147 * temp_output_15_0_g147 ) + indirectDiffuse34_g147 ) * (temp_output_42_0_g147).rgb ) ).x + NL_R80_g147 ) , ( ( ( (temp_output_43_0_g147).rgb * (temp_output_43_0_g147).a * pow( max( dotResult19_g147 , 0.0 ) , ( _Shininess * 128.0 ) ) * temp_output_40_0_g147 * temp_cast_16 ) + ( ( ( temp_output_40_0_g147 * temp_output_15_0_g147 ) + indirectDiffuse34_g147 ) * (temp_output_42_0_g147).rgb ) ).y + NL_G81_g147 ) , ( ( ( (temp_output_43_0_g147).rgb * (temp_output_43_0_g147).a * pow( max( dotResult19_g147 , 0.0 ) , ( _Shininess * 128.0 ) ) * temp_output_40_0_g147 * temp_cast_16 ) + ( ( ( temp_output_40_0_g147 * temp_output_15_0_g147 ) + indirectDiffuse34_g147 ) * (temp_output_42_0_g147).rgb ) ).z + NL_B82_g147 )));
			c.rgb = appendResult99_g147;
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
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=14304
1998;29;1796;1125;544.288;2636.246;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;268;-2192.366,-3837.418;Float;False;1726.069;1247.074;;30;294;58;151;144;158;379;159;157;156;313;314;312;316;318;150;317;297;147;298;299;304;306;308;309;302;303;315;301;310;432;Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;301;-2119.508,-3769.51;Float;True;0;147;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;269;-266.0161,-3828.589;Float;False;2830.692;828.5101;;25;440;467;185;163;466;162;464;462;465;463;449;451;452;450;160;437;438;439;447;445;446;448;443;442;441;Night Lights, Specular, and Displacement;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;303;-1837.507,-3701.51;Float;False;Constant;_FloatConst_2;FloatConst_2;22;0;Create;True;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;315;-1872.507,-3769.51;Half;False;MAINTEX_UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;61;-2198.307,-1899.702;Float;False;1561.773;1099.402;;22;397;65;396;395;429;434;433;414;420;62;394;393;392;63;402;405;403;404;401;400;399;398;Normals;0,0,1,0.5882353;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;302;-1631.507,-3764.51;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;440;-244.833,-3753.858;Float;True;0;160;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;441;126.1691,-3685.858;Float;False;Constant;_Float1;Float 1;22;0;Create;True;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;308;-1400.507,-3580.51;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;306;-1404.507,-3214.511;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;398;-2168.289,-1810.084;Float;True;0;63;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;146;-283.2031,-2344.51;Float;False;1832.302;729.9859;Faux Ground Scatter Effect;12;142;153;141;138;140;105;139;136;137;90;76;251;Atmosphere;0.03448296,1,0,1;0;0
Node;AmplifyShaderEditor.WireNode;309;-1424.507,-3418.51;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;304;-1396.507,-3763.51;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;442;91.1691,-3753.858;Half;False;LSD_UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;400;-1823.289,-1742.084;Float;False;Constant;_Float0;Float 0;22;0;Create;True;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;443;332.1685,-3748.858;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;297;-1218.654,-3608.278;Float;True;Property;_MainTex1;Main Tex Top Right;11;1;[NoScaleOffset];Create;False;None;efc83b3b98af07f498a277cbe5e62e1b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;298;-1217.669,-3425.07;Float;True;Property;_MainTex2;Main Tex Bottom Left;12;1;[NoScaleOffset];Create;False;None;a6c0073ca9d323a469598e1e597959a5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;399;-1858.289,-1810.084;Half;False;NORMALS_UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;299;-1215.669,-3242.071;Float;True;Property;_MainTex3;Main Tex Bottom Right;13;1;[NoScaleOffset];Create;False;None;f7c6daf87d46ecd42a9c03dd6d80b123;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;147;-1221.441,-3791.317;Float;True;Property;_MainTex0;Main Tex Top Left;10;1;[NoScaleOffset];Create;False;None;b3074ab1d3ced204084544ecec896513;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;76;-257.2032,-1831.924;Half;False;Property;_AtmosphereFalloff;Atmosphere Falloff;32;0;Create;True;5;0.66;0.1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;136;-34.39694,-2241.51;Half;False;Property;_AtmosphereNear;Atmosphere Near;31;0;Create;True;1,0.3724138,0,1;0.7426471,0.5287186,0.4017721,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;137;-36.5964,-2078.012;Half;False;Property;_AtmosphereFar;Atmosphere Far;30;0;Create;True;0.359,0.7974198,1,1;0.359,0.7974198,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;448;526.5527,-3424.54;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;445;569.9457,-3201.013;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;401;-1617.288,-1805.084;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;447;563.1688,-3565.935;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;446;567.1688,-3747.858;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;317;-911.6047,-3425.556;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;318;-898.6048,-3242.556;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;316;-907.6047,-3608.556;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;150;-926.4934,-3791.804;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;90;89.0815,-1896.717;Float;False;Tangent;4;0;FLOAT3;0,0,0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;5.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;390;-2191.791,-2555.316;Float;False;995.967;409.2002; Ensures that the"grid" of 2x2 8K main texures won't overlap.;8;378;428;426;383;381;384;382;385;;0.1839857,0.4162503,0.6102941,1;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;139;244.9036,-2148.511;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;313;-681.6078,-3425.878;Fixed;False;C2;-1;True;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;310;-682.2744,-3791.385;Fixed;False;C0;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;312;-683.6078,-3607.878;Fixed;False;C1;-1;True;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;384;-2138.991,-2298.316;Float;False;313;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;385;-2135.991,-2230.316;Float;False;314;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;403;-1386.288,-1621.084;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;382;-2144.991,-2435.316;Float;False;310;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;105;296.61,-1896.674;Float;True;1;0;FLOAT;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;402;-1382.288,-1804.084;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;381;-2172.991,-2505.316;Float;False;315;0;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;404;-1390.288,-1255.087;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;383;-2142.991,-2367.316;Float;False;312;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;314;-679.6078,-3242.878;Fixed;False;C3;-1;True;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;405;-1405.586,-1457.058;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;438;722.9336,-3411.718;Float;True;Property;_LSD2;Lights Spec Disp Bottom Left (RGB);21;1;[NoScaleOffset];Create;False;None;5bfe2db2bb58ccf44972e1706b5f8d12;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;140;250.1037,-2078.312;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;439;723.1963,-3228.386;Float;True;Property;_LSD3;Lights Spec Disp Bottom Right (RGB);22;1;[NoScaleOffset];Create;False;None;7b37853d92a4e734babeede00804bb33;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;437;721.9336,-3593.719;Float;True;Property;_LSD1;Lights Spec Disp Top Right (RGB);20;1;[NoScaleOffset];Create;False;None;1e30a81e8db4e0b4cbfd82f62bfa0124;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;160;720.6001,-3775.617;Float;True;Property;_LSD0;Lights Spec Disp Top Left (RGB);19;1;[NoScaleOffset];Create;False;None;bf5d46b668c52fc41974332823733e87;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;63;-1223.197,-1831.472;Float;True;Property;_NormalMap0;Normal Map Top Left;15;1;[NoScaleOffset];Create;False;None;c05d9e04db0126a4bb723589a49bef3f;True;0;True;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;450;1015.203,-3593.686;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;453;-248.0522,-2965.699;Float;False;1152.967;431.2002; Ensures that the"grid" of 2x2 8K night lights, spec, and displacement texures won't overlap.;10;511;507;435;509;459;457;455;458;454;456;;0.1839857,0.4162503,0.6102941,1;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;452;1013.158,-3228.656;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;413;-2201.43,-764.1;Float;False;845.9005;440.1001; Ensures that the"grid" of 2x2 8K normal map textures won't overlap.;7;412;411;410;409;408;407;427;;0.1839857,0.4162503,0.6102941,1;0;0
Node;AmplifyShaderEditor.ColorNode;156;-2107.407,-2925.692;Half;False;Property;_BaseTint;Base Tint;9;0;Create;True;0,0,0,0;0.915,0.915,0.915,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;138;520.4578,-2096.164;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0.0,0,0;False;2;FLOAT;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;393;-1220.509,-1466.847;Float;True;Property;_NormalMap2;Normal Map Bottom Left;17;1;[NoScaleOffset];Create;False;None;85e5992790e849e41ad515bb85e50381;True;0;True;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;426;-1901.99,-2409.316;Float;False;2x2 Texture Composite;-1;;139;1061a8dc84adbde4e9b833b4bb0fde24;0;5;10;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;451;1017.203,-3411.685;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;449;1008.203,-3775.687;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;394;-1220.509,-1282.848;Float;True;Property;_NormalMap3;Normal Map Bottom Right;18;1;[NoScaleOffset];Create;False;None;56d26c42a8e2618448ba0b6c7027fd88;True;0;True;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;392;-1223.509,-1648.846;Float;True;Property;_NormalMap1;Normal Map Top Right;16;1;[NoScaleOffset];Create;False;None;ebd1ea588cb27c1468c48f9c8997cdc6;True;0;True;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;457;-199.2525,-2777.698;Float;False;463;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;741.9979,-1919.65;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;455;-192.2511,-2640.698;Float;False;465;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;409;-2126.43,-575.1001;Float;False;395;0;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;454;-201.2525,-2845.698;Float;False;462;0;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;428;-1644.175,-2414.277;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;397;-897.2658,-1282.895;Half;False;N3;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;407;-2151.43,-714.1;Float;False;399;0;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;463;1224.93,-3594.118;Fixed;False;LSD1;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;395;-896.2658,-1647.894;Half;False;N1;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;411;-2122.43,-435.1;Float;False;397;0;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;456;-200.6523,-2918.298;Float;False;442;0;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;465;1223.93,-3229.117;Fixed;False;LSD3;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;157;-1862.406,-2925.692;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;410;-2125.43,-505.1002;Float;False;396;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-895.1046,-1831.181;Half;False;N0;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;462;1219.93,-3776.119;Fixed;False;LSD0;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;458;-195.2525,-2708.698;Float;False;464;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;408;-2128.43,-645.1;Float;False;65;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;464;1229.93,-3412.117;Fixed;False;LSD2;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;396;-898.2658,-1466.895;Half;False;N2;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;153;888.9379,-1920.484;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;459;41.74802,-2819.698;Float;False;2x2 Texture Composite;-1;;145;1061a8dc84adbde4e9b833b4bb0fde24;0;5;10;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;378;-1426.422,-2414.631;Fixed;False;COMPOSITE_MAIN;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;-1642.157,-2920.456;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;427;-1886.43,-616.1;Float;False;2x2 Texture Composite;-1;;144;1061a8dc84adbde4e9b833b4bb0fde24;0;5;10;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;379;-1743.913,-2993.679;Float;False;378;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;412;-1625.43,-621.1;Half;False;COMPOSITE_NORMALS;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;420;-2125.189,-1059.376;Float;False;412;0;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2134.635,-987.7259;Half;False;Property;_NormalScale;Normal Scale;14;0;Create;True;1;1;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;509;294.6605,-2819.628;Float;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;144;-1650.551,-2822.276;Float;True;142;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;142;1237.398,-1926.65;Half;False;ATMOSPHERE;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;-1489.658,-2966.833;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;435;591.3717,-2870.279;Fixed;False;COMPOSITE_NIGHTLIGHTS;-1;True;1;0;FLOAT;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;151;-1330.097,-2939.375;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;162;1743.839,-3703.73;Half;False;Property;_NightLightsIntensity;Night Lights Intensity;25;0;Create;True;1;0.95;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;466;1726.106,-3774.105;Float;False;435;0;1;FLOAT;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;414;-1857.167,-1030.435;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1.0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;469;-1420.405,-5218.74;Float;False;1948.436;869.4141;;12;0;470;274;181;260;183;145;295;468;293;182;286;MASTER;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;2017.838,-3746.43;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;58;-1196.093,-2938.009;Float;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;433;-1607.779,-1029.813;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;-1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;286;-365.1496,-4805.626;Float;False;528;345;Displacement Map;4;512;284;288;283;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;434;-1460.779,-1007.813;Float;False;FLOAT3;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;185;2160.957,-3746.078;Float;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;432;-1001.314,-2937.355;Float;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;293;-1280.127,-4947.752;Float;False;507;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;468;-1302.794,-4739.918;Float;False;467;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;467;2335.224,-3752.134;Fixed;False;NIGHTLIGHTS;-1;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;182;-1363.909,-4600.252;Fixed;False;Property;_NightLightGreen;Night Light Green;28;0;Create;True;0.75;0.835;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;294;-846.408,-2942.063;Fixed;False;DIFFUSE;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalVertexDataNode;288;-229.492,-4611.112;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;511;589.0933,-2735.271;Fixed;False;DISP_MAP;-1;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;295;-1269.444,-4878.299;Float;False;294;0;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;429;-1322.447,-1012.894;Half;False;NORMALS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;-1273.38,-4809.663;Float;False;429;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;183;-1361.909,-4530.252;Fixed;False;Property;_NightLightBlue;Night Light Blue;29;0;Create;True;0.35;0.35;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;260;-1336.9,-5114.229;Half;False;Property;_SpecularColor;Specular Color;23;0;Create;True;0,0,0,0;0.609,0.6077723,0.565152,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;181;-1364.909,-4669.252;Fixed;False;Property;_NightLightRed;Night Light Red;27;0;Create;True;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;274;-1361.766,-4459.975;Float;False;Property;_NightLightsSoftness;Night Lights Softness;26;0;Create;True;0.3;0.3;0.1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;507;589.6884,-2802.112;Fixed;False;SPEC_MAP;-1;True;1;0;FLOAT;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;283;-317.1498,-4681.626;Float;False;Property;_DisplacementScale;Displacement Scale;24;0;Create;True;1;0.002;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;512;-230.2294,-4755.533;Float;False;511;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;470;-975.576,-4871.102;Float;False;Blinn-Phong Light JCOR;0;;147;abf9cb092ab53d741a85db181c4b9f11;0;10;43;COLOR;0,0,0,0;False;100;FLOAT3;0,0,0;False;42;COLOR;0,0,0,0;False;52;FLOAT3;0,0,0;False;77;FLOAT;0.0;False;70;FLOAT;0.0;False;74;FLOAT;0.0;False;76;FLOAT;0.0;False;69;FLOAT;0.0;False;113;FLOAT;0.0;False;2;FLOAT3;0;FLOAT;57
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;284;25.84977,-4750.626;Float;False;3;3;0;FLOAT;0,0,0;False;1;FLOAT;0,0,0;False;2;FLOAT3;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;251;1054.707,-1980.145;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;250.3412,-5095.563;Half;False;True;6;Half;ASEMaterialInspector;0;0;CustomLighting;Pipeworks_Custom/Terrain 16K ASE;False;False;False;False;False;False;True;True;True;True;False;True;False;False;False;False;False;Back;0;0;False;0;0;False;0;Opaque;0.5;True;False;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;False;0;255;255;0;0;0;0;0;0;0;0;True;0;15;1;700;True;0.5;True;0;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;4;0;0;0;False;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0.0,0,0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;315;0;301;0
WireConnection;302;0;315;0
WireConnection;302;1;303;0
WireConnection;308;0;302;0
WireConnection;306;0;302;0
WireConnection;309;0;302;0
WireConnection;304;0;302;0
WireConnection;442;0;440;0
WireConnection;443;0;442;0
WireConnection;443;1;441;0
WireConnection;297;1;308;0
WireConnection;298;1;309;0
WireConnection;399;0;398;0
WireConnection;299;1;306;0
WireConnection;147;1;304;0
WireConnection;448;0;443;0
WireConnection;445;0;443;0
WireConnection;401;0;399;0
WireConnection;401;1;400;0
WireConnection;447;0;443;0
WireConnection;446;0;443;0
WireConnection;317;0;298;0
WireConnection;318;0;299;0
WireConnection;316;0;297;0
WireConnection;150;0;147;0
WireConnection;90;3;76;0
WireConnection;139;0;136;0
WireConnection;313;0;317;0
WireConnection;310;0;150;0
WireConnection;312;0;316;0
WireConnection;403;0;401;0
WireConnection;105;0;90;0
WireConnection;402;0;401;0
WireConnection;404;0;401;0
WireConnection;314;0;318;0
WireConnection;405;0;401;0
WireConnection;438;1;448;0
WireConnection;140;0;137;0
WireConnection;439;1;445;0
WireConnection;437;1;447;0
WireConnection;160;1;446;0
WireConnection;63;1;402;0
WireConnection;450;0;437;0
WireConnection;452;0;439;0
WireConnection;138;0;139;0
WireConnection;138;1;140;0
WireConnection;138;2;105;0
WireConnection;393;1;405;0
WireConnection;426;10;381;0
WireConnection;426;1;382;0
WireConnection;426;2;383;0
WireConnection;426;3;384;0
WireConnection;426;4;385;0
WireConnection;451;0;438;0
WireConnection;449;0;160;0
WireConnection;394;1;404;0
WireConnection;392;1;403;0
WireConnection;141;0;138;0
WireConnection;141;1;105;0
WireConnection;428;0;426;0
WireConnection;397;0;394;0
WireConnection;463;0;450;0
WireConnection;395;0;392;0
WireConnection;465;0;452;0
WireConnection;157;0;156;0
WireConnection;65;0;63;0
WireConnection;462;0;449;0
WireConnection;464;0;451;0
WireConnection;396;0;393;0
WireConnection;153;0;141;0
WireConnection;459;10;456;0
WireConnection;459;1;454;0
WireConnection;459;2;457;0
WireConnection;459;3;458;0
WireConnection;459;4;455;0
WireConnection;378;0;428;0
WireConnection;159;0;157;0
WireConnection;159;1;156;4
WireConnection;427;10;407;0
WireConnection;427;1;408;0
WireConnection;427;2;409;0
WireConnection;427;3;410;0
WireConnection;427;4;411;0
WireConnection;412;0;427;0
WireConnection;509;0;459;0
WireConnection;142;0;153;0
WireConnection;158;0;379;0
WireConnection;158;1;159;0
WireConnection;435;0;509;0
WireConnection;151;0;158;0
WireConnection;151;1;144;0
WireConnection;414;0;420;0
WireConnection;414;1;62;0
WireConnection;163;0;466;0
WireConnection;163;1;162;0
WireConnection;58;0;151;0
WireConnection;433;0;414;1
WireConnection;434;0;433;0
WireConnection;434;1;414;2
WireConnection;434;2;414;3
WireConnection;185;0;163;0
WireConnection;432;0;58;0
WireConnection;467;0;185;0
WireConnection;294;0;432;0
WireConnection;511;0;509;2
WireConnection;429;0;434;0
WireConnection;507;0;509;1
WireConnection;470;43;260;0
WireConnection;470;100;293;0
WireConnection;470;42;295;0
WireConnection;470;52;145;0
WireConnection;470;77;468;0
WireConnection;470;70;181;0
WireConnection;470;74;182;0
WireConnection;470;76;183;0
WireConnection;470;113;274;0
WireConnection;284;0;512;0
WireConnection;284;1;283;0
WireConnection;284;2;288;0
WireConnection;251;0;153;0
WireConnection;0;13;470;0
WireConnection;0;11;284;0
ASEEND*/
//CHKSM=F22AF257E640ABFF09E413F4289ACD3CAD3A7B7B