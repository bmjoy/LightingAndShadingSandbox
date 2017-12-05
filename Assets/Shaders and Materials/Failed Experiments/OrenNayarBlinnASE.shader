// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pipeworks_Custom/Oren Nayar Blinn ASE"
{
	Properties
	{
		_ColorTint("Color Tint", Color) = (1,1,1,1)
		_MainRGBSpecA("Main (RGB) Spec (A)", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 5)) = 0
		_Roughness("Roughness", Range( 0 , 1)) = 0
		_RimPower("Rim Power", Range( 0 , 1)) = 0
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_SpecularPower("Specular Power", Range( 0 , 1)) = 0.33
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		ColorMask RGB
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
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

		uniform float _NormalScale;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float _Roughness;
		uniform fixed4 _ColorTint;
		uniform sampler2D _MainRGBSpecA;
		uniform float4 _MainRGBSpecA_ST;
		uniform half _SpecularPower;
		uniform fixed4 _SpecularColor;
		uniform float _RimPower;
		uniform fixed4 _RimColor;

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
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 temp_output_3_0 = (UnpackScaleNormal( tex2D( _Normal, uv_Normal ) ,_NormalScale )).xyz;
			float3 temp_output_51_0_g495 = temp_output_3_0;
			float3 newWorldNormal50_g495 = WorldNormalVector( i , temp_output_51_0_g495 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float3 temp_output_24_0_g495 = ase_worldlightDir;
			float dotResult3_g496 = dot( newWorldNormal50_g495 , temp_output_24_0_g495 );
			half NdotL34_g495 = saturate( max( dotResult3_g496 , 0.0 ) );
			float temp_output_2_0_g495 = _Roughness;
			float temp_output_6_0_g495 = ( temp_output_2_0_g495 * temp_output_2_0_g495 );
			half3 orenNayar16_g495 = ( half3(1,0,0) + ( half3(-0.5,0.17,0.45) * ( temp_output_6_0_g495 / ( temp_output_6_0_g495 + half3(0.33,0.13,0.09) ) ) ) );
			float2 uv_MainRGBSpecA = i.uv_texcoord * _MainRGBSpecA_ST.xy + _MainRGBSpecA_ST.zw;
			float4 temp_output_92_0_g495 = tex2D( _MainRGBSpecA, uv_MainRGBSpecA );
			half3 albedo93_g495 = ( (_ColorTint).rgb * (temp_output_92_0_g495).rgb );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 temp_output_22_0_g495 = ase_worldViewDir;
			float dotResult31_g495 = dot( temp_output_24_0_g495 , temp_output_22_0_g495 );
			float dotResult4_g501 = dot( newWorldNormal50_g495 , temp_output_22_0_g495 );
			half NdotV35_g495 = saturate( max( dotResult4_g501 , 0.0 ) );
			float temp_output_39_0_g495 = ( saturate( dotResult31_g495 ) - ( NdotL34_g495 * NdotV35_g495 ) );
			float lerpResult44_g495 = lerp( max( NdotL34_g495 , NdotV35_g495 ) , 1.0 , step( temp_output_39_0_g495 , 0.0 ));
			half orenNayar_s49_g495 = ( temp_output_39_0_g495 / lerpResult44_g495 );
			float3 temp_output_108_0_g495 = ( NdotL34_g495 * ( orenNayar16_g495.x + ( albedo93_g495 * orenNayar16_g495.y ) + ( orenNayar16_g495.z * orenNayar_s49_g495 ) ) );
			float3 temp_output_69_0_g495 = _LightColor0.rgb;
			half3 lightColor113_g495 = temp_output_69_0_g495;
			half lightAtten112_g495 = ase_lightAtten;
			float temp_output_11_0_g500 = ( 1.0 / 1.31 );
			float temp_output_130_0_g495 = ( 1.0 - ( pow( ( 1.0 - temp_output_11_0_g500 ) , 2.0 ) / pow( ( 1.0 + temp_output_11_0_g500 ) , 2.0 ) ) );
			half3 worldSpaceNormals73_g495 = newWorldNormal50_g495;
			UnityGI gi157_g495 = gi;
			gi157_g495 = UnityGI_Base( data, 1, worldSpaceNormals73_g495 );
			float3 indirectDiffuse157_g495 = gi157_g495.indirect.diffuse;
			float3 normalizeResult156_g495 = normalize( indirectDiffuse157_g495 );
			half3 difuseL137_g495 = saturate( ( ( temp_output_108_0_g495 * albedo93_g495 * lightColor113_g495 * lightAtten112_g495 * temp_output_130_0_g495 ) + ( normalizeResult156_g495 * 0.1 ) ) );
			float3 normalizeResult5_g497 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult6_g497 = dot( WorldNormalVector( i , temp_output_51_0_g495 ) , normalizeResult5_g497 );
			float4 temp_output_61_0_g495 = _SpecularColor;
			fixed specMap99_g495 = (temp_output_92_0_g495).a;
			float3 temp_output_7_0_g498 = temp_output_22_0_g495;
			float3 normalizeResult10_g498 = normalize( ( temp_output_24_0_g495 + temp_output_7_0_g498 ) );
			float dotResult13_g498 = dot( normalizeResult10_g498 , temp_output_7_0_g498 );
			float temp_output_31_0_g498 = pow( ( 1.0 - dotResult13_g498 ) , _RimPower );
			float temp_output_11_0_g499 = ( 1.0 / 1.31 );
			float fresnel82_g495 = ( temp_output_31_0_g498 + ( ( 1.0 - temp_output_31_0_g498 ) * ( pow( ( 1.0 - temp_output_11_0_g499 ) , 2.0 ) / pow( ( 1.0 + temp_output_11_0_g499 ) , 2.0 ) ) ) );
			half3 specL114_g495 = ( ( saturate( pow( max( dotResult6_g497 , 0.0 ) , ( _SpecularPower * 128.0 ) ) ) * (temp_output_61_0_g495).rgb * (temp_output_61_0_g495).a * specMap99_g495 ) * ( 1.0 - fresnel82_g495 ) * ( temp_output_69_0_g495 * ase_lightAtten ) );
			float3 newWorldNormal14 = WorldNormalVector( i , temp_output_3_0 );
			float3 temp_output_7_0_g73 = ase_worldViewDir;
			float3 normalizeResult10_g73 = normalize( ( newWorldNormal14 + temp_output_7_0_g73 ) );
			float dotResult13_g73 = dot( normalizeResult10_g73 , temp_output_7_0_g73 );
			float temp_output_31_0_g73 = pow( ( 1.0 - dotResult13_g73 ) , _RimPower );
			float temp_output_11_0_g74 = ( 1.0 / 1.31 );
			float3 _Const3_01 = float3(0,1,0);
			float dotResult17 = dot( newWorldNormal14 , _Const3_01 );
			float dotResult27 = dot( _Const3_01 , ( ase_worldViewDir * -1.0 ) );
			c.rgb = ( ( difuseL137_g495 + specL114_g495 ) + (( ( (_RimColor).rgb * _RimColor.a ) * ( ( temp_output_31_0_g73 + ( ( 1.0 - temp_output_31_0_g73 ) * ( pow( ( 1.0 - temp_output_11_0_g74 ) , 2.0 ) / pow( ( 1.0 + temp_output_11_0_g74 ) , 2.0 ) ) ) ) * saturate( ( ( dotResult17 * 0.5 ) + 0.5 ) ) * saturate( ( dotResult27 + 1.75 ) ) ) )).xyz );
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
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

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
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal( v.normal );
				fixed3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
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
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13903
1939;35;1796;1125;644.8187;284.305;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;1;-1512.124,112.5015;Float;False;Property;_NormalScale;Normal Scale;3;0;0;0;5;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;2;-1230.727,67.28145;Float;True;Property;_Normal;Normal;2;0;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;3;-941.7271,67.28145;Float;False;True;True;True;False;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;22;-277.5781,996.7413;Float;False;World;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.WorldNormalVector;14;-632.7298,673.6462;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.Vector3Node;15;-638.9064,924.5498;Float;False;Constant;_Const3_01;Const3_01;9;0;0,1,0;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;24;-257.5781,1138.741;Float;False;Constant;_Const1_02;Const1_02;9;0;-1;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;19;-382.578,872.7411;Float;False;Constant;_Const1_01;Const1_01;9;0;0.5;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.DotProductOpNode;17;-347.578,759.7411;Float;False;2;0;FLOAT3;0.0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-88.57803,1063.741;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-212.578,805.7411;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.DotProductOpNode;27;188.422,929.7411;Float;False;2;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;30;147.4219,1033.741;Float;False;Constant;_Const1_03;Const1_03;9;0;1.75;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;29;337.422,929.7411;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;35;-629.9889,536.6292;Float;False;World;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;6;-474.1099,149.1785;Float;False;Property;_RimPower;Rim Power;5;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;20;-71.57803,854.7411;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;5;-20.36818,326.5058;Fixed;False;Property;_RimColor;Rim Color;6;0;1,1,1,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;28;470.4221,929.7411;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;21;53.42191,854.7411;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;113;243.962,326.5164;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.FunctionNode;49;-145.0281,518.4412;Float;False;Schlick Fresnel;-1;;73;a1f21a3cacd7a6d46965aa8e3cd29501;3;0;FLOAT;0.0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;642.4219,837.7411;Float;False;3;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;457.9619,400.5164;Float;False;2;2;0;FLOAT3;0.0;False;1;FLOAT;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.ColorNode;7;-896.827,-202.3186;Fixed;False;Property;_ColorTint;Color Tint;0;0;1,1,1,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;4;-454.0401,228.7914;Fixed;False;Property;_SpecularColor;Specular Color;8;0;1,1,1,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;11;-471.5658,463.5935;Float;False;Property;_Roughness;Roughness;4;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;867.3781,401.1596;Float;False;2;2;0;FLOAT3;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.SamplerNode;8;-975.373,-389.003;Float;True;Property;_MainRGBSpecA;Main (RGB) Spec (A);1;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;10;-474.5658,395.5935;Half;False;Property;_SpecularPower;Specular Power;7;0;0.33;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.FunctionNode;116;-11.84969,28.74247;Float;False;Oren Nayar Blinn;-1;;495;213c3d6404f827644885750c46cbd46c;10;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;COLOR;0,0,0,0;False;5;FLOAT;0.0;False;6;FLOAT;0.0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;9;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.ComponentMaskNode;37;1003.378,396.1596;Float;False;True;True;True;False;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.SimpleAddOpNode;111;1314.501,31.43998;Float;False;2;2;0;FLOAT3;0.0;False;1;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1487.672,-198.3297;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Pipeworks_Custom/Oren Nayar Blinn ASE;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0.0,0,0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;2;5;1;0
WireConnection;3;0;2;0
WireConnection;14;0;3;0
WireConnection;17;0;14;0
WireConnection;17;1;15;0
WireConnection;23;0;22;0
WireConnection;23;1;24;0
WireConnection;18;0;17;0
WireConnection;18;1;19;0
WireConnection;27;0;15;0
WireConnection;27;1;23;0
WireConnection;29;0;27;0
WireConnection;29;1;30;0
WireConnection;20;0;18;0
WireConnection;20;1;19;0
WireConnection;28;0;29;0
WireConnection;21;0;20;0
WireConnection;113;0;5;0
WireConnection;49;0;6;0
WireConnection;49;1;35;0
WireConnection;49;2;14;0
WireConnection;31;0;49;0
WireConnection;31;1;21;0
WireConnection;31;2;28;0
WireConnection;114;0;113;0
WireConnection;114;1;5;4
WireConnection;36;0;114;0
WireConnection;36;1;31;0
WireConnection;116;0;8;0
WireConnection;116;1;7;0
WireConnection;116;2;3;0
WireConnection;116;3;6;0
WireConnection;116;4;4;0
WireConnection;116;5;10;0
WireConnection;116;6;11;0
WireConnection;37;0;36;0
WireConnection;111;0;116;0
WireConnection;111;1;37;0
WireConnection;0;13;111;0
ASEEND*/
//CHKSM=099330C1C800B8F81D0354BAA99EECE6D6843B36