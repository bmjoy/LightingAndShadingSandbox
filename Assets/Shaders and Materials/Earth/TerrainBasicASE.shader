// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pipeworks_Custom/Terrain Basic ASE"
{
	Properties
	{
		_BaseTint("Base Tint", Color) = (0,0,0,0)
		[NoScaleOffset]_MainTex("Main Tex", 2D) = "white" {}
		[Header(Blinn Phong Light JCOR)]
		_Shininess("Gloss", Range( 0.01 , 1)) = 0.1
		_SpecularColor("Specular Color", Color) = (0,0,0,0)
		_SpecMap("Spec Map", 2D) = "black" {}
		[NoScaleOffset]_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 4)) = 1
		_AtmosphereFar("Atmosphere Far", Color) = (0.359,0.7974198,1,1)
		_AtmosphereNear("Atmosphere Near", Color) = (1,0.3724138,0,1)
		_AtmosphereFalloff("Atmosphere Falloff", Range( 0.1 , 5)) = 5
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
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=14401
1950;32;1846;1125;2951.123;2184.245;2.368457;True;False
Node;AmplifyShaderEditor.CommentaryNode;146;-1686.55,-461.793;Float;False;1832.302;729.9859;Faux Ground Scatter Effect;12;142;153;141;138;140;105;139;136;137;90;76;251;Atmosphere;0.03448296,1,0,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-1660.55,50.79377;Half;False;Property;_AtmosphereFalloff;Atmosphere Falloff;12;0;Create;True;5;0.66;0.1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;136;-1437.742,-358.7927;Half;False;Property;_AtmosphereNear;Atmosphere Near;11;0;Create;True;1,0.3724138,0,1;0.7426471,0.5287186,0.4017721,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;137;-1439.942,-195.2932;Half;False;Property;_AtmosphereFar;Atmosphere Far;10;0;Create;True;0.359,0.7974198,1,1;0.359,0.7974198,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;90;-1314.264,-13.99915;Float;False;Tangent;4;0;FLOAT3;0,0,0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;5.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;139;-1158.442,-265.793;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;140;-1153.241,-195.5932;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;105;-1106.735,-13.95615;Float;True;1;0;FLOAT;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;138;-882.8877,-213.4454;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0.0,0,0;False;2;FLOAT;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;268;-1347.134,-1706.716;Float;False;1229.968;480.0734;;9;156;157;147;159;150;158;144;151;58;Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-661.3477,-36.9326;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;156;-1297.134,-1444.666;Half;False;Property;_BaseTint;Base Tint;0;0;Create;True;0,0,0,0;0.915,0.915,0.915,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;269;-623.3911,-1105.878;Float;False;997.4534;595.1657;;9;274;185;182;181;183;163;162;161;160;Night Lights;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;153;-514.4066,-37.7663;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;147;-1225.075,-1656.716;Float;True;Property;_MainTex;Main Tex;1;1;[NoScaleOffset];Create;True;None;c205eb53136d7484eb4969665cda9906;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;157;-1052.133,-1444.666;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;-831.8849,-1439.43;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;150;-897.4284,-1577.102;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;160;-573.3911,-1055.878;Float;True;Property;_NightLights;Night Lights;13;1;[NoScaleOffset];Create;True;None;bd30aec6bcbd12e4b82e2e583b7e6dff;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;61;-1576.589,-1097.658;Float;False;849.7471;248.5637;;3;65;63;62;Normals;0,0,1,0.5882353;0;0
Node;AmplifyShaderEditor.VertexToFragmentNode;251;-361.638,-37.4268;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;161;-222.1201,-1055.124;Float;False;True;False;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-1550.304,-1003.744;Half;False;Property;_NormalScale;Normal Scale;9;0;Create;True;1;1;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;-663.7328,-1515.466;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;267;-29.91757,-1845.092;Float;False;574.7732;440.8311;;3;265;266;260;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;144;-680.9281,-1404.409;Float;False;142;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;162;-285.6169,-975.9932;Half;False;Property;_NightLightsIntensity;Night Lights Intensity;14;0;Create;True;1;0.95;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;142;-173.947,-42.93272;Half;False;ATMOSPHERE;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;0.3826387,-1026.691;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;63;-1261.671,-1049.548;Float;True;Property;_NormalMap;NormalMap;8;1;[NoScaleOffset];Create;True;None;832b069de320ff245b2d3e16fc2e97b4;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;265;20.08241,-1634.26;Float;True;Property;_SpecMap;Spec Map;7;0;Create;True;None;05f355c72668ac3478b983e3887d3f6e;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;151;-449.1702,-1481.008;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;58;-315.1664,-1479.642;Float;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;274;97.2515,-603.4528;Float;False;Property;_NightLightsSoftness;Night Lights Softness;15;0;Create;True;0.3;0.3;0.1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;183;97.10837,-673.7297;Fixed;False;Property;_NightLightBlue;Night Light Blue;18;0;Create;True;0.35;0.35;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-947.9312,-1049.487;Half;False;NORMALS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;182;95.10838,-743.7297;Fixed;False;Property;_NightLightGreen;Night Light Green;17;0;Create;True;0.75;0.835;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;260;272.8557,-1795.092;Half;False;Property;_SpecularColor;Specular Color;6;0;Create;True;0,0,0,0;0.492681,0.5350211,0.609,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;185;143.5023,-1026.339;Float;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;181;94.10837,-812.7297;Fixed;False;Property;_NightLightRed;Night Light Red;16;0;Create;True;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;483.2554,-1163.902;Float;False;65;0;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;266;307.0827,-1634.26;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;289;879.6857,-1215.371;Float;False;Blinn-Phong Light JCOR;2;;128;abf9cb092ab53d741a85db181c4b9f11;0;10;43;COLOR;0,0,0,0;False;100;FLOAT3;0,0,0;False;42;COLOR;0,0,0,0;False;52;FLOAT3;0,0,0;False;77;FLOAT;0.0;False;70;FLOAT;0.0;False;74;FLOAT;0.0;False;76;FLOAT;0.0;False;69;FLOAT;0.0;False;113;FLOAT;0.0;False;2;FLOAT3;0;FLOAT;57
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1255.862,-1445.87;Half;False;True;6;Half;ASEMaterialInspector;0;0;CustomLighting;Pipeworks_Custom/Terrain Basic ASE;False;False;False;False;False;False;True;True;True;True;False;True;False;False;False;False;False;Back;0;0;False;0;0;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;False;0;255;255;0;0;0;0;0;0;0;0;False;0;15;1;700;True;0.5;True;0;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;0;0;0;0;False;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0.0,0,0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;90;3;76;0
WireConnection;139;0;136;0
WireConnection;140;0;137;0
WireConnection;105;0;90;0
WireConnection;138;0;139;0
WireConnection;138;1;140;0
WireConnection;138;2;105;0
WireConnection;141;0;138;0
WireConnection;141;1;105;0
WireConnection;153;0;141;0
WireConnection;157;0;156;0
WireConnection;159;0;157;0
WireConnection;159;1;156;4
WireConnection;150;0;147;0
WireConnection;251;0;153;0
WireConnection;161;0;160;0
WireConnection;158;0;150;0
WireConnection;158;1;159;0
WireConnection;142;0;251;0
WireConnection;163;0;161;0
WireConnection;163;1;162;0
WireConnection;63;5;62;0
WireConnection;151;0;158;0
WireConnection;151;1;144;0
WireConnection;58;0;151;0
WireConnection;65;0;63;0
WireConnection;185;0;163;0
WireConnection;266;0;265;0
WireConnection;289;43;260;0
WireConnection;289;100;266;0
WireConnection;289;42;58;0
WireConnection;289;52;145;0
WireConnection;289;77;185;0
WireConnection;289;70;181;0
WireConnection;289;74;182;0
WireConnection;289;76;183;0
WireConnection;289;113;274;0
WireConnection;0;13;289;0
ASEEND*/
//CHKSM=1C52C62E4FB3ACD6EE2DD9F5F65932AFBA6FF56F