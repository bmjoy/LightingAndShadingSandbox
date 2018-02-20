// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pipeworks_Custom/Terrain Scatter ASE"
{
	Properties
	{
		_BaseTint("Base Tint", Color) = (0,0,0,0)
		[NoScaleOffset]_MainTex("Main Tex", 2D) = "white" {}
		[Header(Blinn Phong Light JCOR)]
		_Gloss("Gloss", Range( 0.01 , 1)) = 0.1
		_ScatterBlend("Scatter Blend", Range( 0 , 1)) = 0
		_RayleighScatterMultiplier("Rayleigh Scatter Multiplier", Range( 5 , 500)) = 50
		_RayleighScatterBias("Rayleigh Scatter Bias", Range( 0 , 10)) = 4.55
		_SpecularColor("Specular Color", Color) = (0,0,0,0)
		_SpecMap("Spec Map", 2D) = "black" {}
		[NoScaleOffset]_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 4)) = 1
		[Toggle]_EnableFauxAtmosphere("Enable Faux Atmosphere", Float) = 1
		_AtmosphereFar("Atmosphere Far", Color) = (0.359,0.7974198,1,1)
		_AtmosphereNear("Atmosphere Near", Color) = (1,0.3724138,0,1)
		_AtmosphereFalloff("Atmosphere Falloff", Range( 0.1 , 5)) = 0.66
		[NoScaleOffset]_NightLights("Night Lights", 2D) = "black" {}
		_NightLightsIntensity("Night Lights Intensity", Range( 0 , 2)) = 1
		_NightLightsSoftness("Night Lights Softness", Range( 0.1 , 1)) = 0.3
		_NightLightRed("Night Light Red", Range( 0 , 1)) = 1
		_NightLightGreen("Night Light Green", Range( 0 , 1)) = 0.75
		_NightLightBlue("Night Light Blue", Range( 0 , 1)) = 0.35
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
		#pragma target 4.6
		#pragma surface surf StandardCustomLighting keepalpha nolightmap  nodynlightmap nodirlightmap nofog noforwardadd vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			half2 uv_texcoord;
			half3 vertexToFrag251;
			half3 vertexToFrag541;
			half3 vertexToFrag540;
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
		uniform half _Gloss;
		uniform sampler2D _SpecMap;
		uniform float4 _SpecMap_ST;
		uniform half _EnableFauxAtmosphere;
		uniform sampler2D _MainTex;
		uniform half4 _BaseTint;
		uniform half4 _AtmosphereNear;
		uniform half4 _AtmosphereFar;
		uniform half _AtmosphereFalloff;
		uniform half fScaleOverScaleDepth;
		uniform half fInnerRadius;
		uniform half3 v3Translate;
		uniform half fScaleHeight;
		uniform half3 v3LightPos;
		uniform half fOuterRadius;
		uniform half3 v3InvWavelength;
		uniform half fKr4PI;
		uniform half _RayleighScatterMultiplier;
		uniform half _RayleighScatterBias;
		uniform half fKm4PI;
		uniform half fOuterRadius2;
		uniform half fScale;
		uniform half fKrESun;
		uniform half fKmESun;
		uniform half fHdrExposure;
		uniform half _ScatterBlend;
		uniform fixed _NightLightRed;
		uniform sampler2D _NightLights;
		uniform half _NightLightsIntensity;
		uniform half _NightLightsSoftness;
		uniform fixed _NightLightGreen;
		uniform fixed _NightLightBlue;


		float ScaleCameraAngle310( float fCos , float scaleHeight )
		{
			float x = 1.0 - fCos;
			return scaleHeight * exp(-0.00287 + x * (0.459 + x * (3.83 + x * (-6.80 + x * 5.25))));
		}


		float ScaleLightAngle387( float fCos , float scaleHeight )
		{
			float x = 1.0 - fCos;
			return scaleHeight * exp(-0.00287 + x * (0.459 + x * (3.83 + x * (-6.80 + x * 5.25))));
		}


		float3x3 ScatterLoop417( float samples , float scaleOverScaleDepth , float innerRadius , float temp , float cameraOffset , float3 invWavelength , float kr4Pi , float km4Pi , float3 samplePoint , float scaledLength , float3 sampleRay )
		{
			float3 v3FrontColor = float3(0.0, 0.0, 0.0);
			float3 v3Attenuate = float3(0.0, 0.0, 0.0);
			float3 v3SamplePoint = samplePoint;
			for(int i = 0; i < int(samples); i++)
			{
				float fHeight = length(v3SamplePoint);
				float fDepth = exp(scaleOverScaleDepth * (innerRadius - fHeight));
				float fScatter = (fDepth * temp) - cameraOffset;
				v3Attenuate = exp(-fScatter * ((invWavelength * kr4Pi) + km4Pi));
				v3FrontColor += v3Attenuate * (fDepth * scaledLength);
				v3SamplePoint += sampleRay;
			}
			return float3x3(
				v3FrontColor.x, v3FrontColor.y, v3FrontColor.z,
				v3Attenuate.x, v3Attenuate.y, v3Attenuate.z,
				0.0, 0.0, 0.0
			);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			half3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			half3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float fresnelNDotV90 = dot( normalize( ase_worldNormal ), ase_worldViewDir );
			float fresnelNode90 = ( 0 + 1 * pow( 1.0 - fresnelNDotV90, _AtmosphereFalloff ) );
			float temp_output_105_0 = saturate( fresnelNode90 );
			float3 lerpResult138 = lerp( (_AtmosphereNear).rgb , (_AtmosphereFar).rgb , temp_output_105_0);
			float fresnel492 = temp_output_105_0;
			o.vertexToFrag251 = saturate( ( lerpResult138 * fresnel492 ) );
			float samples417 = (float)2;
			float scaleOverScaleDepth417 = fScaleOverScaleDepth;
			float fInnerRadius422 = fInnerRadius;
			float innerRadius417 = fInnerRadius422;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 transform537 = mul(unity_ObjectToWorld,half4( ase_vertex3Pos , 0.0 ));
			float3 v3Pos321 = ( (transform537).xyz - v3Translate );
			float3 v3CameraPos315 = ( _WorldSpaceCameraPos - v3Translate );
			float3 temp_output_322_0 = ( v3Pos321 - v3CameraPos315 );
			float temp_output_323_0 = length( temp_output_322_0 );
			float3 v3Ray330 = ( temp_output_322_0 / temp_output_323_0 );
			float dotResult372 = dot( ( v3Ray330 * -1 ) , v3Pos321 );
			float temp_output_375_0 = length( v3Pos321 );
			float fCameraAngle377 = ( dotResult372 / temp_output_375_0 );
			float fCos310 = fCameraAngle377;
			float scaleHeight310 = fScaleHeight;
			float localScaleCameraAngle310 = ScaleCameraAngle310( fCos310 , scaleHeight310 );
			float3 v3LightPosition427 = v3LightPos;
			float dotResult380 = dot( v3LightPosition427 , v3Pos321 );
			float fLightAngle382 = ( dotResult380 / temp_output_375_0 );
			float fCos387 = fLightAngle382;
			float scaleHeight387 = fScaleHeight;
			float localScaleLightAngle387 = ScaleLightAngle387( fCos387 , scaleHeight387 );
			float fTemp392 = ( localScaleCameraAngle310 + localScaleLightAngle387 );
			float temp417 = fTemp392;
			float fDepth367 = exp( ( ( fInnerRadius - fOuterRadius ) / fScaleHeight ) );
			float fCameraOffset390 = ( fDepth367 * localScaleCameraAngle310 );
			float cameraOffset417 = fCameraOffset390;
			float3 v3InverseWavelength442 = v3InvWavelength;
			float3 invWavelength417 = v3InverseWavelength442;
			float rayleighMult586 = _RayleighScatterMultiplier;
			float rayleighBias580 = _RayleighScatterBias;
			float kr4Pi417 = ( ( fKr4PI * rayleighMult586 ) + rayleighBias580 );
			float km4Pi417 = fKm4PI;
			float dotResult331 = dot( v3Ray330 , v3CameraPos315 );
			float temp_output_397_0 = ( dotResult331 * 2 );
			float temp_output_313_0 = length( v3CameraPos315 );
			float temp_output_385_0 = ( ( ( temp_output_397_0 * -1 ) - sqrt( max( ( ( temp_output_397_0 * temp_output_397_0 ) - ( ( ( temp_output_313_0 * temp_output_313_0 ) - fOuterRadius2 ) * 4 ) ) , 0 ) ) ) * 0.5 );
			float3 v3Start354 = ( v3CameraPos315 + ( temp_output_385_0 * v3Ray330 ) );
			float fNear526 = temp_output_385_0;
			float fFar362 = ( temp_output_323_0 - fNear526 );
			float temp_output_401_0 = ( fFar362 / 2.0 );
			float3 v3SampleRay407 = ( v3Ray330 * temp_output_401_0 );
			float3 v3SamplePoint411 = ( v3Start354 + ( v3SampleRay407 * 0.5 ) );
			float3 samplePoint417 = v3SamplePoint411;
			float fScaledLength404 = ( temp_output_401_0 * fScale );
			float scaledLength417 = fScaledLength404;
			float3 sampleRay417 = v3SampleRay407;
			float3x3 localScatterLoop417 = ScatterLoop417( samples417 , scaleOverScaleDepth417 , innerRadius417 , temp417 , cameraOffset417 , invWavelength417 , kr4Pi417 , km4Pi417 , samplePoint417 , scaledLength417 , sampleRay417 );
			float3 appendResult434 = (half3(localScatterLoop417[ 0 ][ 0 ] , localScatterLoop417[ 0 ][ 1 ] , localScatterLoop417[ 0 ][ 2 ]));
			o.vertexToFrag541 = ( appendResult434 * ( ( v3InverseWavelength442 * ( ( fKrESun * rayleighMult586 ) + rayleighBias580 ) ) + fKmESun ) );
			float3 appendResult436 = (half3(localScatterLoop417[ 1 ][ 0 ] , localScatterLoop417[ 1 ][ 1 ] , localScatterLoop417[ 1 ][ 2 ]));
			o.vertexToFrag540 = appendResult436;
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
			float4 temp_output_43_0_g3 = _SpecularColor;
			float3 ase_worldPos = i.worldPos;
			half3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float3 normalizeResult4_g4 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float2 uv_NormalMap63 = i.uv_texcoord;
			half3 NORMALS65 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap63 ) ,_NormalScale );
			float3 normalizeResult64_g3 = normalize( WorldNormalVector( i , NORMALS65 ) );
			float dotResult19_g3 = dot( normalizeResult4_g4 , normalizeResult64_g3 );
			float3 temp_output_40_0_g3 = ( _LightColor0.rgb * ase_lightAtten );
			float2 uv_SpecMap = i.uv_texcoord * _SpecMap_ST.xy + _SpecMap_ST.zw;
			float3 SPEC131_g3 = ( (temp_output_43_0_g3).rgb * (temp_output_43_0_g3).a * pow( max( dotResult19_g3 , 0 ) , ( _Gloss * 128 ) ) * temp_output_40_0_g3 * (tex2D( _SpecMap, uv_SpecMap )).rgb );
			float dotResult14_g3 = dot( normalizeResult64_g3 , ase_worldlightDir );
			float temp_output_15_0_g3 = max( dotResult14_g3 , 0 );
			UnityGI gi34_g3 = gi;
			float3 diffNorm34_g3 = normalizeResult64_g3;
			gi34_g3 = UnityGI_Base( data, 1, diffNorm34_g3 );
			float3 indirectDiffuse34_g3 = gi34_g3.indirect.diffuse + diffNorm34_g3 * 0.0001;
			float2 uv_MainTex147 = i.uv_texcoord;
			float3 temp_output_158_0 = ( (tex2D( _MainTex, uv_MainTex147 )).rgb * ( (_BaseTint).rgb * _BaseTint.a ) );
			half3 ATMOSPHERE142 = i.vertexToFrag251;
			float3 DIFFUSE459 = saturate( lerp(temp_output_158_0,( temp_output_158_0 + ATMOSPHERE142 ),_EnableFauxAtmosphere) );
			float4 temp_output_42_0_g3 = half4( DIFFUSE459 , 0.0 );
			float3 OUTC0542 = i.vertexToFrag541;
			float3 OUTC1543 = i.vertexToFrag540;
			float3 temp_output_479_0 = ( 1.0 - exp( ( ( OUTC0542 + ( OUTC1543 * 0.25 ) ) * ( fHdrExposure * -1 ) ) ) );
			float scatterAtten497 = (temp_output_479_0).z;
			float3 scatterColor498 = temp_output_479_0;
			float3 scatterDiffuse120_g3 = ( ( (temp_output_42_0_g3).rgb * scatterAtten497 ) + scatterColor498 );
			float3 lerpResult134_g3 = lerp( ( SPEC131_g3 + ( ( ( temp_output_40_0_g3 * temp_output_15_0_g3 ) + indirectDiffuse34_g3 ) * (temp_output_42_0_g3).rgb ) ) , ( SPEC131_g3 + scatterDiffuse120_g3 ) , _ScatterBlend);
			float2 uv_NightLights160 = i.uv_texcoord;
			fixed NIGHTLIGHTS462 = saturate( ( (tex2D( _NightLights, uv_NightLights160 )).r * _NightLightsIntensity ) );
			float smoothstepResult111_g3 = smoothstep( 0 , _NightLightsSoftness , temp_output_15_0_g3);
			fixed NL_ALPHA85_g3 = ( 1.0 - saturate( smoothstepResult111_g3 ) );
			float temp_output_84_0_g3 = min( NIGHTLIGHTS462 , NL_ALPHA85_g3 );
			half NL_R80_g3 = ( _NightLightRed * temp_output_84_0_g3 );
			half NL_G81_g3 = ( _NightLightGreen * temp_output_84_0_g3 );
			half NL_B82_g3 = ( temp_output_84_0_g3 * _NightLightBlue );
			float3 appendResult99_g3 = (half3(( lerpResult134_g3.x + NL_R80_g3 ) , ( lerpResult134_g3.y + NL_G81_g3 ) , ( lerpResult134_g3.z + NL_B82_g3 )));
			c.rgb = appendResult99_g3;
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
Version=14406
1957;50;1819;1125;4417.395;532.1599;3.459846;True;True
Node;AmplifyShaderEditor.CommentaryNode;464;-2873.091,206.8116;Float;False;3481.872;2577.972;;115;580;577;586;584;486;441;485;304;581;587;582;585;303;296;583;588;301;589;319;542;541;543;447;540;434;436;445;302;431;444;443;578;417;423;442;390;422;425;404;392;426;411;418;307;391;389;409;403;367;410;354;387;310;388;305;408;407;353;363;393;377;394;382;352;381;406;376;365;350;405;306;380;364;375;372;351;362;299;400;527;398;297;373;528;378;427;357;294;526;358;525;346;396;343;384;340;523;317;522;298;313;330;325;521;324;520;315;321;320;314;311;293;538;537;533;Ground Atmospheric Scattering;0.05862069,0.5,0,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;533;-2689.425,1020.529;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;537;-2483.425,1020.529;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceCameraPos;311;-2391.912,613.7674;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;293;-2301.116,745.1205;Float;False;Global;v3Translate;v3Translate;16;1;[HideInInspector];Create;True;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;538;-2292.425,1015.529;Float;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;320;-2104.473,808.7987;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;314;-2127.873,670.9244;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;520;-1699.079,760.2897;Float;False;152;142;v3Ray Temp;1;322;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;315;-1988.873,665.9244;Float;False;v3CameraPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;321;-1962.08,804.2897;Float;False;v3Pos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;322;-1688.079,810.2897;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;324;-1496.079,761.2893;Float;False;135;122;fFar Temp;1;323;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LengthOpNode;323;-1485.079,811.2897;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;325;-1319.079,949.2895;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;521;-1910.836,429.2345;Float;False;472.6951;166.676;B;3;331;334;397;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;334;-1901.836,498.3615;Float;False;330;0;1;FLOAT3;0
Node;AmplifyShaderEditor.LengthOpNode;313;-1750.873,670.9244;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;330;-1183.946,943.9066;Float;False;v3Ray;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;317;-1618.872,659.9244;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;331;-1718.55,503.9105;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;298;-1325.005,731.1355;Float;False;Global;fOuterRadius2;fOuterRadius2;16;1;[HideInInspector];Create;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;522;-1135.718,610.0865;Float;False;156;145;C;1;337;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleNode;397;-1578.141,479.2345;Float;False;2;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;337;-1120.718,660.0865;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;384;-939.1522,659.0965;Float;False;4;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;340;-1356.718,502.0866;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;523;-762.4177,452.6864;Float;False;274;144;fDet;2;339;341;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;341;-753.4177,502.6864;Float;False;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;339;-608.4178,502.6864;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;396;-1360.141,396.2345;Float;False;-1;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;343;-465.4177,501.6864;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;525;-176.152,348.0966;Float;False;145;122;fNear;1;385;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;346;-333.4178,397.6864;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;385;-167.152,398.0966;Float;False;0.5;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;526;9.084717,257.0868;Float;False;fNear;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;358;-1319.221,870.8106;Float;False;526;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;357;-1111.221,811.8107;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;294;-1148.11,1121.882;Float;False;Global;v3LightPos;v3LightPos;16;1;[HideInInspector];Create;True;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleNode;527;-962.9322,948.9622;Float;False;-1;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;398;-2327.409,1570.179;Float;False;362;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;400;-2306.973,1663.302;Float;False;Constant;_Samples;Samples;16;0;Create;True;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;362;-971.2214,806.8107;Float;False;fFar;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;299;-694.7886,646.9855;Float;False;Global;fInnerRadius;fInnerRadius;16;1;[HideInInspector];Create;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;378;-1156.661,1260.546;Float;False;321;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;427;-983.9349,1121.89;Float;False;v3LightPosition;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;528;-2135.41,1559.179;Float;False;152;143;fSampleLength;1;401;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;297;-702.7886,736.9854;Float;False;Global;fOuterRadius;fOuterRadius;16;1;[HideInInspector];Create;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;373;-971.5121,1035.557;Float;False;321;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;306;-527.5512,824.4196;Float;False;Global;fScaleHeight;fScaleHeight;16;1;[HideInInspector];Create;True;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;380;-755.6614,1126.545;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;405;-2149.409,1464.179;Float;False;330;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;401;-2112.41,1609.179;Float;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;372;-761.5118,948.5964;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;351;-184.2749,487.2077;Float;False;330;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;364;-525.2544,687.1524;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;375;-766.5118,1040.557;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;406;-1948.411,1512.179;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;381;-628.5955,1081.498;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;352;13.56367,397.8147;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;350;12.02637,327.4085;Float;False;315;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;365;-274.2546,688.1524;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;376;-631.5119,980.5576;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;353;241.3438,374.7945;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ExpOpNode;363;-151.8241,688.4944;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;584;-2494.766,2645.115;Float;False;Property;_RayleighScatterMultiplier;Rayleigh Scatter Multiplier;7;0;Create;True;0;50;55;5;500;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;407;-1810.411,1507.179;Float;False;v3SampleRay;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;394;-353.8148,852.0503;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;382;-507.5956,1076.498;Float;False;fLightAngle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;393;-369.8148,851.0503;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;377;-503.512,975.5575;Float;False;fCameraAngle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;303;-2478.422,2175.492;Float;False;Global;fKr4PI;fKr4PI;16;1;[HideInInspector];Create;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;367;-36.25385,683.1524;Float;False;fDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;587;-2584.067,2254.283;Float;False;586;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;586;-2228.766,2645.115;Float;False;rayleighMult;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;577;-2492.766,2573.115;Float;False;Property;_RayleighScatterBias;Rayleigh Scatter Bias;8;0;Create;True;0;4.55;4.55;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;410;-1602.41,1512.179;Float;False;0.5;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;310;-230.2755,980.7475;Float;False;float x = 1.0 - fCos@$return scaleHeight * exp(-0.00287 + x * (0.459 + x * (3.83 + x * (-6.80 + x * 5.25))))@;1;False;2;True;fCos;FLOAT;0;In;True;scaleHeight;FLOAT;0;In;ScaleCameraAngle;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;387;-227.6239,1082.158;Float;False;float x = 1.0 - fCos@$return scaleHeight * exp(-0.00287 + x * (0.459 + x * (3.83 + x * (-6.80 + x * 5.25))))@;1;False;2;True;fCos;FLOAT;0;In;True;scaleHeight;FLOAT;0;In;ScaleLightAngle;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;388;-187.7318,909.2456;Float;False;367;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;408;-1778.41,1429.179;Float;False;354;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;305;-2107.526,1710.674;Float;False;Global;fScale;fScale;16;1;[HideInInspector];Create;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;354;365.3434,369.7945;Float;False;v3Start;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;581;-2582.067,2324.283;Float;False;580;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;389;-10.73162,935.2455;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;580;-2228.766,2572.115;Float;False;rayleighBias;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;403;-1955.411,1626.179;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;409;-1453.41,1435.179;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;585;-2329.067,2180.283;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;589;-1388.067,2323.283;Float;False;586;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;301;-1382.566,2253.185;Float;False;Global;fKrESun;fKrESun;16;1;[HideInInspector];Create;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;296;-2684.732,2101.577;Float;False;Global;v3InvWavelength;v3InvWavelength;16;1;[HideInInspector];Create;True;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;391;-7.731622,1026.246;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;588;-1166.067,2259.283;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;441;-2245.545,2339.24;Float;False;411;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;304;-2168.522,2265.791;Float;False;Global;fKm4PI;fKm4PI;16;1;[HideInInspector];Create;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;582;-2146.967,2177.283;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;583;-1387.067,2392.283;Float;False;580;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;485;-2235.369,2407.69;Float;False;404;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;426;-2368.696,2034.083;Float;False;390;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;392;126.2684,1021.246;Float;False;fTemp;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;404;-1818.411,1621.179;Float;False;fScaledLength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;307;-2393.506,1831.329;Float;False;Global;fScaleOverScaleDepth;fScaleOverScaleDepth;16;1;[HideInInspector];Create;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;418;-2320.201,1750.743;Float;False;Constant;_intSamples;intSamples;16;0;Create;True;0;2;2;0;1;INT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;411;-1321.41,1430.179;Float;False;v3SamplePoint;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;425;-2328.897,1965.082;Float;False;392;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;442;-2327.641,2101.381;Float;False;v3InverseWavelength;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;423;-2357.467,1897.745;Float;False;422;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;486;-2231.881,2476.313;Float;False;407;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;422;-523.679,616.5064;Float;False;fInnerRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;390;124.2684,930.2455;Float;False;fCameraOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;146;-2428.91,-709.8559;Float;False;1728.034;722.8644;Faux Ground Scatter Effect;13;142;251;153;141;138;105;140;139;90;137;136;76;492;Atmosphere;0.03448296,1,0,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;578;-999.0674,2258.283;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-2402.91,-197.2692;Half;False;Property;_AtmosphereFalloff;Atmosphere Falloff;16;0;Create;True;0;0.66;1;0.1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;443;-1064.566,2177.185;Float;False;442;0;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;417;-1888.481,1992.329;Float;False;float3 v3FrontColor = float3(0.0, 0.0, 0.0)@$float3 v3Attenuate = float3(0.0, 0.0, 0.0)@$float3 v3SamplePoint = samplePoint@$for(int i = 0@ i < int(samples)@ i++)${$	float fHeight = length(v3SamplePoint)@$	float fDepth = exp(scaleOverScaleDepth * (innerRadius - fHeight))@$	float fScatter = (fDepth * temp) - cameraOffset@$	v3Attenuate = exp(-fScatter * ((invWavelength * kr4Pi) + km4Pi))@$	v3FrontColor += v3Attenuate * (fDepth * scaledLength)@$	v3SamplePoint += sampleRay@$}$return float3x3($	v3FrontColor.x, v3FrontColor.y, v3FrontColor.z,$	v3Attenuate.x, v3Attenuate.y, v3Attenuate.z,$	0.0, 0.0, 0.0$)@;5;False;11;True;samples;FLOAT;0;In;True;scaleOverScaleDepth;FLOAT;0;In;True;innerRadius;FLOAT;0;In;True;temp;FLOAT;0;In;True;cameraOffset;FLOAT;0;In;True;invWavelength;FLOAT3;0,0,0;In;True;kr4Pi;FLOAT;0;In;True;km4Pi;FLOAT;0;In;True;samplePoint;FLOAT3;0,0,0;In;True;scaledLength;FLOAT;0;In;True;sampleRay;FLOAT3;0,0,0;In;ScatterLoop;True;11;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT3;0,0,0;False;9;FLOAT;0;False;10;FLOAT3;0,0,0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.RangedFloatNode;302;-804.5661,2278.185;Float;False;Global;fKmESun;fKmESun;16;1;[HideInInspector];Create;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;136;-2180.101,-606.8557;Half;False;Property;_AtmosphereNear;Atmosphere Near;15;0;Create;True;0;1,0.3724138,0,1;0.7426471,0.5287186,0.4017721,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;137;-2182.301,-443.3563;Half;False;Property;_AtmosphereFar;Atmosphere Far;14;0;Create;True;0;0.359,0.7974198,1,1;0.359,0.7974198,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;444;-788.5661,2182.185;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;431;-1554.698,1992.271;Float;False;FLOAT3x3;1;0;FLOAT3x3;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FresnelNode;90;-2056.624,-262.0621;Float;False;Tangent;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;436;-1230.103,2109.475;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;434;-1236.699,1947.271;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;105;-1849.095,-262.0191;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;139;-1900.802,-513.8562;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;445;-651.5661,2182.185;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;140;-1895.601,-443.6563;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;268;-2474.336,-2237.475;Float;False;2145.847;831.1229;;23;498;497;459;58;480;479;483;477;151;144;158;476;150;475;469;159;147;157;308;544;473;156;545;Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;447;-499.1003,1948.433;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;540;-1066.092,2109.608;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;138;-1625.247,-461.5085;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;492;-1640.555,-267.2729;Float;False;fresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;541;-325.4301,1948.336;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;545;-1963.437,-1645.438;Float;False;543;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;543;-882.0825,2104.932;Float;False;OUTC1;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-1403.708,-284.9956;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;156;-2420.347,-1945.477;Half;False;Property;_BaseTint;Base Tint;0;0;Create;True;0;0,0,0,0;0.915,0.915,0.915,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;542;-147.3479,1943.307;Float;False;OUTC0;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;544;-1807.437,-1752.438;Float;False;542;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;153;-1256.767,-285.8293;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;147;-2348.288,-2157.527;Float;True;Property;_MainTex;Main Tex;1;1;[NoScaleOffset];Create;True;0;None;c205eb53136d7484eb4969665cda9906;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleNode;473;-1787.206,-1640.253;Float;False;0.25;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;308;-1786.488,-1575.839;Float;False;Global;fHdrExposure;fHdrExposure;16;1;[HideInInspector];Create;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;157;-2175.346,-1945.477;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;-1955.098,-1940.241;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;269;-1510.964,-1162.598;Float;False;1162.878;336.9643;;6;462;185;163;162;161;160;Night Lights;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleNode;475;-1606.307,-1570.909;Float;False;-1;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;469;-1615.208,-1747.253;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;251;-1103.998,-285.4898;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;150;-2020.642,-2077.915;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;160;-1460.964,-1112.598;Float;True;Property;_NightLights;Night Lights;17;1;[NoScaleOffset];Create;True;0;None;bd30aec6bcbd12e4b82e2e583b7e6dff;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;142;-910.3067,-290.9957;Half;False;ATMOSPHERE;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;144;-1721.277,-1921.235;Float;False;142;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;-1667.606,-2018.085;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;476;-1439.938,-1673.211;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;151;-1473.514,-1939.628;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ExpOpNode;477;-1301.938,-1673.211;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;61;-2450.404,-1167.86;Float;False;849.7471;248.5637;;3;65;63;62;Normals;0,0,1,0.5882353;0;0
Node;AmplifyShaderEditor.RangedFloatNode;162;-1173.189,-1032.713;Half;False;Property;_NightLightsIntensity;Night Lights Intensity;18;0;Create;True;0;1;0.357;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;161;-1109.693,-1111.844;Float;False;True;False;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;-887.1901,-1083.411;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2424.119,-1073.946;Half;False;Property;_NormalScale;Normal Scale;12;0;Create;True;0;1;1;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;267;-218.0776,-1095.951;Float;False;574.7732;440.8311;;3;265;266;260;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;479;-1179.938,-1673.211;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;483;-1323.59,-2022.577;Half;False;Property;_EnableFauxAtmosphere;Enable Faux Atmosphere;13;0;Create;True;0;1;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;63;-2135.486,-1119.75;Float;True;Property;_NormalMap;NormalMap;11;1;[NoScaleOffset];Create;True;0;None;832b069de320ff245b2d3e16fc2e97b4;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;265;-168.0777,-885.1198;Float;True;Property;_SpecMap;Spec Map;10;0;Create;True;0;None;05f355c72668ac3478b983e3887d3f6e;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;185;-744.0704,-1083.059;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;480;-985.716,-1720.429;Float;False;False;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;58;-1029.841,-2017.661;Float;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;501;171.4197,-91.38559;Float;False;497;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;459;-856.1868,-2022.615;Float;False;DIFFUSE;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;181;104.0387,-440.6298;Fixed;False;Property;_NightLightRed;Night Light Red;20;0;Create;True;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;497;-768.8259,-1719.946;Float;False;scatterAtten;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;183;107.0387,-301.6296;Fixed;False;Property;_NightLightBlue;Night Light Blue;22;0;Create;True;0;0.35;0.35;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;274;107.1818,-231.3527;Float;False;Property;_NightLightsSoftness;Night Lights Softness;19;0;Create;True;0;0.3;0.1;0.1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;500;172.7677,-162.7697;Float;False;498;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;462;-573.1511,-1087.969;Fixed;False;NIGHTLIGHTS;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;193.7188,-580.6506;Float;False;65;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;498;-570.2665,-1680.048;Float;False;scatterColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;182;105.0387,-371.6296;Fixed;False;Property;_NightLightGreen;Night Light Green;21;0;Create;True;0;0.75;0.835;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;266;118.9227,-885.1198;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;260;84.69568,-1045.951;Half;False;Property;_SpecularColor;Specular Color;9;0;Create;True;0;0,0,0,0;0.492681,0.5350211,0.609,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;463;169.8347,-511.7579;Float;False;462;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;461;197.9247,-648.4877;Float;False;459;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-1821.746,-1119.689;Half;False;NORMALS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;319;-2315.771,882.8622;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;300;-2454.582,-2485.909;Float;False;Global;fInnerRadius2;fInnerRadius2;16;1;[HideInInspector];Create;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;309;-2448.655,-2553.626;Float;False;Global;krPhaseBias;krPhaseBias;16;1;[HideInInspector];Create;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;592;596.7277,-637.4788;Float;False;Blinn-Phong Light JCOR;2;;3;abf9cb092ab53d741a85db181c4b9f11;0;11;43;COLOR;0,0,0,0;False;100;FLOAT3;0,0,0;False;42;COLOR;0,0,0,0;False;52;FLOAT3;0,0,0;False;77;FLOAT;0;False;70;FLOAT;0;False;74;FLOAT;0;False;76;FLOAT;0;False;113;FLOAT;0;False;115;FLOAT3;0,0,0;False;114;FLOAT;0;False;2;FLOAT3;0;FLOAT;57
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;936.9037,-867.9774;Half;False;True;6;Half;ASEMaterialInspector;0;0;CustomLighting;Pipeworks_Custom/Terrain Scatter ASE;False;False;False;False;False;False;True;True;True;True;False;True;False;False;False;False;False;False;False;Back;0;0;False;0;0;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;False;0;255;255;0;0;0;0;0;0;0;0;False;0;15;1;700;True;0.5;True;0;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;537;0;533;0
WireConnection;538;0;537;0
WireConnection;320;0;538;0
WireConnection;320;1;293;0
WireConnection;314;0;311;0
WireConnection;314;1;293;0
WireConnection;315;0;314;0
WireConnection;321;0;320;0
WireConnection;322;0;321;0
WireConnection;322;1;315;0
WireConnection;323;0;322;0
WireConnection;325;0;322;0
WireConnection;325;1;323;0
WireConnection;313;0;315;0
WireConnection;330;0;325;0
WireConnection;317;0;313;0
WireConnection;317;1;313;0
WireConnection;331;0;334;0
WireConnection;331;1;315;0
WireConnection;397;0;331;0
WireConnection;337;0;317;0
WireConnection;337;1;298;0
WireConnection;384;0;337;0
WireConnection;340;0;397;0
WireConnection;340;1;397;0
WireConnection;341;0;340;0
WireConnection;341;1;384;0
WireConnection;339;0;341;0
WireConnection;396;0;397;0
WireConnection;343;0;339;0
WireConnection;346;0;396;0
WireConnection;346;1;343;0
WireConnection;385;0;346;0
WireConnection;526;0;385;0
WireConnection;357;0;323;0
WireConnection;357;1;358;0
WireConnection;527;0;330;0
WireConnection;362;0;357;0
WireConnection;427;0;294;0
WireConnection;380;0;427;0
WireConnection;380;1;378;0
WireConnection;401;0;398;0
WireConnection;401;1;400;0
WireConnection;372;0;527;0
WireConnection;372;1;373;0
WireConnection;364;0;299;0
WireConnection;364;1;297;0
WireConnection;375;0;373;0
WireConnection;406;0;405;0
WireConnection;406;1;401;0
WireConnection;381;0;380;0
WireConnection;381;1;375;0
WireConnection;352;0;385;0
WireConnection;352;1;351;0
WireConnection;365;0;364;0
WireConnection;365;1;306;0
WireConnection;376;0;372;0
WireConnection;376;1;375;0
WireConnection;353;0;350;0
WireConnection;353;1;352;0
WireConnection;363;0;365;0
WireConnection;407;0;406;0
WireConnection;394;0;306;0
WireConnection;382;0;381;0
WireConnection;393;0;306;0
WireConnection;377;0;376;0
WireConnection;367;0;363;0
WireConnection;586;0;584;0
WireConnection;410;0;407;0
WireConnection;310;0;377;0
WireConnection;310;1;394;0
WireConnection;387;0;382;0
WireConnection;387;1;393;0
WireConnection;354;0;353;0
WireConnection;389;0;388;0
WireConnection;389;1;310;0
WireConnection;580;0;577;0
WireConnection;403;0;401;0
WireConnection;403;1;305;0
WireConnection;409;0;408;0
WireConnection;409;1;410;0
WireConnection;585;0;303;0
WireConnection;585;1;587;0
WireConnection;391;0;310;0
WireConnection;391;1;387;0
WireConnection;588;0;301;0
WireConnection;588;1;589;0
WireConnection;582;0;585;0
WireConnection;582;1;581;0
WireConnection;392;0;391;0
WireConnection;404;0;403;0
WireConnection;411;0;409;0
WireConnection;442;0;296;0
WireConnection;422;0;299;0
WireConnection;390;0;389;0
WireConnection;578;0;588;0
WireConnection;578;1;583;0
WireConnection;417;0;418;0
WireConnection;417;1;307;0
WireConnection;417;2;423;0
WireConnection;417;3;425;0
WireConnection;417;4;426;0
WireConnection;417;5;442;0
WireConnection;417;6;582;0
WireConnection;417;7;304;0
WireConnection;417;8;441;0
WireConnection;417;9;485;0
WireConnection;417;10;486;0
WireConnection;444;0;443;0
WireConnection;444;1;578;0
WireConnection;431;0;417;0
WireConnection;90;3;76;0
WireConnection;436;0;431;3
WireConnection;436;1;431;4
WireConnection;436;2;431;5
WireConnection;434;0;431;0
WireConnection;434;1;431;1
WireConnection;434;2;431;2
WireConnection;105;0;90;0
WireConnection;139;0;136;0
WireConnection;445;0;444;0
WireConnection;445;1;302;0
WireConnection;140;0;137;0
WireConnection;447;0;434;0
WireConnection;447;1;445;0
WireConnection;540;0;436;0
WireConnection;138;0;139;0
WireConnection;138;1;140;0
WireConnection;138;2;105;0
WireConnection;492;0;105;0
WireConnection;541;0;447;0
WireConnection;543;0;540;0
WireConnection;141;0;138;0
WireConnection;141;1;492;0
WireConnection;542;0;541;0
WireConnection;153;0;141;0
WireConnection;473;0;545;0
WireConnection;157;0;156;0
WireConnection;159;0;157;0
WireConnection;159;1;156;4
WireConnection;475;0;308;0
WireConnection;469;0;544;0
WireConnection;469;1;473;0
WireConnection;251;0;153;0
WireConnection;150;0;147;0
WireConnection;142;0;251;0
WireConnection;158;0;150;0
WireConnection;158;1;159;0
WireConnection;476;0;469;0
WireConnection;476;1;475;0
WireConnection;151;0;158;0
WireConnection;151;1;144;0
WireConnection;477;0;476;0
WireConnection;161;0;160;0
WireConnection;163;0;161;0
WireConnection;163;1;162;0
WireConnection;479;0;477;0
WireConnection;483;0;158;0
WireConnection;483;1;151;0
WireConnection;63;5;62;0
WireConnection;185;0;163;0
WireConnection;480;0;479;0
WireConnection;58;0;483;0
WireConnection;459;0;58;0
WireConnection;497;0;480;0
WireConnection;462;0;185;0
WireConnection;498;0;479;0
WireConnection;266;0;265;0
WireConnection;65;0;63;0
WireConnection;592;43;260;0
WireConnection;592;100;266;0
WireConnection;592;42;461;0
WireConnection;592;52;145;0
WireConnection;592;77;463;0
WireConnection;592;70;181;0
WireConnection;592;74;182;0
WireConnection;592;76;183;0
WireConnection;592;113;274;0
WireConnection;592;115;500;0
WireConnection;592;114;501;0
WireConnection;0;13;592;0
ASEEND*/
//CHKSM=E46375550C8FDC7A82638B37805717E541745FEB