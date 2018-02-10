// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Pipeworks_Custom/UV Decal ASE"
{
	Properties
	{
		[NoScaleOffset]_BaseRGB("Base (RGB)", 2D) = "white" {}
		[Toggle]_UseMask("Use Mask", Float) = 0
		_MaskColor("Mask Color", Color) = (0,0,0,1)
		_UTile("U Tile", Range( 0.001 , 10)) = 1
		_VTile("V Tile", Range( 0.001 , 10)) = 1
		_UOffset("U Offset", Range( -10 , 10)) = 0
		_VOffset("V Offset", Range( -10 , 10)) = 0
		_UMin("U Min", Range( 0 , 10)) = 0
		_UMax("U Max", Range( 0 , 10)) = 1
		_VMin("V Min", Range( 0 , 10)) = 0
		_VMax("V Max", Range( 0 , 10)) = 1
		_RotUCenterOffset("Rot U Center Offset", Range( 0 , 10)) = 0
		_RotVCenterOffset("Rot V Center Offset", Range( 0 , 10)) = 0
		[Toggle]_RotationSnap("Rotation Snap", Float) = 1
		_UVRotation("UV Rotation", Range( -4 , 4)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform half _UTile;
		uniform half _VTile;
		uniform float _UOffset;
		uniform float _VOffset;
		uniform float _UMax;
		uniform float _VMax;
		uniform fixed4 _MaskColor;
		uniform fixed _UseMask;
		uniform sampler2D _BaseRGB;
		uniform float _UMin;
		uniform float _VMin;
		uniform float _RotUCenterOffset;
		uniform float _RotVCenterOffset;
		uniform fixed _RotationSnap;
		uniform float _UVRotation;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 appendResult120 = (float2(_UTile , _VTile));
			float2 appendResult23 = (float2(_UOffset , _VOffset));
			float2 uv_TexCoord11 = i.uv_texcoord * appendResult120 + appendResult23;
			float2 uvRaw103 = uv_TexCoord11;
			float uMax46 = _UMax;
			float vMax47 = _VMax;
			float2 appendResult96 = (float2(( 1.0 - ( uvRaw103.x / uMax46 ) ) , ( 1.0 - ( uvRaw103.y / vMax47 ) )));
			fixed uvMask111 = ( step( float2( 0,0 ) , appendResult96 ).x * step( float2( 0,0 ) , appendResult96 ).y * step( float2( 0,0 ) , uvRaw103 ).x * step( float2( 0,0 ) , uvRaw103 ).y );
			fixed3 uvMaskTinted132 = ( ( 1.0 - uvMask111 ) * (_MaskColor).rgb );
			float uMin45 = _UMin;
			float vMin48 = _VMin;
			float2 appendResult19 = (float2(uMin45 , vMin48));
			float2 uvMin140 = appendResult19;
			float2 appendResult20 = (float2(uMax46 , vMax47));
			float2 uvMax141 = appendResult20;
			float2 clampResult2 = clamp( uvRaw103 , uvMin140 , uvMax141 );
			float uCenter44 = saturate( ( ( _UMin + _UMax ) / 2.0 ) );
			float vCenter54 = saturate( ( ( _VMin + _VMax ) / 2.0 ) );
			float2 appendResult57 = (float2(( uCenter44 + _RotUCenterOffset ) , ( vCenter54 + _RotVCenterOffset )));
			float temp_output_102_0 = ( _UVRotation * -1.0 );
			float uvRotation108 = ( lerp(( temp_output_102_0 * 0.5 ),( trunc( temp_output_102_0 ) / 2.0 ),_RotationSnap) * UNITY_PI );
			float cos30 = cos( uvRotation108 );
			float sin30 = sin( uvRotation108 );
			float2 rotator30 = mul( clampResult2 - saturate( appendResult57 ) , float2x2( cos30 , -sin30 , sin30 , cos30 )) + saturate( appendResult57 );
			o.Albedo = ( uvMaskTinted132 + ( lerp(1.0,uvMask111,_UseMask) * (tex2D( _BaseRGB, rotator30 )).rgb ) );
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=14401
371;91;1549;964;2358.104;1327.771;1.986068;True;False
Node;AmplifyShaderEditor.CommentaryNode;8;-1967.511,-384.8179;Float;False;1609.093;948.8781;;29;19;20;46;45;48;47;54;44;43;53;41;51;50;40;18;14;17;16;2;120;103;11;23;22;21;121;122;140;141; UV Extents and Offset;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1910.019,-105.7258;Float;False;Property;_VOffset;V Offset;6;0;Create;True;0;0;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-1908.019,-174.7259;Float;False;Property;_UOffset;U Offset;5;0;Create;True;0;0;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-1913.021,-247.2966;Half;False;Property;_VTile;V Tile;4;0;Create;True;1;4;0.001;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-1910.145,-322.4242;Half;False;Property;_UTile;U Tile;3;0;Create;True;1;4;0.001;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;23;-1630.52,-148.726;Float;False;FLOAT2;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;120;-1635.162,-293.5209;Float;False;FLOAT2;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1427.829,-194.7482;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,2;False;1;FLOAT2;0.34,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;106;-1989.523,-1292.344;Float;False;2321.144;656.8346;;15;91;83;104;146;145;147;144;111;73;96;77;78;105;95;94;UV Masking;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;-1936.973,-1246.756;Float;False;103;0;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;103;-938.0974,-198.4444;Float;False;uvRaw;-1;True;1;0;FLOAT2;0.0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;58;-305.4484,-207.2687;Float;False;1343.532;774.4656;;16;108;33;107;32;109;30;64;57;62;66;61;55;56;60;59;110;UV Rotation;1,1,1,1;0;0
Node;AmplifyShaderEditor.RelayNode;83;-1727.583,-1241.431;Float;True;1;0;FLOAT2;0.0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1909.542,318.5683;Float;False;Property;_UMax;U Max;8;0;Create;True;1;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1907.542,387.5683;Float;False;Property;_VMax;V Max;10;0;Create;True;1;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1907.173,42.68536;Float;False;Property;_VMin;V Min;9;0;Create;True;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1909.173,-28.3146;Float;False;Property;_UMin;U Min;7;0;Create;True;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-286.7347,303.8353;Float;False;Property;_UVRotation;UV Rotation;14;0;Create;True;0;0;-4;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-1460.729,317.8796;Float;False;uMax;-1;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;146;-1527.617,-1083.321;Float;False;47;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-1459.29,122.5006;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-1460.972,217.7151;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;-1531.317,-1152.313;Float;False;46;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-1460.111,386.4148;Float;False;vMax;-1;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;91;-1530.332,-1241.415;Float;False;FLOAT2;1;0;FLOAT2;0.0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleDivideOpNode;147;-1267.727,-1029.448;Float;True;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;51;-1342.28,217.7444;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;2.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;66;115.2378,402.0822;Float;False;320.6052;139;Limit rotation to whole-pi increments.;2;65;37;;1,1,1,0;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;144;-1270.06,-1241.582;Float;True;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-4.859106,308.6731;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;-1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;41;-1341.29,122.5006;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;2.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;53;-1218.28,217.7444;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TruncOpNode;37;165.8052,440.7178;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;94;-1055.096,-1241.824;Float;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;95;-1053.096,-1029.825;Float;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;43;-1219.291,122.5006;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-185.7946,-41.80844;Float;False;44;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;78;-646.1813,-1217.552;Float;False;389.7761;273.8649;;2;69;71;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;96;-864.0419,-1145.123;Float;True;FLOAT2;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-1076.433,117.2153;Float;False;uCenter;-1;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-838.3471,-855.6013;Float;False;103;0;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;216.3168,309.08;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-278.588,28.51017;Float;False;Property;_RotUCenterOffset;Rot U Center Offset;11;0;Create;True;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;-183.6812,103.2562;Float;False;54;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-1460.24,41.83172;Float;False;vMin;-1;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-278.288,172.3101;Float;False;Property;_RotVCenterOffset;Rot V Center Offset;12;0;Create;True;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;65;289.7643,440.0074;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;2.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-1077.28,212.7444;Float;False;vCenter;-1;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;77;-644.2206,-924.0002;Float;False;382.443;270.2408;;2;70;72;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-1460.26,-28.90321;Float;False;uMin;-1;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;107;443.6615,304.157;Fixed;False;Property;_RotationSnap;Rotation Snap;13;0;Create;True;1;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;16.71222,-36.48989;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;70;-623.2207,-873.7593;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;16.41212,107.8101;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;20;-1240.181,342.4874;Float;False;FLOAT2;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;69;-626.2446,-1167.452;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;19;-1237.861,-4.715493;Float;False;FLOAT2;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;71;-497.2157,-1167.544;Float;True;FLOAT2;1;0;FLOAT2;0.0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;57;173.3538,-37.00187;Float;False;FLOAT2;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;33;653.1796,309.1354;Float;False;1;0;FLOAT;1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;72;-497.7777,-874.0002;Float;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;141;-1077.482,291.0508;Float;False;uvMax;-1;True;1;0;FLOAT2;0.0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;140;-1085.286,37.98442;Float;False;uvMin;-1;True;1;0;FLOAT2;0.0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;108;825.6528,302.8569;Float;False;uvRotation;-1;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;64;346.9422,-36.94781;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;2;-627.4934,-102.8471;Float;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;135;481.3474,-826.3362;Float;False;1291.836;332.3657;;6;132;126;127;125;124;112;UV Mask Colorize;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-130.8773,-1038.03;Float;True;4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;325.7398,30.86999;Float;False;108;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;86.54268,-1043.778;Fixed;False;uvMask;-1;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;30;594.0803,-103.365;Float;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;531.3473,-776.3361;Float;True;111;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;125;893.8104,-702.9703;Fixed;False;Property;_MaskColor;Mask Color;2;0;Create;True;0,0,0,1;1,0,0,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;124;724.6066,-771.5095;Float;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;1067.135,-131.738;Float;True;Property;_BaseRGB;Base (RGB);0;1;[NoScaleOffset];Create;True;None;6b2910686f14f5844bf4707db2d5e2ba;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;127;1108.851,-702.9706;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;1176.807,-212.4275;Float;False;111;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;136;1355.873,-235.5527;Fixed;False;Property;_UseMask;Use Mask;1;0;Create;True;0;2;0;FLOAT;1.0;False;1;FLOAT;1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;1334.21,-771.1309;Float;True;2;2;0;FLOAT;0.0,0,0;False;1;FLOAT3;0.0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;99;1356.015,-132.1546;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;133;1569.648,-226.4173;Float;False;132;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;1576.015,-150.1546;Float;True;2;2;0;FLOAT;0.0,0,0;False;1;FLOAT3;0.0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;132;1534.785,-776.5028;Fixed;False;uvMaskTinted;-1;True;1;0;FLOAT3;0.0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;131;1806.065,-172.787;Float;True;2;2;0;FLOAT3;0.0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2028.471,-172.7725;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Pipeworks_Custom/UV Decal ASE;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;23;0;21;0
WireConnection;23;1;22;0
WireConnection;120;0;121;0
WireConnection;120;1;122;0
WireConnection;11;0;120;0
WireConnection;11;1;23;0
WireConnection;103;0;11;0
WireConnection;83;0;104;0
WireConnection;46;0;17;0
WireConnection;40;0;14;0
WireConnection;40;1;17;0
WireConnection;50;0;16;0
WireConnection;50;1;18;0
WireConnection;47;0;18;0
WireConnection;91;0;83;0
WireConnection;147;0;91;1
WireConnection;147;1;146;0
WireConnection;51;0;50;0
WireConnection;144;0;91;0
WireConnection;144;1;145;0
WireConnection;102;0;32;0
WireConnection;41;0;40;0
WireConnection;53;0;51;0
WireConnection;37;0;102;0
WireConnection;94;0;144;0
WireConnection;95;0;147;0
WireConnection;43;0;41;0
WireConnection;96;0;94;0
WireConnection;96;1;95;0
WireConnection;44;0;43;0
WireConnection;110;0;102;0
WireConnection;48;0;16;0
WireConnection;65;0;37;0
WireConnection;54;0;53;0
WireConnection;45;0;14;0
WireConnection;107;0;110;0
WireConnection;107;1;65;0
WireConnection;62;0;55;0
WireConnection;62;1;59;0
WireConnection;70;1;105;0
WireConnection;61;0;56;0
WireConnection;61;1;60;0
WireConnection;20;0;46;0
WireConnection;20;1;47;0
WireConnection;69;1;96;0
WireConnection;19;0;45;0
WireConnection;19;1;48;0
WireConnection;71;0;69;0
WireConnection;57;0;62;0
WireConnection;57;1;61;0
WireConnection;33;0;107;0
WireConnection;72;0;70;0
WireConnection;141;0;20;0
WireConnection;140;0;19;0
WireConnection;108;0;33;0
WireConnection;64;0;57;0
WireConnection;2;0;103;0
WireConnection;2;1;140;0
WireConnection;2;2;141;0
WireConnection;73;0;71;0
WireConnection;73;1;71;1
WireConnection;73;2;72;0
WireConnection;73;3;72;1
WireConnection;111;0;73;0
WireConnection;30;0;2;0
WireConnection;30;1;64;0
WireConnection;30;2;109;0
WireConnection;124;0;112;0
WireConnection;6;1;30;0
WireConnection;127;0;125;0
WireConnection;136;1;134;0
WireConnection;126;0;124;0
WireConnection;126;1;127;0
WireConnection;99;0;6;0
WireConnection;100;0;136;0
WireConnection;100;1;99;0
WireConnection;132;0;126;0
WireConnection;131;0;133;0
WireConnection;131;1;100;0
WireConnection;0;0;131;0
ASEEND*/
//CHKSM=D000A78C026088AF366D1F2C074180CC13918EB5