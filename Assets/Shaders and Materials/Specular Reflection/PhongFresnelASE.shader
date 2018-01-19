// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "Pipeworks_Custom/Phong Fresnel ASE"
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
		[HideInInspector] __dirty( "", Int ) = 1
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
			//float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
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
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=14205
1939;35;1796;1125;1372.985;385.8434;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;61;-903.011,1793.46;Float;False;2708.898;727.9316;;6;62;64;63;102;91;65;Normals;1,1,1,0;0;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-882.9929,2122.126;Half;False;Property;_NormalScale;Normal Scale;11;0;Create;True;1;0.8;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;63;-587.0883,1893.25;Float;True;Property;_Normals;Normals;10;0;Create;True;None;f7f322ea849ea7d41adb6fa8a7d8a3e6;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;91;-274.3773,2008.155;Float;False;1357;303;For Android, scale normals manually because Unity implements normal maps as regular textures in Android (since 'Droid doesn't support DXT5nm format);8;99;98;97;96;95;94;93;92;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;92;-215.3774,2100.155;Float;False;True;True;True;True;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;15.62259,2106.155;Float;False;2;2;0;FLOAT3;0,0;False;1;FLOAT;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;94;239.6226,2170.155;Float;False;2;0;FLOAT3;0,0;False;1;FLOAT3;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;95;383.6227,2170.155;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;96;527.6228,2170.155;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;97;239.6226,2058.155;Float;False;FLOAT3;1;0;FLOAT3;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SqrtOpNode;98;687.6227,2170.155;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;99;847.6226,2058.155;Float;True;FLOAT3;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;64;-256.3931,1893.031;Float;False;True;True;True;False;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;102;969.3418,1854.212;Float;False;591.0002;146.4344;Making sure it only scales manually if it's android, otherwise carry on.;1;101;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;6;-895.3,514.58;Float;False;1150.8;555.1;Half Lambert;6;66;8;1;2;107;115;Diffuse;0.9191176,0,0,0.5882353;0;0
Node;AmplifyShaderEditor.StaticSwitch;101;1151.059,1896.333;Float;False;Property;_Keyword0;Keyword 0;3;0;Create;True;2;False;False;False;UNITY_NO_DXT5nm;Toggle;2;1;FLOAT3;0.0,0,0;False;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;19;-892.4311,1163.408;Float;False;1150.245;505.7;Phong;9;22;16;17;21;15;41;70;40;38;Specular;0,1,0,0.5882353;0;0
Node;AmplifyShaderEditor.ColorNode;15;-854.3464,1411.638;Fixed;False;Property;_SpecularColor;Specular Color;7;0;Create;True;0.9191176,0.5205312,0.2840074,1;1,0.9568627,0.8392157,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-869.1442,629.683;Float;True;Property;_BaseRGB;Base (RGB);2;0;Create;True;None;a9f953c7353804247b8c3ed6e1c46a2e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;66;-813.6782,990.014;Float;False;65;0;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;1;-838.0553,821.017;Half;False;Property;_BaseTint;Base Tint;0;0;Create;True;0.6397059,0.620891,0.620891,1;0,0.1778824,0.378,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;1605.378,1896.383;Half;False;NORMALS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-856.2105,1319.167;Float;False;65;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-842.8231,1245.693;Float;False;Property;_SpecularPower;Specular Power;9;0;Create;True;0.2;0.2;0.001;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;16;-564.798,1483.915;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.FunctionNode;124;-530.1086,802.2725;Float;False;Lambert Wrap;-1;;100;31f8f5f80290a284a82e58e8d6bb3fef;0;5;28;COLOR;0,0,0,0;False;32;COLOR;0,0,0,0;False;26;FLOAT3;0,0,0;False;34;FLOAT3;0,0,0;False;43;FLOAT3;0,0,0;False;2;FLOAT3;0;FLOAT;39
Node;AmplifyShaderEditor.ComponentMaskNode;21;-599.3125,1411.534;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightAttenuation;38;-566.3198,1599.523;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-664.798,1343.916;Half;False;Property;_SpecularIntensity;Specular Intensity;8;0;Create;True;1;0.6;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;125;-568.8385,1251.179;Float;False;Phong;-1;;103;797d6640119c1a04d98b7512b0da5e7b;0;2;14;FLOAT;0.0;False;17;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-294.3206,1249.523;Float;False;5;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT3;0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;107;-112.042,802.1788;Float;False;COLOR;4;0;FLOAT3;0,0,0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;10;-1195.236,-211.5539;Float;False;1454.754;650.7079;;19;117;114;116;0;58;105;87;14;86;90;73;108;110;89;76;23;13;78;126;Master;0,0,1,0.5882353;0;0
Node;AmplifyShaderEditor.ColorNode;78;-1090.899,-166.5877;Half;False;Property;_RimColor;Rim Color;4;0;Create;True;0,1,1,1;0.01254326,0.8529412,0,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;76;-1148.955,75.62814;Half;False;Property;_RimPower;Rim Power;5;0;Create;True;5;4;0.1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;40.4404,797.4509;Fixed;False;DIFFUSE;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;-1042.23,154.4946;Float;False;8;0;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-1070.671,5.83445;Float;False;65;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-105.3134,1244.535;Fixed;False;SPECULAR;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-1077.116,336.3918;Float;False;22;0;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;86;-875.1517,-166.4465;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;90;-802.6705,10.83444;Float;False;Tangent;4;0;FLOAT3;0,0,0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;5.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;108;-846.042,241.1788;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;73;-876.7567,313.523;Fixed;False;Property;_SpecularEnable;SpecularEnable;6;0;Create;True;0;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;-530.3047,979.6315;Fixed;False;TINT_A;-1;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;110;-842.042,155.1788;Float;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;116;-643.3047,211.6315;Float;False;115;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-539.0689,296.3543;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-466.3047,160.6315;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-605.3586,-91.41933;Float;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0,0,0;False;2;FLOAT;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;-602.9878,52.15527;Fixed;False;FRESNEL;-1;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;105;-449.0422,-91.82117;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;58;-400.3355,296.2763;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;117;-284.1733,90.87;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;1.0;False;2;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;18.62079,20.95785;Half;False;True;2;Half;ASEMaterialInspector;0;0;CustomLighting;Pipeworks_Custom/Phong Fresnel ASE;False;False;False;False;True;True;True;True;True;True;True;True;False;False;True;False;False;Back;1;0;False;0;0;False;0;Custom;0.5;True;False;0;True;Transparent;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;True;2;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;Legacy Shaders/Transparent/Diffuse;1;-1;-1;-1;0;0;0;False;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0.0,0,0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;63;5;62;0
WireConnection;92;0;63;0
WireConnection;93;0;92;0
WireConnection;93;1;62;0
WireConnection;94;0;93;0
WireConnection;94;1;93;0
WireConnection;95;0;94;0
WireConnection;96;0;95;0
WireConnection;97;0;93;0
WireConnection;98;0;96;0
WireConnection;99;0;97;0
WireConnection;99;1;97;1
WireConnection;99;2;98;0
WireConnection;64;0;63;0
WireConnection;101;1;64;0
WireConnection;101;0;99;0
WireConnection;65;0;101;0
WireConnection;124;28;2;0
WireConnection;124;32;1;0
WireConnection;124;26;66;0
WireConnection;21;0;15;0
WireConnection;125;14;41;0
WireConnection;125;17;70;0
WireConnection;40;0;125;0
WireConnection;40;1;17;0
WireConnection;40;2;21;0
WireConnection;40;3;16;1
WireConnection;40;4;38;0
WireConnection;107;0;124;0
WireConnection;107;3;124;39
WireConnection;8;0;107;0
WireConnection;22;0;40;0
WireConnection;86;0;78;0
WireConnection;90;0;89;0
WireConnection;90;3;76;0
WireConnection;108;0;13;0
WireConnection;73;1;23;0
WireConnection;115;0;1;4
WireConnection;110;0;13;0
WireConnection;14;0;108;0
WireConnection;14;1;73;0
WireConnection;114;0;110;0
WireConnection;114;1;116;0
WireConnection;87;0;86;0
WireConnection;87;1;78;4
WireConnection;87;2;90;0
WireConnection;126;0;90;0
WireConnection;105;0;87;0
WireConnection;58;0;14;0
WireConnection;117;0;114;0
WireConnection;117;2;126;0
WireConnection;0;2;105;0
WireConnection;0;9;117;0
WireConnection;0;13;58;0
ASEEND*/
//CHKSM=B27E70C8CDE41DDD58F525E6C898D846D11465E4