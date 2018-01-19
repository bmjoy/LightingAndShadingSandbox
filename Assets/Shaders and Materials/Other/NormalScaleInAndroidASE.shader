// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "NormalScaleAndroid"
{
	Properties
	{
		_NormalScale("Normal Scale", Float) = 5
		_Normals("Normals", 2D) = "bump" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		ZTest LEqual
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _NormalScale;
		uniform sampler2D _Normals;
		uniform float4 _Normals_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normals = i.uv_texcoord * _Normals_ST.xy + _Normals_ST.zw;
			float3 tex2DNode5 = UnpackScaleNormal( tex2D( _Normals, uv_Normals ) ,_NormalScale );
			float2 temp_output_12_0 = ( (tex2DNode5).xy * _NormalScale );
			float dotResult14 = dot( temp_output_12_0 , temp_output_12_0 );
			float3 appendResult9 = (float3(temp_output_12_0.x , temp_output_12_0.y , sqrt( ( 1.0 - saturate( dotResult14 ) ) )));
			#ifdef UNITY_NO_DXT5nm
				float3 staticSwitch6 = appendResult9;
			#else
				float3 staticSwitch6 = tex2DNode5;
			#endif
			o.Normal = staticSwitch6;
			float temp_output_8_0 = 0.5;
			float3 temp_cast_0 = (temp_output_8_0).xxx;
			o.Albedo = temp_cast_0;
			o.Smoothness = temp_output_8_0;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=14205
1939;35;1796;1125;1650.847;777.9811;1.39677;True;False
Node;AmplifyShaderEditor.RangedFloatNode;7;-2178.989,-118.8678;Float;False;Property;_NormalScale;Normal Scale;0;0;Create;True;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;20;-1666,-82;Float;False;1357;303;Scale normals manually because unity uses normal maps as regular texture in android (because they don't support DXT5nm format);8;12;10;14;15;16;17;9;11;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;5;-1956.633,-235.0886;Float;True;Property;_Normals;Normals;1;0;Create;True;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;11;-1616,0;Float;False;True;True;False;True;1;0;FLOAT3;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;19;-1950.219,37.1089;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-1376,16;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;14;-1152,80;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;15;-1008,80;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;16;-864,80;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;10;-1152,-32;Float;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SqrtOpNode;17;-704,80;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;9;-544,-32;Float;True;FLOAT3;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;18;-574.7174,-298.1212;Float;False;569.0002;191.4344;Making sure it only scales manually if it's android, otherwise carry on;1;6;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;6;-336,-240;Float;False;Property;_Keyword0;Keyword 0;2;0;Create;True;2;False;False;False;UNITY_NO_DXT5nm;Toggle;2;1;FLOAT3;0.0,0,0;False;0;FLOAT3;0.0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-176,-32;Float;False;Constant;_Float0;Float 0;1;0;Create;True;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;48,-272;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;NormalScaleAndroid;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;3;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;5;7;0
WireConnection;11;0;5;0
WireConnection;19;0;7;0
WireConnection;12;0;11;0
WireConnection;12;1;19;0
WireConnection;14;0;12;0
WireConnection;14;1;12;0
WireConnection;15;0;14;0
WireConnection;16;0;15;0
WireConnection;10;0;12;0
WireConnection;17;0;16;0
WireConnection;9;0;10;0
WireConnection;9;1;10;1
WireConnection;9;2;17;0
WireConnection;6;1;5;0
WireConnection;6;0;9;0
WireConnection;0;0;8;0
WireConnection;0;1;6;0
WireConnection;0;4;8;0
ASEEND*/
//CHKSM=C0DB36542E8F7DF59B93C37A6149A95FAA93782C