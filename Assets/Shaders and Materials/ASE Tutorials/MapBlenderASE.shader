// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pipeworks_Custom/Map Blender"
{
	Properties
	{
		_MapARGB("Map A (RGB)", 2D) = "white" {}
		_MapBRGB("Map B (RGB)", 2D) = "white" {}
		_MapANormalsScale("Map A Normals Scale", Range( 0.1 , 5)) = 1
		_MapANormals("Map A Normals", 2D) = "bump" {}
		_MapBNormalsScale("Map B Normals Scale", Range( 0.1 , 5)) = 1
		_MapBNormals("Map B Normals", 2D) = "bump" {}
		[Toggle]_BlendDirectionUV("Blend Direction UV", Float) = 0
		_BlendPosition("Blend Position", Range( 0 , 1)) = 0.5
		_BlendSoftness("Blend Softness", Range( 0.001 , 1)) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform half _MapANormalsScale;
		uniform sampler2D _MapANormals;
		uniform float4 _MapANormals_ST;
		uniform half _MapBNormalsScale;
		uniform sampler2D _MapBNormals;
		uniform float4 _MapBNormals_ST;
		uniform half _BlendPosition;
		uniform float _BlendDirectionUV;
		uniform half _BlendSoftness;
		uniform sampler2D _MapARGB;
		uniform float4 _MapARGB_ST;
		uniform sampler2D _MapBRGB;
		uniform float4 _MapBRGB_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MapANormals = i.uv_texcoord * _MapANormals_ST.xy + _MapANormals_ST.zw;
			float2 uv_MapBNormals = i.uv_texcoord * _MapBNormals_ST.xy + _MapBNormals_ST.zw;
			float2 uv_TexCoord1 = i.uv_texcoord * float2( 1,1 ) + float2( 0,0 );
			float clampResult15 = clamp( ( _BlendPosition + ( ( _BlendPosition - lerp(uv_TexCoord1.x,uv_TexCoord1.y,_BlendDirectionUV) ) / _BlendSoftness ) ) , 0.0 , 1.0 );
			half BLEND17 = clampResult15;
			float3 lerpResult9 = lerp( UnpackScaleNormal( tex2D( _MapANormals, uv_MapANormals ) ,_MapANormalsScale ) , UnpackScaleNormal( tex2D( _MapBNormals, uv_MapBNormals ) ,_MapBNormalsScale ) , BLEND17);
			o.Normal = lerpResult9;
			float2 uv_MapARGB = i.uv_texcoord * _MapARGB_ST.xy + _MapARGB_ST.zw;
			float2 uv_MapBRGB = i.uv_texcoord * _MapBRGB_ST.xy + _MapBRGB_ST.zw;
			float4 lerpResult6 = lerp( tex2D( _MapARGB, uv_MapARGB ) , tex2D( _MapBRGB, uv_MapBRGB ) , BLEND17);
			o.Albedo = lerpResult6.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=14401
495;91;1425;966;1972.009;260.6786;1.918308;True;False
Node;AmplifyShaderEditor.CommentaryNode;19;-1262.057,932.3695;Float;False;2108.088;544.3284;Calculate the blend location and softness.;9;15;13;14;3;12;16;2;1;17;BLEND CALCULATION;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-1212.057,1058.87;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;16;-893.2578,1076.17;Float;False;Property;_BlendDirectionUV;Blend Direction UV;6;0;Create;True;0;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-972.0574,1232.27;Half;False;Property;_BlendPosition;Blend Position;7;0;Create;True;0.5;0.54;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-565.9581,982.3695;Half;False;Property;_BlendSoftness;Blend Softness;8;0;Create;True;0.5;0.4;0.001;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;12;-498.5813,1057.72;Float;True;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;14;-204.0579,1058.87;Float;True;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;83.94208,1234.87;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;15;307.942,1234.87;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1151.087,626.9343;Half;False;Property;_MapBNormalsScale;Map B Normals Scale;4;0;Create;True;1;0.66;0.1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1150.087,455.9343;Half;False;Property;_MapANormalsScale;Map A Normals Scale;2;0;Create;True;1;3;0.1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-840.8123,358.8599;Float;True;Property;_MapANormals;Map A Normals;3;0;Create;True;None;f5453dca2ac649e4182c56a3966ad395;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;8;-835.3311,545.2264;Float;True;Property;_MapBNormals;Map B Normals;5;0;Create;True;None;0bebe40e9ebbecc48b8e9cfea982da7e;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-855.8851,-89.24281;Float;True;Property;_MapARGB;Map A (RGB);0;0;Create;True;None;c68296334e691ed45b62266cbc716628;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-851.7741,95.75376;Float;True;Property;_MapBRGB;Map B (RGB);1;0;Create;True;None;b297077dae62c1944ba14cad801cddf5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;629.6219,1230.063;Half;False;BLEND;-1;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-738.1206,285.1949;Float;False;17;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;6;-231.0075,-0.1704731;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;9;-233.6003,449.6729;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Pipeworks_Custom/Map Blender;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;16;0;1;1
WireConnection;16;1;1;2
WireConnection;12;0;2;0
WireConnection;12;1;16;0
WireConnection;14;0;12;0
WireConnection;14;1;3;0
WireConnection;13;0;2;0
WireConnection;13;1;14;0
WireConnection;15;0;13;0
WireConnection;7;5;10;0
WireConnection;8;5;11;0
WireConnection;17;0;15;0
WireConnection;6;0;4;0
WireConnection;6;1;5;0
WireConnection;6;2;18;0
WireConnection;9;0;7;0
WireConnection;9;1;8;0
WireConnection;9;2;18;0
WireConnection;0;0;6;0
WireConnection;0;1;9;0
ASEEND*/
//CHKSM=6A5C452D3CF757EABFBEE7715970281D706E4DBD