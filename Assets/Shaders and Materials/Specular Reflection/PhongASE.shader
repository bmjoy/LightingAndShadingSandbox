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
		uniform float _SpecularPower;
		uniform half _SpecularIntensity;
		uniform fixed4 _SpecularColor;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float dotResult3_g61 = dot( i.worldNormal , ase_worldlightDir );
			float2 uv_BaseRGB = i.uv_texcoord * _BaseRGB_ST.xy + _BaseRGB_ST.zw;
			fixed3 DIFFUSE8 = saturate( ( saturate( max( dotResult3_g61 , 0.0 ) ) * (_BaseTint).rgb * ((tex2D( _BaseRGB, uv_BaseRGB )).rgb).xyz * _LightColor0.rgb * 1 ) );
			float3 temp_output_3_0_g59 = ase_worldlightDir;
			float3 temp_output_2_0_g59 = i.worldNormal;
			float dotResult5_g59 = dot( temp_output_3_0_g59 , temp_output_2_0_g59 );
			float dotResult44 = dot( i.viewDir , ( ( 2.0 * saturate( max( dotResult5_g59 , 0.0 ) ) * temp_output_2_0_g59 ) - temp_output_3_0_g59 ) );
			fixed3 SPECULAR22 = ( pow( saturate( max( dotResult44 , 0.0 ) ) , ( _SpecularPower * 128.0 ) ) * _SpecularIntensity * (_SpecularColor).rgb * _LightColor0.rgb * 1 );
			c.rgb = ( DIFFUSE8 + SPECULAR22 );
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
1953;34;1796;1125;2521.306;-515.4268;1.6;True;False
Node;AmplifyShaderEditor.CommentaryNode;54;-2220.234,1404.069;Float;False;1281.078;679.509;Phong spec calculation;11;43;45;47;46;49;48;41;53;52;50;51;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;45;-2126.234,1639.069;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;47;-2170.234,1772.069;Float;False;1;0;FLOAT;0.0;False;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;43;-1653.234,1454.069;Float;False;197;155;V dot R;1;44;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;46;-2118.234,1498.069;Float;False;World;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.FunctionNode;49;-1914.234,1750.069;Float;False;Reflection Vector;-1;;59;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.DotProductOpNode;44;-1603.234,1504.069;Float;False;2;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;53;-1647.014,1968.578;Float;False;Constant;_Float1;Float 1;0;0;128;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;41;-2168.416,1914.581;Float;False;Property;_SpecularPower;Specular Power;4;0;0.2;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMaxOpNode;48;-1419.156,1504.037;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-1491.309,1912.048;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SaturateNode;50;-1285.233,1504.069;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;1;-799.0553,1008.017;Half;False;Property;_BaseTint;Base Tint;0;0;0.9191176,0.5205312,0.2840074,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;2;-849.1442,823.683;Float;True;Property;_BaseRGB;Base (RGB);1;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;15;-896.9147,1663.886;Fixed;False;Property;_SpecularColor;Specular Color;2;0;0.9191176,0.5205312,0.2840074,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;17;-707.3663,1596.164;Half;False;Property;_SpecularIntensity;Specular Intensity;3;0;1;0;10;0;1;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;21;-641.8806,1663.782;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.FunctionNode;37;-537.8423,989.8717;Float;False;Lambert;-1;;60;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;1;FLOAT3
Node;AmplifyShaderEditor.LightAttenuation;38;-608.8879,1851.771;Float;False;0;1;FLOAT
Node;AmplifyShaderEditor.PowerNode;51;-1119.156,1504.037;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.LightColorNode;16;-603.3661,1743.163;Float;False;0;3;COLOR;FLOAT3;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-336.8886,1501.77;Float;False;5;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT3;0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.SaturateNode;35;-234.8423,989.8717;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-147.8813,1496.783;Fixed;False;SPECULAR;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.GetLocalVarNode;23;-730.9752,369.5435;Float;False;22;0;1;FLOAT3
Node;AmplifyShaderEditor.GetLocalVarNode;13;-723.0999,301.6487;Float;False;8;0;1;FLOAT3
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-64.0596,985.1509;Fixed;False;DIFFUSE;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-542.0999,329.6487;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-262.7106,284.6523;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Pipeworks_Custom/Phong ASE;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;14;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;10;-886.8859,152.0229;Float;False;1021.7;100;;0;Master;0,0,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;19;-895.2988,1241.555;Float;False;1021.645;101;;0;Specular;0,1,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;6;-893,720.7798;Float;False;1020;101;;0;Lambert Wrap Diffuse;0.9191176,0,0,1;0;0
WireConnection;49;0;45;0
WireConnection;49;1;47;0
WireConnection;44;0;46;0
WireConnection;44;1;49;0
WireConnection;48;0;44;0
WireConnection;52;0;41;0
WireConnection;52;1;53;0
WireConnection;50;0;48;0
WireConnection;21;0;15;0
WireConnection;37;0;2;0
WireConnection;37;1;1;0
WireConnection;51;0;50;0
WireConnection;51;1;52;0
WireConnection;40;0;51;0
WireConnection;40;1;17;0
WireConnection;40;2;21;0
WireConnection;40;3;16;1
WireConnection;40;4;38;0
WireConnection;35;0;37;0
WireConnection;22;0;40;0
WireConnection;8;0;35;0
WireConnection;14;0;13;0
WireConnection;14;1;23;0
WireConnection;0;2;14;0
ASEEND*/
//CHKSM=FAC2F3F2AC8413DC6BCE5972E3ED2BF75ED3C8F3