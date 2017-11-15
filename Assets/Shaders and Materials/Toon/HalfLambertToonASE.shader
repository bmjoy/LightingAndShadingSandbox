// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pipeworks_Custom/HalfLambertToonASE"
{
	Properties
	{
		_BaseTint("Base Tint", Color) = (1,1,1,1)
		[Toggle]_UseRampTex("Use Ramp  Tex", Float) = 1
		_BaseRGB("Base (RGB)", 2D) = "white" {}
		_ToonRampRGB("Toon Ramp (RGB)", 2D) = "white" {}
		[IntRange]_CellShadingLevels("Cell Shading Levels", Range( 2 , 10)) = 2
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_SpecularIntensity("Specular Intensity", Range( 0 , 10)) = 1
		_GlossSpecPower("Gloss (Spec Power)", Range( 0 , 10)) = 3
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
		struct Input
		{
			float3 worldNormal;
			float3 worldPos;
			float2 uv_texcoord;
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
		uniform sampler2D _ToonRampRGB;
		uniform sampler2D _BaseRGB;
		uniform float4 _BaseRGB_ST;
		uniform fixed4 _BaseTint;
		uniform half _GlossSpecPower;
		uniform half _SpecularIntensity;
		uniform fixed4 _SpecularColor;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult5_g26 = normalize( ( ase_worldlightDir + ase_worldViewDir ) );
			float dotResult6_g26 = dot( ase_worldNormal , normalizeResult5_g26 );
			o.data60 = ( saturate( pow( max( dotResult6_g26 , 0.0 ) , ( _GlossSpecPower * 128.0 ) ) ) * _SpecularIntensity * (_SpecularColor).rgb * _LightColor0.rgb );
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
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float dotResult3_g24 = dot( i.worldNormal , ase_worldlightDir );
			float temp_output_6_0_g23 = (saturate( max( dotResult3_g24 , 0.0 ) )*0.65 + ( 1.0 - 0.65 ));
			float temp_output_92_0 = saturate( max( ( temp_output_6_0_g23 * temp_output_6_0_g23 ) , 0.0 ) );
			fixed3 temp_cast_0 = (( floor( ( _CellShadingLevels * temp_output_92_0 ) ) / ( _CellShadingLevels - 0.5 ) )).xxx;
			float2 appendResult29 = (half2(temp_output_92_0 , 0.5));
			float2 uv_BaseRGB = i.uv_texcoord * _BaseRGB_ST.xy + _BaseRGB_ST.zw;
			fixed3 DIFFUSE63 = ( lerp(temp_cast_0,(tex2D( _ToonRampRGB, appendResult29 )).rgb,_UseRampTex) * (tex2D( _BaseRGB, uv_BaseRGB )).rgb * (_BaseTint).rgb * ase_lightAtten * _LightColor0.rgb );
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
				float3 worldPos : TEXCOORD6;
				float3 worldNormal : TEXCOORD1;
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
				o.worldNormal = worldNormal;
				o.texcoords01 = float4( v.texcoord.xy, v.texcoord1.xy );
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
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
Version=13706
1953;34;1796;1125;2210.393;250.642;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;74;-2810.461,20.70782;Float;False;2778.921;867.3069;Half Lambert;14;63;95;96;97;40;101;100;88;19;92;94;43;103;93;Diffuse;0.03448296,1,0,0.5882353;0;0
Node;AmplifyShaderEditor.CommentaryNode;43;-2221.936,608.1403;Float;False;913.1957;222;Cell shading via ramp texture.;4;102;26;29;41;;1,1,1,0;0;0
Node;AmplifyShaderEditor.CommentaryNode;103;-2388.834,183.9627;Float;False;883.601;244;Cell shading via discrete levels.;5;38;32;36;35;37;;1,1,1,0;0;0
Node;AmplifyShaderEditor.WorldNormalVector;94;-2689.224,558.8396;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;93;-2737.324,427.5403;Float;False;1;0;FLOAT;0.0;False;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;37;-2371.834,260.9628;Float;False;Property;_CellShadingLevels;Cell Shading Levels;4;1;[IntRange];2;2;10;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;41;-2197.936,686.8958;Fixed;False;Constant;_Const_05;Const_0.5;3;0;0.5;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.FunctionNode;92;-2444.824,471.7399;Float;False;Lambert Wrap Base;-1;;23;d2fad7166e67ae841a437cc798d8cb09;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;73;-2805.314,993.7677;Float;False;1787.674;542;Blinn Phong (Per Vert);9;57;71;99;53;98;64;72;59;58;Specular;1,0,0,0.5882353;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;29;-1995.535,668.0961;Float;False;FLOAT2;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-2001.233,208.9627;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;71;-2556.068,1235.495;Fixed;False;Property;_SpecularColor;Specular Color;5;0;1,1,1,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;26;-1820.741,639.8403;Float;True;Property;_ToonRampRGB;Toon Ramp (RGB);3;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleSubtractOpNode;36;-2006.233,331.9627;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.5;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;53;-2702.113,1097.347;Half;False;Property;_GlossSpecPower;Gloss (Spec Power);7;0;3;0;10;0;1;FLOAT
Node;AmplifyShaderEditor.FloorOpNode;32;-1840.233,208.9627;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.FunctionNode;98;-2426.408,1102.394;Float;False;Blinn Phong;-1;;26;1d2fe4dd949cc274fada205553d043f9;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;58;-2421.52,1167.773;Half;False;Property;_SpecularIntensity;Specular Intensity;6;0;1;0;10;0;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;19;-1163.462,551.8909;Fixed;False;Property;_BaseTint;Base Tint;0;0;1,1,1,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;88;-1020.936,365.456;Float;True;Property;_BaseRGB;Base (RGB);2;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;99;-2354.571,1235.704;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.ComponentMaskNode;102;-1520.286,640.2563;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.SimpleDivideOpNode;38;-1660.233,308.9627;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.LightColorNode;57;-2305.52,1303.774;Float;False;0;3;COLOR;FLOAT3;FLOAT
Node;AmplifyShaderEditor.ComponentMaskNode;100;-910.9716,551.2435;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.ToggleSwitchNode;40;-1238.642,306.0893;Fixed;True;Property;_UseRampTex;Use Ramp  Tex;1;1;[Toggle];1;2;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0;False;1;FLOAT3
Node;AmplifyShaderEditor.LightAttenuation;96;-866.1915,618.3062;Float;False;0;1;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;72;-1905.098,1151.196;Float;False;196.2;124.8;Bypass for per-pixel.;1;60;;1,1,1,0;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-2083.522,1194.773;Float;False;4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT3;0;False;3;FLOAT3;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.ComponentMaskNode;101;-727.9716,365.2434;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.LightColorNode;97;-860.3068,681.5009;Float;False;0;3;COLOR;FLOAT3;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;75;-2810.331,-750.5659;Float;False;1267.813;544.656;;5;0;70;67;65;66;Master;0,0,1,0.5882353;0;0
Node;AmplifyShaderEditor.VertexToFragmentNode;60;-1890.522,1194.773;Float;False;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-475.5716,309.9669;Float;False;5;5;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0,0,0,0;False;2;FLOAT3;0,0,0,0;False;3;FLOAT;0,0,0;False;4;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.GetLocalVarNode;66;-2569.76,-528.3477;Float;False;64;0;1;FLOAT3
Node;AmplifyShaderEditor.GetLocalVarNode;65;-2564.161,-595.9483;Float;False;63;0;1;FLOAT3
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-1462.966,1188.494;Fixed;False;SPECULAR;-1;True;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-260.3047,304.1531;Fixed;False;DIFFUSE;-1;True;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.SimpleAddOpNode;67;-2369.86,-571.3475;Float;False;2;2;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.SaturateNode;70;-2194.862,-571.3475;Float;False;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-1959.898,-616.6045;Half;False;True;2;Half;ASEMaterialInspector;0;0;CustomLighting;Pipeworks_Custom/HalfLambertToonASE;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;False;0;255;255;0;0;0;0;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;14;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;92;0;93;0
WireConnection;92;1;94;0
WireConnection;29;0;92;0
WireConnection;29;1;41;0
WireConnection;35;0;37;0
WireConnection;35;1;92;0
WireConnection;26;1;29;0
WireConnection;36;0;37;0
WireConnection;36;1;41;0
WireConnection;32;0;35;0
WireConnection;98;0;53;0
WireConnection;99;0;71;0
WireConnection;102;0;26;0
WireConnection;38;0;32;0
WireConnection;38;1;36;0
WireConnection;100;0;19;0
WireConnection;40;0;38;0
WireConnection;40;1;102;0
WireConnection;59;0;98;0
WireConnection;59;1;58;0
WireConnection;59;2;99;0
WireConnection;59;3;57;1
WireConnection;101;0;88;0
WireConnection;60;0;59;0
WireConnection;95;0;40;0
WireConnection;95;1;101;0
WireConnection;95;2;100;0
WireConnection;95;3;96;0
WireConnection;95;4;97;1
WireConnection;64;0;60;0
WireConnection;63;0;95;0
WireConnection;67;0;65;0
WireConnection;67;1;66;0
WireConnection;70;0;67;0
WireConnection;0;2;70;0
ASEEND*/
//CHKSM=03F8E4E05B61BF52434BD66B37CF8E0B7221A9B4