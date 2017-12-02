//Minnaert Vert/Frag shader with diffuse, spec, and normal map support.
Shader "Pipeworks_Custom/Minnaert"
{
	Properties
	{
		_baseTint("Base Tint", Color) = (1,1,1,1)
		_base("Base (RGB) Spec (A)", 2D) = "white" {}
		_normalMap("Normal", 2D) = "bump" {}
		_normalScale("Normal Scale", Range(0 , 5)) = 1
		_frenselPower("Rim Power", Range(1.0, 10.0)) = 2.5
		_rimColor("Rim Color", Color) = (1,1,1,1)
		_darken("Darken", Range(0.0, 10.0)) = 1
		_specPower("Specular Power", Range(0.0, 2.0)) = 0.3
		_specularColor("Specular Color", Color) = (1,1,1,1)
	}

	// Code pasted into all CGPROGRAM blocks
	CGINCLUDE
	#include "UnityCG.cginc"
	#include "UnityStandardUtils.cginc"

	// Reference the Unity library that includes all the lighting shadow macros
	#include "AutoLight.cginc"

	#pragma target 3.0
	#pragma vertex vert
	#pragma fragment frag

	uniform fixed3		_baseTint;
	uniform sampler2D	_base;
	uniform half4		_base_ST;
	uniform fixed4		_LightColor0;
	uniform float		_frenselPower;
	uniform fixed4		_rimColor;
	uniform sampler2D	_normalMap;
	uniform half4		_normalMap_ST;
	uniform float		_normalScale;
	uniform half		_darken;
	uniform half		_specPower;
	uniform fixed4		_specularColor;

	struct app2vert
	{
		float4 vertex 	: 	POSITION;
		fixed2 texCoord : 	TEXCOORD0;
		fixed4 normal 	:	NORMAL;
		fixed4 tangent	:	TANGENT;
	};

	struct vert2frag
	{
		float4 pos 		: 	SV_POSITION;
		fixed2 uvs		:	TEXCOORD0;
		half3 tspace0	:	TEXCOORD1;
		half3 tspace1	:	TEXCOORD2;
		half3 tspace2	:	TEXCOORD3;
		half3 posWorld	:	TEXCOORD4;
		fixed3 viewDir	:	TEXCOORD5;

		// The LIGHTING_COORDS macro (defined in AutoLight.cginc) defines the parameters needed to sample
		// the shadow map. The (6,7) specifies which unused TEXCOORD semantics to hold the sampled values.
		// I use TEXCOORD6 and TEXCOORD7 because TEXCOORD0-5 are already in use.
		LIGHTING_COORDS(6, 7)
	};

	// Fresnel term at normal incidence.
	float FZero()
	{
		return pow((1.0f - (1.0f / 1.31f)), 2) / pow((1.0f + (1.0f / 1.31f)), 2);
	}

	// Fresnel calculation.
	fixed frensel(fixed3 V, fixed3 L)
	{
		// Precalculate 1/2-vector
		fixed3 halfV = normalize(L + V);

		// Precalculate 1/2-vector falloff.
		fixed hdotV = dot(halfV, V);

		// Calculate fresnel falloff using Schlick's approximation.
		fixed base = 1.0 - hdotV;
		float exponential = pow(base, _frenselPower);
		fixed fresnel = exponential + FZero() * (1.0 - exponential);

		return fresnel;
	}

	// Minnaert shading
	fixed minnaert(fixed3 N, fixed3 L, fixed3 V)
	{
		fixed nDotL = dot(N, L);
		fixed nDotV = dot(N, V);
		return saturate(nDotL * pow(nDotL * nDotV, _darken));
	}

	// Blinn-Phong specular.
	fixed blinnPhong(fixed3 N, fixed3 L, fixed3 V)
	{
		fixed3 H = normalize(V + L);
		fixed ndotH = max(dot(N, H), 0.0);
		return saturate(pow(ndotH, (_specPower * 128.0)));
	}

	// Vert function.
	vert2frag vert(app2vert IN)
	{
		vert2frag OUT;

		float4x4 WorldInverseTranspose = unity_WorldToObject;
		float4x4 World = unity_ObjectToWorld;
		OUT.pos = UnityObjectToClipPos(IN.vertex);

		// The TRANSFER_VERTEX_TO_FRAGMENT macro populates the chosen LIGHTING_COORDS in the v2f structure
		// with appropriate values to sample from the shadow/lighting map
		TRANSFER_VERTEX_TO_FRAGMENT(OUT);

		OUT.posWorld = mul(World, IN.vertex).xyz;
		OUT.viewDir = normalize(_WorldSpaceCameraPos - OUT.posWorld);
		OUT.uvs = IN.texCoord;

		half3 wNormal = UnityObjectToWorldNormal(IN.normal);
		half3 wTangent = UnityObjectToWorldDir(IN.tangent.xyz);
		half tangentSign = IN.tangent.w * unity_WorldTransformParams.w;
		half3 wBitangent = cross(wNormal, wTangent) * tangentSign;

		OUT.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
		OUT.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
		OUT.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);

		return OUT;
	}

	// Fragment function.
	fixed4 frag(vert2frag IN) : COLOR
	{
		half2 diffuseUVs = TRANSFORM_TEX(IN.uvs, _base);
		fixed4 texSample = tex2D(_base, diffuseUVs);
		fixed3 diffuseC = texSample.xyz * _baseTint.xyz;
		fixed specMap = texSample.w;

		half2 normalUVs = TRANSFORM_TEX(IN.uvs, _normalMap);
		half3 tnormal = (UnpackScaleNormal(tex2D(_normalMap, normalUVs), _normalScale)).xyz;
		half3 worldNormal;
		worldNormal.x = dot(IN.tspace0, tnormal);
		worldNormal.y = dot(IN.tspace1, tnormal);
		worldNormal.z = dot(IN.tspace2, tnormal);
		half3 worldViewDir = normalize(UnityWorldSpaceViewDir(IN.posWorld));

		half3 worldRefl = reflect(-worldViewDir, worldNormal);
		half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldRefl);
		half3 skyColor = DecodeHDR(skyData, unity_SpecCube0_HDR);

		half3 pixelToLightSource = _WorldSpaceLightPos0.xyz - (IN.posWorld * _WorldSpaceLightPos0.w);
		fixed3 lightDirection = normalize(pixelToLightSource);
		fixed diffuseL = minnaert(worldNormal, lightDirection, IN.viewDir);

		// The LIGHT_ATTENUATION samples the shadowmap (using the coordinates calculated by TRANSFER_VERTEX_TO_FRAGMENT
		// and stored in the structure defined by LIGHTING_COORDS), and returns the value as a float.
		float unityAtten = LIGHT_ATTENUATION(IN);

		fixed rimLight = frensel(-IN.viewDir, lightDirection);
		rimLight *= saturate(dot(fixed3(0, 1, 0), worldNormal) * 0.5 + 0.5) * saturate(dot(fixed3(0, 1, 0), -IN.viewDir) + 1.75);
		fixed3 diffuse = _LightColor0.xyz * (diffuseL + (rimLight * diffuseL)) * unityAtten;
		diffuse = saturate(UNITY_LIGHTMODEL_AMBIENT.xyz + diffuse);
		rimLight *= (1 - diffuseL);
		diffuse = saturate(diffuse + (rimLight * _rimColor));

		// Diffuse color is added to spec and then multiplied by diffuse light.
		// This incorporates light attenuation/color and allows diffuse color to effect Cook Torrance lighting.
		fixed4 outColor;
		fixed specularHighlight = diffuseL * blinnPhong(worldNormal, lightDirection, IN.viewDir);
		fixed3 specular = (specularHighlight * _specularColor.rgb * _specularColor.a * specMap);
		outColor = fixed4(diffuse * (specular + diffuseC), 1.0);

		return outColor;
	}
	ENDCG

	SubShader
	{
		Pass
		{
			// This will be the base forward rendering pass in which ambient, vertex, and
			// main directional light will be applied; additional lights will need additional passes
			// using the "ForwardAdd" lightmode tag.
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			// This matches the "forward base" of the LightMode tag to ensure the shader compiles
			// properly for the forward bass pass. As with the LightMode tag, for any additional lights
			// this would be changed from _fwdbase to _fwdadd
			#pragma multi_compile_fwdbase
			ENDCG
		}

		// Second pass for additional lights.
		Pass
		{
			Tags { "LightMode" = "ForwardAdd" }
			Blend One One

			CGPROGRAM
			ENDCG
		}
	}
	// To receive or cast a shadow, shaders must implement the appropriate "Shadow Collector" or "Shadow Caster" pass.
	// Although we haven't explicitly done so in this shader, if these passes are missing they will be read from a fallback
	// shader instead, so specify one here to import the collector/caster passes used in that fallback.
	Fallback "Mobile/VertexLit"
}