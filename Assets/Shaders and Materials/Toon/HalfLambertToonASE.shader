// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pipeworks_Custom/HalfLambertToonASE"
{
	Properties
	{
		_BaseTint("Base Tint", Color) = (0,0,0,0)
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
			half4 data60;
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
			float3 normalizeResult5_g14 = normalize( ( ase_worldlightDir + ase_worldViewDir ) );
			float dotResult6_g14 = dot( ase_worldNormal , normalizeResult5_g14 );
			o.data60 = ( saturate( pow( max( dotResult6_g14 , 0.0 ) , ( _GlossSpecPower * 128.0 ) ) ) * _SpecularIntensity * _SpecularColor * half4( _LightColor0.rgb , 0.0 ) );
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			float dotResult3_g24 = dot( i.worldNormal , ase_worldlightDir );
			float temp_output_6_0_g23 = (saturate( max( dotResult3_g24 , 0.0 ) )*0.65 + ( 1.0 - 0.65 ));
			float temp_output_92_0 = saturate( max( ( temp_output_6_0_g23 * temp_output_6_0_g23 ) , 0.0 ) );
			fixed4 temp_cast_0 = (( floor( ( _CellShadingLevels * temp_output_92_0 ) ) / ( _CellShadingLevels - 0.5 ) )).xxxx;
			float2 appendResult29 = (half2(temp_output_92_0 , 0.5));
			float2 uv_BaseRGB = i.uv_texcoord * _BaseRGB_ST.xy + _BaseRGB_ST.zw;
			fixed4 LIGHTING_DIFFUSE63 = ( lerp(temp_cast_0,tex2D( _ToonRampRGB, appendResult29 ),_UseRampTex) * tex2D( _BaseRGB, uv_BaseRGB ) * _BaseTint * 1 * half4( _LightColor0.rgb , 0.0 ) );
			fixed4 LIGHTING_SPECULAR64 = i.data60;
			c.rgb = saturate( ( LIGHTING_DIFFUSE63 + LIGHTING_SPECULAR64 ) ).rgb;
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
Version=13703
1953;34;1796;1125;3051.352;219.2405;1.91915;True;False
Node;AmplifyShaderEditor.CommentaryNode;42;-2324.834,161.9629;Float;False;846.5999;285;Cell shading via discrete levels.;5;37;38;36;32;35;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;94;-2641.224,587.8396;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;93;-2689.324,456.5403;Float;False;1;0;FLOAT;0.0;False;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;43;-2204.335,688.0059;Float;False;750.7957;250;Cell shading via ramp texture.;3;41;26;29;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-2312.834,263.9628;Float;False;Property;_CellShadingLevels;Cell Shading Levels;4;1;[IntRange];2;2;10;0;1;FLOAT
Node;AmplifyShaderEditor.FunctionNode;92;-2396.824,500.7399;Float;False;Lambert Wrap Base;-1;;23;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-1942.233,211.9627;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;41;-2175.335,783.7614;Fixed;False;Constant;_Const_05;Const_0.5;3;0;0.5;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;29;-1918.332,766.2617;Float;False;FLOAT2;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.RangedFloatNode;53;-2694.461,1299.187;Half;False;Property;_GlossSpecPower;Gloss (Spec Power);7;0;3;0;10;0;1;FLOAT
Node;AmplifyShaderEditor.FloorOpNode;32;-1781.233,211.9627;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleSubtractOpNode;36;-1947.233,334.9627;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.5;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;58;-2328.868,1443.613;Half;False;Property;_SpecularIntensity;Specular Intensity;6;0;1;0;10;0;1;FLOAT
Node;AmplifyShaderEditor.FunctionNode;86;-2405.596,1303.948;Float;False;Blinn-Phong Basic;-1;;14;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.LightColorNode;57;-2216.868,1671.614;Float;False;0;3;COLOR;FLOAT3;FLOAT
Node;AmplifyShaderEditor.SimpleDivideOpNode;38;-1601.233,311.9627;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;26;-1743.538,738.0059;Float;True;Property;_ToonRampRGB;Toon Ramp (RGB);3;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;71;-2260.416,1511.335;Fixed;False;Property;_SpecularColor;Specular Color;5;0;1,1,1,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-1990.87,1470.613;Float;False;4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;COLOR;0;False;3;FLOAT3;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;19;-1050.154,732.9639;Fixed;False;Property;_BaseTint;Base Tint;0;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ToggleSwitchNode;40;-1332.334,496.1624;Fixed;True;Property;_UseRampTex;Use Ramp  Tex;1;1;[Toggle];1;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.LightAttenuation;96;-817.8835,801.3792;Float;False;0;1;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;72;-1812.446,1427.036;Float;False;196.2;124.8;Bypass for per-pixel.;1;60;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;88;-1090.628,554.5291;Float;True;Property;_BaseRGB;Base (RGB);2;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LightColorNode;97;-811.9987,864.574;Float;False;0;3;COLOR;FLOAT3;FLOAT
Node;AmplifyShaderEditor.VertexToFragmentNode;60;-1797.87,1470.613;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-569.2635,500.0401;Float;False;5;5;0;COLOR;0.0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0,0,0,0;False;4;FLOAT3;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.GetLocalVarNode;65;-2558.184,-507.1738;Float;False;63;0;1;COLOR
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-353.9965,494.2263;Fixed;False;LIGHTING_DIFFUSE;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-1370.314,1464.334;Fixed;False;LIGHTING_SPECULAR;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.GetLocalVarNode;66;-2566.783,-439.5734;Float;False;64;0;1;COLOR
Node;AmplifyShaderEditor.SimpleAddOpNode;67;-2220.783,-483.5731;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SaturateNode;70;-2045.785,-483.5731;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-1810.822,-528.83;Half;False;True;2;Half;ASEMaterialInspector;0;0;CustomLighting;Pipeworks_Custom/HalfLambertToonASE;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;False;0;255;255;0;0;0;0;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;14;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;75;-2810.331,-750.5659;Float;False;3067.778;100;;0;// MASTER;0,0,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;73;-2813.472,1150.797;Float;False;3064.835;100;BLINN PHONG SPECULAR LIGHTING;0;// VERTEX PROGRAM;1,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;74;-2810.461,20.70782;Float;False;3073.664;100;HALF-LAMBERT DIFFUSE SHADING;0;//FRAGMENT PROGRAM;0.03448296,1,0,1;0;0
WireConnection;92;0;93;0
WireConnection;92;1;94;0
WireConnection;35;0;37;0
WireConnection;35;1;92;0
WireConnection;29;0;92;0
WireConnection;29;1;41;0
WireConnection;32;0;35;0
WireConnection;36;0;37;0
WireConnection;36;1;41;0
WireConnection;86;0;53;0
WireConnection;38;0;32;0
WireConnection;38;1;36;0
WireConnection;26;1;29;0
WireConnection;59;0;86;0
WireConnection;59;1;58;0
WireConnection;59;2;71;0
WireConnection;59;3;57;1
WireConnection;40;0;38;0
WireConnection;40;1;26;0
WireConnection;60;0;59;0
WireConnection;95;0;40;0
WireConnection;95;1;88;0
WireConnection;95;2;19;0
WireConnection;95;3;96;0
WireConnection;95;4;97;1
WireConnection;63;0;95;0
WireConnection;64;0;60;0
WireConnection;67;0;65;0
WireConnection;67;1;66;0
WireConnection;70;0;67;0
WireConnection;0;2;70;0
ASEEND*/
//CHKSM=8D1EFC97049453F0C6E90C252CA35A56F76F4D49