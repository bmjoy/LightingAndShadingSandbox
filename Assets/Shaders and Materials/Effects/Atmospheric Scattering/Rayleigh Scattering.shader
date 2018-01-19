// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pipeworks_Custom/Rayleigh Scattering ASE"
{
	Properties
	{
		_PlanetScale("Planet Scale", Range( 1 , 10)) = 1
		_AtmoshpereThickness("Atmoshpere Thickness", Range( 0 , 10)) = 0.1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" }
		Cull Back
		Blend One One
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			fixed filler;
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

		uniform float _AtmoshpereThickness;
		uniform float _PlanetScale;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			float3 atmosphereLVO28 = ( ( ase_vertexNormal * _AtmoshpereThickness ) + ( ( _PlanetScale - 1.0 ) * ase_vertexNormal ) );
			v.vertex.xyz += atmosphereLVO28;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			c.rgb = 0;
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
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=14204
1939;35;1796;1125;1188.051;8.4335;1.86;True;False
Node;AmplifyShaderEditor.CommentaryNode;30;-766.7435,512.7998;Float;False;1026;510;;9;2;10;20;28;22;26;18;1;27;// Atmosphere Local Vertex Offset;1,0,0,0;0;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-760.9697,758.6151;Float;False;Property;_PlanetScale;Planet Scale;1;0;Create;True;1;1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-486.1971,763.4261;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;2;-529.1119,850.4353;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;27;-551.1971,554.426;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1;-631.1995,687.9885;Float;False;Property;_AtmoshpereThickness;Atmoshpere Thickness;2;0;Create;True;0.1;0.05;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-302.1972,669.4262;Float;False;2;2;0;FLOAT3;0.0,0,0;False;1;FLOAT;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-300.1972,763.4261;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT3;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;31;-767.6632,-2.099487;Float;False;1037.258;408.9257;;2;0;29;// Master;1,0,0,0;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-153.1971,704.4261;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-526.0916,1196.205;Float;False;2;2;0;FLOAT4x4;0.0;False;1;FLOAT4;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;35;-713.0916,1242.205;Float;False;Constant;_Vector0;Vector 0;3;0;Create;True;0,0,0,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;34;-739.0916,1176.205;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;48.80252,699.4262;Float;False;atmosphereLVO;-1;True;1;0;FLOAT3;0.0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-337.2533,258.8087;Float;False;28;0;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;38;-144.4516,1196.325;Float;False;1;0;FLOAT4;0.0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-381.4513,1191.285;Float;False;planetCenter;-1;True;1;0;FLOAT4;0.0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;44.09964,11.17929;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Pipeworks_Custom/Rayleigh Scattering ASE;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;False;0;Custom;0.5;True;False;0;True;Transparent;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;False;4;One;One;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;False;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0.0,0,0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;20;0;10;0
WireConnection;26;0;27;0
WireConnection;26;1;1;0
WireConnection;18;0;20;0
WireConnection;18;1;2;0
WireConnection;22;0;26;0
WireConnection;22;1;18;0
WireConnection;36;0;34;0
WireConnection;36;1;35;0
WireConnection;28;0;22;0
WireConnection;38;0;39;0
WireConnection;39;0;36;0
WireConnection;0;11;29;0
ASEEND*/
//CHKSM=8411DFEF811739F5B83C685339CD1D714EF0754B