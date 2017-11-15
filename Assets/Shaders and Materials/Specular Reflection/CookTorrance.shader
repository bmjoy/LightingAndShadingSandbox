//Cook Torrance Vert/Frag shader with diffuse, spec, and normal map support.
Shader "Pipeworks_Custom/Cook Torrance"
{
	Properties
	{
		_baseTint("Diffuse Tint", Color) = (1,1,1,1)
		_base("Diffuse Color (RGB) Spec (A)", 2D) = "white" {}
		_specularColor("Specular Color", Color) = (1,1,1,1)
		_roughness("Roughness", Range(0.0, 1.0)) = 0
		_schlick("Frensel Multiplier", Range(0.0, 1.0)) = 0
		_normalMap("Normal", 2D) = "bump" {}
		_normalScale("Normal Scale", Range(0 , 5)) = 1
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

	uniform fixed3 _baseTint;
	uniform sampler2D _base;
	uniform half4 _base_ST;
	uniform fixed4 _LightColor0;
	uniform half _FrenselPower;
	uniform fixed4 _rimColor;
	uniform half _specularPower;
	uniform fixed3 _specularColor;
	uniform sampler2D _normalMap;
	uniform half4 _normalMap_ST;
	uniform float _normalScale;
	uniform fixed _roughness;
	uniform fixed _schlick;

	struct app2vert
	{
		float4 vertex 	: 	POSITION;
		fixed2 texCoord : 	TEXCOORD0;
		fixed4 normal 	:	NORMAL;
		fixed4 tangent	:	TANGENT;
	};

	struct vert2frag
	{
		float4 pos 				: 	SV_POSITION;
		fixed2 uvs : TEXCOORD0;
		half3 tspace0			:	TEXCOORD1;
		half3 tspace1			:	TEXCOORD2;
		half3 tspace2			:	TEXCOORD3;
		half3 posWorld			:	TEXCOORD4;
		fixed3 viewDir : TEXCOORD5;

		// The LIGHTING_COORDS macro (defined in AutoLight.cginc) defines the parameters needed to sample
		// the shadow map. The (6,7) specifies which unused TEXCOORD semantics to hold the sampled values.
		// I use TEXCOORD6 and TEXCOORD7 because TEXCOORD0-5 are already in use.
		LIGHTING_COORDS(6, 7)
	};

	// Simple Lambert shading model.
	fixed lambert(fixed3 N, fixed3 L)
	{
		return saturate(dot(N, L));
	}

	// Valve Half-Lambert shading model (i.e. Lambert Wrap).
	fixed halfLambert(fixed3 N, fixed3 L)
	{
		half wrapConst = 0.5;
		half wrapped_NdotL = dot(N, L) * wrapConst + (1.0 - wrapConst);
		wrapped_NdotL *= wrapped_NdotL;
		return saturate( wrapped_NdotL );
	}

	// Cook Torrance lighting.
	fixed cookTorrance(fixed3 V, fixed3 N, fixed3 L)
	{
		// Precalculate 1/2-vector
		fixed3 halfV = normalize(L + V);

		// Precalculate non-saturated Lambertian.
		fixed ndotL = dot(N, L);

		// Precalculate Blinn falloff.
		fixed ndotH = dot(N, halfV);

		// Precalculate Fresnel falloff.
		fixed ndotV = dot(N, V);

		// Precalculate 1/2-vector falloff.
		fixed hdotV = dot(halfV, V);

		// Precalculate self shadowing.
		fixed shadowM = 2 * ndotH;

		// Precalculate light blocked by a neighboring facet towards the view vector.
		fixed shadowV = (shadowM * ndotV) / hdotV;

		// Precalculate light blocked by a neighboring facet towards the light vector.
		fixed shadowL = (shadowM * ndotL) / hdotV;

		// Precalculate facet self-shadowing.
		fixed shadow = min(1.0, min(shadowV, shadowL));

		// Avoid a perfectly smooth surface...and precalculate roughness squared.
		fixed roughSq = _roughness + 0.01;
		roughSq = saturate(roughSq * roughSq);

		// Calculate roughness.
		fixed ndotHSq = ndotH * ndotH;
		fixed ndotHQuad = ndotHSq * ndotHSq;
		fixed roughness = 1.0 / (4.0 * roughSq * ndotHQuad);
		roughness *= exp((ndotHSq - 1) / (ndotHSq * roughSq));

		// Calculate fresnel falloff using Schlick's approximation.
		fixed fresnel = 1 - hdotV;
		fresnel = fresnel * fresnel * fresnel * fresnel * fresnel;
		fresnel *= (1 - _schlick);
		fresnel += _schlick;

		// Final specular calculation.
		fixed specular = fresnel * shadow * roughness;
		specular /= (ndotV * ndotL);

		return saturate(specular);
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
		fixed diffuseL = halfLambert(worldNormal, lightDirection);

		// The LIGHT_ATTENUATION samples the shadowmap (using the coordinates calculated by TRANSFER_VERTEX_TO_FRAGMENT
		// and stored in the structure defined by LIGHTING_COORDS), and returns the value as a float.
		float unityAtten = LIGHT_ATTENUATION(IN);
		fixed3 diffuse = _LightColor0.xyz * diffuseL * unityAtten;
		diffuse = saturate(UNITY_LIGHTMODEL_AMBIENT.xyz + diffuse);

		// Diffuse color is added to spec and then multiplied by diffuse light.
		// This incorporates light attenuation/color and allows diffuse color to effect Cook Torrance lighting.
		fixed4 outColor;
		fixed specularHighlight = diffuseL * cookTorrance(IN.viewDir, worldNormal, lightDirection);
		fixed3 specular = (specularHighlight * _specularColor * specMap);

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