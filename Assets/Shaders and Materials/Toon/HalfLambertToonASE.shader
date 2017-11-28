// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pipeworks_Custom/HalfLambertToonASE"
{
	Properties
	{
		[Header(Toon)]
		[Toggle]_UseRampTex("Use Ramp Tex", Float) = 0
		_ToonRampRGB("Toon Ramp (RGB)", 2D) = "white" {}
		[Toggle]_UseHalfLambert("Use Half Lambert", Float) = 1
		[IntRange]_CellShadingLevels("Cell Shading Levels", Range( 2 , 10)) = 5
		_BaseTint("Base Tint", Color) = (1,1,1,1)
		_BaseRGB("Base (RGB)", 2D) = "white" {}
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_SpecularIntensity("Specular Intensity", Range( 0 , 10)) = 1
		_GlossSpecPower("Gloss (Spec Power)", Range( 0 , 10)) = 3
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
			half2 uv_texcoord;
			float3 worldPos;
			half3 data60;
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
		uniform fixed _UseHalfLambert;
		uniform half _NormalScale;
		uniform sampler2D _Normals;
		uniform float4 _Normals_ST;
		uniform sampler2D _ToonRampRGB;
		uniform fixed4 _BaseTint;
		uniform sampler2D _BaseRGB;
		uniform float4 _BaseRGB_ST;
		uniform half _GlossSpecPower;
		uniform half _SpecularIntensity;
		uniform fixed4 _SpecularColor;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 uv_Normals = v.texcoord * _Normals_ST.xy + _Normals_ST.zw;
			half3 NORMALS147 = (UnpackScaleNormal( tex2Dlod( _Normals, half4( uv_Normals, 0, 0.0) ) ,_NormalScale )).xyz;
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float3 ase_worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
			float3x3 tangentToWorld = CreateTangentToWorldPerVertex( ase_worldNormal, ase_worldTangent, v.tangent.w );
			float3 tangentNormal24_g133 = NORMALS147;
			float3 modWorldNormal24_g133 = (tangentToWorld[0] * tangentNormal24_g133.x + tangentToWorld[1] * tangentNormal24_g133.y + tangentToWorld[2] * tangentNormal24_g133.z);
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float3 normalizeResult5_g133 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult6_g133 = dot( modWorldNormal24_g133 , normalizeResult5_g133 );
			o.data60 = ( saturate( pow( max( dotResult6_g133 , 0.0 ) , ( _GlossSpecPower * 128.0 ) ) ) * _SpecularIntensity * (_SpecularColor).rgb * _LightColor0.rgb );
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
			float temp_output_25_0_g166 = _CellShadingLevels;
			float2 uv_Normals = i.uv_texcoord * _Normals_ST.xy + _Normals_ST.zw;
			half3 NORMALS147 = (UnpackScaleNormal( tex2D( _Normals, uv_Normals ) ,_NormalScale )).xyz;
			float3 newWorldNormal62_g166 = WorldNormalVector( i , NORMALS147 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float3 temp_output_63_0_g166 = ase_worldlightDir;
			float dotResult3_g169 = dot( newWorldNormal62_g166 , temp_output_63_0_g166 );
			float dotResult3_g168 = dot( newWorldNormal62_g166 , temp_output_63_0_g166 );
			float temp_output_6_0_g167 = (saturate( max( dotResult3_g168 , 0.0 ) )*0.5 + ( 1.0 - 0.5 ));
			fixed3 temp_cast_0 = (( floor( ( temp_output_25_0_g166 * lerp(saturate( max( dotResult3_g169 , 0.0 ) ),saturate( max( ( temp_output_6_0_g167 * temp_output_6_0_g167 ) , 0.0 ) ),_UseHalfLambert) ) ) / ( temp_output_25_0_g166 - 0.5 ) )).xxx;
			float2 appendResult35_g166 = (float2(lerp(saturate( max( dotResult3_g169 , 0.0 ) ),saturate( max( ( temp_output_6_0_g167 * temp_output_6_0_g167 ) , 0.0 ) ),_UseHalfLambert) , 0.5));
			float4 tex2DNode41_g166 = tex2D( _ToonRampRGB, appendResult35_g166 );
			float3 normalizeResult14_g166 = normalize( newWorldNormal62_g166 );
			UnityGI gi22_g166 = gi;
			gi22_g166 = UnityGI_Base( data, 1, normalizeResult14_g166 );
			float3 indirectDiffuse22_g166 = gi22_g166.indirect.diffuse;
			float2 uv_BaseRGB = i.uv_texcoord * _BaseRGB_ST.xy + _BaseRGB_ST.zw;
			fixed3 DIFFUSE63 = ( ( ( lerp(temp_cast_0,(tex2DNode41_g166).rgb,_UseRampTex) * ( _LightColor0.rgb * ase_lightAtten ) ) + indirectDiffuse22_g166 ) * (_BaseTint).rgb * (tex2D( _BaseRGB, uv_BaseRGB )).rgb );
			fixed3 SPECULAR64 = i.data60;
			c.rgb = saturate( ( DIFFUSE63 + SPECULAR64 ) );
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
				Input customInputData;
				vertexDataFunc( v, customInputData );
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
1953;34;1796;1125;3349.383;187.9109;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;146;-2815.752,1281.415;Float;False;1126.698;269.2189;;4;139;140;138;147;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;138;-2765.752,1377.208;Half;False;Property;_NormalScale;Normal Scale;11;0;1;0;4;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;140;-2492.749,1331.634;Float;True;Property;_Normals;Normals;10;0;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;139;-2208.054,1331.415;Float;False;True;True;True;False;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.CommentaryNode;73;-2814.117,723.8041;Float;False;1585.359;462.3004;Blinn Phong (Per Vert);10;64;59;72;99;57;58;71;53;132;148;Specular;1,0,0,0.5882353;0;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-2726.516,802.6841;Half;False;Property;_GlossSpecPower;Gloss (Spec Power);9;0;3;0;10;0;1;FLOAT
Node;AmplifyShaderEditor.GetLocalVarNode;148;-2644.784,880.6893;Float;False;147;0;1;FLOAT3
Node;AmplifyShaderEditor.ColorNode;71;-2665.871,965.5322;Fixed;False;Property;_SpecularColor;Specular Color;7;0;1,1,1,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RegisterLocalVarNode;147;-1965.054,1331.153;Half;False;NORMALS;-1;True;1;0;FLOAT3;0.0;False;1;FLOAT3
Node;AmplifyShaderEditor.LightColorNode;57;-2314.323,1033.812;Float;False;0;3;COLOR;FLOAT3;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;58;-2430.323,897.8099;Half;False;Property;_SpecularIntensity;Specular Intensity;8;0;1;0;10;0;1;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;99;-2363.374,965.7412;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.CommentaryNode;74;-2815.188,-58.04008;Float;False;1405.288;633.2452;Toon;6;63;144;88;37;145;19;Diffuse;0.03448296,1,0,0.5882353;0;0
Node;AmplifyShaderEditor.FunctionNode;132;-2450.811,807.7311;Float;False;Blinn Phong;-1;;133;1d2fe4dd949cc274fada205553d043f9;2;0;FLOAT;0.0;False;1;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.GetLocalVarNode;145;-2269.756,455.3532;Float;False;147;0;1;FLOAT3
Node;AmplifyShaderEditor.RangedFloatNode;37;-2365.28,34.43657;Float;False;Property;_CellShadingLevels;Cell Shading Levels;4;1;[IntRange];5;2;10;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;88;-2379.506,106.5315;Float;True;Property;_BaseRGB;Base (RGB);6;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;19;-2332.231,287.7668;Fixed;False;Property;_BaseTint;Base Tint;5;0;1,1,1,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-2092.325,924.8101;Float;False;4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT3;0;False;3;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.CommentaryNode;72;-1913.901,881.233;Float;False;196.2;124.8;Bypass for per-pixel.;1;60;;1,1,1,0;0;0
Node;AmplifyShaderEditor.CommentaryNode;75;-2816.267,-617.0594;Float;False;1005.413;487.5204;;5;0;70;67;66;65;Master;0,0,1,0.5882353;0;0
Node;AmplifyShaderEditor.FunctionNode;144;-1992.704,88.99036;Float;False;Toon;0;;166;0ffb1693e7af3a14da83f10323240483;6;0;FLOAT;0.0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;3;FLOAT3;FLOAT;FLOAT
Node;AmplifyShaderEditor.VertexToFragmentNode;60;-1899.325,924.8101;Float;False;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.GetLocalVarNode;66;-2679.387,-454.0927;Float;False;64;0;1;FLOAT3
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-1471.769,918.5311;Fixed;False;SPECULAR;-1;True;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-1628.016,84.46056;Fixed;False;DIFFUSE;-1;True;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.GetLocalVarNode;65;-2673.787,-521.6932;Float;False;63;0;1;FLOAT3
Node;AmplifyShaderEditor.SimpleAddOpNode;67;-2479.487,-497.0926;Float;False;2;2;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.SaturateNode;70;-2304.489,-497.0926;Float;False;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-2069.525,-542.3498;Half;False;True;2;Half;ASEMaterialInspector;0;0;CustomLighting;Pipeworks_Custom/HalfLambertToonASE;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;False;0;255;255;0;0;0;0;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0.0,0,0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;140;5;138;0
WireConnection;139;0;140;0
WireConnection;147;0;139;0
WireConnection;99;0;71;0
WireConnection;132;0;53;0
WireConnection;132;1;148;0
WireConnection;59;0;132;0
WireConnection;59;1;58;0
WireConnection;59;2;99;0
WireConnection;59;3;57;1
WireConnection;144;0;37;0
WireConnection;144;1;88;0
WireConnection;144;2;19;0
WireConnection;144;3;145;0
WireConnection;60;0;59;0
WireConnection;64;0;60;0
WireConnection;63;0;144;0
WireConnection;67;0;65;0
WireConnection;67;1;66;0
WireConnection;70;0;67;0
WireConnection;0;13;70;0
ASEEND*/
//CHKSM=65CE55DDFEF207F696C845927B9A85A53BB2E48B