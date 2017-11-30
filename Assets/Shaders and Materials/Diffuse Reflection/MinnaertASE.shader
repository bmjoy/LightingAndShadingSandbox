// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pipeworks_Custom/MinnaertASE"
{
	Properties
	{
		_BaseTint("Base Tint", Color) = (1,1,1,1)
		_BaseRGBSpecA("Base (RGB) Spec (A)", 2D) = "white" {}
		_Normal("Normal", 2D) = "white" {}
		_NormalScale("Normal Scale", Range( 0 , 5)) = 0
		_RimPower("Rim Power", Range( 0 , 10)) = 0
		_RimColor("Rim Color", Color) = (0,0,0,0)
		_Darken("Darken", Range( 0 , 10)) = 0
		_SpecularPower("Specular Power", Range( 0 , 2)) = 0.33
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
		uniform float _Darken;
		uniform half _SpecularPower;
		uniform fixed4 _SpecularColor;
		uniform sampler2D _BaseRGBSpecA;
		uniform float4 _BaseRGBSpecA_ST;
		uniform fixed4 _BaseTint;
		uniform float4 _RimColor;
		uniform float _RimPower;

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
			float3 temp_output_7_0 = (UnpackScaleNormal( tex2D( _Normal, uv_Normal ) ,_NormalScale )).xyz;
			half3 normals45_g211 = WorldNormalVector( i , temp_output_7_0 );
			float3 temp_output_4_0_g213 = normals45_g211;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float3 temp_output_2_0_g211 = ase_worldlightDir;
			float dotResult3_g215 = dot( temp_output_4_0_g213 , temp_output_2_0_g211 );
			float NdotL19_g213 = saturate( max( dotResult3_g215 , 0.0 ) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult4_g214 = dot( temp_output_4_0_g213 , ase_worldViewDir );
			half diffuseL62_g211 = saturate( ( pow( ( NdotL19_g213 * saturate( max( dotResult4_g214 , 0.0 ) ) ) , _Darken ) * NdotL19_g213 ) );
			float3 normalizeResult5_g35 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult6_g35 = dot( WorldNormalVector( i , temp_output_7_0 ) , normalizeResult5_g35 );
			float4 temp_output_87_0_g211 = _SpecularColor;
			float2 uv_BaseRGBSpecA = i.uv_texcoord * _BaseRGBSpecA_ST.xy + _BaseRGBSpecA_ST.zw;
			float4 temp_output_20_0_g211 = tex2D( _BaseRGBSpecA, uv_BaseRGBSpecA );
			fixed specMap101_g211 = (temp_output_20_0_g211).a;
			float3 diffuseC96_g211 = ( (_BaseTint).rgb * (temp_output_20_0_g211).rgb );
			float3 temp_output_34_0_g211 = ( -1.0 * ase_worldViewDir );
			half3 minusViewDir52_g211 = temp_output_34_0_g211;
			float3 _Vector0 = float3(0,1,0);
			float dotResult54_g211 = dot( minusViewDir52_g211 , _Vector0 );
			float dotResult43_g211 = dot( _Vector0 , normals45_g211 );
			float temp_output_51_0_g211 = ( saturate( ( dotResult54_g211 + 1.75 ) ) * saturate( ( ( dotResult43_g211 * 0.5 ) + 0.5 ) ) );
			float3 temp_output_7_0_g212 = temp_output_34_0_g211;
			float3 normalizeResult10_g212 = normalize( ( temp_output_2_0_g211 + temp_output_7_0_g212 ) );
			float dotResult13_g212 = dot( normalizeResult10_g212 , temp_output_7_0_g212 );
			float temp_output_31_0_g212 = pow( ( 1.0 - dotResult13_g212 ) , _RimPower );
			float temp_output_40_0_g212 = ( 1.0 / 1.31 );
			float3 normalizeResult11_g211 = normalize( normals45_g211 );
			UnityGI gi12_g211 = gi;
			gi12_g211 = UnityGI_Base( data, 1, normalizeResult11_g211 );
			float3 indirectDiffuse12_g211 = gi12_g211.indirect.diffuse;
			half3 diffuse73_g211 = saturate( ( ( ( ( diffuseL62_g211 * ( temp_output_51_0_g211 * ( temp_output_31_0_g212 + ( ( 1.0 - temp_output_31_0_g212 ) * ( pow( ( 1.0 - temp_output_40_0_g212 ) , 2.0 ) / pow( ( 1.0 + temp_output_40_0_g212 ) , 2.0 ) ) ) ) ) ) + diffuseL62_g211 ) * ( _LightColor0.rgb * ase_lightAtten ) ) + indirectDiffuse12_g211 ) );
			float4 appendResult94_g211 = (float4(( ( ( ( diffuseL62_g211 * saturate( pow( max( dotResult6_g35 , 0.0 ) , ( _SpecularPower * 128.0 ) ) ) ) * (temp_output_87_0_g211).rgb * (temp_output_87_0_g211).a * specMap101_g211 ) + diffuseC96_g211 ) * saturate( ( ( ( temp_output_51_0_g211 * ( 1.0 - diffuseL62_g211 ) ) * (_RimColor).rgb ) + diffuse73_g211 ) ) ).x , ( ( ( ( diffuseL62_g211 * saturate( pow( max( dotResult6_g35 , 0.0 ) , ( _SpecularPower * 128.0 ) ) ) ) * (temp_output_87_0_g211).rgb * (temp_output_87_0_g211).a * specMap101_g211 ) + diffuseC96_g211 ) * saturate( ( ( ( temp_output_51_0_g211 * ( 1.0 - diffuseL62_g211 ) ) * (_RimColor).rgb ) + diffuse73_g211 ) ) ).y , ( ( ( ( diffuseL62_g211 * saturate( pow( max( dotResult6_g35 , 0.0 ) , ( _SpecularPower * 128.0 ) ) ) ) * (temp_output_87_0_g211).rgb * (temp_output_87_0_g211).a * specMap101_g211 ) + diffuseC96_g211 ) * saturate( ( ( ( temp_output_51_0_g211 * ( 1.0 - diffuseL62_g211 ) ) * (_RimColor).rgb ) + diffuse73_g211 ) ) ).z , 1.0));
			c.rgb = (appendResult94_g211).xyz;
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
1953;34;1796;1125;2836.529;554.8719;1.3;True;False
Node;AmplifyShaderEditor.RangedFloatNode;17;-2296.966,-16.44409;Float;False;Property;_NormalScale;Normal Scale;3;0;0;0;5;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;6;-2015.569,-61.66411;Float;True;Property;_Normal;Normal;2;0;None;True;0;True;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;7;-1726.569,-61.66411;Float;False;True;True;True;False;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.RangedFloatNode;10;-1771.446,141.0804;Half;False;Property;_SpecularPower;Specular Power;7;0;0.33;0;2;0;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;11;-1396.682,160.5458;Fixed;False;Property;_SpecularColor;Specular Color;8;0;1,1,1,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;12;-1391.782,321.7461;Float;False;Property;_RimColor;Rim Color;5;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;14;-1458.028,480.5682;Float;False;Property;_RimPower;Rim Power;4;0;0;0;10;0;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;4;-1725.369,-227.4642;Fixed;False;Property;_BaseTint;Base Tint;0;0;1,1,1,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.FunctionNode;9;-1466.446,73.08044;Float;False;Blinn Phong;-1;;35;1d2fe4dd949cc274fada205553d043f9;2;0;FLOAT;0.0;False;1;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;2;-1808.915,-413.1486;Float;True;Property;_BaseRGBSpecA;Base (RGB) Spec (A);1;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;15;-1457.996,549.715;Float;False;Property;_Darken;Darken;6;0;0;0;10;0;1;FLOAT
Node;AmplifyShaderEditor.FunctionNode;51;-709.297,77.50027;Float;False;Minnaert;-1;;211;4b58cda758f533243a1a954e6aaae021;10;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;FLOAT;0.0;False;7;FLOAT;0.0;False;8;FLOAT3;0,0,0;False;9;FLOAT3;0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.ComponentMaskNode;19;-292.9658,173.5559;Float;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Pipeworks_Custom/MinnaertASE;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0.0,0,0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;5;17;0
WireConnection;7;0;6;0
WireConnection;9;0;10;0
WireConnection;9;1;7;0
WireConnection;51;0;2;0
WireConnection;51;1;4;0
WireConnection;51;2;7;0
WireConnection;51;3;9;0
WireConnection;51;4;11;0
WireConnection;51;5;12;0
WireConnection;51;6;14;0
WireConnection;51;7;15;0
WireConnection;19;0;51;0
WireConnection;0;13;19;0
ASEEND*/
//CHKSM=0B8F8B29490C96CEEC0FBA069B1419A7064641DA