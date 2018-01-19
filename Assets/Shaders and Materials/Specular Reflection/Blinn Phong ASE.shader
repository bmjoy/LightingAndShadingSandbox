// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pipeworks_Custom/Blinn Phong ASE"
{
	Properties
	{
		_BaseTint("Base Tint", Color) = (0.9191176,0.5205312,0.2840074,1)
		_BaseRGB("Base (RGB)", 2D) = "white" {}
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_SpecularIntensity("Specular Intensity", Range( 0 , 10)) = 1
		_SpecularPower("Specular Power", Range( 0 , 2)) = 0.2
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
			half3 NORMALS40 = (UnpackScaleNormal( tex2D( _Normals, uv_Normals ) ,_NormalScale )).xyz;
			float3 newWorldNormal22_g63 = WorldNormalVector( i , NORMALS40 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float dotResult3_g65 = dot( newWorldNormal22_g63 , ase_worldlightDir );
			float temp_output_6_0_g64 = (saturate( max( dotResult3_g65 , 0.0 ) )*0.5 + ( 1.0 - 0.5 ));
			float3 normalizeResult24_g63 = normalize( newWorldNormal22_g63 );
			UnityGI gi37_g63 = gi;
			float3 diffNorm37_g63 = normalizeResult24_g63;
			gi37_g63 = UnityGI_Base( data, 1, diffNorm37_g63 );
			float3 indirectDiffuse37_g63 = gi37_g63.indirect.diffuse + diffNorm37_g63 * 0.0001;
			float2 uv_BaseRGB = i.uv_texcoord * _BaseRGB_ST.xy + _BaseRGB_ST.zw;
			float4 temp_output_28_0_g63 = tex2D( _BaseRGB, uv_BaseRGB );
			fixed3 DIFFUSE16 = ( ( ( saturate( max( ( temp_output_6_0_g64 * temp_output_6_0_g64 ) , 0.0 ) ) * ( _LightColor0.rgb * ase_lightAtten ) ) + indirectDiffuse37_g63 ) * (_BaseTint).rgb * (temp_output_28_0_g63).rgb );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult5_g62 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult6_g62 = dot( WorldNormalVector( i , NORMALS40 ) , normalizeResult5_g62 );
			fixed3 SPECULAR15 = ( saturate( pow( max( dotResult6_g62 , 0.0 ) , ( _SpecularPower * 128.0 ) ) ) * _SpecularIntensity * (_SpecularColor).rgb * _LightColor0.rgb * ase_lightAtten );
			c.rgb = saturate( ( DIFFUSE16 + SPECULAR15 ) );
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
Version=14205
1939;35;1796;1125;1578.789;417.3458;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;43;-1151.777,1608.722;Float;False;1096.577;280.219;;4;38;37;36;40;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-1101.777,1704.515;Half;False;Property;_NormalScale;Normal Scale;6;0;Create;True;1;1.02;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;37;-828.772,1658.941;Float;True;Property;_Normals;Normals;5;0;Create;True;None;b3d940e75e1f5d24684cd93a2758e1bf;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;36;-544.077,1658.722;Float;False;True;True;True;False;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;17;-1147.017,1046.236;Float;False;1140.715;497;Blinn Phong;9;15;13;12;8;10;29;3;4;41;Specular;0,1,0,0.5882353;0;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1071.736,1113.241;Half;False;Property;_SpecularPower;Specular Power;4;0;Create;True;0.2;0.2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-1072.2,1181.024;Float;False;40;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-298.2001,1658.824;Half;False;NORMALS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;4;-958.069,1276;Fixed;False;Property;_SpecularColor;Specular Color;2;0;Create;True;1,1,1,1;0.9191176,0.5205312,0.2840074,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;18;-1151.125,462.0261;Float;False;1155.973;511.6906;Half Lambert;5;42;7;6;16;31;Diffuse;0.9191176,0,0,0.5882353;0;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-768.5208,1208.277;Half;False;Property;_SpecularIntensity;Specular Intensity;3;0;Create;True;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;12;-664.5207,1355.277;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ComponentMaskNode;10;-703.0352,1275.896;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;44;-790.179,1117.777;Float;False;Blinn Phong;-1;;62;1d2fe4dd949cc274fada205553d043f9;0;2;9;FLOAT;0.0;False;23;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;7;-1027.18,713.2632;Half;False;Property;_BaseTint;Base Tint;0;0;Create;True;0.9191176,0.5205312,0.2840074,1;0.7426471,0.4033718,0.2020437,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;29;-669.4521,1465.04;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-984.2002,879.0239;Float;False;40;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;6;-1076.269,528.9293;Float;True;Property;_BaseRGB;Base (RGB);1;0;Create;True;None;a9f953c7353804247b8c3ed6e1c46a2e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;22;-1154.146,-134.8238;Float;False;1154.035;519.9;;5;0;33;21;19;20;Master;0,0,1,0.5882353;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-435.5213,1210.277;Float;False;5;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT3;0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;31;-731.188,614.4565;Float;False;Lambert Wrap;-1;;63;31f8f5f80290a284a82e58e8d6bb3fef;0;5;28;COLOR;0,0,0,0;False;32;COLOR;0,0,0,0;False;26;FLOAT3;0,0,0;False;34;FLOAT3;0.0,0,0;False;43;FLOAT3;0,0,0;False;2;FLOAT3;0;FLOAT;39
Node;AmplifyShaderEditor.GetLocalVarNode;19;-980.8524,48.36546;Float;False;15;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-976.9771,-22.5293;Float;False;16;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-261.0347,1204.896;Fixed;False;SPECULAR;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-277.1844,609.3972;Fixed;False;DIFFUSE;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-783.9771,5.470651;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;33;-664.4882,5.15652;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-431.8044,-35.44049;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Pipeworks_Custom/Blinn Phong ASE;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0.0,0,0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;37;5;38;0
WireConnection;36;0;37;0
WireConnection;40;0;36;0
WireConnection;10;0;4;0
WireConnection;44;9;3;0
WireConnection;44;23;41;0
WireConnection;13;0;44;0
WireConnection;13;1;8;0
WireConnection;13;2;10;0
WireConnection;13;3;12;1
WireConnection;13;4;29;0
WireConnection;31;28;6;0
WireConnection;31;32;7;0
WireConnection;31;26;42;0
WireConnection;15;0;13;0
WireConnection;16;0;31;0
WireConnection;21;0;20;0
WireConnection;21;1;19;0
WireConnection;33;0;21;0
WireConnection;0;13;33;0
ASEEND*/
//CHKSM=DBFD191DD157EDD47780AD50C03C9035BEE8B507