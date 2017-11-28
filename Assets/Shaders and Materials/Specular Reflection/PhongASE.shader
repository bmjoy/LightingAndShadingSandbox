// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pipeworks_Custom/Phong ASE"
{
	Properties
	{
		_BaseTint("Base Tint", Color) = (0.9191176,0.5205312,0.2840074,1)
		_BaseRGB("Base (RGB)", 2D) = "white" {}
		_SpecularColor("Specular Color", Color) = (0.9191176,0.5205312,0.2840074,1)
		_SpecularIntensity("Specular Intensity", Range( 0 , 10)) = 1
		_SpecularPower("Specular Power", Range( 0 , 1)) = 0.2
		_Normals("Normals", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 4)) = 1
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

		uniform half _NormalScale;
		uniform sampler2D _Normals;
		uniform float4 _Normals_ST;
		uniform half4 _BaseTint;
		uniform sampler2D _BaseRGB;
		uniform float4 _BaseRGB_ST;
		uniform float _SpecularPower;
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
			half3 NORMALS65 = (UnpackScaleNormal( tex2D( _Normals, uv_Normals ) ,_NormalScale )).xyz;
			float3 newWorldNormal22_g78 = WorldNormalVector( i , NORMALS65 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float dotResult3_g80 = dot( newWorldNormal22_g78 , ase_worldlightDir );
			float temp_output_6_0_g79 = (saturate( max( dotResult3_g80 , 0.0 ) )*0.5 + ( 1.0 - 0.5 ));
			float3 normalizeResult24_g78 = normalize( newWorldNormal22_g78 );
			UnityGI gi37_g78 = gi;
			gi37_g78 = UnityGI_Base( data, 1, normalizeResult24_g78 );
			float3 indirectDiffuse37_g78 = gi37_g78.indirect.diffuse;
			float2 uv_BaseRGB = i.uv_texcoord * _BaseRGB_ST.xy + _BaseRGB_ST.zw;
			float4 temp_output_28_0_g78 = tex2D( _BaseRGB, uv_BaseRGB );
			fixed3 DIFFUSE8 = ( ( ( saturate( max( ( temp_output_6_0_g79 * temp_output_6_0_g79 ) , 0.0 ) ) * ( _LightColor0.rgb * ase_lightAtten ) ) + indirectDiffuse37_g78 ) * (_BaseTint).rgb * (temp_output_28_0_g78).rgb );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 temp_output_3_0_g88 = ase_worldlightDir;
			float3 temp_output_2_0_g88 = WorldNormalVector( i , NORMALS65 );
			float dotResult5_g88 = dot( temp_output_3_0_g88 , temp_output_2_0_g88 );
			float dotResult7_g87 = dot( ase_worldViewDir , ( ( 2.0 * saturate( max( dotResult5_g88 , 0.0 ) ) * temp_output_2_0_g88 ) - temp_output_3_0_g88 ) );
			fixed3 SPECULAR22 = ( pow( saturate( max( dotResult7_g87 , 0.0 ) ) , ( _SpecularPower * 128.0 ) ) * _SpecularIntensity * (_SpecularColor).rgb * _LightColor0.rgb * ase_lightAtten );
			c.rgb = saturate( ( DIFFUSE8 + SPECULAR22 ) );
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
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
				float4 texcoords01 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal( v.normal );
				fixed3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.texcoords01 = float4( v.texcoord.xy, v.texcoord1.xy );
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
				surfIN.uv_texcoord.xy = IN.texcoords01.xy;
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
Version=13803
1953;34;1796;1125;1251.678;-1002.014;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;61;-897.1194,1889.284;Float;False;1096.577;280.219;;4;65;64;63;62;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-847.1194,1985.077;Half;False;Property;_NormalScale;Normal Scale;6;0;1;0;4;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;63;-574.1147,1939.503;Float;True;Property;_Normals;Normals;5;0;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;19;-897.8988,1305.255;Float;False;1150.245;505.7;Phong;7;22;16;17;21;15;41;70;Specular;0,1,0,0.5882353;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;64;-289.4196,1939.284;Float;False;True;True;True;False;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.ColorNode;15;-859.8141,1553.485;Fixed;False;Property;_SpecularColor;Specular Color;2;0;0.9191176,0.5205312,0.2840074,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;6;-896.3,702.58;Float;False;1150.8;555.1;Half Lambert;5;66;8;57;1;2;Diffuse;0.9191176,0,0,0.5882353;0;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-848.2908,1387.54;Float;False;Property;_SpecularPower;Specular Power;4;0;0.2;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.GetLocalVarNode;70;-861.6782,1461.014;Float;False;65;0;1;FLOAT3
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-43.54269,1939.386;Half;False;NORMALS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.ComponentMaskNode;21;-604.7802,1553.381;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.FunctionNode;71;-574.3062,1393.026;Float;False;Phong;-1;;87;797d6640119c1a04d98b7512b0da5e7b;2;0;FLOAT;0.0;False;1;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;17;-670.2657,1485.763;Half;False;Property;_SpecularIntensity;Specular Intensity;3;0;1;0;10;0;1;FLOAT
Node;AmplifyShaderEditor.GetLocalVarNode;66;-814.6782,1178.014;Float;False;65;0;1;FLOAT3
Node;AmplifyShaderEditor.LightAttenuation;38;-571.7875,1741.37;Float;False;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;2;-870.1442,817.683;Float;True;Property;_BaseRGB;Base (RGB);1;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;1;-839.0553,1009.017;Half;False;Property;_BaseTint;Base Tint;0;0;0.9191176,0.5205312,0.2840074,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LightColorNode;16;-570.2657,1625.762;Float;False;0;3;COLOR;FLOAT3;FLOAT
Node;AmplifyShaderEditor.FunctionNode;57;-544.6135,903.1041;Float;False;Lambert Wrap;-1;;78;31f8f5f80290a284a82e58e8d6bb3fef;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0.0,0,0;False;4;FLOAT3;0,0,0;False;2;FLOAT3;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;10;-894.1397,152.0229;Float;False;1150.654;444.0731;;5;23;13;0;14;58;Master;0,0,1,0.5882353;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-299.7885,1391.37;Float;False;5;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT3;0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-73.5596,897.4509;Fixed;False;DIFFUSE;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.GetLocalVarNode;23;-696.9752,297.5435;Float;False;22;0;1;FLOAT3
Node;AmplifyShaderEditor.GetLocalVarNode;13;-692.9999,229.6487;Float;False;8;0;1;FLOAT3
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-110.7813,1386.382;Fixed;False;SPECULAR;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-508.0999,257.6487;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.SaturateNode;58;-382.3671,257.5707;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-225.7106,211.6523;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Pipeworks_Custom/Phong ASE;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0.0,0,0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;63;5;62;0
WireConnection;64;0;63;0
WireConnection;65;0;64;0
WireConnection;21;0;15;0
WireConnection;71;0;41;0
WireConnection;71;1;70;0
WireConnection;57;0;2;0
WireConnection;57;1;1;0
WireConnection;57;2;66;0
WireConnection;40;0;71;0
WireConnection;40;1;17;0
WireConnection;40;2;21;0
WireConnection;40;3;16;1
WireConnection;40;4;38;0
WireConnection;8;0;57;0
WireConnection;22;0;40;0
WireConnection;14;0;13;0
WireConnection;14;1;23;0
WireConnection;58;0;14;0
WireConnection;0;13;58;0
ASEEND*/
//CHKSM=B4C07418FFEDC39EA4B51D229AE9E8226C7A2750