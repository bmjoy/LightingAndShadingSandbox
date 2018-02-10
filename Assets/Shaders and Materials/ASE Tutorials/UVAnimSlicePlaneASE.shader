// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pipeworks_Custom/Animated UV Slice Plane"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MapARGB("Map A (RGB)", 2D) = "white" {}
		_MapBRGB("Map B (RGB)", 2D) = "white" {}
		_UVPanDirection("UV Pan Direction", Vector) = (0.5,0.5,0,0)
		_UVPanSpeed("UV Pan Speed", Range( 0 , 10)) = 1
		_SlicePlanePosn("Slice Plane Posn", Range( -4 , 4)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform sampler2D _MapARGB;
		uniform float4 _MapARGB_ST;
		uniform sampler2D _MapBRGB;
		uniform float _UVPanSpeed;
		uniform float2 _UVPanDirection;
		uniform half _SlicePlanePosn;
		uniform float _Cutoff = 0.5;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MapARGB = i.uv_texcoord * _MapARGB_ST.xy + _MapARGB_ST.zw;
			float2 uv_TexCoord4 = i.uv_texcoord * float2( 1,1 ) + float2( 0,0 );
			float2 panner9 = ( uv_TexCoord4 + ( _Time.y * _UVPanSpeed ) * _UVPanDirection);
			o.Albedo = ( tex2D( _MapARGB, uv_MapARGB ) + tex2D( _MapBRGB, panner9 ) ).rgb;
			o.Alpha = 1;
			float3 ase_worldPos = i.worldPos;
			clip( ( ase_worldPos.y + _SlicePlanePosn ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=14401
434;91;1486;966;1995.838;772.8389;2.104643;True;False
Node;AmplifyShaderEditor.TimeNode;8;-1179.5,240.5;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;6;-1245.5,374.5;Float;False;Property;_UVPanSpeed;UV Pan Speed;4;0;Create;True;1;0.33;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;5;-963.5,187.5;Float;False;Property;_UVPanDirection;UV Pan Direction;3;0;Create;True;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-943.5,306.5;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-993.5,77.5;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;9;-701.5,124.5;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1.0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;12;-389.7784,290.7254;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;13;-474.7785,422.7254;Half;False;Property;_SlicePlanePosn;Slice Plane Posn;5;0;Create;True;0;1;-4;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-496.5,97.5;Float;True;Property;_MapBRGB;Map B (RGB);2;0;Create;True;None;5798ded558355430c8a9b13ee12a847c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-499.5,-85.5;Float;True;Property;_MapARGB;Map A (RGB);1;0;Create;True;None;b297077dae62c1944ba14cad801cddf5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-198.7784,362.7254;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;3;-163.5,-0.5;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Pipeworks_Custom/Animated UV Slice Plane;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;False;0;Custom;0.5;True;True;0;False;TransparentCutout;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;True;0;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;False;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;0;8;2
WireConnection;7;1;6;0
WireConnection;9;0;4;0
WireConnection;9;2;5;0
WireConnection;9;1;7;0
WireConnection;2;1;9;0
WireConnection;10;0;12;2
WireConnection;10;1;13;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;0;0;3;0
WireConnection;0;10;10;0
ASEEND*/
//CHKSM=1981499CE4D1ED62C78225D55BAC036D30FA170B