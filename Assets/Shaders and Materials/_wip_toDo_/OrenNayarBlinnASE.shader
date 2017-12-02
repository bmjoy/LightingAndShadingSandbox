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
		_RimPower("Rim Power", Range( 0 , 10)) = 0
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_SpecularPower("Specular Power", Range( 0 , 1)) = 0.33
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
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

		uniform fixed4 _RimColor;
		uniform float _NormalScale;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float _RimPower;
		uniform float _Roughness;
		uniform fixed4 _ColorTint;
		uniform sampler2D _MainRGBSpecA;
		uniform float4 _MainRGBSpecA_ST;
		uniform half _SpecularPower;
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
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float3 temp_output_24_0_g66 = ase_worldlightDir;
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 temp_output_3_0 = (UnpackScaleNormal( tex2D( _Normal, uv_Normal ) ,_NormalScale )).xyz;
			float3 newWorldNormal50_g66 = WorldNormalVector( i , temp_output_3_0 );
			float dotResult3_g69 = dot( temp_output_24_0_g66 , newWorldNormal50_g66 );
			half NdotL34_g66 = saturate( max( dotResult3_g69 , 0.0 ) );
			float temp_output_2_0_g66 = _Roughness;
			float temp_output_6_0_g66 = ( temp_output_2_0_g66 * temp_output_2_0_g66 );
			half3 orenNayar16_g66 = ( half3(1,0,0) + ( half3(-0.5,0.17,0.45) * ( temp_output_6_0_g66 / ( temp_output_6_0_g66 + half3(0.33,0.13,0.09) ) ) ) );
			float2 uv_MainRGBSpecA = i.uv_texcoord * _MainRGBSpecA_ST.xy + _MainRGBSpecA_ST.zw;
			float4 temp_output_92_0_g66 = tex2D( _MainRGBSpecA, uv_MainRGBSpecA );
			half3 albedo93_g66 = ( (_ColorTint).rgb * (temp_output_92_0_g66).rgb );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 temp_output_22_0_g66 = ase_worldViewDir;
			float dotResult31_g66 = dot( temp_output_24_0_g66 , temp_output_22_0_g66 );
			float dotResult4_g70 = dot( newWorldNormal50_g66 , temp_output_22_0_g66 );
			half NdotV35_g66 = saturate( max( dotResult4_g70 , 0.0 ) );
			float temp_output_39_0_g66 = ( saturate( dotResult31_g66 ) - ( NdotL34_g66 * NdotV35_g66 ) );
			float lerpResult44_g66 = lerp( max( NdotL34_g66 , NdotV35_g66 ) , 1.0 , step( temp_output_39_0_g66 , 0.0 ));
			half orenNayar_S49_g66 = ( temp_output_39_0_g66 / lerpResult44_g66 );
			float3 temp_output_69_0_g66 = _LightColor0.rgb;
			half3 lightColor113_g66 = temp_output_69_0_g66;
			half lightAtten112_g66 = ase_lightAtten;
			float temp_output_11_0_g68 = ( 1.0 / 1.31 );
			half3 normals73_g66 = newWorldNormal50_g66;
			float3 normalizeResult71_g66 = normalize( normals73_g66 );
			UnityGI gi75_g66 = gi;
			gi75_g66 = UnityGI_Base( data, 1, WorldNormalVector( i , normalizeResult71_g66 ) );
			float3 indirectDiffuse75_g66 = gi75_g66.indirect.diffuse;
			half3 difuseL137_g66 = saturate( ( ( ( NdotL34_g66 * ( orenNayar16_g66.x + ( albedo93_g66 * orenNayar16_g66.y ) + ( orenNayar16_g66.z * orenNayar_S49_g66 ) ) ) * albedo93_g66 * lightColor113_g66 * lightAtten112_g66 * ( 1.0 - ( pow( ( 1.0 - temp_output_11_0_g68 ) , 2.0 ) / pow( ( 1.0 + temp_output_11_0_g68 ) , 2.0 ) ) ) ) + indirectDiffuse75_g66 ) );
			float3 normalizeResult5_g67 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult6_g67 = dot( WorldNormalVector( i , normals73_g66 ) , normalizeResult5_g67 );
			float4 temp_output_61_0_g66 = _SpecularColor;
			fixed specMap99_g66 = (temp_output_92_0_g66).a;
			float3 temp_output_7_0_g71 = temp_output_22_0_g66;
			float3 normalizeResult10_g71 = normalize( ( temp_output_24_0_g66 + temp_output_7_0_g71 ) );
			float dotResult13_g71 = dot( normalizeResult10_g71 , temp_output_7_0_g71 );
			float temp_output_31_0_g71 = pow( ( 1.0 - dotResult13_g71 ) , _RimPower );
			float temp_output_11_0_g72 = ( 1.0 / 1.31 );
			float fresnel82_g66 = ( temp_output_31_0_g71 + ( ( 1.0 - temp_output_31_0_g71 ) * ( pow( ( 1.0 - temp_output_11_0_g72 ) , 2.0 ) / pow( ( 1.0 + temp_output_11_0_g72 ) , 2.0 ) ) ) );
			half3 specL114_g66 = ( ( saturate( pow( max( dotResult6_g67 , 0.0 ) , ( _SpecularPower * 128.0 ) ) ) * (temp_output_61_0_g66).rgb * (temp_output_61_0_g66).a * specMap99_g66 ) * ( 1.0 - fresnel82_g66 ) * ( temp_output_69_0_g66 * ase_lightAtten ) );
			c.rgb = ( difuseL137_g66 + specL114_g66 );
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
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 temp_output_3_0 = (UnpackScaleNormal( tex2D( _Normal, uv_Normal ) ,_NormalScale )).xyz;
			float3 newWorldNormal14 = WorldNormalVector( i , temp_output_3_0 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 temp_output_7_0_g36 = ase_worldViewDir;
			float3 normalizeResult10_g36 = normalize( ( newWorldNormal14 + temp_output_7_0_g36 ) );
			float dotResult13_g36 = dot( normalizeResult10_g36 , temp_output_7_0_g36 );
			float temp_output_31_0_g36 = pow( ( 1.0 - dotResult13_g36 ) , _RimPower );
			float temp_output_11_0_g37 = ( 1.0 / 1.31 );
			float3 _Const3_01 = float3(0,1,0);
			float dotResult17 = dot( newWorldNormal14 , _Const3_01 );
			float dotResult27 = dot( _Const3_01 , ( ase_worldViewDir * -1.0 ) );
			o.Emission = (( _RimColor * ( ( temp_output_31_0_g36 + ( ( 1.0 - temp_output_31_0_g36 ) * ( pow( ( 1.0 - temp_output_11_0_g37 ) , 2.0 ) / pow( ( 1.0 + temp_output_11_0_g37 ) , 2.0 ) ) ) ) * saturate( ( ( dotResult17 * 0.5 ) + 0.5 ) ) * saturate( ( dotResult27 + 1.75 ) ) ) )).rgb;
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
1936;39;1796;1125;1547.837;529.8364;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;1;-1519.124,29.50147;Float;False;Property;_NormalScale;Normal Scale;3;0;0;0;5;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;2;-1237.727,-15.71855;Float;True;Property;_Normal;Normal;2;0;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;3;-948.7271,-15.71855;Float;False;True;True;True;False;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.RangedFloatNode;24;-257.5781,1138.741;Float;False;Constant;_Const1_02;Const1_02;9;0;-1;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;22;-277.5781,996.7413;Float;False;World;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.Vector3Node;15;-638.9064,924.5498;Float;False;Constant;_Const3_01;Const3_01;9;0;0,1,0;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.WorldNormalVector;14;-658.7298,759.6462;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;19;-382.578,872.7411;Float;False;Constant;_Const1_01;Const1_01;9;0;0.5;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-88.57803,1063.741;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.DotProductOpNode;17;-347.578,759.7411;Float;False;2;0;FLOAT3;0.0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-212.578,805.7411;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;30;147.4219,1033.741;Float;False;Constant;_Const1_03;Const1_03;9;0;1.75;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.DotProductOpNode;27;188.422,929.7411;Float;False;2;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;35;-472.9889,539.6292;Float;False;World;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;6;-474.1099,149.1785;Float;False;Property;_RimPower;Rim Power;5;0;0;0;10;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;29;337.422,929.7411;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;20;-71.57803,854.7411;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.FunctionNode;34;-144.0281,521.4412;Float;False;Schlick Fresnel;-1;;36;a1f21a3cacd7a6d46965aa8e3cd29501;3;0;FLOAT;0.0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;21;53.42191,854.7411;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;28;470.4221,929.7411;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;5;575.9576,670.2689;Fixed;False;Property;_RimColor;Rim Color;6;0;1,1,1,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;642.4219,837.7411;Float;False;3;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;7;-896.827,-202.3186;Fixed;False;Property;_ColorTint;Color Tint;0;0;1,1,1,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;4;-454.0401,228.7914;Fixed;False;Property;_SpecularColor;Specular Color;8;0;1,1,1,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;8;-975.373,-389.003;Float;True;Property;_MainRGBSpecA;Main (RGB) Spec (A);1;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;11;-471.5658,463.5935;Float;False;Property;_Roughness;Roughness;4;0;0;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;797.695,748.1595;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;10;-474.5658,395.5935;Half;False;Property;_SpecularPower;Specular Power;7;0;0.33;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.FunctionNode;43;-11.84969,28.74247;Float;False;Oren Nayar Blinn;-1;;66;213c3d6404f827644885750c46cbd46c;10;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;COLOR;0,0,0,0;False;5;FLOAT;0.0;False;6;FLOAT;0.0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;9;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.ComponentMaskNode;37;933.6949,743.1595;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1319.475,230.2124;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Pipeworks_Custom/Oren Nayar Blinn ASE;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0.0,0,0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;2;5;1;0
WireConnection;3;0;2;0
WireConnection;14;0;3;0
WireConnection;23;0;22;0
WireConnection;23;1;24;0
WireConnection;17;0;14;0
WireConnection;17;1;15;0
WireConnection;18;0;17;0
WireConnection;18;1;19;0
WireConnection;27;0;15;0
WireConnection;27;1;23;0
WireConnection;29;0;27;0
WireConnection;29;1;30;0
WireConnection;20;0;18;0
WireConnection;20;1;19;0
WireConnection;34;0;6;0
WireConnection;34;1;35;0
WireConnection;34;2;14;0
WireConnection;21;0;20;0
WireConnection;28;0;29;0
WireConnection;31;0;34;0
WireConnection;31;1;21;0
WireConnection;31;2;28;0
WireConnection;36;0;5;0
WireConnection;36;1;31;0
WireConnection;43;0;8;0
WireConnection;43;1;7;0
WireConnection;43;2;3;0
WireConnection;43;3;6;0
WireConnection;43;4;4;0
WireConnection;43;5;10;0
WireConnection;43;6;11;0
WireConnection;37;0;36;0
WireConnection;0;2;37;0
WireConnection;0;13;43;0
ASEEND*/
//CHKSM=ABBD919E5706D0359A78E31EBF41CA9CAFF07AFA