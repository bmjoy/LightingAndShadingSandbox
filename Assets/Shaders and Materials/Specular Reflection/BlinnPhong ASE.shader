// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pipeworks_Custom/Blinn-Phong ASE"
{
	Properties
	{
		_BaseTint("Base Tint", Color) = (0.9191176,0.5205312,0.2840074,1)
		_BaseRGB("Base (RGB)", 2D) = "white" {}
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_SpecularIntensity("Specular Intensity", Range( 0 , 10)) = 1
		_SpecularPower("Specular Power", Range( 0 , 2)) = 0.2
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
			float3 worldPos;
			float2 uv_texcoord;
			float3 viewDir;
			INTERNAL_DATA
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
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float dotResult3_g48 = dot( i.worldNormal , ase_worldlightDir );
			float2 uv_BaseRGB = i.uv_texcoord * _BaseRGB_ST.xy + _BaseRGB_ST.zw;
			fixed3 DIFFUSE16 = saturate( ( saturate( max( dotResult3_g48 , 0.0 ) ) * (_BaseTint).rgb * ((tex2D( _BaseRGB, uv_BaseRGB )).rgb).xyz * _LightColor0.rgb * ase_lightAtten ) );
			float3 normalizeResult5_g49 = normalize( ( ase_worldlightDir + i.viewDir ) );
			float dotResult6_g49 = dot( i.worldNormal , normalizeResult5_g49 );
			fixed3 SPECULAR15 = ( saturate( pow( max( dotResult6_g49 , 0.0 ) , ( _SpecularPower * 128.0 ) ) ) * _SpecularIntensity * (_SpecularColor).rgb * _LightColor0.rgb * ase_lightAtten );
			c.rgb = ( DIFFUSE16 + SPECULAR15 );
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
			# include "HLSLSupport.cginc"
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
				surfIN.viewDir = worldViewDir;
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
Version=13703
1953;34;1796;1125;1331.188;-351.4565;1;True;False
Node;AmplifyShaderEditor.SamplerNode;6;-1028.269,596.9293;Float;True;Property;_BaseRGB;Base (RGB);1;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;7;-979.1801,781.2632;Half;False;Property;_BaseTint;Base Tint;0;0;0.9191176,0.5205312,0.2840074,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;3;-1057.731,1145.724;Half;False;Property;_SpecularPower;Specular Power;4;0;0.2;0;2;0;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;4;-949.0628,1283.483;Fixed;False;Property;_SpecularColor;Specular Color;2;0;1,1,1,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.FunctionNode;30;-776.1728,1150.26;Float;False;BlinnPhong Base;-1;;49;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;8;-759.5146,1215.76;Half;False;Property;_SpecularIntensity;Specular Intensity;3;0;1;0;10;0;1;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;10;-694.029,1283.379;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.LightAttenuation;29;-660.4459,1472.523;Float;False;0;1;FLOAT
Node;AmplifyShaderEditor.FunctionNode;28;-694.9671,763.118;Float;False;Lambert;-1;;47;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;1;FLOAT3
Node;AmplifyShaderEditor.LightColorNode;12;-655.5145,1362.76;Float;False;0;3;COLOR;FLOAT3;FLOAT
Node;AmplifyShaderEditor.SaturateNode;14;-391.9671,763.118;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-421.5155,1242.76;Float;False;5;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT3;0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.GetLocalVarNode;19;-926.5522,90.66545;Float;False;15;0;1;FLOAT3
Node;AmplifyShaderEditor.GetLocalVarNode;20;-918.6769,22.7707;Float;False;16;0;1;FLOAT3
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-221.1844,758.3972;Fixed;False;DIFFUSE;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-247.0289,1237.379;Fixed;False;SPECULAR;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-737.6769,50.77064;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-547.5043,4.859507;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Pipeworks_Custom/Blinn-Phong ASE;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;14;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;18;-1148.125,462.0261;Float;False;1145.973;100;;0;Diffuse;0.9191176,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;17;-1148.012,1011.719;Float;False;1140.715;100;;0;Specular;0,1,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;22;-1154.146,-134.8238;Float;False;1151.435;100;;0;Master;0,0,1,1;0;0
WireConnection;30;0;3;0
WireConnection;10;0;4;0
WireConnection;28;0;6;0
WireConnection;28;1;7;0
WireConnection;14;0;28;0
WireConnection;13;0;30;0
WireConnection;13;1;8;0
WireConnection;13;2;10;0
WireConnection;13;3;12;1
WireConnection;13;4;29;0
WireConnection;16;0;14;0
WireConnection;15;0;13;0
WireConnection;21;0;20;0
WireConnection;21;1;19;0
WireConnection;0;2;21;0
ASEEND*/
//CHKSM=BAC9B59A5CE5BD957AC4E48113DEF029E9DB0AA9